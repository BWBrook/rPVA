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
git branch --list codex/rpva-goal020-deep-server-image-preflight
git branch --remotes --list 'origin/codex/rpva-goal020-deep-server-image-preflight'
git switch -c codex/rpva-goal020-deep-server-image-preflight origin/main
```

Read context:

```sh
for f in \
  docs/goals/019-practical-1-local-deployment-preflight/Goal.md \
  docs/goals/019-practical-1-local-deployment-preflight/Plan.md \
  docs/goals/019-practical-1-local-deployment-preflight/Runbook.md \
  docs/goals/019-practical-1-local-deployment-preflight/Log.md \
  deploy/shinyproxy/practical1/README.md \
  deploy/shinyproxy/practical1/Dockerfile.template \
  deploy/shinyproxy/practical1/dockerignore.template \
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

Prepare immutable local variables:

```sh
SOURCE_COMMIT=$(git rev-parse origin/main)
SOURCE_SHORT=$(git rev-parse --short origin/main)
REMOTE_WORKSPACE="/data/codex/teaching/rpva-2026/preflight/goal020-${SOURCE_SHORT}"
IMAGE_TAG="rpva-practical1:goal020-${SOURCE_SHORT}"
CONTAINER_NAME="rpva-goal020-${SOURCE_SHORT}"
SMOKE_PORT=3920
```

Create the disposable remote workspace and transfer source:

```sh
ssh deep-server-ts "mkdir -p '$REMOTE_WORKSPACE'"
git archive --format=tar "$SOURCE_COMMIT" | \
  ssh deep-server-ts "cd '$REMOTE_WORKSPACE' && tar -xf -"
ssh deep-server-ts "cd '$REMOTE_WORKSPACE' && \
  cp deploy/shinyproxy/practical1/dockerignore.template .dockerignore && \
  printf '%s\n' '$SOURCE_COMMIT' > SOURCE_COMMIT.txt"
```

Capture remote evidence:

```sh
ssh deep-server-ts "set -eu
hostname
uname -m
docker --version
docker info --format 'ServerVersion={{.ServerVersion}} Architecture={{.Architecture}} NCPU={{.NCPU}} MemTotal={{.MemTotal}} DockerRootDir={{.DockerRootDir}}'
df -h /data
cd '$REMOTE_WORKSPACE'
pwd
cat SOURCE_COMMIT.txt
test -f .dockerignore
"
```

Run one bounded remote image build:

```sh
ssh deep-server-ts "cd '$REMOTE_WORKSPACE' && \
  docker build \
    -f deploy/shinyproxy/practical1/Dockerfile.template \
    --build-arg RPVA_REF='$SOURCE_COMMIT' \
    -t '$IMAGE_TAG' \
    ."
```

If the image builds, inspect it:

```sh
ssh deep-server-ts "docker image inspect '$IMAGE_TAG' \
  --format 'ID={{.Id}} Size={{.Size}} Created={{.Created}}'"
```

If the image builds, run one short local-only smoke:

```sh
ssh deep-server-ts "set -eu
docker rm -f '$CONTAINER_NAME' >/dev/null 2>&1 || true
docker run -d --name '$CONTAINER_NAME' \
  -p 127.0.0.1:${SMOKE_PORT}:3838 \
  '$IMAGE_TAG'
for i in 1 2 3 4 5 6 7 8 9 10; do
  if curl --fail --silent --show-error --max-time 5 \
    'http://127.0.0.1:${SMOKE_PORT}/' >/tmp/rpva-goal020-smoke.html; then
    printf 'local-only smoke ok on attempt %s\n' \"\$i\"
    break
  fi
  sleep 3
done
docker logs --tail 80 '$CONTAINER_NAME'
docker stop '$CONTAINER_NAME' >/dev/null
docker rm '$CONTAINER_NAME' >/dev/null 2>&1 || true
docker ps --filter name='$CONTAINER_NAME' --format '{{.ID}} {{.Names}} {{.Status}}'
"
```

Record whether the image remains:

```sh
ssh deep-server-ts "docker image ls '$IMAGE_TAG'"
```

Run local validation:

```sh
git status --short --branch
git diff --check
rg -n "$(printf '%s|%s|%s' 'TO''DO' 'T''BD' 'PLACE''HOLDER')" \
  docs/goals/020-deep-server-image-preflight
bash -n deploy/shinyproxy/practical1/validate-scaffold.sh
bash deploy/shinyproxy/practical1/validate-scaffold.sh
ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0)); puts "ruby yaml parse ok"' \
  deploy/shinyproxy/practical1/application.example.yml
rg -n -i "(password|token|secret|credential|private key|api[_-]?key)" \
  docs/goals/020-deep-server-image-preflight
git status --short --branch
```

Review all secret-scan hits manually. Inert replacement-value wording is
acceptable; real-looking secrets are not.

Do not run broad R tests for docs/templates-only work. If executable R/Shiny
code changes, run the focused relevant tests and explain why.
