# KPZ308 Practical 1 Final Polish Deployment

Status: immutable image published; dev and production deployment pending

## Release Identity

| Field | Value |
|---|---|
| App ID | `kpz308-rpva-practical` |
| Source commit | `bdb15517d2fe56105c76547a66218e6f798c24ce` |
| Source branch state | clean `main`; source equals `origin/main` |
| Immutable image | `git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-20260716-bdb15517d2fe` |
| Registry digest | `sha256:4c4a57e3b8d1ba1e08984bda333051b06f5ed8b2b1d4a18af8002db0c16d118c` |
| Registry media type | `application/vnd.docker.distribution.manifest.v2+json` |
| Local image ID | `sha256:a13a7e143b4200a4160317f7a018293ea6b212ab9bd35709249c5ad793fe08e1` |
| OCI source revision | `bdb15517d2fe56105c76547a66218e6f798c24ce` |
| Target platform | `linux/amd64` |
| Build window | `2026-07-16T01:49:46Z` to `2026-07-16T01:57:07Z` |
| Publication window | `2026-07-16T01:59:39Z` to `2026-07-16T02:03:09Z` |

Tasks 11 and 12 must use the image and digest above unchanged. Stop if a
remote pull reports a different repository digest or OCI source revision.

## Scope And Approved Design

This release implements the signed-off Practical 1 Core plus Explore Further
classroom route in
`docs/superpowers/specs/2026-07-15-practical1-final-polish-design.md`.
Practical 2 source, image, access groups, workspace root, and configuration are
outside this release and must remain unchanged.

## Source Commit And Test Summary

Task 9 froze and approved the source before image construction. The complete
record is `.superpowers/sdd/practical1-final-task-9-release-report.md`.

- Bootstrap and `renv` status checks completed.
- Focused teaching API and Practical 1 Shiny suites passed.
- The full `tests/testthat` suite, including Practical 2, passed.
- The Practical 1 deployment scaffold validator passed.
- The source-launched browser gate passed 135/135 checks with 14 non-empty
  artifacts and empty console-error, console-warning, and page-error arrays.
- The final independent source audit reported no Critical, Important, or Minor
  findings.

## Immutable Image And Local Acceptance

Docker Desktop 4.82.0 supplied Docker Engine 29.6.1, BuildKit 0.31.1, and
Buildx 0.35.0-desktop.2. An initial attempt ended before any Dockerfile step
when Docker Desktop's WSL-mounted CLI/storage layer went offline. Docker
Desktop then reported its engine stopped and the Ubuntu proxy was detached.
A supported Docker Desktop CLI restart restored the `Ubuntu-24.04` proxy and
daemon. The unchanged source, tag, and build command were then run from the
beginning and completed successfully.

Local scratch evidence was captured under:

- `/tmp/rpva-practical1-task10-dev-20260716-bdb15517d2fe`
- `/tmp/rpva-practical1-image-bdb15517d2fe`

These paths are transient; the acceptance facts needed for deployment are
recorded below.

### Build And Identity

- The image was built with
  `deploy/shinyproxy/practical1/Dockerfile.template`,
  `--platform linux/amd64`, and
  `RPVA_REF=bdb15517d2fe56105c76547a66218e6f798c24ce`.
- The successful image ID is
  `sha256:a13a7e143b4200a4160317f7a018293ea6b212ab9bd35709249c5ad793fe08e1`.
- The image's `org.opencontainers.image.revision` label equals the full source
  commit.
- After publication, local `RepoDigests` resolved to
  `git.its.utas.edu.au/utas/kpz308-rpva-practical@sha256:4c4a57e3b8d1ba1e08984bda333051b06f5ed8b2b1d4a18af8002db0c16d118c`.
- A fresh registry manifest inspection returned the same digest.

### Bounded Container Smoke

- Container name: `rpva-practical-smoke-bdb15517d2fe`.
- Health reached `healthy` on attempt 4 of the bounded wait loop.
- `http://127.0.0.1:3838/` returned the Practical 1 page and expected title,
  navigation, and learning-surface markers.
- The smoke container was removed after the check.

### Image Browser Acceptance

- Container name: `rpva-practical1-browser-bdb15517d2fe`.
- Health reached `healthy` on attempt 4 of the bounded wait loop.
- Acceptance URL: `http://127.0.0.1:3922`.
- Result: 135/135 browser checks passed.
- Result: 14/14 non-report artifacts were non-empty.
- Console errors, console warnings, and page errors were empty.
- Desktop and mobile Concept Lab, Compare, and extension screenshots were
  visually spot-checked at original resolution.
- The acceptance container was removed after the check.

## Independent Task 10 Review

A bounded read-only audit independently rechecked the release evidence and
returned **APPROVE** with no material assumptions or uncertainty.

- `HEAD`, `origin/main`, and live `origin/main` all resolved to the recorded
  source commit.
- Live Docker inspection confirmed `linux/amd64`, the recorded local image ID,
  and the exact OCI source revision.
- Smoke health, page marker, and container cleanup were confirmed.
- Browser evidence contained 135/135 passing checks, 14 non-empty artifacts
  whose sizes matched the report, and no console or page failures.
- The push log, saved manifest, live registry inspection, and local
  `RepoDigests` all resolved to the recorded registry digest.
- The initial Docker Desktop failure was classified as non-material because
  the complete retry retained the same source and tag and produced the image
  subsequently inspected and published.

## Dev Deployment

Pending Task 11 on Saturday 2026-07-18. Record the dev backup, exact
configuration diff, remote image identity, health, logs, browser route,
exports, checksums, and Practical 2 regression here.

## Production Deployment

Pending Task 12 on Sunday 2026-07-19. Record the production backup, exact
configuration diff, remote image identity, health, logs, browser route,
exports, checksums, and Practical 2 regression here.

## KPZ308 Student Path

Pending an enrolled-student check if an authorized tester is available.

## Remaining Caveats

- Practical 1 session state is in memory. Students must download their
  comparison CSV and evidence notes before closing the app.
- Record the known non-blocking remote IPv4-forwarding warning here only if it
  is observed during the scheduled deployment.

## Monday Freeze

Pending final production acceptance. After sign-off, normal deployment changes
freeze for the Monday 2026-07-20 class.

## Rollback

The current production Practical 1 rollback image is
`git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-20260713-02b09aeed4f0`.
Record the dev and production permission-preserving backup filenames during
Tasks 11 and 12. Rollback must restore only Practical 1, restart ShinyProxy,
wait for actuator health `UP`, and repeat Staff browser acceptance. It must not
alter Practical 2.
