package sidecar

// Tests for the instance-ID resource-name prefix the sidecar wires into
// the podman proxy (issue #2951).
//
// This is the join between the two halves of the change. The proxy
// package takes the prefix as an opaque configured string and tests it
// against literals; the container package derives the prefix and tests
// the derivation. Neither one notices if THIS file's wiring hands the
// proxy a prefix built from the session name alone — which is the
// pre-change behaviour, and the behaviour that let one session claim
// another live session's containers and volumes.
//
// So the assertion here is on the prefix the running proxy actually
// enforces, read back out of its own 403 message.

import (
	"context"
	"encoding/json"
	"io"
	"net/http"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/prismatic-koi/prism/internal/container"
	"github.com/prismatic-koi/prism/internal/sidecar/sidecartest"
)

// pxIdentityInstanceID is a canonical UUID, because
// container.InstanceTokenForID accepts nothing else. A test that used
// the suite's usual "test-instance-<name>" string would exercise the
// documented fallback and pin nothing about identity.
const pxIdentityInstanceID = "3f2a1b0c-1234-5678-9abc-def012345678"

// TestPodmanProxy_NamePrefix_CarriesInstanceID asserts the running proxy
// enforces `prism-<instance token>-<sanitised session>-`, and that it
// refuses a name carrying only the legacy prefix.
//
// The legacy name in this test is not an arbitrary bad name. It is
// exactly what a nested sibling session could have created, and it is
// what the proxy ADMITTED before this change.
func TestPodmanProxy_NamePrefix_CarriesInstanceID(t *testing.T) {
	session := "prism-test@" + t.Name()
	bus := sidecartest.NewIsolated(t, session)

	// A non-existent upstream is fine: the name policy denies before any
	// dial attempt, so the friendly 503 path does not run.
	upstream := filepath.Join(bus.XDGStateHome, "unused-upstream.sock")

	sc, listenerPath := newPodmanProxyTestSidecarWithInstanceID(t, bus, session, upstream, pxIdentityInstanceID)
	setContainersEnabled(t, bus, session, true)

	ctx, cancel := context.WithCancel(context.Background())
	t.Cleanup(cancel)
	done := runSidecarBackground(t, sc, ctx)
	if !waitForPath(listenerPath, 3*time.Second) {
		t.Fatalf("podman.sock listener did not appear at %s", listenerPath)
	}
	defer func() {
		cancel()
		<-done
	}()

	client := proxyClientFor(listenerPath)

	legacyPrefix := container.ResourceNamePrefixForSession(session)
	identityPrefix := container.ResourceNamePrefixForOwner(pxIdentityInstanceID, session)

	// Guard the premise: if the two prefixes were equal the assertions
	// below would pass without proving anything.
	if legacyPrefix == identityPrefix {
		t.Fatalf("test premise broken: the identity prefix equals the legacy prefix (%q)", legacyPrefix)
	}

	// A volume name carrying only the legacy prefix must now be refused.
	// Under the old wiring this name was admitted, and it is the shape a
	// nested sibling's volume takes.
	resp, err := client.Post("http://podman.sock/v1.41/volumes/create",
		"application/json", strings.NewReader(`{"Name":"`+legacyPrefix+`bar-data"}`))
	if err != nil {
		t.Fatalf("POST volumes/create: %v", err)
	}
	body, _ := io.ReadAll(resp.Body)
	resp.Body.Close()
	if resp.StatusCode != http.StatusForbidden {
		t.Fatalf("status: got %d, want 403 (body=%q) — the sidecar wired a prefix that carries no instance ID",
			resp.StatusCode, body)
	}

	var env struct {
		Message string `json:"message"`
	}
	if err := json.Unmarshal(body, &env); err != nil {
		t.Fatalf("unmarshal envelope: %v (raw=%q)", err, body)
	}
	if !strings.Contains(env.Message, identityPrefix) {
		t.Errorf("the proxy is not enforcing the identity-bearing prefix %q; message=%q",
			identityPrefix, env.Message)
	}

	// Positive control: the same request with the identity prefix is
	// admitted by the policy. The upstream does not exist, so the proxy
	// answers 503 rather than 200 — which is still proof the name check
	// passed, because a name denial never reaches the dial.
	resp2, err := client.Post("http://podman.sock/v1.41/volumes/create",
		"application/json", strings.NewReader(`{"Name":"`+identityPrefix+`pgdata"}`))
	if err != nil {
		t.Fatalf("POST volumes/create (own name): %v", err)
	}
	body2, _ := io.ReadAll(resp2.Body)
	resp2.Body.Close()
	if resp2.StatusCode == http.StatusForbidden {
		t.Fatalf("the session's own volume name was refused (body=%q); the wired prefix is wrong", body2)
	}
}

// TestPodmanProxy_InjectedName_IsAttributableToTheSession closes the
// loop on the other create shape. A create with no Name receives an
// injected one, and that name is what `prism cleanup` has to attribute
// later — so it must parse back to this incarnation under
// container.ResourceIsOwnedBy, the same function the sweep uses.
//
// The proxy cannot make this assertion itself: it does not import
// internal/container, by design. The sidecar is where the two meet.
func TestPodmanProxy_InjectedName_IsAttributableToTheSession(t *testing.T) {
	session := "prism-test@" + t.Name()
	bus := sidecartest.NewIsolated(t, session)
	upstream := filepath.Join(bus.XDGStateHome, "unused-upstream.sock")

	sc, listenerPath := newPodmanProxyTestSidecarWithInstanceID(t, bus, session, upstream, pxIdentityInstanceID)
	setContainersEnabled(t, bus, session, true)

	ctx, cancel := context.WithCancel(context.Background())
	t.Cleanup(cancel)
	done := runSidecarBackground(t, sc, ctx)
	if !waitForPath(listenerPath, 3*time.Second) {
		t.Fatalf("podman.sock listener did not appear at %s", listenerPath)
	}
	defer func() {
		cancel()
		<-done
	}()

	// The proxy injects `prefix + 8 hex` when the body names nothing.
	// Reconstruct that name here rather than reading it off the
	// upstream, which does not exist on this path.
	prefix := container.ResourceNamePrefixForOwner(pxIdentityInstanceID, session)
	injected := prefix + "a1b2c3d4"

	if !container.ResourceIsOwnedBy(injected, pxIdentityInstanceID) {
		t.Fatalf("a name the proxy injects (%q) is not attributable to the session that created it — cleanup would leak it", injected)
	}
	// And it is attributable to nobody else.
	if container.ResourceIsOwnedBy(injected, "7d4e5f60-abcd-4321-8765-0fedcba98765") {
		t.Errorf("SECURITY: %q is attributable to a different incarnation", injected)
	}
}
