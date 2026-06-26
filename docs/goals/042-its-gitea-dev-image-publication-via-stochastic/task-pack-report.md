# Goal 042 Task Pack Report

## Summary

Goal 042 prepares the repo-local task pack for `stochastic` to perform the
first controlled ITS Gitea registry image publication for the KPZ308 rPVA
ShinyProxy app.

This pack delegates live registry publication to the WSL/campus worker only.
`woodhen` did not access WSL, log in to ITS Gitea, build an image, push an
image, or alter any live service state.

## Key Task Choices

- `stochastic` must start from current `origin/main` and create a dedicated
  report branch:
  `codex/rpva-stochastic-goal042-image-publication`, with a suffix if needed.
- `stochastic` must not push `main`.
- `stochastic` must not push to the ITS Gitea source repository.
- `stochastic` may push only the dedicated GitHub report branch, and only with
  non-secret report/evidence files.
- The report branch setup checks both local and remote branch existence before
  choosing the default branch name.
- Registry image target is:
  `git.its.utas.edu.au/UTAS/kpz308-rpva-practical:<TAG>`.
- Default tag shape is immutable and source-linked:
  `dev-YYYYMMDD-<SHORT_SHA>`.
- `latest` is forbidden.
- The task authorizes Docker build, local WSL smoke, safe Docker registry login,
  registry image push, digest capture, Mark-ready return note, and non-secret
  report/evidence writing.
- Any build, smoke, login, push, or manifest inspection failure must still
  produce a report and, if possible, a dedicated GitHub report-branch push.
- Downstream operations are skipped after upstream failure: build failure means
  no smoke/login/push; smoke failure means no login/push; login failure means
  no push; push failure means no Mark deployment request.
- Docker push status is captured with `set -o pipefail` so `tee` cannot mask a
  push failure.
- Digest extraction is conditional on successful push; successful push without
  digest extraction is reported as partial.
- Local smoke HTML is temporary by default. It may be committed only when tiny,
  useful, and explicitly classified as non-secret.
- Docker logout runs after push/manifest capture unless Barry explicitly asks
  to keep the Docker session authenticated for this goal; only the logout
  result class is reported.
- External-service wording distinguishes between forbidden external contact and
  the explicitly authorized GitHub origin plus ITS Gitea host/registry
  operations.
- Evidence checksums prefer Ubuntu `sha256sum`, fall back to `shasum -a 256`,
  and are reportable-but-nonfatal if no checksum tool is available.
- The task forbids source/app/Dockerfile/YAML edits, dev-server SSH/login,
  compose down/up, service restart, ShinyProxy/nginx/systemd/firewall/DNS/TLS
  changes, token creation, credential capture, student/Moodle contact,
  Practical 2 implementation, KPZ314 work, external contact, and public
  exposure.

## Updated Files

- `docs/ops/stochastic/README.md`
- `docs/ops/stochastic/inbox/current-task.md`
- `docs/ops/stochastic/outbox/current-report.md`
- `docs/ops/stochastic/outbox/evidence/goal042/README.md`

## Expected Stochastic Outputs

`stochastic` should write:

- `docs/ops/stochastic/outbox/current-report.md`
- small non-secret files under
  `docs/ops/stochastic/outbox/evidence/goal042/`
- `docs/ops/stochastic/outbox/evidence/goal042/mark-ready-return-note.md`
- `docs/ops/stochastic/outbox/evidence/goal042/SHA256SUMS.txt`
  when a checksum tool is available, otherwise a report note that checksum
  generation was unavailable

It should commit only those report/evidence files on the dedicated report
branch and push only that branch to GitHub origin if possible.

## Residual Questions

- Whether Mark prefers future ShinyProxy config pinned by tag or digest.
- Exact dev-server URL, SSO/access-group expectation, service-user home path,
  deployment directory, and restart path to be returned by Mark after image
  publication.
- Whether the next orchestrator gate should treat a successful pushed image as
  enough for Mark handoff, or require one more WSL-side manifest/pull proof.

## Recommendation

Accept if validation remains green. The next gate should be orchestrator review
of this task pack, then publication/closeout of Goal 042 before Barry wakes
`stochastic` to execute the live registry publication.
