# KPZ308 Two-App Production Proof Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish and run distinct KPZ308 Practical 1 and Practical 2 images concurrently on UTAS dev and production ShinyProxy, prove Staff and KPZ308 access, then return provisional Practical 2 to Staff-only visibility.

**Architecture:** Practical 1 retains stable app ID `kpz308-rpva-practical` and its accepted immutable image. Practical 2 receives a dedicated Docker recipe, registry repository, stable app ID `kpz308-rpva-practical2`, and separate host workspace subtree. The same Practical 2 image is accepted on dev and promoted unchanged to production; production student visibility is temporary until a real KPZ308 login proves the group path.

**Tech Stack:** R 4.6.0 container runtime, `renv`, base Shiny, Docker Buildx, Gitea container registry, ShinyProxy 3.2.4, rootless Docker on Red Hat 9.8, SAML/Entra ID, Bash, Playwright 1.58.2.

## Global Constraints

- Preserve Practical 1 app ID `kpz308-rpva-practical`.
- Use Practical 2 app ID `kpz308-rpva-practical2`.
- Use lowercase registry repository `git.its.utas.edu.au/utas/kpz308-rpva-practical2`.
- Use immutable source-derived tags; never deploy a moving tag.
- Build `linux/amd64` images and record the OCI revision label and registry digest.
- Use host workspace `data/kpz308-rpva-practical2/workspaces` and container mount `/srv/rpva-workspaces/current`.
- Keep Practical 1 and Practical 2 host workspace paths distinct.
- Use `UNI-Ecology-Teaching-Shiny-Staff` and `KPZ308` on production during the canary.
- Return Practical 2 to Staff-only production access after the student canary.
- Preserve `:z` on Red Hat bind mounts; do not alter SELinux labels manually.
- Back up `application.yml` with `cp -p` before every remote mutation.
- Restore the backup and re-prove Practical 1 if any health, launch, image, export, workspace, or access check fails.
- Do not include credentials, cookies, SAML assertions, or unnecessary user identifiers in committed evidence.
- Do not repeat the 60-container capacity test unless the runtime or resource limits materially change.

---

### Task 1: Add the Practical 2 deployment scaffold

**Files:**
- Create: `deploy/shinyproxy/practical2/Dockerfile.template`
- Create: `deploy/shinyproxy/practical2/dockerignore.template`
- Create: `deploy/shinyproxy/practical2/application.spec.example.yml`
- Create: `deploy/shinyproxy/practical2/README.md`
- Create: `deploy/shinyproxy/practical2/validate-scaffold.sh`
- Modify: `deploy/shinyproxy/teaching-app-human-playbook.md:103-114`
- Modify: `deploy/shinyproxy/teaching-app-human-playbook.md:451-476`
- Modify: `deploy/shinyproxy/teaching-app-codex-playbook.md:90-105`
- Modify: `deploy/shinyproxy/teaching-app-codex-playbook.md:620-647`

**Interfaces:**
- Consumes: exported R function `run_practical2_shiny(host, port, launch.browser, ...)` and installed directory `system.file("shiny", "practical2", package = "rPVA")`.
- Produces: validated Docker recipe `deploy/shinyproxy/practical2/Dockerfile.template`, ShinyProxy spec example, and confirmed app inventory used by Tasks 2-6.

- [ ] **Step 1: Create the failing scaffold validator**

Create `deploy/shinyproxy/practical2/validate-scaffold.sh` with:

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
SCAFFOLD="$ROOT/deploy/shinyproxy/practical2"

required=(
  "$SCAFFOLD/README.md"
  "$SCAFFOLD/Dockerfile.template"
  "$SCAFFOLD/dockerignore.template"
  "$SCAFFOLD/application.spec.example.yml"
  "$SCAFFOLD/validate-scaffold.sh"
)

for path in "${required[@]}"; do
  if [[ ! -f "$path" ]]; then
    printf 'missing required scaffold file: %s\n' "$path" >&2
    exit 1
  fi
done

marker_re="$(printf '%s|%s|%s' 'TO''DO' 'T''BD' 'PLACE''HOLDER')"
if grep -R -n -E "$marker_re" "$SCAFFOLD"; then
  printf 'unexpected unresolved marker found in scaffold\n' >&2
  exit 1
fi

if grep -R -n -E '(password|token|secret)[[:space:]]*[:=]' "$SCAFFOLD" | grep -v '<'; then
  printf 'possible credential value found\n' >&2
  exit 1
fi

grep -q 'R CMD INSTALL' "$SCAFFOLD/Dockerfile.template"
grep -q 'rPVA::run_practical2_shiny' "$SCAFFOLD/Dockerfile.template"
grep -q 'system.file("shiny", "practical2", package = "rPVA")' "$SCAFFOLD/Dockerfile.template"
grep -q 'org.opencontainers.image.revision' "$SCAFFOLD/Dockerfile.template"
grep -q 'libuv1-dev' "$SCAFFOLD/Dockerfile.template"
grep -q 'HEALTHCHECK' "$SCAFFOLD/Dockerfile.template"
grep -q 'id: "kpz308-rpva-practical2"' "$SCAFFOLD/application.spec.example.yml"
grep -q 'git.its.utas.edu.au/utas/kpz308-rpva-practical2:' "$SCAFFOLD/application.spec.example.yml"
grep -q 'UNI-Ecology-Teaching-Shiny-Staff' "$SCAFFOLD/application.spec.example.yml"
grep -q 'KPZ308' "$SCAFFOLD/application.spec.example.yml"
grep -q '#{proxy.userId}' "$SCAFFOLD/application.spec.example.yml"
grep -q 'data/kpz308-rpva-practical2/workspaces/' "$SCAFFOLD/application.spec.example.yml"

bash -n "$SCAFFOLD/validate-scaffold.sh"

if command -v ruby >/dev/null 2>&1; then
  ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0))' "$SCAFFOLD/application.spec.example.yml"
else
  printf 'ruby unavailable; skipped YAML parse check\n' >&2
fi

printf 'Practical 2 Shiny deployment scaffold static checks passed.\n'
```

- [ ] **Step 2: Run the validator and verify the expected failure**

Run:

```bash
bash deploy/shinyproxy/practical2/validate-scaffold.sh
```

Expected: non-zero exit with `missing required scaffold file` for `README.md`.

- [ ] **Step 3: Add the dedicated Practical 2 Docker recipe**

Create `deploy/shinyproxy/practical2/Dockerfile.template` by copying the proven Practical 1 recipe, then make only these app-specific substitutions:

```diff
-LABEL org.opencontainers.image.title="rPVA Practical 1 Shiny concept lab"
-LABEL org.opencontainers.image.description="Template image for the bounded Practical 1 teaching app"
+LABEL org.opencontainers.image.title="rPVA Practical 2 Woodhen Management Lab"
+LABEL org.opencontainers.image.description="Image for the bounded KPZ308 Practical 2 teaching app"
@@
-  && Rscript -e 'stopifnot(dir.exists(system.file("shiny", "practical1", package = "rPVA")))'
+  && Rscript -e 'stopifnot(dir.exists(system.file("shiny", "practical2", package = "rPVA")))'
@@
-CMD ["Rscript", "-e", "rPVA::run_practical1_shiny(host = Sys.getenv('SHINY_HOST', '0.0.0.0'), port = as.integer(Sys.getenv('SHINY_PORT', '3838')), launch.browser = FALSE)"]
+CMD ["Rscript", "-e", "rPVA::run_practical2_shiny(host = Sys.getenv('SHINY_HOST', '0.0.0.0'), port = as.integer(Sys.getenv('SHINY_PORT', '3838')), launch.browser = FALSE)"]
```

Retain `rocker/r-ver:4.6.0`, the `listenv` 0.10.1 priming step, all current system dependencies, port 3838, health check, workspace environment variables, and `ARG RPVA_REF` unchanged.

- [ ] **Step 4: Add the Docker build-context exclusions**

Copy `deploy/shinyproxy/practical1/dockerignore.template` to `deploy/shinyproxy/practical2/dockerignore.template` and change only the final log exclusion:

```text
deploy/shinyproxy/practical2/*.log
```

- [ ] **Step 5: Add the production-shaped app spec example**

Create `deploy/shinyproxy/practical2/application.spec.example.yml`:

```yaml
- id: "kpz308-rpva-practical2"
  display-name: "KPZ308 Practical 2 - Infrastructure Canary"
  description: "Provisional Woodhen Management Lab for KPZ308 infrastructure validation"
  container-image: "git.its.utas.edu.au/utas/kpz308-rpva-practical2:dev-20260713-0123456789ab"
  container-network: "shinyproxy-net"
  container-memory-limit: "1g"
  container-cpu-limit: 1.0
  access-groups:
    - "UNI-Ecology-Teaching-Shiny-Staff"
    - "KPZ308"
  port: 3838
  target-path: "/"
  container-env:
    SHINY_HOST: "0.0.0.0"
    SHINY_PORT: "3838"
    RPVA_STUDENT_ID: "#{proxy.userId}"
    RPVA_STUDENT_WORKSPACE_ROOT: "/srv/rpva-workspaces/current"
  container-volumes:
    - "/srv/sa-container/ecology-teaching-shiny/data/kpz308-rpva-practical2/workspaces/#{proxy.userId}:/srv/rpva-workspaces/current:z"
```

The source-derived tag in live configuration is generated in Task 2; the example value is documentation, not a deployable tag.

- [ ] **Step 6: Add the Practical 2 scaffold README**

Create `deploy/shinyproxy/practical2/README.md`:

```markdown
# Practical 2 ShinyProxy Deployment Scaffold

This directory contains the reviewed image and ShinyProxy spec inputs for the
KPZ308 Practical 2 Woodhen Management Lab.

- `Dockerfile.template` installs the locked rPVA package and launches
  `rPVA::run_practical2_shiny()` on port 3838.
- `dockerignore.template` is copied to `.dockerignore` only in an approved
  image-build workspace.
- `application.spec.example.yml` records the stable app identity, registry
  repository, access groups, and separate per-user workspace path.
- `validate-scaffold.sh` performs static and YAML checks.

Use an immutable `dev-YYYYMMDD-SHORTSHA` image tag. Accept the image on dev,
then promote that exact tag and digest to production. During infrastructure
validation the production tile is visible briefly to Staff and KPZ308, then
returned to Staff-only access until teaching-content signoff.

The authoritative operational sequence is in the human and Codex teaching app
deployment playbooks one directory above.
```

- [ ] **Step 7: Confirm the permanent identity in both playbooks**

Change the Practical 2 inventory row in both playbooks to:

```markdown
| KPZ308 Practical 2 | `kpz308-rpva-practical2` | `git.its.utas.edu.au/utas/kpz308-rpva-practical2` | `data/kpz308-rpva-practical2/workspaces` | `KPZ308` | Confirmed permanent identity; use Staff-only access outside approved student release windows. |
```

In both Practical 2 YAML examples, replace the image line with:

```yaml
container-image: "git.its.utas.edu.au/utas/kpz308-rpva-practical2:dev-YYYYMMDD-SHORTSHA"
```

Replace prose saying the repository or ID requires confirmation with prose stating that the immutable tag must be replaced with the Task 2 accepted tag.

- [ ] **Step 8: Run focused source and scaffold verification**

Run:

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-14_practical2_woodhen_api.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-15_practical2_shiny.R", reporter = "summary")'
bash deploy/shinyproxy/practical1/validate-scaffold.sh
bash deploy/shinyproxy/practical2/validate-scaffold.sh
git diff --check
```

Expected: both test files finish with no failures, both validators print their passing messages, and `git diff --check` prints nothing.

- [ ] **Step 9: Commit the deployment scaffold**

```bash
git add deploy/shinyproxy/practical2 \
  deploy/shinyproxy/teaching-app-human-playbook.md \
  deploy/shinyproxy/teaching-app-codex-playbook.md
git commit -m "Add Practical 2 deployment scaffold"
```

Expected: one commit containing only the new Practical 2 deployment assets and confirmed playbook contract.

---

### Task 2: Build and publish the immutable Practical 2 image

**Files:**
- Read: `deploy/shinyproxy/practical2/Dockerfile.template`
- Read: `deploy/shinyproxy/practical2/dockerignore.template`
- No committed file changes.

**Interfaces:**
- Consumes: committed Task 1 source and Docker recipe.
- Produces: exact `P2_SOURCE_REF`, `P2_IMAGE`, local image ID, OCI revision label, and registry digest used unchanged by Tasks 3-6.

- [ ] **Step 1: Verify clean committed source and push it**

```bash
git status --short --branch
git push origin main
P2_SOURCE_REF="$(git rev-parse HEAD)"
P2_SHORT_SHA="${P2_SOURCE_REF:0:12}"
P2_TAG="dev-$(date +%Y%m%d)-${P2_SHORT_SHA}"
P2_IMAGE="git.its.utas.edu.au/utas/kpz308-rpva-practical2:${P2_TAG}"
printf 'P2_SOURCE_REF=%s\nP2_IMAGE=%s\n' "$P2_SOURCE_REF" "$P2_IMAGE"
```

Expected: clean worktree, successful push, and a tag such as `dev-20260713-abcdef123456`.

- [ ] **Step 2: Build the linux/amd64 image**

```bash
docker buildx build \
  --platform linux/amd64 \
  --load \
  --build-arg RPVA_REF="$P2_SOURCE_REF" \
  -f deploy/shinyproxy/practical2/Dockerfile.template \
  -t "$P2_IMAGE" \
  .
```

Expected: successful package installation, installed Practical 2 directory check, and local image creation.

- [ ] **Step 3: Verify image architecture and revision label**

```bash
docker image inspect "$P2_IMAGE" --format \
  'id={{.Id}} arch={{.Architecture}} revision={{index .Config.Labels "org.opencontainers.image.revision"}}'
```

Expected: `arch=amd64` and `revision` exactly equals `P2_SOURCE_REF`.

- [ ] **Step 4: Run a local container and API smoke**

```bash
docker rm -f rpva-practical2-local-smoke 2>/dev/null || true
docker run -d \
  --name rpva-practical2-local-smoke \
  --memory 1g \
  -p 127.0.0.1:3852:3838 \
  "$P2_IMAGE"

cleanup_smoke() {
  docker rm -f rpva-practical2-local-smoke >/dev/null 2>&1 || true
}
trap cleanup_smoke EXIT

healthy=0
for attempt in $(seq 1 24); do
  if curl -fsS http://127.0.0.1:3852/ >/dev/null; then
    printf 'healthy_attempt=%s\n' "$attempt"
    healthy=1
    break
  fi
  sleep 5
done

if [[ "$healthy" -ne 1 ]]; then
  docker logs --tail 100 rpva-practical2-local-smoke
  exit 1
fi

docker inspect rpva-practical2-local-smoke --format 'status={{.State.Status}} health={{.State.Health.Status}}'
docker exec rpva-practical2-local-smoke Rscript -e \
  'x <- rPVA::run_woodhen_management_set(c("01_no_mgmt", "02_pig_control"), keep_traj = FALSE, seed = 123); stopifnot(nrow(x$comparison) == 2); cat("rows=", nrow(x$comparison), "\n", sep = "")'
docker logs --tail 100 rpva-practical2-local-smoke
docker rm -f rpva-practical2-local-smoke
trap - EXIT
```

Expected: HTTP success, `health=healthy`, `rows=2`, Shiny listening on `0.0.0.0:3838`, and container removal.

- [ ] **Step 5: Push and verify the registry digest**

```bash
docker push "$P2_IMAGE"
docker buildx imagetools inspect "$P2_IMAGE"
docker pull "$P2_IMAGE"
docker image inspect "$P2_IMAGE" --format 'id={{.Id}} repoDigests={{json .RepoDigests}}'
```

Expected: push completes, the registry reports a manifest digest, and local `RepoDigests` contains the same digest. Record it as `P2_DIGEST` in the session notes.

---

### Task 3: Add Practical 2 on dev and prove concurrent operation

**Files:**
- Remote modify: `/srv/sa-container/ecology-teaching-shiny/application.yml` on `ecology-r-dev1.its.utas.edu.au`
- Remote create: `/srv/sa-container/ecology-teaching-shiny/data/kpz308-rpva-practical2/workspaces`
- Local temporary evidence: `/tmp/rpva-dev-two-app-*`

**Interfaces:**
- Consumes: `P2_IMAGE` and `P2_DIGEST` from Task 2; current accepted Practical 1 image `git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-20260713-02b09aeed4f0` with digest `sha256:3b69050e1091fa3e521e345328341b982d6b7d4739d441d740300de0c75e2f9b`.
- Produces: dev backup path and evidence that both app specs, images, browser flows, exports, containers, and workspace paths coexist.

- [ ] **Step 1: Connect through RDS/PuTTY and perform read-only discovery**

As `sa-container`:

```bash
cd /srv/sa-container/ecology-teaching-shiny
whoami
hostname -f
pwd
docker compose ps
curl -fsS http://127.0.0.1:9090/actuator/health
grep -nE '^[[:space:]]+- id:|container-image:|access-groups:|workspaces/' application.yml
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
```

Expected: correct service user/path, actuator `UP`, Practical 1 on its accepted image, and no unexplained active app containers.

- [ ] **Step 2: Pull Practical 2 and create its workspace parent**

Paste the exact `P2_IMAGE` and `P2_DIGEST` assignments recorded in Task 2,
then run:

```bash
: "${P2_IMAGE:?Set P2_IMAGE to the immutable Task 2 image}"
: "${P2_DIGEST:?Set P2_DIGEST to the Task 2 registry digest}"
docker pull "$P2_IMAGE"
docker image inspect "$P2_IMAGE" --format 'id={{.Id}} repoDigests={{json .RepoDigests}}'
mkdir -p data/kpz308-rpva-practical2/workspaces
chmod 0750 data/kpz308-rpva-practical2 data/kpz308-rpva-practical2/workspaces
ls -ldZ data/kpz308-rpva-practical2 data/kpz308-rpva-practical2/workspaces
```

Expected: digest matches `P2_DIGEST`; owner is `sa-container`; paths are separate from Practical 1.

- [ ] **Step 3: Back up and add the dev Practical 2 spec**

```bash
STAMP="$(date +%Y%m%d-%H%M%S)"
DEV_BACKUP="application.yml.before-kpz308-rpva-practical2-${STAMP}"
cp -p application.yml "$DEV_BACKUP"
ls -l "$DEV_BACKUP"
vi application.yml
```

Add this app spec under `proxy.specs`, replacing the example image with the
exact value of `P2_IMAGE`:

```yaml
    - id: "kpz308-rpva-practical2"
      display-name: "KPZ308 Practical 2 - Infrastructure Canary"
      description: "Provisional Woodhen Management Lab for KPZ308 infrastructure validation"
      container-image: "git.its.utas.edu.au/utas/kpz308-rpva-practical2:dev-20260713-0123456789ab"
      container-network: "shinyproxy-net"
      container-memory-limit: "1g"
      container-cpu-limit: 1.0
      access-groups:
        - "UNI-Ecology-Teaching-Shiny-Admins"
      port: 3838
      target-path: "/"
      container-env:
        SHINY_HOST: "0.0.0.0"
        SHINY_PORT: "3838"
        RPVA_STUDENT_ID: "#{proxy.userId}"
        RPVA_STUDENT_WORKSPACE_ROOT: "/srv/rpva-workspaces/current"
      container-volumes:
        - "/srv/sa-container/ecology-teaching-shiny/data/kpz308-rpva-practical2/workspaces/#{proxy.userId}:/srv/rpva-workspaces/current:z"
```

Review:

```bash
diff -u "$DEV_BACKUP" application.yml || true
grep -nE '^[[:space:]]+- id:|container-image:|access-groups:|workspaces/' application.yml
for expected in 01_hello kpz308-rpva-practical kpz308-rpva-practical2; do
  grep -qE "^[[:space:]]+- id: [\"']?${expected}[\"']?[[:space:]]*$" application.yml || exit 1
done
```

Expected: one added app spec, no SAML changes, no Practical 1 identity/image/workspace changes, and all three IDs present.

- [ ] **Step 4: Restart dev with automatic rollback on failed health**

```bash
docker compose down
if ! docker compose up -d; then
  cp -p "$DEV_BACKUP" application.yml
  docker compose up -d
  exit 1
fi

healthy=0
for attempt in $(seq 1 24); do
  if curl -fsS http://127.0.0.1:9090/actuator/health; then
    printf '\nhealth_attempt=%s\n' "$attempt"
    healthy=1
    break
  fi
  sleep 5
done

if [[ "$healthy" -ne 1 ]]; then
  docker compose down
  cp -p "$DEV_BACKUP" application.yml
  docker compose up -d
  exit 1
fi

docker compose ps
docker logs --tail 160 shinyproxy 2>&1 | grep -Ei 'Started ShinyProxy|error|warn|kpz308' || true
```

Expected: actuator `UP`, ShinyProxy 3.2.4 started, and no unexplained startup error.

- [ ] **Step 5: Run the dev two-tab browser acceptance**

Use Playwright with one interactive SAML/Duo handoff. Keep both app pages open at the same time.

Practical 1 path:

```text
launcher -> KPZ308 rPVA Practical -> Start baseline ->
Concept Lab -> Environmental stochasticity -> Run stage -> Compare ->
enter interpretation -> download Comparison CSV and Evidence notes
```

Required assertions: Mission 4 label is visible; `env_sd=0.35`; `K=15`; comparison has two rows; both downloads are non-empty.

Practical 2 path:

```text
launcher -> KPZ308 Practical 2 - Infrastructure Canary ->
Management scenarios -> Run management scenarios ->
Bounded sensitivity -> Run sensitivity scenarios -> Evidence pack ->
enter interpretation -> download both comparison CSV files and evidence notes
```

Required assertions: five core rows; at least four sensitivity rows; all three downloads are non-empty; no relevant browser console errors. Capture desktop screenshots for both apps and one mobile Practical 2 screenshot.

- [ ] **Step 6: Capture concurrent dev server evidence while both tabs remain open**

```bash
curl -fsS http://127.0.0.1:9090/actuator/health
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
docker logs --tail 240 shinyproxy 2>&1 \
  | grep -Ei 'Starting proxy|Proxy activated|kpz308-rpva-practical2|kpz308-rpva-practical|error|warn' \
  || true
find data/kpz308-rpva-practical data/kpz308-rpva-practical2 \
  -maxdepth 2 -type d -printf '%p %u:%g %m\n' | sort
```

Expected: ShinyProxy plus two healthy `sp-container-*` containers, one on each distinct image repository, and separate workspace trees.

---

### Task 4: Promote both accepted images to production

**Files:**
- Remote modify: `/srv/sa-container/ecology-teaching-shiny/application.yml` on `ecology-r1.its.utas.edu.au`
- Remote create: `/srv/sa-container/ecology-teaching-shiny/data/kpz308-rpva-practical2/workspaces`
- Local temporary evidence: `/tmp/rpva-prod-two-app-*`

**Interfaces:**
- Consumes: dev-accepted `P2_IMAGE`/`P2_DIGEST` and Practical 1 image/digest listed in Task 3.
- Produces: production backup path and evidence that the same accepted images run concurrently under Staff and KPZ308 access.

- [ ] **Step 1: Notify Mark of the short production canary window**

Send:

```text
We are about to run a short KPZ308 two-app production canary. It will promote
the already accepted Practical 1 image and add a distinct Practical 2 image,
then open one session in each app concurrently. Could you please retain the
monitoring window so we can record any CPU, RAM, or infrastructure anomalies?
No capacity load test is planned.
```

- [ ] **Step 2: Perform read-only production discovery**

Through RDS/PuTTY, connect to `ecology-r1.its.utas.edu.au`, become
`sa-container`, and run:

```bash
cd /srv/sa-container/ecology-teaching-shiny
whoami
hostname -f
pwd
docker compose ps
curl -fsS http://127.0.0.1:9090/actuator/health
grep -nE '^[[:space:]]+- id:|container-image:|access-groups:|workspaces/' application.yml
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
```

Expected before mutation: actuator `UP`; Practical 1 still uses its previous production image; production access groups are `UNI-Ecology-Teaching-Shiny-Staff` and `KPZ308`; no Practical 2 spec exists.

- [ ] **Step 3: Pull both exact images and verify digests**

```bash
P1_IMAGE='git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-20260713-02b09aeed4f0'
: "${P2_IMAGE:?Paste the immutable P2_IMAGE assignment recorded in Task 2}"
: "${P2_DIGEST:?Paste the P2_DIGEST assignment recorded in Task 2}"
docker pull "$P1_IMAGE"
docker pull "$P2_IMAGE"
docker image inspect "$P1_IMAGE" --format 'id={{.Id}} repoDigests={{json .RepoDigests}}'
docker image inspect "$P2_IMAGE" --format 'id={{.Id}} repoDigests={{json .RepoDigests}}'
```

Expected digests are
`sha256:3b69050e1091fa3e521e345328341b982d6b7d4739d441d740300de0c75e2f9b`
for Practical 1 and the recorded `P2_DIGEST` for Practical 2.

- [ ] **Step 4: Back up and edit production configuration**

```bash
STAMP="$(date +%Y%m%d-%H%M%S)"
PROD_BACKUP="application.yml.before-two-app-canary-${STAMP}"
cp -p application.yml "$PROD_BACKUP"
ls -l "$PROD_BACKUP"
mkdir -p data/kpz308-rpva-practical2/workspaces
chmod 0750 data/kpz308-rpva-practical2 data/kpz308-rpva-practical2/workspaces
ls -ldZ data/kpz308-rpva-practical2 data/kpz308-rpva-practical2/workspaces
vi application.yml
```

Make exactly two logical changes:

1. Change Practical 1 `container-image` to `P1_IMAGE`.
2. Add this Practical 2 spec, replacing the example tag with the exact
   `P2_IMAGE` value:

```yaml
    - id: "kpz308-rpva-practical2"
      display-name: "KPZ308 Practical 2 - Infrastructure Canary"
      description: "Provisional Woodhen Management Lab for KPZ308 infrastructure validation"
      container-image: "git.its.utas.edu.au/utas/kpz308-rpva-practical2:dev-20260713-0123456789ab"
      container-network: "shinyproxy-net"
      container-memory-limit: "1g"
      container-cpu-limit: 1.0
      access-groups:
        - "UNI-Ecology-Teaching-Shiny-Staff"
        - "KPZ308"
      port: 3838
      target-path: "/"
      container-env:
        SHINY_HOST: "0.0.0.0"
        SHINY_PORT: "3838"
        RPVA_STUDENT_ID: "#{proxy.userId}"
        RPVA_STUDENT_WORKSPACE_ROOT: "/srv/rpva-workspaces/current"
      container-volumes:
        - "/srv/sa-container/ecology-teaching-shiny/data/kpz308-rpva-practical2/workspaces/#{proxy.userId}:/srv/rpva-workspaces/current:z"
```

Review:

```bash
diff -u "$PROD_BACKUP" application.yml || true
grep -nE '^[[:space:]]+- id:|container-image:|access-groups:|workspaces/' application.yml
for expected in 01_hello kpz308-rpva-practical kpz308-rpva-practical2; do
  grep -qE "^[[:space:]]+- id: [\"']?${expected}[\"']?[[:space:]]*$" application.yml || exit 1
done
```

Expected: only the Practical 1 image line and one new Practical 2 spec differ;
SAML, ports, networks, and unrelated specs are unchanged.

- [ ] **Step 5: Restart production with rollback**

```bash
docker compose down
if ! docker compose up -d; then
  cp -p "$PROD_BACKUP" application.yml
  docker compose up -d
  exit 1
fi

healthy=0
for attempt in $(seq 1 24); do
  if curl -fsS http://127.0.0.1:9090/actuator/health; then
    printf '\nhealth_attempt=%s\n' "$attempt"
    healthy=1
    break
  fi
  sleep 5
done

if [[ "$healthy" -ne 1 ]]; then
  docker compose down
  cp -p "$PROD_BACKUP" application.yml
  docker compose up -d
  exit 1
fi

docker compose ps
docker logs --tail 160 shinyproxy 2>&1 | grep -Ei 'Started ShinyProxy|error|warn|kpz308' || true
```

Expected: actuator `UP`, both app specs retained, and clean ShinyProxy startup logs. On failure, restore `PROD_BACKUP` immediately and re-open Practical 1.

- [ ] **Step 6: Run production two-tab acceptance and collect server evidence**

At `https://ecology-r1.its.utas.edu.au/`, keep both app pages open
simultaneously and run these paths:

```text
Practical 1: Start baseline -> Environmental stochasticity -> Run stage ->
Compare -> interpretation -> Comparison CSV -> Evidence notes

Practical 2: Management scenarios -> Run management scenarios ->
Bounded sensitivity -> Run sensitivity scenarios -> Evidence pack ->
interpretation -> core CSV -> sensitivity CSV -> evidence notes
```

While both tabs remain open, run:

```bash
curl -fsS http://127.0.0.1:9090/actuator/health
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
docker logs --tail 240 shinyproxy 2>&1 \
  | grep -Ei 'Starting proxy|Proxy activated|kpz308-rpva-practical2|kpz308-rpva-practical|error|warn' \
  || true
find data/kpz308-rpva-practical data/kpz308-rpva-practical2 \
  -maxdepth 2 -type d -printf '%p %u:%g %m\n' | sort
```

Expected: both complete browser flows pass; both distinct app containers are simultaneously healthy; exports are valid; workspace trees are separate; no unexplained ShinyProxy/browser errors.

- [ ] **Step 7: Record Mark's monitoring result**

Record the exact test interval in UTC and Mark's CPU/RAM/infrastructure assessment. A missing response does not invalidate functional proof, but remains an open evidence item.

---

### Task 5: Complete the KPZ308 student canary and return Practical 2 to Staff-only

**Files:**
- Remote modify: production `application.yml`
- No local source changes.

**Interfaces:**
- Consumes: healthy production two-app state from Task 4.
- Produces: empirical KPZ308 access result and final Staff-only Practical 2 state.

- [ ] **Step 1: Arrange one KPZ308 student check by Friday 2026-07-17**

Ask the student to sign in at the production launcher and report only:

```text
1. Both KPZ308 Practical 1 and Practical 2 tiles are visible.
2. Practical 1 opens.
3. Practical 2 opens and shows Woodhen Management Lab.
```

Do not request credentials, screenshots containing personal information, or model work.

- [ ] **Step 2: Classify the student gate honestly**

Record `passed` only after a real KPZ308 student launches both apps. If no student is available, record `pending`, owner `Barry Brook`, deadline `2026-07-17`, and do not describe Staff testing as student proof.

- [ ] **Step 3: Back up and remove KPZ308 from Practical 2**

```bash
STAMP="$(date +%Y%m%d-%H%M%S)"
CLOSEOUT_BACKUP="application.yml.before-practical2-staff-only-${STAMP}"
cp -p application.yml "$CLOSEOUT_BACKUP"
vi application.yml
```

Remove only this line from the Practical 2 access group block:

```yaml
        - "KPZ308"
```

Leave Practical 1 Staff and KPZ308 access unchanged. Review the diff before restart.

- [ ] **Step 4: Restart and verify closeout state**

```bash
docker compose down
if ! docker compose up -d; then
  cp -p "$CLOSEOUT_BACKUP" application.yml
  docker compose up -d
  exit 1
fi

healthy=0
for attempt in $(seq 1 24); do
  if curl -fsS http://127.0.0.1:9090/actuator/health; then
    printf '\nhealth_attempt=%s\n' "$attempt"
    healthy=1
    break
  fi
  sleep 5
done

if [[ "$healthy" -ne 1 ]]; then
  docker compose down
  cp -p "$CLOSEOUT_BACKUP" application.yml
  docker compose up -d
  exit 1
fi
```

Then confirm:

```bash
curl -fsS http://127.0.0.1:9090/actuator/health
grep -nE '^[[:space:]]+- id:|container-image:|access-groups:|KPZ308|UNI-Ecology-Teaching-Shiny-Staff' application.yml
```

Expected: Practical 1 retains Staff and KPZ308; Practical 2 retains Staff only; both immutable images remain configured; actuator is `UP`.

- [ ] **Step 5: Run final Staff smoke**

As Barry, sign in through Staff access and open both apps. Confirm Practical 1 still runs and Practical 2 remains available for content refinement.

---

### Task 6: Commit the durable deployment evidence and publish the result

**Files:**
- Create: `docs/ops/deployments/2026-07-13-kpz308-two-app-production-proof.md`
- Modify only if needed: `deploy/shinyproxy/teaching-app-human-playbook.md`
- Modify only if needed: `deploy/shinyproxy/teaching-app-codex-playbook.md`

**Interfaces:**
- Consumes: exact source/tag/digest, dev/prod, browser, student, monitoring, closeout, and rollback evidence from Tasks 1-5.
- Produces: orchestrator-readable deployment record and a clean pushed `main`.

- [ ] **Step 1: Write the deployment report**

Use this exact section structure:

```markdown
# KPZ308 Two-App Production Proof

Date: 2026-07-13
Status: passed | passed-with-student-gate-pending | rolled-back

## Scope
## Source and image identity
## Practical 2 scaffold verification
## Local image acceptance
## Dev configuration and rollback
## Dev concurrent browser and container evidence
## Production configuration and rollback
## Production concurrent browser and container evidence
## KPZ308 student access result
## Infrastructure monitoring
## Canary closeout state
## Remaining actions before 20 July
```

Under image identity, include a table with both app IDs, source commits, immutable tags, image IDs, and registry digests. Under each environment, include the backup filename, redacted config diff summary, health result, both app container image names, export filenames/row counts, and workspace separation result. Do not include cookies, tokens, SAML assertions, or personal identifiers.

- [ ] **Step 2: Verify the complete repository**

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-14_practical2_woodhen_api.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-15_practical2_shiny.R", reporter = "summary")'
bash deploy/shinyproxy/practical1/validate-scaffold.sh
bash deploy/shinyproxy/practical2/validate-scaffold.sh
git diff --check
git status --short --branch
```

Expected: no test failures, both scaffold validators pass, no whitespace errors, and only the intended report/playbook evidence changes remain.

- [ ] **Step 3: Commit the evidence**

```bash
git add docs/ops/deployments/2026-07-13-kpz308-two-app-production-proof.md \
  deploy/shinyproxy/teaching-app-human-playbook.md \
  deploy/shinyproxy/teaching-app-codex-playbook.md
git commit -m "Record KPZ308 two-app production proof"
```

If no playbook changes remain, omit those two paths from `git add`.

- [ ] **Step 4: Push and verify synchronization**

```bash
git push origin main
git status --short --branch
git rev-parse HEAD
git rev-parse origin/main
```

Expected: push succeeds, worktree is clean, and local/remote commit IDs match.
