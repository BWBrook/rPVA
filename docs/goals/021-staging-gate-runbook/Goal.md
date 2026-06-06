# Goal 021: Staging Gate Runbook

## Objective

Create a decision-ready, strictly pre-live staging-gate package for the first
future Practical 1 Shiny staging approval on `deep-server`.

This goal turns Goals 017-020 evidence into a compact runbook and go/no-go
checklist for a later approved ShinyProxy/nginx/app-path staging pass. It does
not authorize staging, exposing, installing, configuring, restarting, or
editing any live service.

## Context

Accepted prior evidence:

- Goal 017 selected ShinyProxy backed by Docker on `deep-server` as the leading
  self-managed path.
- Goal 018 created the inert ShinyProxy/Docker/nginx scaffold under
  `deploy/shinyproxy/practical1/`.
- Goal 019 tightened the scaffold locally and kept the work non-live.
- Goal 020 proved the x86_64 image-build path on `deep-server` after adding
  `libuv1-dev`; image `rpva-practical1:goal020-6ed2445` built successfully,
  one localhost-only smoke returned the Practical 1 PVA app page, and the smoke
  container was removed.

Current blockers are no longer basic image buildability. They are approval and
operations gates: TLS trust and student-friendly URL, identity, per-student
workspace mapping, image promotion, ShinyProxy app config, nginx route
alignment, student-like route tests, monitoring, rollback, cleanup, support
materials, and explicit Barry/SRF handoff.

## Deliverables

Create:

- `docs/goals/021-staging-gate-runbook/Goal.md`
- `docs/goals/021-staging-gate-runbook/Plan.md`
- `docs/goals/021-staging-gate-runbook/Runbook.md`
- `docs/goals/021-staging-gate-runbook/Log.md`

Create or update inert scaffold documentation only if it improves operator
clarity, preferably Markdown under:

- `deploy/shinyproxy/practical1/`

Targeted teaching Shiny docs may be updated only to point at Goal 021 or
reconcile stale next-step wording.

## Required Read Context

Read:

- global and repo-local instructions if present;
- `docs/codex/thread-handoff-2026-06-04.md`;
- Shiny teaching planning docs under `docs/teaching/shiny/`;
- Goals 017, 018, 019, and 020 packets;
- `deploy/shinyproxy/practical1/README.md`;
- `deploy/shinyproxy/practical1/Dockerfile.template`;
- `deploy/shinyproxy/practical1/application.example.yml`;
- `deploy/shinyproxy/practical1/nginx-practical1.example.conf`;
- `deploy/shinyproxy/practical1/validate-scaffold.sh`.

## Go/No-Go Gates

All gates below must be green or explicitly waived by Barry/SRF before a later
live or staging implementation goal proceeds.

| Gate | Required decision/evidence | Current state |
| --- | --- | --- |
| Approval handoff | Barry/SRF names the exact staging scope, URL/path, service owner, and rollback authority | Not approved in Goal 021 |
| TLS trust and student URL | Browser path uses an acceptable trusted certificate and a student-friendly DNS name or an explicitly accepted pilot exception | Still a release gate |
| Identity model | Generated class accounts/tokens or approved institutional auth is selected, distributed, and revocable | Recommended, not implemented |
| Workspace mapping | One writable workspace per authenticated student; no shared writable class directory | Template supports this, not created |
| Quota and retention | Per-student quota target, retention date, and cleanup owner are written before accounts are issued | Not implemented |
| Image promotion | Exact image tag/source commit is selected for staging, with decision whether to reuse or rebuild from `d50cb51` or later | Goal 020 image exists for review only |
| ShinyProxy config | Reviewed application config uses inert values replaced through an approved implementation goal | Template only |
| nginx route | Gateway upstream/path aligns with the selected ShinyProxy internal port and app path | Template only |
| Local route test | `deep-server` localhost/app-path check passes after approved staging | Not run in Goal 021 |
| Tailnet/admin route test | Mac mini tailnet health and app path pass after approved staging | Health passes; app path not staged |
| Campus/student route test | Windows/WSL or equivalent student-like browser path passes without unacceptable TLS warning | Health previously passed from Windows/WSL; Mac mini campus IP timed out in Goal 021 |
| Monitoring | Commands/checklist for service status, container count, CPU/RAM, disk, logs, and workspace growth are ready | Checklist drafted |
| Rollback | Stop/disable/revert steps and owner are approved before service edits | Checklist drafted |
| Cleanup | Containers, image policy, workspaces, accounts/tokens, and logs cleanup policy are approved | Checklist drafted |
| Support/fallback | Static fallback materials and demonstrator recovery notes are ready before student URL release | Required before go-live |
| Research boundary | Teaching deployment must not encode Lord Howe woodhen research analysis assumptions | Preserved |

## Future Staging Shape

A later approved staging goal should be a narrow operations goal, not a new
design exercise. It should:

1. choose the staging image tag or rebuild source commit;
2. choose ShinyProxy internal port and nginx app path;
3. prepare generated identity and workspace mapping without committing
   sensitive values;
4. stage only to a non-student URL/path first;
5. run localhost, tailnet, campus/student-like, and browser smoke checks;
6. record rollback and cleanup evidence before any student-facing handoff.

## Boundaries

Do not perform in Goal 021:

- ShinyProxy installation or configuration;
- nginx, systemd, firewall, DNS, TLS, Docker daemon/service, account,
  credential, class workspace, or external-access changes;
- Docker build;
- Docker container launch;
- host package installs;
- app/R/package/scenario/test changes unless a tiny docs-reference mismatch is
  found;
- public, campus, tailnet, or student-facing exposure;
- commit or push.

## Teaching And Research Boundary

Goal 021 serves Practical 1 teaching delivery only. Future Lord Howe Island
woodhen recovery research remains a separate path requiring its own data
provenance, scenario definitions, uncertainty treatment, sensitivity analysis,
and manuscript review.

## Validation

Required local checks:

```sh
git status --short --branch
git diff --check
rg -n "$(printf '%s|%s|%s' 'TO''DO' 'T''BD' 'PLACE''HOLDER')" \
  docs/goals/021-staging-gate-runbook \
  deploy/shinyproxy/practical1/staging-gate-checklist.md \
  docs/teaching/shiny/README.md \
  docs/teaching/shiny/implementation-roadmap.md
bash -n deploy/shinyproxy/practical1/validate-scaffold.sh
bash deploy/shinyproxy/practical1/validate-scaffold.sh
ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0)); puts "ruby yaml parse ok"' \
  deploy/shinyproxy/practical1/application.example.yml
```

Run a secret-pattern scan over changed/new text and review all hits manually.
No R tests are required for docs-only work.

## Report Back

Report to SRF-A:

- branch/worktree state;
- files created/changed;
- read-only remote probes run and results, if any;
- validation commands and outcomes;
- recommended next action and approval gates;
- explicit boundary confirmation.
