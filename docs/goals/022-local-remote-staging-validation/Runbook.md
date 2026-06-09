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
git branch --list codex/rpva-goal022-local-remote-staging-validation
git branch --remotes --list 'origin/codex/rpva-goal022-local-remote-staging-validation'
git switch -c codex/rpva-goal022-local-remote-staging-validation origin/main
```

Read context:

```sh
for f in \
  docs/codex/thread-handoff-2026-06-04.md \
  docs/teaching/shiny/README.md \
  docs/teaching/shiny/implementation-roadmap.md \
  docs/teaching/shiny/deep-server-hosting-feasibility.md \
  docs/teaching/shiny/platform-options-decision-matrix.md \
  docs/teaching/shiny/road-test-operations-plan.md \
  docs/teaching/shiny/student-workspace-and-export-design.md \
  docs/goals/020-deep-server-image-preflight/Goal.md \
  docs/goals/020-deep-server-image-preflight/Plan.md \
  docs/goals/020-deep-server-image-preflight/Runbook.md \
  docs/goals/020-deep-server-image-preflight/Log.md \
  docs/goals/021-staging-gate-runbook/Goal.md \
  docs/goals/021-staging-gate-runbook/Plan.md \
  docs/goals/021-staging-gate-runbook/Runbook.md \
  docs/goals/021-staging-gate-runbook/Log.md \
  deploy/shinyproxy/practical1/README.md \
  deploy/shinyproxy/practical1/Dockerfile.template \
  deploy/shinyproxy/practical1/application.example.yml \
  deploy/shinyproxy/practical1/nginx-practical1.example.conf \
  deploy/shinyproxy/practical1/staging-gate-checklist.md
do
  printf '\n### %s\n' "$f"
  sed -n '1,260p' "$f"
done
```

Read Nectar routing/placement context:

```sh
for f in \
  /Users/bwbrook/work/nectar/docs/workflows/control-plane-doctrine.md \
  /Users/bwbrook/work/nectar/docs/workflows/compute-resource-selection.md \
  /Users/bwbrook/work/nectar/docs/workflows/project-integration.md \
  /Users/bwbrook/work/nectar/docs/workflows/data-placement.md \
  /Users/bwbrook/work/nectar/docs/exchange/current_status.md
do
  test -f "$f" && sed -n '1,260p' "$f"
done
```

Inspect CI failures:

```sh
gh run view 27050337437 --repo BWBrook/rPVA \
  --json databaseId,displayTitle,headSha,headBranch,conclusion,status,url,jobs
gh run view 27050337437 --repo BWBrook/rPVA --log
gh run view 27050148750 --repo BWBrook/rPVA \
  --json databaseId,displayTitle,headSha,headBranch,conclusion,status,url,jobs
```

Run CI-equivalent local verification after any workflow/bootstrap fix:

```sh
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); print(run_scenarios("woodhen", csv_out = NULL, rds_out = NULL, keep_traj = FALSE, parallel = FALSE))'
```

Run one bounded local Shiny smoke:

```sh
PORT=3892
LOG=/tmp/rpva-goal022-local-shiny.log
HTML=/tmp/rpva-goal022-local-shiny.html
Rscript -e 'source("bootstrap.R"); run_practical1_shiny(host = "127.0.0.1", port = 3892, launch.browser = FALSE)' >"$LOG" 2>&1 &
PID=$!
curl --fail --silent --show-error --max-time 5 "http://127.0.0.1:${PORT}/" >"$HTML"
kill "$PID"
lsof -nP -iTCP:${PORT} -sTCP:LISTEN || true
```

Use a guarded loop in real execution so the process is stopped even if the
curl fails.

Run read-only remote discovery:

```sh
curl -k --max-time 10 https://100.96.185.60/_gateway-health
curl -k --max-time 10 https://131.217.90.193/_gateway-health

ssh deep-server-ts '
  hostname
  uname -m
  docker --version
  docker info --format "ServerVersion={{.ServerVersion}} Architecture={{.Architecture}} NCPU={{.NCPU}} MemTotal={{.MemTotal}} DockerRootDir={{.DockerRootDir}}"
  docker image ls "rpva-practical1" --format "{{.Repository}}:{{.Tag}} {{.ID}} {{.Size}} {{.CreatedSince}}"
  docker image inspect "rpva-practical1:goal020-6ed2445" --format "ID={{.Id}} Size={{.Size}} Created={{.Created}}"
  docker ps -a --filter name=rpva --format "{{.ID}} {{.Names}} {{.Image}} {{.Status}} {{.Ports}}"
  command -v shinyproxy || true
  systemctl status shinyproxy --no-pager || true
  ls -ld /etc/shinyproxy /opt/shinyproxy /var/log/shinyproxy 2>&1 || true
  command -v nginx || true
  systemctl is-active nginx || true
  sudo -n nginx -t
  sudo -n nginx -T 2>&1 | grep -E "^# configuration file|listen |server_name|location |proxy_pass|_gateway-health|3838|shiny|rpva|map \\\\$http_upgrade|upstream"
  ss -ltnp 2>/dev/null | sed -n "1,120p"
'
```

Stop Track B if ShinyProxy is absent or the conditional service-change rule is
not satisfied. Do not create the staging workspace, launch a container, edit
nginx, or reload services in that case.

Validation:

```sh
git status --short --branch
git diff --check
rg -n "$(printf '%s|%s|%s' 'TO''DO' 'T''BD' 'PLACE''HOLDER')" \
  .github/workflows/r-ci.yaml \
  docs/goals/022-local-remote-staging-validation \
  docs/teaching/shiny/README.md \
  docs/teaching/shiny/implementation-roadmap.md
bash -n deploy/shinyproxy/practical1/validate-scaffold.sh
bash deploy/shinyproxy/practical1/validate-scaffold.sh
ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0)); puts "ruby yaml parse ok"' \
  deploy/shinyproxy/practical1/application.example.yml
rg -n -i "(password|token|secret|credential|private key|api[_-]?key)" \
  .github/workflows/r-ci.yaml \
  docs/goals/022-local-remote-staging-validation \
  docs/teaching/shiny/README.md \
  docs/teaching/shiny/implementation-roadmap.md
git status --short --branch
```

Review secret-scan hits manually. Policy wording and inert template terms are
acceptable; real sensitive values are not.
