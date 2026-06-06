# Log

## 2026-06-06 - SRF-A Publication And Branch Setup

- SRF-A directed `woodhen` to create Goal 021 after accepting Goal 020.
- Accepted Goal 020 result:
  - `libuv1-dev` resolved the prior `fs`/`libuv` build failure on
    `deep-server` `x86_64`;
  - image `rpva-practical1:goal020-6ed2445` built successfully on
    `deep-server`;
  - exactly one localhost-only smoke passed via `127.0.0.1:3920`;
  - smoke container was stopped and removed;
  - image remains on `deep-server` for review;
  - no live service, deployment, or public exposure boundary was crossed.
- Objective: create a strictly pre-live staging-gate/runbook package for a
  future approved ShinyProxy/nginx/app-path staging pass.
- First checkpoint before editing:
  - CWD: `/Users/bwbrook/.codex/worktrees/a4af/rPVA`
  - branch: `codex/rpva-goal020-deep-server-image-preflight`
  - HEAD:
    `d50cb51 (HEAD -> codex/rpva-goal020-deep-server-image-preflight, origin/main, origin/codex/rpva-goal020-deep-server-image-preflight, origin/HEAD, main) Record Goal 020 image rebuild smoke`
  - status:
    `## codex/rpva-goal020-deep-server-image-preflight...origin/codex/rpva-goal020-deep-server-image-preflight`
- Ran `git fetch --prune origin`.
- Confirmed `origin/main` resolves to:
  `d50cb51459cf9d6f55e8d5de83bdcdd3541a2631`
- Confirmed no local or remote branch named
  `codex/rpva-goal021-staging-gate-runbook` was present.
- Created and switched to branch:
  `codex/rpva-goal021-staging-gate-runbook` from `origin/main`.
- Confirmed branch state after switching:
  - CWD: `/Users/bwbrook/.codex/worktrees/a4af/rPVA`
  - branch: `codex/rpva-goal021-staging-gate-runbook`
  - HEAD:
    `d50cb51 (HEAD -> codex/rpva-goal021-staging-gate-runbook, origin/main, origin/codex/rpva-goal020-deep-server-image-preflight, origin/HEAD, main, codex/rpva-goal020-deep-server-image-preflight) Record Goal 020 image rebuild smoke`
  - status:
    `## codex/rpva-goal021-staging-gate-runbook...origin/main`

## 2026-06-06 - Context Review

- `AGENTS.md` was not present in the repository root; this matches the
  2026-06-04 handoff note.
- Read:
  - `docs/codex/thread-handoff-2026-06-04.md`
  - `docs/teaching/shiny/README.md`
  - `docs/teaching/shiny/deep-server-hosting-feasibility.md`
  - `docs/teaching/shiny/platform-options-decision-matrix.md`
  - `docs/teaching/shiny/implementation-roadmap.md`
  - `docs/teaching/shiny/road-test-operations-plan.md`
  - `docs/teaching/shiny/student-workspace-and-export-design.md`
  - Goals 017, 018, 019, and 020 `Goal.md`, `Plan.md`, `Runbook.md`, and
    `Log.md`
  - `deploy/shinyproxy/practical1/README.md`
  - `deploy/shinyproxy/practical1/Dockerfile.template`
  - `deploy/shinyproxy/practical1/application.example.yml`
  - `deploy/shinyproxy/practical1/nginx-practical1.example.conf`
  - `deploy/shinyproxy/practical1/validate-scaffold.sh`
- Context summary:
  - ShinyProxy backed by Docker remains the preferred self-managed platform;
  - the existing nginx `443` gateway is the intended front door;
  - TLS trust and student-friendly URL remain release gates;
  - generated accounts or per-student tokens remain the recommended first
    road-test identity model;
  - per-student workspaces should map under
    `/data/codex/teaching/rpva-2026/workspaces/<student_id>/`;
  - the Goal 020 image-build and localhost smoke evidence removes the basic
    x86_64 build blocker.

## 2026-06-06 - Read-Only Probe Refresh

- Ran tailnet gateway health check:
  - command:
    `curl -k --max-time 10 https://100.96.185.60/_gateway-health`
  - result: `deep-server app gateway ok`
- Ran campus-IP gateway health check from the Mac mini route:
  - command:
    `curl -k --max-time 10 https://131.217.90.193/_gateway-health`
  - result:
    `curl: (28) Connection timed out after 10008 milliseconds`
  - interpretation: preserve Windows/WSL or equivalent student-route browser
    verification as a go/no-go gate.
- Ran read-only image and container-state probe on `deep-server-ts`:
  - hostname: `deep-server`
  - architecture: `x86_64`
  - Docker CLI: `Docker version 29.5.2, build 79eb04c`
  - image:
    `rpva-practical1:goal020-6ed2445`
  - image ID:
    `sha256:346260b5dd1739b758e8b918aaeeddfa0a6040776fb30d576e42919e52895d76`
  - image size:
    `1786576408` bytes; `docker image ls` reported about `1.79GB`
  - image created:
    `2026-06-06T12:24:46.191673688+10:00`
  - `docker ps --filter name=rpva-goal020-6ed2445` returned no rows;
  - `docker ps -a --filter name=rpva-goal020-6ed2445` returned no rows.
- No Docker build, container launch, service change, remote service operation,
  or remote write was performed.

## 2026-06-06 - Packet And Checklist Creation

- Created:
  - `docs/goals/021-staging-gate-runbook/Goal.md`
  - `docs/goals/021-staging-gate-runbook/Plan.md`
  - `docs/goals/021-staging-gate-runbook/Runbook.md`
  - `docs/goals/021-staging-gate-runbook/Log.md`
- Created inert operator checklist:
  - `deploy/shinyproxy/practical1/staging-gate-checklist.md`
- Updated targeted planning docs:
  - `docs/teaching/shiny/README.md`
  - `docs/teaching/shiny/implementation-roadmap.md`
- No app, R package, scenario, dependency, or test files changed.

## 2026-06-06 - Validation

- Ran `git status --short --branch`:
  - `## codex/rpva-goal021-staging-gate-runbook...origin/main`
  - modified:
    - `docs/teaching/shiny/README.md`
    - `docs/teaching/shiny/implementation-roadmap.md`
  - new:
    - `deploy/shinyproxy/practical1/staging-gate-checklist.md`
    - `docs/goals/021-staging-gate-runbook/`
- Ran `git diff --check`:
  - passed with no output.
- Ran marker scan over the Goal 021 packet, inert checklist, and targeted
  planning docs:
  - no hits.
- Ran shell syntax check:
  - `bash -n deploy/shinyproxy/practical1/validate-scaffold.sh`
  - passed.
- Ran scaffold validator:
  - `bash deploy/shinyproxy/practical1/validate-scaffold.sh`
  - output:
    `Practical 1 Shiny deployment scaffold static checks passed.`
- Ran explicit YAML parse:
  - `ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0)); puts "ruby yaml parse ok"' deploy/shinyproxy/practical1/application.example.yml`
  - output: `ruby yaml parse ok`
- Ran secret-pattern scan over changed/new text:
  - hits were limited to policy/gate wording about accounts, tokens,
    credentials, and the scan command itself;
  - no real-looking secrets, keys, passwords, credentials, private TLS
    material, or student identifiers were found.
- No R tests were run because no executable R, Shiny app, package, scenario,
  dependency, or test files changed.
- Boundary confirmation:
  - no ShinyProxy installation or configuration;
  - no nginx, systemd, firewall, DNS, TLS, Docker daemon/service, account,
    credential, class workspace, or external-access changes;
  - no Docker build;
  - no Docker container launch;
  - no host package installs;
  - no public/student-facing/tailnet/campus exposure;
  - no remote writes or remote service operations;
  - no commit or push.
