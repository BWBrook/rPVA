# Teaching App Deployment Playbooks Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create two self-contained playbooks that let Barry or a fresh Codex agent build, publish, deploy, verify, promote, and roll back three simultaneous ITS ShinyProxy teaching applications without reconstructing the process from historical goal packets.

**Architecture:** The human playbook is organized by the four environments Barry moves through: Windows browser, WSL bash, RDS/PuTTY, and the remote RedHat shell. The Codex playbook expresses the same operational path as a gated execution protocol with parameters, authority boundaries, evidence requirements, human handoffs, stop rules, and cross-app regression checks. Both documents repeat a small set of live infrastructure facts intentionally so that either remains usable on its own.

**Tech Stack:** Markdown, Bash and PowerShell command examples, Git, R/renv/testthat, Docker Desktop with WSL integration, ITS Gitea container registry, RDS, PuTTY/SSH, RedHat 9, Docker Compose, ShinyProxy 3.2.4, SAML/SSO.

## Global Constraints

- Create only `deploy/shinyproxy/teaching-app-human-playbook.md` and `deploy/shinyproxy/teaching-app-codex-playbook.md` as operational deliverables.
- Do not build or push an image, connect to RDS/PuTTY, edit a live `application.yml`, restart ShinyProxy, or mutate dev/prod while implementing these documents.
- Document one shared ShinyProxy platform that can host all three apps simultaneously.
- Retain the existing Practical 1 app ID `kpz308-rpva-practical`; do not silently rename it.
- Use `kpz308-rpva-practical2` as the recommended Practical 2 ID, with first deployment blocked until Barry and ITS confirm it.
- Use `kpz314-sdm-practical` as the reserved KPZ314 ID, with first deployment blocked until the KPZ314 project and ITS confirm its image path and workspace subtree.
- Use dev host `ecology-r-dev1.its.utas.edu.au` and prod host `ecology-r1.its.utas.edu.au`.
- Use deployment directory `/srv/sa-container/ecology-teaching-shiny` and service account `sa-container`.
- Use Docker network `shinyproxy-net` and ShinyProxy image `openanalytics/shinyproxy:3.2.4` unless live discovery proves the platform has changed.
- Use lowercase `utas` in Docker image references; uppercase `UTAS` is allowed only for the Gitea source owner/path.
- Use readable immutable image tags in `application.yml`, record digests separately, and never deploy `latest`.
- Promote dev first, then the exact accepted tag to prod.
- Keep per-app and per-user workspaces isolated with `#{proxy.userId}`.
- Never include real passwords, access tokens, private keys, student identifiers, or credential-like examples.
- Treat browser/SAML acceptance as human-observed evidence; container health alone is insufficient.
- Do not repeat the 5/10/20/40/60-container capacity rehearsal unless runtime, limits, platform, host capacity, or expected concurrency changes materially.
- Use ASCII except for existing proper names or text that requires another character set.

---

### Task 1: Human Deployment Playbook

**Files:**
- Create: `deploy/shinyproxy/teaching-app-human-playbook.md`
- Reference: `deploy/shinyproxy/practical1/wsl-image-push-runbook.md`
- Reference: `deploy/shinyproxy/practical1/gitea-registry-runbook.md`
- Reference: `deploy/shinyproxy/practical1/its-vm-handoff.md`
- Reference: `deploy/shinyproxy/practical1/staging-gate-checklist.md`
- Reference: `docs/goals/043-its-dev-prod-validation-canonicalization/its-dev-prod-validation-closeout.md`

**Interfaces:**
- Consumes: the accepted hostnames, paths, access groups, registry rules, promotion policy, and validated failure remedies from the design and reference documents.
- Produces: a standalone, copy-and-paste-oriented human procedure organized by execution environment and task type.

- [ ] **Step 1: Create the human playbook opening and stable-facts sections**

Create the file with these opening sections in this order:

```markdown
# ITS Teaching Apps: Human Deployment Playbook

## What This Playbook Is For
## Update This Playbook When
## Choose Your Task
## Platform Map: Where Each Command Runs
## Current Shared Infrastructure
## Teaching App Inventory
## Safety Rules
## Deployment Record
```

The task chooser must distinguish:

1. refreshing an existing app with a new image;
2. adding a new app without replacing existing apps;
3. rolling back or recovering one app.

The environment map must make these boundaries explicit:

| Label | Environment | Work performed there |
| --- | --- | --- |
| `WINDOWS` | Windows browser and desktop | GlobalProtect, Docker Desktop startup, RDS web portal, DUO, PuTTY launch, and final browser smoke. |
| `WSL` | Ubuntu bash in WSL | Git checkout, R validation, Docker build, local smoke, Gitea login, push, and digest capture. |
| `PUTTY` | PuTTY session reached through RDS | SSH to dev or prod, then `sudo -iu sa-container`. |
| `REMOTE` | RedHat shell as `sa-container` | Inspect and back up config, pull image, restart ShinyProxy, check health/logs, and roll back. |

The deployment record must tell the operator to write down before mutation:

```text
APP_ID=
SOURCE_REPO=
SOURCE_REF=
IMAGE_REPOSITORY=
NEW_TAG=
NEW_DIGEST=
PREVIOUS_TAG_DEV=
PREVIOUS_TAG_PROD=
DEV_CONFIG_BACKUP=
PROD_CONFIG_BACKUP=
DEV_BROWSER_RESULT=
PROD_BROWSER_RESULT=
```

- [ ] **Step 2: Add source validation and image publication from WSL**

Add these sections:

```markdown
## Phase 1: Prepare Windows, VPN, and Docker Desktop
## Phase 2: Select and Validate Source in WSL
## Phase 3: Build and Smoke the Image in WSL
## Phase 4: Log In, Push, and Record the Digest
```

Phase 1 must include a short Windows PowerShell entry block:

```powershell
Start-Process "$Env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
wsl.exe --status
wsl.exe -d Ubuntu
```

State that Docker Desktop may already be running and that the WSL-side
`docker info` result, not the Windows process alone, proves integration is
ready. GlobalProtect and DUO remain GUI interactions.

Use a concrete WSL parameter block that requires the operator to change only
the selected app values:

```bash
cd /home/bwbrook/git/rPVA

APP_ID='kpz308-rpva-practical'
REVIEWED_REF="$(git rev-parse HEAD)"
SHORT_SHA="$(git rev-parse --short=12 HEAD)"
BUILD_DATE="$(date +%Y%m%d)"
IMAGE_REPOSITORY='git.its.utas.edu.au/utas/kpz308-rpva-practical'
TAG="dev-${BUILD_DATE}-${SHORT_SHA}"
IMAGE="${IMAGE_REPOSITORY}:${TAG}"
```

State that a different project checkout, Dockerfile, and image repository must
be supplied for KPZ308 Practical 2 or KPZ314; do not imply that the rPVA
Practical 1 Dockerfile packages those applications.

Include clean source and validation commands:

```bash
git fetch --prune origin
git status --short --branch
git show -s --format='source=%H%nsubject=%s' "${REVIEWED_REF}"
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter = "summary")'
bash deploy/shinyproxy/practical1/validate-scaffold.sh
docker info
```

Include the existing Linux AMD64 build command:

```bash
docker build \
  --platform linux/amd64 \
  -f deploy/shinyproxy/practical1/Dockerfile.template \
  --build-arg RPVA_REF="${REVIEWED_REF}" \
  -t "${IMAGE}" \
  .
```

Include this bounded local smoke. It confirms port `3838` is free, waits for
the image health check, checks page content, shows logs on failure, and always
removes the smoke container:

```bash
SMOKE_NAME="rpva-practical-smoke-${SHORT_SHA}"

if ss -ltn '( sport = :3838 )' | grep -q LISTEN; then
  echo 'Port 3838 is already in use; stop and choose a free local port.' >&2
  exit 1
fi

cleanup_smoke() {
  docker rm -f "${SMOKE_NAME}" >/dev/null 2>&1 || true
}
trap cleanup_smoke EXIT

docker run --rm -d \
  --name "${SMOKE_NAME}" \
  -p 127.0.0.1:3838:3838 \
  "${IMAGE}"

for attempt in $(seq 1 60); do
  STATUS="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "${SMOKE_NAME}")"
  if [ "${STATUS}" = 'healthy' ]; then
    break
  fi
  if [ "${STATUS}" = 'exited' ] || [ "${STATUS}" = 'unhealthy' ]; then
    docker logs "${SMOKE_NAME}"
    exit 1
  fi
  sleep 2
done

test "${STATUS}" = 'healthy' || {
  docker logs "${SMOKE_NAME}"
  exit 1
}

curl -fsS http://127.0.0.1:3838/ > /tmp/rpva-practical-smoke.html
grep -E 'KPZ308|Practical|rPVA|Shiny' /tmp/rpva-practical-smoke.html
cleanup_smoke
trap - EXIT
```

Include token-safe registry login:

```bash
read -rp 'Gitea username: ' GITEA_USER
read -rsp 'Gitea token or password: ' GITEA_TOKEN
printf '\n'
printf '%s' "${GITEA_TOKEN}" | docker login git.its.utas.edu.au \
  --username "${GITEA_USER}" \
  --password-stdin
unset GITEA_TOKEN
```

Push with pipeline failure propagation, then capture both the pushed digest
line and local repo digests:

```bash
set -o pipefail
docker push "${IMAGE}" | tee "push-${TAG}.log"
docker image inspect "${IMAGE}" \
  --format 'id={{.Id}} repoDigests={{json .RepoDigests}}'
docker buildx imagetools inspect "${IMAGE}" | tee "manifest-${TAG}.txt"
```

Stop if source validation, build, local smoke, login, push, or digest capture
does not produce the expected evidence.

- [ ] **Step 3: Add RDS, PuTTY, and remote-host entry procedures**

Add these sections:

```markdown
## Phase 5: Enter the ITS Jump Host and Open PuTTY
## Phase 6: Inspect Dev Before Changing It
```

Include the RDS URL exactly:

```text
https://remoteapps.utas.edu.au/RDWeb/Pages/en-US/login.aspx?ReturnUrl=/RDWeb/Pages/en-US/Default.aspx
```

Explain the human sequence: open the RDS URL in Windows, complete UTAS login
and DUO, launch the remote desktop or published PuTTY, and connect first to
`ecology-r-dev1.its.utas.edu.au` as `bwbrook`.

Include this remote entry block:

```bash
hostname -f
whoami
sudo -iu sa-container
cd /srv/sa-container/ecology-teaching-shiny
pwd
docker compose ps
docker compose config --services
curl -fsS http://127.0.0.1:9090/actuator/health
```

Immediately after entering the deployment directory, establish remote-shell
values independently of the earlier WSL shell:

```bash
APP_ID='kpz308-rpva-practical'
IMAGE='git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-YYYYMMDD-SHORTSHA'
EXPECTED_APP_IDS='kpz308-rpva-practical'
```

Label the date and short-SHA segments as operator metavariables that must be
replaced with the exact pushed tag. As additional apps become live, add all
their stable IDs to `EXPECTED_APP_IDS` before comparing the config inventory.
Require the inventory check to test each expected ID:

```bash
for expected in ${EXPECTED_APP_IDS}; do
  grep -qE "^[[:space:]]+- id: [\"']?${expected}[\"']?[[:space:]]*$" application.yml || {
    echo "Missing app spec: ${expected}" >&2
    exit 1
  }
done
```

Include checks for active teaching sessions and all app specs:

```bash
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
grep -nE '^[[:space:]]+- id:|container-image:|access-groups:|workspaces/' application.yml
```

The playbook must stop deployment if a class or unexplained active
`sp-container-*` session is present.

- [ ] **Step 4: Add safe multi-app configuration, restart, and dev checks**

Add these sections:

```markdown
## Phase 7: Back Up and Update Dev
## Phase 8: Restart and Check Dev
## Phase 9: Perform the Dev Browser Acceptance Test
```

Back up the config before editing:

```bash
STAMP="$(date +%Y%m%d-%H%M%S)"
cp -p application.yml "application.yml.before-${APP_ID}-${STAMP}"
ls -l "application.yml.before-${APP_ID}-${STAMP}"
```

Tell the operator to use `vi application.yml` or the editor available on the
host. For an existing app, change only that spec's `container-image`. For a
new app, add another list item under `proxy.specs`; do not replace an existing
item.

Include a complete additive spec shape with these fields:

```yaml
    - id: "kpz308-rpva-practical2"
      display-name: "KPZ308 rPVA Practical 2"
      description: "KPZ308 Practical 2"
      container-image: "git.its.utas.edu.au/utas/CONFIRMED_REPOSITORY:IMMUTABLE_TAG"
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

Label `CONFIRMED_REPOSITORY` and `IMMUTABLE_TAG` as deliberate operator
metavariables, not values to paste unchanged. State that KPZ314 uses access
group `KPZ314`, not `KPZ308`, and requires its own confirmed environment
variables and workspace path. State that the example memory and CPU limits are
the validated Practical 1 values, not automatic defaults for every new app.

For a first deployment, create and inspect the selected app's workspace parent
as `sa-container` before restart. For the Practical 2 proposed identity, use:

```bash
mkdir -p data/kpz308-rpva-practical2/workspaces
chmod 0750 data/kpz308-rpva-practical2 data/kpz308-rpva-practical2/workspaces
ls -ldZ data/kpz308-rpva-practical2 data/kpz308-rpva-practical2/workspaces
```

Do not reuse that path for KPZ314. Do not change SELinux labels manually;
retain the `:z` bind-mount option and stop for ITS help if container access is
denied.

After editing, show the diff against the backup and verify that all expected
app IDs remain:

```bash
diff -u "application.yml.before-${APP_ID}-${STAMP}" application.yml || true
grep -nE '^[[:space:]]+- id:' application.yml
docker pull "${IMAGE}"
docker image inspect "${IMAGE}" --format 'id={{.Id}} repoDigests={{json .RepoDigests}}'
```

Use the ITS-confirmed restart path:

```bash
docker compose down
docker compose up -d
docker compose ps
curl -fsS http://127.0.0.1:9090/actuator/health
docker logs --tail 120 shinyproxy
```

State that any less disruptive restart may be used only after ITS confirms it
reloads the bind-mounted `application.yml`; otherwise use the known down/up
sequence during a no-user maintenance window.

The dev browser acceptance checklist must require:

1. SAML login succeeds;
2. all expected app tiles are still present;
3. the selected app starts and its container becomes healthy;
4. baseline run succeeds;
5. one changed scenario succeeds;
6. Compare shows both runs;
7. CSV downloads and opens with expected columns and non-empty rows;
8. Markdown evidence notes download and contain run settings and prompts;
9. returning to the launcher does not reveal a missing unrelated app.

Name the current browser roots explicitly:

```text
https://ecology-r-dev1.its.utas.edu.au
https://ecology-r1.its.utas.edu.au
```

State that the stable app route is `/app/<APP_ID>`, for example
`/app/kpz308-rpva-practical`, while the root launcher is preferred for the
cross-app tile check.

- [ ] **Step 5: Add prod promotion, rollback, class-day, and troubleshooting procedures**

Add these sections:

```markdown
## Phase 10: Promote the Accepted Tag to Prod
## Roll Back One Application
## Add a New Application for the First Time
## Pre-Class and Class-Day Checks
## Known Problems and Proven Remedies
## Completion Record
```

Prod promotion must repeat remote discovery, backup, one-spec edit, exact
image pull, restart, health/log checks, and browser acceptance on
`ecology-r1.its.utas.edu.au`. It must forbid rebuilding or retagging between
dev and prod.

Rollback must restore the timestamped config backup, verify the prior image is
available, restart ShinyProxy in a no-user window, recheck health, and perform
a browser smoke. It must not remove unrelated images, workspaces, or app
specs.

The first-app procedure must require confirmation of app ID, image repository,
Dockerfile/runtime, port, environment variables, access groups, workspace
subtree, SSO registration, and browser route before config mutation.

The class-day checks must cover health, expected tiles, one staff smoke,
fallback documents, support owner, rollback record, disk/workspace state, and
the fact that the prior capacity rehearsal was container workload evidence,
not 60 distinct SAML identities.

Include these known failures and remedies:

| Failure | Established response |
| --- | --- |
| WSL cannot reach Docker | Start Docker Desktop and confirm WSL integration before retrying `docker info`. |
| Docker rejects uppercase repository name | Use lowercase `utas` in the image path. Keep uppercase `UTAS` only in the Gitea source URL. |
| `docker login` silently reuses an old account/token | Run `docker logout git.its.utas.edu.au`, then log in again with `--password-stdin`. |
| Image build fails while restoring `listenv` | Confirm the Practical 1 Dockerfile still installs locked `listenv` 0.10.1 before `renv::restore()`. |
| Manual capacity command fails with `NanoCPUs can not be set` | Omit `--cpus`; the RedHat/rootless kernel did not expose that CFS control during rehearsal. Keep the ShinyProxy config limit unless ITS changes it. |
| Docker warns that IPv4 forwarding is disabled | Record it and test the actual workload. The validated R workload succeeded, but browser/network-dependent checks still require investigation if they fail. |
| Health endpoint returns 404 | Use port `9090` and `/actuator/health`; port `8080` is the user-facing proxy route. |
| App route redirects to login | Expected without a valid SAML browser session; complete acceptance in a browser. |

- [ ] **Step 6: Review and commit the human playbook**

Run:

```bash
git diff --check -- deploy/shinyproxy/teaching-app-human-playbook.md
rg -n 'WINDOWS|WSL|PUTTY|REMOTE' deploy/shinyproxy/teaching-app-human-playbook.md
rg -n 'ecology-r-dev1|ecology-r1|sa-container|shinyproxy-net|actuator/health' deploy/shinyproxy/teaching-app-human-playbook.md
rg -n 'kpz308-rpva-practical|kpz308-rpva-practical2|kpz314-sdm-practical' deploy/shinyproxy/teaching-app-human-playbook.md
rg -n 'rollback|browser acceptance|CSV|Markdown|access-groups' deploy/shinyproxy/teaching-app-human-playbook.md
```

Expected: all searches find the relevant sections; `git diff --check` exits
zero.

Commit:

```bash
git add deploy/shinyproxy/teaching-app-human-playbook.md
git commit -m "Add human ITS teaching app deployment playbook"
```

---

### Task 2: Codex Deployment Playbook

**Files:**
- Create: `deploy/shinyproxy/teaching-app-codex-playbook.md`
- Reference: `deploy/shinyproxy/teaching-app-human-playbook.md`
- Reference: `docs/superpowers/specs/2026-07-13-teaching-app-deployment-playbooks-design.md`
- Reference: `docs/goals/043-its-dev-prod-validation-canonicalization/its-dev-prod-validation-closeout.md`

**Interfaces:**
- Consumes: the same accepted infrastructure facts as the human playbook, plus its environment labels and browser acceptance criteria.
- Produces: a standalone agent execution protocol that can coordinate local automation and explicit Barry handoffs without claiming unobserved live outcomes.

- [ ] **Step 1: Create the Codex protocol, parameter contract, and authority model**

Create the file with these opening sections:

```markdown
# ITS Teaching Apps: Codex Deployment Playbook

## Mission
## Update This Playbook When
## Non-Negotiable Invariants
## Current Infrastructure Contract
## Application Inventory
## Select the Operation
## Deployment Parameter Contract
## Authority and Human-Handoff Boundaries
## Evidence Model
```

The parameter contract must require these values before publication begins:

```text
TARGET_REPO
TARGET_BRANCH
SOURCE_REF
APP_ID
APP_DISPLAY_NAME
IMAGE_REPOSITORY
IMAGE_TAG
DOCKERFILE
BUILD_CONTEXT
CONTAINER_PORT
DEV_HOST
PROD_HOST
ACCESS_GROUPS
HOST_WORKSPACE_ROOT
CONTAINER_WORKSPACE_ROOT
PREVIOUS_DEV_TAG
PREVIOUS_PROD_TAG
```

Define three operation types: `refresh-existing`, `add-new`, and `rollback`.
For `add-new`, block execution until app ID, image repository, workspace root,
SSO/access groups, runtime port, and browser route are confirmed.

The authority model must distinguish:

- Codex-safe local actions: read repo state, validate source, run tests, build
  and smoke a local image, and prepare non-secret commands/evidence when the
  user has requested deployment work;
- credential-bearing actions: require Barry to supply credentials only through
  interactive prompts and never paste them into chat;
- RDS/PuTTY actions: Codex normally supplies bounded command blocks and Barry
  returns output unless an explicitly available computer-control path is
  authorized;
- browser/SAML acceptance: Barry or an authorized tester must observe it;
- ITS-owned changes: DNS, TLS, SSO registration, groups, host patching, and
  resource/platform changes remain with ITS.

- [ ] **Step 2: Add source, validation, build, and registry publication gates**

Add gated phases:

```markdown
## Gate 0: Reconcile Repo and Live Intent
## Gate 1: Validate the Reviewed Source
## Gate 2: Build and Smoke the Image
## Gate 3: Publish the Immutable Image
```

For every gate, use this structure:

```markdown
### Preconditions
### Actions
### Evidence to Record
### Pass Condition
### Stop Conditions
```

Require fresh `git fetch`, clean-tree inspection, source commit recording,
repo-local instructions, dependency status, relevant tests, scaffold
validation when present, Docker availability, Linux AMD64 build, local HTTP
smoke, safe login, push with `pipefail`, and digest capture.

Require the agent to adapt validation to the target repo. For this rPVA
Practical 1 app, name these exact commands:

```bash
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter = "summary")'
bash deploy/shinyproxy/practical1/validate-scaffold.sh
```

State that passing rPVA tests is not evidence for KPZ314; its agent must use
the KPZ314 repo's own instructions and tests.

- [ ] **Step 3: Add dev mutation, server verification, and human browser gate**

Add:

```markdown
## Gate 4: Discover and Back Up Dev
## Gate 5: Update One Dev App Spec
## Gate 6: Restart and Verify ShinyProxy on Dev
## Gate 7: Human SAML and Browser Acceptance on Dev
```

Require live discovery to reconcile host, service user, deployment directory,
compose service, ShinyProxy image, health endpoint, current app IDs, current
selected image, active sessions, access groups, and workspace mappings before
any mutation.

Require a timestamped config backup and a redacted pre-change evidence record.
For an app refresh, permit only the chosen `container-image` line to change.
For a new app, require an additive spec and a before/after inventory proving
that no prior app ID disappeared.

Require the agent to provide Barry one bounded PuTTY command block at a time,
explain expected output, inspect returned output, and stop on ambiguity rather
than queueing prod commands before dev passes.

Define browser acceptance using the same nine checks as the human playbook.
Record tester identity by role only, timestamp, URL/host, app ID, image tag,
workflow results, export results, unrelated-app tile check, and any warnings.

- [ ] **Step 4: Add prod promotion and student release gates**

Add:

```markdown
## Gate 8: Promote the Exact Accepted Tag to Prod
## Gate 9: Human SAML and Browser Acceptance on Prod
## Gate 10: Student-Release Readiness
```

Gate 8 must verify that the prod image string exactly matches the accepted dev
image string and digest record. It must repeat discovery, active-session stop,
backup, one-app edit, app-inventory check, image pull, restart, health, and
logs on prod.

Gate 9 must not infer browser success from HTTP health. Require the same human
workflow and cross-app tile checks as dev.

Gate 10 must cover approved student URL, correct class access group, staff
access, fallback, support owner, rollback owner and previous tag, monitoring,
workspace/disk state, cleanup policy, release timing, and communication
wording. State that KPZ308 apps receive `KPZ308`; KPZ314 receives `KPZ314`;
the staff group may be shared when ITS confirms membership.

- [ ] **Step 5: Add rollback, troubleshooting, evidence report, and resumption protocol**

Add:

```markdown
## Rollback Protocol
## Known Failure Signatures
## Capacity-Retest Decision
## Deployment Evidence Report Template
## Interrupted-Session Resumption
## Completion Criteria
```

Rollback must be scoped to one app and must preserve unrelated specs and
workspaces. Require restoration of the recorded config backup or an exact
one-line tag revert, prior image availability, restart, health, logs, human
browser smoke, and a rollback reason.

Repeat the established failure table from the human playbook in agent-oriented
language, including Docker Desktop unavailable, uppercase registry namespace,
stale Docker credentials, `listenv` restore, unsupported `NanoCPUs`, IPv4
forwarding warning, wrong health port, and login redirect.

The evidence report template must contain:

```markdown
# Deployment Report: <app-id> <immutable-tag>

## Outcome
## Scope and Operation
## Source and Image Provenance
## Pre-Change Live State
## Dev Deployment
## Dev Human Browser Acceptance
## Prod Deployment
## Prod Human Browser Acceptance
## Cross-App Regression Check
## Student-Release Decision
## Rollback Record
## Residual Risks and Follow-Up
```

Explain that angle-bracket fields in the report template are schema markers
to replace in a deployment report, never credentials. Recommend
`docs/ops/deployments/YYYY-MM-DD-<app-id>-deployment.md` when the target repo
has no established deployment-report location.

The resumption protocol must require a fresh state check and continuation from
the last evidenced passing gate; it must forbid rerunning publication or
server mutation merely because chat context was lost.

- [ ] **Step 6: Review and commit the Codex playbook**

Run:

```bash
git diff --check -- deploy/shinyproxy/teaching-app-codex-playbook.md
rg -n '^## Gate [0-9]+:' deploy/shinyproxy/teaching-app-codex-playbook.md
rg -n 'Preconditions|Evidence to Record|Pass Condition|Stop Conditions' deploy/shinyproxy/teaching-app-codex-playbook.md
rg -n 'human|SAML|browser|CSV|Markdown' deploy/shinyproxy/teaching-app-codex-playbook.md
rg -n 'refresh-existing|add-new|rollback' deploy/shinyproxy/teaching-app-codex-playbook.md
rg -n 'kpz308-rpva-practical|kpz308-rpva-practical2|kpz314-sdm-practical' deploy/shinyproxy/teaching-app-codex-playbook.md
```

Expected: gates 0 through 10 are present; every gate has explicit evidence and
stop logic; `git diff --check` exits zero.

Commit:

```bash
git add deploy/shinyproxy/teaching-app-codex-playbook.md
git commit -m "Add Codex ITS teaching app deployment playbook"
```

---

### Task 3: Cross-Playbook Consistency and Final Verification

**Files:**
- Verify: `deploy/shinyproxy/teaching-app-human-playbook.md`
- Verify: `deploy/shinyproxy/teaching-app-codex-playbook.md`
- Modify only if verification exposes a defect in either file.

**Interfaces:**
- Consumes: both completed playbooks.
- Produces: a consistent two-document operational entry point with no conflicting infrastructure facts, app identities, promotion order, or acceptance criteria.

- [ ] **Step 1: Verify shared facts and app identities**

Run:

```bash
for file in \
  deploy/shinyproxy/teaching-app-human-playbook.md \
  deploy/shinyproxy/teaching-app-codex-playbook.md
do
  rg -q 'ecology-r-dev1\.its\.utas\.edu\.au' "${file}"
  rg -q 'ecology-r1\.its\.utas\.edu\.au' "${file}"
  rg -q '/srv/sa-container/ecology-teaching-shiny' "${file}"
  rg -q 'shinyproxy-net' "${file}"
  rg -q 'kpz308-rpva-practical' "${file}"
  rg -q 'kpz308-rpva-practical2' "${file}"
  rg -q 'kpz314-sdm-practical' "${file}"
done
```

Expected: exit zero.

- [ ] **Step 2: Verify namespace, promotion, workspace, and credential safety**

Run:

```bash
rg -n 'git\.its\.utas\.edu\.au/UTAS/.+:' \
  deploy/shinyproxy/teaching-app-human-playbook.md \
  deploy/shinyproxy/teaching-app-codex-playbook.md && exit 1 || true

rg -n 'latest' \
  deploy/shinyproxy/teaching-app-human-playbook.md \
  deploy/shinyproxy/teaching-app-codex-playbook.md

rg -n '#\{proxy\.userId\}' \
  deploy/shinyproxy/teaching-app-human-playbook.md \
  deploy/shinyproxy/teaching-app-codex-playbook.md

rg -n 'dev.*prod|prod.*dev|exact.*tag' \
  deploy/shinyproxy/teaching-app-human-playbook.md \
  deploy/shinyproxy/teaching-app-codex-playbook.md
```

Expected: no uppercase Docker image namespace; every `latest` mention forbids
its use; both files describe per-user workspaces and dev-first promotion.

Review all credential-related lines manually. They may describe safe prompts,
stop rules, or forbidden handling, but must not contain a plausible secret.

- [ ] **Step 3: Verify scaffold and documentation integrity**

Run:

```bash
bash deploy/shinyproxy/practical1/validate-scaffold.sh
git diff --check
git status --short --branch
```

Expected: scaffold validation passes, `git diff --check` exits zero, and only
the two intended playbook files differ from the pre-implementation commit.

Manually verify every repo-relative Markdown link target exists. Confirm the
two playbooks are self-contained and historical goal packets are supporting
evidence rather than required reading.

- [ ] **Step 4: Commit verification fixes if needed**

If Tasks 1-3 reveal defects, fix only those defects and commit:

```bash
git add \
  deploy/shinyproxy/teaching-app-human-playbook.md \
  deploy/shinyproxy/teaching-app-codex-playbook.md
git commit -m "Align teaching app deployment playbooks"
```

If no fixes are needed, do not create an empty commit.

- [ ] **Step 5: Final evidence check**

Run:

```bash
git log --oneline --decorate -4
git diff --check origin/main...HEAD
git status --short --branch
```

Expected: the design commit and two implementation commits are visible; the
working tree is clean; no live deployment action has been performed.
