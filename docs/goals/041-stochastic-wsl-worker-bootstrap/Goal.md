# Goal 041: Stochastic WSL Worker Bootstrap

## Objective

Create a repo-local markdown communication scaffold and paste-ready priming
prompt for a future WSL/campus worker named `stochastic`.

This is setup only. It prepares an asynchronous Git/markdown-mediated bridge
for campus/VPN operations without moving the rPVA source-of-truth lane off the
Mac mini.

## Architecture

- Mac mini plus the rPVA orchestrator plus `woodhen` remain the source-of-truth
  project lane.
- `stochastic` will run later on Barry's WSL/campus-connected machine after
  Barry clones the rPVA repo there and starts a separate Codex agent manually.
- The orchestrator cannot use Codex thread tools directly against the WSL
  worker. Communication must happen through repo-local markdown files,
  branches when explicitly authorized, and Barry's manual wake-up/relay.
- `stochastic` is a narrow campus/VPN operations bridge for ITS Gitea/dev-server
  reachability, especially future image build/push, registry proof, and
  dev-server smoke evidence.
- `stochastic` is not a general second developer.

## In Scope

- Create this Goal 041 packet and concise bootstrap report.
- Add `docs/ops/stochastic/` with protocol, inbox, outbox, evidence hygiene,
  and priming-prompt markdown.
- Make Barry's human relay role explicit.
- Add a first bootstrap/orientation-only task for `stochastic`.
- Run patch hygiene, `renv` status, targeted authorization/search checks, and
  secret/private-key/token scans over changed text.

## Out Of Scope

- Contacting, creating, or waking `stochastic`.
- Accessing WSL, ITS Gitea, ITS VM/dev server, or any external service.
- Logging in, cloning from ITS Gitea, pushing source, creating tokens, creating
  registry/package entries, building images, pushing images, deploying,
  restarting services, or changing VM/service/TLS/DNS/Docker state.
- App/package/Shiny UI/server/CSS behavior, science/YAML/model defaults,
  Practical 2 implementation, assessment design, dependencies,
  Moodle/student-facing release state, KPZ314 material, external contact, PRs,
  commits, pushes, or Goal 042 work.

## Deliverables

- `docs/ops/stochastic/README.md`
- `docs/ops/stochastic/priming-prompt.md`
- `docs/ops/stochastic/inbox/current-task.md`
- `docs/ops/stochastic/outbox/current-report.md`
- `docs/ops/stochastic/outbox/evidence/README.md`
- Narrow `.gitignore` exception for `docs/ops/`
- `docs/goals/041-stochastic-wsl-worker-bootstrap/bootstrap-report.md`
- Updated `Log.md`

## Validation

- `git diff --check`
- `Rscript -e 'renv::status(sources = FALSE)'`
- Targeted search showing the bootstrap task does not authorize build, push,
  deploy, restart, source push, registry push, token creation, or live service
  changes
- Marker scan over changed text
- Secret/private-key/token scan over changed text
- Manual review that `priming-prompt.md` is paste-ready and keeps
  `stochastic` in a narrow orientation-only role

## Completion

Leave the result uncommitted for orchestrator review and wake the rPVA
orchestrator with branch/status, changed files, scaffold paths, priming prompt
location, initial task location, validation results, residual questions, and an
accept/revise recommendation.
