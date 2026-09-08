package cmd

// cleanup_podman_proxy_archive_test.go — regression tests for issue #2959:
// the podman-proxy audit log must be copied into the session archive
// alongside agent-run.log, so the retention story matches the archive
// policy that already covers the harness transcript.

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/prismatic-koi/prism/internal/container"
)

// writeFakePodmanProxyAuditLog writes a fake podman-proxy.log at the path
// container.PodmanProxyAuditLogPath resolves for instanceID, creating the
// per-instance audit directory as the sidecar would. Returns the log
// content it wrote so the caller can assert byte-identity.
func writeFakePodmanProxyAuditLog(t *testing.T, instanceID string) (path, content string) {
	t.Helper()
	p, err := container.PodmanProxyAuditLogPath(instanceID)
	if err != nil {
		t.Fatalf("PodmanProxyAuditLogPath: %v", err)
	}
	if mkErr := os.MkdirAll(filepath.Dir(p), 0o700); mkErr != nil {
		t.Fatalf("mkdir audit dir: %v", mkErr)
	}
	content = `{"ts":"2026-04-25T14:31:00Z","method":"POST","endpoint":"/containers/create","decision":"allow","reason":""}` + "\n"
	if writeErr := os.WriteFile(p, []byte(content), 0o600); writeErr != nil {
		t.Fatalf("write podman-proxy.log: %v", writeErr)
	}
	return p, content
}

// TestHeadlessCleanup_ArchivesPodmanProxyAuditLog covers the containers-
// enabled case: a session with a podman-proxy audit log on disk gets that
// log copied into the archive as podman-proxy.log, byte-identical to the
// source, alongside the harness transcript.
func TestHeadlessCleanup_ArchivesPodmanProxyAuditLog(t *testing.T) {
	f := setupArchiveOrderFixture(t, "archive-order-podman-proxy", "")
	_, auditContent := writeFakePodmanProxyAuditLog(t, archiveOrderIID)

	if err := headlessCleanup(f.session, "archive-order-podman-proxy", "", ""); err != nil {
		t.Fatalf("headlessCleanup: %v", err)
	}

	archiveDir := assertTranscriptArchived(t, f)
	got, readErr := os.ReadFile(filepath.Join(archiveDir, "podman-proxy.log"))
	if readErr != nil {
		t.Fatalf("archive must contain podman-proxy.log: %v", readErr)
	}
	if string(got) != auditContent {
		t.Errorf("archived podman-proxy.log = %q, want %q", got, auditContent)
	}
}

// TestHeadlessCleanup_NoContainers_NoPodmanProxyLogInArchive covers the
// edge case named in the AC: a session that ran without --containers has no
// audit log on disk. The archive step must complete without error and must
// not create an empty placeholder podman-proxy.log in the archive.
func TestHeadlessCleanup_NoContainers_NoPodmanProxyLogInArchive(t *testing.T) {
	f := setupArchiveOrderFixture(t, "archive-order-no-containers", "")
	// Deliberately do NOT write a podman-proxy.log — this session never ran
	// with --containers, so container.PodmanProxyAuditLogPath resolves to a
	// path that does not exist on disk.

	if err := headlessCleanup(f.session, "archive-order-no-containers", "", ""); err != nil {
		t.Fatalf("headlessCleanup: %v", err)
	}

	archiveDir := assertTranscriptArchived(t, f)
	if _, statErr := os.Stat(filepath.Join(archiveDir, "podman-proxy.log")); !os.IsNotExist(statErr) {
		t.Errorf("podman-proxy.log should not exist in archive for a session with no audit log, but stat returned: %v", statErr)
	}
}
