# Goal 018: Practical 1 Shiny Deployment Scaffold

## Objective

Create an inert, repo-local deployment scaffold for reviewing a Practical 1
Shiny deployment on `deep-server`.

This goal moves one step beyond Goal 017 readiness planning by drafting
templates and runbooks that CoS/BB can inspect before any live service work.
It does not deploy, install, build, expose, or change any remote service.

## Context

Goal 017 established the current deployment direction:

- ShinyProxy backed by Docker is the preferred self-managed platform path.
- `deep-server` remains the target host.
- The existing nginx HTTPS gateway on `443` is the intended front door.
- The campus/public gateway health path works from Barry's Windows/WSL campus
  route, but the browser still shows a red HTTPS warning.
- TLS trust / student-friendly URL polish remains a release gate.
- Generated class accounts or per-student tokens are the preferred first
  road-test identity model.
- Student workspaces should live under `/data/codex/teaching/rpva-2026/` with
  compact exports and explicit cleanup.

This scaffold is for Practical 1 teaching delivery only. It must not encode
future Lord Howe Island woodhen recovery research assumptions.

## Deliverables

Create:

- `docs/goals/018-practical-1-shiny-deployment-scaffold/Goal.md`
- `docs/goals/018-practical-1-shiny-deployment-scaffold/Plan.md`
- `docs/goals/018-practical-1-shiny-deployment-scaffold/Runbook.md`
- `docs/goals/018-practical-1-shiny-deployment-scaffold/Log.md`
- `deploy/shinyproxy/practical1/README.md`
- `deploy/shinyproxy/practical1/Dockerfile.template`
- `deploy/shinyproxy/practical1/application.example.yml`
- `deploy/shinyproxy/practical1/nginx-practical1.example.conf`
- `deploy/shinyproxy/practical1/validate-scaffold.sh`

Targeted Shiny planning docs may be updated only to point at Goal 018 or to
reconcile stale next-goal text.

## Scaffold Requirements

The scaffold must be inert:

- templates/examples only;
- no real domains, credentials, tokens, student identifiers, TLS paths, or
  secrets;
- no commands that write to `deep-server`;
- no service operations;
- no live Docker build, pull, or run;
- no public or student-facing exposure.

Use angle-bracket placeholders such as `<COURSE_DOMAIN>` or
`<GENERATED_USER_001>` for values that must be supplied later.

## Review Expectations

The scaffold should let CoS/BB review:

- whether the Docker image template is sensible for the current app;
- whether the ShinyProxy example matches the Goal 017 account, workspace, and
  resource-limit model;
- whether the nginx example clarifies upstream alignment choices;
- what static checks can be run locally before any live implementation;
- which values must be resolved in the later implementation goal.

## Boundaries

Do not:

- install ShinyProxy;
- configure or restart ShinyProxy;
- edit nginx, systemd, firewall, DNS, TLS, Docker service, or
  external-access settings;
- run remote writes;
- create users, workspaces, directories, containers, volumes, tokens, or
  credentials;
- build or pull Docker images;
- edit app code, package code, scenario YAML, dependencies, or tests;
- run broad tests for docs/templates-only work;
- commit or push.

## Validation

Required before reporting:

```sh
git diff --check
rg -n "$(printf '%s|%s|%s' 'TO''DO' 'T''BD' 'PLACE''HOLDER')" \
  docs/goals/018-practical-1-shiny-deployment-scaffold \
  deploy/shinyproxy/practical1 \
  docs/teaching/shiny/README.md \
  docs/teaching/shiny/implementation-roadmap.md
bash -n deploy/shinyproxy/practical1/validate-scaffold.sh
bash deploy/shinyproxy/practical1/validate-scaffold.sh
git status --short --branch
```

Run a lightweight YAML parse check for `application.example.yml` if a suitable
local parser is available. The scaffold validator attempts Ruby YAML first and
Python YAML second.

No R tests are required for docs/templates-only work. If executable R/Shiny
code changes despite this boundary, run the focused relevant tests and explain
why the code edit was necessary.

## Report Back

Report:

- branch/worktree state;
- files created or changed;
- validation run and result;
- blockers or risky assumptions;
- recommended next action;
- explicit confirmation that no service, deploy, remote-write, commit, or push
  boundary was crossed.
