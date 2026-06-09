# Goal 022: Local And Remote Staging Validation

## Objective

Create and execute a bounded local-plus-remote non-student staging validation
package for the Practical 1 Shiny app.

The goal is to prove, or sharply characterize blockers for, two testing
environments:

- local Mac mini Shiny for agent-side smoke and iteration;
- remote non-student Shiny through the existing `deep-server` gateway path for
  Barry human sanity checks.

SRF-A added CI health to this goal after GitHub reported failing `R CI` runs on
`main`. CI repair is therefore part of the staging gate and must be handled
before any remote escalation beyond read-only discovery.

## Context

Accepted prior evidence:

- Goal 020 proved the Practical 1 Docker image can build on `deep-server`
  `x86_64` and pass one localhost-only Shiny smoke after the `libuv1-dev`
  scaffold fix.
- Goal 021 created the pre-live staging gate and made approval, TLS, identity,
  workspace, route, monitoring, rollback, cleanup, and fallback gates explicit.
- SRF-A then authorized bounded validation of two testing environments:
  local Mac mini Shiny and remote non-student Shiny through the campus
  portal/gateway path.

New CI evidence:

- `R CI` failed on `main` runs `27050148750` and `27050337437`.
- Both failures occurred in the `Bootstrap` step:
  `Rscript -e 'source("bootstrap.R")'`.
- The local Goal 022 branch includes a focused workflow repair so CI uses
  `bootstrap.R` and `renv.lock` as the single dependency authority.

## Deliverables

Create:

- `docs/goals/022-local-remote-staging-validation/Goal.md`
- `docs/goals/022-local-remote-staging-validation/Plan.md`
- `docs/goals/022-local-remote-staging-validation/Runbook.md`
- `docs/goals/022-local-remote-staging-validation/Log.md`

Targeted teaching/deployment docs may be updated only to point at Goal 022 or
reconcile stale next-step wording.

## Track A: Local Mac Mini Shiny

Run one bounded local smoke:

- launch Practical 1 Shiny on `127.0.0.1` only;
- curl the local page;
- capture command, port, response marker, and cleanup state;
- stop the temporary R/Shiny process;
- confirm no listener remains on the selected port.

## Track B: Remote Non-Student Staging

Start with read-only discovery on `deep-server-ts`:

- host and architecture;
- Docker state and accepted image metadata;
- gateway health;
- ShinyProxy install/service/config state;
- nginx/app gateway status, syntax, selected config summary, and listeners;
- relevant `/data/codex` roots.

Remote staging may proceed only if the Goal 022 conditional service-change rule
is satisfied. If ShinyProxy is absent, service ownership is unclear, sudo or
syntax validation fails, or staging requires firewall, DNS, TLS, Docker daemon,
or major host-component changes, stop Track B after discovery and recommend a
separate Goal 023 service-bootstrap package.

## CI Gate

CI must not be ignored. The repair must preserve:

- `bootstrap.R`;
- `renv::status(sources = FALSE)`;
- the test suite;
- the Woodhen smoke test.

It must not skip tests, loosen the workflow without evidence, or make optional
plotting packages part of the default restore path.

## Boundaries

Do not:

- create student accounts, class accounts, class workspaces, or student-facing
  routes;
- store real passwords, tokens, student identifiers, private TLS material, or
  plausible credentials;
- change firewall, DNS, TLS certificate, Docker daemon/service, account,
  credential, or class workspace state;
- install ShinyProxy or major host components;
- change manuscript or research-analysis files;
- edit R/Shiny/package/scenario/test code unless a tiny unavoidable
  environment blocker is found and separately explained;
- commit or push.

## Teaching And Research Boundary

Goal 022 serves Practical 1 teaching delivery only. It must not encode future
Lord Howe Island woodhen recovery research assumptions, data choices, scenario
parameters, uncertainty treatment, sensitivity analysis, or manuscript logic.

## Validation

Required before reporting:

```sh
git status --short --branch
git diff --check
rg -n "$(printf '%s|%s|%s' 'TO''DO' 'T''BD' 'PLACE''HOLDER')" \
  .github/workflows/r-ci.yaml \
  docs/goals/022-local-remote-staging-validation \
  docs/teaching/shiny/README.md \
  docs/teaching/shiny/implementation-roadmap.md
bash -n deploy/shinyproxy/practical1/validate-scaffold.sh
bash deploy/shinyproxy/practical1/validate-scaffold.sh
ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0)); puts "ruby yaml parse ok"' \
  deploy/shinyproxy/practical1/application.example.yml
```

Run a secret-pattern scan over changed/new text and manually review all hits.
Run CI-equivalent local bootstrap verification for the workflow repair. No R
package test suite is required solely for docs/log/runtime staging, but Goal 022
does run the CI-equivalent test suite because the workflow changed.

## Report Back

Report to SRF-A:

- branch/worktree state;
- files created/changed;
- CI diagnosis, repair, and verification;
- local Shiny launch/smoke/cleanup evidence;
- remote discovery evidence;
- whether non-student staging proceeded or stopped, with exact reason;
- if staging proceeded, URL/path and rollback summary;
- validation commands and outcomes;
- recommended next action;
- explicit boundary confirmation.
