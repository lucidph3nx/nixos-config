package cmd

// Tests for issue #2982: `prism spawn --repo <name>` was silently dropped on
// the host-API proxy path. Covers:
//   - proxySpawn forwards "repo" only when --repo was explicitly set.
//   - proxySpawn omits "repo" entirely when --repo was not passed.
//
// The host-side resolution (unresolvable --repo errors, self-delivery guard)
// is exercised in internal/sidecar/host_api_spawn_repo_test.go, since it
// requires a real host-side `prism spawn` subprocess invocation, which these
// client-side proxySpawn tests do not have.

import (
	"encoding/json"
	"net/http"
	"testing"
	"time"

	"github.com/spf13/cobra"
)

func newSpawnTestCmd() *cobra.Command {
	cmd := &cobra.Command{Use: "spawn"}
	cmd.Flags().String("branch", "", "")
	cmd.Flags().String("repo", "", "")
	cmd.Flags().String("agent", "", "")
	cmd.Flags().String("profile", "", "")
	cmd.Flags().String("model", "", "")
	cmd.Flags().String("variant", "", "")
	cmd.Flags().String("isolation", "", "")
	cmd.Flags().Bool("ignore-concurrency-cap", false, "")
	cmd.Flags().String("harness", "pi", "")
	addPromptFlags(cmd)
	return cmd
}

// TestProxySpawnBody_RepoForwardedOnlyWhenSet verifies that proxySpawn
// forwards "repo" in the request body when --repo was explicitly set on the
// command line, and omits the field entirely when it was not.
func TestProxySpawnBody_RepoForwardedOnlyWhenSet(t *testing.T) {
	cases := []struct {
		name        string
		setRepo     bool
		repoValue   string
		wantPresent bool
	}{
		{name: "unset_omitted", setRepo: false, wantPresent: false},
		{name: "set_forwards_value", setRepo: true, repoValue: "other-repo", wantPresent: true},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			rawCh := make(chan map[string]any, 1)
			srv := newMockUnixServer(t, func(w http.ResponseWriter, r *http.Request) {
				var raw map[string]any
				_ = json.NewDecoder(r.Body).Decode(&raw)
				rawCh <- raw
				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusOK)
				_, _ = w.Write([]byte(`{"session_name":"other-repo@repo-branch"}`))
			})

			t.Setenv("PRISM_HOST_API", srv.apiURL())
			t.Setenv("PRISM_BARE_ROOT", "/prism-git")

			cmd := newSpawnTestCmd()
			_ = cmd.Flags().Set("branch", "repo-branch")
			_ = cmd.Flags().Set("prompt", "hi")
			if tc.setRepo {
				_ = cmd.Flags().Set("repo", tc.repoValue)
			}

			if err := proxySpawn(srv.apiURL(), cmd); err != nil {
				t.Fatalf("proxySpawn: %v", err)
			}

			select {
			case raw := <-rawCh:
				val, present := raw["repo"]
				if present != tc.wantPresent {
					t.Fatalf("repo field present = %v, want %v; body = %v", present, tc.wantPresent, raw)
				}
				if tc.wantPresent && val != tc.repoValue {
					t.Errorf("repo = %v, want %q", val, tc.repoValue)
				}
			case <-time.After(3 * time.Second):
				t.Fatal("timed out waiting for request")
			}
		})
	}
}
