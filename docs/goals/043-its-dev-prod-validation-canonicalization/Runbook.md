# Runbook

## Read-Only Evidence Review

```sh
git fetch --prune origin
git rev-parse origin/main
git rev-parse origin/codex/rpva-stochastic-goal042-image-publication
git show origin/codex/rpva-stochastic-goal042-image-publication:docs/ops/stochastic/outbox/current-report.md
git show origin/codex/rpva-stochastic-goal042-image-publication:docs/ops/stochastic/outbox/evidence/goal042/its-dev-prod-validation-report.md
git diff origin/main..origin/codex/rpva-stochastic-goal042-image-publication -- deploy/shinyproxy/practical1/Dockerfile.template
```

Do not merge the `stochastic` branch wholesale.

## Validation

```sh
git diff --check
ruby -e 'require "yaml"; YAML.load_file("deploy/shinyproxy/practical1/application.its-staging.example.yml"); puts "YAML OK"'
bash -n deploy/shinyproxy/practical1/validate-scaffold.sh
bash deploy/shinyproxy/practical1/validate-scaffold.sh
Rscript -e 'renv::status(sources = FALSE)'
```

Then run targeted text searches for Docker image namespace, source repository
namespace, historical uppercase image references, markers, and
secret/private-key/token/student-identifier terms.

## Stop Rules

Stop and report if:

- `origin/main` has advanced unexpectedly from the accepted Goal 042 base;
- the worktree is dirty before Goal 043 work starts;
- report-branch evidence contradicts the orchestrator-supplied facts;
- validation fails;
- a needed check requires live credentials, WSL, ITS Gitea, Docker registry,
  ITS host access, or any live service change.
