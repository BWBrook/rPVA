# Runbook

Start from the Goal 017 branch:

```sh
cd /Users/bwbrook/.codex/worktrees/a4af/rPVA
git status --short --branch
git branch --show-current
git log -1 --oneline --decorate
```

Read required context:

```sh
sed -n '1,260p' docs/codex/thread-handoff-2026-06-04.md
sed -n '1,240p' docs/teaching/shiny/README.md
sed -n '1,280p' docs/teaching/shiny/deep-server-hosting-feasibility.md
sed -n '1,300p' docs/teaching/shiny/platform-options-decision-matrix.md
sed -n '1,260p' docs/teaching/shiny/implementation-roadmap.md
sed -n '1,260p' docs/teaching/shiny/road-test-operations-plan.md
sed -n '1,260p' docs/teaching/shiny/student-workspace-and-export-design.md
```

Read recent goal packets:

```sh
for f in \
  docs/goals/012-deep-server-shiny-platform-feasibility/Goal.md \
  docs/goals/012-deep-server-shiny-platform-feasibility/Plan.md \
  docs/goals/012-deep-server-shiny-platform-feasibility/Runbook.md \
  docs/goals/012-deep-server-shiny-platform-feasibility/Log.md \
  docs/goals/015-practical-1-shiny-mvp-scaffold/Goal.md \
  docs/goals/015-practical-1-shiny-mvp-scaffold/Log.md \
  docs/goals/016-practical-1-shiny-interaction-qa/Goal.md \
  docs/goals/016-practical-1-shiny-interaction-qa/Log.md \
  docs/goals/016-practical-1-shiny-interaction-qa/qa-report.md
do
  printf '\n### %s\n' "$f"
  sed -n '1,220p' "$f"
done
```

Read app surfaces only for context:

```sh
sed -n '1,180p' R/shiny_practical1.R
sed -n '1,180p' inst/shiny/practical1/README.md
sed -n '1,380p' inst/shiny/practical1/app.R
sed -n '1,220p' tests/testthat/test-13_practical1_shiny.R
```

Read Nectar control-plane docs before remote-routing decisions:

```sh
sed -n '1,220p' /Users/bwbrook/work/nectar/docs/workflows/control-plane-doctrine.md
sed -n '1,220p' /Users/bwbrook/work/nectar/docs/workflows/compute-resource-selection.md
sed -n '1,220p' /Users/bwbrook/work/nectar/docs/workflows/project-integration.md
sed -n '1,220p' /Users/bwbrook/work/nectar/docs/workflows/data-placement.md
sed -n '1,220p' /Users/bwbrook/work/nectar/docs/exchange/current_status.md
```

Allowed read-only probes:

```sh
curl -k --max-time 10 https://100.96.185.60/_gateway-health
curl -k --max-time 10 https://131.217.90.193/_gateway-health
ssh -o BatchMode=yes -o ConnectTimeout=10 deep-server-ts '
  printf "hostname="; hostname
  printf "nproc="; nproc
  free -h | sed -n "1,2p"
  df -h / /data 2>/dev/null || df -h /
  printf "docker="; docker --version 2>&1
  docker info --format "docker_server={{.ServerVersion}} cgroup={{.CgroupVersion}} cpus={{.NCPU}} mem={{.MemTotal}} root={{.DockerRootDir}} containers={{.Containers}} running={{.ContainersRunning}}" 2>&1
  printf "R="; R --version 2>&1 | sed -n "1p"
  printf "java="; java -version 2>&1 | sed -n "1p"
  printf "listeners\n"
  ss -ltn | sed -n "1,80p"
'
```

If a probe fails, record the exact failure once and continue with a blocker
note. Do not retry in a loop.

Validation:

```sh
git diff --check
git status --short --branch
```

Docs-only work does not require R tests. If executable R/Shiny code changes,
run:

```sh
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R")'
```

Hard stop boundaries:

- no ShinyProxy installation or configuration;
- no nginx, systemd, firewall, DNS, TLS, Docker service, or external-access
  changes;
- no package installs;
- no app/package/scenario/test changes unless explicitly authorized;
- no commit or push;
- no student-facing exposure.
