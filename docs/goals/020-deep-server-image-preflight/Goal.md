# Goal 020: Deep Server Image Preflight

## Objective

Run a bounded `deep-server` `x86_64` Docker image-build preflight for the
Practical 1 Shiny deployment scaffold.

The goal is to find real architecture, Dockerfile, R-package, and image-build
defects before any ShinyProxy, nginx, service, account, TLS, DNS, or
student-facing staging work.

## Context

Goal 017 created the Practical 1 Shiny deployment-readiness package. Goal 018
created the inert ShinyProxy/Docker/nginx scaffold. Goal 019 tightened the
scaffold locally and deliberately skipped a Mac mini image build because the
local Docker Desktop context is `aarch64`, while the intended class target is
`deep-server` on Linux `x86_64`.

CoS fast-forward-published `main` to `38ef13f`:

```text
38ef13f Add Practical 1 local deployment preflight
```

This Goal 020 run is still strictly pre-deployment. It may use a disposable
workspace under `/data/codex` on `deep-server` plus Docker's normal local image
and container state, but it must not configure or expose a live service.

## Required Sources

Read:

- `docs/goals/019-practical-1-local-deployment-preflight/Goal.md`
- `docs/goals/019-practical-1-local-deployment-preflight/Plan.md`
- `docs/goals/019-practical-1-local-deployment-preflight/Runbook.md`
- `docs/goals/019-practical-1-local-deployment-preflight/Log.md`
- `deploy/shinyproxy/practical1/README.md`
- `deploy/shinyproxy/practical1/Dockerfile.template`
- `deploy/shinyproxy/practical1/dockerignore.template`
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

- `docs/goals/020-deep-server-image-preflight/Goal.md`
- `docs/goals/020-deep-server-image-preflight/Plan.md`
- `docs/goals/020-deep-server-image-preflight/Runbook.md`
- `docs/goals/020-deep-server-image-preflight/Log.md`

Use the published Goal 019 scaffold under:

- `deploy/shinyproxy/practical1/`

Refine scaffold docs or templates only if the remote preflight reveals a clear
repo-local defect. Prefer no app, package, scenario, dependency, or test
changes.

## Remote Preflight Scope

Allowed remote writes are limited to a new disposable Goal 020 workspace under
`/data/codex` on `deep-server` or `deep-server-ts`, for example:

```text
/data/codex/teaching/rpva-2026/preflight/goal020-38ef13f
```

The reviewed rPVA source should be placed there at commit `38ef13f` or newer
using a reliable transfer method. In the disposable remote build workspace
only, copy:

```text
deploy/shinyproxy/practical1/dockerignore.template -> .dockerignore
```

Then run one bounded image build using:

```text
deploy/shinyproxy/practical1/Dockerfile.template
```

with:

```text
--build-arg RPVA_REF=<source-commit>
```

and a temporary local tag such as:

```text
rpva-practical1:goal020-<short-sha>
```

If the image builds, run at most one short container smoke on `deep-server`.
Bind it to `127.0.0.1` only, curl it from `deep-server` localhost only, then
stop and remove the container. No container may be left running.

Record whether the image was retained in Docker or removed.

## Evidence To Capture

Record:

- branch/worktree state;
- `origin/main` base commit;
- remote hostname and architecture;
- Docker version and `docker info` summary;
- disposable workspace path;
- source commit used;
- image-build command class and result;
- image tag, ID, and size if built;
- local-only smoke command class and result if run;
- container cleanup result;
- whether the temporary image remains;
- any scaffold defects fixed or blockers found.

## Boundaries

Do not:

- install or configure ShinyProxy;
- change nginx, systemd, firewall, DNS, TLS, Docker daemon/service, accounts,
  class workspaces, tokens, or external-access settings;
- expose a public, campus, tailnet, or student-facing service;
- write remotely outside the disposable `/data/codex` Goal 020 workspace and
  Docker's normal local image/container state;
- install host packages outside Docker build layers;
- store secrets, real passwords, student identifiers, or plausible credentials;
- edit app code, package code, scenario YAML, dependencies, or tests unless an
  unavoidable build mismatch is found and explained;
- commit or push.

## Teaching And Research Boundary

This preflight serves Practical 1 teaching delivery only. It must not bake in
future Lord Howe Island woodhen recovery paper assumptions, analysis choices,
scenario parameters, or research-grade workflow decisions.

## Validation

Required local checks:

```sh
git status --short --branch
git diff --check
rg -n "$(printf '%s|%s|%s' 'TO''DO' 'T''BD' 'PLACE''HOLDER')" \
  docs/goals/020-deep-server-image-preflight
bash -n deploy/shinyproxy/practical1/validate-scaffold.sh
bash deploy/shinyproxy/practical1/validate-scaffold.sh
ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0)); puts "ruby yaml parse ok"' \
  deploy/shinyproxy/practical1/application.example.yml
```

Run a non-placeholder secret scan over changed/new text and review all hits.
Literal template replacement values are acceptable only when clearly inert and
not plausible credentials.

No R tests are required for docs/templates-only work. If executable R/Shiny
code changes, run the focused relevant tests and explain why.

## Report Back

Report to CoS:

- branch/worktree state;
- files created/changed;
- remote command classes run and results;
- whether build and local-only smoke passed or failed;
- scaffold defects fixed or blockers found;
- cleanup state;
- recommended next action;
- explicit confirmation that no live service, deployment, external access,
  remote write outside the allowed workspace/Docker state, commit, or push
  boundary was crossed.
