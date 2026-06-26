# Current Report From `stochastic`: Goal 042 Image Publication

## Task

- Task file read: `docs/ops/stochastic/inbox/current-task.md`
- Assigned goal packet, if any: `docs/goals/042-its-gitea-dev-image-publication-via-stochastic/`
- Start time: 2026-06-26 13:28:42 AEST +1000
- End time: 2026-06-26 13:43:28 AEST +1000

## Report Branch And Repo State

- Report branch: `codex/rpva-stochastic-goal042-image-publication`
- HEAD during latest build attempt: `e2e4016e215defc968702f0ff98e4f1f110eeb48`
- Source base: `15643e1bdd9714715bffda3b354c969c19667815`
- `SOURCE_REF`: `15643e1bdd9714715bffda3b354c969c19667815`
- `SHORT_SHA`: `15643e1bdd97`

## WSL And Tool Posture

- Host/OS summary: WSL2 Linux host `laptop`, kernel `6.18.33.1-microsoft-standard-WSL2`, x86_64; Ubuntu 24.04.4 LTS (Noble Numbat).
- Git: available, `git version 2.43.0`.
- Docker CLI: available, `Docker version 29.1.3, build 29.1.3-0ubuntu3~24.04.2`.
- Docker daemon: available, `server=29.5.3 arch=x86_64 cpus=16`.
- ITS Gitea host reachability: reachable without credentials; `curl -sSI --max-time 10 https://git.its.utas.edu.au/` returned `HTTP/1.1 200 OK`.
- R availability: Rscript available, `Rscript (R) version 4.6.0`.

## Image

- Target registry: `git.its.utas.edu.au`
- `TAG`: `dev-20260626-15643e1bdd97`
- `IMAGE`: `git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-20260626-15643e1bdd97`
- Tag collision or variant reason, if any: not checked; build failed before registry contact.
- Confirmed not `latest`: yes.
- Lowercase namespace note: Barry explicitly authorized trying lowercase `utas` after the first report showed Docker rejecting uppercase `UTAS`.

## Build Result

- Build command summary: `docker build --platform linux/amd64 -f deploy/shinyproxy/practical1/Dockerfile.template --build-arg RPVA_REF=<SOURCE_REF> -t <LOWERCASE_IMAGE> .`
- Build result: failed during `renv::restore()` inside the image.
- Skipped because upstream failed: no; this was the upstream failure after the lowercase image reference passed Docker validation.
- Retry used: yes, because the first lower-case build was classified as potentially transient before the failure repeated at the same package-restore stage.
- Failure signature, if any: `renv::restore(prompt = FALSE)` installed 85 packages, then failed to install `future`, `future.apply`, and `listenv`; the root package edge is the known locked `listenv` 0.10.1 restore issue documented in Goal 038.

## Local Smoke Result

- Container name/id: not created.
- Local port: not allocated.
- HTTP result: skipped.
- Smoke evidence: `docs/ops/stochastic/outbox/evidence/goal042/smoke-summary.txt`
- Temporary HTML handling: no temporary HTML created.
- Container cleanup confirmed: no container was created.
- Skipped because upstream failed: yes, Docker build failed before image creation.

## Registry Login

- Login attempted: no.
- Login result class: skipped because build failed.
- Retry used: no.
- Skipped because upstream failed: yes.

## Registry Push And Digest

- Push attempted: no.
- Push result: skipped because build failed.
- Push status evidence: `docs/ops/stochastic/outbox/evidence/goal042/push-status.txt`
- Digest: not available.
- Manifest inspection: skipped because no image was pushed.
- Digest/manifest partial status: no partial registry success occurred.
- Skipped because upstream failed: yes.
- Docker logout result class: not applicable; login was not attempted.
- Confirmed no source push to ITS Gitea: yes.

## Mark-Ready Return Note

- Note path: not created; skip evidence at `docs/ops/stochastic/outbox/evidence/goal042/mark-ready-return-note-skipped.txt`
- Content summary: Mark deployment request skipped because image publication did not complete.

## Evidence

Evidence directory:

```text
docs/ops/stochastic/outbox/evidence/goal042/
```

List evidence files and checksums:

- `README.md`: `5d82178f7976f8dc42be2af72460707378ccb39629926191182321eb0ea95b1f`
- `build-summary.txt`: `c0a6fa1edceea837810982b12492c77c3a7ef9aa4cb4c7bfbcf33b2a2acf90e6`
- `manifest-stderr.txt`: `0613403bee9adb4867e68ae18d9f0f990e3b8837c79e7a16e70f2e0909364c93`
- `mark-ready-return-note-skipped.txt`: `682f529ca0fff0ce08ad81b2d1bc0750f3115cd668cdcee230d5aa5d9266edf1`
- `push-status.txt`: `25a0b2d229c387d63e3759e89a0704efc1518a66f7ac82f6da170af3ccbd7887`
- `smoke-summary.txt`: `5751ebee9e8afaa7b0a7ee928fe712143ce1a617d9fa5340ae44dd5774839470`
- `versions.txt`: `85d3663cb432e99c36df5053a5df8d37838bdef6dd1f37369c980e4d339c1ab9`
- `SHA256SUMS.txt`: checksum manifest for the evidence files above.
- Checksum tool used, or unavailable: `sha256sum`

## Blockers Or Deviations

- Blocker: the uppercase Docker reference issue is resolved by the lower-case `utas` image reference, but the Docker build now fails at the known `renv`/`listenv` restore edge before a local image exists.
- Deviation: tried lower-case registry namespace after Barry explicitly authorized it. No source/app/Dockerfile/YAML edits were made.

## Readiness Judgement

- Image publication succeeded: no.
- Ready for Mark/ITS dev-server link/deploy step: no.
- Suggested next gate: authorize a bounded Dockerfile template fix equivalent to the existing CI workaround: install the locked `listenv` 0.10.1 source tarball before `renv::restore()`, then rerun the lower-case-image Goal 042 path. This next blocker appears repo/Dockerfile-side, not an ITS registry blocker.

## Boundary Confirmation

Confirmed:

- no credentials, tokens, private keys, student identifiers, or sensitive service payloads were written to repo files, reports, screenshots, transcripts, markdown, logs, or chat;
- no registry credentials were requested because build failed before login was appropriate;
- no `main` push was performed;
- no source push to ITS Gitea was performed;
- no source/app/Dockerfile/YAML edits were made;
- no dev-server SSH/login, compose command, service restart, or live-state change was performed;
- no external contact, student/Moodle contact, KPZ314 work, Practical 2 implementation, or public exposure was performed.
