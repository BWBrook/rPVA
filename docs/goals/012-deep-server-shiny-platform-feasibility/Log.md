# Log

## 2026-06-02 - Supervisor Goal Publication

- Supervisor created Goal 012 after Barry approved the Goal 011 hosted/server
  Shiny direction and clarified that the service should be persistent across
  the Practical 1 to report-due window.
- New requirement: per-student workspaces for saved/recoverable exports, likely
  quota-capped around 1 GB/student and cleaned after semester.
- New strategic framing: design a reusable teaching-app platform on
  `deep-server`, with later Fauna of Tasmania SDM reuse in mind.
- Goal 012 is a feasibility and architecture goal. It must not install
  software, change services, open ports, implement Shiny, or commit/push.

## 2026-06-02 - Execution Start

- Formal goal mode appeared active for this action-thread run.
- Started from `/Users/bwbrook/git/rPVA` on `main`.
- Read the Goal 012 packet:
  - `Goal.md`
  - `Plan.md`
  - `Runbook.md`
  - `Log.md`
- Starting `git status --short --branch --untracked-files=all` showed:
  - `## main...origin/main`
  - pre-existing tracked edits in:
    - `docs/teaching/woodhen/README.md`
    - `docs/teaching/woodhen/instructor-guide.md`
  - pre-existing untracked Goal 010, Goal 011, legacy intake, assessment
    draft, and Shiny design files.
  - untracked Goal 012 packet files.
- Boundary confirmed: create/update only `docs/teaching/shiny/` and this Goal
  012 `Log.md`; no installation, service change, port/firewall change, user or
  directory creation, container creation, Shiny implementation, commit, or push.

## 2026-06-02 - Source Review And Read-Only Probes

- Read current Shiny design docs from Goal 011:
  - `docs/teaching/shiny/README.md`
  - `docs/teaching/shiny/deployment-and-setup-options.md`
  - `docs/teaching/shiny/implementation-roadmap.md`
  - `docs/teaching/shiny/engine-affordance-audit.md`
- Read the Nectar control-plane context for remote-compute and project
  integration policy, including:
  - `docs/workflows/control-plane-doctrine.md`
  - `docs/workflows/compute-resource-selection.md`
  - `docs/workflows/project-integration.md`
  - `docs/exchange/current_status.md`
- Ran read-only `deep-server-ts` host/resource probe:
  - hostname `deep-server`
  - `64` logical CPUs
  - memory `125Gi` total, `123Gi` available at probe time
  - root filesystem `937G` total, `831G` available
  - `/data` filesystem `13T` total, `4.5T` available
- Ran read-only container/runtime probe:
  - Docker Engine Community `29.5.2` active
  - Docker server visible, zero running containers
  - cgroup v2, `64` CPUs and `125.8GiB` memory visible to Docker
  - `podman` not found
- Ran read-only R/Java probe:
  - R `4.6.0` on `x86_64-pc-linux-gnu`
  - OpenJDK `21.0.11`
- Ran read-only listening-port and web-server probes:
  - listeners included SSH on `0.0.0.0:22` and `[::]:22`
  - `127.0.0.1:8787` was local-only
  - no visible listeners on student-facing `80`, `443`, `3838`, or `8080`
  - `nginx`, `apache2`, and `caddy` were not found on the visible path
- Ran read-only route probes:
  - Mac mini direct SSH to `deep-server` campus IP timed out on port `22`
  - Mac mini `nc` to `131.217.90.193:22` timed out
  - WSL/campus route showed `22` open but `80`, `443`, `3838`, `8080`, and
    `8787` closed or filtered
- No `sudo`, installs, service changes, firewall changes, user/directory
  creation, or container creation were performed.

## 2026-06-02 - Draft Platform Feasibility Package

- Created:
  - `docs/teaching/shiny/deep-server-hosting-feasibility.md`
  - `docs/teaching/shiny/student-workspace-and-export-design.md`
  - `docs/teaching/shiny/platform-options-decision-matrix.md`
  - `docs/teaching/shiny/road-test-operations-plan.md`
- Updated:
  - `docs/teaching/shiny/README.md`
- Recommendation recorded in the design docs:
  - keep `deep-server` as the preferred candidate host, conditional on campus
    web access, TLS, and reverse-proxy/firewall decisions;
  - use ShinyProxy backed by Docker as the preferred self-managed platform
    candidate;
  - check UTAS-supported Posit Connect before self-managing ShinyProxy if an
    institutional licence and support path already exists;
  - use generated class accounts or tokens for the first road test unless SSO
    is easy;
  - use compact per-student exports under a quota-capped `/data` workspace
    model and clean after semester.
- No Shiny implementation, package code, scenario YAML, tests, CI,
  dependencies, metadata, Goal 010 assessment files, commits, pushes, branches,
  or PRs were touched.

## 2026-06-02 - Validation

- Ran `git diff --check`:
  - passed with no whitespace or patch hygiene issues.
- Ran the required marker scan across `docs/teaching/shiny` and the Goal 012
  packet:
  - no hits in the Shiny design documents.
  - intentional hits remain only in the Goal 012 contract text where `Goal.md`
    and `Runbook.md` quote the validation command itself.
- Ran `git status --short --branch --untracked-files=all`:
  - `## main...origin/main`
  - pre-existing tracked edits remain in:
    - `docs/teaching/woodhen/README.md`
    - `docs/teaching/woodhen/instructor-guide.md`
  - pre-existing untracked Goal 010, Goal 011, legacy intake, assessment
    draft, and Goal 011 Shiny design files remain visible.
  - new Goal 012 packet and Shiny feasibility files remain untracked.
- Allowed-surface check:
  - Goal 012-created/updated paths are limited to `docs/teaching/shiny/` and
    `docs/goals/012-deep-server-shiny-platform-feasibility/Log.md`.
  - No install, service change, sudo change, firewall/port change,
    user/directory/container creation, Shiny implementation, package code,
    scenarios, tests, dependencies, CI, metadata, Goal 010 assessment edits,
    commit, push, branch, or PR occurred.
