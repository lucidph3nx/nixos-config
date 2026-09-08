package db_test

// disagreement_rollup_2970_test.go — the spawn_outcome review roll-up counts
// review-goal's terminating PASS_WITH_DISAGREEMENT marker distinctly from a
// missing verdict (issue #2970).
//
// Before #2970 the roll-up folded the marker to noneCount, and a round in
// which every agent passed but review-goal disagreed rolled up to "mixed".
// The fix counts the marker distinctly and rolls the round up to
// "pass_with_disagreement".

import (
	"testing"
	"time"

	"github.com/google/uuid"

	"github.com/prismatic-koi/prism/internal/db"
)

// seedDisagreementReviewRound seeds a closed five-agent round in which
// review-goal emitted PASS_WITH_DISAGREEMENT and the other four passed. It
// mirrors seedClosedReviewRound but with a per-role verdict.
func seedDisagreementReviewRound(t *testing.T, d *db.DB, parent string) string {
	t.Helper()
	groupID, err := d.RegisterGroupWithPR(parent, "2970", 1)
	if err != nil {
		t.Fatalf("RegisterGroupWithPR: %v", err)
	}
	roles := []string{"review-goal", "review-code", "review-qa", "review-security", "review-context"}
	for _, role := range roles {
		sess := parent + "~review-1-" + role
		verdict := "PASS"
		if role == "review-goal" {
			verdict = "PASS_WITH_DISAGREEMENT"
		}
		if err := d.UpsertStatus(sess, "prism-test-repo", "/tmp/test-wt", "finished", nil, nil); err != nil {
			t.Fatalf("UpsertStatus(%q): %v", sess, err)
		}
		if err := d.SetGroupID(sess, groupID); err != nil {
			t.Fatalf("SetGroupID(%q): %v", sess, err)
		}
		if err := d.WriteEvent(db.Event{
			ID:          uuid.New().String(),
			SessionName: sess,
			Repo:        "prism-test-repo",
			Worktree:    "/tmp/test-wt",
			Type:        "msg_assistant",
			Payload:     `{"text":"Reviewed.\n<verdict>` + verdict + `</verdict>"}`,
			CreatedAt:   time.Now(),
		}); err != nil {
			t.Fatalf("WriteEvent(%q): %v", sess, err)
		}
		if err := d.SetEnded(sess); err != nil {
			t.Fatalf("SetEnded(%q): %v", sess, err)
		}
	}
	return groupID
}

// TestComputeSpawnOutcome_DisagreementRollup covers AC #4: the roll-up counts
// the marker distinctly from a missing verdict — noneCount does NOT include
// the marker, and the round rolls up to the distinct "pass_with_disagreement"
// verdict rather than "mixed".
func TestComputeSpawnOutcome_DisagreementRollup(t *testing.T) {
	d := openTestDB(t)
	parent := "prism-test@disagreement-rollup"

	iid := uuid.New().String()
	if err := d.InsertSession(db.Session{
		InstanceID:  iid,
		SessionName: parent,
		Repo:        "prism-test-repo",
		Worktree:    "/tmp/test-wt",
		Harness:     "pi",
		StartedAt:   time.Now().Add(-5 * time.Minute),
	}); err != nil {
		t.Fatalf("InsertSession: %v", err)
	}
	seedDisagreementReviewRound(t, d, parent)

	// Fallback roll-up path — no UpdateSpawnOutcomeReviewResult call.
	out, err := d.ComputeSpawnOutcome(iid)
	if err != nil {
		t.Fatalf("ComputeSpawnOutcome: %v", err)
	}
	if out == nil || out.ReviewVerdict == nil {
		t.Fatal("ReviewVerdict is nil — the roll-up did not run")
	}
	if *out.ReviewVerdict != "pass_with_disagreement" {
		t.Errorf("ReviewVerdict = %q, want %q — the marker terminates the round as a pass", *out.ReviewVerdict, "pass_with_disagreement")
	}
	// The marker must NOT be folded into the missing-verdict count.
	if out.ReviewNoneCount == nil || *out.ReviewNoneCount != 0 {
		t.Errorf("ReviewNoneCount = %v, want 0 — the marker must not count as a missing verdict", out.ReviewNoneCount)
	}
	// The four plain passes are counted, and the marker is NOT among them.
	if out.ReviewPassCount == nil || *out.ReviewPassCount != 4 {
		t.Errorf("ReviewPassCount = %v, want 4", out.ReviewPassCount)
	}
	if out.ReviewFailCount == nil || *out.ReviewFailCount != 0 {
		t.Errorf("ReviewFailCount = %v, want 0", out.ReviewFailCount)
	}
}
