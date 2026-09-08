package doclint

// The podman-proxy enumeration rules.
//
// internal/podmanproxy/policy.go declares the per-session name-policy
// channel set once (`namePolicyChannels`), and the named-volume check set
// once (`createVolumeChecks`). Prose across the repo enumerates the same
// two sets. A reader cannot hold the prose in step with the code by hand:
// on PR #2961 a deliberate sweep for stale channel counts missed a site,
// and the next review round found it. Issue #2974 records the rest.
//
// These rules make the code the source of truth and hold the prose to it:
//
//	podman-channel-decl    the declaration is internally consistent, and
//	                       every deny reason of the family is declared.
//	podman-channel-table   the canonical table in docs/podman-proxy.md
//	                       section 3 carries one row per declared channel,
//	                       and no row the declaration does not name.
//	podman-gate-section    the canonical doc comment above
//	                       checkCreateVolumeNames names every declared
//	                       check on the side of the gate the code declares.
//	podman-channel-count   a prose count phrase about the channel set
//	                       ("the four named-volume channels") states the
//	                       declared number.
//	podman-phrase-catalogue
//	                       the phrase list in docs/doclint.md names every
//	                       count phrase the rules recognise, and no other.
//
// Precision over recall, as with every other rule in this package. A count
// phrase that names a deliberate SUBSET ("two channels, two consequences"
// in the doc comment above checkMountedVolumeNames) matches none of the
// patterns and never produces a finding.

import (
	"fmt"
	"go/ast"
	"go/parser"
	"go/token"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"
)

const (
	// categoryEnumeration tags every finding these rules produce.
	categoryEnumeration = "enumeration"

	ruleChannelDecl     = "podman-channel-decl"
	ruleChannelTable    = "podman-channel-table"
	ruleGateSection     = "podman-gate-section"
	ruleChannelCount    = "podman-channel-count"
	rulePhraseCatalogue = "podman-phrase-catalogue"

	// podmanPolicyRel is the file that holds both declarations.
	podmanPolicyRel = "internal/podmanproxy/policy.go"
	// podmanProxyPkgRel is walked for prose (Go comments) that carries a
	// count phrase.
	podmanProxyPkgRel = "internal/podmanproxy"
	// podmanDocRel is the canonical prose site for the channel set. Its
	// presence is what switches these rules on: a synthetic scan root
	// with no podman-proxy doc has nothing to check.
	podmanDocRel = "docs/podman-proxy.md"

	channelsVarName = "namePolicyChannels"
	checksVarName   = "createVolumeChecks"

	// prefixReaderFunc is the only function allowed to read the
	// volume-name prefix out of the config. See volumeNamePrefixFor.
	prefixReaderFunc  = "volumeNamePrefixFor"
	prefixConfigField = "VolumeNamePrefix"

	// gateHeading anchors the canonical gated/un-gated section inside the
	// doc comment above gateSectionFunc.
	gateSectionFunc = "checkCreateVolumeNames"
	gateHeading     = "# What is gated on the prefix, and what is not"
	gateSeparator   = "NOT gated"

	// podmanDoclintDocRel carries the phrase catalogue: the list a prose
	// site reads to learn which phrasing the count rule enforces.
	podmanDoclintDocRel = "docs/doclint.md"

	// The region markers. tableMarkerName sits in podmanDocRel and
	// catalogueMarkerName in podmanDoclintDocRel.
	tableMarkerName     = "name-policy-channels"
	catalogueMarkerName = "count-phrases"
)

// podmanNonChannelPrefixMismatchReasons lists the audit reasons that carry
// `prefix_mismatch` but belong to no naming CHANNEL, with the reason why.
// Every other such reason in the podman-proxy source must come from a row
// of namePolicyChannels.
//
// Add an entry here only for a reason that names no new resource. A reason
// that does gets a row in the declaration, and the canonical table gets a
// row with it.
var podmanNonChannelPrefixMismatchReasons = map[string]string{
	"rename_prefix_mismatch": "POST /containers/{id}/rename renames a container that already exists, " +
		"so it names no new resource and the section-3 table carries no row for it",
}

// formatNonChannelReasons renders the recorded exclusions for a finding,
// so an author who hits the rule sees the shape an exclusion takes.
func formatNonChannelReasons() string {
	keys := make([]string, 0, len(podmanNonChannelPrefixMismatchReasons))
	for k := range podmanNonChannelPrefixMismatchReasons {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	parts := make([]string, 0, len(keys))
	for _, k := range keys {
		parts = append(parts, fmt.Sprintf("%s (%s)", k, podmanNonChannelPrefixMismatchReasons[k]))
	}
	return strings.Join(parts, ", ")
}

// podmanChannel mirrors one row of namePolicyChannels.
type podmanChannel struct {
	key               string // the row's index constant, for example chBindsVolume
	id                string
	configField       string
	checkFunc         string
	denyReason        string
	altDenyReason     string
	namesVolume       bool
	injectsAbsentName bool
	line              int
}

// denyReasons returns the row's reasons, the alternate one included.
func (c podmanChannel) denyReasons() []string {
	out := []string{c.denyReason}
	if c.altDenyReason != "" {
		out = append(out, c.altDenyReason)
	}
	return out
}

// podmanCheck mirrors one row of createVolumeChecks.
type podmanCheck struct {
	key         string // the row's index constant, for example volumeCheckName
	proseName   string
	prefixGated bool
	denyReasons []string
	line        int
}

// podmanDecls is what the two declarations, and the shape of the source
// around them, say. Every rule below reads this and nothing else about
// the code.
type podmanDecls struct {
	policyPath string

	channels []podmanChannel
	checks   []podmanCheck

	// funcLines maps every function declared in policy.go to its line.
	funcLines map[string]int

	// rowReaders maps "<var>[<key>]" to the set of functions that read
	// that row, with the line of the first read.
	rowReaders map[string]map[string]int

	// strayReasons holds every string literal outside the two
	// declarations, with the line of its first occurrence.
	strayReasons map[string]int

	// prefixReaders maps each function that reads cfg.VolumeNamePrefix to
	// the line of the read.
	prefixReaders map[string]int

	// gateSection is the canonical gated/un-gated prose, split at the
	// first line that carries gateSeparator.
	gateSectionFound bool
	gateSectionLine  int
	gatedSide        []proseLine
	unGatedSide      []proseLine
	gateSeparatorAt  int // line of the separator, 0 when absent
}

// namedVolumeChannels returns the channels that carry a VOLUME name on a
// containers/create body — the "four named-volume channels" of the prose.
// A channel that injects a name is a create-endpoint channel and is not
// one of them.
func (d *podmanDecls) namedVolumeChannels() []podmanChannel {
	var out []podmanChannel
	for _, c := range d.channels {
		if c.namesVolume && !c.injectsAbsentName {
			out = append(out, c)
		}
	}
	return out
}

// namedVolumeDenyReasons returns the distinct deny reasons of the
// named-volume channels, sorted. Two channels share one reason today, so
// this is not the channel count.
func (d *podmanDecls) namedVolumeDenyReasons() []string {
	seen := map[string]bool{}
	var out []string
	for _, c := range d.namedVolumeChannels() {
		for _, r := range c.denyReasons() {
			if !seen[r] {
				seen[r] = true
				out = append(out, r)
			}
		}
	}
	sort.Strings(out)
	return out
}

// volumePrefixChannels counts the channels the volume-name prefix covers,
// the volumes/create endpoint included.
func (d *podmanDecls) volumePrefixChannels() int {
	n := 0
	for _, c := range d.channels {
		if c.configField == prefixConfigField {
			n++
		}
	}
	return n
}

func (d *podmanDecls) gatedChecks() (gated, unGated []podmanCheck) {
	for _, c := range d.checks {
		if c.prefixGated {
			gated = append(gated, c)
			continue
		}
		unGated = append(unGated, c)
	}
	return gated, unGated
}

// scanPodmanEnumerations runs the four rules. It returns no finding at all
// when the canonical doc is absent, which is the synthetic-scan-root case
// (see scan_test.go); when the doc IS present, an absent or unparseable
// policy.go is itself a finding.
func scanPodmanEnumerations(prismRoot, repoRoot string) []Finding {
	docPath := filepath.Join(prismRoot, podmanDocRel)
	docContent, err := os.ReadFile(docPath)
	if err != nil {
		return nil
	}

	policyPath := filepath.Join(prismRoot, podmanPolicyRel)
	decls, findings := parsePodmanDecls(policyPath)
	if decls == nil {
		return findings
	}

	findings = append(findings, checkPodmanDeclConsistency(decls)...)
	findings = append(findings, checkPodmanChannelTable(docPath, docContent, decls)...)
	findings = append(findings, checkPodmanGateSection(decls)...)
	findings = append(findings, checkPodmanCountPhrases(prismRoot, repoRoot, decls)...)
	findings = append(findings, checkPodmanPhraseCatalogue(prismRoot)...)
	return dedupeFindings(findings)
}

// dedupeFindings drops repeats. One prose site can sit in two scan sets —
// the canonical section lives in a file the count patterns also read — and
// a reader needs the site once.
func dedupeFindings(findings []Finding) []Finding {
	seen := map[string]bool{}
	out := findings[:0]
	for _, f := range findings {
		key := fmt.Sprintf("%s|%d|%s|%s", f.File, f.Line, f.Rule, f.Token)
		if seen[key] {
			continue
		}
		seen[key] = true
		out = append(out, f)
	}
	return out
}

// parsePodmanDecls reads policy.go and extracts both declarations plus the
// facts about the surrounding source the rules need. A nil result means
// the file could not be read or parsed, and the returned findings say so.
func parsePodmanDecls(policyPath string) (*podmanDecls, []Finding) {
	src, err := os.ReadFile(policyPath)
	if err != nil {
		return nil, []Finding{{
			File:     policyPath,
			Line:     1,
			Token:    podmanPolicyRel,
			Rule:     ruleChannelDecl,
			Note:     fmt.Sprintf("the canonical channel declaration lives here and could not be read: %v", err),
			Category: categoryEnumeration,
		}}
	}
	fset := token.NewFileSet()
	file, err := parser.ParseFile(fset, policyPath, src, parser.ParseComments)
	if err != nil {
		return nil, []Finding{{
			File:     policyPath,
			Line:     1,
			Token:    podmanPolicyRel,
			Rule:     ruleChannelDecl,
			Note:     fmt.Sprintf("could not parse the file that holds the canonical channel declaration: %v", err),
			Category: categoryEnumeration,
		}}
	}

	d := &podmanDecls{
		policyPath:    policyPath,
		funcLines:     map[string]int{},
		rowReaders:    map[string]map[string]int{},
		strayReasons:  map[string]int{},
		prefixReaders: map[string]int{},
	}
	lineOf := func(p token.Pos) int { return fset.Position(p).Line }

	var declRanges [][2]token.Pos
	for _, decl := range file.Decls {
		gen, ok := decl.(*ast.GenDecl)
		if !ok || gen.Tok != token.VAR {
			continue
		}
		for _, spec := range gen.Specs {
			vs, ok := spec.(*ast.ValueSpec)
			if !ok || len(vs.Names) != 1 || len(vs.Values) != 1 {
				continue
			}
			lit, ok := vs.Values[0].(*ast.CompositeLit)
			if !ok {
				continue
			}
			switch vs.Names[0].Name {
			case channelsVarName:
				declRanges = append(declRanges, [2]token.Pos{gen.Pos(), gen.End()})
				d.channels = parseChannelRows(lit, lineOf)
			case checksVarName:
				declRanges = append(declRanges, [2]token.Pos{gen.Pos(), gen.End()})
				d.checks = parseCheckRows(lit, lineOf)
			}
		}
	}

	inDecl := func(p token.Pos) bool {
		for _, r := range declRanges {
			if p >= r[0] && p < r[1] {
				return true
			}
		}
		return false
	}

	for _, decl := range file.Decls {
		fn, ok := decl.(*ast.FuncDecl)
		if !ok {
			continue
		}
		d.funcLines[fn.Name.Name] = lineOf(fn.Pos())
		if fn.Name.Name == gateSectionFunc && fn.Doc != nil {
			d.readGateSection(fn.Doc, lineOf)
		}
		ast.Inspect(fn, func(n ast.Node) bool {
			switch e := n.(type) {
			case *ast.IndexExpr:
				arr, ok := e.X.(*ast.Ident)
				if !ok {
					return true
				}
				key, ok := e.Index.(*ast.Ident)
				if !ok {
					return true
				}
				if arr.Name != channelsVarName && arr.Name != checksVarName {
					return true
				}
				ref := arr.Name + "[" + key.Name + "]"
				if d.rowReaders[ref] == nil {
					d.rowReaders[ref] = map[string]int{}
				}
				if _, seen := d.rowReaders[ref][fn.Name.Name]; !seen {
					d.rowReaders[ref][fn.Name.Name] = lineOf(e.Pos())
				}
			case *ast.SelectorExpr:
				if e.Sel.Name != prefixConfigField {
					return true
				}
				// p.cfg.VolumeNamePrefix — the read this package funnels
				// through one function.
				if inner, ok := e.X.(*ast.SelectorExpr); ok && inner.Sel.Name == "cfg" {
					if _, seen := d.prefixReaders[fn.Name.Name]; !seen {
						d.prefixReaders[fn.Name.Name] = lineOf(e.Pos())
					}
				}
			}
			return true
		})
	}

	ast.Inspect(file, func(n ast.Node) bool {
		lit, ok := n.(*ast.BasicLit)
		if !ok || lit.Kind != token.STRING || inDecl(lit.Pos()) {
			return true
		}
		s, err := strconv.Unquote(lit.Value)
		if err != nil {
			return true
		}
		if _, seen := d.strayReasons[s]; !seen {
			d.strayReasons[s] = lineOf(lit.Pos())
		}
		return true
	})

	return d, nil
}

// parseChannelRows reads the keyed rows of the namePolicyChannels literal.
func parseChannelRows(lit *ast.CompositeLit, lineOf func(token.Pos) int) []podmanChannel {
	var out []podmanChannel
	for _, elt := range lit.Elts {
		kv, ok := elt.(*ast.KeyValueExpr)
		if !ok {
			continue
		}
		key, ok := kv.Key.(*ast.Ident)
		if !ok {
			continue
		}
		row, ok := kv.Value.(*ast.CompositeLit)
		if !ok {
			continue
		}
		c := podmanChannel{key: key.Name, line: lineOf(kv.Pos())}
		for name, value := range compositeFields(row) {
			switch name {
			case "id":
				c.id = litString(value)
			case "configField":
				c.configField = litString(value)
			case "checkFunc":
				c.checkFunc = litString(value)
			case "denyReason":
				c.denyReason = litString(value)
			case "altDenyReason":
				c.altDenyReason = litString(value)
			case "namesVolume":
				c.namesVolume = litBool(value)
			case "injectsAbsentName":
				c.injectsAbsentName = litBool(value)
			}
		}
		out = append(out, c)
	}
	return out
}

// parseCheckRows reads the keyed rows of the createVolumeChecks literal.
func parseCheckRows(lit *ast.CompositeLit, lineOf func(token.Pos) int) []podmanCheck {
	var out []podmanCheck
	for _, elt := range lit.Elts {
		kv, ok := elt.(*ast.KeyValueExpr)
		if !ok {
			continue
		}
		key, ok := kv.Key.(*ast.Ident)
		if !ok {
			continue
		}
		row, ok := kv.Value.(*ast.CompositeLit)
		if !ok {
			continue
		}
		c := podmanCheck{key: key.Name, line: lineOf(kv.Pos())}
		for name, value := range compositeFields(row) {
			switch name {
			case "proseName":
				c.proseName = litString(value)
			case "prefixGated":
				c.prefixGated = litBool(value)
			case "denyReasons":
				c.denyReasons = litStringSlice(value)
			}
		}
		out = append(out, c)
	}
	return out
}

// compositeFields returns the keyed fields of a struct literal.
func compositeFields(lit *ast.CompositeLit) map[string]ast.Expr {
	out := map[string]ast.Expr{}
	for _, elt := range lit.Elts {
		kv, ok := elt.(*ast.KeyValueExpr)
		if !ok {
			continue
		}
		if name, ok := kv.Key.(*ast.Ident); ok {
			out[name.Name] = kv.Value
		}
	}
	return out
}

func litString(e ast.Expr) string {
	lit, ok := e.(*ast.BasicLit)
	if !ok || lit.Kind != token.STRING {
		return ""
	}
	s, err := strconv.Unquote(lit.Value)
	if err != nil {
		return ""
	}
	return s
}

func litBool(e ast.Expr) bool {
	id, ok := e.(*ast.Ident)
	return ok && id.Name == "true"
}

func litStringSlice(e ast.Expr) []string {
	lit, ok := e.(*ast.CompositeLit)
	if !ok {
		return nil
	}
	var out []string
	for _, elt := range lit.Elts {
		if s := litString(elt); s != "" {
			out = append(out, s)
		}
	}
	return out
}

// readGateSection extracts the canonical gated/un-gated prose from the doc
// comment above checkCreateVolumeNames and splits it at the separator.
func (d *podmanDecls) readGateSection(doc *ast.CommentGroup, lineOf func(token.Pos) int) {
	lines := commentLines(doc, lineOf)
	start := -1
	for i, l := range lines {
		if strings.Contains(l.text, gateHeading) {
			start = i
			break
		}
	}
	if start < 0 {
		return
	}
	end := len(lines)
	for i := start + 1; i < len(lines); i++ {
		if strings.HasPrefix(strings.TrimSpace(lines[i].text), "# ") {
			end = i
			break
		}
	}
	section := lines[start:end]
	d.gateSectionFound = true
	d.gateSectionLine = section[0].line

	for i, l := range section {
		if strings.Contains(l.text, gateSeparator) {
			d.gateSeparatorAt = l.line
			d.gatedSide = section[:i]
			d.unGatedSide = section[i+1:]
			return
		}
	}
	d.gatedSide = section
}

// checkPodmanDeclConsistency holds the declaration to the code around it:
// every row is complete, every checkFunc exists and is the function that
// reads its row, every check leaves evidence in the source, and no deny
// reason of either family arrives undeclared.
func checkPodmanDeclConsistency(d *podmanDecls) []Finding {
	var out []Finding
	add := func(line int, token, note string) {
		out = append(out, Finding{
			File:     d.policyPath,
			Line:     line,
			Token:    token,
			Rule:     ruleChannelDecl,
			Note:     note,
			Category: categoryEnumeration,
		})
	}

	if len(d.channels) == 0 {
		add(1, channelsVarName, "the canonical channel declaration is missing from this file; "+
			"the prose enumerations in docs/podman-proxy.md have nothing to be checked against")
		return out
	}
	if len(d.checks) == 0 {
		add(1, checksVarName, "the canonical named-volume check declaration is missing from this file")
	}

	declaredReasons := map[string]bool{}
	for _, c := range d.channels {
		if c.id == "" || c.configField == "" || c.checkFunc == "" || c.denyReason == "" {
			add(c.line, c.key, "channel row is incomplete: id, configField, checkFunc, and denyReason are all required")
			continue
		}
		for _, r := range c.denyReasons() {
			declaredReasons[r] = true
		}
		if _, ok := d.funcLines[c.checkFunc]; !ok {
			add(c.line, c.checkFunc, fmt.Sprintf(
				"channel %q names a policy function that this file does not declare; "+
					"a renamed or removed check needs the declaration and the canonical table in %s updated with it",
				c.id, podmanDocRel))
		}
		ref := channelsVarName + "[" + c.key + "]"
		readers := d.rowReaders[ref]
		if len(readers) == 0 {
			add(c.line, c.key, fmt.Sprintf(
				"channel %q is declared but no function in this file reads %s; "+
					"a channel with no check is either a removed check or a row that was never wired up",
				c.id, ref))
			continue
		}
		for reader, line := range readers {
			if reader != c.checkFunc {
				add(line, reader, fmt.Sprintf(
					"%s is read by %s, but channel %q declares checkFunc %q; "+
						"update the declaration and the canonical table in %s to name the function that applies the check",
					ref, reader, c.id, c.checkFunc, podmanDocRel))
			}
		}
	}

	// Every prefix_mismatch reason in the source belongs to a channel, or
	// to the documented set that names no new resource.
	for reason, line := range d.strayReasons {
		if !strings.Contains(reason, "prefix_mismatch") {
			continue
		}
		if declaredReasons[reason] {
			add(line, reason, fmt.Sprintf(
				"this deny reason is declared by a row of %s; take it from that row rather than restating the literal",
				channelsVarName))
			continue
		}
		if _, ok := podmanNonChannelPrefixMismatchReasons[reason]; ok {
			continue
		}
		add(line, reason, fmt.Sprintf(
			"deny reason belongs to no row of %s. Add a channel row (and a row to the canonical table in %s), "+
				"or record it in podmanNonChannelPrefixMismatchReasons with the reason it names no new resource. "+
				"Recorded there today: %s",
			channelsVarName, podmanDocRel, formatNonChannelReasons()))
	}

	// The volume-name prefix has exactly one reader, so a change of gate
	// has to go through the declaration.
	for fn, line := range d.prefixReaders {
		if fn == prefixReaderFunc {
			continue
		}
		add(line, fn, fmt.Sprintf(
			"reads cfg.%s directly. %s is the only reader: it takes the gate from a row of %s, "+
				"which is the column the canonical enumeration above %s renders",
			prefixConfigField, prefixReaderFunc, checksVarName, gateSectionFunc))
	}
	if _, ok := d.prefixReaders[prefixReaderFunc]; !ok && len(d.checks) > 0 {
		add(lineOr1(d.funcLines[prefixReaderFunc]), prefixReaderFunc, fmt.Sprintf(
			"no function reads cfg.%s any more; the gate the canonical enumeration describes is gone",
			prefixConfigField))
	}

	// Every check leaves evidence in the source, and every `volumes` deny
	// reason is claimed by exactly one check.
	claimed := map[string]string{}
	for _, c := range d.checks {
		if c.proseName == "" || len(c.denyReasons) == 0 {
			add(c.line, c.key, "check row is incomplete: proseName and denyReasons are both required")
			continue
		}
		for _, r := range c.denyReasons {
			if prev, dup := claimed[r]; dup {
				add(c.line, r, fmt.Sprintf("deny reason is claimed by both %s and %s; one check must own it", prev, c.key))
				continue
			}
			claimed[r] = c.key
			if _, inSource := d.strayReasons[r]; inSource || declaredReasons[r] {
				continue
			}
			add(c.line, r, fmt.Sprintf(
				"check %q declares a deny reason that this file no longer emits; "+
					"a removed check needs the canonical enumeration above %s updated with it",
				c.proseName, gateSectionFunc))
		}
	}
	for reason, line := range d.strayReasons {
		if !strings.HasPrefix(reason, "create_volumes") {
			continue
		}
		if _, ok := claimed[reason]; ok {
			continue
		}
		add(line, reason, fmt.Sprintf(
			"containers/create `volumes` deny reason belongs to no row of %s. Add it to the row of the check that emits it, "+
				"and name that check in the canonical enumeration above %s",
			checksVarName, gateSectionFunc))
	}

	return out
}

var (
	regionEndRe = regexp.MustCompile(`(?m)^[ \t]*<!--[ \t]*doclint-enumeration-end[ \t]*-->`)
	tableRuleRe = regexp.MustCompile(`^\|[\s\-:|]*\|$`)
)

// enumerationRegion returns the text between the named region markers and
// the 1-based line the text starts on.
func enumerationRegion(content []byte, name string) (region string, firstLine int, ok bool) {
	startRe := regexp.MustCompile(`(?m)^[ \t]*<!--[ \t]*doclint-enumeration:[ \t]*` + regexp.QuoteMeta(name) + `[ \t]*-->`)
	start := startRe.FindIndex(content)
	if start == nil {
		return "", 0, false
	}
	end := regionEndRe.FindIndex(content[start[1]:])
	if end == nil {
		return "", 0, false
	}
	firstLine = 1 + strings.Count(string(content[:start[1]]), "\n")
	return string(content[start[1] : start[1]+end[0]]), firstLine, true
}

// missingRegionNote is the diagnostic for an absent or reversed marker
// pair. The markers are what ties a prose list to the declaration it
// renders, so their absence is a finding rather than a skip.
func missingRegionNote(name, holds, declaration, declaredIn string) string {
	return fmt.Sprintf(
		"the %s must sit between `<!-- doclint-enumeration: %s -->` and `<!-- doclint-enumeration-end -->`. "+
			"One marker is missing or the two are out of order, so nothing holds the list to %s in %s",
		holds, name, declaration, declaredIn)
}

// checkPodmanChannelTable holds the canonical table to the declaration in
// both directions: every declared channel has a row, and every row is a
// declared channel.
//
// The check is line-oriented, not cell-oriented. A row matches a channel
// when the line carries that channel's config field, policy function, and
// deny reasons. Column order, alignment, and the prose of the Channel
// column are therefore free to change without breaking the rule.
func checkPodmanChannelTable(docPath string, content []byte, d *podmanDecls) []Finding {
	var out []Finding
	add := func(line int, token, note string) {
		out = append(out, Finding{
			File:     docPath,
			Line:     line,
			Token:    token,
			Rule:     ruleChannelTable,
			Note:     note,
			Category: categoryEnumeration,
		})
	}

	region, firstLine, ok := enumerationRegion(content, tableMarkerName)
	if !ok {
		add(1, tableMarkerName, missingRegionNote(tableMarkerName,
			"canonical channel table", channelsVarName, podmanPolicyRel))
		return out
	}

	type row struct {
		line int
		text string
	}
	var rows []row
	seenRule := false
	for i, text := range strings.Split(region, "\n") {
		trimmed := strings.TrimSpace(text)
		if !strings.HasPrefix(trimmed, "|") {
			continue
		}
		if tableRuleRe.MatchString(trimmed) {
			seenRule = true
			continue
		}
		if !seenRule {
			continue // header row
		}
		rows = append(rows, row{line: firstLine + i, text: trimmed})
	}
	if len(rows) == 0 {
		add(firstLine, tableMarkerName, "the canonical enumeration region carries no table rows")
		return out
	}

	matchedRow := make([]bool, len(rows))
	for _, c := range d.channels {
		if c.checkFunc == "" || c.denyReason == "" {
			continue // already reported by the declaration rule
		}
		var hits []int
		for i, r := range rows {
			if !strings.Contains(r.text, c.checkFunc) || !strings.Contains(r.text, c.configField) {
				continue
			}
			ok := true
			for _, reason := range c.denyReasons() {
				if !strings.Contains(r.text, reason) {
					ok = false
					break
				}
			}
			if !ok {
				continue
			}
			hits = append(hits, i)
		}
		switch len(hits) {
		case 0:
			add(firstLine, c.id, fmt.Sprintf(
				"channel %q is declared in %s but no row of the canonical table carries its config field %q, "+
					"its policy function %q, and its deny reason(s) %s. Add the row",
				c.id, podmanPolicyRel, c.configField, c.checkFunc, strings.Join(c.denyReasons(), ", ")))
			continue
		case 1:
		default:
			add(rows[hits[0]].line, c.id, fmt.Sprintf(
				"channel %q matches %d rows of the canonical table; one channel is one row",
				c.id, len(hits)))
		}
		r := rows[hits[0]]
		matchedRow[hits[0]] = true
		want, unwanted := "forwarded", "injected"
		if c.injectsAbsentName {
			want, unwanted = "injected", "forwarded"
		}
		if !strings.Contains(r.text, want) || strings.Contains(r.text, unwanted) {
			add(r.line, c.id, fmt.Sprintf(
				"channel %q declares injectsAbsentName=%t, so its row must say %q for an absent name",
				c.id, c.injectsAbsentName, want))
		}
	}
	for i, r := range rows {
		if matchedRow[i] {
			continue
		}
		add(r.line, tableMarkerName, fmt.Sprintf(
			"this row of the canonical table matches no channel declared in %s. "+
				"A removed or renamed channel must leave the table with it",
			podmanPolicyRel))
	}
	return out
}

// checkPodmanGateSection holds the canonical gated/un-gated enumeration —
// the doc comment above checkCreateVolumeNames — to createVolumeChecks.
func checkPodmanGateSection(d *podmanDecls) []Finding {
	var out []Finding
	add := func(line int, token, note string) {
		out = append(out, Finding{
			File:     d.policyPath,
			Line:     line,
			Token:    token,
			Rule:     ruleGateSection,
			Note:     note,
			Category: categoryEnumeration,
		})
	}
	if len(d.checks) == 0 {
		return out
	}
	if !d.gateSectionFound {
		add(lineOr1(d.funcLines[gateSectionFunc]), gateHeading, fmt.Sprintf(
			"the doc comment above %s must carry the canonical section %q; it is the prose rendering of %s",
			gateSectionFunc, gateHeading, checksVarName))
		return out
	}
	if d.gateSeparatorAt == 0 {
		add(d.gateSectionLine, gateSeparator, fmt.Sprintf(
			"the canonical section must carry one sentence with %q, which separates the gated checks from the un-gated ones",
			gateSeparator))
		return out
	}

	gated := proseText(d.gatedSide)
	unGated := proseText(d.unGatedSide)
	for _, c := range d.checks {
		if c.proseName == "" {
			continue // reported by the declaration rule
		}
		onGated := strings.Contains(gated, c.proseName)
		onUnGated := strings.Contains(unGated, c.proseName)
		switch {
		case c.prefixGated && (!onGated || onUnGated):
			add(d.gateSectionLine, c.proseName, fmt.Sprintf(
				"%s declares this check gated on Config.%s, so the canonical section must name it above the %q sentence and not below it",
				checksVarName, prefixConfigField, gateSeparator))
		case !c.prefixGated && (!onUnGated || onGated):
			add(d.gateSectionLine, c.proseName, fmt.Sprintf(
				"%s declares this check un-gated, so the canonical section must name it below the %q sentence and not above it",
				checksVarName, gateSeparator))
		}
	}

	return out
}

// lineOr1 keeps a finding on a real line when the anchor it wanted is
// gone.
func lineOr1(line int) int {
	if line < 1 {
		return 1
	}
	return line
}

// numberWords maps the count words a doc is allowed to use to their value.
// A capture that is not in here and is not a decimal number is not a count
// phrase, and produces no finding.
var numberWords = map[string]int{
	"one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6,
	"seven": 7, "eight": 8, "nine": 9, "ten": 10, "eleven": 11, "twelve": 12,
}

// wordToCount returns the value of a count word, and whether it is one.
func wordToCount(w string) (int, bool) {
	if n, ok := numberWords[strings.ToLower(w)]; ok {
		return n, true
	}
	if n, err := strconv.Atoi(w); err == nil {
		return n, true
	}
	return 0, false
}

// countPattern is one prose shape that states a number the declaration
// also states. Each capture group holds a count word, and want returns the
// declared value for each group, in the same order.
type countPattern struct {
	re   *regexp.Regexp
	what []string
	want func(d *podmanDecls) []int

	// phrase renders the pattern for the catalogue in docs/doclint.md,
	// with `N` in place of each count word. It is the phrasing a prose
	// site writes to opt in, so the catalogue rule requires the doc to
	// carry it, and TestPodmanCountPatterns_PhrasesMatchTheirRegex
	// requires the pattern itself to match it.
	phrase string
}

// podmanAllCountPatterns is every pattern the count rule runs, in the
// order the catalogue lists them.
func podmanAllCountPatterns() []countPattern {
	out := make([]countPattern, 0, len(podmanCountPatterns)+len(podmanGateCountPatterns))
	out = append(out, podmanCountPatterns...)
	return append(out, podmanGateCountPatterns...)
}

// podmanCountPatterns are the phrases that carry a channel-set count. They
// name the SET. A phrase about a subset ("two channels, two consequences")
// matches none of them, which is what keeps a function doc comment that
// covers only its own channels out of the rule.
var podmanCountPatterns = []countPattern{
	{
		re:     regexp.MustCompile(`(?i)\b(\w+) named-volume channels?\b`),
		what:   []string{"named-volume channels"},
		want:   func(d *podmanDecls) []int { return []int{len(d.namedVolumeChannels())} },
		phrase: "N named-volume channels",
	},
	{
		re:     regexp.MustCompile(`(?i)\b(\w+) container-create channels?\b`),
		what:   []string{"named-volume channels of a containers/create body"},
		want:   func(d *podmanDecls) []int { return []int{len(d.namedVolumeChannels())} },
		phrase: "N container-create channels",
	},
	{
		re:     regexp.MustCompile(`(?i)\b(\w+) create-body channels?\b`),
		what:   []string{"named-volume channels of a containers/create body"},
		want:   func(d *podmanDecls) []int { return []int{len(d.namedVolumeChannels())} },
		phrase: "N create-body channels",
	},
	{
		re:     regexp.MustCompile(`(?i)\b(\w+) name-policy channels?\b`),
		what:   []string{"name-policy channels"},
		want:   func(d *podmanDecls) []int { return []int{len(d.channels)} },
		phrase: "N name-policy channels",
	},
	{
		re:     regexp.MustCompile(`(?i)\b(\w+) mount-channel reasons?\b`),
		what:   []string{"distinct deny reasons across the named-volume channels"},
		want:   func(d *podmanDecls) []int { return []int{len(d.namedVolumeDenyReasons())} },
		phrase: "N mount-channel reasons",
	},
	{
		re:     regexp.MustCompile(`(?i)VolumeNamePrefix covers (\w+) surfaces\b`),
		what:   []string{"channels the volume-name prefix covers"},
		want:   func(d *podmanDecls) []int { return []int{d.volumePrefixChannels()} },
		phrase: "VolumeNamePrefix covers N surfaces",
	},
}

// podmanGateCountPatterns are the phrases that carry a gated/un-gated
// count. They run against every prose site, because the doc restates the
// gating in section 8.3 as well as in the canonical section.
var podmanGateCountPatterns = []countPattern{
	{
		re:   regexp.MustCompile(`(?i)\b(\w+) checks? of the (\w+) (?:is|are) gated\b`),
		what: []string{"gated checks", "named-volume checks"},
		want: func(d *podmanDecls) []int {
			gated, _ := d.gatedChecks()
			return []int{len(gated), len(d.checks)}
		},
		phrase: "N checks of the N are gated",
	},
	{
		re:   regexp.MustCompile(`(?i)\bThe other (\w+) are NOT gated\b`),
		what: []string{"un-gated checks"},
		want: func(d *podmanDecls) []int {
			_, unGated := d.gatedChecks()
			return []int{len(unGated)}
		},
		phrase: "The other N are NOT gated",
	},
}

// proseLine is one line of prose with its 1-based line number in the file
// it came from.
type proseLine struct {
	line int
	text string
}

// proseText joins prose lines with single spaces.
func proseText(lines []proseLine) string {
	parts := make([]string, 0, len(lines))
	for _, l := range lines {
		parts = append(parts, strings.TrimSpace(l.text))
	}
	return strings.Join(parts, " ")
}

// flattenProse joins prose lines into one string and returns, for every
// byte of it, the line the byte came from. A count phrase that a writer
// wrapped across two lines is then still one match, and the finding still
// names the line the phrase starts on.
func flattenProse(lines []proseLine) (string, []int) {
	var sb strings.Builder
	var lineOf []int
	for i, l := range lines {
		text := strings.TrimSpace(l.text)
		if i > 0 {
			sb.WriteByte(' ')
			lineOf = append(lineOf, l.line)
		}
		sb.WriteString(text)
		for i := 0; i < len(text); i++ {
			lineOf = append(lineOf, l.line)
		}
	}
	return sb.String(), lineOf
}

// countFindings runs a pattern set over one file's prose.
func countFindings(path string, lines []proseLine, patterns []countPattern, d *podmanDecls, ignore map[string]bool) []Finding {
	text, lineOf := flattenProse(lines)
	var out []Finding
	for _, p := range patterns {
		want := p.want(d)
		for _, m := range p.re.FindAllStringSubmatchIndex(text, -1) {
			line := 1
			if m[0] < len(lineOf) {
				line = lineOf[m[0]]
			}
			phrase := text[m[0]:m[1]]
			if ignore[phrase] {
				continue
			}
			for g := 0; g < len(want) && 2*(g+1)+1 < len(m); g++ {
				lo, hi := m[2*(g+1)], m[2*(g+1)+1]
				if lo < 0 {
					continue
				}
				got, ok := wordToCount(text[lo:hi])
				if !ok || got == want[g] {
					continue
				}
				out = append(out, Finding{
					File:  path,
					Line:  line,
					Token: phrase,
					Rule:  ruleChannelCount,
					Note: fmt.Sprintf("prose says %d %s; %s declares %d. Update the prose, or the declaration",
						got, p.what[g], podmanPolicyRel, want[g]),
					Category: categoryEnumeration,
				})
			}
		}
	}
	return out
}

// checkPodmanPhraseCatalogue holds the phrase catalogue in docs/doclint.md
// to the pattern set, in both directions.
//
// The catalogue is the opt-in contract: a prose site that wants its count
// enforced writes one of the phrases, and any other phrasing is unenforced
// prose. A catalogue that omits a pattern therefore tells an author their
// phrasing is free when the rule governs it, and a catalogue that carries
// a phrase the rules dropped tells them the opposite. Both are the drift
// this family exists to close, one layer up.
func checkPodmanPhraseCatalogue(prismRoot string) []Finding {
	path := filepath.Join(prismRoot, podmanDoclintDocRel)
	content, err := os.ReadFile(path)
	if err != nil {
		return nil
	}
	var out []Finding
	add := func(line int, token, note string) {
		out = append(out, Finding{
			File:     path,
			Line:     line,
			Token:    token,
			Rule:     rulePhraseCatalogue,
			Note:     note,
			Category: categoryEnumeration,
		})
	}

	region, firstLine, ok := enumerationRegion(content, catalogueMarkerName)
	if !ok {
		add(1, catalogueMarkerName, missingRegionNote(catalogueMarkerName,
			"count-phrase catalogue", "podmanCountPatterns", "internal/doclint/podman_enumeration.go"))
		return out
	}

	type entry struct {
		line int
		text string
	}
	var entries []entry
	for i, text := range strings.Split(region, "\n") {
		trimmed := strings.TrimSpace(text)
		if trimmed == "" || strings.HasPrefix(trimmed, "```") || strings.HasPrefix(trimmed, "~~~") {
			continue
		}
		entries = append(entries, entry{line: firstLine + i, text: trimmed})
	}

	matched := make([]bool, len(entries))
	for _, p := range podmanAllCountPatterns() {
		hits := 0
		for i, e := range entries {
			if strings.Contains(e.text, p.phrase) {
				matched[i] = true
				hits++
			}
		}
		switch {
		case hits == 0:
			add(firstLine, p.phrase,
				"the count rule recognises this phrase, and the catalogue does not list it. "+
					"A reader of the catalogue concludes the phrasing is unenforced prose. Add the entry")
		case hits > 1:
			add(firstLine, p.phrase, fmt.Sprintf("the catalogue lists this phrase %d times; one phrase is one entry", hits))
		}
	}
	for i, e := range entries {
		if matched[i] {
			continue
		}
		add(e.line, e.text, "the catalogue carries an entry that no count pattern recognises. "+
			"A prose site that copies it gets no enforcement at all")
	}
	return out
}

// checkPodmanCountPhrases runs the count patterns over every prose site the
// rule governs: the prism docs, the comments of the podman-proxy package,
// and — when the repo root is available — the prism agent and skill files.
func checkPodmanCountPhrases(prismRoot, repoRoot string, d *podmanDecls) []Finding {
	var out []Finding
	for _, path := range podmanProseFiles(prismRoot, repoRoot) {
		content, err := os.ReadFile(path)
		if err != nil {
			continue
		}
		var lines []proseLine
		var ignore map[string]bool
		if strings.HasSuffix(path, ".go") {
			lines = goCommentLines(path, content)
		} else {
			ignore = extractIgnoreSet(content)
			for i, text := range strings.Split(string(stripFencedBlocks(content)), "\n") {
				lines = append(lines, proseLine{line: i + 1, text: text})
			}
		}
		out = append(out, countFindings(path, lines, podmanAllCountPatterns(), d, ignore)...)
	}
	return out
}

// podmanProseFiles lists the files the count patterns run against.
func podmanProseFiles(prismRoot, repoRoot string) []string {
	var out []string
	appendMarkdown := func(root string) {
		_ = filepath.WalkDir(root, func(path string, entry os.DirEntry, err error) error {
			if err != nil {
				return nil
			}
			if entry.IsDir() {
				return nil
			}
			if strings.HasSuffix(entry.Name(), ".md") {
				out = append(out, path)
			}
			return nil
		})
	}
	appendMarkdown(filepath.Join(prismRoot, "docs"))

	pkg := filepath.Join(prismRoot, podmanProxyPkgRel)
	if entries, err := os.ReadDir(pkg); err == nil {
		for _, entry := range entries {
			if !entry.IsDir() && strings.HasSuffix(entry.Name(), ".go") {
				out = append(out, filepath.Join(pkg, entry.Name()))
			}
		}
	}

	// The prism agent and skill files live outside the Go subtree, so they
	// are present in a full checkout and absent in the nix sandbox build.
	if repoRoot != "" {
		appendMarkdown(filepath.Join(repoRoot, "modules", "programs", "prism", "skills"))
		appendMarkdown(filepath.Join(repoRoot, "modules", "programs", "prism", "agents"))
	}
	sort.Strings(out)
	return out
}

// commentLines returns one proseLine per line of a comment group, with the
// comment markers removed and the true source line kept.
func commentLines(group *ast.CommentGroup, lineOf func(token.Pos) int) []proseLine {
	var out []proseLine
	for _, c := range group.List {
		text := c.Text
		switch {
		case strings.HasPrefix(text, "//"):
			out = append(out, proseLine{line: lineOf(c.Slash), text: strings.TrimPrefix(text, "//")})
		case strings.HasPrefix(text, "/*"):
			body := strings.TrimSuffix(strings.TrimPrefix(text, "/*"), "*/")
			for i, l := range strings.Split(body, "\n") {
				out = append(out, proseLine{line: lineOf(c.Slash) + i, text: l})
			}
		}
	}
	return out
}

// goCommentLines returns every comment line of a Go file. A file that does
// not parse contributes nothing: it fails the build long before it reaches
// this rule.
func goCommentLines(path string, src []byte) []proseLine {
	fset := token.NewFileSet()
	file, err := parser.ParseFile(fset, path, src, parser.ParseComments)
	if err != nil {
		return nil
	}
	lineOf := func(p token.Pos) int { return fset.Position(p).Line }
	var out []proseLine
	for _, group := range file.Comments {
		out = append(out, commentLines(group, lineOf)...)
	}
	return out
}
