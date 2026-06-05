# Log

## 2026-06-05 - CoS Goal Publication And Branch Setup

- CoS directed `woodhen` to create the next bounded implementation package
  under the current `BB -> CoS -> Action Agent` model.
- Objective: create a non-live Practical 1 Shiny deployment scaffold for
  `deep-server`, with templates/runbooks that can be reviewed before any real
  deployment.
- First checkpoint before editing:
  - CWD: `/Users/bwbrook/.codex/worktrees/a4af/rPVA`
  - branch: `codex/rpva-goal017-deployment-readiness`
  - linked worktree Git dir:
    `/Users/bwbrook/git/rPVA/.git/worktrees/rPVA`
  - common Git dir: `/Users/bwbrook/git/rPVA/.git`
  - HEAD:
    `a3fccda (HEAD -> codex/rpva-goal017-deployment-readiness, origin/codex/rpva-goal017-deployment-readiness) Record campus route check for Shiny readiness`
  - status:
    `## codex/rpva-goal017-deployment-readiness...origin/codex/rpva-goal017-deployment-readiness`
- Ran `git fetch --prune origin`.
- Confirmed local and remote Goal 017 both resolve to:
  `a3fccda6a55c157558771f0546e68ff4cd8088cb`.
- Confirmed no local or remote branch named
  `codex/rpva-goal018-deployment-scaffold` was present, and no worktree had it
  checked out.
- Created and switched to branch:
  `codex/rpva-goal018-deployment-scaffold`.
- Confirmed branch state after switching:
  - CWD: `/Users/bwbrook/.codex/worktrees/a4af/rPVA`
  - branch: `codex/rpva-goal018-deployment-scaffold`
  - HEAD:
    `a3fccda (HEAD -> codex/rpva-goal018-deployment-scaffold, origin/codex/rpva-goal017-deployment-readiness, codex/rpva-goal017-deployment-readiness) Record campus route check for Shiny readiness`
  - status: `## codex/rpva-goal018-deployment-scaffold`

## 2026-06-05 - Context Review

- Read required Goal 017 files:
  - `docs/goals/017-practical-1-shiny-deployment-readiness/Goal.md`
  - `docs/goals/017-practical-1-shiny-deployment-readiness/Plan.md`
  - `docs/goals/017-practical-1-shiny-deployment-readiness/Runbook.md`
  - `docs/goals/017-practical-1-shiny-deployment-readiness/Log.md`
- Read Shiny planning docs:
  - `docs/teaching/shiny/README.md`
  - `docs/teaching/shiny/implementation-roadmap.md`
  - `docs/teaching/shiny/deep-server-hosting-feasibility.md`
  - `docs/teaching/shiny/platform-options-decision-matrix.md`
  - `docs/teaching/shiny/road-test-operations-plan.md`
  - `docs/teaching/shiny/student-workspace-and-export-design.md`
- Read app surfaces for context only:
  - `R/shiny_practical1.R`
  - `inst/shiny/practical1/README.md`
  - `inst/shiny/practical1/app.R`
  - `tests/testthat/test-13_practical1_shiny.R`
- Confirmed no existing Dockerfile/ShinyProxy scaffold in the rPVA worktree.
  The only existing deployment-like file found by the search was
  `docs/teaching/shiny/deployment-and-setup-options.md`.

## 2026-06-05 - Scaffold And Packet Creation

- Created Goal 018 packet:
  - `docs/goals/018-practical-1-shiny-deployment-scaffold/Goal.md`
  - `docs/goals/018-practical-1-shiny-deployment-scaffold/Plan.md`
  - `docs/goals/018-practical-1-shiny-deployment-scaffold/Runbook.md`
  - `docs/goals/018-practical-1-shiny-deployment-scaffold/Log.md`
- Created inert deployment scaffold:
  - `deploy/shinyproxy/practical1/README.md`
  - `deploy/shinyproxy/practical1/Dockerfile.template`
  - `deploy/shinyproxy/practical1/application.example.yml`
  - `deploy/shinyproxy/practical1/nginx-practical1.example.conf`
  - `deploy/shinyproxy/practical1/validate-scaffold.sh`
- Scaffold intent:
  - reviewable templates/examples only;
  - no live ShinyProxy configuration;
  - no Docker build, pull, run, or image creation;
  - no nginx, systemd, firewall, DNS, TLS, Docker service, account, token,
    student workspace, or external-access changes;
  - no remote writes to `deep-server`;
  - no app, package, scenario, dependency, or test edits.
- The scaffold uses angle-bracket placeholders for required future values such
  as `<RPVA_IMAGE>`, `<VERSION_TAG>`, `<GENERATED_USER_001>`, and
  `<STUDENT_ID>`. These are intentional, inert, and not plausible credentials.

## 2026-06-05 - Planning Doc Updates

- Updated targeted planning docs:
  - `docs/teaching/shiny/README.md`
  - `docs/teaching/shiny/implementation-roadmap.md`
- The README now points to Goal 018 and the inert scaffold directory.
- The roadmap now identifies Goal 018 as the non-live scaffold review step
  before any remote ShinyProxy/deep-server implementation.

## 2026-06-05 - Validation

- First static validation pass exposed a self-match in
  `validate-scaffold.sh`: the scaffold marker scan matched the validator's
  own literal regex. Fixed the validator and the Goal 018 validation examples
  so the scan still checks scaffold content without tripping over its own
  source text.
- Ran `git diff --check`:
  - passed with no output.
- Ran marker scan:
  - scanned the Goal 018 packet, scaffold directory, and targeted planning
    docs for unresolved marker words;
  - no hits.
- Ran shell syntax check:
  - `bash -n deploy/shinyproxy/practical1/validate-scaffold.sh`
  - passed.
- Ran scaffold validator:
  - `bash deploy/shinyproxy/practical1/validate-scaffold.sh`
  - output: `Practical 1 Shiny deployment scaffold static checks passed.`
- Ran explicit YAML parse check:
  - `ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0)); puts "ruby yaml parse ok"' deploy/shinyproxy/practical1/application.example.yml`
  - output: `ruby yaml parse ok`
- Ran `git status --short --branch`:
  - `## codex/rpva-goal018-deployment-scaffold`
  - ` M docs/teaching/shiny/README.md`
  - ` M docs/teaching/shiny/implementation-roadmap.md`
  - `?? deploy/`
  - `?? docs/goals/018-practical-1-shiny-deployment-scaffold/`
- Docs/templates-only validation decision:
  - no R tests were run because no executable R, Shiny app, package, scenario,
    dependency, or test files changed.
- Boundary confirmation:
  - no Docker build, pull, or run;
  - no package installs;
  - no app or package code edits;
  - no remote writes;
  - no ShinyProxy, nginx, systemd, firewall, DNS, TLS, Docker service, account,
    token, workspace, directory, container, or external-access changes;
  - no student-facing exposure;
  - no commit or push.
