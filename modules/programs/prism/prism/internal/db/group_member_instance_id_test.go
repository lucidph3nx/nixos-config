package db_test

// group_member_instance_id_test.go — GroupMemberResult.InstanceID, the
// read-side projection added for the per-agent review verdict counter
// (issue #2963).
//
// The review monitor needs each member's OWN instance id to attribute a
// per-agent telemetry event to that agent rather than to the parent worker.
// The value is projected from agent_status; it is not a new column and there
// is no migration behind it.

import (
	"testing"

	"github.com/google/uuid"
)

// TestGroupResults_ProjectsMemberInstanceID verifies the projection: a member
// with an instance_id carries it, and a member whose column is NULL carries
// "" rather than failing the scan.
func TestGroupResults_ProjectsMemberInstanceID(t *testing.T) {
	d := openTestDB(t)

	groupID, err := d.RegisterGroup("nixos-config@feature")
	if err != nil {
		t.Fatalf("RegisterGroup: %v", err)
	}

	const withIID = "nixos-config@feature~review-1-review-goal"
	const withoutIID = "nixos-config@feature~review-1-review-code"
	for _, name := range []string{withIID, withoutIID} {
		if err := d.UpsertStatus(name, "nixos-config", "/wt", "finished", nil, nil); err != nil {
			t.Fatalf("UpsertStatus %s: %v", name, err)
		}
		if err := d.SetGroupID(name, groupID); err != nil {
			t.Fatalf("SetGroupID %s: %v", name, err)
		}
	}
	iid := uuid.New().String()
	if err := d.SetInstanceID(withIID, iid); err != nil {
		t.Fatalf("SetInstanceID: %v", err)
	}

	results, err := d.GroupResults(groupID)
	if err != nil {
		t.Fatalf("GroupResults: %v", err)
	}
	if got := results[withIID].InstanceID; got != iid {
		t.Errorf("InstanceID for the member with an instance = %q, want %q", got, iid)
	}
	if got := results[withoutIID].InstanceID; got != "" {
		t.Errorf("InstanceID for the member with NULL instance_id = %q, want \"\"", got)
	}
}

// TestGroupResultsAll_ProjectsMemberInstanceID pins the same projection on the
// historical variant, which shares the implementation but includes members
// whose agent_status row has been closed.
func TestGroupResultsAll_ProjectsMemberInstanceID(t *testing.T) {
	d := openTestDB(t)

	groupID, err := d.RegisterGroup("nixos-config@feature-all")
	if err != nil {
		t.Fatalf("RegisterGroup: %v", err)
	}
	const member = "nixos-config@feature-all~review-1-review-qa"
	if err := d.UpsertStatus(member, "nixos-config", "/wt", "finished", nil, nil); err != nil {
		t.Fatalf("UpsertStatus: %v", err)
	}
	if err := d.SetGroupID(member, groupID); err != nil {
		t.Fatalf("SetGroupID: %v", err)
	}
	iid := uuid.New().String()
	if err := d.SetInstanceID(member, iid); err != nil {
		t.Fatalf("SetInstanceID: %v", err)
	}
	if err := d.SetEnded(member); err != nil {
		t.Fatalf("SetEnded: %v", err)
	}

	results, err := d.GroupResultsAll(groupID)
	if err != nil {
		t.Fatalf("GroupResultsAll: %v", err)
	}
	if got := results[member].InstanceID; got != iid {
		t.Errorf("InstanceID for the closed member = %q, want %q", got, iid)
	}
}
