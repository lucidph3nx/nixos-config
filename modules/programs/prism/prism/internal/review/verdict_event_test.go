package review_test

// verdict_event_test.go — the shared verdict-event writer and its
// double-count guard (issue #2965).
//
// A completed review round reaches the worker by one of two paths: the
// detached monitor (persistReviewOutcome) or the sidecar recovery watcher
// (DeliverGroupResults). Both now emit the round's verdict event through the
// single helper writeVerdictEvent, so prism_review_verdicts_total counts a
// round exactly once regardless of which path delivered it.
//
// The guard is the deterministic event id: both paths derive the
// agent_events.id from the round's group_id and write INSERT OR IGNORE, so a
// second write for the same round is a no-op. These tests exercise that
// ordering directly — including the write-then-die-then-recover case that is
// the whole risk of the change.

import (
	"testing"
	"time"

	"github.com/google/uuid"

	"github.com/prismatic-koi/prism/internal/db"
	"github.com/prismatic-koi/prism/internal/review"
)

// countVerdictEvents returns the number of review.verdict_pass and
// review.verdict_fail rows recorded for the given worker session.
func countVerdictEvents(t *testing.T, d *db.DB, workerSession string) (pass, fail int) {
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

// TestWriteVerdictEvent_WritesSingleEvent verifies the happy path: one call
// writes exactly one verdict event, of the correct type, carrying the worker
// sessions row's instance_id (AC: same event type and instance ID the monitor
// path writes).
func TestWriteVerdictEvent_WritesSingleEvent(t *testing.T) {
	d := openTestDB(t)
	worker := "prism-test@verdict-single"
	iid := seedWorkerSession(t, d, worker)

	results := []review.AgentResult{
		makePassResult("review-goal"),
		makePassResult("review-code"),
		makePassResult("review-security"),
		makePassResult("review-qa"),
		makePassResult("review-context"),
	}
	review.WriteVerdictEventForTest(d, "grp-single", worker, results, true /*allPassed*/)

	pass, fail := countVerdictEvents(t, d, worker)
	if pass != 1 || fail != 0 {
		t.Fatalf("verdict events: got pass=%d fail=%d, want pass=1 fail=0", pass, fail)
	}

	// The event's instance_id must be the worker sessions row's, and its id
	// must be the deterministic one derived from the group.
	var gotIID, gotID string
	if err := d.QueryRow(
		`SELECT instance_id, id FROM agent_events WHERE session_name = ? AND type = ?`,
		worker, review.EventReviewVerdictPass,
	).Scan(&gotIID, &gotID); err != nil {
		t.Fatalf("read event row: %v", err)
	}
	if gotIID != iid {
		t.Errorf("event instance_id = %q, want %q (the worker sessions row)", gotIID, iid)
	}
	if want := review.VerdictEventIDForTest("grp-single"); gotID != want {
		t.Errorf("event id = %q, want %q (deterministic from group_id)", gotID, want)
	}
}

// TestWriteVerdictEvent_WriteThenRecover_NoDoubleCount is the core edge-case
// test for #2965. It exercises the write-then-die-then-recover ordering
// directly: the monitor writes the event (first call) and then dies before
// delivery; the recovery watcher later delivers the same round (second call
// with the same group_id). The round must count exactly once.
func TestWriteVerdictEvent_WriteThenRecover_NoDoubleCount(t *testing.T) {
	d := openTestDB(t)
	worker := "prism-test@verdict-no-double"
	seedWorkerSession(t, d, worker)

	results := []review.AgentResult{
		makePassResult("review-goal"),
		makeFailResult("review-code"),
	}
	const groupID = "grp-write-then-recover"

	// Monitor path writes the event, then (conceptually) dies before delivery.
	review.WriteVerdictEventForTest(d, groupID, worker, results, false /*allPassed*/)
	// Recovery path re-delivers the same round — same group_id.
	review.WriteVerdictEventForTest(d, groupID, worker, results, false /*allPassed*/)

	pass, fail := countVerdictEvents(t, d, worker)
	if pass != 0 || fail != 1 {
		t.Fatalf("verdict events after write-then-recover: got pass=%d fail=%d, want pass=0 fail=1 (exactly one, no double count)", pass, fail)
	}
}

// TestWriteVerdictEvent_DistinctGroups_DistinctEvents verifies the guard is
// scoped to the round, not the worker: two rounds (two group_ids) for the same
// worker write two events. A worker that runs round 1 then round 2 must count
// both.
func TestWriteVerdictEvent_DistinctGroups_DistinctEvents(t *testing.T) {
	d := openTestDB(t)
	worker := "prism-test@verdict-two-rounds"
	seedWorkerSession(t, d, worker)

	round1 := []review.AgentResult{makeFailResult("review-goal")}
	round2 := []review.AgentResult{makePassResult("review-goal")}

	review.WriteVerdictEventForTest(d, "grp-round-1", worker, round1, false /*allPassed*/)
	review.WriteVerdictEventForTest(d, "grp-round-2", worker, round2, true /*allPassed*/)

	pass, fail := countVerdictEvents(t, d, worker)
	if pass != 1 || fail != 1 {
		t.Fatalf("verdict events across two rounds: got pass=%d fail=%d, want pass=1 fail=1", pass, fail)
	}
}

// TestWriteVerdictEvent_NoSessionsRow_NoEvent verifies the edge-case AC: a
// worker with no sessions row writes no event and the helper does not error or
// panic.
func TestWriteVerdictEvent_NoSessionsRow_NoEvent(t *testing.T) {
	d := openTestDB(t)
	// No seedWorkerSession call — MostRecentSessionForName returns nil.
	worker := "prism-test@verdict-no-session"
	results := []review.AgentResult{makePassResult("review-goal")}

	review.WriteVerdictEventForTest(d, "grp-no-session", worker, results, true)

	pass, fail := countVerdictEvents(t, d, worker)
	if pass != 0 || fail != 0 {
		t.Fatalf("verdict events with no sessions row: got pass=%d fail=%d, want 0/0", pass, fail)
	}
}

// TestVerdictEventID_DeterministicPerGroup verifies the id derivation is
// stable for a group and distinct across groups — the property both delivery
// paths rely on to collapse to a single row.
func TestVerdictEventID_DeterministicPerGroup(t *testing.T) {
	a1 := review.VerdictEventIDForTest("group-A")
	a2 := review.VerdictEventIDForTest("group-A")
	b := review.VerdictEventIDForTest("group-B")

	if a1 != a2 {
		t.Errorf("verdictEventID not stable for the same group: %q vs %q", a1, a2)
	}
	if a1 == b {
		t.Errorf("verdictEventID collides across groups: %q == %q", a1, b)
	}
	if _, err := uuid.Parse(a1); err != nil {
		t.Errorf("verdictEventID is not a valid UUID: %q (%v)", a1, err)
	}
}

// TestWriteVerdictEvent_SecondWriteDoesNotMoveTimestamp is a belt-and-braces
// check that the ignored second write leaves the original row untouched — the
// first writer wins, matching SetGroupDeliveredAt's first-write-wins semantics.
func TestWriteVerdictEvent_SecondWriteDoesNotMoveTimestamp(t *testing.T) {
	d := openTestDB(t)
	worker := "prism-test@verdict-first-wins"
	seedWorkerSession(t, d, worker)
	const groupID = "grp-first-wins"
	results := []review.AgentResult{makePassResult("review-goal")}

	review.WriteVerdictEventForTest(d, groupID, worker, results, true)
	var firstCreatedAt int64
	if err := d.QueryRow(
		`SELECT created_at FROM agent_events WHERE id = ?`, review.VerdictEventIDForTest(groupID),
	).Scan(&firstCreatedAt); err != nil {
		t.Fatalf("read first created_at: %v", err)
	}

	time.Sleep(2 * time.Millisecond)
	review.WriteVerdictEventForTest(d, groupID, worker, results, true)

	var secondCreatedAt int64
	if err := d.QueryRow(
		`SELECT created_at FROM agent_events WHERE id = ?`, review.VerdictEventIDForTest(groupID),
	).Scan(&secondCreatedAt); err != nil {
		t.Fatalf("read second created_at: %v", err)
	}
	if firstCreatedAt != secondCreatedAt {
		t.Errorf("created_at changed across ignored second write: first=%d second=%d — want the first write to stick", firstCreatedAt, secondCreatedAt)
	}
}
