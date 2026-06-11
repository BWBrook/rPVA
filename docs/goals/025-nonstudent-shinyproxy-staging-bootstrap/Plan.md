# Plan

## Phase 1: Orient And Record Start State

- Read `Goal.md`, `Plan.md`, `Runbook.md`, and required context.
- Confirm local branch, HEAD, status, and repo-local instruction state.
- Record start state in `Log.md`.

## Phase 2: Live Remote Preflight

- Probe `deep-server-ts` for host, route, sudo, Docker, Java, nginx, listeners,
  ShinyProxy state, gateway health, and `/data/codex` workspace roots.
- Record all findings before changing remote state.
- Stop early if the live state contradicts the goal assumptions in a material
  way.

## Phase 3: Source And Image Preparation

- Stage the exact `5c9d500` source state on `deep-server`.
- Prefer Git if available; otherwise use a trusted Mac mini archive, bundle, or
  `rsync`.
- Build the Practical 1 image with a goal-specific tag.
- Run a bounded local image/container smoke if practical.

## Phase 4: ShinyProxy Bootstrap

- Install ShinyProxy if absent.
- Create/update config for one Practical 1 staging app and one non-student
  staging identity.
- Keep secret values out of repo, logs, and chat.
- Configure systemd service if needed.
- Bind to localhost and align with the existing gateway when possible.

## Phase 5: Route And Browser Smoke

- Validate localhost route.
- Validate tailnet gateway route.
- Attempt Mac mini campus-IP route once and record the result.
- Use Chrome plugin if available for authenticated browser smoke.
- Exercise Start, Concept Lab, Compare/export, and Transfer.
- Capture screenshot/download evidence under `/tmp`.

## Phase 6: Final Posture

- If smoke passes, leave authenticated non-student staging running and record
  rollback/cleanup instructions.
- If smoke fails, stop/disable or roll back partial service exposure and record
  exact blockers.

## Phase 7: Repo Records And Validation

- Update `Log.md`.
- Create `staging-report.md`.
- Update targeted Shiny/deployment docs only if live state changed.
- Run local validation gates, marker scan, secret scan, and final status.
- Report final local and remote state to the orchestrator.
