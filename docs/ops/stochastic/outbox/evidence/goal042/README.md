# Goal 042 Evidence Hygiene

This folder is for small non-secret evidence from the first controlled ITS
Gitea registry image publication by `stochastic`.

Allowed files:

- `versions.txt`: non-secret OS/Git/Docker/R posture summary.
- `build-summary.txt`: concise build result or sanitized failure signature.
- `smoke-summary.txt`: local container smoke result and response summary.
- `smoke-home.html`: optional only when tiny, useful, and classified as
  non-secret before staging.
- `push-output.txt`: concise registry push output.
- `push-status.txt`: captured push exit status.
- `digest.txt`: pushed image digest from `docker push`.
- `manifest.txt`: non-secret manifest inspection if available.
- `manifest-stderr.txt`: non-secret manifest inspection warning text if any.
- `docker-logout-summary.txt`: logout result class.
- `mark-ready-return-note.md`: sendable note for Barry to paste to Mark.
- `its-dev-prod-validation-report.md`: non-secret dev/prod smoke, capacity,
  monitoring, access, and release-readiness report.
- `SHA256SUMS.txt`: checksums for committed evidence files, generated with
  `sha256sum` when available or `shasum -a 256` as a fallback.

Avoid committing:

- large full build logs;
- full HTML pages unless they are tiny and clearly non-sensitive;
- temporary smoke HTML that has not been explicitly classified as small and
  non-secret;
- raw Docker credential or logout config;
- Docker login config;
- credentials;
- tokens;
- passwords;
- private keys;
- shell history captures;
- `.env` files;
- full environment dumps;
- student identifiers;
- live service secrets;
- sensitive config payloads.

If evidence cannot be captured safely, summarize the blocker in
`docs/ops/stochastic/outbox/current-report.md`.

If neither `sha256sum` nor `shasum` is available, record the missing checksum
tool in `docs/ops/stochastic/outbox/current-report.md` and continue; the task
should not fail solely because checksums could not be generated.
