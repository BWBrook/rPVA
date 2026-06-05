# Log

## 2026-06-05 - CoS Goal Publication And Branch Setup

- CoS directed `woodhen` to create Goal 019 under the current
  `BB -> CoS -> Action Agent` model.
- Objective: create a local/non-live deployment-preflight package for
  Practical 1 Shiny and tighten the repo-local scaffold before any remote
  service work.
- First checkpoint before editing:
  - CWD: `/Users/bwbrook/.codex/worktrees/a4af/rPVA`
  - branch: `codex/rpva-goal018-deployment-scaffold`
  - linked worktree Git dir:
    `/Users/bwbrook/git/rPVA/.git/worktrees/rPVA`
  - common Git dir: `/Users/bwbrook/git/rPVA/.git`
  - HEAD:
    `8c2c586 (HEAD -> codex/rpva-goal018-deployment-scaffold, origin/main, origin/codex/rpva-goal018-deployment-scaffold, origin/HEAD, main) Add Practical 1 Shiny deployment scaffold`
  - status:
    `## codex/rpva-goal018-deployment-scaffold...origin/codex/rpva-goal018-deployment-scaffold`
- Ran `git fetch --prune origin`.
- Confirmed `origin/main` resolves to
  `8c2c586704d9db102837cd0584b24e1b09f09077`.
- Confirmed no local or remote branch named
  `codex/rpva-goal019-local-deployment-preflight` was present.
- Created and switched to branch:
  `codex/rpva-goal019-local-deployment-preflight` from `origin/main`.
- Confirmed branch state after switching:
  - CWD: `/Users/bwbrook/.codex/worktrees/a4af/rPVA`
  - branch: `codex/rpva-goal019-local-deployment-preflight`
  - HEAD:
    `8c2c586 (HEAD -> codex/rpva-goal019-local-deployment-preflight, origin/main, origin/codex/rpva-goal018-deployment-scaffold, origin/HEAD, main, codex/rpva-goal018-deployment-scaffold) Add Practical 1 Shiny deployment scaffold`
  - status:
    `## codex/rpva-goal019-local-deployment-preflight...origin/main`

## 2026-06-05 - Context Review And Docker Availability

- Read required Goal 018 files:
  - `docs/goals/018-practical-1-shiny-deployment-scaffold/Goal.md`
  - `docs/goals/018-practical-1-shiny-deployment-scaffold/Plan.md`
  - `docs/goals/018-practical-1-shiny-deployment-scaffold/Runbook.md`
  - `docs/goals/018-practical-1-shiny-deployment-scaffold/Log.md`
- Read existing scaffold files:
  - `deploy/shinyproxy/practical1/README.md`
  - `deploy/shinyproxy/practical1/Dockerfile.template`
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
- Ran `docker info`.
- Docker is available locally through Docker Desktop:
  - client/server version: `29.5.2`
  - context: `desktop-linux`
  - server architecture: `aarch64`
  - CPUs: `10`
  - memory: `7.75GiB`
  - containers: `3` stopped, `0` running
- Docker build decision:
  - no image build was attempted.
  - reason: the scaffold build would likely pull `rocker/r-ver:4.6.0`, restore
    R packages from `renv.lock`, and build a full R package image. That is
    local but not clearly cheap/bounded for this docs/template preflight, and
    the target deployment host is Linux `x86_64` while this Docker Desktop
    context is `aarch64`.

## 2026-06-05 - Scaffold Refinements

- Refined `deploy/shinyproxy/practical1/Dockerfile.template`:
  - added image revision label from `RPVA_REF`;
  - added `R_LIBS=/opt/rpva/renv-library`;
  - changed runtime model to install the package with `R CMD INSTALL` and run
    `rPVA::run_practical1_shiny(...)` from the installed package;
  - removed `source("bootstrap.R")` from the container command;
  - added installed-app verification using `system.file("shiny", "practical1",
    package = "rPVA")`;
  - set workspace root default to `/srv/rpva-workspaces/current`.
- Added `deploy/shinyproxy/practical1/dockerignore.template`:
  - excludes VCS metadata, local R state, `renv` generated libraries/staging,
    generated teaching artefacts, goal evidence, and common caches from a
    future image-build context.
- Refined `deploy/shinyproxy/practical1/application.example.yml`:
  - added `RPVA_STUDENT_ID: "#{proxy.userId}"`;
  - maps each authenticated user to
    `/data/codex/teaching/rpva-2026/workspaces/#{proxy.userId}`;
  - mounts that per-user directory at `/srv/rpva-workspaces/current`;
  - added an explicit warning not to replace it with one shared class-wide
    writable directory.
- Refined `deploy/shinyproxy/practical1/nginx-practical1.example.conf`:
  - added a review note for defining `$connection_upgrade` in nginx `http`
    context if the live gateway config does not already provide it.
- Refined `deploy/shinyproxy/practical1/validate-scaffold.sh`:
  - requires `dockerignore.template`;
  - checks for installed-package Dockerfile runtime markers;
  - checks for ShinyProxy per-user workspace mapping;
  - keeps shell and YAML parse checks.
- Updated targeted planning docs:
  - `docs/teaching/shiny/README.md`
  - `docs/teaching/shiny/implementation-roadmap.md`
- Created this Goal 019 packet:
  - `Goal.md`
  - `Plan.md`
  - `Runbook.md`
  - `Log.md`

## 2026-06-05 - Validation

- Ran `git diff --check`:
  - passed with no output.
- Ran marker scan over the Goal 019 packet, scaffold directory, and targeted
  planning docs:
  - no hits.
- Ran shell syntax check:
  - `bash -n deploy/shinyproxy/practical1/validate-scaffold.sh`
  - passed.
- Ran scaffold validator:
  - `bash deploy/shinyproxy/practical1/validate-scaffold.sh`
  - output: `Practical 1 Shiny deployment scaffold static checks passed.`
- Ran explicit YAML parse:
  - `ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0)); puts "ruby yaml parse ok"' deploy/shinyproxy/practical1/application.example.yml`
  - output: `ruby yaml parse ok`
- Ran non-placeholder credential scan over changed/new text:
  - hits were limited to policy text, validation-script checks, and
    angle-bracket password placeholders in `application.example.yml`;
  - no real-looking secrets, tokens, keys, or student identifiers were found.
- Ran `git status --short --branch`:
  - `## codex/rpva-goal019-local-deployment-preflight...origin/main`
  - modified scaffold files:
    - `deploy/shinyproxy/practical1/Dockerfile.template`
    - `deploy/shinyproxy/practical1/README.md`
    - `deploy/shinyproxy/practical1/application.example.yml`
    - `deploy/shinyproxy/practical1/nginx-practical1.example.conf`
    - `deploy/shinyproxy/practical1/validate-scaffold.sh`
  - modified planning docs:
    - `docs/teaching/shiny/README.md`
    - `docs/teaching/shiny/implementation-roadmap.md`
  - new files:
    - `deploy/shinyproxy/practical1/dockerignore.template`
    - `docs/goals/019-practical-1-local-deployment-preflight/`
- No R tests were run because no executable R, Shiny app, package, scenario,
  dependency, or test files changed.
- No Docker build was attempted because the build would likely pull the R base
  image and restore R packages, which is not clearly cheap/bounded for this
  local docs/template preflight; local Docker Desktop is also `aarch64`, while
  the target deployment host is Linux `x86_64`.
- Boundary confirmation:
  - no Docker build, pull, or run;
  - no package installs;
  - no app, package, scenario, dependency, or test edits;
  - no remote probes or remote writes;
  - no ShinyProxy, nginx, systemd, firewall, DNS, TLS, Docker service, account,
    token, workspace, directory, container, or external-access changes;
  - no public/student-facing exposure;
  - no commit or push.
