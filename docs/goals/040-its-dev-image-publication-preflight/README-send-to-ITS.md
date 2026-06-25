# README: Sendable ITS Dev Image Preflight Bundle

This bundle is the sendable subset for Mark/ITS. It contains the current rPVA
dev-image publication handoff material.

Suggested files to send:

- `mark-dev-image-message-draft.md`: draft message Barry can adapt before
  sending.
- `its-vm-handoff.md`: platform, ownership, source repo, registry path, auth,
  data, update, and release-gate handoff.
- `gitea-registry-runbook.md`: image naming, tag/digest, push/pull, tarball
  fallback, staging-proof, and rollback guidance.
- `wsl-image-push-runbook.md`: Barry's WSL/GlobalProtect build and registry
  push steps, including safe credential handling.
- `application.its-staging.example.yml`: non-live ShinyProxy YAML example with
  angle-bracket stand-ins only where ITS values remain unknown.
- `SHA256SUMS.txt`: checksums for the bundle files.

This bundle does not include credentials, tokens, private keys, student
identifiers, image layers, live service config, or VM payloads.
