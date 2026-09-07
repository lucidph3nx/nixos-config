// Tests that `prism cleanup` removes the per-session podman-proxy audit
// directory.
//
// The audit log lives outside the session work dir so the agent cannot
// write its own audit trail (internal/container/podman_proxy_audit.go), and
// RemoveSessionWorkDir therefore does not reach it. Cleanup must remove it
// explicitly, or one audit log per containers-enabled session accumulates
// on the host forever.

package cmd

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/prismatic-koi/prism/internal/container"
	"github.com/prismatic-koi/prism/internal/db"
)

// plantAuditLog writes a non-empty audit log at the session instance's audit
// path and returns the path.
func plantAuditLog(t *testing.T, instanceID string) string {
	t.Helper()
	auditPath, err := container.PodmanProxyAuditLogPath(instanceID)
	if err != nil {
		t.Fatalf("PodmanProxyAuditLogPath(%q): %v", instanceID, err)
	}
	if err := os.MkdirAll(filepath.Dir(auditPath), 0o700); err != nil {
		t.Fatalf("mkdir audit dir: %v", err)
	}
	line := `{"timestamp":"2026-06-30T11:58:42.123456Z","method":"GET","endpoint":"/v1.41/_ping","decision":"allow","reason":""}` + "\n"
	if err := os.WriteFile(auditPath, []byte(line), 0o600); err != nil {
		t.Fatalf("write audit log: %v", err)
	}
	return auditPath
}

// seededInstanceIDs reads the instance ID of each session out of the DB, in
// the order given. One open serves every session: a fresh open applies the
// schema and every migration, which is the expensive part.
func seededInstanceIDs(t *testing.T, dbFile string, sessions ...string) []string {
	t.Helper()
	d, err := db.Open(dbFile)
	if err != nil {
		t.Fatalf("open db: %v", err)
	}
	defer d.Close()
	ids := make([]string, 0, len(sessions))
	for _, session := range sessions {
		instanceID := instanceIDFromStatus(d, session)
		if instanceID == "" {
			t.Fatalf("no instance_id recorded for %q", session)
		}
		ids = append(ids, instanceID)
	}
	return ids
}

// TestHeadlessCleanup_RemovesPodmanProxyAuditDir asserts that cleanup of a
// session removes that session's audit directory, and that a second
// session's audit log survives — cleanup removes the log of the session it
// cleans, not every log on the host.
func TestHeadlessCleanup_RemovesPodmanProxyAuditDir(t *testing.T) {
	t.Setenv("PRISM_HOST_API", "")
	withNoopTmux(t)

	dbFile := filepath.Join(t.TempDir(), "prism.db")
	session := "prism-test@2950-worker"
	bystander := "prism-test@2950-bystander"
	// Seeding plants the test-owned HOME and XDG_STATE_HOME, so every path
	// helper below resolves under the temp dir. Seed before deriving paths.
	_ = seedRowWithLifecycleFields(t, dbFile, session, "", "audit-hsid")
	_ = seedRowWithLifecycleFields(t, dbFile, bystander, "", "bystander-hsid")

	ids := seededInstanceIDs(t, dbFile, session, bystander)
	instanceID, bystanderInstanceID := ids[0], ids[1]

	auditPath := plantAuditLog(t, instanceID)
	bystanderAuditPath := plantAuditLog(t, bystanderInstanceID)

	// The work dir is planted too: the removal of the two trees is one
	// cleanup step, and a regression that drops either one must fail here.
	sessionDir, err := container.SessionWorkDirPath(instanceID)
	if err != nil {
		t.Fatalf("SessionWorkDirPath: %v", err)
	}
	if err := os.MkdirAll(sessionDir, 0o700); err != nil {
		t.Fatalf("mkdir session work dir: %v", err)
	}

	SetTestDBPath(dbFile)
	t.Cleanup(func() { SetTestDBPath("") })

	if err := headlessCleanup(session, "2950-worker", "", ""); err != nil {
		t.Fatalf("headlessCleanup: %v", err)
	}

	auditDir, err := container.PodmanProxyAuditDirPath(instanceID)
	if err != nil {
		t.Fatalf("PodmanProxyAuditDirPath: %v", err)
	}
	if _, err := os.Stat(auditPath); !os.IsNotExist(err) {
		t.Errorf("audit log still present after cleanup: %s (stat err %v)", auditPath, err)
	}
	if _, err := os.Stat(auditDir); !os.IsNotExist(err) {
		t.Errorf("audit dir still present after cleanup: %s (stat err %v)", auditDir, err)
	}
	if _, err := os.Stat(sessionDir); !os.IsNotExist(err) {
		t.Errorf("session work dir still present after cleanup: %s (stat err %v)", sessionDir, err)
	}
	if _, err := os.Stat(bystanderAuditPath); err != nil {
		t.Errorf("cleanup removed another session's audit log %s: %v", bystanderAuditPath, err)
	}
}
