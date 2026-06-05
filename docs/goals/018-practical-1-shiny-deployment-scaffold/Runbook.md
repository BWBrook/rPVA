# Runbook

Start from the linked Codex worktree:

```sh
cd /Users/bwbrook/.codex/worktrees/a4af/rPVA
pwd
git branch --show-current
git log -1 --oneline --decorate
git status --short --branch
```

Confirm the Goal 017 base:

```sh
git fetch --prune origin
git rev-parse codex/rpva-goal017-deployment-readiness
git rev-parse origin/codex/rpva-goal017-deployment-readiness
git log -1 --oneline --decorate origin/codex/rpva-goal017-deployment-readiness
```

Create the Goal 018 branch only if it does not already exist:

```sh
git branch --list codex/rpva-goal018-deployment-scaffold
git branch --remotes --list 'origin/codex/rpva-goal018-deployment-scaffold'
git switch -c codex/rpva-goal018-deployment-scaffold
```

Read context:

```sh
for f in \
  docs/goals/017-practical-1-shiny-deployment-readiness/Goal.md \
  docs/goals/017-practical-1-shiny-deployment-readiness/Plan.md \
  docs/goals/017-practical-1-shiny-deployment-readiness/Runbook.md \
  docs/goals/017-practical-1-shiny-deployment-readiness/Log.md \
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

Read app surfaces for context only:

```sh
sed -n '1,220p' R/shiny_practical1.R
sed -n '1,180p' inst/shiny/practical1/README.md
sed -n '1,380p' inst/shiny/practical1/app.R
sed -n '1,240p' tests/testthat/test-13_practical1_shiny.R
```

Inspect for existing deployment scaffold:

```sh
rg --files | rg '(^|/)(Dockerfile|dockerfile|shinyproxy|application.*yml|nginx|deploy|deployment)'
```

Validation:

```sh
git diff --check
rg -n "$(printf '%s|%s|%s' 'TO''DO' 'T''BD' 'PLACE''HOLDER')" \
  docs/goals/018-practical-1-shiny-deployment-scaffold \
  deploy/shinyproxy/practical1 \
  docs/teaching/shiny/README.md \
  docs/teaching/shiny/implementation-roadmap.md
bash -n deploy/shinyproxy/practical1/validate-scaffold.sh
bash deploy/shinyproxy/practical1/validate-scaffold.sh
git status --short --branch
```

If the marker scan hits intentional angle-bracket template values, record why
they are safe. Prefer avoiding the uppercase marker words in the templates.

Do not run Docker builds, Docker pulls, ShinyProxy commands, nginx commands,
remote writes, package installs, R tests, commits, or pushes for this
docs/templates-only goal.
