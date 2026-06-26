# Current Report From `stochastic`: Goal 042 Image Publication

## Task

- Task file read: `docs/ops/stochastic/inbox/current-task.md`
- Assigned goal packet, if any: `docs/goals/042-its-gitea-dev-image-publication-via-stochastic/`
- Start time: 2026-06-26 14:05:56 AEST +1000
- End time: 2026-06-26 14:36:10 AEST +1000

## Report Branch And Repo State

- Report branch: `codex/rpva-stochastic-goal042-image-publication`
- HEAD for built image: `9524304fb74805baad7672f81f219b8455a4aac8`
- `SOURCE_REF`: `9524304fb74805baad7672f81f219b8455a4aac8`
- `SHORT_SHA`: `9524304fb748`
- Report branch status before final staging: branch ahead of origin with report/evidence updates only after the Dockerfile fix commit.

## WSL And Tool Posture

- Host/OS summary: WSL2 Linux host `laptop`, kernel `6.18.33.1-microsoft-standard-WSL2`, x86_64; Ubuntu 24.04.4 LTS (Noble Numbat).
- Git: available, `git version 2.43.0`.
- Docker CLI: available, `Docker version 29.1.3, build 29.1.3-0ubuntu3~24.04.2`.
- Docker daemon: available, `server=29.5.3 arch=x86_64 cpus=16`.
- ITS Gitea host reachability: reachable without credentials; `curl -sSI --max-time 10 https://git.its.utas.edu.au/` returned `HTTP/1.1 200 OK`.
- R availability: Rscript available, `Rscript (R) version 4.6.0`.

## Image

- Target registry: `git.its.utas.edu.au`
- `TAG`: `dev-20260626-9524304fb748`
- `IMAGE`: `git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-20260626-9524304fb748`
- Tag collision or variant reason, if any: none observed.
- Confirmed not `latest`: yes.
- Lowercase namespace note: Barry explicitly authorized trying lowercase `utas` after Docker rejected uppercase `UTAS`.

## Build Result

- Build command summary: `docker build --platform linux/amd64 -f deploy/shinyproxy/practical1/Dockerfile.template --build-arg RPVA_REF=<SOURCE_REF> -t <LOWERCASE_IMAGE> .`
- Build result: success.
- Skipped because upstream failed: no.
- Retry used: no for the final successful build.
- Fix applied before final build: authorized Dockerfile template preinstall of locked `listenv` 0.10.1 before `renv::restore()`, matching the existing CI workaround for the known `renv` restore edge.
- Image inspect summary: image id `sha256:fcfb8ea7c9ddcf20efdc39fcd80829efb9ff82419966a2c876b209be057081c1`, size `1807797117`.

## Local Smoke Result

- Container name/id: `rpva-goal042-9524304fb748` / `d741b0c1ffb8077d4769fa163a38501a54814753191e7488815dfcc1c5c1392a`
- Local port: `3904`
- HTTP result: passed; Shiny homepage returned `11720` bytes.
- Smoke evidence: `docs/ops/stochastic/outbox/evidence/goal042/smoke-summary.txt`
- Temporary HTML handling: `smoke-home.html` was under 20 KB, classified as non-secret, and retained as evidence.
- Container cleanup confirmed: yes, `docker rm -f` was run after smoke.
- Skipped because upstream failed: no.

## Registry Login

- Login attempted: Barry refreshed Docker login interactively outside Codex; credentials were not entered into chat or repo files.
- Login result class: subsequent registry push succeeded, proving sufficient package write access for this image path.
- Retry used: yes, after the first push failed with `unauthorized: reqPackageAccess`.
- Skipped because upstream failed: no.

## Registry Push And Digest

- Push attempted: yes.
- Push result: success.
- Push status evidence: `docs/ops/stochastic/outbox/evidence/goal042/push-status.txt`
- Digest: `sha256:7aa013152b226d5ba3fcc34d31051fe049dd0f34c2c7e0187de83580523f4340`
- Manifest inspection: success; manifest digest matches pushed digest.
- Digest/manifest partial status: complete.
- Skipped because upstream failed: no.
- Docker logout result class: `logout_result=success`
- Confirmed no source push to ITS Gitea: yes.

## Mark-Ready Return Note

- Note path: `docs/ops/stochastic/outbox/evidence/goal042/mark-ready-return-note.md`
- Content summary: sendable note for Barry to Mark with image path, digest, source commit, local smoke result, no-secret statement, and requested ITS dev-server return details.

## Evidence

Evidence directory:

```text
docs/ops/stochastic/outbox/evidence/goal042/
```

List evidence files and checksums:

- `README.md`: `5d82178f7976f8dc42be2af72460707378ccb39629926191182321eb0ea95b1f`
- `build-summary.txt`: `d90364b659ccf1a69f67cc3baef89ea707e771186ad6819db6b5ff093365ee04`
- `digest.txt`: `31381678c7efac52eff4bbff97af0c512ea2c7a09d660b09dc44203ddfbab17e`
- `docker-logout-summary.txt`: `7b0ea96cea4b7ad6f12ea1c64157204130e5073e7af51d006831c02e6d393e08`
- `manifest-stderr.txt`: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`
- `manifest.txt`: `4f6fe9830f4fe61308aae70b6cf3dc7baec26a4c0b2930e6577e846f980541b1`
- `mark-ready-return-note.md`: `8fc743614e3d4c60d5f2a5018427c332eba54bd4e03c527735b116e36ee791d5`
- `push-output.txt`: `e720a4cdb97a6b0e698bed41a6da45766f9a92c972f8c95e200f37f02f615d35`
- `push-status.txt`: `9b43c41e65b2f06b159091617f3a55d7b97737420d5d82a707f1366bd3323391`
- `smoke-home.html`: `e38a9e78b5e54d6da42d2af802f5f83344f0caa8001a541e27f0f8e84572f68c`
- `smoke-summary.txt`: `dbf45ee81ab7e569507e84dd76be8715372332dce4108935a432c17fb5c5c1f3`
- `versions.txt`: `ea9c293da95edcb33f538272a549d30d34e694c9020f951c20507331b3993739`
- `SHA256SUMS.txt`: checksum manifest for the evidence files above.
- Checksum tool used, or unavailable: `sha256sum`

## Blockers Or Deviations

- Blocker: none remaining for Goal 042 image publication.
- Deviation: lower-case `utas` registry namespace used after Barry authorization because Docker rejects uppercase repository paths.
- Deviation: one bounded Dockerfile template fix applied after Barry authorization to preinstall locked `listenv` 0.10.1 before `renv::restore()`.

## Readiness Judgement

- Image publication succeeded: yes.
- Ready for Mark/ITS dev-server link/deploy step: yes.
- Suggested next gate: Barry can send `docs/ops/stochastic/outbox/evidence/goal042/mark-ready-return-note.md` to Mark/ITS and ask for the dev URL, SSO/access group, service-user home path, deployment directory, restart path, and tag-vs-digest pinning preference.

## Boundary Confirmation

Confirmed:

- no credentials, tokens, private keys, student identifiers, or sensitive service payloads were written to repo files, reports, screenshots, transcripts, markdown, logs, or chat;
- registry credentials were entered by Barry outside Codex and were not captured;
- no `main` push was performed;
- no source push to ITS Gitea was performed;
- one authorized Dockerfile template edit was made on the GitHub report branch; no app/source/YAML edits were made;
- no dev-server SSH/login, compose command, service restart, or live-state change was performed;
- no external contact, student/Moodle contact, KPZ314 work, Practical 2 implementation, or public exposure was performed.
