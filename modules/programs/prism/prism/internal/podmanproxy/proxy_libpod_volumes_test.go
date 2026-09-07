package podmanproxy

// Tests for the per-session volume-name policy on the TOP-LEVEL
// `volumes` key of a containers/create body (issue #2958), and for the
// decode boundary between the libpod and docker-compat body shapes.
//
// The policy lives in policy.go::checkCreateVolumeNames and is gated on
// Config.VolumeNamePrefix, the same knob applyVolumeNamePolicy and
// checkMountedVolumeNames use. It is the third named-volume channel of
// a create body:
//
//   - HostConfig.Binds            — "myvol:/data[:options]"   (#2954)
//   - HostConfig.Mounts           — Type=volume, Source="myvol" (#2954)
//   - top-level `volumes` array   — libpod NamedVolume{Name, …} (#2958)
//
// The key carries two unrelated meanings. docker's field is a
// placeholder map of container paths and names no volume. libpod's
// field of the same name is an array of NamedVolume, and every Name is
// a volume the container ATTACHES. normalisePath strips the `libpod/`
// prefix and Go matches a JSON field name case-insensitively, so the
// libpod array decoded into the same json.RawMessage and forwarded
// unchecked: a cross-session attach, plus a volume the cleanup sweep
// cannot find.
//
// The deny tests and TestLibpodVolumes_NegativeControl_EmptyPrefix are
// a pair: the negative control runs the SAME cross-session attach on
// all three shapes with the prefix unset and asserts each reaches the
// upstream. That is what proves the 403s come from the new check and
// not from an unrelated policy path, in the shape §6 of
// docs/podman-proxy.md prescribes.
//
// TestLibpodBoundary_DangerousKeysRefusedAtDecode is the other half of
// the file, and it is not coverage of this change — it PINS the decode
// boundary that made `volumes` the only leaking key. podman is not a
// Go dependency of this repo (the proxy speaks HTTP to a socket), so
// there is no upstream struct to diff containerCreateBody against, and
// the boundary cannot be verified by reading source. It can only be
// verified behaviourally.

import (
	"bytes"
	"fmt"
	"io"
	"net/http"
	"strings"
	"testing"
)

// The session under test and the foreign session whose volume it tries
// to attach.
const (
	lvSessionPrefix = "prism-nixos-config-libpod-vol-"
	lvForeignVolume = "prism-nixos-config-other-session-cafebabe"
)

// The two create endpoints that reach containerCreateBody. Both are
// exercised: normalisePath strips the version segment and the
// `libpod/` prefix, so the two paths share one classifier, one struct,
// and one policy.
const (
	lvLibpodPath = "/v5.0.0/libpod/containers/create"
	lvDockerPath = "/v1.41/containers/create"
)

// postCreateJSON posts a raw JSON body to one of the create endpoints.
// Unlike postCreate and postCreateRaw it takes the body as a string,
// so a test can express a libpod body exactly as a client would send
// it — key case, key order, and duplicate case-variant keys all
// matter here, and none of them survive a round trip through a Go map.
func postCreateJSON(t *testing.T, sock, apiPath, body string) *http.Response {
	t.Helper()
	req, err := http.NewRequest(http.MethodPost,
		"http://podman.sock"+apiPath,
		strings.NewReader(body))
	if err != nil {
		t.Fatalf("new request: %v", err)
	}
	req.Header.Set("Content-Type", "application/json")
	return doRequest(t, sock, req)
}

// lvBody wraps a `volumes` value in the smallest create body that
// passes every other policy check, using the supplied key spelling.
func lvBody(key, value string) string {
	return fmt.Sprintf(`{"image":"alpine","%s":%s}`, key, value)
}

// ── deny: a foreign volume name on every shape that decodes ─────────────

// TestLibpodVolumes_ForeignName_Denied is the security AC. A create
// body whose top-level `volumes` key names a volume outside the
// session prefix returns 403, does not reach the upstream, and is
// audited under the volume-name policy.
//
// The three named shapes are the ones issue #2958 measured as
// forwarding: the lowercase array of objects, the uppercase array of
// objects, and the array of strings. The rest are traps that a
// narrower check would let through.
func TestLibpodVolumes_ForeignName_Denied(t *testing.T) {
	cases := []struct {
		name string
		body string
	}{
		{
			// The reproducer from the issue, verbatim in shape.
			name: "lowercase_key_array_of_objects",
			body: lvBody("volumes", `[{"Name":"`+lvForeignVolume+`","Dest":"/data"}]`),
		},
		{
			name: "uppercase_key_array_of_objects",
			body: lvBody("Volumes", `[{"Name":"`+lvForeignVolume+`","Dest":"/data"}]`),
		},
		{
			name: "lowercase_key_array_of_strings",
			body: lvBody("volumes", `["`+lvForeignVolume+`:/data"]`),
		},
		{
			// Go matches a JSON field name case-insensitively inside
			// the entry too, so lowercase entry keys decode the same
			// way and must be policed the same way.
			name: "lowercase_entry_keys",
			body: lvBody("volumes", `[{"name":"`+lvForeignVolume+`","dest":"/data"}]`),
		},
		{
			// A second entry must not be skipped because the first one
			// is fine.
			name: "second_entry_is_the_foreign_one",
			body: lvBody("volumes", `[{"Name":"`+lvSessionPrefix+`ok","Dest":"/ok"},{"Name":"`+lvForeignVolume+`","Dest":"/data"}]`),
		},
		{
			// Substring trap: contains the prefix but does not start
			// with it.
			name: "prefix_as_substring",
			body: lvBody("volumes", `[{"Name":"user-`+lvSessionPrefix+`data","Dest":"/data"}]`),
		},
		{
			name: "unprefixed_plain_name",
			body: lvBody("volumes", `[{"Name":"notours","Dest":"/data"}]`),
		},
		{
			// A string entry with a leading '/' reads as a host bind
			// under docker's -v grammar. There is no host-bind branch
			// on this channel, so the prefix rule refuses it rather
			// than leaving it to nobody. Same outcome as a
			// Type=volume Mounts entry with Source="/etc".
			name: "host_path_string_entry",
			body: lvBody("volumes", `["/etc:/host-etc"]`),
		},
		{
			// A colon-less string entry carries no destination, so its
			// whole text reads as the name.
			name: "colonless_string_entry",
			body: lvBody("volumes", `["`+lvForeignVolume+`"]`),
		},
		{
			// Options on the entry must not distract the check.
			name: "entry_with_options",
			body: lvBody("volumes", `[{"Name":"`+lvForeignVolume+`","Dest":"/data","Options":["ro"]}]`),
		},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			fu := newFakeUpstream(t)
			h := startProxyWithMountVolumePrefix(t, fu, lvSessionPrefix)

			resp := postCreateJSON(t, h.sock, lvLibpodPath, tc.body)
			if resp.StatusCode != http.StatusForbidden {
				body, _ := io.ReadAll(resp.Body)
				t.Fatalf("status: got %d, want 403 (body=%q)", resp.StatusCode, body)
			}
			assertNoForward(t, fu)
			if !strings.Contains(h.audit.String(), "create_volumes_name_prefix_mismatch") {
				t.Errorf("audit log does not carry reason create_volumes_name_prefix_mismatch; log=%s", h.audit.String())
			}
			// The 403 must tell the caller what to do about it.
			env := readEnvelope(t, resp)
			if !strings.Contains(env.Message, lvSessionPrefix) {
				t.Errorf("deny message does not name the required prefix; message=%q", env.Message)
			}
		})
	}
}

// TestLibpodVolumes_CrossSessionAttach_Denied states the
// cross-session-attach property as its own test so it is findable by
// name, and asserts it on BOTH create endpoints. A libpod body reaches
// the docker-compat path too: normalisePath only strips the prefix, it
// does not route on it.
func TestLibpodVolumes_CrossSessionAttach_Denied(t *testing.T) {
	body := lvBody("volumes", `[{"Name":"`+lvForeignVolume+`","Dest":"/data"}]`)
	for _, apiPath := range []string{lvLibpodPath, lvDockerPath} {
		t.Run(apiPath, func(t *testing.T) {
			fu := newFakeUpstream(t)
			h := startProxyWithMountVolumePrefix(t, fu, lvSessionPrefix)

			resp := postCreateJSON(t, h.sock, apiPath, body)
			if resp.StatusCode != http.StatusForbidden {
				got, _ := io.ReadAll(resp.Body)
				t.Fatalf("SECURITY: cross-session volume attach was admitted; status %d (body=%q)",
					resp.StatusCode, got)
			}
			assertNoForward(t, fu)
		})
	}
}

// TestLibpodVolumes_CaseVariantKeys_BothInspected covers the reason
// checkCreateVolumeNames reads the raw body rather than the decoded
// struct field. Go resolves an exact key match and a case-folded key
// match to the SAME field in document order, so a body carrying both
// `Volumes` and `volumes` leaves only the last one in the struct. A
// check on the struct field would inspect one and forward both.
func TestLibpodVolumes_CaseVariantKeys_BothInspected(t *testing.T) {
	cases := map[string]string{
		"foreign_key_first": `{"image":"alpine","volumes":[{"Name":"` + lvForeignVolume + `","Dest":"/d"}],"Volumes":{"/data":{}}}`,
		"foreign_key_last":  `{"image":"alpine","Volumes":{"/data":{}},"volumes":[{"Name":"` + lvForeignVolume + `","Dest":"/d"}]}`,
	}
	for name, body := range cases {
		t.Run(name, func(t *testing.T) {
			fu := newFakeUpstream(t)
			h := startProxyWithMountVolumePrefix(t, fu, lvSessionPrefix)

			resp := postCreateJSON(t, h.sock, lvLibpodPath, body)
			if resp.StatusCode != http.StatusForbidden {
				got, _ := io.ReadAll(resp.Body)
				t.Fatalf("SECURITY: a case-variant `volumes` key escaped inspection; status %d (body=%q)",
					resp.StatusCode, got)
			}
			assertNoForward(t, fu)
		})
	}
}

// ── negative control: the checks are not no-ops ─────────────────────────

// TestLibpodVolumes_NegativeControl_EmptyPrefix is the
// revert-and-watch-fail partner for every deny test above. It runs the
// same cross-session attach on all three measured shapes with
// VolumeNamePrefix unset and asserts each one reaches the upstream.
//
// If this test fails, the 403s above are being produced by some
// unrelated policy path and prove nothing about the new check. If the
// new check is deleted, the deny tests fail and this one still passes
// — the pair is what makes the coverage non-vacuous.
func TestLibpodVolumes_NegativeControl_EmptyPrefix(t *testing.T) {
	cases := map[string]string{
		"lowercase_key_array_of_objects": lvBody("volumes", `[{"Name":"`+lvForeignVolume+`","Dest":"/data"}]`),
		"uppercase_key_array_of_objects": lvBody("Volumes", `[{"Name":"`+lvForeignVolume+`","Dest":"/data"}]`),
		"lowercase_key_array_of_strings": lvBody("volumes", `["`+lvForeignVolume+`:/data"]`),
	}
	for name, body := range cases {
		t.Run(name, func(t *testing.T) {
			fu := newFakeUpstream(t)
			h := startProxyWithMountVolumePrefix(t, fu, "")

			resp := postCreateJSON(t, h.sock, lvLibpodPath, body)
			if resp.StatusCode != http.StatusOK {
				got, _ := io.ReadAll(resp.Body)
				t.Fatalf("status: got %d, want 200 (with no prefix configured the name policy is a no-op; body=%q)",
					resp.StatusCode, got)
			}
			if got := fu.captured(); got != 1 {
				t.Errorf("upstream request count: got %d, want 1", got)
			}
		})
	}
}

// ── allow: in-prefix names forward unchanged ────────────────────────────

// TestLibpodVolumes_PrefixedName_ForwardedUnchanged is the functional
// AC: a `volumes` entry that names a volume inside the session prefix
// is admitted, and the body the upstream receives is byte-identical to
// the one the client sent. This policy refuses; it never rewrites.
func TestLibpodVolumes_PrefixedName_ForwardedUnchanged(t *testing.T) {
	cases := map[string]string{
		"array_of_objects": lvBody("volumes", `[{"Name":"`+lvSessionPrefix+`pgdata","Dest":"/var/lib/postgresql/data"}]`),
		"uppercase_key":    lvBody("Volumes", `[{"Name":"`+lvSessionPrefix+`pgdata","Dest":"/data"}]`),
		"array_of_strings": lvBody("volumes", `["`+lvSessionPrefix+`cache:/cache:ro"]`),
		"two_entries":      lvBody("volumes", `[{"Name":"`+lvSessionPrefix+`a","Dest":"/a"},{"Name":"`+lvSessionPrefix+`b","Dest":"/b","Options":["ro"]}]`),
		// Exactly the prefix. applyVolumeNamePolicy admits this name
		// and the sweep reaches it, so this channel must too.
		"name_is_exactly_the_prefix": lvBody("volumes", `[{"Name":"`+lvSessionPrefix+`","Dest":"/bare"}]`),
	}
	for name, body := range cases {
		t.Run(name, func(t *testing.T) {
			fu := newFakeUpstream(t)
			h := startProxyWithMountVolumePrefix(t, fu, lvSessionPrefix)

			resp := postCreateJSON(t, h.sock, lvLibpodPath, body)
			if resp.StatusCode != http.StatusOK {
				got, _ := io.ReadAll(resp.Body)
				t.Fatalf("status: got %d, want 200 (body=%q)", resp.StatusCode, got)
			}
			got, _ := fu.lastBody.Load().([]byte)
			if !bytes.Equal(got, []byte(body)) {
				t.Errorf("upstream body was modified\n got: %s\nwant: %s", got, body)
			}
		})
	}
}

// TestLibpodVolumes_DockerCompatPlaceholder_Admitted is the functional
// AC for the docker meaning of the key. The docker-compat shape is a
// map of container path to an empty object. It names no volume, so the
// prefix rule has nothing to refuse and anonymous volumes keep
// working.
func TestLibpodVolumes_DockerCompatPlaceholder_Admitted(t *testing.T) {
	cases := map[string]string{
		"single_path":     lvBody("Volumes", `{"/data":{}}`),
		"two_paths":       lvBody("Volumes", `{"/data":{},"/cache":{}}`),
		"lowercase_key":   lvBody("volumes", `{"/data":{}}`),
		"null_value":      lvBody("Volumes", `{"/data":null}`),
		"empty_container": lvBody("Volumes", `{}`),
	}
	for name, body := range cases {
		t.Run(name, func(t *testing.T) {
			fu := newFakeUpstream(t)
			h := startProxyWithMountVolumePrefix(t, fu, lvSessionPrefix)

			resp := postCreateJSON(t, h.sock, lvDockerPath, body)
			if resp.StatusCode != http.StatusOK {
				got, _ := io.ReadAll(resp.Body)
				t.Fatalf("status: got %d, want 200 (body=%q)", resp.StatusCode, got)
			}
			if got := fu.captured(); got != 1 {
				t.Errorf("upstream request count: got %d, want 1", got)
			}
		})
	}
}

// TestLibpodVolumes_AbsentOrEmpty_Admitted is the edge-case AC: a body
// with no `volumes` key, or one whose value names nothing, is admitted
// exactly as it is today.
func TestLibpodVolumes_AbsentOrEmpty_Admitted(t *testing.T) {
	cases := map[string]string{
		"absent":            `{"image":"alpine"}`,
		"null":              lvBody("volumes", `null`),
		"empty_array":       lvBody("volumes", `[]`),
		"empty_object":      lvBody("volumes", `{}`),
		"array_of_nulls":    lvBody("volumes", `[null]`),
		"anonymous_no_name": lvBody("volumes", `[{"Dest":"/data"}]`),
		"anonymous_empty":   lvBody("volumes", `[{"Name":"","Dest":"/data"}]`),
	}
	for name, body := range cases {
		t.Run(name, func(t *testing.T) {
			fu := newFakeUpstream(t)
			h := startProxyWithMountVolumePrefix(t, fu, lvSessionPrefix)

			resp := postCreateJSON(t, h.sock, lvLibpodPath, body)
			if resp.StatusCode != http.StatusOK {
				got, _ := io.ReadAll(resp.Body)
				t.Fatalf("status: got %d, want 200 (body=%q)", resp.StatusCode, got)
			}
			if got := fu.captured(); got != 1 {
				t.Errorf("upstream request count: got %d, want 1", got)
			}
		})
	}
}

// ── shape and field admission on the value itself ───────────────────────

// TestLibpodVolumes_UnauditedEntryField_Denied pins the field-name
// layer on the new entry shape. libpodNamedVolume admits Name, Dest,
// and Options. A NamedVolume field podman adds later — or any field
// this repo has not audited — must refuse rather than forward, because
// there is no pinned upstream struct to check it against. The name in
// each body is IN prefix, so the refusal can only come from the
// unknown field.
func TestLibpodVolumes_UnauditedEntryField_Denied(t *testing.T) {
	cases := map[string]string{
		"SubPath":     lvBody("volumes", `[{"Name":"`+lvSessionPrefix+`a","Dest":"/a","SubPath":"sub"}]`),
		"IsAnonymous": lvBody("volumes", `[{"Name":"`+lvSessionPrefix+`a","Dest":"/a","IsAnonymous":true}]`),
		"Source":      lvBody("volumes", `[{"Name":"`+lvSessionPrefix+`a","Dest":"/a","Source":"/etc"}]`),
	}
	for field, body := range cases {
		t.Run(field, func(t *testing.T) {
			fu := newFakeUpstream(t)
			h := startProxyWithMountVolumePrefix(t, fu, lvSessionPrefix)

			resp := postCreateJSON(t, h.sock, lvLibpodPath, body)
			if resp.StatusCode != http.StatusForbidden {
				got, _ := io.ReadAll(resp.Body)
				t.Fatalf("status: got %d, want 403 (body=%q)", resp.StatusCode, got)
			}
			assertNoForward(t, fu)
			log := h.audit.String()
			if !strings.Contains(log, "create_volumes:unknown_field") {
				t.Errorf("audit log does not carry reason create_volumes:unknown_field; log=%s", log)
			}
			if !strings.Contains(log, field) {
				t.Errorf("audit reason does not name the rejected field %q; log=%s", field, log)
			}
		})
	}
}

// TestLibpodVolumes_UnsupportedShape_Denied covers the values that
// match NEITHER documented meaning of the key. Admitting an
// undocumented shape on this key is how the libpod meaning slipped
// through in the first place, so each one denies.
//
// These checks are NOT gated on VolumeNamePrefix — they are the
// field-name / field-value layers, which are unconditional everywhere
// else in this package — so the subtests run with the prefix unset as
// well.
func TestLibpodVolumes_UnsupportedShape_Denied(t *testing.T) {
	cases := []struct {
		name       string
		body       string
		wantReason string
	}{
		{"number", lvBody("volumes", `5`), "create_volumes_shape_not_allowed"},
		{"string", lvBody("volumes", `"myvol"`), "create_volumes_shape_not_allowed"},
		{"bool", lvBody("volumes", `true`), "create_volumes_shape_not_allowed"},
		{"entry_number", lvBody("volumes", `[5]`), "create_volumes_entry_shape_not_allowed"},
		{"entry_array", lvBody("volumes", `[["myvol","/data"]]`), "create_volumes_entry_shape_not_allowed"},
		{"map_value_not_empty", lvBody("Volumes", `{"/data":{"Name":"`+lvForeignVolume+`"}}`), "create_volumes_map_value_not_empty"},
		{"map_value_string", lvBody("Volumes", `{"/data":"`+lvForeignVolume+`"}`), "create_volumes_map_value_not_empty"},
	}
	for _, tc := range cases {
		for _, prefix := range []string{lvSessionPrefix, ""} {
			name := tc.name
			if prefix == "" {
				name += "_no_prefix"
			}
			t.Run(name, func(t *testing.T) {
				fu := newFakeUpstream(t)
				h := startProxyWithMountVolumePrefix(t, fu, prefix)

				resp := postCreateJSON(t, h.sock, lvLibpodPath, tc.body)
				if resp.StatusCode != http.StatusForbidden {
					got, _ := io.ReadAll(resp.Body)
					t.Fatalf("status: got %d, want 403 (body=%q)", resp.StatusCode, got)
				}
				assertNoForward(t, fu)
				if !strings.Contains(h.audit.String(), tc.wantReason) {
					t.Errorf("audit log does not carry reason %s; log=%s", tc.wantReason, h.audit.String())
				}
			})
		}
	}
}

// ── ordering: the escape-vector checks still win ────────────────────────

// TestLibpodVolumes_WorseViolationWinsAuditReason pins the check
// order. checkCreateVolumeNames runs after checkHostConfig, so a body
// that carries BOTH an escape vector and an out-of-prefix volume name
// must be audited under the escape vector. Adding a third name channel
// must not displace an existing threat-table mitigation in the log.
func TestLibpodVolumes_WorseViolationWinsAuditReason(t *testing.T) {
	foreign := `"volumes":[{"Name":"` + lvForeignVolume + `","Dest":"/data"}]`
	cases := []struct {
		name       string
		body       string
		wantReason string
	}{
		{
			name:       "privileged",
			body:       `{"image":"alpine","HostConfig":{"Privileged":true},` + foreign + `}`,
			wantReason: "privileged",
		},
		{
			name:       "host_bind",
			body:       `{"image":"alpine","HostConfig":{"Binds":["/etc:/host-etc"]},` + foreign + `}`,
			wantReason: "host_bind:",
		},
		{
			name:       "mount_type_glob",
			body:       `{"image":"alpine","HostConfig":{"Mounts":[{"Type":"glob","Source":"/etc/*","Target":"/x"}]},` + foreign + `}`,
			wantReason: "mount_type_not_allowed:",
		},
		{
			name:       "bind_volume_name",
			body:       `{"image":"alpine","HostConfig":{"Binds":["notours:/data"]},` + foreign + `}`,
			wantReason: "bind_volume_name_prefix_mismatch",
		},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			fu := newFakeUpstream(t)
			h := startProxyWithMountVolumePrefix(t, fu, lvSessionPrefix)

			resp := postCreateJSON(t, h.sock, lvLibpodPath, tc.body)
			if resp.StatusCode != http.StatusForbidden {
				got, _ := io.ReadAll(resp.Body)
				t.Fatalf("status: got %d, want 403 (body=%q)", resp.StatusCode, got)
			}
			assertNoForward(t, fu)
			log := h.audit.String()
			if !strings.Contains(log, tc.wantReason) {
				t.Errorf("audit reason: want %q in log; log=%s", tc.wantReason, log)
			}
			if strings.Contains(log, "create_volumes_name_prefix_mismatch") {
				t.Errorf("the top-level volumes policy displaced the worse violation %q in the audit log; log=%s",
					tc.wantReason, log)
			}
		})
	}
}

// ── the decode boundary between the two body shapes ─────────────────────

// TestLibpodBoundary_DangerousKeysRefusedAtDecode pins the boundary
// that made `volumes` the ONE leaking key, rather than the first of
// many.
//
// The collision surface is exactly the intersection of libpod
// SpecGenerator JSON key names with containerCreateBody TOP-LEVEL
// field names, case-insensitive. Anything outside that intersection
// dies at DisallowUnknownFields. Two facts do the protective work, and
// each key below rests on one of them:
//
//  1. libpod puts its security fields at SpecGenerator top level;
//     docker nests them inside HostConfig. A libpod body carries no
//     HostConfig key, so the whole hostConfig allowlist is unreachable
//     from it, and a top-level `privileged` / `mounts` / `devices`
//     matches no top-level field here.
//  2. libpod spells the rest in snake_case. `command`, `work_dir`,
//     `cap_add`, `device_cgroup_rule`, `env_host`, `httpproxy` do not
//     case-match `Cmd`, `WorkingDir` or any sibling.
//
// That protection is a LOAD-BEARING ACCIDENT. Nothing enforces it. One
// future podman field with a CamelCase tag, or one future top-level
// docker field added to containerCreateBody, opens the boundary and
// nothing else fails. It cannot be closed by reading source either:
// podman is not a Go dependency of this repo — the proxy speaks HTTP
// to a socket — so there is no upstream struct to diff against.
//
// This test is the only mechanism that holds the boundary. A change to
// containerCreateBody that admits one of these keys must be a
// deliberate field admission under docs/podman-proxy.md §4, with this
// test updated in the same commit and the new field INSPECTED or
// DENIED. Do not "fix" a failure here by deleting the row.
func TestLibpodBoundary_DangerousKeysRefusedAtDecode(t *testing.T) {
	cases := []struct {
		key   string
		value string
	}{
		{"mounts", `[{"type":"bind","source":"/etc","destination":"/host-etc"}]`},
		{"devices", `[{"path":"/dev/sda"}]`},
		{"device_cgroup_rule", `["a *:* rwm"]`},
		{"privileged", `true`},
		{"cap_add", `["SYS_ADMIN"]`},
		{"sysctl", `{"kernel.shmmax":"1024"}`},
		{"annotations", `{"run.oci.keep_original_groups":"1"}`},
		{"env_host", `true`},
		{"httpproxy", `true`},
		{"command", `["sh","-c","cat /etc/shadow"]`},
		{"work_dir", `"/etc"`},
	}
	for _, tc := range cases {
		t.Run(tc.key, func(t *testing.T) {
			fu := newFakeUpstream(t)
			h := startProxyWithMountVolumePrefix(t, fu, lvSessionPrefix)

			resp := postCreateJSON(t, h.sock, lvLibpodPath, lvBody(tc.key, tc.value))
			if resp.StatusCode != http.StatusForbidden {
				got, _ := io.ReadAll(resp.Body)
				t.Fatalf("SECURITY: libpod key %q was admitted at decode; status %d (body=%q). Read this test's doc comment before you change it.",
					tc.key, resp.StatusCode, got)
			}
			assertNoForward(t, fu)
			log := h.audit.String()
			if !strings.Contains(log, "create_top:unknown_field") {
				t.Errorf("libpod key %q must be refused at decode with an unknown_field reason; log=%s", tc.key, log)
			}
			if !strings.Contains(log, tc.key) {
				t.Errorf("audit reason does not name the rejected key %q; log=%s", tc.key, log)
			}
		})
	}
}

// ── unit: the string-entry name extractor ───────────────────────────────

// TestVolumeSpecName covers volumeSpecName's own table, including the
// two inputs where it deliberately differs from bindVolumeName: a
// source with a leading '/' (there is no host-bind branch on this
// channel to hand it to) and an entry with no colon (there is no
// destination, so the whole text is the name). Both differences exist
// so the prefix rule reaches an entry that would otherwise forward
// uninspected.
func TestVolumeSpecName(t *testing.T) {
	cases := []struct {
		in, want string
	}{
		{"myvol:/data", "myvol"},
		{"myvol:/data:ro", "myvol"},
		{"prism-foo-aaaaaaaa:/data", "prism-foo-aaaaaaaa"},
		{"myvol::ro", "myvol"},
		{"myvol", "myvol"},         // no colon: whole text is the name
		{"/etc:/host-etc", "/etc"}, // host-path source is still a name here
		{"./rel:/data", "./rel"},   // and so is a relative one
		{":/data", ""},             // empty source: nothing to name
		{"", ""},                   // empty entry
	}
	for _, tc := range cases {
		t.Run(tc.in, func(t *testing.T) {
			if got := volumeSpecName(tc.in); got != tc.want {
				t.Errorf("volumeSpecName(%q) = %q, want %q", tc.in, got, tc.want)
			}
		})
	}
}
