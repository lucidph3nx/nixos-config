package podmanproxy

// Tests for the per-session volume-name policy on the CONTAINER-CREATE
// mount paths (issue #2954).
//
// The policy lives in policy.go::checkMountedVolumeNames and is gated
// on Config.VolumeNamePrefix, the same knob applyVolumeNamePolicy uses
// for POST /volumes/create. It covers the two channels that attach a
// named volume to a container:
//
//   - HostConfig.Binds  — "myvol:/data[:options]"
//   - HostConfig.Mounts — an entry of Type=volume with Source="myvol"
//
// Both channels decoded the volume name and then ignored it before
// this change, which left two holes: an unprefixed volume the cleanup
// sweep could not find, and a cross-session attach of another
// session's volume by name.
//
// The deny tests and TestMountVolumeName_NegativeControl_EmptyPrefix
// are a pair: the negative control runs the SAME cross-session attach
// with the prefix unset and asserts it reaches the upstream. That is
// what proves the 403 comes from the new check and not from an
// unrelated policy path, in the shape §6 of docs/podman-proxy.md
// prescribes.

import (
	"bytes"
	"encoding/json"
	"io"
	"net/http"
	"path/filepath"
	"strings"
	"testing"
)

// The session under test and the foreign session whose volume it tries
// to attach. Named as constants because several tests below assert on
// both halves of the pair.
const (
	mvSessionPrefix = "prism-prism-test@mount-vol-"
	mvForeignVolume = "prism-prism-test@other-session-cafebabe"
)

// startProxyWithMountVolumePrefix stands up a harness with BOTH a
// bind-source allowlist and a VolumeNamePrefix. The bind allowlist is
// needed because these tests also assert the Type=bind and
// absolute-path Binds behaviour is unchanged, and those paths deny
// unless the source is a real directory inside the allowlist.
func startProxyWithMountVolumePrefix(t *testing.T, fu *fakeUpstream, prefix string) *proxyHarness {
	t.Helper()
	dir := shortSocketDir(t)
	listenPath := filepath.Join(dir, "proxy.sock")
	auditBuf := &bytes.Buffer{}

	allowedDir := mkRealDir(t, "allow")
	scratchDir := mkRealDir(t, "scratch")

	cfg := Config{
		ListenerPath:       listenPath,
		UpstreamPath:       fu.sockPath,
		AllowedBindSources: []string{allowedDir, scratchDir},
		VolumeNamePrefix:   prefix,
		AuditWriter:        auditBuf,
	}
	startProxyWithConfig(t, cfg, auditBuf, listenPath)
	return &proxyHarness{
		sock:       listenPath,
		audit:      auditBuf,
		allowedDir: allowedDir,
		scratchDir: scratchDir,
	}
}

// volumeMount returns a Mounts entry of Type=volume naming source.
func volumeMount(source string) map[string]any {
	return map[string]any{
		"Type":   "volume",
		"Source": source,
		"Target": "/data",
	}
}

// ── deny: HostConfig.Binds ──────────────────────────────────────────────

// TestMountVolumeName_BindsForeignVolume_Denied is the security AC: a
// containers/create whose Binds entry names a volume outside the
// session prefix returns 403 and does not reach the upstream.
func TestMountVolumeName_BindsForeignVolume_Denied(t *testing.T) {
	for _, bind := range []string{
		"notours:/data",
		// The options field must not let a name slip past.
		"notours:/data:ro",
		// Cross-session attach: another session's auto-named volume.
		mvForeignVolume + ":/data",
		// Substring trap: contains the prefix but does not start with
		// it.
		"user-" + mvSessionPrefix + "data:/data",
		// A relative source is a volume name per docker's Binds
		// grammar, and is not in the prefix.
		"../etc:/data",
	} {
		t.Run(bind, func(t *testing.T) {
			fu := newFakeUpstream(t)
			h := startProxyWithMountVolumePrefix(t, fu, mvSessionPrefix)

			resp := postCreate(t, h.sock, map[string]any{"Binds": []string{bind}})
			if resp.StatusCode != http.StatusForbidden {
				body, _ := io.ReadAll(resp.Body)
				t.Fatalf("status: got %d, want 403 (body=%q)", resp.StatusCode, body)
			}
			assertNoForward(t, fu)
			if !strings.Contains(h.audit.String(), "bind_volume_name_prefix_mismatch") {
				t.Errorf("audit log does not carry reason bind_volume_name_prefix_mismatch; log=%s", h.audit.String())
			}
			// The 403 must tell the caller what to do about it.
			env := readEnvelope(t, resp)
			if !strings.Contains(env.Message, mvSessionPrefix) {
				t.Errorf("deny message does not name the required prefix; message=%q", env.Message)
			}
		})
	}
}

// ── deny: HostConfig.Mounts, Type=volume ────────────────────────────────

// TestMountVolumeName_MountsForeignVolume_Denied is the security AC for
// the second channel: a Mounts entry of Type=volume whose Source is
// outside the session prefix returns 403.
func TestMountVolumeName_MountsForeignVolume_Denied(t *testing.T) {
	for _, source := range []string{
		"notours",
		mvForeignVolume,
		"user-" + mvSessionPrefix + "data",
		// Type=volume with a path-shaped Source was forwarded
		// uninspected before this change.
		"/etc",
	} {
		t.Run(source, func(t *testing.T) {
			fu := newFakeUpstream(t)
			h := startProxyWithMountVolumePrefix(t, fu, mvSessionPrefix)

			resp := postCreate(t, h.sock, map[string]any{
				"Mounts": []map[string]any{volumeMount(source)},
			})
			if resp.StatusCode != http.StatusForbidden {
				body, _ := io.ReadAll(resp.Body)
				t.Fatalf("status: got %d, want 403 (body=%q)", resp.StatusCode, body)
			}
			assertNoForward(t, fu)
			if !strings.Contains(h.audit.String(), "mount_volume_name_prefix_mismatch") {
				t.Errorf("audit log does not carry reason mount_volume_name_prefix_mismatch; log=%s", h.audit.String())
			}
		})
	}
}

// TestMountVolumeName_CrossSessionAttach_DeniedOnBothPaths is the
// cross-session data-access AC stated as one test, so the property is
// findable by name. A session must not be able to attach
// prism-<other-session>-<hex> through either channel.
func TestMountVolumeName_CrossSessionAttach_DeniedOnBothPaths(t *testing.T) {
	cases := map[string]map[string]any{
		"binds":  {"Binds": []string{mvForeignVolume + ":/data"}},
		"mounts": {"Mounts": []map[string]any{volumeMount(mvForeignVolume)}},
	}
	for name, hostConfig := range cases {
		t.Run(name, func(t *testing.T) {
			fu := newFakeUpstream(t)
			h := startProxyWithMountVolumePrefix(t, fu, mvSessionPrefix)

			resp := postCreate(t, h.sock, hostConfig)
			if resp.StatusCode != http.StatusForbidden {
				body, _ := io.ReadAll(resp.Body)
				t.Fatalf("SECURITY: cross-session volume attach was admitted; status %d (body=%q)",
					resp.StatusCode, body)
			}
			assertNoForward(t, fu)
		})
	}
}

// ── negative control: the checks are not no-ops ─────────────────────────

// TestMountVolumeName_NegativeControl_EmptyPrefix is the
// revert-and-watch-fail partner for every deny test above. It runs the
// same two cross-session attach requests with VolumeNamePrefix unset
// and asserts BOTH reach the upstream.
//
// If this test fails, the 403s above are being produced by some
// unrelated policy path and prove nothing about the new check. If the
// new check is deleted, the deny tests fail and this one still passes
// — the pair is what makes the coverage non-vacuous.
func TestMountVolumeName_NegativeControl_EmptyPrefix(t *testing.T) {
	cases := map[string]map[string]any{
		"binds":  {"Binds": []string{mvForeignVolume + ":/data"}},
		"mounts": {"Mounts": []map[string]any{volumeMount(mvForeignVolume)}},
	}
	for name, hostConfig := range cases {
		t.Run(name, func(t *testing.T) {
			fu := newFakeUpstream(t)
			h := startProxyWithMountVolumePrefix(t, fu, "")

			resp := postCreate(t, h.sock, hostConfig)
			if resp.StatusCode != http.StatusOK {
				body, _ := io.ReadAll(resp.Body)
				t.Fatalf("status: got %d, want 200 (with no prefix configured the name policy is a no-op; body=%q)",
					resp.StatusCode, body)
			}
			if got := fu.captured(); got != 1 {
				t.Errorf("upstream request count: got %d, want 1", got)
			}
		})
	}
}

// ── allow: in-prefix names forward unchanged ────────────────────────────

// TestMountVolumeName_PrefixedVolume_ForwardedUnchanged is the
// functional AC: a named volume inside the session prefix is admitted
// on both paths, and the body the upstream receives is byte-identical
// to the one the client sent. This policy refuses; it never rewrites.
func TestMountVolumeName_PrefixedVolume_ForwardedUnchanged(t *testing.T) {
	cases := map[string]map[string]any{
		"binds": {"Binds": []string{
			mvSessionPrefix + "pgdata:/var/lib/postgresql/data",
			mvSessionPrefix + "cache:/cache:ro",
			// Exactly the prefix. applyVolumeNamePolicy admits this
			// name and the sweep reaches it, so this path must too.
			mvSessionPrefix + ":/bare",
		}},
		"mounts": {"Mounts": []map[string]any{
			volumeMount(mvSessionPrefix + "pgdata"),
			volumeMount(mvSessionPrefix + "aaaaaaaa"),
		}},
	}
	for name, hostConfig := range cases {
		t.Run(name, func(t *testing.T) {
			fu := newFakeUpstream(t)
			h := startProxyWithMountVolumePrefix(t, fu, mvSessionPrefix)

			sent, err := json.Marshal(map[string]any{
				"Image":      "alpine",
				"HostConfig": hostConfig,
			})
			if err != nil {
				t.Fatalf("marshal body: %v", err)
			}
			resp := postCreate(t, h.sock, hostConfig)
			if resp.StatusCode != http.StatusOK {
				body, _ := io.ReadAll(resp.Body)
				t.Fatalf("status: got %d, want 200 (body=%q)", resp.StatusCode, body)
			}
			got, _ := fu.lastBody.Load().([]byte)
			if !bytes.Equal(got, sent) {
				t.Errorf("upstream body was modified\n got: %s\nwant: %s", got, sent)
			}
		})
	}
}

// TestMountVolumeName_AnonymousVolume_Admitted pins the documented
// residual rather than an accident. A Type=volume mount with an empty
// Source is an ANONYMOUS volume: the runtime picks the name, so there
// is no name to refuse. It forwards, and the resulting volume is
// outside the sweep's reach — docs/podman-proxy.md §8.3 records that.
//
// If a later change decides to deny anonymous volumes, this test is
// the one to update, and §8.3 with it.
func TestMountVolumeName_AnonymousVolume_Admitted(t *testing.T) {
	fu := newFakeUpstream(t)
	h := startProxyWithMountVolumePrefix(t, fu, mvSessionPrefix)

	resp := postCreate(t, h.sock, map[string]any{
		"Mounts": []map[string]any{
			{"Type": "volume", "Target": "/data"},
		},
	})
	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		t.Fatalf("status: got %d, want 200 (body=%q)", resp.StatusCode, body)
	}
}

// ── unchanged behaviour: host paths and malformed entries ───────────────

// TestMountVolumeName_HostPathBinds_Unchanged is the edge-case AC: a
// Binds entry whose source has a leading '/' keeps the bind-source
// allowlist and its EvalSymlinks handling, with the volume-name policy
// active. Allowed source passes, foreign source still denies with the
// host_bind reason — not with a volume-name reason.
func TestMountVolumeName_HostPathBinds_Unchanged(t *testing.T) {
	t.Run("allowed_source_passes", func(t *testing.T) {
		fu := newFakeUpstream(t)
		h := startProxyWithMountVolumePrefix(t, fu, mvSessionPrefix)

		resp := postCreate(t, h.sock, map[string]any{
			"Binds": []string{h.allowedDir + ":/work"},
		})
		if resp.StatusCode != http.StatusOK {
			body, _ := io.ReadAll(resp.Body)
			t.Fatalf("status: got %d, want 200 (body=%q)", resp.StatusCode, body)
		}
	})

	t.Run("foreign_source_denies_as_host_bind", func(t *testing.T) {
		fu := newFakeUpstream(t)
		h := startProxyWithMountVolumePrefix(t, fu, mvSessionPrefix)

		resp := postCreate(t, h.sock, map[string]any{
			"Binds": []string{"/etc:/host-etc"},
		})
		if resp.StatusCode != http.StatusForbidden {
			body, _ := io.ReadAll(resp.Body)
			t.Fatalf("status: got %d, want 403 (body=%q)", resp.StatusCode, body)
		}
		assertNoForward(t, fu)
		log := h.audit.String()
		if !strings.Contains(log, "host_bind:") {
			t.Errorf("audit reason must stay host_bind for an absolute source; log=%s", log)
		}
		if strings.Contains(log, "volume_name_prefix_mismatch") {
			t.Errorf("an absolute bind source must not be read as a volume name; log=%s", log)
		}
	})
}

// TestMountVolumeName_BindTypeMount_Unchanged is the same edge-case AC
// for the Mounts channel: Type=bind keeps the bind-source allowlist,
// and the volume-name policy does not touch it.
func TestMountVolumeName_BindTypeMount_Unchanged(t *testing.T) {
	t.Run("allowed_source_passes", func(t *testing.T) {
		fu := newFakeUpstream(t)
		h := startProxyWithMountVolumePrefix(t, fu, mvSessionPrefix)

		resp := postCreate(t, h.sock, map[string]any{
			"Mounts": []map[string]any{
				{"Type": "bind", "Source": h.scratchDir, "Target": "/scratch"},
			},
		})
		if resp.StatusCode != http.StatusOK {
			body, _ := io.ReadAll(resp.Body)
			t.Fatalf("status: got %d, want 200 (body=%q)", resp.StatusCode, body)
		}
	})

	t.Run("foreign_source_denies_as_mount_bind", func(t *testing.T) {
		fu := newFakeUpstream(t)
		h := startProxyWithMountVolumePrefix(t, fu, mvSessionPrefix)

		resp := postCreate(t, h.sock, map[string]any{
			"Mounts": []map[string]any{
				{"Type": "bind", "Source": "/etc", "Target": "/host-etc"},
			},
		})
		if resp.StatusCode != http.StatusForbidden {
			body, _ := io.ReadAll(resp.Body)
			t.Fatalf("status: got %d, want 403 (body=%q)", resp.StatusCode, body)
		}
		assertNoForward(t, fu)
		log := h.audit.String()
		if !strings.Contains(log, "mount_bind:") {
			t.Errorf("audit reason must stay mount_bind for a Type=bind source; log=%s", log)
		}
		if strings.Contains(log, "volume_name_prefix_mismatch") {
			t.Errorf("a Type=bind Source must not be read as a volume name; log=%s", log)
		}
	})
}

// TestMountVolumeName_MalformedBindNoColon_Forwarded is the edge-case
// AC: a Binds entry with no colon is invalid bind syntax and keeps its
// pre-change behaviour — forwarded, for the upstream to reject. The
// proxy must not fabricate a policy decision for a request podman
// rejects on its own.
func TestMountVolumeName_MalformedBindNoColon_Forwarded(t *testing.T) {
	for _, bind := range []string{
		"no-colon",
		"",
		// Colon present but no source: nothing to name-check either.
		":/data",
	} {
		t.Run(bind, func(t *testing.T) {
			fu := newFakeUpstream(t)
			h := startProxyWithMountVolumePrefix(t, fu, mvSessionPrefix)

			resp := postCreate(t, h.sock, map[string]any{"Binds": []string{bind}})
			if resp.StatusCode != http.StatusOK {
				body, _ := io.ReadAll(resp.Body)
				t.Fatalf("status: got %d, want 200 (malformed binds forward to the upstream; body=%q)",
					resp.StatusCode, body)
			}
			if got := fu.captured(); got != 1 {
				t.Errorf("upstream request count: got %d, want 1", got)
			}
		})
	}
}

// ── ordering: the escape-vector checks still win ────────────────────────

// TestMountVolumeName_WorseViolationWinsAuditReason pins the check
// order. checkMountedVolumeNames runs last, so a body that carries
// BOTH an escape vector and an out-of-prefix volume name must be
// audited under the escape vector. Adding the name policy must not
// displace an existing threat-table mitigation in the log.
func TestMountVolumeName_WorseViolationWinsAuditReason(t *testing.T) {
	cases := []struct {
		name       string
		hostConfig map[string]any
		wantReason string
	}{
		{
			name: "privileged",
			hostConfig: map[string]any{
				"Privileged": true,
				"Binds":      []string{mvForeignVolume + ":/data"},
			},
			wantReason: "privileged",
		},
		{
			name: "host_bind",
			hostConfig: map[string]any{
				"Binds": []string{"/etc:/host-etc", mvForeignVolume + ":/data"},
			},
			wantReason: "host_bind:",
		},
		{
			name: "mount_type_glob",
			hostConfig: map[string]any{
				"Mounts": []map[string]any{
					{"Type": "glob", "Source": "/etc/*", "Target": "/x"},
					volumeMount(mvForeignVolume),
				},
			},
			wantReason: "mount_type_not_allowed:",
		},
		{
			name: "volume_driver_config",
			hostConfig: map[string]any{
				"Mounts": []map[string]any{
					{
						"Type":   "volume",
						"Source": mvForeignVolume,
						"Target": "/x",
						"VolumeOptions": map[string]any{
							"DriverConfig": map[string]any{
								"Name":    "local",
								"Options": map[string]string{"device": "/etc", "o": "bind"},
							},
						},
					},
				},
			},
			wantReason: "mount_volume_driver_config",
		},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			fu := newFakeUpstream(t)
			h := startProxyWithMountVolumePrefix(t, fu, mvSessionPrefix)

			resp := postCreate(t, h.sock, tc.hostConfig)
			if resp.StatusCode != http.StatusForbidden {
				body, _ := io.ReadAll(resp.Body)
				t.Fatalf("status: got %d, want 403 (body=%q)", resp.StatusCode, body)
			}
			assertNoForward(t, fu)
			log := h.audit.String()
			if !strings.Contains(log, tc.wantReason) {
				t.Errorf("audit reason: want %q in log; log=%s", tc.wantReason, log)
			}
			if strings.Contains(log, "volume_name_prefix_mismatch") {
				t.Errorf("the volume-name policy displaced the worse violation %q in the audit log; log=%s",
					tc.wantReason, log)
			}
		})
	}
}

// ── unit: the two source extractors partition the same string ───────────

// TestBindVolumeName covers bindVolumeName's own table, and pins the
// complement property against bindSource: for any Binds entry, at most
// one of the two returns a non-empty value, and an entry with a colon
// and a non-empty source always yields exactly one. A gap between them
// is a source that nothing inspects.
func TestBindVolumeName(t *testing.T) {
	cases := []struct {
		in, want string
	}{
		{"myvol:/data", "myvol"},
		{"myvol:/data:ro", "myvol"},
		{"prism-foo-aaaaaaaa:/data", "prism-foo-aaaaaaaa"},
		{"./rel:/data", "./rel"},        // relative source reads as a name
		{"../etc:/data", "../etc"},      // and so does this one
		{"myvol::ro", "myvol"},          // empty dst, name still extracted
		{"/host/src:/in_container", ""}, // host path — bindSource's
		{"/", ""},                       // no colon = invalid syntax
		{"no-colon", ""},                // invalid syntax
		{":/data", ""},                  // empty source, nothing to name
		{"", ""},                        // empty
	}
	for _, tc := range cases {
		t.Run(tc.in, func(t *testing.T) {
			got := bindVolumeName(tc.in)
			if got != tc.want {
				t.Errorf("bindVolumeName(%q) = %q, want %q", tc.in, got, tc.want)
			}
			if src := bindSource(tc.in); src != "" && got != "" {
				t.Errorf("bindSource(%q)=%q and bindVolumeName(%q)=%q are both non-empty; the two must partition the source",
					tc.in, src, tc.in, got)
			}
		})
	}
}
