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
git branch --list codex/rpva-goal019-local-deployment-preflight
git branch --remotes --list 'origin/codex/rpva-goal019-local-deployment-preflight'
git switch -c codex/rpva-goal019-local-deployment-preflight origin/main
```

Read context:

```sh
for f in \
  docs/goals/018-practical-1-shiny-deployment-scaffold/Goal.md \
  docs/goals/018-practical-1-shiny-deployment-scaffold/Plan.md \
  docs/goals/018-practical-1-shiny-deployment-scaffold/Runbook.md \
  docs/goals/018-practical-1-shiny-deployment-scaffold/Log.md \
  deploy/shinyproxy/practical1/README.md \
  deploy/shinyproxy/practical1/Dockerfile.template \
  deploy/shinyproxy/practical1/application.example.yml \
  deploy/shinyproxy/practical1/nginx-practical1.example.conf \
  deploy/shinyproxy/practical1/validate-scaffold.sh \
  docs/teaching/shiny/README.md \
  docs/teaching/shiny/implementation-roadmap.md \
  docs/teaching/shiny/deep-server-hosting-feasibility.md \
  docs/teaching/shiny/platform-options-decision-matrix.md \
  docs/teaching/shiny/road-test-operations-plan.md \
  docs/teaching/shiny/student-workspace-and-export-design.md
do
  printf '\n### %s\n' "$f"
  sed -n '1,260p' "$f"
done
```

Read app context only:

```sh
sed -n '1,220p' R/shiny_practical1.R
sed -n '1,180p' inst/shiny/practical1/README.md
sed -n '1,380p' inst/shiny/practical1/app.R
sed -n '1,240p' tests/testthat/test-13_practical1_shiny.R
```

Inspect Docker availability:

```sh
docker info
```

Run validation:

```sh
git diff --check
rg -n "$(printf '%s|%s|%s' 'TO''DO' 'T''BD' 'PLACE''HOLDER')" \
  docs/goals/019-practical-1-local-deployment-preflight \
  deploy/shinyproxy/practical1 \
  docs/teaching/shiny/README.md \
  docs/teaching/shiny/implementation-roadmap.md
bash -n deploy/shinyproxy/practical1/validate-scaffold.sh
bash deploy/shinyproxy/practical1/validate-scaffold.sh
ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0)); puts "ruby yaml parse ok"' \
  deploy/shinyproxy/practical1/application.example.yml
git status --short --branch
```

Run a non-placeholder secret scan:

```sh
rg -n -i "(password|token|secret|credential|private key|api[_-]?key)" \
  docs/goals/019-practical-1-local-deployment-preflight \
  deploy/shinyproxy/practical1 \
  docs/teaching/shiny/README.md \
  docs/teaching/shiny/implementation-roadmap.md
```

Review hits manually. Inert placeholder wording is acceptable; real-looking
secrets are not.

Do not run remote writes, service operations, Docker build/pull/run, package
installs, R tests, commits, or pushes unless a later instruction explicitly
widens this goal.
