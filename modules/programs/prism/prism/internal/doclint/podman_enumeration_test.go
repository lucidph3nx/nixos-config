package doclint

import (
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"testing"
)

// cataloguePlaceholderRe matches the count placeholder of a catalogue
// phrase.
var cataloguePlaceholderRe = regexp.MustCompile(`\bN\b`)

// fixtureEdit is one mutation applied to a copy of the real source. An
// empty `old` appends `new` to the end of the file.
type fixtureEdit struct {
	rel string
	old string
	new string
}

// podmanFixture copies the two real trees the enumeration rules read —
// docs/ and internal/podmanproxy/ — into a fresh temp prism root, then
// applies the given mutations to the COPY. The real worktree is never
// written to.
//
// Every mutation test below is a revert-and-watch-fail pair by
// construction: TestPodmanEnumerations_RealTreeIsClean asserts the
// unmutated tree reports nothing, and each test here asserts that one
// mutation of it reports something specific.
func podmanFixture(t *testing.T, edits ...fixtureEdit) string {
	t.Helper()
	real, _, err := LocateRoots()
	if err != nil {
		t.Fatalf("LocateRoots: %v", err)
	}
	root := t.TempDir()
	for _, dir := range []string{"docs", podmanProxyPkgRel} {
		dest := filepath.Join(root, dir)
		if err := os.MkdirAll(filepath.Dir(dest), 0o755); err != nil {
			t.Fatal(err)
		}
		if err := os.CopyFS(dest, os.DirFS(filepath.Join(real, dir))); err != nil {
			t.Fatalf("copy %s: %v", dir, err)
		}
	}
	for _, e := range edits {
		applyFixtureEdit(t, root, e)
	}
	return root
}

func applyFixtureEdit(t *testing.T, root string, e fixtureEdit) {
	t.Helper()
	path := filepath.Join(root, e.rel)
	content, err := os.ReadFile(path)
	if err != nil {
		if !os.IsNotExist(err) || e.old != "" {
			t.Fatalf("read %s: %v", e.rel, err)
		}
		content = nil
	}
	text := string(content)
	switch {
	case e.old == "":
		text += e.new
	default:
		if n := strings.Count(text, e.old); n != 1 {
			t.Fatalf("fixture edit anchor for %s matched %d times, want 1:\n%s", e.rel, n, e.old)
		}
		text = strings.Replace(text, e.old, e.new, 1)
	}
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(path, []byte(text), 0o644); err != nil {
		t.Fatalf("write %s: %v", e.rel, err)
	}
}

// enumerationFindings runs the rules over a fixture root and keeps only
// the enumeration findings, so an unrelated identifier finding in a
// mutated copy cannot satisfy an assertion.
func enumerationFindings(root, repoRoot string) []Finding {
	var out []Finding
	for _, f := range scanPodmanEnumerations(root, repoRoot) {
		if f.Category == categoryEnumeration {
			out = append(out, f)
		}
	}
	return out
}

// wantFinding asserts that some finding carries the given rule and that
// its rendered text contains every needle.
func wantFinding(t *testing.T, findings []Finding, rule string, needles ...string) {
	t.Helper()
	for _, f := range findings {
		if f.Rule != rule {
			continue
		}
		text := f.String()
		ok := true
		for _, n := range needles {
			if !strings.Contains(text, n) {
				ok = false
				break
			}
		}
		if ok {
			return
		}
	}
	t.Fatalf("no %s finding matching %v; got:\n%s", rule, needles, renderFindings(findings))
}

func wantNoFindings(t *testing.T, findings []Finding) {
	t.Helper()
	if len(findings) != 0 {
		t.Fatalf("expected no enumeration findings, got:\n%s", renderFindings(findings))
	}
}

func renderFindings(findings []Finding) string {
	var b strings.Builder
	for _, f := range findings {
		b.WriteString("  ")
		b.WriteString(f.String())
		b.WriteByte('\n')
	}
	if b.Len() == 0 {
		return "  (none)\n"
	}
	return b.String()
}

// TestPodmanEnumerations_RealTreeIsClean is the baseline every mutation
// test below is measured against: the real declaration and the real prose
// agree. It also asserts the declaration actually parsed, so a parser that
// silently returns nothing cannot make the whole rule set vacuous.
func TestPodmanEnumerations_RealTreeIsClean(t *testing.T) {
	prismRoot, repoRoot, err := LocateRoots()
	if err != nil {
		t.Fatalf("LocateRoots: %v", err)
	}
	decls, findings := parsePodmanDecls(filepath.Join(prismRoot, podmanPolicyRel))
	if decls == nil {
		t.Fatalf("parsePodmanDecls returned no declarations: %s", renderFindings(findings))
	}
	if len(decls.channels) == 0 || len(decls.checks) == 0 {
		t.Fatalf("parsed %d channels and %d checks; both declarations must be found",
			len(decls.channels), len(decls.checks))
	}
	if len(decls.namedVolumeChannels()) == 0 {
		t.Fatal("parsed no named-volume channels; the subset the prose counts is empty")
	}
	gated, unGated := decls.gatedChecks()
	if len(gated) == 0 || len(unGated) == 0 {
		t.Fatalf("parsed %d gated and %d un-gated checks; the canonical section describes both sides",
			len(gated), len(unGated))
	}
	if !decls.gateSectionFound || decls.gateSeparatorAt == 0 {
		t.Fatal("the canonical gated/un-gated section was not found in the doc comment")
	}
	wantNoFindings(t, enumerationFindings(prismRoot, repoRoot))
}

// TestPodmanEnumerations_AddedChannelFailsProse covers the acceptance
// criterion that a channel added to the Go declaration, with no matching
// prose, fails the gate.
func TestPodmanEnumerations_AddedChannelFailsProse(t *testing.T) {
	root := podmanFixture(t,
		fixtureEdit{
			rel: podmanPolicyRel,
			old: "\tchDockerCompatVolumesMap: {",
			new: "\tchExtraVolumeChannel: {\n" +
				"\t\tid:          \"extra_test_channel\",\n" +
				"\t\tconfigField: \"VolumeNamePrefix\",\n" +
				"\t\tcheckFunc:   \"checkExtraVolumeNames\",\n" +
				"\t\tdenyReason:  \"extra_volume_name_prefix_mismatch\",\n" +
				"\t\tnamesVolume: true,\n" +
				"\t},\n" +
				"\tchDockerCompatVolumesMap: {",
		},
		fixtureEdit{
			rel: podmanPolicyRel,
			new: "\nfunc (p *Proxy) checkExtraVolumeNames() policyDecision {\n" +
				"\treturn denyDecision(403, namePolicyChannels[chExtraVolumeChannel].denyReason, \"test\")\n}\n",
		},
	)
	findings := enumerationFindings(root, "")
	wantFinding(t, findings, ruleChannelTable, "extra_test_channel", "no row of the canonical table")
	wantFinding(t, findings, ruleChannelCount, "named-volume channels", "declares 5")
}

// TestPodmanEnumerations_RenamedCheckFailsProse covers the acceptance
// criterion for a renamed check: the author updates the code and the
// declaration, and the canonical table still names the old function.
func TestPodmanEnumerations_RenamedCheckFailsProse(t *testing.T) {
	root := podmanFixture(t)
	policy := filepath.Join(root, podmanPolicyRel)
	src, err := os.ReadFile(policy)
	if err != nil {
		t.Fatal(err)
	}
	renamed := strings.ReplaceAll(string(src), "checkDockerCompatVolumeKey", "checkDockerCompatVolumeSpec")
	if err := os.WriteFile(policy, []byte(renamed), 0o644); err != nil {
		t.Fatal(err)
	}

	findings := enumerationFindings(root, "")
	wantFinding(t, findings, ruleChannelTable, "docker_compat_volumes_map_key", "checkDockerCompatVolumeSpec")
	wantFinding(t, findings, ruleChannelTable, "matches no channel declared in")
}

// TestPodmanEnumerations_RenamedCheckWithStaleDeclaration covers the same
// rename when the declaration itself is left behind.
func TestPodmanEnumerations_RenamedCheckWithStaleDeclaration(t *testing.T) {
	root := podmanFixture(t, fixtureEdit{
		rel: podmanPolicyRel,
		old: "func (p *Proxy) checkDockerCompatVolumeKey(key, spec string) policyDecision {",
		new: "func (p *Proxy) checkDockerCompatVolumeSpec(key, spec string) policyDecision {",
	})
	findings := enumerationFindings(root, "")
	wantFinding(t, findings, ruleChannelDecl, "checkDockerCompatVolumeKey", "does not declare")
	wantFinding(t, findings, ruleChannelDecl, "checkDockerCompatVolumeSpec", "declares checkFunc")
}

// TestPodmanEnumerations_RemovedCheckIsReported covers a check that stops
// deriving from the declaration — the shape a removed or open-coded check
// takes.
func TestPodmanEnumerations_RemovedCheckIsReported(t *testing.T) {
	root := podmanFixture(t, fixtureEdit{
		rel: podmanPolicyRel,
		old: "namePolicyChannels[chMountsVolume].denyReason",
		new: "\"mount_volume_name_prefix_mismatch\"",
	})
	findings := enumerationFindings(root, "")
	wantFinding(t, findings, ruleChannelDecl, "chMountsVolume", "no function in this file reads")
	wantFinding(t, findings, ruleChannelDecl, "mount_volume_name_prefix_mismatch", "take it from that row")
}

// TestPodmanEnumerations_UndeclaredDenyReasonIsReported covers a new
// named-volume check that arrives with its own audit reason and no row.
func TestPodmanEnumerations_UndeclaredDenyReasonIsReported(t *testing.T) {
	root := podmanFixture(t, fixtureEdit{
		rel: podmanPolicyRel,
		new: "\nfunc (p *Proxy) checkNewVolumeRule() policyDecision {\n" +
			"\treturn denyDecision(403, \"newchannel_volume_name_prefix_mismatch\", \"test\")\n}\n",
	})
	wantFinding(t, enumerationFindings(root, ""), ruleChannelDecl,
		"newchannel_volume_name_prefix_mismatch", "belongs to no row")
}

// TestPodmanEnumerations_UndeclaredVolumesReasonIsReported covers a new
// check on the top-level `volumes` key that no row of createVolumeChecks
// claims.
func TestPodmanEnumerations_UndeclaredVolumesReasonIsReported(t *testing.T) {
	root := podmanFixture(t, fixtureEdit{
		rel: podmanPolicyRel,
		new: "\nfunc (p *Proxy) checkNewVolumesShape() policyDecision {\n" +
			"\treturn denyDecision(403, \"create_volumes_unaudited_shape\", \"test\")\n}\n",
	})
	wantFinding(t, enumerationFindings(root, ""), ruleChannelDecl,
		"create_volumes_unaudited_shape", "belongs to no row of createVolumeChecks")
}

// TestPodmanEnumerations_DirectPrefixReadIsReported covers the funnel that
// keeps the gate in the declaration: a hand-rolled read of the config
// field bypasses the column the canonical section renders.
func TestPodmanEnumerations_DirectPrefixReadIsReported(t *testing.T) {
	root := podmanFixture(t, fixtureEdit{
		rel: podmanPolicyRel,
		new: "\nfunc (p *Proxy) checkHostBindGate() bool {\n\treturn p.cfg.VolumeNamePrefix == \"\"\n}\n",
	})
	wantFinding(t, enumerationFindings(root, ""), ruleChannelDecl,
		"checkHostBindGate", "reads cfg.VolumeNamePrefix directly")
}

// TestPodmanEnumerations_GateChangeFailsProse covers the acceptance
// criterion for the gated/un-gated enumeration: a change to which checks
// are gated fails the gate while the canonical prose still says otherwise.
func TestPodmanEnumerations_GateChangeFailsProse(t *testing.T) {
	root := podmanFixture(t, fixtureEdit{
		rel: podmanPolicyRel,
		old: "\t\tproseName:   \"NAME check\",\n\t\tprefixGated: true,",
		new: "\t\tproseName:   \"NAME check\",\n\t\tprefixGated: false,",
	})
	findings := enumerationFindings(root, "")
	wantFinding(t, findings, ruleGateSection, "NAME check", "declares this check un-gated")
	wantFinding(t, findings, ruleChannelCount, "gated", "declares 0")
}

// TestPodmanEnumerations_GateSectionHeadingRequired covers the anchor the
// gated/un-gated rule depends on: losing the canonical heading loses the
// enumeration, so the rule reports it rather than passing silently.
func TestPodmanEnumerations_GateSectionHeadingRequired(t *testing.T) {
	root := podmanFixture(t, fixtureEdit{
		rel: podmanPolicyRel,
		old: "// # What is gated on the prefix, and what is not",
		new: "// # Gating",
	})
	wantFinding(t, enumerationFindings(root, ""), ruleGateSection, "canonical section")
}

// TestPodmanEnumerations_RemovedTableRowIsReported covers prose that drops
// a channel the code still applies.
func TestPodmanEnumerations_RemovedTableRowIsReported(t *testing.T) {
	root := podmanFixture(t, fixtureEdit{
		rel: podmanDocRel,
		old: "| `POST /containers/create` top-level libpod `volumes` array `Name` | `VolumeNamePrefix` | `checkLibpodVolumesArray` | `create_volumes_name_prefix_mismatch` | forwarded |\n",
		new: "",
	})
	wantFinding(t, enumerationFindings(root, ""), ruleChannelTable,
		"libpod_volumes_array", "no row of the canonical table")
}

// TestPodmanEnumerations_WrongAbsentNameColumnIsReported covers the column
// that records whether a channel injects a name or refuses one. Getting it
// backwards tells a reader the proxy names their volume for them.
func TestPodmanEnumerations_WrongAbsentNameColumnIsReported(t *testing.T) {
	root := podmanFixture(t, fixtureEdit{
		rel: podmanDocRel,
		old: "| `checkMountedVolumeNames` | `bind_volume_name_prefix_mismatch` | forwarded |",
		new: "| `checkMountedVolumeNames` | `bind_volume_name_prefix_mismatch` | injected |",
	})
	wantFinding(t, enumerationFindings(root, ""), ruleChannelTable,
		"hostconfig_binds", "must say \"forwarded\"")
}

// TestPodmanEnumerations_MissingMarkersAreReported covers the region
// markers. Without them the rule has no canonical table to read, so it
// must fail rather than pass vacuously.
func TestPodmanEnumerations_MissingMarkersAreReported(t *testing.T) {
	root := podmanFixture(t, fixtureEdit{
		rel: podmanDocRel,
		old: "<!-- doclint-enumeration: name-policy-channels -->",
		new: "",
	})
	wantFinding(t, enumerationFindings(root, ""), ruleChannelTable, "marker is missing")
}

// TestPodmanEnumerations_StaleCountInDocIsReported covers the drift class
// that PR #2961 hit twice: prose that states the old number of channels.
func TestPodmanEnumerations_StaleCountInDocIsReported(t *testing.T) {
	root := podmanFixture(t, fixtureEdit{
		rel: podmanDocRel,
		old: "The prefix rule now applies to all four named-volume channels a",
		new: "The prefix rule now applies to all three named-volume channels a",
	})
	wantFinding(t, enumerationFindings(root, ""), ruleChannelCount,
		"three named-volume channels", "prose says 3")
}

// TestPodmanEnumerations_ThreatRowCountIsGoverned pins the T24 threat row
// of the podman-proxy doc. That row states the channel-derived count for
// the volume-name prefix, one line away from the T25 row the rule already
// governed, and a hand sweep left it out of the governed set.
//
// The anchor fails loudly if a future edit rewords the row out of a
// governed phrase, which is the failure this test exists to catch.
func TestPodmanEnumerations_ThreatRowCountIsGoverned(t *testing.T) {
	root := podmanFixture(t, fixtureEdit{
		rel: podmanDocRel,
		old: "on the four named-volume channels of a create body",
		new: "on the three named-volume channels of a create body",
	})
	wantFinding(t, enumerationFindings(root, ""), ruleChannelCount,
		"three named-volume channels", "prose says 3")
}

// TestPodmanEnumerations_StaleCountInPackageCommentIsReported covers the
// same drift inside the Go comments of the podman-proxy package, which is
// where the stale count of PR #2961 round 4 lived.
func TestPodmanEnumerations_StaleCountInPackageCommentIsReported(t *testing.T) {
	root := podmanFixture(t, fixtureEdit{
		rel: filepath.Join(podmanProxyPkgRel, "doc.go"),
		old: "//     The four container-create channels REFUSE",
		new: "//     The three container-create channels REFUSE",
	})
	wantFinding(t, enumerationFindings(root, ""), ruleChannelCount,
		"three container-create channels", "prose says 3")
}

// TestPodmanEnumerations_StaleGateCountInDocIsReported covers the second
// prose site of the gated/un-gated enumeration: the restatement in §8.3 of
// the podman-proxy doc, outside the canonical section.
func TestPodmanEnumerations_StaleGateCountInDocIsReported(t *testing.T) {
	root := podmanFixture(t, fixtureEdit{
		rel: podmanDocRel,
		old: "- One check of the four is gated, three are not.",
		new: "- Two checks of the four are gated, two are not.",
	})
	wantFinding(t, enumerationFindings(root, ""), ruleChannelCount,
		"Two checks of the four are gated", "prose says 2 gated checks")
}

// TestPodmanEnumerations_SkillProseIsGoverned covers the prose sites that
// live outside the Go subtree. They are scanned in a full checkout and
// absent in the nix sandbox build, so the rule must read them when the
// repo root is available and must not fail when it is not.
func TestPodmanEnumerations_SkillProseIsGoverned(t *testing.T) {
	root := podmanFixture(t)
	repoRoot := t.TempDir()
	skill := filepath.Join(repoRoot, "modules", "programs", "prism", "skills", "podman-proxy", "SKILL.md")
	if err := os.MkdirAll(filepath.Dir(skill), 0o755); err != nil {
		t.Fatal(err)
	}

	if err := os.WriteFile(skill, []byte("A create body reaches a volume through four named-volume channels.\n"), 0o644); err != nil {
		t.Fatal(err)
	}
	wantNoFindings(t, enumerationFindings(root, repoRoot))

	if err := os.WriteFile(skill, []byte("A create body reaches a volume through three named-volume channels.\n"), 0o644); err != nil {
		t.Fatal(err)
	}
	findings := enumerationFindings(root, repoRoot)
	wantFinding(t, findings, ruleChannelCount, "SKILL.md", "three named-volume channels")
}

// TestPodmanCountPatterns_PhrasesMatchTheirRegex is the first link of the
// catalogue chain: each pattern's phrase must be a phrase that pattern
// actually matches. The catalogue rule then holds docs/doclint.md to the
// phrases, so the doc cannot drift from the regexes through either link.
func TestPodmanCountPatterns_PhrasesMatchTheirRegex(t *testing.T) {
	for _, p := range podmanAllCountPatterns() {
		if p.phrase == "" {
			t.Errorf("pattern %s carries no catalogue phrase", p.re)
			continue
		}
		// "four" stands in for the count word the prose carries. Only a
		// standalone N is a placeholder: the N of `VolumeNamePrefix` and
		// the N of `NOT` are letters of a real word.
		sample := cataloguePlaceholderRe.ReplaceAllString(p.phrase, "four")
		m := p.re.FindStringSubmatch(sample)
		if m == nil {
			t.Errorf("phrase %q does not match its own pattern %s", p.phrase, p.re)
			continue
		}
		if got := len(m) - 1; got != len(p.want(&podmanDecls{})) {
			t.Errorf("phrase %q yields %d capture(s), and the pattern declares %d expected count(s)",
				p.phrase, got, len(p.want(&podmanDecls{})))
		}
	}
}

// TestPodmanEnumerations_CatalogueOmissionIsReported covers a recognised
// phrase that the catalogue in docs/doclint.md does not list. An author
// who reads the catalogue then believes that phrasing is unenforced.
func TestPodmanEnumerations_CatalogueOmissionIsReported(t *testing.T) {
	root := podmanFixture(t, fixtureEdit{
		rel: podmanDoclintDocRel,
		old: "N create-body channels              -> named-volume channels\n",
		new: "",
	})
	wantFinding(t, enumerationFindings(root, ""), rulePhraseCatalogue,
		"N create-body channels", "catalogue does not list it")
}

// TestPodmanEnumerations_CatalogueStrayEntryIsReported covers the other
// direction: an entry no pattern recognises promises enforcement that a
// prose site copying it never gets.
func TestPodmanEnumerations_CatalogueStrayEntryIsReported(t *testing.T) {
	root := podmanFixture(t, fixtureEdit{
		rel: podmanDoclintDocRel,
		old: "The other N are NOT gated           -> un-gated checks\n",
		new: "The other N are NOT gated           -> un-gated checks\n" +
			"N volume-name surfaces              -> a phrase no pattern reads\n",
	})
	wantFinding(t, enumerationFindings(root, ""), rulePhraseCatalogue,
		"N volume-name surfaces", "no count pattern recognises")
}

// TestPodmanEnumerations_CatalogueMarkersAreRequired keeps the catalogue
// rule from passing vacuously when the markers go missing.
func TestPodmanEnumerations_CatalogueMarkersAreRequired(t *testing.T) {
	root := podmanFixture(t, fixtureEdit{
		rel: podmanDoclintDocRel,
		old: "<!-- doclint-enumeration: count-phrases -->",
		new: "",
	})
	wantFinding(t, enumerationFindings(root, ""), rulePhraseCatalogue, "count-phrase catalogue")
}

// TestPodmanEnumerations_SubsetProseDoesNotFail covers the edge case the
// acceptance criteria call out: prose that describes a deliberate subset —
// a function doc comment that covers only the channels that function
// handles — must not fail the rule.
func TestPodmanEnumerations_SubsetProseDoesNotFail(t *testing.T) {
	root := podmanFixture(t,
		fixtureEdit{
			rel: podmanPolicyRel,
			new: "\n// checkTwoOfThem covers two channels, two consequences. It handles\n" +
				"// the two channels that carry a name inside a colon-delimited\n" +
				"// string, and says nothing about the others.\nfunc (p *Proxy) checkTwoOfThem() {}\n",
		},
		fixtureEdit{
			rel: filepath.Join("docs", "zz-subset-example.md"),
			new: "This section covers only the two channels that a `HostConfig` carries.\n" +
				"The other pair is described in three channels' worth of detail elsewhere.\n",
		},
	)
	wantNoFindings(t, enumerationFindings(root, ""))
}

// TestPodmanEnumerations_AbsentDocSkipsRules keeps the rules quiet on a
// scan root that carries no podman-proxy doc — the synthetic roots the
// rest of this package's tests build.
func TestPodmanEnumerations_AbsentDocSkipsRules(t *testing.T) {
	root := synthPrismRoot(t)
	wantNoFindings(t, enumerationFindings(root, ""))
}

// TestPodmanEnumerations_AbsentPolicyFileIsReported is the other half of
// the pair above: a tree that HAS the canonical doc and no declaration to
// check it against must fail, not skip.
func TestPodmanEnumerations_AbsentPolicyFileIsReported(t *testing.T) {
	root := podmanFixture(t)
	if err := os.Remove(filepath.Join(root, podmanPolicyRel)); err != nil {
		t.Fatal(err)
	}
	wantFinding(t, enumerationFindings(root, ""), ruleChannelDecl, "could not be read")
}
