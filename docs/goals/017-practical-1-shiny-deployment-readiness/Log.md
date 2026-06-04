# Log

## 2026-06-04 - CoS Goal Publication And Branch Setup

- CoS directed `woodhen` under the revised direct model:
  `BB -> CoS -> Action Agent`.
- Objective: create and advance the Goal 017 deployment-readiness package for
  Practical 1 Shiny on `deep-server`, while remaining strictly
  pre-deployment.
- Starting checkpoint before branch creation:
  - CWD: `/Users/bwbrook/.codex/worktrees/a4af/rPVA`
  - linked worktree Git dir:
    `/Users/bwbrook/git/rPVA/.git/worktrees/rPVA`
  - common Git dir: `/Users/bwbrook/git/rPVA/.git`
  - detached `HEAD` at `c6d3426`
  - status: `## HEAD (no branch)`
- Created and switched to branch:
  `codex/rpva-goal017-deployment-readiness`.
- Confirmed branch state after switching:
  - CWD: `/Users/bwbrook/.codex/worktrees/a4af/rPVA`
  - branch: `codex/rpva-goal017-deployment-readiness`
  - HEAD:
    `c6d3426 (HEAD -> codex/rpva-goal017-deployment-readiness, origin/main, origin/HEAD, main) Add rPVA thread handoff note`
  - status: `## codex/rpva-goal017-deployment-readiness`

## 2026-06-04 - Implementation Start And Context

- Continued after CoS acknowledged the branch checkpoint.
- Reconfirmed boundaries:
  - create Goal 017 packet;
  - only targeted Shiny planning doc updates if needed;
  - read-only remote-readiness probes allowed;
  - no ShinyProxy, nginx, systemd, firewall, DNS, TLS, Docker service, or
    external-access changes;
  - no package installs;
  - no app code changes unless unavoidable;
  - no broad tests for docs-only work;
  - no commit or push.
- Read required rPVA context:
  - `docs/codex/thread-handoff-2026-06-04.md`
  - `docs/teaching/shiny/README.md`
  - `docs/teaching/shiny/deep-server-hosting-feasibility.md`
  - `docs/teaching/shiny/platform-options-decision-matrix.md`
  - `docs/teaching/shiny/implementation-roadmap.md`
  - `docs/teaching/shiny/road-test-operations-plan.md`
  - `docs/teaching/shiny/student-workspace-and-export-design.md`
  - Goal 012 `Goal.md`, `Plan.md`, `Runbook.md`, `Log.md`
  - Goal 015 `Goal.md`, `Log.md`
  - Goal 016 `Goal.md`, `Log.md`, `qa-report.md`
  - `R/shiny_practical1.R`
  - `inst/shiny/practical1/README.md`
  - `inst/shiny/practical1/app.R`
  - `tests/testthat/test-13_practical1_shiny.R`
- Read Nectar control-plane docs for remote-routing and placement accuracy:
  - `/Users/bwbrook/work/nectar/docs/workflows/control-plane-doctrine.md`
  - `/Users/bwbrook/work/nectar/docs/workflows/compute-resource-selection.md`
  - `/Users/bwbrook/work/nectar/docs/workflows/project-integration.md`
  - `/Users/bwbrook/work/nectar/docs/workflows/data-placement.md`
  - `/Users/bwbrook/work/nectar/docs/exchange/current_status.md`

## 2026-06-04 - Read-Only Remote Refresh

- Ran tailnet gateway health check:
  - command:
    `curl -k --max-time 10 https://100.96.185.60/_gateway-health`
  - result: `deep-server app gateway ok`
- Ran campus-IP gateway health check from the Mac mini route:
  - command:
    `curl -k --max-time 10 https://131.217.90.193/_gateway-health`
  - result: `curl: (28) Connection timed out after 10002 milliseconds`
  - interpretation: do not treat the campus/student route as verified from
    this action thread; retest from Barry's Windows/WSL or another
    student-like route before go-live.
- Ran one read-only `deep-server-ts` metadata probe:
  - hostname: `deep-server`
  - logical CPUs: `64`
  - memory: `125Gi` total, `123Gi` available
  - root filesystem: `937G` total, `831G` available
  - `/data`: `13T` total, `4.5T` available
  - Docker client/server: `29.5.2`
  - Docker cgroup version: `2`
  - Docker CPUs visible: `64`
  - Docker root: `/var/lib/docker`
  - containers/running: `0` / `0`
  - R: `4.6.0`
  - Java: OpenJDK `21.0.11`
  - listeners include `0.0.0.0:443`, `[::]:443`, `0.0.0.0:22`, `[::]:22`,
    Tailscale listener addresses, and local-only RStudio on
    `127.0.0.1:8787`
- No `sudo`, installs, writes, service changes, firewall changes, account
  changes, directory creation, container creation, or deployment actions were
  performed on `deep-server`.

## 2026-06-04 - Packet And Planning Doc Updates

- Created:
  - `docs/goals/017-practical-1-shiny-deployment-readiness/Goal.md`
  - `docs/goals/017-practical-1-shiny-deployment-readiness/Plan.md`
  - `docs/goals/017-practical-1-shiny-deployment-readiness/Runbook.md`
  - `docs/goals/017-practical-1-shiny-deployment-readiness/Log.md`
- Updated targeted planning docs:
  - `docs/teaching/shiny/README.md`
  - `docs/teaching/shiny/implementation-roadmap.md`
- Goal 017 package records:
  - ShinyProxy on `deep-server` as the primary self-managed platform path;
  - existing nginx `443` gateway as the intended front door, pending
    student-route verification;
  - generated class accounts or tokens as the first road-test identity path;
  - per-student workspaces under
    `/data/codex/teaching/rpva-2026/workspaces/<student_id>/`;
  - about `1 GB` per-student quota target with compact exports only;
  - Docker/ShinyProxy build contract for a later implementation goal;
  - load-test ladder up to 50 sessions if feasible;
  - monitoring, fallback, rollback, cleanup, and explicit go/no-go gates;
  - clear separation between the teaching app simplifications and the future
    Lord Howe Island woodhen recovery research lane.
- No app, package, scenario, dependency, or test files were edited.

## 2026-06-04 - Validation

- Ran `git diff --check`:
  - passed with no output.
- Ran marker scan as an extra docs hygiene check:
  - scanned the new Goal 017 packet and updated Shiny planning docs for
    unresolved placeholder markers;
  - no content hits.
- Ran `git status --short --branch`:
  - `## codex/rpva-goal017-deployment-readiness`
  - ` M docs/teaching/shiny/README.md`
  - ` M docs/teaching/shiny/implementation-roadmap.md`
  - `?? docs/goals/017-practical-1-shiny-deployment-readiness/`
- Docs-only validation decision:
  - no R tests were run because no executable R, Shiny, package, scenario,
    dependency, or test files were changed.
- Boundary confirmation:
  - no package installs;
  - no app code changes;
  - no broad tests;
  - no remote writes;
  - no ShinyProxy, nginx, systemd, firewall, DNS, TLS, Docker service, account,
    directory, container, or external-access changes;
  - no student-facing exposure;
  - no commit or push.
