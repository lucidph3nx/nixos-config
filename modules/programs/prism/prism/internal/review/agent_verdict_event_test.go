package review_test

// agent_verdict_event_test.go — the PER-AGENT verdict events (issue #2963).
//
// The shared writer emits two things for one completed round: one round event
// (covered by verdict_event_test.go) and one event for each review agent of
// the round. The per-agent events feed
// prism_review_agent_verdicts_total{verdict,agent_role,repo}, so the question
// "which review dimension fails most often" has an answer.
//
// Three properties carry the risk, and each has a test below:
//
//  1. The per-agent idempotency key is derived from the group AND the role.
//     Reusing the round's group-only key would collapse five agents into one
//     row under INSERT OR IGNORE and lose four verdicts silently.
//  2. An agent whose AgentResult.IsError is true records "error", never
//     "fail". An agent that never started is not a code-quality verdict.
//  3. The per-agent sum reconciles with the round count: five agent events
//     beside one round event, on every delivery.

import (
	"database/sql"
	"errors"
	"testing"
	"time"

	"github.com/google/uuid"

	"github.com/prismatic-koi/prism/internal/db"
	"github.com/prismatic-koi/prism/internal/review"
)

// reviewRoles is the production five-agent set, in order.
var reviewRoles = []string{"review-goal", "review-code", "review-security", "review-qa", "review-context"}

// seedReviewAgentSession inserts the sessions row for one review agent and
// returns its instance id. agent_events.instance_id is a foreign key into
// sessions, and the exporter resolves the agent_role label through the same
// row, so this is the shape the production spawn path produces.
func seedReviewAgentSession(t *testing.T, d *db.DB, workerSession, role string) (sessionName, instanceID string) {
	t.Helper()
	sessionName = workerSession + "~review-1-" + role
	instanceID = uuid.New().String()
	r := role
	if err := d.InsertSession(db.Session{
		InstanceID:  instanceID,
		SessionName: sessionName,
		Repo:        "prism-test-repo",
		Worktree:    "/tmp/" + workerSession,
		Harness:     "pi",
		AgentRole:   &r,
	}); err != nil {
		t.Fatalf("InsertSession(%s): %v", sessionName, err)
	}
	return sessionName, instanceID
}

// agentResult builds one AgentResult carrying the identity fields
// buildMonitorResults stamps in production: the review agent's own session
// name and instance id.
func agentResult(t *testing.T, d *db.DB, workerSession, role string, passed, isError bool) review.AgentResult {
	t.Helper()
	sessionName, instanceID := seedReviewAgentSession(t, d, workerSession, role)
	return review.AgentResult{
		Agent:       review.Agent{Name: role},
		Passed:      passed,
		IsError:     isError,
		Output:      "test output",
		SessionName: sessionName,
		InstanceID:  instanceID,
	}
}

// passingRound builds the five-agent all-pass round.
func passingRound(t *testing.T, d *db.DB, workerSession string) []review.AgentResult {
	t.Helper()
	results := make([]review.AgentResult, 0, len(reviewRoles))
	for _, role := range reviewRoles {
		results = append(results, agentResult(t, d, workerSession, role, true, false))
	}
	return results
}

// countAgentVerdictEvents returns the per-agent verdict-event counts for the
// whole database, by verdict.
func countAgentVerdictEvents(t *testing.T, d *db.DB) (pass, fail, errored int) {
	t.Helper()
	for _, c := range []struct {
		eventType string
		out       *int
	}{
		{review.EventReviewAgentVerdictPass, &pass},
		{review.EventReviewAgentVerdictFail, &fail},
		{review.EventReviewAgentVerdictError, &errored},
	} {
		if err := d.QueryRow(
			`SELECT COUNT(*) FROM agent_events WHERE type = ?`, c.eventType,
		).Scan(c.out); err != nil {
			t.Fatalf("count %s events: %v", c.eventType, err)
		}
	}
	return pass, fail, errored
}

// agentVerdictRow is the per-agent verdict event recorded for one review agent
// session, with agent_role resolved exactly as the exporter's lifecycle join
// resolves it: sessions joined on the EVENT's instance_id.
type agentVerdictRow struct {
	Role  string
	Type  string
	ID    string
	Found bool
}

// agentVerdictRowFor reads the per-agent verdict event for one review agent
// session name. Found is false when no such event was written.
func agentVerdictRowFor(t *testing.T, d *db.DB, sessionName string) agentVerdictRow {
	t.Helper()
	var r agentVerdictRow
	err := d.QueryRow(
		`SELECT COALESCE(s.agent_role, ''), ae.type, ae.id
		   FROM agent_events ae
		   LEFT JOIN sessions s ON s.instance_id = ae.instance_id
		  WHERE ae.session_name = ? AND ae.type IN (?, ?, ?)`,
		sessionName,
		review.EventReviewAgentVerdictPass,
		review.EventReviewAgentVerdictFail,
		review.EventReviewAgentVerdictError,
	).Scan(&r.Role, &r.Type, &r.ID)
	if errors.Is(err, sql.ErrNoRows) {
		return agentVerdictRow{}
	}
	if err != nil {
		t.Fatalf("read per-agent verdict event for %s: %v", sessionName, err)
	}
	r.Found = true
	return r
}

// TestWriteVerdictEvent_FiveAgents_FiveDistinctEvents covers the functional
// ACs: a completed round of five review agents produces five per-agent
// increments, each carrying its OWN instance id — which is what makes the
// exporter resolve agent_role to the review dimension rather than to the
// worker's role.
func TestWriteVerdictEvent_FiveAgents_FiveDistinctEvents(t *testing.T) {
	d := openTestDB(t)
	worker := "prism-test@agent-verdict-five"
	seedWorkerSession(t, d, worker)
	results := passingRound(t, d, worker)

	review.WriteVerdictEventForTest(d, "grp-five", worker, results, true /*allPassed*/)

	pass, fail, errored := countAgentVerdictEvents(t, d)
	if pass != 5 || fail != 0 || errored != 0 {
		t.Fatalf("per-agent verdict events: got pass=%d fail=%d error=%d, want 5/0/0", pass, fail, errored)
	}

	seenIDs := make(map[string]string, 5)
	for _, r := range results {
		got := agentVerdictRowFor(t, d, r.SessionName)
		if !got.Found {
			t.Fatalf("no per-agent verdict event for %s", r.SessionName)
		}
		if got.Role != r.Agent.Name {
			t.Errorf("agent_role resolved through the sessions join = %q, want %q", got.Role, r.Agent.Name)
		}
		if prev, dup := seenIDs[got.ID]; dup {
			t.Errorf("event id %q is shared by %s and %s; the key must include the agent role", got.ID, prev, r.SessionName)
		}
		seenIDs[got.ID] = r.SessionName
		if want := review.AgentVerdictEventIDForTest("grp-five", r.Agent.Name); got.ID != want {
			t.Errorf("event id for %s = %q, want %q (deterministic from group_id AND role)", r.Agent.Name, got.ID, want)
		}
	}
}

// TestWriteVerdictEvent_SameRoundTwice_ExactlyFiveAgentEvents is the
// double-count guard for the per-agent key. Delivering the same round twice —
// the monitor writing then dying, then the recovery watcher re-delivering —
// must leave exactly five per-agent events: not ten (no guard) and not one
// (the round's group-only key reused).
func TestWriteVerdictEvent_SameRoundTwice_ExactlyFiveAgentEvents(t *testing.T) {
	d := openTestDB(t)
	worker := "prism-test@agent-verdict-twice"
	seedWorkerSession(t, d, worker)
	results := passingRound(t, d, worker)
	const groupID = "grp-delivered-twice"

	review.WriteVerdictEventForTest(d, groupID, worker, results, true)
	review.WriteVerdictEventForTest(d, groupID, worker, results, true)

	pass, fail, errored := countAgentVerdictEvents(t, d)
	total := pass + fail + errored
	if total != 5 {
		t.Fatalf("per-agent verdict events after two deliveries = %d (pass=%d fail=%d error=%d), want exactly 5 — 10 means no guard, 1 means the round key was reused",
			total, pass, fail, errored)
	}

	// And the round counter still counts the round exactly once, so the two
	// counters reconcile.
	roundPass, roundFail := countVerdictEvents(t, d, worker)
	if roundPass+roundFail != 1 {
		t.Errorf("round verdict events after two deliveries: got pass=%d fail=%d, want exactly one", roundPass, roundFail)
	}
}

// TestWriteVerdictEvent_DistinctAgentsDistinctRows covers the mixed round: a
// parseable FAIL records "fail", and an infrastructure failure records
// "error" — never "fail". The two facts are different and the round-level
// failCount cannot tell them apart.
func TestWriteVerdictEvent_DistinctAgentsDistinctRows(t *testing.T) {
	d := openTestDB(t)
	worker := "prism-test@agent-verdict-mixed"
	seedWorkerSession(t, d, worker)

	results := []review.AgentResult{
		agentResult(t, d, worker, "review-goal", true, false),     // pass
		agentResult(t, d, worker, "review-code", false, false),    // parseable FAIL
		agentResult(t, d, worker, "review-security", false, true), // no-start / stall
		agentResult(t, d, worker, "review-qa", true, false),       // pass
		agentResult(t, d, worker, "review-context", false, false), // parseable FAIL
	}
	review.WriteVerdictEventForTest(d, "grp-mixed", worker, results, false /*allPassed*/)

	pass, fail, errored := countAgentVerdictEvents(t, d)
	if pass != 2 || fail != 2 || errored != 1 {
		t.Fatalf("per-agent verdicts: got pass=%d fail=%d error=%d, want 2/2/1", pass, fail, errored)
	}

	want := map[string]string{
		"review-goal":     review.EventReviewAgentVerdictPass,
		"review-code":     review.EventReviewAgentVerdictFail,
		"review-security": review.EventReviewAgentVerdictError,
		"review-qa":       review.EventReviewAgentVerdictPass,
		"review-context":  review.EventReviewAgentVerdictFail,
	}
	for _, r := range results {
		got := agentVerdictRowFor(t, d, r.SessionName)
		if got.Type != want[r.Agent.Name] {
			t.Errorf("%s recorded %q, want %q", r.Agent.Name, got.Type, want[r.Agent.Name])
		}
	}
}

// TestWriteVerdictEvent_IsErrorNeverRecordsFail pins the mapping edge the AC
// names explicitly: an AgentResult that is BOTH not-passed and IsError records
// "error" and never "fail", whatever else the round looks like.
func TestWriteVerdictEvent_IsErrorNeverRecordsFail(t *testing.T) {
	d := openTestDB(t)
	worker := "prism-test@agent-verdict-error-only"
	seedWorkerSession(t, d, worker)

	results := make([]review.AgentResult, 0, len(reviewRoles))
	for _, role := range reviewRoles {
		results = append(results, agentResult(t, d, worker, role, false, true))
	}
	review.WriteVerdictEventForTest(d, "grp-all-error", worker, results, false)

	pass, fail, errored := countAgentVerdictEvents(t, d)
	if fail != 0 {
		t.Errorf("per-agent fail events = %d, want 0 — an IsError result must never record verdict=\"fail\"", fail)
	}
	if pass != 0 || errored != 5 {
		t.Fatalf("per-agent verdicts: got pass=%d fail=%d error=%d, want 0/0/5", pass, fail, errored)
	}
}

// TestWriteVerdictEvent_AgentWithNoInstanceID_SkippedAloneCovers the
// edge-case AC: an agent whose instance id could not be resolved is skipped on
// its own — its role cannot be resolved, so the event would carry an empty
// agent_role — and the other four agents still record their verdicts.
func TestWriteVerdictEvent_AgentWithNoInstanceID_SkippedAlone(t *testing.T) {
	d := openTestDB(t)
	worker := "prism-test@agent-verdict-missing-iid"
	seedWorkerSession(t, d, worker)

	results := passingRound(t, d, worker)
	// The shape buildMonitorResults produces for a member that was reaped
	// mid-review: no group row, so no instance id.
	results[2].InstanceID = ""
	results[2].SessionName = ""
	results[2].Passed = false
	results[2].IsError = true

	review.WriteVerdictEventForTest(d, "grp-missing-iid", worker, results, false)

	pass, fail, errored := countAgentVerdictEvents(t, d)
	if pass != 4 || fail != 0 || errored != 0 {
		t.Fatalf("per-agent verdicts with one unresolvable agent: got pass=%d fail=%d error=%d, want 4/0/0", pass, fail, errored)
	}
	if agentVerdictRowFor(t, d, worker+"~review-1-review-security").Found {
		t.Errorf("the agent with no instance id recorded an event; it must be skipped")
	}

	// The round event is unaffected — the round still counts once.
	roundPass, roundFail := countVerdictEvents(t, d, worker)
	if roundPass != 0 || roundFail != 1 {
		t.Errorf("round verdict events: got pass=%d fail=%d, want pass=0 fail=1", roundPass, roundFail)
	}
}

// TestWriteVerdictEvent_NoWorkerSessionsRow_NoAgentEvents keeps the two
// counters in lockstep on the give-up path: when the worker has no sessions
// row the round event is skipped, and the per-agent events must be skipped
// too. Writing them alone would leave five agent verdicts with no round to
// reconcile against.
func TestWriteVerdictEvent_NoWorkerSessionsRow_NoAgentEvents(t *testing.T) {
	d := openTestDB(t)
	worker := "prism-test@agent-verdict-no-worker-row"
	// Deliberately no seedWorkerSession call.
	results := passingRound(t, d, worker)

	review.WriteVerdictEventForTest(d, "grp-no-worker-row", worker, results, true)

	pass, fail, errored := countAgentVerdictEvents(t, d)
	if pass != 0 || fail != 0 || errored != 0 {
		t.Fatalf("per-agent verdicts with no worker sessions row: got pass=%d fail=%d error=%d, want 0/0/0", pass, fail, errored)
	}
}

// TestWriteVerdictEvent_PerAgentSumReconcilesWithRound is the reconciliation
// AC on the monitor path: one round delivered through persistReviewOutcome
// writes one round event and five per-agent events, so
// sum(prism_review_agent_verdicts_total) over the round equals the agent count
// and prism_review_verdicts_total counts the round once.
func TestWriteVerdictEvent_PerAgentSumReconcilesWithRound(t *testing.T) {
	d := openTestDB(t)
	worker := "prism-test@agent-verdict-reconcile"
	seedWorkerSession(t, d, worker)
	results := passingRound(t, d, worker)

	review.PersistReviewOutcomeForTest(d, "grp-reconcile", worker, results, true)

	pass, fail, errored := countAgentVerdictEvents(t, d)
	if got := pass + fail + errored; got != len(results) {
		t.Errorf("per-agent verdict events = %d, want %d (one per agent)", got, len(results))
	}
	roundPass, roundFail := countVerdictEvents(t, d, worker)
	if roundPass+roundFail != 1 {
		t.Errorf("round verdict events = %d, want exactly 1", roundPass+roundFail)
	}
}

// TestAgentVerdictEventID_DerivedFromGroupAndRole pins the key derivation
// itself: stable for a (group, role) pair, distinct across roles within one
// group, distinct across groups, a valid UUID, and never equal to the round
// event id of the same group.
func TestAgentVerdictEventID_DerivedFromGroupAndRole(t *testing.T) {
	first := review.AgentVerdictEventIDForTest("group-A", "review-goal")
	again := review.AgentVerdictEventIDForTest("group-A", "review-goal")
	otherRole := review.AgentVerdictEventIDForTest("group-A", "review-code")
	otherGroup := review.AgentVerdictEventIDForTest("group-B", "review-goal")

	if first != again {
		t.Errorf("agentVerdictEventID not stable for the same (group, role): %q vs %q", first, again)
	}
	if first == otherRole {
		t.Errorf("agentVerdictEventID collides across roles in one group: %q — five agents would collapse to one row", first)
	}
	if first == otherGroup {
		t.Errorf("agentVerdictEventID collides across groups: %q == %q", first, otherGroup)
	}
	if first == review.VerdictEventIDForTest("group-A") {
		t.Errorf("agentVerdictEventID collides with the round event id of the same group: %q", first)
	}
	if _, err := uuid.Parse(first); err != nil {
		t.Errorf("agentVerdictEventID is not a valid UUID: %q (%v)", first, err)
	}
}

// TestAgentVerdictEventType_PassWithDisagreementRecordsError pins the bucket
// boundary review-context raised: a review-goal agent that ran to `finished`
// and emitted <verdict>PASS_WITH_DISAGREEMENT</verdict> records
// verdict="error", not "pass" and not "fail".
//
// This is a PIN, not an endorsement. AssessPassed maps the marker to
// VerdictNone, so the ROUND pipeline already treats such a member as having
// produced no parseable verdict (classifyMember, roundstatus.go). The
// per-agent counter follows that classification so the two counters cannot
// disagree about the same round. Whether the pipeline SHOULD treat the marker
// that way is a separate question about AssessPassed (#2862 / #2867), tracked
// as #2970 — the direction recorded there is to fix the pipeline, not to
// correct agents/review-goal.md.
//
// When #2970 lands, UPDATE this test to expect the new mapping. Do not delete
// it: #2970 says so explicitly, and the pin is what stops the pipeline change
// moving this metric silently. Change the metric HELP text and the
// review.EventReviewAgentVerdictError comment in the same commit.
func TestAgentVerdictEventType_PassWithDisagreementRecordsError(t *testing.T) {
	d := openTestDB(t)
	worker := "prism-test@agent-verdict-disagreement"
	seedWorkerSession(t, d, worker)

	// Drive the real classification path rather than hand-building the
	// AgentResult: the mapping under test starts at the assistant text.
	sessionName, instanceID := seedReviewAgentSession(t, d, worker, "review-goal")
	agents := []review.Agent{{Name: "review-goal"}}
	agentSessions := []string{sessionName}
	groupData := map[string]db.GroupMemberResult{
		sessionName: {
			SessionName: sessionName,
			InstanceID:  instanceID,
			State:       "finished",
			LastMessage: "summary\n<verdict>PASS_WITH_DISAGREEMENT</verdict>",
		},
	}
	results := review.BuildMonitorResultsForTest(agents, agentSessions, groupData)
	if !results[0].IsError {
		t.Fatalf("PASS_WITH_DISAGREEMENT produced IsError=false; the round pipeline changed — revisit the per-agent mapping and the EventReviewAgentVerdictError comment together")
	}

	review.WriteVerdictEventForTest(d, "grp-disagreement", worker, results, false)

	got := agentVerdictRowFor(t, d, sessionName)
	if got.Type != review.EventReviewAgentVerdictError {
		t.Errorf("PASS_WITH_DISAGREEMENT recorded %q, want %q", got.Type, review.EventReviewAgentVerdictError)
	}
	if got.Type == review.EventReviewAgentVerdictFail {
		t.Errorf("PASS_WITH_DISAGREEMENT must never record a FAIL verdict")
	}
}

// TestBuildMonitorResults_ReapedMemberKeepsItsInstanceID covers the gap
// review-context found: db.GroupResults drops every row whose ended_at is set,
// so a member reaped mid-round is absent from groupData — and those members
// are exactly the ones the "error" verdict exists to expose. The instance id
// is still in hand, on the endedRows read the same call already takes, so the
// agent must still record its verdict.
func TestBuildMonitorResults_ReapedMemberKeepsItsInstanceID(t *testing.T) {
	agents := []review.Agent{{Name: "review-goal"}, {Name: "review-code"}}
	agentSessions := []string{"prism-test@w~review-1-review-goal", "prism-test@w~review-1-review-code"}
	groupData := map[string]db.GroupMemberResult{
		agentSessions[0]: {
			SessionName: agentSessions[0],
			InstanceID:  "iid-goal",
			State:       "finished",
			LastMessage: "<verdict>PASS</verdict>",
		},
		// review-code was reaped mid-round: GroupResults drops it.
	}
	reapedIID := "iid-code"
	endedAt := time.Now()
	endedRows := map[string]db.Status{
		agentSessions[1]: {
			SessionName: agentSessions[1],
			State:       "error",
			InstanceID:  &reapedIID,
			EndedAt:     &endedAt,
		},
	}

	results := review.BuildMonitorResultsWithEndedForTest(agents, agentSessions, groupData, endedRows)
	if got := results[1].InstanceID; got != reapedIID {
		t.Errorf("reaped member InstanceID = %q, want %q — a reaped agent must still record its error verdict", got, reapedIID)
	}
	if !results[1].IsError {
		t.Errorf("reaped member IsError = false, want true")
	}
	if got := results[0].InstanceID; got != "iid-goal" {
		t.Errorf("live member InstanceID = %q, want %q — groupData must still win", got, "iid-goal")
	}
}

// TestBuildMonitorResults_ClearedInstanceIDStaysUnresolvable pins the half of
// the gap the endedRows fallback does NOT close: the tmux session-closed hook
// calls ClearInstanceID, which NULLs agent_status.instance_id. A member closed
// that way has no resolvable id on either read, and the writer skips it — the
// edge case the ACs sanction.
func TestBuildMonitorResults_ClearedInstanceIDStaysUnresolvable(t *testing.T) {
	agents := []review.Agent{{Name: "review-code"}}
	agentSessions := []string{"prism-test@w~review-1-review-code"}
	endedAt := time.Now()
	endedRows := map[string]db.Status{
		agentSessions[0]: {
			SessionName: agentSessions[0],
			State:       "error",
			InstanceID:  nil, // ClearInstanceID has already run.
			EndedAt:     &endedAt,
		},
	}

	results := review.BuildMonitorResultsWithEndedForTest(agents, agentSessions, map[string]db.GroupMemberResult{}, endedRows)
	if got := results[0].InstanceID; got != "" {
		t.Errorf("InstanceID = %q, want \"\" when agent_status.instance_id is NULL", got)
	}
}

// TestBuildMonitorResults_StampsAgentIdentity covers the plumbing the writer
// depends on: buildMonitorResults carries each member's own session name and
// instance id onto its AgentResult, and leaves the instance id empty for a
// member with no row on either read (the skip case above).
func TestBuildMonitorResults_StampsAgentIdentity(t *testing.T) {
	agents := []review.Agent{{Name: "review-goal"}, {Name: "review-code"}}
	agentSessions := []string{"prism-test@w~review-1-review-goal", "prism-test@w~review-1-review-code"}
	groupData := map[string]db.GroupMemberResult{
		agentSessions[0]: {
			SessionName: agentSessions[0],
			InstanceID:  "iid-goal",
			State:       "finished",
			LastMessage: "<verdict>PASS</verdict>",
		},
		// review-code has no row on either read.
	}

	results := review.BuildMonitorResultsForTest(agents, agentSessions, groupData)
	if len(results) != 2 {
		t.Fatalf("results = %d, want 2", len(results))
	}
	if results[0].InstanceID != "iid-goal" {
		t.Errorf("results[0].InstanceID = %q, want %q", results[0].InstanceID, "iid-goal")
	}
	if results[0].SessionName != agentSessions[0] {
		t.Errorf("results[0].SessionName = %q, want %q", results[0].SessionName, agentSessions[0])
	}
	if !results[0].Passed {
		t.Errorf("results[0].Passed = false, want true — the identity stamp must not disturb the verdict")
	}
	if results[1].InstanceID != "" {
		t.Errorf("results[1].InstanceID = %q, want \"\" for a member missing from the group data", results[1].InstanceID)
	}
	if !results[1].IsError {
		t.Errorf("results[1].IsError = false, want true for a missing member")
	}
}
