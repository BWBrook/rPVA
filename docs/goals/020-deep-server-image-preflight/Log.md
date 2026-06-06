# Log

## 2026-06-05 - CoS Goal Publication And Branch Setup

- CoS directed `woodhen` to create and execute Goal 020 under the current
  `BB -> CoS -> Action Agent` model.
- Objective: run a bounded `deep-server` `x86_64` Docker image-build preflight
  for the Practical 1 Shiny deployment scaffold before any ShinyProxy/nginx
  service staging.
- CoS stated that Goal 019 was committed and pushed as:
  - `38ef13f Add Practical 1 local deployment preflight`
- First checkpoint before editing:
  - CWD: `/Users/bwbrook/.codex/worktrees/a4af/rPVA`
  - branch: `codex/rpva-goal019-local-deployment-preflight`
  - HEAD:
    `38ef13f (HEAD -> codex/rpva-goal019-local-deployment-preflight, origin/main, origin/codex/rpva-goal019-local-deployment-preflight, origin/HEAD, main) Add Practical 1 local deployment preflight`
  - status:
    `## codex/rpva-goal019-local-deployment-preflight...origin/codex/rpva-goal019-local-deployment-preflight`
- Ran `git fetch --prune origin`.
- Confirmed `origin/main` resolves to
  `38ef13fd4ada7dfd4b9523ba22bc154eb53e6ec0`.
- Confirmed no local or remote branch named
  `codex/rpva-goal020-deep-server-image-preflight` was present.
- Created and switched to branch:
  `codex/rpva-goal020-deep-server-image-preflight` from `origin/main`.
- Confirmed branch state after switching:
  - CWD: `/Users/bwbrook/.codex/worktrees/a4af/rPVA`
  - branch: `codex/rpva-goal020-deep-server-image-preflight`
  - HEAD:
    `38ef13f (HEAD -> codex/rpva-goal020-deep-server-image-preflight, origin/main, origin/codex/rpva-goal019-local-deployment-preflight, origin/HEAD, main, codex/rpva-goal019-local-deployment-preflight) Add Practical 1 local deployment preflight`
  - status:
    `## codex/rpva-goal020-deep-server-image-preflight...origin/main`

## 2026-06-05 - Context Review

- Read required Goal 019 files:
  - `docs/goals/019-practical-1-local-deployment-preflight/Goal.md`
  - `docs/goals/019-practical-1-local-deployment-preflight/Plan.md`
  - `docs/goals/019-practical-1-local-deployment-preflight/Runbook.md`
  - `docs/goals/019-practical-1-local-deployment-preflight/Log.md`
- Read existing scaffold files:
  - `deploy/shinyproxy/practical1/README.md`
  - `deploy/shinyproxy/practical1/Dockerfile.template`
  - `deploy/shinyproxy/practical1/dockerignore.template`
  - `deploy/shinyproxy/practical1/application.example.yml`
  - `deploy/shinyproxy/practical1/nginx-practical1.example.conf`
  - `deploy/shinyproxy/practical1/validate-scaffold.sh`
- Read Shiny planning docs:
  - `docs/teaching/shiny/README.md`
  - `docs/teaching/shiny/implementation-roadmap.md`
  - `docs/teaching/shiny/deep-server-hosting-feasibility.md`
  - `docs/teaching/shiny/platform-options-decision-matrix.md`
  - `docs/teaching/shiny/road-test-operations-plan.md`
  - `docs/teaching/shiny/student-workspace-and-export-design.md`
- Read app context only:
  - `R/shiny_practical1.R`
  - `inst/shiny/practical1/README.md`
  - `inst/shiny/practical1/app.R`
  - `tests/testthat/test-13_practical1_shiny.R`

## 2026-06-05 - Goal 020 Packet Created

- Created:
  - `docs/goals/020-deep-server-image-preflight/Goal.md`
  - `docs/goals/020-deep-server-image-preflight/Plan.md`
  - `docs/goals/020-deep-server-image-preflight/Runbook.md`
  - `docs/goals/020-deep-server-image-preflight/Log.md`
- No app, package, scenario, dependency, or test files changed.
- No service, deployment, external-access, commit, or push boundary was crossed.

## 2026-06-05 - Disposable Deep Server Workspace

- Prepared immutable local values:
  - source commit:
    `38ef13fd4ada7dfd4b9523ba22bc154eb53e6ec0`
  - source short SHA: `38ef13f`
  - remote workspace:
    `/data/codex/teaching/rpva-2026/preflight/goal020-38ef13f`
  - image tag: `rpva-practical1:goal020-38ef13f`
- Created the disposable remote workspace on `deep-server-ts`.
- Transferred source with `git archive` from local `origin/main` to avoid
  remote GitHub/auth variability.
- In the disposable remote workspace only:
  - copied `deploy/shinyproxy/practical1/dockerignore.template` to
    `.dockerignore`;
  - wrote `SOURCE_COMMIT.txt` containing the full source commit.
- Remote evidence:
  - hostname: `deep-server`
  - architecture: `x86_64`
  - Docker CLI: `Docker version 29.5.2, build 79eb04c`
  - Docker info summary:
    `ServerVersion=29.5.2 Architecture=x86_64 NCPU=64 MemTotal=135068536832 DockerRootDir=/var/lib/docker`
  - `/data` filesystem:
    `/dev/sdb 13T 8.1T 4.5T 65% /data`

## 2026-06-05 - Remote Image Build Result

- Ran one bounded remote Docker image build in the disposable workspace:
  - Dockerfile:
    `deploy/shinyproxy/practical1/Dockerfile.template`
  - build arg:
    `RPVA_REF=38ef13fd4ada7dfd4b9523ba22bc154eb53e6ec0`
  - tag: `rpva-practical1:goal020-38ef13f`
  - build log:
    `/data/codex/teaching/rpva-2026/preflight/goal020-38ef13f/docker-build.log`
- Build result: failed.
- Useful passing evidence before failure:
  - `rocker/r-ver:4.6.0` resolved for `amd64`;
  - source build context was small, about `948 kB`;
  - Ubuntu package installation completed inside the image layer;
  - `renv` installed successfully;
  - most R package dependencies restored successfully.
- Root failure:
  - R package `fs` failed during configure because `libuv` headers/pkg-config
    metadata were unavailable;
  - error excerpt:
    `Package 'libuv', required by 'virtual:world', not found`;
  - error excerpt:
    `fatal error: uv.h: No such file or directory`;
  - `renv::restore()` then failed to install `fs`, and the failure cascaded to
    `sass`, `bslib`, `shiny`, `pkgload`, `rmarkdown`, and `testthat`.
- No image ID or size was available because the build failed before image
  creation.
- No container smoke was run because the image did not build.
- No container was created or left running.

## 2026-06-05 - Scaffold Defect Fixed

- Fixed the repo-local Dockerfile template by adding `libuv1-dev` to the
  Ubuntu build dependencies.
- Tightened `deploy/shinyproxy/practical1/validate-scaffold.sh` to require
  `libuv1-dev` in the Dockerfile template.
- Did not run a second remote Docker build in this turn because the Goal 020
  instruction allowed one bounded build attempt.
- No app, package, scenario, dependency, or test files changed.

## 2026-06-05 - Remote Cleanup State

- Retained disposable workspace for CoS review:
  `/data/codex/teaching/rpva-2026/preflight/goal020-38ef13f`
- Retained build log:
  `/data/codex/teaching/rpva-2026/preflight/goal020-38ef13f/docker-build.log`
- Build log length: `957` lines.
- Temporary image tag state:
  - `docker image ls rpva-practical1:goal020-38ef13f` returned no image rows.
  - No Goal 020 image was left in Docker because the build failed before image
    creation.
- Temporary container state:
  - `docker ps -a --filter name=rpva-goal020-38ef13f` returned no rows.
  - `docker ps --filter name=rpva-goal020-38ef13f` returned no rows.
  - No Goal 020 container was created or left running.

## 2026-06-05 - Local Validation

- Ran `git status --short --branch`:
  - `## codex/rpva-goal020-deep-server-image-preflight...origin/main`
  - modified:
    - `deploy/shinyproxy/practical1/Dockerfile.template`
    - `deploy/shinyproxy/practical1/validate-scaffold.sh`
  - new:
    - `docs/goals/020-deep-server-image-preflight/`
- Ran `git diff --check`:
  - passed with no output.
- Ran marker scan over changed/new Goal 020 text and modified scaffold files:
  - no hits.
- Ran trailing-whitespace scan over the new Goal 020 docs:
  - no hits.
- Ran shell syntax check:
  - `bash -n deploy/shinyproxy/practical1/validate-scaffold.sh`
  - passed.
- Ran scaffold validator:
  - `bash deploy/shinyproxy/practical1/validate-scaffold.sh`
  - output:
    `Practical 1 Shiny deployment scaffold static checks passed.`
- Ran explicit YAML parse:
  - `ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0)); puts "ruby yaml parse ok"' deploy/shinyproxy/practical1/application.example.yml`
  - output: `ruby yaml parse ok`
- Ran non-placeholder credential scan over changed/new text:
  - hits were limited to boundary/policy wording and the validator's own scan
    expression;
  - no real-looking secrets, tokens, keys, passwords, credentials, or student
    identifiers were found.
- No R tests were run because no executable R, Shiny app, package, scenario,
  dependency, or test files changed.
- Boundary confirmation:
  - no ShinyProxy installation or configuration;
  - no nginx, systemd, firewall, DNS, TLS, Docker daemon/service, account,
    credential, class workspace, or external-access changes;
  - no public/student-facing exposure;
  - no remote writes outside the disposable `/data/codex` Goal 020 workspace
    and Docker's normal build-layer state;
  - no host package installs outside Docker build layers;
  - no commit or push.

## 2026-06-06 - SRF-A Continuation Branch Check

- SRF-A directed a bounded Goal 020 continuation on the same branch after
  publishing the previous Goal 020 work as:
  - `6ed2445 Add deep-server image preflight`
- Objective: verify whether the committed `libuv1-dev` Dockerfile-template
  fix resolves the prior `fs`/`libuv` build failure on `deep-server` `x86_64`.
- First checkpoint before editing:
  - CWD: `/Users/bwbrook/.codex/worktrees/a4af/rPVA`
  - branch: `codex/rpva-goal020-deep-server-image-preflight`
  - HEAD:
    `6ed2445 (HEAD -> codex/rpva-goal020-deep-server-image-preflight, origin/codex/rpva-goal020-deep-server-image-preflight) Add deep-server image preflight`
  - status:
    `## codex/rpva-goal020-deep-server-image-preflight...origin/codex/rpva-goal020-deep-server-image-preflight`
- Confirmed the local branch was on the requested branch at
  `6ed24459b9a265f687d0855f6cd9bc9392e2f0ba`.

## 2026-06-06 - Continuation Remote Workspace

- Prepared immutable local values:
  - source commit:
    `6ed24459b9a265f687d0855f6cd9bc9392e2f0ba`
  - source short SHA: `6ed2445`
  - remote workspace:
    `/data/codex/teaching/rpva-2026/preflight/goal020-6ed2445`
  - image tag: `rpva-practical1:goal020-6ed2445`
  - smoke container name: `rpva-goal020-6ed2445`
- Confirmed the fresh remote workspace path was available.
- Created the disposable remote workspace on `deep-server-ts`.
- Transferred source with `git archive` from local branch `HEAD`.
- In the disposable remote workspace only:
  - copied `deploy/shinyproxy/practical1/dockerignore.template` to
    `.dockerignore`;
  - wrote `SOURCE_COMMIT.txt` containing the full source commit;
  - confirmed the Dockerfile template contains `libuv1-dev`.
- Remote evidence:
  - hostname: `deep-server`
  - architecture: `x86_64`
  - Docker CLI: `Docker version 29.5.2, build 79eb04c`
  - Docker info summary:
    `ServerVersion=29.5.2 Architecture=x86_64 NCPU=64 MemTotal=135068536832 DockerRootDir=/var/lib/docker`
  - `/data` filesystem:
    `/dev/sdb 13T 8.1T 4.5T 65% /data`

## 2026-06-06 - Continuation Image Rebuild Result

- Ran exactly one bounded remote Docker image build in the disposable
  workspace:
  - Dockerfile:
    `deploy/shinyproxy/practical1/Dockerfile.template`
  - build arg:
    `RPVA_REF=6ed24459b9a265f687d0855f6cd9bc9392e2f0ba`
  - tag: `rpva-practical1:goal020-6ed2445`
  - build log:
    `/data/codex/teaching/rpva-2026/preflight/goal020-6ed2445/docker-build-continuation.log`
- Build result: passed.
- The build log is `869` lines.
- Evidence that the previous defect was resolved:
  - `libuv1-dev` was installed in the Ubuntu package layer;
  - `fs 2.1.0` built from source successfully;
  - `sass`, `bslib`, `rmarkdown`, and `shiny` subsequently built
    successfully;
  - `renv::restore()` completed with `Successfully installed 88 packages in
    260 seconds`;
  - `R CMD INSTALL --no-multiarch --no-test-load .` completed with
    `* DONE (rPVA)`;
  - Docker exported image
    `sha256:346260b5dd1739b758e8b918aaeeddfa0a6040776fb30d576e42919e52895d76`
    and tagged it as `rpva-practical1:goal020-6ed2445`.
- Image state after build:
  - tag: `rpva-practical1:goal020-6ed2445`
  - image ID:
    `sha256:346260b5dd1739b758e8b918aaeeddfa0a6040776fb30d576e42919e52895d76`
  - Docker-reported size: `1786576408` bytes
  - `docker image ls` reported about `1.79GB` disk usage.

## 2026-06-06 - Continuation Local-Only Smoke

- Ran exactly one short local-only container smoke on `deep-server`.
- Container launch was bound to localhost only:
  - container name: `rpva-goal020-6ed2445`
  - image: `rpva-practical1:goal020-6ed2445`
  - port mapping: `127.0.0.1:3920:3838`
- Curl target was local to `deep-server`:
  - `http://127.0.0.1:3920/`
- Smoke result: passed.
- Captured smoke response:
  - `/tmp/rpva-goal020-smoke.html`
  - size: `9902` bytes
  - HTML marker: `<title>Practical 1 PVA</title>`
- Container logs showed:
  - `Loading required package: shiny`
  - Shiny warning about `SHINY_PORT` naming when not using Shiny Server;
  - `Listening on http://0.0.0.0:3838`
- Cleanup state:
  - the smoke container was stopped and removed;
  - `docker ps --filter name=rpva-goal020-6ed2445` returned no rows;
  - `docker ps -a --filter name=rpva-goal020-6ed2445` returned no rows.
- Image state:
  - the image `rpva-practical1:goal020-6ed2445` remains in Docker on
    `deep-server` for SRF-A review.
- No further scaffold dependency fix was needed in this continuation.
- No app, package, scenario, dependency, or test files changed.

## 2026-06-06 - Continuation Local Validation

- Ran `git status --short --branch`:
  - `## codex/rpva-goal020-deep-server-image-preflight...origin/codex/rpva-goal020-deep-server-image-preflight`
  - modified:
    - `docs/goals/020-deep-server-image-preflight/Log.md`
- Ran `git diff --check`:
  - passed with no output.
- Ran marker scan over the changed Goal 020 log text:
  - no hits.
- Ran shell syntax check:
  - `bash -n deploy/shinyproxy/practical1/validate-scaffold.sh`
  - passed.
- Ran scaffold validator:
  - `bash deploy/shinyproxy/practical1/validate-scaffold.sh`
  - output:
    `Practical 1 Shiny deployment scaffold static checks passed.`
- Ran explicit YAML parse:
  - `ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0)); puts "ruby yaml parse ok"' deploy/shinyproxy/practical1/application.example.yml`
  - output: `ruby yaml parse ok`
- Ran non-placeholder credential scan over changed/new text:
  - hits were limited to prior policy wording in the log;
  - no real-looking secrets, tokens, keys, passwords, credentials, or student
    identifiers were found.
- No R tests were run because no executable R, Shiny app, package, scenario,
  dependency, or test files changed.
- Boundary confirmation:
  - no ShinyProxy installation or configuration;
  - no nginx, systemd, firewall, DNS, TLS, Docker daemon/service, account,
    credential, class workspace, or external-access changes;
  - no public/student-facing/tailnet/campus exposure;
  - no remote writes outside the disposable `/data/codex` continuation
    workspace and Docker's normal build/container state;
  - no host package installs outside Docker build layers;
  - no commit or push.
