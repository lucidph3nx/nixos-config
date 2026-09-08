package podmanproxy

import "testing"

// TestNamePolicyChannels_DeclarationIsComplete guards the keyed-array
// shape of the declaration. A new index constant with no row leaves a
// zero row behind, and a zero row carries an empty deny reason — which
// would reach the audit log as a blank reason on a real refusal.
//
// The doclint rule reports the same class of defect against the prose.
// This test fails first, and in the package that owns the declaration.
func TestNamePolicyChannels_DeclarationIsComplete(t *testing.T) {
	ids := map[string]bool{}
	for i, c := range namePolicyChannels {
		if c.id == "" || c.configField == "" || c.checkFunc == "" || c.denyReason == "" {
			t.Errorf("namePolicyChannels[%d] is incomplete: %+v", i, c)
			continue
		}
		if ids[c.id] {
			t.Errorf("namePolicyChannels[%d] repeats id %q; the id names one channel", i, c.id)
		}
		ids[c.id] = true
		switch c.configField {
		case "ContainerNamePrefix", "VolumeNamePrefix":
		default:
			t.Errorf("namePolicyChannels[%d] names config field %q, which carries no prefix", i, c.configField)
		}
	}
}

// TestCreateVolumeChecks_DeclarationIsComplete is the same guard for the
// named-volume check set.
func TestCreateVolumeChecks_DeclarationIsComplete(t *testing.T) {
	gated := 0
	for i, c := range createVolumeChecks {
		if c.proseName == "" || len(c.denyReasons) == 0 {
			t.Errorf("createVolumeChecks[%d] is incomplete: %+v", i, c)
			continue
		}
		if c.prefixGated {
			gated++
		}
	}
	if gated == 0 {
		t.Error("no check is gated on the volume-name prefix; the empty-prefix back-compat path is gone")
	}
}

// TestVolumeNamePrefixFor_GateSemantics pins the behaviour every
// named-volume check now derives from the declaration: a gated check does
// not run against an empty prefix, an un-gated check always runs, and
// neither one alters the prefix it hands back.
func TestVolumeNamePrefixFor_GateSemantics(t *testing.T) {
	gatedCheck := createVolumeCheck{proseName: "gated", prefixGated: true}
	unGatedCheck := createVolumeCheck{proseName: "un-gated"}

	for _, tc := range []struct {
		name       string
		configured string
		check      createVolumeCheck
		wantPrefix string
		wantRun    bool
	}{
		{"gated with a prefix", "prism-abc-", gatedCheck, "prism-abc-", true},
		{"gated with no prefix", "", gatedCheck, "", false},
		{"un-gated with a prefix", "prism-abc-", unGatedCheck, "prism-abc-", true},
		{"un-gated with no prefix", "", unGatedCheck, "", true},
	} {
		t.Run(tc.name, func(t *testing.T) {
			p := &Proxy{cfg: Config{VolumeNamePrefix: tc.configured}}
			prefix, run := p.volumeNamePrefixFor(tc.check)
			if prefix != tc.wantPrefix || run != tc.wantRun {
				t.Fatalf("volumeNamePrefixFor(%s) = (%q, %t), want (%q, %t)",
					tc.check.proseName, prefix, run, tc.wantPrefix, tc.wantRun)
			}
		})
	}
}
