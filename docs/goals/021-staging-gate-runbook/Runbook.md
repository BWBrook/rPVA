# Runbook

Start in the linked Codex worktree:

```sh
cd /Users/bwbrook/.codex/worktrees/a4af/rPVA
pwd
git branch --show-current
git log -1 --oneline --decorate
git status --short --branch
```

Confirm the base:

```sh
git fetch --prune origin
git rev-parse origin/main
git log -1 --oneline --decorate origin/main
```

Create the branch:

```sh
git branch --list codex/rpva-goal021-staging-gate-runbook
git branch --remotes --list 'origin/codex/rpva-goal021-staging-gate-runbook'
git switch -c codex/rpva-goal021-staging-gate-runbook origin/main
```

Read context:

```sh
test -f AGENTS.md && sed -n '1,220p' AGENTS.md || true
sed -n '1,260p' docs/codex/thread-handoff-2026-06-04.md
for f in \
  docs/teaching/shiny/README.md \
  docs/teaching/shiny/deep-server-hosting-feasibility.md \
  docs/teaching/shiny/platform-options-decision-matrix.md \
  docs/teaching/shiny/implementation-roadmap.md \
  docs/teaching/shiny/road-test-operations-plan.md \
  docs/teaching/shiny/student-workspace-and-export-design.md \
  docs/goals/017-practical-1-shiny-deployment-readiness/Goal.md \
  docs/goals/017-practical-1-shiny-deployment-readiness/Plan.md \
  docs/goals/017-practical-1-shiny-deployment-readiness/Runbook.md \
  docs/goals/017-practical-1-shiny-deployment-readiness/Log.md \
  docs/goals/018-practical-1-shiny-deployment-scaffold/Goal.md \
  docs/goals/018-practical-1-shiny-deployment-scaffold/Plan.md \
  docs/goals/018-practical-1-shiny-deployment-scaffold/Runbook.md \
  docs/goals/018-practical-1-shiny-deployment-scaffold/Log.md \
  docs/goals/019-practical-1-local-deployment-preflight/Goal.md \
  docs/goals/019-practical-1-local-deployment-preflight/Plan.md \
  docs/goals/019-practical-1-local-deployment-preflight/Runbook.md \
  docs/goals/019-practical-1-local-deployment-preflight/Log.md \
  docs/goals/020-deep-server-image-preflight/Goal.md \
  docs/goals/020-deep-server-image-preflight/Plan.md \
  docs/goals/020-deep-server-image-preflight/Runbook.md \
  docs/goals/020-deep-server-image-preflight/Log.md \
  deploy/shinyproxy/practical1/README.md \
  deploy/shinyproxy/practical1/Dockerfile.template \
  deploy/shinyproxy/practical1/application.example.yml \
  deploy/shinyproxy/practical1/nginx-practical1.example.conf \
  deploy/shinyproxy/practical1/validate-scaffold.sh
do
  printf '\n### %s\n' "$f"
  sed -n '1,260p' "$f"
done
```

Allowed read-only probes:

```sh
curl -k --max-time 10 https://100.96.185.60/_gateway-health
curl -k --max-time 10 https://131.217.90.193/_gateway-health
ssh deep-server-ts '
  hostname
  uname -m
  docker --version
  docker image inspect rpva-practical1:goal020-6ed2445 \
    --format "ID={{.Id}} Size={{.Size}} Created={{.Created}}"
  docker image ls rpva-practical1:goal020-6ed2445
  docker ps --filter name=rpva-goal020-6ed2445 \
    --format "{{.ID}} {{.Names}} {{.Status}}"
  docker ps -a --filter name=rpva-goal020-6ed2445 \
    --format "{{.ID}} {{.Names}} {{.Status}}"
'
```

If a read-only route probe fails, record the exact failure once and preserve it
as a gate. Do not retry in a loop.

Future staging approval handoff checklist:

```text
Barry/SRF approval names:
- staging source commit or image tag;
- service owner and reviewer;
- app path and hostname;
- TLS/DNS owner;
- identity model;
- workspace root and retention policy;
- route-test sources;
- rollback owner;
- cleanup owner;
- explicit stop rule before student URL release.
```

Validation:

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
rg -n -i "(password|token|secret|credential|private key|api[_-]?key)" \
  docs/goals/021-staging-gate-runbook \
  deploy/shinyproxy/practical1/staging-gate-checklist.md \
  docs/teaching/shiny/README.md \
  docs/teaching/shiny/implementation-roadmap.md
git status --short --branch
```

Review all secret-pattern hits manually. Policy wording and inert template
terms are acceptable; real-looking sensitive values are not.

Do not run R tests for docs-only work. If executable R/Shiny code changes, run
the focused Practical 1 Shiny tests and explain why the code edit was needed.

Hard stops:

- no ShinyProxy installation or configuration;
- no nginx, systemd, firewall, DNS, TLS, Docker daemon/service, account,
  credential, class workspace, external-access, or public/student-facing
  changes;
- no Docker build;
- no Docker container launch;
- no host package installs;
- no app/R/package/scenario/test changes unless explicitly authorized;
- no commit or push.
