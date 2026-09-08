// Tests for the pending-disagreement finish-notification backstop (#2977).
//
// When a review round terminates on the PASS_WITH_DISAGREEMENT marker,
// internal/review persists the rendered disagreement section to the
// worker's agent_status.pending_disagreement column. These tests verify
// that:
//
//	(a) a plain finish notification with a pending disagreement carries it,
//	    verbatim, alongside the generic finish text;
//	(b) a plain finish notification with no pending disagreement is
//	    unchanged;
//	(c) a second finish notification does not re-deliver an
//	    already-consumed disagreement;
//	(d) a worker in the escalated state does not consume the pending
//	    disagreement — the notification is suppressed entirely by the
//	    existing escalated guard, and the pending record survives for a
//	    later, genuine finish.
//
// Isolation contract: every test uses sidecartest.NewIsolated and the
// "prism-test@" session-name prefix per AGENTS.md.
package sidecar

import (
	"strings"
	"testing"
)

const testDisagreementSection = "### Unresolved disagreement for the coordinator (1)\n\n" +
	"The decision on each item below belongs to the coordinator, not the worker.\n\n" +
	"- **review-goal** (`prism-test@worker~review-1-review-goal`)\n"

// TestNotifyCoordinator_PendingDisagreementSurfaced asserts AC (a): a
// worker with a pending disagreement that finishes normally (without
// escalating) delivers a notification carrying the verbatim disagreement
// section and naming the agent.
func TestNotifyCoordinator_PendingDisagreementSurfaced(t *testing.T) {
	workerSession := "prism-test@worker-disagreement-surfaced"
	coordSession := "prism-test@coordinator-disagreement-surfaced"
	repo := "prism-test"

	s, bus, tr := newMutedTestSidecar(t, workerSession, coordSession, repo)

	if err := bus.DB.SetPendingDisagreement(workerSession, testDisagreementSection); err != nil {
		t.Fatalf("SetPendingDisagreement: %v", err)
	}

	s.notifyCoordinator("")

	if got := tr.Count(); got != 1 {
		t.Fatalf("delivered %d coordinator notification(s); want 1", got)
	}
	text := tr.calls[0].text
	if !strings.Contains(text, "Agent "+workerSession+" has finished its current task") {
		t.Errorf("notification missing generic finish text: %q", text)
	}
	if !strings.Contains(text, testDisagreementSection) {
		t.Errorf("notification missing verbatim disagreement section: %q", text)
	}
	if !strings.Contains(text, "review-goal") {
		t.Errorf("notification does not name the disagreeing agent: %q", text)
	}
	if !strings.Contains(strings.ToLower(text), "without escalating") {
		t.Errorf("notification does not flag the missing escalation: %q", text)
	}
}

// TestNotifyCoordinator_NoPendingDisagreementUnchanged asserts AC (b): a
// round that carried no disagreement produces the plain, unchanged finish
// notification.
func TestNotifyCoordinator_NoPendingDisagreementUnchanged(t *testing.T) {
	workerSession := "prism-test@worker-disagreement-none"
	coordSession := "prism-test@coordinator-disagreement-none"
	repo := "prism-test"

	s, _, tr := newMutedTestSidecar(t, workerSession, coordSession, repo)

	s.notifyCoordinator("")

	if got := tr.Count(); got != 1 {
		t.Fatalf("delivered %d coordinator notification(s); want 1", got)
	}
	want := "Agent " + workerSession + " has finished its current task"
	if tr.calls[0].text != want {
		t.Errorf("notification text = %q, want unchanged generic text %q", tr.calls[0].text, want)
	}
}

// TestNotifyCoordinator_PendingDisagreementConsumedOnce asserts AC (c): a
// disagreement is delivered on the first finish notification, and a second
// finish for the same session does not re-deliver it.
func TestNotifyCoordinator_PendingDisagreementConsumedOnce(t *testing.T) {
	workerSession := "prism-test@worker-disagreement-once"
	coordSession := "prism-test@coordinator-disagreement-once"
	repo := "prism-test"

	s, bus, tr := newMutedTestSidecar(t, workerSession, coordSession, repo)

	if err := bus.DB.SetPendingDisagreement(workerSession, testDisagreementSection); err != nil {
		t.Fatalf("SetPendingDisagreement: %v", err)
	}

	s.notifyCoordinator("")
	s.notifyCoordinator("")

	if got := tr.Count(); got != 2 {
		t.Fatalf("delivered %d coordinator notification(s); want 2", got)
	}
	if !strings.Contains(tr.calls[0].text, testDisagreementSection) {
		t.Errorf("first notification missing disagreement: %q", tr.calls[0].text)
	}
	if strings.Contains(tr.calls[1].text, testDisagreementSection) {
		t.Errorf("second notification re-delivered the disagreement: %q", tr.calls[1].text)
	}
}

// TestNotifyCoordinator_EscalatedDoesNotConsumeDisagreement asserts AC (d):
// while the worker is in the escalated state, notifyCoordinator is
// suppressed entirely by the pre-existing escalated guard, and the pending
// disagreement is left untouched — a later, genuine finish (once the
// escalated state clears) can still see it if nothing else has cleared it
// in the meantime.
func TestNotifyCoordinator_EscalatedDoesNotConsumeDisagreement(t *testing.T) {
	workerSession := "prism-test@worker-disagreement-escalated"
	coordSession := "prism-test@coordinator-disagreement-escalated"
	repo := "prism-test"

	s, bus, tr := newMutedTestSidecar(t, workerSession, coordSession, repo)

	if err := bus.DB.SetPendingDisagreement(workerSession, testDisagreementSection); err != nil {
		t.Fatalf("SetPendingDisagreement: %v", err)
	}
	if err := bus.DB.UpsertStatus(workerSession, repo, "/tmp/test-worker-"+workerSession, "escalated", nil, nil); err != nil {
		t.Fatalf("UpsertStatus escalated: %v", err)
	}

	s.notifyCoordinator("")

	if got := tr.Count(); got != 0 {
		t.Fatalf("delivered %d coordinator notification(s) while escalated; want 0", got)
	}

	// The pending disagreement must still be there — the escalated guard
	// returned before the consume step ran.
	text, ok, err := bus.DB.ConsumePendingDisagreement(workerSession)
	if err != nil {
		t.Fatalf("ConsumePendingDisagreement: %v", err)
	}
	if !ok || text != testDisagreementSection {
		t.Errorf("pending disagreement was consumed or lost while escalated: ok=%v text=%q", ok, text)
	}
}
