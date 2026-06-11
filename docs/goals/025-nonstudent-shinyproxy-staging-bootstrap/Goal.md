# Goal 025: Non-Student ShinyProxy Staging Bootstrap

## Objective

Bootstrap a non-student Practical 1 Shiny staging service on `deep-server`
behind the existing HTTPS gateway, using the accepted current rPVA source state
at `5c9d500`, and prove that the app can be reached and exercised through an
authenticated non-student browser path.

The completed state is either:

1. a running, authenticated, non-student staging service with documented
   rollback/cleanup and browser-smoke evidence; or
2. an exact blocker report with no unsafe partial exposure left behind.

This goal is explicitly a staging/bootstrap goal, not a student release.

## Why This Matters

Goals 023 and 024 made Practical 1 locally road-testable: the app now exports
compact evidence and has a fallback pack. The next risk is operational:
`deep-server` has an HTTPS gateway and Docker support, but prior discovery
stopped because ShinyProxy was absent. We now need one tightly bounded service
bootstrap to determine whether the app can actually run behind the gateway
before Barry spends time on campus-route testing or class account design.

## Operating Mode

Bounded deployment operations plus evidence logging.

Unlike Goals 021-024, this goal does authorize narrowly scoped remote service
work after live preflight checks pass.

## Review Surface

The rPVA orchestrator will review:

- Goal 025 `Log.md`;
- a concise staging report under this goal directory;
- any targeted updates to Shiny/deployment docs;
- remote command/evidence summaries with secrets redacted;
- local and remote validation outcomes;
- browser smoke evidence;
- final local and remote service state;
- final git status and changed-file list.

## Scope

In scope:

- live preflight probes of `deep-server` through `deep-server-ts`;
- use of existing nginx HTTPS gateway on `443`;
- Docker image build or rebuild for current commit `5c9d500`;
- remote source staging under `/data/codex/repos` or equivalent approved
  `/data/codex` workspace;
- creation of a staging workspace under
  `/data/codex/teaching/rpva-2026/staging`;
- ShinyProxy installation if still absent;
- ShinyProxy configuration for a single non-student staging app;
- systemd service creation/update for ShinyProxy if needed;
- creation of exactly one non-student staging identity for agent/browser smoke
  testing, with secret values kept out of git, logs, and chat;
- localhost, tailnet, and best-effort campus-IP route checks;
- authenticated browser smoke using the non-student staging identity;
- rollback and cleanup documentation.

Out of scope:

- student-facing release;
- class accounts, class tokens, class workspaces, or student identifiers;
- public announcement or distribution of any URL or credential;
- DNS changes;
- firewall changes;
- TLS certificate replacement or trust-chain work;
- nginx changes unless the existing gateway cannot reach a localhost-only
  ShinyProxy service and a small reversible route alignment is clearly required;
- Docker daemon/service changes;
- broad host maintenance, apt upgrade, reboot, or unrelated package installs;
- Practical 2 Shiny app mode;
- assessment redesign;
- scenario/YAML changes or research-grade Lord Howe woodhen analysis;
- new R package dependencies;
- committing, pushing, opening a PR, or merging.

## Read First

- `README.md`
- `docs/codex/thread-handoff-2026-06-04.md`
- `docs/goals/020-deep-server-image-preflight/Goal.md`
- `docs/goals/020-deep-server-image-preflight/Log.md`
- `docs/goals/021-staging-gate-runbook/Goal.md`
- `docs/goals/021-staging-gate-runbook/Runbook.md`
- `docs/goals/021-staging-gate-runbook/Log.md`
- `docs/goals/022-local-remote-staging-validation/Goal.md`
- `docs/goals/022-local-remote-staging-validation/Log.md`
- `docs/goals/023-practical-1-evidence-export-road-test-hardening/Goal.md`
- `docs/goals/023-practical-1-evidence-export-road-test-hardening/Log.md`
- `docs/goals/024-practical-1-classroom-dry-run-fallback/Goal.md`
- `docs/goals/024-practical-1-classroom-dry-run-fallback/dry-run-report.md`
- `docs/teaching/shiny/README.md`
- `docs/teaching/shiny/deep-server-hosting-feasibility.md`
- `docs/teaching/shiny/implementation-roadmap.md`
- `docs/teaching/shiny/platform-options-decision-matrix.md`
- `docs/teaching/shiny/road-test-operations-plan.md`
- `docs/teaching/shiny/student-workspace-and-export-design.md`
- `deploy/shinyproxy/practical1/README.md`
- `deploy/shinyproxy/practical1/Dockerfile.template`
- `deploy/shinyproxy/practical1/dockerignore.template`
- `deploy/shinyproxy/practical1/application.example.yml`
- `deploy/shinyproxy/practical1/nginx-practical1.example.conf`
- `deploy/shinyproxy/practical1/staging-gate-checklist.md`
- `deploy/shinyproxy/practical1/validate-scaffold.sh`

There is no repo-local `AGENTS.md` in this checkout. Use the repo-local files
above plus Barry's global Mac mini instructions.

If live ShinyProxy installation details are not sufficiently determined by the
repo-local scaffold and the host itself, use only primary official ShinyProxy
or Open Analytics documentation, and cite the exact source in `Log.md`.

## Starting State Checks

Before editing, report in `Log.md` and final response:

```sh
pwd
git branch --show-current
git rev-parse --short HEAD
git status --short --branch
```

Expected branch at handoff:

```text
codex/rpva-goal025-nonstudent-staging
```

Expected starting base:

```text
5c9d500 Add Practical 1 classroom dry-run fallback pack
```

Treat any unexpected dirty state as project state. Do not clean, restore, or
overwrite it unless it is clearly your own failed intermediate output.

## Git And Publication Policy

- Work on `codex/rpva-goal025-nonstudent-staging`.
- Do not commit.
- Do not push.
- Do not open a PR.
- Keep a precise changed-file list in `Log.md` and final response.

The orchestrator will review the uncommitted result before deciding whether a
separate closeout commit/publish goal is needed.

## Remote State And Secret Policy

Permitted remote writes, after preflight:

- `/data/codex/repos/<goal-specific-rpva-source-or-build-dir>`;
- `/data/codex/teaching/rpva-2026/staging/`;
- `/opt/shinyproxy` or another standard ShinyProxy install root;
- `/etc/shinyproxy/application.yml` or equivalent ShinyProxy config path;
- `/etc/systemd/system/shinyproxy.service` or equivalent service unit;
- `/var/log/shinyproxy` if needed.

Do not write real secrets, student identifiers, or private TLS material into the
git repo or goal logs.

For the single non-student staging credential:

- generate it on the host or in-process;
- use a high-entropy value;
- do not print the secret value in terminal output, logs, final response, or
  chat;
- store it only in an appropriately permissioned non-git location needed for
  service operation or smoke testing;
- report the storage path and permissions, not the value;
- remove or rotate it during rollback/cleanup if the service is not left
  running.

## Required Work

1. Prove current state before changing it.
   - Verify Mac mini action repo branch/status.
   - Verify `origin/main` and local branch are at `5c9d500`.
   - Probe `deep-server-ts` once for hostname, architecture, time, sudo,
     Docker, Java, nginx, current listeners, current ShinyProxy state, gateway
     health, and relevant `/data/codex` roots.
   - If ShinyProxy is already installed, inspect and record the current state
     before changing it.

2. Prepare current source/image.
   - Ensure the staged service uses source commit `5c9d500`.
   - If direct remote GitHub access works, use it.
   - If remote GitHub access fails, use a trusted local archive, bundle, or
     `rsync` from the Mac mini checkout to a goal-specific `/data/codex/repos`
     path.
   - Build or rebuild an image tagged clearly, for example
     `rpva-practical1:goal025-5c9d500`.
   - Run a localhost-only image/container smoke before wiring ShinyProxy if
     practical.

3. Bootstrap ShinyProxy.
   - Install ShinyProxy only if absent or unusable.
   - Keep it bound to localhost, preferably matching the existing gateway
     upstream `127.0.0.1:3838` unless a small reversible alignment is needed.
   - Configure one app id for Practical 1.
   - Configure one non-student staging identity for smoke testing.
   - Do not create student/class identities.
   - Do not commit or log secret values.

4. Route through the existing gateway.
   - Prefer the existing nginx gateway on `443`.
   - Preserve `/_gateway-health`.
   - Avoid nginx edits if ShinyProxy can match the existing upstream.
   - If a tiny nginx route alignment is required, back up the prior config,
     validate syntax with `sudo -n nginx -t`, reload only if valid, and record
     exact rollback.
   - Do not change firewall, DNS, or TLS certificates.

5. Prove non-student staging.
   - Check localhost service route.
   - Check tailnet route.
   - Attempt campus IP route from the Mac mini once and record the outcome; do
     not loop if this route times out.
   - Use Chrome plugin if available for authenticated browser smoke against the
     tailnet or local gateway route.
   - If Chrome is unavailable, record the exact blocker and use in-app Browser
     or Playwright/Chromium.
   - Exercise Start -> Concept Lab -> Compare/export -> Transfer.
   - Confirm comparison CSV and evidence-notes downloads still work.
   - Save browser evidence under `/tmp` and record paths.

6. Decide final remote posture.
   - If the authenticated browser smoke passes, leave the non-student staging
     service running and authenticated, with rollback and cleanup instructions
     recorded.
   - If the app cannot pass smoke after bounded fixes, stop/disable the service
     or roll back partial exposure, and report exact blockers.
   - In either case, do not release to students.

7. Update repo-local records.
   - Update Goal 025 `Log.md`.
   - Create a staging report, for example `staging-report.md`.
   - Update Shiny/deployment docs narrowly if the live state changed.
   - Do not store credentials or sensitive remote config.

## Validation Gates

The goal is not complete until these pass, or a blocker is logged with exact
evidence:

```sh
git status --short --branch
git diff --check
bash -n deploy/shinyproxy/practical1/validate-scaffold.sh
bash deploy/shinyproxy/practical1/validate-scaffold.sh
ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0)); puts "ruby yaml parse ok"' deploy/shinyproxy/practical1/application.example.yml
Rscript -e 'renv::status(sources = FALSE)'
```

Run focused R/Shiny tests if package, app, or deploy-template behaviour changes:

```sh
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
```

Also run:

- remote service-state checks relevant to the final posture;
- authenticated browser smoke, or exact blocker;
- marker scan over changed/new tracked text for unresolved implementation
  markers;
- secret-pattern scan over changed/new tracked text and manual review of all
  hits;
- explicit confirmation that no credential value appears in changed files or
  logs.

## Deliverables

- updated `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/Log.md`;
- staging report under the same goal directory;
- targeted deployment/Shiny doc updates if warranted;
- browser and route evidence paths;
- remote service final-state summary;
- rollback and cleanup instructions;
- final report to the rPVA orchestrator with validation evidence, changed
  files, residual risks, and recommended next action.

## Decision Authority

You may decide:

- exact ShinyProxy version/install route, after checking current official docs
  or existing host state;
- exact remote staging source path under `/data/codex/repos`;
- exact image tag, if it includes `goal025` and `5c9d500`;
- whether to reuse the existing nginx root upstream or make a tiny reversible
  route alignment;
- whether to leave a passing non-student staging service running;
- whether to roll back if smoke fails.

Pause before:

- firewall changes;
- DNS changes;
- TLS certificate replacement or trust-chain work;
- student/class identity creation;
- class workspace creation;
- public or student-facing release;
- adding dependencies;
- changing scientific defaults, scenarios, YAML files, stochastic engine
  behaviour, Practical 2 mode, or assessment design;
- storing or printing any real secret;
- committing, pushing, opening a PR, or merging.

## Checkpoint Rules

Checkpoint to the rPVA orchestrator if:

- live preflight contradicts the assumed gateway/Docker/ShinyProxy state in a
  way that changes the deployment shape;
- ShinyProxy installation requires a broad OS package install, Java change, or
  host maintenance;
- nginx route alignment is more than a small reversible localhost proxy change;
- authentication cannot be configured without exposing a secret in logs/chat;
- the browser smoke cannot exercise the app through any local browser path;
- any campus/student-like route result raises a policy or exposure question;
- validation fails for reasons outside this goal's scope.
