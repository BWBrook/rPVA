# Runbook

## Start Guard

```sh
cd /Users/bwbrook/git/rPVA
pwd
git fetch --prune origin
git status --short --branch
git switch -c codex/rpva-goal041-stochastic-wsl-worker-bootstrap origin/main
```

Stop if the working tree is dirty or `origin/main` is not the intended base.

## Files To Create

```text
docs/ops/stochastic/README.md
docs/ops/stochastic/priming-prompt.md
docs/ops/stochastic/inbox/current-task.md
docs/ops/stochastic/outbox/current-report.md
docs/ops/stochastic/outbox/evidence/README.md
docs/goals/041-stochastic-wsl-worker-bootstrap/bootstrap-report.md
```

## Validation

```sh
git diff --check
Rscript -e 'renv::status(sources = FALSE)'
```

Run targeted searches over changed text:

- no real credential, token, private-key, or student identifier values;
- no hard-coded private paths beyond repo-local paths;
- no accidental authorization in the bootstrap task to build, push, deploy,
  restart, create tokens, change registry state, or change live services;
- priming prompt is paste-ready and orientation-only.

## Wake-Up

When complete or blocked, send a short wake-up to the rPVA orchestrator thread
with branch/status, changed files, validation, boundary notes, and
accept/revise recommendation.
