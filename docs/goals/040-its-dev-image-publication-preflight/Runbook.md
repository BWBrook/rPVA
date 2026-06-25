# Runbook

## Start Guard

```sh
cd /Users/bwbrook/git/rPVA
pwd
git branch --show-current
git rev-parse HEAD
git status --short --branch
```

Expected working branch:

```text
codex/rpva-goal040-its-dev-image-preflight
```

## Handoff Update

Update only the current ITS deploy/handoff surfaces:

- `deploy/shinyproxy/practical1/README.md`
- `deploy/shinyproxy/practical1/application.its-staging.example.yml`
- `deploy/shinyproxy/practical1/gitea-registry-runbook.md`
- `deploy/shinyproxy/practical1/its-vm-handoff.md`
- `deploy/shinyproxy/practical1/staging-gate-checklist.md`
- `deploy/shinyproxy/practical1/wsl-image-push-runbook.md`
- `docs/teaching/shiny/README.md`

Use the confirmed registry image path:

```text
git.its.utas.edu.au/UTAS/kpz308-rpva-practical:<TAG>
```

Use the confirmed Docker network:

```text
shinyproxy-net
```

Keep unknown live values as angle-bracket stand-ins, especially the service
user home, auth groups, and approved secret source references.

## Bundle

Create the sendable bundle from reviewed repo files only:

```sh
rm -rf /tmp/rpva-goal040-its-dev-image-preflight
mkdir -p /tmp/rpva-goal040-its-dev-image-preflight
cp docs/goals/040-its-dev-image-publication-preflight/README-send-to-ITS.md /tmp/rpva-goal040-its-dev-image-preflight/
cp docs/goals/040-its-dev-image-publication-preflight/mark-dev-image-message-draft.md /tmp/rpva-goal040-its-dev-image-preflight/
cp deploy/shinyproxy/practical1/its-vm-handoff.md /tmp/rpva-goal040-its-dev-image-preflight/
cp deploy/shinyproxy/practical1/gitea-registry-runbook.md /tmp/rpva-goal040-its-dev-image-preflight/
cp deploy/shinyproxy/practical1/wsl-image-push-runbook.md /tmp/rpva-goal040-its-dev-image-preflight/
cp deploy/shinyproxy/practical1/application.its-staging.example.yml /tmp/rpva-goal040-its-dev-image-preflight/
cd /tmp/rpva-goal040-its-dev-image-preflight
shasum -a 256 README-send-to-ITS.md mark-dev-image-message-draft.md its-vm-handoff.md gitea-registry-runbook.md wsl-image-push-runbook.md application.its-staging.example.yml > SHA256SUMS.txt
```

Mirror the same sendable subset into:

```text
/Users/bwbrook/Library/CloudStorage/OneDrive-UniversityofTasmania/EXCHANGE/rPVA/goal040-its-dev-image-preflight-2026-06-25/
```

## Validation

```sh
git diff --check
ruby -e 'require "yaml"; YAML.load_file("deploy/shinyproxy/practical1/application.its-staging.example.yml"); puts "YAML OK"'
bash -n deploy/shinyproxy/practical1/validate-scaffold.sh
bash deploy/shinyproxy/practical1/validate-scaffold.sh
Rscript -e 'renv::status(sources = FALSE)'
```

Run targeted searches over the current sendable/operator surfaces and the
generated bundle:

- no old registry stand-ins in current sendable/operator surfaces;
- no `kpz308-rpva-practical1` app id in current sendable/operator surfaces;
- no goal/workflow scaffolding language in the sendable bundle;
- no real secrets, tokens, private keys, or student identifiers.

## Stop Rules

Stop and wake the orchestrator if the repo state changes unexpectedly, a check
fails, live credentials are needed, a build would require external login or
push, or the task would need deployment/service state changes.
