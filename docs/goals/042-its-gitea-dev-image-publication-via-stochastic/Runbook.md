# Runbook

## Start Guard

```sh
cd /Users/bwbrook/git/rPVA
git fetch --prune origin
git status --short --branch
git rev-parse origin/main
git log -1 --oneline origin/main
git switch -c codex/rpva-goal042-stochastic-image-publication-task origin/main
```

Stop if the working tree is dirty or `origin/main` has unexpected unrelated
changes.

## Update Files

Edit only:

```text
docs/goals/042-its-gitea-dev-image-publication-via-stochastic/
docs/ops/stochastic/README.md
docs/ops/stochastic/inbox/current-task.md
docs/ops/stochastic/outbox/current-report.md
docs/ops/stochastic/outbox/evidence/goal042/README.md
```

Do not edit app/package/deployment source or live infrastructure surfaces.

## Validation

```sh
git diff --check
ruby -e 'require "yaml"; YAML.load_file("deploy/shinyproxy/practical1/application.its-staging.example.yml"); puts "YAML OK"'
bash -n deploy/shinyproxy/practical1/validate-scaffold.sh
bash deploy/shinyproxy/practical1/validate-scaffold.sh
Rscript -e 'renv::status(sources = FALSE)'
```

Run targeted searches:

- no stale `kpz308-rpva-practical1` app id in current touched
  sendable/operator surfaces;
- `docs/ops/stochastic/inbox/current-task.md` forbids `main` push;
- current task forbids ITS Gitea source push;
- current task forbids dev-server compose/restart;
- no marker text;
- no secret, private key, token, credential value, or sensitive payload.

## Wake-Up

Send a wake-up to the rPVA orchestrator with branch/status, changed files, key
task choices, validation, residual questions, and accept/revise
recommendation.
