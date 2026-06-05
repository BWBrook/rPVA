# Goal 017: Practical 1 Shiny Deployment Readiness

## Objective

Create a decision-ready, pre-deployment package for hosting the Practical 1
Shiny concept lab on `deep-server`.

This goal does not deploy the app. It must turn the current local MVP and
platform-planning evidence into a clear go/no-go plan for the next service
implementation goal: platform choice, gateway/upstream alignment, account or
token model, workspace/quota policy, Docker/ShinyProxy build path, load-test
ladder, monitoring checklist, fallback materials, rollback/cleanup plan, and
explicit gates that must pass before students receive a URL.

## Context

`rPVA` is Barry's highest current priority because the Practical 1 teaching
use is expected in late July, and it is now early June. The immediate lane is
student access to the Practical 1 Shiny app on `deep-server`, with enough test
runway before class.

The project also has a future research lane around Lord Howe Island woodhen
recovery after rodent control. This goal must preserve that path by keeping
teaching simplifications separate from research-grade model, data, and
scenario-analysis needs.

Recent state:

- Goal 013 published the Practical 1 teaching API.
- Goal 015 added the base Shiny MVP under `inst/shiny/practical1/`.
- Goal 016 completed student-style browser QA for the local MVP.
- Goal 012 found `deep-server` technically plausible for a four-week teaching
  service and recommended ShinyProxy backed by Docker.
- Follow-up infrastructure work added an nginx HTTPS gateway on `443`.
- A Goal 017 read-only refresh from the Mac mini confirmed the tailnet gateway
  health endpoint still responds, but the campus-IP health check from this Mac
  mini route timed out.
- A 2026-06-05 Windows/WSL campus-network follow-up confirmed the campus/public
  gateway route returns the expected health text. The browser still shows a red
  HTTPS "Not secure" warning, so TLS trust / student-friendly URL polish
  remains a go/no-go gate.

## Required Sources

Read:

- `docs/codex/thread-handoff-2026-06-04.md`
- `docs/teaching/shiny/README.md`
- `docs/teaching/shiny/deep-server-hosting-feasibility.md`
- `docs/teaching/shiny/platform-options-decision-matrix.md`
- `docs/teaching/shiny/implementation-roadmap.md`
- `docs/teaching/shiny/road-test-operations-plan.md`
- `docs/teaching/shiny/student-workspace-and-export-design.md`
- `docs/goals/012-deep-server-shiny-platform-feasibility/Goal.md`
- `docs/goals/012-deep-server-shiny-platform-feasibility/Plan.md`
- `docs/goals/012-deep-server-shiny-platform-feasibility/Runbook.md`
- `docs/goals/012-deep-server-shiny-platform-feasibility/Log.md`
- `docs/goals/015-practical-1-shiny-mvp-scaffold/Goal.md`
- `docs/goals/015-practical-1-shiny-mvp-scaffold/Log.md`
- `docs/goals/016-practical-1-shiny-interaction-qa/Goal.md`
- `docs/goals/016-practical-1-shiny-interaction-qa/Log.md`
- `docs/goals/016-practical-1-shiny-interaction-qa/qa-report.md`
- `R/shiny_practical1.R`
- `inst/shiny/practical1/README.md`
- `inst/shiny/practical1/app.R`
- `tests/testthat/test-13_practical1_shiny.R`

For remote-routing accuracy, read the Nectar control-plane docs before any
future remote implementation:

- `/Users/bwbrook/work/nectar/docs/workflows/control-plane-doctrine.md`
- `/Users/bwbrook/work/nectar/docs/workflows/compute-resource-selection.md`
- `/Users/bwbrook/work/nectar/docs/workflows/project-integration.md`
- `/Users/bwbrook/work/nectar/docs/workflows/data-placement.md`
- `/Users/bwbrook/work/nectar/docs/exchange/current_status.md`

## Current Read-Only Evidence

Goal 017 refresh probes were read-only only.

Tailnet gateway:

```sh
curl -k --max-time 10 https://100.96.185.60/_gateway-health
```

Result:

```text
deep-server app gateway ok
```

Campus IP from this Mac mini route:

```sh
curl -k --max-time 10 https://131.217.90.193/_gateway-health
```

Result:

```text
curl: (28) Connection timed out after 10002 milliseconds
```

Campus Windows/WSL follow-up, reported 2026-06-05:

- Browser opened `https://131.217.90.193/_gateway-health`, showed a red
  "Not secure" warning, and returned `deep-server app gateway ok` after the
  warning was accepted.
- PowerShell:
  - `curl.exe -k --max-time 10 https://131.217.90.193/_gateway-health`
    returned `deep-server app gateway ok`.
  - `Test-NetConnection 131.217.90.193 -Port 443` returned
    `TcpTestSucceeded : True`.
  - Tailnet `100.96.185.60:443` timed out from PowerShell.
- WSL:
  - `curl -k --max-time 10 https://131.217.90.193/_gateway-health` returned
    `deep-server app gateway ok`.
  - `nc` reported TCP success for both `100.96.185.60:443` and
    `131.217.90.193:443`.

`deep-server-ts` runtime probe:

- hostname: `deep-server`
- logical CPUs: `64`
- memory: `125Gi` total, `123Gi` available at probe time
- root filesystem: `937G` total, `831G` available
- `/data`: `13T` total, `4.5T` available
- Docker: client/server `29.5.2`, cgroup v2, `64` CPUs, zero containers
- R: `4.6.0`
- Java: OpenJDK `21.0.11`
- listeners included `0.0.0.0:443`, `[::]:443`, SSH on `22`, and local-only
  RStudio on `127.0.0.1:8787`

Interpretation: host capacity, the tailnet gateway, and the campus/public
health route are ready for the next pre-deployment implementation pass. The
remaining route-related release gates are TLS trust / student-friendly URL
polish and verification of the eventual app path, not only `/_gateway-health`.

## Decision Package

### Platform Choice

Use ShinyProxy on `deep-server`, backed by Docker, as the primary
self-managed platform path for the 2026 road test.

Rationale:

- `deep-server` has sufficient CPU, RAM, disk, Docker, R, and Java.
- ShinyProxy aligns with per-student or per-session container isolation.
- Docker limits can bound CPU and memory per session.
- The same platform pattern can support later teaching apps.
- Posit Connect remains a conditional institutional fallback only if UTAS
  provides a supported instance.
- Shiny Server open source is not the primary path because it does not
  naturally solve per-student workspace and quota needs.

### Gateway And Upstream Alignment

Use the existing nginx HTTPS gateway on `443` as the intended front door. The
campus/public health route has been confirmed from Barry's Windows/WSL campus
path, but the eventual app URL must not ask students to accept a red browser
security warning.

The next implementation goal must decide one of these two approaches before
service work:

1. Configure ShinyProxy to listen internally on the current gateway upstream
   target, documented as `127.0.0.1:3838`.
2. Change the nginx upstream to the selected ShinyProxy internal port.

Either choice must be explicit, documented, reversible, and tested from:

- the Mac mini tailnet route,
- Barry's Windows/WSL or other campus/student-like route,
- an ordinary browser path that does not require admin SSH and does not present
  an unacceptable TLS trust warning.

### Account Or Token Model

Use generated class accounts or generated per-student tokens for the first road
test unless UTAS SSO is already easy and supported.

Minimum account plan:

- one identity per student or demonstrator;
- a small spare-account pool;
- no shared writeable workspace for all students;
- no unauthenticated URL for workflows that promise recoverable exports;
- credentials distributed through an approved teaching channel;
- clear expiry and cleanup date.

### Workspace And Quota Policy

Use one workspace per student identity under the `/data` family. Recommended
root for the first road test:

```text
/data/codex/teaching/rpva-2026/workspaces/<student_id>/
```

Recommended subdirectories:

```text
exports/
settings/
plots/
logs/
tmp/
```

Quota target:

- about `1 GB` per student for under 50 students;
- compact exports only;
- no raw trajectory object exports by default;
- daily or session-end cleanup of `tmp/`;
- post-semester cleanup after an announced retention date.

### Docker And ShinyProxy Build Path

The next implementation goal should build from a version-pinned source state.

Preferred build contract:

- build a Docker image from a clean `rPVA` checkout or release reference;
- install package dependencies from `renv.lock`;
- install only the app/runtime dependencies needed for Practical 1;
- run the app through `run_practical1_shiny()` or an equivalent installed-app
  entrypoint;
- keep app dependencies inside the image rather than the host R library;
- map per-student workspace volumes explicitly;
- set conservative CPU and memory limits per container/session.

No Dockerfile, ShinyProxy config, service file, or remote clone is created by
this Goal 017 packet.

### Load-Test Ladder

Run the ladder before students receive the URL:

1. one instructor session completes the full Practical 1 path;
2. five concurrent sessions run baseline and compare screens;
3. ten concurrent sessions run stochastic scenarios;
4. twenty-five concurrent sessions run a typical mid-practical sequence;
5. fifty simulated or human sessions run bounded workloads if feasible.

Measure:

- app response time;
- CPU and memory pressure;
- container count;
- failed runs;
- disk writes per workspace;
- export creation and download time when exports exist;
- gateway and app logs.

### Monitoring Checklist

Minimum operational checks:

- `deep-server` reachability over the admin route;
- student-facing URL reachability;
- nginx/gateway status;
- ShinyProxy service status;
- Docker container count and failed containers;
- CPU and memory pressure;
- root disk and `/data` disk use;
- per-student workspace growth;
- app errors and access logs;
- spare-account availability;
- fallback bundle availability.

Suggested cadence:

- before Practical 1;
- during Practical 1;
- after Practical 1;
- before Practical 2;
- after Practical 2;
- midway through the report-writing period;
- before cleanup.

### Fallback Materials

Prepare before class:

- static Practical 1 worksheet;
- screenshots of each concept stage;
- precomputed comparison table;
- representative trajectory, summary, and extinction/genetics plots;
- compact explanation of zero observed extinction risk;
- demonstrator notes for instructor-led recovery;
- local instructor launch path using `run_practical1_shiny()`.

The fallback must preserve the teaching objective even if the hosted service is
unavailable.

### Rollback And Cleanup

Rollback plan for the next implementation goal:

- keep the previous gateway config or service state recoverable before edits;
- define how to stop ShinyProxy without affecting local-only RStudio;
- define how to remove generated class accounts or tokens;
- define how to remove containers/images created for the road test;
- define workspace retention and deletion dates before class;
- record all service changes in the project and Nectar control-plane notes.

Cleanup after the teaching window:

- stop new sessions;
- retain or archive only approved support records;
- remove temporary files;
- delete student workspaces after the announced retention period;
- remove generated class credentials;
- document what worked before reuse for future teaching apps.

## Go/No-Go Gates

Do not expose the app to students until all gates pass or Barry explicitly
accepts a documented exception:

1. Approved platform path: ShinyProxy on `deep-server`, or a documented
   alternative.
2. Approved URL, DNS, TLS, and campus/firewall route.
3. Student-like browser path reaches the gateway and app without an
   unacceptable browser security warning.
4. Gateway upstream target is aligned with the app service.
5. Generated account/token model is tested.
6. Per-student workspace mapping and quota/cap policy are tested.
7. A complete Practical 1 browser flow passes from the student URL.
8. Load testing reaches a conservative class-size target.
9. Monitoring checklist and recovery checklist are ready.
10. Fallback materials are ready.
11. Cleanup and retention dates are written down.
12. No local-only RStudio or unrelated service exposure is introduced.

## Teaching Versus Future Research Boundary

The hosted Practical 1 app is a teaching concept lab. It deliberately uses
bounded controls, toy-model stages, compact outputs, and interpretation prompts
to prepare students for the Woodhen Practical 2 workflow.

Do not treat these simplifications as research-grade assumptions for the future
Lord Howe Island woodhen recovery paper. The research lane will need separate
versioned scenarios, real data provenance, sensitivity analysis, model
calibration or justification, richer uncertainty treatment, reproducible
analysis artefacts, and manuscript-facing review.

The deployment platform can be reused for teaching and demonstration, but the
scientific paper path remains a separate analysis contract.

## Boundaries

Allowed in this goal:

- create this Goal 017 packet;
- update targeted Shiny planning docs to point at Goal 017 or remove stale
  next-goal text;
- run read-only gateway and host metadata probes;
- run docs-only validation.

Do not:

- install or configure ShinyProxy;
- edit nginx, systemd, firewall, DNS, TLS, Docker service configuration, or
  any external-access setting;
- start, stop, restart, enable, or disable services;
- create users, tokens, directories, containers, images, or remote clones;
- edit app code, package code, scenarios, dependencies, or tests;
- run broad tests for docs-only work;
- commit or push;
- expose a student-facing service;
- contact other agents.

## Validation

Before reporting:

```sh
git diff --check
git status --short --branch
```

For docs-only work, no R tests are required. If executable R/Shiny code is
changed contrary to the intended boundary, run the focused relevant tests and
explain why the code edit was necessary.

## Report Back

Report:

- branch/worktree state;
- files created or changed;
- remote probes run and results;
- validation result;
- blockers or risky assumptions;
- recommended next action;
- explicit confirmation that no service, deploy, commit, or push boundary was
  crossed.
