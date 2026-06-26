# Goal 042: ITS Gitea Dev Image Publication Via Stochastic

## Objective

Prepare a complete repo-local instruction pack for the WSL/campus worker
`stochastic` to perform the first controlled ITS Gitea registry image
publication for the KPZ308 rPVA ShinyProxy app.

This is a setup/delegation goal for `stochastic`, not an image publication
goal for `woodhen`. The Mac mini action agent must not build, push, log in,
access WSL, access ITS Gitea, or change live infrastructure.

## Context

- Barry has launched `stochastic` on WSL and it reported back successfully via
  commit `199f605a095a8597cd5fe500cefaa1eb062b7b50`.
- WSL lane viability is confirmed: Ubuntu 24.04 WSL2, x86_64, Docker
  CLI/daemon available, and `https://git.its.utas.edu.au/` reachable.
- The bootstrap report was pushed directly to `main`. That was harmless and R
  CI passed, but live registry work needs a stricter report-branch protocol.
- `stochastic` should be autonomous enough to build, smoke, log in with
  Barry-entered credentials, push an immutable tag, capture digest, prepare a
  Mark-ready return note, and report back in one pass unless a real blocker or
  unsafe ambiguity appears.

## In Scope

- Create this Goal 042 packet and concise task-pack report.
- Replace `docs/ops/stochastic/inbox/current-task.md` with the Goal 042 task.
- Update `docs/ops/stochastic/README.md` to make the report-branch convention
  explicit.
- Replace `docs/ops/stochastic/outbox/current-report.md` with a Goal
  042-specific report template.
- Add `docs/ops/stochastic/outbox/evidence/goal042/README.md`.
- Run validation, targeted searches, scans, and manual review.

## Out Of Scope For Woodhen

- Contacting or creating `stochastic`.
- Accessing WSL, ITS Gitea, ITS VM/dev server, or external services.
- Logging in, cloning from ITS Gitea, pushing source, creating tokens, creating
  registry/package entries, building images, pushing images, deploying,
  restarting services, or changing VM/service/TLS/DNS/Docker state.
- App/package/Shiny UI/server/CSS behavior, science/YAML/model defaults,
  tests, dependencies, Practical 2 implementation, KPZ314 material, assessment
  design, Moodle/student-facing release state, PRs, commits, pushes, or Goal
  043 work.

## Deliverables

- `docs/goals/042-its-gitea-dev-image-publication-via-stochastic/Goal.md`
- `docs/goals/042-its-gitea-dev-image-publication-via-stochastic/Plan.md`
- `docs/goals/042-its-gitea-dev-image-publication-via-stochastic/Runbook.md`
- `docs/goals/042-its-gitea-dev-image-publication-via-stochastic/Log.md`
- `docs/goals/042-its-gitea-dev-image-publication-via-stochastic/task-pack-report.md`
- Updated `docs/ops/stochastic/README.md`
- Updated `docs/ops/stochastic/inbox/current-task.md`
- Updated `docs/ops/stochastic/outbox/current-report.md`
- New `docs/ops/stochastic/outbox/evidence/goal042/README.md`

## Validation

- `git diff --check`
- Ruby YAML parse for
  `deploy/shinyproxy/practical1/application.its-staging.example.yml`
- `bash -n deploy/shinyproxy/practical1/validate-scaffold.sh`
- `bash deploy/shinyproxy/practical1/validate-scaffold.sh`
- `Rscript -e 'renv::status(sources = FALSE)'`
- Targeted stale app-id search
- Search proving the current task forbids `main` push, source push to ITS
  Gitea, and dev-server compose/restart
- Marker scan
- Secret/private-key/token scan over changed text
- Manual review that the task is autonomous enough for one useful pass and
  bounded enough to avoid live infrastructure or credential mistakes

## Completion

Leave the result uncommitted for orchestrator review and wake the rPVA
orchestrator with branch/status, changed files, key task choices, validation,
and an accept/revise recommendation.
