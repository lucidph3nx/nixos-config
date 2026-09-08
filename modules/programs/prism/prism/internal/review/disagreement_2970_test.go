package review_test

// disagreement_2970_test.go — the pipeline honouring review-goal's terminating
// PASS_WITH_DISAGREEMENT marker (issue #2970).
//
// Before #2970 the marker mapped to VerdictNone: AssessPassed returned
// (false, VerdictNone), the round classifier read the member as "produced no
// parseable verdict", the round did not count toward the 3-cycle limit, and
// the worker was told to re-run — a loop with no backstop, contradicting
// agents/review-goal.md, which promises the marker counts as PASS and the
// worker must not push more code.
//
// These tests pin the fixed behaviour across the surfaces the issue names:
// AssessPassed, the round classifier, the delivery message, the round/per-agent
// verdict events, and the spawn_outcome roll-up.

import (
	"strings"
	"testing"

	"github.com/prismatic-koi/prism/internal/db"
	"github.com/prismatic-koi/prism/internal/review"
)

// disagreementMarker is a review-goal assistant message that carries the
// terminating marker plus the <disagreement> block review-goal.md defines.
const disagreementMarker = "Requirements met.\n" +
	"<verdict>PASS_WITH_DISAGREEMENT</verdict>\n" +
	"<disagreement>\n" +
	"  Between-cycles concern: the flag name uses camelCase.\n" +
	"  Worker's position: matches the referenced ticket.\n" +
	"  Reviewer's position: repo convention is kebab-case.\n" +
	"  Decision needed from: coordinator\n" +
	"  Suggested resolution: accept as-is and track in a follow-up.\n" +
	"</disagreement>"

// disagreementRoundSessions returns the canonical five per-agent session names for a
// worker's first review round, in spawn order.
func disagreementRoundSessions(worker string) []string {
	roles := []string{"review-goal", "review-code", "review-security", "review-qa", "review-context"}
	out := make([]string, len(roles))
	for i, r := range roles {
		out[i] = worker + "~review-1-" + r
	}
	return out
}

// TestAssessPassed_PassWithDisagreement_TerminatingPass covers AC #2: the
// marker returns a terminating verdict kind and never VerdictNone.
func TestAssessPassed_PassWithDisagreement_TerminatingPass(t *testing.T) {
	passed, kind := review.AssessPassed(disagreementMarker)
	if !passed {
		t.Errorf("AssessPassed(marker) passed = false, want true — the marker is a terminating pass")
	}
	if kind == review.VerdictNone {
		t.Errorf("AssessPassed(marker) kind = VerdictNone, want VerdictPassWithDisagreement")
	}
	if kind != review.VerdictPassWithDisagreement {
		t.Errorf("AssessPassed(marker) kind = %v, want VerdictPassWithDisagreement", kind)
	}
}

// disagreementGroupData builds a complete five-agent round in which review-goal
// emits the marker and every other agent passes. failingCode, when true, makes
// review-code return a FAIL instead of a PASS.
func disagreementGroupData(sessions []string, failingCode bool) map[string]db.GroupMemberResult {
	gd := make(map[string]db.GroupMemberResult, len(sessions))
	for i, sess := range sessions {
		msg := "Looks good.\n<verdict>PASS</verdict>"
		switch {
		case i == 0:
			msg = disagreementMarker
		case i == 1 && failingCode:
			msg = "Problem here.\n<verdict>FAIL</verdict>"
		}
		gd[sess] = db.GroupMemberResult{
			SessionName: sess,
			InstanceID:  "iid-" + sess,
			State:       "finished",
			LastMessage: msg,
		}
	}
	return gd
}

// TestClassifyRound_Disagreement_TerminatesAsPass covers AC #1 and AC #3: a
// round in which review-goal emits the marker is complete (counts as a cycle),
// carries no FAIL, records the disagreement, and no member is classified as
// NoVerdictUnparseable.
func TestClassifyRound_Disagreement_TerminatesAsPass(t *testing.T) {
	sessions := disagreementRoundSessions("prism-test@w")
	agents := review.AgentsFromSessionsForTest(sessions)
	gd := disagreementGroupData(sessions, false)

	status := review.ClassifyRound(agents, sessions, gd, nil)

	if !status.Complete() {
		t.Errorf("status.Complete() = false, want true — every agent produced a verdict")
	}
	if !status.CountsAsCycle() {
		t.Errorf("status.CountsAsCycle() = false, want true — a complete round counts")
	}
	if status.HasFailVerdict() {
		t.Errorf("status.HasFailVerdict() = true, want false — the marker is not a FAIL")
	}
	if len(status.Missing) != 0 {
		t.Errorf("status.Missing = %v, want empty — the marker must NOT be NoVerdictUnparseable", status.Missing)
	}
	if !status.HasDisagreement() {
		t.Fatalf("status.HasDisagreement() = false, want true")
	}
	if len(status.Disagreements) != 1 {
		t.Fatalf("len(status.Disagreements) = %d, want 1", len(status.Disagreements))
	}
	d := status.Disagreements[0]
	if d.Agent != "review-goal" {
		t.Errorf("disagreement agent = %q, want review-goal", d.Agent)
	}
	if !strings.Contains(d.Detail, "kebab-case") {
		t.Errorf("disagreement detail did not carry the <disagreement> block: %q", d.Detail)
	}
}

// TestBuildDeliveryMessage_Disagreement_PassesAndEscalates covers AC #1 and
// AC #6: the delivery message terminates the round as a pass, does not tell the
// worker to re-run for a missing verdict, names the unresolved disagreement,
// and routes the decision to the coordinator via escalation.
func TestBuildDeliveryMessage_Disagreement_PassesAndEscalates(t *testing.T) {
	worker := "prism-test@w"
	sessions := disagreementRoundSessions(worker)
	agents := review.AgentsFromSessionsForTest(sessions)
	gd := disagreementGroupData(sessions, false)

	results := review.BuildMonitorResultsForTest(agents, sessions, gd)
	formatted, allPassed := review.FormatResults(results, "123", 1, 0)
	if !allPassed {
		t.Fatalf("FormatResults allPassed = false, want true — the marker terminates as a pass")
	}

	msg := review.BuildDeliveryMessageForTest("123", 1, formatted, allPassed, gd, sessions)

	if !strings.Contains(msg, "Review passed with an unresolved disagreement") {
		t.Errorf("delivery message missing the disagreement header:\n%s", msg)
	}
	if !strings.Contains(msg, "prism escalate") {
		t.Errorf("delivery message must route the decision to the coordinator via `prism escalate`:\n%s", msg)
	}
	if !strings.Contains(msg, "Do NOT push more code") {
		t.Errorf("delivery message must tell the worker not to push more code:\n%s", msg)
	}
	if !strings.Contains(msg, "kebab-case") {
		t.Errorf("delivery message must quote the disagreement so the coordinator sees it:\n%s", msg)
	}
	// The bug this fixes: the marker round used to be reported as "ran but
	// produced no parseable verdict" and the worker told to re-run.
	if strings.Contains(msg, "produced no parseable verdict") {
		t.Errorf("delivery message still reports the marker as an unparseable round:\n%s", msg)
	}
	if strings.Contains(msg, "does NOT count toward the 3-cycle limit") {
		t.Errorf("delivery message still treats the marker round as non-counting:\n%s", msg)
	}
}

// TestClassifyRound_DisagreementPlusFail_Fails covers AC #8: the marker
// terminates the round as a pass ONLY when no agent returned FAIL. A round
// carrying the marker AND a FAIL still fails.
func TestClassifyRound_DisagreementPlusFail_Fails(t *testing.T) {
	worker := "prism-test@w"
	sessions := disagreementRoundSessions(worker)
	agents := review.AgentsFromSessionsForTest(sessions)
	gd := disagreementGroupData(sessions, true) // review-code FAILs

	status := review.ClassifyRound(agents, sessions, gd, nil)
	if !status.HasFailVerdict() {
		t.Errorf("status.HasFailVerdict() = false, want true — a FAIL is present")
	}

	results := review.BuildMonitorResultsForTest(agents, sessions, gd)
	_, allPassed := review.FormatResults(results, "123", 1, 0)
	if allPassed {
		t.Fatalf("allPassed = true, want false — a FAIL beside the marker must fail the round")
	}

	msg := review.BuildDeliveryMessageForTest("123", 1, "results", allPassed, gd, sessions)
	if strings.Contains(msg, "Review passed with an unresolved disagreement") {
		t.Errorf("a round with a FAIL must not take the disagreement-pass branch:\n%s", msg)
	}
	if !strings.Contains(msg, "One or more review agents failed") {
		t.Errorf("a round with a FAIL must take the ordinary FAIL branch:\n%s", msg)
	}
}

// TestVerdictEvents_Disagreement_RoundAndAgentAgree covers AC #5: the round
// counter and the per-agent counter record a marker-carrying round
// consistently — the round records pass_with_disagreement and review-goal's
// per-agent event records pass_with_disagreement, never error and never fail.
func TestVerdictEvents_Disagreement_RoundAndAgentAgree(t *testing.T) {
	d := openTestDB(t)
	worker := "prism-test@verdict-disagreement-round"
	seedWorkerSession(t, d, worker)

	sessions := disagreementRoundSessions(worker)
	agents := review.AgentsFromSessionsForTest(sessions)
	// Seed each review-agent sessions row so the per-agent events resolve a role.
	gd := disagreementGroupData(sessions, false)
	for i, sess := range sessions {
		role := agents[i].Name
		_, iid := seedReviewAgentSession(t, d, worker, role)
		mr := gd[sess]
		mr.InstanceID = iid
		gd[sess] = mr
	}
	results := review.BuildMonitorResultsWithEndedForTest(agents, sessions, gd, nil)

	// A marker-carrying round terminates as a pass: allPassed is true.
	review.WriteVerdictEventForTest(d, "grp-disagreement-round", worker, results, true)

	// Round-level counter records pass_with_disagreement, not plain pass.
	roundPass, roundFail := countVerdictEvents(t, d, worker)
	if roundPass != 0 || roundFail != 0 {
		t.Errorf("round pass/fail events = %d/%d, want 0/0 — the round is pass_with_disagreement", roundPass, roundFail)
	}
	var roundPWD int
	if err := d.QueryRow(
		`SELECT COUNT(*) FROM agent_events WHERE session_name = ? AND type = ?`,
		worker, review.EventReviewVerdictPassWithDisagreement,
	).Scan(&roundPWD); err != nil {
		t.Fatalf("count round pass_with_disagreement events: %v", err)
	}
	if roundPWD != 1 {
		t.Errorf("round pass_with_disagreement events = %d, want 1", roundPWD)
	}

	// review-goal's per-agent event agrees.
	got := agentVerdictRowFor(t, d, sessions[0])
	if got.Type != review.EventReviewAgentVerdictPassWithDisagreement {
		t.Errorf("review-goal per-agent event = %q, want %q", got.Type, review.EventReviewAgentVerdictPassWithDisagreement)
	}
	if got.Type == review.EventReviewAgentVerdictError || got.Type == review.EventReviewAgentVerdictFail {
		t.Errorf("review-goal per-agent event must never be error or fail; got %q", got.Type)
	}
}
