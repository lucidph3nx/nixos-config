package db

// DB-layer tests for the pending_disagreement column on agent_status (#2977).
// These exercise SetPendingDisagreement, ConsumePendingDisagreement, and
// ClearPendingDisagreement — the backstop that lets a worker's finish
// notification surface an unresolved review disagreement when the worker did
// not run `prism escalate`.

import (
	"path/filepath"
	"testing"
)

func openPendingDisagreementTestDB(t *testing.T) *DB {
	t.Helper()
	path := filepath.Join(t.TempDir(), "pending-disagreement.db")
	d, err := Open(path)
	if err != nil {
		t.Fatalf("Open: %v", err)
	}
	t.Cleanup(func() { d.Close() })
	return d
}

// TestConsumePendingDisagreement_NoneRecorded asserts the common case: a
// session with no pending disagreement reports (false).
func TestConsumePendingDisagreement_NoneRecorded(t *testing.T) {
	d := openPendingDisagreementTestDB(t)
	const session = "prism-test@disagreement-none"
	if err := d.UpsertStatus(session, "prism-test", "/tmp/w", "active", nil, nil); err != nil {
		t.Fatalf("UpsertStatus: %v", err)
	}

	text, ok, err := d.ConsumePendingDisagreement(session)
	if err != nil {
		t.Fatalf("ConsumePendingDisagreement: %v", err)
	}
	if ok {
		t.Errorf("ok = true, want false (no disagreement recorded); text=%q", text)
	}
}

// TestSetAndConsumePendingDisagreement_Roundtrip asserts that a stored
// disagreement is returned exactly once, and cleared by the read.
func TestSetAndConsumePendingDisagreement_Roundtrip(t *testing.T) {
	d := openPendingDisagreementTestDB(t)
	const session = "prism-test@disagreement-roundtrip"
	if err := d.UpsertStatus(session, "prism-test", "/tmp/w", "active", nil, nil); err != nil {
		t.Fatalf("UpsertStatus: %v", err)
	}

	const want = "### Unresolved disagreement for the coordinator (1)\n\n- **review-goal**\n"
	if err := d.SetPendingDisagreement(session, want); err != nil {
		t.Fatalf("SetPendingDisagreement: %v", err)
	}

	got, ok, err := d.ConsumePendingDisagreement(session)
	if err != nil {
		t.Fatalf("ConsumePendingDisagreement: %v", err)
	}
	if !ok {
		t.Fatal("ok = false, want true")
	}
	if got != want {
		t.Errorf("got %q, want %q", got, want)
	}

	// Second consume must report nothing pending — a disagreement is
	// delivered at most once.
	got2, ok2, err := d.ConsumePendingDisagreement(session)
	if err != nil {
		t.Fatalf("ConsumePendingDisagreement (second): %v", err)
	}
	if ok2 {
		t.Errorf("second consume returned ok=true text=%q, want false (already consumed)", got2)
	}
}

// TestSetPendingDisagreement_EmptyStringClears asserts that
// SetPendingDisagreement("") clears a previously stored value, mirroring the
// "no disagreement this round" write path (persistPendingDisagreement in
// internal/review).
func TestSetPendingDisagreement_EmptyStringClears(t *testing.T) {
	d := openPendingDisagreementTestDB(t)
	const session = "prism-test@disagreement-clear-via-empty"
	if err := d.UpsertStatus(session, "prism-test", "/tmp/w", "active", nil, nil); err != nil {
		t.Fatalf("UpsertStatus: %v", err)
	}
	if err := d.SetPendingDisagreement(session, "stale disagreement from an earlier round"); err != nil {
		t.Fatalf("SetPendingDisagreement: %v", err)
	}
	if err := d.SetPendingDisagreement(session, ""); err != nil {
		t.Fatalf("SetPendingDisagreement(\"\"): %v", err)
	}

	_, ok, err := d.ConsumePendingDisagreement(session)
	if err != nil {
		t.Fatalf("ConsumePendingDisagreement: %v", err)
	}
	if ok {
		t.Error("disagreement still pending after SetPendingDisagreement(\"\")")
	}
}

// TestClearPendingDisagreement asserts the `prism escalate` path: a stored
// disagreement is discarded without being returned, mirroring the fact that
// the coordinator already received it verbatim via the escalation message.
func TestClearPendingDisagreement(t *testing.T) {
	d := openPendingDisagreementTestDB(t)
	const session = "prism-test@disagreement-escalate-clear"
	if err := d.UpsertStatus(session, "prism-test", "/tmp/w", "active", nil, nil); err != nil {
		t.Fatalf("UpsertStatus: %v", err)
	}
	if err := d.SetPendingDisagreement(session, "the disagreement text"); err != nil {
		t.Fatalf("SetPendingDisagreement: %v", err)
	}

	if err := d.ClearPendingDisagreement(session); err != nil {
		t.Fatalf("ClearPendingDisagreement: %v", err)
	}

	_, ok, err := d.ConsumePendingDisagreement(session)
	if err != nil {
		t.Fatalf("ConsumePendingDisagreement: %v", err)
	}
	if ok {
		t.Error("disagreement still pending after ClearPendingDisagreement")
	}
}

// TestSetPendingDisagreement_MissingRowIsNoop asserts the caller contract:
// SetPendingDisagreement against a session with no agent_status row is a
// silent no-op, not an error — it is a best-effort side channel, not a
// user-facing command.
func TestSetPendingDisagreement_MissingRowIsNoop(t *testing.T) {
	d := openPendingDisagreementTestDB(t)
	if err := d.SetPendingDisagreement("does-not-exist", "text"); err != nil {
		t.Fatalf("SetPendingDisagreement on missing row returned error: %v", err)
	}
}
