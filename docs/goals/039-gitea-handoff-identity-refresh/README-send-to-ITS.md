# README: Sendable ITS Handoff Bundle

This bundle is the sendable subset for Mark/ITS. It excludes internal repo
review notes and reports.

Suggested files to send:

- `mark-update-draft.md`: draft message Barry can adapt before sending.
- `its-vm-handoff.md`: concise platform, ownership, app identity, auth,
  rootless-Docker, update, and release-gate handoff.
- `gitea-registry-runbook.md`: non-live image naming, tag/digest, push/pull,
  tarball-fallback, staging-proof, and rollback guidance.
- `application.its-staging.example.yml`: non-live ShinyProxy YAML example with
  angle-bracket stand-ins only.
- `SHA256SUMS.txt`: checksums for the bundle files.

Do not send internal repo-review files unless Barry specifically wants to share
project history. This bundle does not include credentials, tokens, private
keys, student identifiers, image layers, live service config, or VM payloads.
