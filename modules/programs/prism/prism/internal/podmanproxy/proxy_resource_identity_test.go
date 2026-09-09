package podmanproxy

// Tests for the ADMIT half of issue #2951: a session must not be able to
// name another live session's container or volume in a create request.
//
// The sweep half lives in cmd/cleanup_sweep_identity_test.go. This file
// covers what the proxy refuses, because the two halves fail
// independently: a sweep that spares a foreign volume is no use if the
// create endpoint lets the session ATTACH it while the owner is still
// running.
//
// # Why these tests are not vacuous
//
// Before the change the sidecar wired the prefix to
// `prism-<sanitised session>-`, so a session called `foo` was admitted
// to name `prism-foo-bar-data` — a volume belonging to live session
// `foo-bar` — on every one of the four named-volume channels and on
// `POST /volumes/create`. The prefix now carries the session
// incarnation's instance ID, so those names fall outside it and the
// existing prefix checks refuse them.
//
// Each deny case below therefore names a volume that the PREVIOUS prefix
// admitted, and each is paired with a positive control that the session
// can still name its own volumes.
//
// The prefixes here are built by container.ResourceNamePrefixForOwner in
// production. They are written out literally instead, because
// internal/podmanproxy is stdlib-only by design — the proxy takes the
// prefix as a configured string and never derives it — and a test that
// imported the helper would stop testing the proxy's own contract.

import (
	"fmt"
	"io"
	"net/http"
	"strings"
	"testing"
)

const (
	// riTokenA and riTokenB are the instance tokens of two live
	// sessions: `foo` and the nested sibling `foo-bar`.
	riTokenA = "3f2a1b0c123456789abcdef012345678"
	riTokenB = "7d4e5f60abcd432187650fedcba98765"

	// riPrefix is what the sidecar wires for session `foo`.
	riPrefix = "prism-" + riTokenA + "-foo-"

	// riNestedLegacyName is the name issue #2951's coordinator comment
	// records as the open admit. Under the OLD prefix `prism-foo-` it
	// passed the check on every channel.
	riNestedLegacyName = "prism-foo-bar-data"

	// riNestedIdentityName is live session `foo-bar`'s volume under the
	// new naming. It must be refused for the same reason.
	riNestedIdentityName = "prism-" + riTokenB + "-foo-bar-data"

	// riFoldedName belongs to a session whose sanitised name folds onto
	// this one's. Distinct token, so it is refused too.
	riFoldedName = "prism-" + riTokenB + "-foo-pgdata"

	// riOwnName is this session's own volume: the positive control.
	riOwnName = riPrefix + "pgdata"
)

// riForeignNames is every name a session called `foo` must NOT be able
// to name, and riForeignReasons explains each one in a failure message.
var riForeignNames = []struct {
	name string
	why  string
}{
	{riNestedLegacyName, "nested sibling, pre-identity name (the admit issue #2951 records)"},
	{riNestedIdentityName, "nested sibling, identity-scoped name"},
	{riFoldedName, "folded sibling, identity-scoped name"},
	{"prism-foo-a1b2c3d4", "this session's own pre-identity name — a different incarnation owns it"},
	{"user-" + riPrefix + "pgdata", "substring trap"},
}

// ── POST /volumes/create ──────────────────────────────────────────────────

// TestResourceIdentity_VolumeCreate_ForeignNameDenied covers the
// endpoint that creates a volume outright.
func TestResourceIdentity_VolumeCreate_ForeignNameDenied(t *testing.T) {
	for _, tc := range riForeignNames {
		t.Run(tc.name, func(t *testing.T) {
			fu := newFakeUpstream(t)
			h := startProxyWithVolumePrefix(t, fu, riPrefix)

			resp := postVolumeCreateRaw(t, h.sock, map[string]any{"Name": tc.name})
			if resp.StatusCode != http.StatusForbidden {
				body, _ := io.ReadAll(resp.Body)
				t.Fatalf("status: got %d, want 403 for %s (body=%q)", resp.StatusCode, tc.why, body)
			}
			assertNoForward(t, fu)
			if !strings.Contains(h.audit.String(), "volume_name_prefix_mismatch") {
				t.Errorf("audit log does not carry volume_name_prefix_mismatch; log=%s", h.audit.String())
			}
		})
	}
}

// TestResourceIdentity_VolumeCreate_OwnNameAdmitted is the positive
// control for the endpoint above. Without it, a change that denied every
// name would make the deny tests pass.
func TestResourceIdentity_VolumeCreate_OwnNameAdmitted(t *testing.T) {
	fu := newFakeUpstream(t)
	h := startProxyWithVolumePrefix(t, fu, riPrefix)

	resp := postVolumeCreateRaw(t, h.sock, map[string]any{"Name": riOwnName})
	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		t.Fatalf("status: got %d, want 200 (body=%q)", resp.StatusCode, body)
	}
	if got := readUpstreamVolumeName(t, fu); got != riOwnName {
		t.Errorf("upstream Name: got %q, want %q", got, riOwnName)
	}
}

// TestResourceIdentity_VolumeCreate_InjectedNameCarriesTheToken pins the
// inject branch. A create with no Name receives `prefix + 8 hex`, and
// the prefix is the identity-bearing one, so the sweep's exact parse
// attributes the volume to this incarnation.
func TestResourceIdentity_VolumeCreate_InjectedNameCarriesTheToken(t *testing.T) {
	fu := newFakeUpstream(t)
	h := startProxyWithVolumePrefix(t, fu, riPrefix)

	resp := postVolumeCreateRaw(t, h.sock, map[string]any{})
	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		t.Fatalf("status: got %d, want 200 (body=%q)", resp.StatusCode, body)
	}
	got := readUpstreamVolumeName(t, fu)
	if !strings.HasPrefix(got, "prism-"+riTokenA+"-") {
		t.Errorf("injected name %q does not carry the instance token — the sweep cannot attribute it", got)
	}
}

// ── The four container-create channels ────────────────────────────────────

// TestResourceIdentity_MountChannels_ForeignNameDenied walks every
// channel a create body can name a volume through. All four share one
// rule, so all four shared the admit that issue #2951 records.
func TestResourceIdentity_MountChannels_ForeignNameDenied(t *testing.T) {
	channels := []struct {
		channel string
		reason  string
		body    func(volume string) string
	}{
		{
			channel: "HostConfig.Binds",
			reason:  "bind_volume_name_prefix_mismatch",
			body: func(v string) string {
				return fmt.Sprintf(`{"image":"alpine","HostConfig":{"Binds":[%q]}}`, v+":/data")
			},
		},
		{
			channel: "HostConfig.Mounts Type=volume",
			reason:  "mount_volume_name_prefix_mismatch",
			body: func(v string) string {
				return fmt.Sprintf(`{"image":"alpine","HostConfig":{"Mounts":[{"Type":"volume","Source":%q,"Target":"/data"}]}}`, v)
			},
		},
		{
			channel: "libpod volumes array",
			reason:  "create_volumes_name_prefix_mismatch",
			body: func(v string) string {
				return fmt.Sprintf(`{"image":"alpine","volumes":[{"Name":%q,"Dest":"/data"}]}`, v)
			},
		},
		{
			channel: "docker-compat volumes map key",
			reason:  "create_volumes_name_prefix_mismatch",
			body: func(v string) string {
				return fmt.Sprintf(`{"image":"alpine","Volumes":{%q:{}}}`, v+":/data")
			},
		},
	}

	for _, ch := range channels {
		for _, tc := range riForeignNames {
			t.Run(ch.channel+"/"+tc.name, func(t *testing.T) {
				fu := newFakeUpstream(t)
				h := startProxyWithMountVolumePrefix(t, fu, riPrefix)

				resp := postCreateJSON(t, h.sock, lvDockerPath, ch.body(tc.name))
				if resp.StatusCode != http.StatusForbidden {
					body, _ := io.ReadAll(resp.Body)
					t.Fatalf("status: got %d, want 403 for %s (body=%q)", resp.StatusCode, tc.why, body)
				}
				assertNoForward(t, fu)
				if !strings.Contains(h.audit.String(), ch.reason) {
					t.Errorf("audit log does not carry %s; log=%s", ch.reason, h.audit.String())
				}
			})
		}
	}
}

// TestResourceIdentity_MountChannels_OwnNameAdmitted is the positive
// control for all four named-volume channels. It is what proves the 403s above come
// from the name policy and not from an unrelated denial path — the
// bodies differ only in the volume name.
func TestResourceIdentity_MountChannels_OwnNameAdmitted(t *testing.T) {
	bodies := map[string]string{
		"HostConfig.Binds":              fmt.Sprintf(`{"image":"alpine","HostConfig":{"Binds":[%q]}}`, riOwnName+":/data"),
		"HostConfig.Mounts Type=volume": fmt.Sprintf(`{"image":"alpine","HostConfig":{"Mounts":[{"Type":"volume","Source":%q,"Target":"/data"}]}}`, riOwnName),
		"libpod volumes array":          fmt.Sprintf(`{"image":"alpine","volumes":[{"Name":%q,"Dest":"/data"}]}`, riOwnName),
		"docker-compat volumes map key": fmt.Sprintf(`{"image":"alpine","Volumes":{%q:{}}}`, riOwnName+":/data"),
	}
	for channel, body := range bodies {
		t.Run(channel, func(t *testing.T) {
			fu := newFakeUpstream(t)
			h := startProxyWithMountVolumePrefix(t, fu, riPrefix)

			resp := postCreateJSON(t, h.sock, lvDockerPath, body)
			if resp.StatusCode != http.StatusOK {
				respBody, _ := io.ReadAll(resp.Body)
				t.Fatalf("status: got %d, want 200 (body=%q)", resp.StatusCode, respBody)
			}
		})
	}
}

// ── Container names ───────────────────────────────────────────────────────

// TestResourceIdentity_ContainerName_ForeignNameDenied covers the
// container half. A container is stateless, so the harm is narrower than
// a volume attach — but a container named into another session's prefix
// is a container that session's cleanup would remove, which is a
// denial-of-service on a live sibling's workload.
func TestResourceIdentity_ContainerName_ForeignNameDenied(t *testing.T) {
	for _, name := range []string{
		"prism-foo-bar-aaaaaaaa",
		"prism-" + riTokenB + "-foo-bar-aaaaaaaa",
	} {
		t.Run(name, func(t *testing.T) {
			fu := newFakeUpstream(t)
			h := startProxyWithPrefix(t, fu, riPrefix)

			resp := postCreateRaw(t, h.sock, map[string]any{"Image": "alpine", "Name": name})
			if resp.StatusCode != http.StatusForbidden {
				body, _ := io.ReadAll(resp.Body)
				t.Fatalf("status: got %d, want 403 (body=%q)", resp.StatusCode, body)
			}
			assertNoForward(t, fu)
			if !strings.Contains(h.audit.String(), "name_prefix_mismatch_body") {
				t.Errorf("audit log does not carry name_prefix_mismatch_body; log=%s", h.audit.String())
			}
		})
	}
}

// TestResourceIdentity_ContainerName_InjectedNameCarriesTheToken pins
// the container inject branch, the counterpart of the volume one.
func TestResourceIdentity_ContainerName_InjectedNameCarriesTheToken(t *testing.T) {
	fu := newFakeUpstream(t)
	h := startProxyWithPrefix(t, fu, riPrefix)

	resp := postCreateRaw(t, h.sock, map[string]any{"Image": "alpine"})
	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		t.Fatalf("status: got %d, want 200 (body=%q)", resp.StatusCode, body)
	}
	got := readUpstreamName(t, fu)
	if !strings.HasPrefix(got, "prism-"+riTokenA+"-") {
		t.Errorf("injected name %q does not carry the instance token — the sweep cannot attribute it", got)
	}
}
