# Runbook

## Contract

Read `Goal.md` first. This runbook orders the work; it does not authorize
broadening beyond Goal 025.

## Start

From `/Users/bwbrook/git/rPVA`:

```sh
pwd
git branch --show-current
git rev-parse --short HEAD
git status --short --branch
test -f AGENTS.md && sed -n '1,180p' AGENTS.md || true
```

Expected branch:

```text
codex/rpva-goal025-nonstudent-staging
```

Expected start commit:

```text
5c9d500
```

If branch or status is unexpected, record it in `Log.md` and pause if unrelated
modifications are present.

## Read Context

Read the files listed in `Goal.md`, especially:

```text
docs/goals/021-staging-gate-runbook/Goal.md
docs/goals/021-staging-gate-runbook/Runbook.md
docs/goals/022-local-remote-staging-validation/Goal.md
docs/goals/022-local-remote-staging-validation/Log.md
docs/goals/024-practical-1-classroom-dry-run-fallback/dry-run-report.md
docs/teaching/shiny/deep-server-hosting-feasibility.md
docs/teaching/shiny/road-test-operations-plan.md
deploy/shinyproxy/practical1/README.md
deploy/shinyproxy/practical1/Dockerfile.template
deploy/shinyproxy/practical1/application.example.yml
deploy/shinyproxy/practical1/nginx-practical1.example.conf
deploy/shinyproxy/practical1/staging-gate-checklist.md
```

## Local Preflight

Run:

```sh
git fetch --prune origin
git rev-parse HEAD origin/main
git status --short --branch
bash deploy/shinyproxy/practical1/validate-scaffold.sh
Rscript -e 'renv::status(sources = FALSE)'
```

## Remote Preflight

Use short, bounded probes. Do not loop on failures.

```sh
curl -k --max-time 10 https://100.96.185.60/_gateway-health || true
curl -k --max-time 10 https://131.217.90.193/_gateway-health || true
ssh deep-server-ts '
  set -eu
  hostname
  date -Is
  uname -m
  whoami
  sudo -n true && echo sudo_ok
  docker --version || true
  docker info --format "ServerVersion={{.ServerVersion}} Architecture={{.Architecture}} NCPU={{.NCPU}} MemTotal={{.MemTotal}} DockerRootDir={{.DockerRootDir}}" || true
  java -version 2>&1 | head -3 || true
  systemctl is-active nginx || true
  command -v nginx || true
  sudo -n nginx -t || true
  ss -ltnp 2>/dev/null | sed -n "1,80p"
  command -v shinyproxy || true
  systemctl status shinyproxy --no-pager || true
  test -d /etc/shinyproxy && find /etc/shinyproxy -maxdepth 2 -type f -print || true
  test -d /opt/shinyproxy && find /opt/shinyproxy -maxdepth 2 -type f -print || true
  docker image ls "rpva-practical1*" || true
  df -h / /data 2>/dev/null || df -h
  find /data/codex -maxdepth 3 -type d 2>/dev/null | sed -n "1,80p"
'
```

Record the preflight before changing remote state.

## Source Staging

Goal-specific paths are preferred, for example:

```text
/data/codex/repos/rPVA-goal025
/data/codex/teaching/rpva-2026/staging
```

If remote GitHub access works, clone/fetch `5c9d500` there. If not, use a
trusted local archive, Git bundle, or `rsync` from the Mac mini checkout.

Do not leave divergent remote source edits. The source must match `5c9d500`.

## Image Build

Use a goal-specific tag such as:

```text
rpva-practical1:goal025-5c9d500
```

Build from the reviewed Dockerfile template or an approved copied build file in
the remote goal-specific workspace.

Capture:

- source commit;
- image tag;
- image ID;
- image creation time;
- image size;
- build command class;
- any warnings.

If build fails because of missing host prerequisites, record the exact blocker
and stop unless the fix is narrow and explicitly in scope.

## ShinyProxy Bootstrap

If ShinyProxy is absent:

- install a pinned ShinyProxy release under a standard root such as
  `/opt/shinyproxy`;
- record version and download/source URL;
- record checksum if available or compute SHA256 of the downloaded artifact;
- create `/etc/shinyproxy/application.yml` from a reviewed, concrete config;
- create a systemd service if needed;
- keep bind address localhost-only.

If ShinyProxy is already present:

- back up the existing config before edits;
- avoid overwriting unrelated apps;
- update only what is needed for Practical 1 staging.

Credential handling:

- create one non-student staging user;
- do not print the generated secret;
- store secret material only in an appropriate non-git remote path;
- set restrictive permissions;
- use the secret for browser smoke without logging it.

## nginx Gateway

Prefer no nginx edit by aligning ShinyProxy with the existing upstream:

```text
127.0.0.1:3838
```

If a small nginx route alignment is required:

```sh
ssh deep-server-ts 'sudo -n cp <live-config> <backup-with-goal025-date>'
ssh deep-server-ts 'sudo -n nginx -t'
ssh deep-server-ts 'sudo -n systemctl reload nginx'
```

Only reload after syntax validation passes. Record exact rollback commands.
Do not change firewall, DNS, or TLS certificates.

## Service Validation

At minimum, record:

```sh
ssh deep-server-ts 'systemctl is-active shinyproxy; systemctl status shinyproxy --no-pager | sed -n "1,80p"'
ssh deep-server-ts 'ss -ltnp | grep 3838 || true'
ssh deep-server-ts 'curl -fsS --max-time 10 http://127.0.0.1:3838/ | head -40'
curl -k --max-time 15 https://100.96.185.60/ | head -40
curl -k --max-time 15 https://131.217.90.193/ | head -40 || true
```

Use authenticated browser automation for app proof. Prefer Chrome if available.
If Chrome is not available, record the blocker and use in-app Browser or
Playwright/Chromium.

Browser path:

1. open the gateway URL;
2. authenticate with the non-student staging identity;
3. open Practical 1 app;
4. start baseline;
5. run at least one non-baseline stage;
6. open Compare;
7. download comparison CSV and evidence-notes Markdown;
8. open Transfer;
9. capture screenshots under `/tmp`;
10. log out or close the session if practical.

## Final Remote Posture

If browser smoke passes:

- leave ShinyProxy running and authenticated;
- record service status;
- record app URL/path;
- record credential storage path and permissions, not the secret value;
- record rollback and cleanup commands.

If smoke fails:

- stop and disable ShinyProxy unless keeping it running is safer for diagnosis;
- remove or rotate the staging credential if no service is left running;
- record the blocker and final listener/service state.

## Local Validation

Run:

```sh
git status --short --branch
git diff --check
bash -n deploy/shinyproxy/practical1/validate-scaffold.sh
bash deploy/shinyproxy/practical1/validate-scaffold.sh
ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0)); puts "ruby yaml parse ok"' deploy/shinyproxy/practical1/application.example.yml
Rscript -e 'renv::status(sources = FALSE)'
```

If package/app/deploy-template behaviour changed, run focused tests:

```sh
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
```

Marker scan:

```sh
{ git diff --name-only --diff-filter=ACMRTUXB; git ls-files --others --exclude-standard; } | \
  sort -u | xargs rg -n "$(printf '%s|%s|%s' 'TO''DO' 'T''BD' 'PLACE''HOLDER')" || true
```

Secret scan:

```sh
{ git diff --name-only --diff-filter=ACMRTUXB; git ls-files --others --exclude-standard; } | \
  sort -u | xargs rg -n -i "(api[_-]?key|secret|password|passwd|token|credential|private[ _-]?key|BEGIN RSA|BEGIN OPENSSH|BEGIN PRIVATE|client_secret|access_token|refresh_token)" || true
```

Review all hits manually. Policy wording is acceptable; real values are not.

## Final Report

Create `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/staging-report.md`
and update `Log.md`.

Include:

- branch/start state;
- live preflight;
- source/image path and tag;
- ShinyProxy version/install/config summary;
- nginx/gateway summary;
- secret handling summary without secret values;
- route/browser evidence;
- final remote service posture;
- rollback/cleanup instructions;
- changed files;
- validation outcomes;
- residual risks;
- next recommended action.
