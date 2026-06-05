# Goal 019: Practical 1 Local Deployment Preflight

## Objective

Run a local, non-live preflight over the Practical 1 Shiny deployment scaffold.

This goal tightens the repo-local ShinyProxy/Docker/nginx templates as far as
possible without writing to `deep-server`, changing services, or exposing a
student-facing URL.

## Context

Goal 017 created the deployment-readiness decision package. Goal 018 created
the first inert deployment scaffold under `deploy/shinyproxy/practical1/`.
CoS fast-forward-published Goals 017 and 018 to `main` at `8c2c586`.

CoS has not authorized live staging or deployment. This Goal 019 package is a
local-only preflight step intended to find obvious scaffold defects before any
remote implementation work.

Current strategic boundaries remain:

- Practical 1 Shiny teaching delivery is the immediate objective.
- Future Lord Howe Island woodhen recovery research analysis remains separate.
- Scaffold templates must not encode paper-facing scenario or data assumptions.

## Required Sources

Read:

- `docs/goals/018-practical-1-shiny-deployment-scaffold/Goal.md`
- `docs/goals/018-practical-1-shiny-deployment-scaffold/Plan.md`
- `docs/goals/018-practical-1-shiny-deployment-scaffold/Runbook.md`
- `docs/goals/018-practical-1-shiny-deployment-scaffold/Log.md`
- `deploy/shinyproxy/practical1/README.md`
- `deploy/shinyproxy/practical1/Dockerfile.template`
- `deploy/shinyproxy/practical1/application.example.yml`
- `deploy/shinyproxy/practical1/nginx-practical1.example.conf`
- `deploy/shinyproxy/practical1/validate-scaffold.sh`
- `docs/teaching/shiny/README.md`
- `docs/teaching/shiny/implementation-roadmap.md`
- `docs/teaching/shiny/deep-server-hosting-feasibility.md`
- `docs/teaching/shiny/platform-options-decision-matrix.md`
- `docs/teaching/shiny/road-test-operations-plan.md`
- `docs/teaching/shiny/student-workspace-and-export-design.md`
- `R/shiny_practical1.R`
- `inst/shiny/practical1/README.md`
- `inst/shiny/practical1/app.R`
- `tests/testthat/test-13_practical1_shiny.R`

## Deliverables

Create:

- `docs/goals/019-practical-1-local-deployment-preflight/Goal.md`
- `docs/goals/019-practical-1-local-deployment-preflight/Plan.md`
- `docs/goals/019-practical-1-local-deployment-preflight/Runbook.md`
- `docs/goals/019-practical-1-local-deployment-preflight/Log.md`

Refine scaffold files only as needed under:

- `deploy/shinyproxy/practical1/`

Targeted Shiny planning docs may be updated only to point at Goal 019 or
reconcile stale next-goal text.

## Preflight Findings To Capture

Record:

- branch/worktree and `origin/main` base state;
- Docker availability from `docker info`;
- whether a local Docker build was attempted;
- if no build was attempted, why;
- static validator result;
- YAML parse result;
- non-placeholder secret scan result;
- remaining defects or risky assumptions.

## Accepted Scaffold Refinements

Allowed refinements include:

- clarify source-ref and image-tag expectations;
- add a `dockerignore.template`;
- clarify installed-package versus source-tree runtime;
- tighten ShinyProxy simple-auth/account placeholders;
- ensure workspace volume mapping cannot be mistaken for one shared writable
  class workspace;
- improve static validation;
- update local-only review/checklist wording.

Do not change R/Shiny/package code unless an unavoidable scaffold mismatch is
found and explained.

## Docker Build Decision

Docker availability may be inspected with:

```sh
docker info
```

A local image build is optional, not required. Attempt it only if it is clearly
local, cheap, and bounded. Skip it if it would pull a large base image, restore
large dependency sets, require Docker Desktop changes, or risk turning the
preflight into a long build job.

Do not run containers unless a single local, short-lived container is
explicitly necessary and safe. Prefer no container run in this goal.

## Boundaries

Do not:

- write to `deep-server`;
- run remote probes unless a later instruction explicitly requests them;
- install or configure ShinyProxy;
- edit nginx, systemd, firewall, DNS, TLS, Docker service, or external-access
  settings;
- build, run, or expose a public/student-facing service;
- install host packages;
- edit app code, package code, scenario YAML, dependencies, or tests unless
  unavoidable;
- commit or push.

## Validation

Required:

```sh
git diff --check
rg -n "$(printf '%s|%s|%s' 'TO''DO' 'T''BD' 'PLACE''HOLDER')" \
  docs/goals/019-practical-1-local-deployment-preflight \
  deploy/shinyproxy/practical1 \
  docs/teaching/shiny/README.md \
  docs/teaching/shiny/implementation-roadmap.md
bash -n deploy/shinyproxy/practical1/validate-scaffold.sh
bash deploy/shinyproxy/practical1/validate-scaffold.sh
ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0)); puts "ruby yaml parse ok"' \
  deploy/shinyproxy/practical1/application.example.yml
git status --short --branch
```

Run a non-placeholder secret scan over changed/new text. Intentional
angle-bracket placeholders are allowed; real-looking secrets are not.

No R tests are required for docs/templates-only work. If executable R/Shiny
code changes, run the focused relevant tests and explain why.

## Report Back

Report:

- branch/worktree state;
- files created/changed;
- validation and investigation run;
- whether Docker build was attempted, and why or why not;
- blockers or risky assumptions;
- recommended next action;
- explicit confirmation that no service, deploy, remote-write, commit, or push
  boundary was crossed.
