package sidecar

// verdict_event_recovery_test.go — end-to-end coverage that the recovery
// delivery path writes the round's verdict event, and does not double-count a
// round whose verdict event already exists (issue #2965).
//
// The unit tests under internal/review/ exercise the shared writer and its
// deterministic-id guard directly, including the write-then-die-then-recover
// ordering. This file drives the real review.DeliverGroupResults path — the
// recovery analogue of the back half of MonitorFunc — through the fake
// host-API /prompt socket, so the assertion is against the exact code the
// sidecar recovery watcher calls.
//
// Uses sidecartest.NewIsolated (via setupDeliveredAtFixture) per the
// isolation convention so no host-side prism state is touched.

import (
	"net/http"
	"testing"
	"time"

	"github.com/google/uuid"

	"github.com/prismatic-koi/prism/internal/db"
	"github.com/prismatic-koi/prism/internal/review"
)

// seedWorkerSessionRow inserts the sessions row that the verdict-event writer
// joins through (MostRecentSessionForName). The fixture's NewIsolated seeds
// only an agent_status row, which is the deliberate "no sessions row" case;
// tests that expect an event must add the sessions row explicitly. Returns the
// instance id the event should carry.
func seedWorkerSessionRow(t *testing.T, d *db.DB, workerSession, groupID string) string {
	t.Helper()
	iid := uuid.New().String()
	g := groupID
	if err := d.InsertSession(db.Session{
		InstanceID:  iid,
		SessionName: workerSession,
		Repo:        "prism-test",
		Worktree:    "/tmp/worktree",
		Harness:     "pi",
		GroupID:     &g,
		StartedAt:   time.Now().Add(-1 * time.Minute),
	}); err != nil {
		t.Fatalf("InsertSession(%s): %v", workerSession, err)
	}
	return iid
}

// countWorkerVerdictEvents returns the pass/fail verdict-event counts for the
// worker session.
func countWorkerVerdictEvents(t *testing.T, d *db.DB, workerSession string) (pass, fail int) {
	t.Helper()
	if err := d.QueryRow(
		`SELECT COUNT(*) FROM agent_events WHERE session_name = ? AND type = ?`,
		workerSession, review.EventReviewVerdictPass,
	).Scan(&pass); err != nil {
		t.Fatalf("count pass events: %v", err)
	}
	if err := d.QueryRow(
		`SELECT COUNT(*) FROM agent_events WHERE session_name = ? AND type = ?`,
		workerSession, review.EventReviewVerdictFail,
	).Scan(&fail); err != nil {
		t.Fatalf("count fail events: %v", err)
	}
	return pass, fail
}

// TestDeliverGroupResults_WritesVerdictEvent verifies the functional AC: a
// round the recovery watcher delivers writes exactly one verdict event, and it
// carries the worker sessions row's instance_id.
func TestDeliverGroupResults_WritesVerdictEvent(t *testing.T) {
	d, workerSession, groupID, sockPath := setupDeliveredAtFixture(t, "verdict-event-positive")
	iid := seedWorkerSessionRow(t, d, workerSession, groupID)

	srv, cleanup := startFakePromptServer(t, sockPath, http.StatusOK, `{"replayed":false}`)
	defer cleanup()
	_ = srv

	res, err := review.DeliverGroupResults(d, groupID, review.RecoveryDeliveryID(groupID))
	if err != nil {
		t.Fatalf("DeliverGroupResults: %v", err)
	}
	if !res.Delivered {
		t.Fatalf("DeliverGroupResults: Delivered=false, want true")
	}

	pass, fail := countWorkerVerdictEvents(t, d, workerSession)
	if pass+fail != 1 {
		t.Fatalf("verdict events after recovery delivery: got pass=%d fail=%d, want exactly one", pass, fail)
	}

	// The single event must carry the worker sessions row's instance_id.
	var gotIID string
	if err := d.QueryRow(
		`SELECT instance_id FROM agent_events WHERE session_name = ? AND type IN (?, ?)`,
		workerSession, review.EventReviewVerdictPass, review.EventReviewVerdictFail,
	).Scan(&gotIID); err != nil {
		t.Fatalf("read verdict event: %v", err)
	}
	if gotIID != iid {
		t.Errorf("event instance_id = %q, want %q", gotIID, iid)
	}
}

// TestDeliverGroupResults_TwiceNoDoubleCount drives the double-count guard
// through the real recovery path (issue #2965). Two deliveries of the same
// round — the shape the recovery watcher produces when it fires alongside, or
// after, a monitor that already emitted the event — must leave exactly one
// verdict event. Both deliveries route through the shared writer, whose
// group-derived event id makes the second write a no-op.
func TestDeliverGroupResults_TwiceNoDoubleCount(t *testing.T) {
	d, workerSession, groupID, sockPath := setupDeliveredAtFixture(t, "verdict-event-no-double")
	seedWorkerSessionRow(t, d, workerSession, groupID)

	srv, cleanup := startFakePromptServer(t, sockPath, http.StatusOK, `{"replayed":false}`)
	defer cleanup()
	_ = srv

	deliveryID := review.RecoveryDeliveryID(groupID)
	if _, err := review.DeliverGroupResults(d, groupID, deliveryID); err != nil {
		t.Fatalf("DeliverGroupResults (first): %v", err)
	}
	if pass, fail := countWorkerVerdictEvents(t, d, workerSession); pass+fail != 1 {
		t.Fatalf("after first delivery: got pass=%d fail=%d, want exactly one", pass, fail)
	}

	// Second delivery of the same round — the guard must suppress a second
	// verdict event.
	if _, err := review.DeliverGroupResults(d, groupID, deliveryID); err != nil {
		t.Fatalf("DeliverGroupResults (second): %v", err)
	}
	if pass, fail := countWorkerVerdictEvents(t, d, workerSession); pass+fail != 1 {
		t.Fatalf("after second delivery: got pass=%d fail=%d, want exactly one (no double count)", pass, fail)
	}
}

// TestDeliverGroupResults_NoSessionsRow_DeliversNoEvent verifies the edge-case
// AC: a recovery delivery for a worker with no sessions row writes no event and
// the delivery still completes. The default fixture seeds only an agent_status
// row, so this is the no-sessions-row case by construction.
func TestDeliverGroupResults_NoSessionsRow_DeliversNoEvent(t *testing.T) {
	d, workerSession, groupID, sockPath := setupDeliveredAtFixture(t, "verdict-event-no-session")
	// Deliberately NO seedWorkerSessionRow call.

	srv, cleanup := startFakePromptServer(t, sockPath, http.StatusOK, `{"replayed":false}`)
	defer cleanup()
	_ = srv

	res, err := review.DeliverGroupResults(d, groupID, review.RecoveryDeliveryID(groupID))
	if err != nil {
		t.Fatalf("DeliverGroupResults: %v", err)
	}
	if !res.Delivered {
		t.Fatalf("DeliverGroupResults: Delivered=false, want true (delivery must complete even with no sessions row)")
	}

	pass, fail := countWorkerVerdictEvents(t, d, workerSession)
	if pass != 0 || fail != 0 {
		t.Fatalf("verdict events with no sessions row: got pass=%d fail=%d, want 0/0", pass, fail)
	}
}
