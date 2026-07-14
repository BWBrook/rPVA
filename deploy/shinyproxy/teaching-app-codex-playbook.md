# ITS Teaching Apps: Codex Deployment Playbook

## Mission

Use this protocol to coordinate a controlled release of one teaching-app
container to the shared ITS ShinyProxy platform. It is written for a fresh
Codex agent with access to the target source repository but no chat history.

The protocol supports three operations:

- `refresh-existing`: publish a new image and change one existing app spec;
- `add-new`: add another app without replacing existing apps;
- `rollback`: restore one app to its previous accepted image.

The target platform can host KPZ308 Practical 1, KPZ308 Practical 2, and the
KPZ314 practical simultaneously. Shared infrastructure does not imply shared
app IDs, images, workspaces, SSO groups, or release decisions.

This document is self-contained. The human-oriented companion is
`deploy/shinyproxy/teaching-app-human-playbook.md`, but reading it is not a
precondition for using this protocol.

## Update This Playbook When

Update this file and the human playbook in the same commit when any of these
facts change:

- dev/prod hostname, browser route, service account, or deployment directory;
- ShinyProxy image/version, Docker network, health endpoint, or restart path;
- Gitea registry or image naming rules;
- app IDs, image repositories, ports, environment, workspaces, or access
  groups;
- human browser acceptance workflow;
- capacity assumptions, student-release gates, or workspace retention policy.

Historical goal packets are provenance. This playbook is the operational
entry point.

## Non-Negotiable Invariants

1. Do not perform live deployment work unless the user has explicitly placed
   that deployment in scope.
2. Never deploy from an uncommitted or ambiguous source tree.
3. The image contents must match the recorded source commit; a Docker build
   argument or label does not switch the build context.
4. Docker image paths use lowercase `utas`. Uppercase `UTAS` is allowed only
   in the Gitea source owner/path.
5. Never deploy `latest`; use a readable immutable tag and record its digest.
6. Dev is changed and accepted before prod is mutated.
7. Prod receives the exact dev-accepted image string and digest, not a rebuild
   or substitute tag.
8. Back up `application.yml` before every server edit.
9. A refresh changes one app's image only. A new app is additive under
   `proxy.specs`.
10. Preserve every unrelated app spec and workspace.
11. Use one workspace subtree per app and one directory per SSO user through
    `#{proxy.userId}`.
12. Do not deploy during active teaching or unexplained user sessions.
13. Never expose credentials or student identifiers in tool output, chat,
    logs committed to Git, or deployment reports.
14. ShinyProxy health proves only the proxy is up. Browser/SAML acceptance is
    separate human evidence.
15. Do not claim a gate passed without fresh output that proves its pass
    condition.

## Current Infrastructure Contract

| Item | Accepted current value |
| --- | --- |
| Dev SSH host | `ecology-r-dev1.its.utas.edu.au` |
| Dev browser root | `https://ecology-r-dev1.its.utas.edu.au` |
| Prod SSH host | `ecology-r1.its.utas.edu.au` |
| Prod browser root | `https://ecology-r1.its.utas.edu.au` |
| Human SSH identity | `bwbrook` |
| Service account | `sa-container` via `sudo -iu sa-container` |
| Deployment directory | `/srv/sa-container/ecology-teaching-shiny` |
| Compose service | `shinyproxy` |
| ShinyProxy image | `openanalytics/shinyproxy:3.2.4` |
| Docker network | `shinyproxy-net` |
| Health endpoint | `http://127.0.0.1:9090/actuator/health` |
| User-facing proxy binding | `127.0.0.1:8080` |
| Registry | `git.its.utas.edu.au` |
| RDS portal | `https://remoteapps.utas.edu.au/RDWeb/Pages/en-US/login.aspx?ReturnUrl=/RDWeb/Pages/en-US/Default.aspx` |
| Shared staff group | `UNI-Ecology-Teaching-Shiny-Staff` |
| Promotion policy | Readable immutable tag in config; digest in evidence; dev first, then same tag on prod. |

Treat this table as an expected contract, not unquestionable live truth. Gate
4 and Gate 8 must reconcile it against the actual servers before mutation. A
drifted ShinyProxy version, path, service, network, or health endpoint is a stop
condition until the operator and ITS understand it.

## Application Inventory

| App | Stable ID | Image repository | Workspace subtree | Student group | State |
| --- | --- | --- | --- | --- | --- |
| KPZ308 Practical 1 | `kpz308-rpva-practical` | `git.its.utas.edu.au/utas/kpz308-rpva-practical` | `data/kpz308-rpva-practical/workspaces` | `KPZ308` | Existing identity; do not rename. |
| KPZ308 Practical 2 | `kpz308-rpva-practical2` | `git.its.utas.edu.au/utas/kpz308-rpva-practical2` | `data/kpz308-rpva-practical2/workspaces` | `KPZ308` | Confirmed permanent identity; use Staff-only access outside approved student release windows. |
| KPZ314 practical | `kpz314-sdm-practical` | Must be confirmed by its project and ITS | Proposed: `data/kpz314-sdm-practical/workspaces` | `KPZ314` | Reserved identity; KPZ314 is in SSO configuration but not yet an app spec. |

The stable browser route is normally `/app/<APP_ID>`. The root launcher must
also be tested because it exposes cross-app regressions.

### Last Validated Practical 1 Baseline

Treat this as historical evidence until Gate 4 and Gate 8 re-observe live
state:

```text
Image:  git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-20260626-9524304fb748
Digest: sha256:7aa013152b226d5ba3fcc34d31051fe049dd0f34c2c7e0187de83580523f4340
Source: 9524304fb74805baad7672f81f219b8455a4aac8
```

Goal 043 recorded that image as passing dev/prod browser smokes, CSV and
Markdown exports, and the production capacity rehearsal. Do not infer that it
is still deployed or that later source commits are represented by it.

## Select the Operation

Use exactly one operation per run:

```text
refresh-existing
add-new
rollback
```

For `refresh-existing`, establish the current dev and prod image tags before
publishing a replacement.

For `add-new`, block before Gate 1 until the app owner and ITS confirm all of:

- stable app ID and display name;
- image repository and server pull permission;
- source repo, Dockerfile, build context, runtime port, and health check;
- environment variables and volume mounts;
- memory and CPU limits;
- SSO registration, staff group, and correct student group;
- unique host workspace subtree;
- app-specific browser workflow and export checks;
- rollback and support ownership.

For `rollback`, start at the Rollback Protocol unless a replacement image
must first be published.

## Deployment Parameter Contract

Resolve and record these values. Do not leave an operational value implicit.

```text
OPERATION
TARGET_REPO
TARGET_BRANCH
SOURCE_REF
APP_ID
APP_DISPLAY_NAME
IMAGE_REPOSITORY
IMAGE_TAG
IMAGE
IMAGE_DIGEST
DOCKERFILE
BUILD_CONTEXT
CONTAINER_PORT
DEV_HOST
DEV_BROWSER_ROOT
PROD_HOST
PROD_BROWSER_ROOT
ACCESS_GROUPS
HOST_WORKSPACE_ROOT
CONTAINER_WORKSPACE_ROOT
EXPECTED_APP_IDS_DEV
EXPECTED_APP_IDS_PROD
PREVIOUS_DEV_TAG
PREVIOUS_PROD_TAG
DEV_CONFIG_BACKUP
PROD_CONFIG_BACKUP
```

For the existing rPVA Practical 1 app, the starting values are:

```bash
OPERATION='refresh-existing'
TARGET_REPO='/home/bwbrook/git/rPVA'
APP_ID='kpz308-rpva-practical'
APP_DISPLAY_NAME='KPZ308 rPVA Practical'
IMAGE_REPOSITORY='git.its.utas.edu.au/utas/kpz308-rpva-practical'
DOCKERFILE='deploy/shinyproxy/practical1/Dockerfile.template'
BUILD_CONTEXT='.'
CONTAINER_PORT='3838'
DEV_HOST='ecology-r-dev1.its.utas.edu.au'
DEV_BROWSER_ROOT='https://ecology-r-dev1.its.utas.edu.au'
PROD_HOST='ecology-r1.its.utas.edu.au'
PROD_BROWSER_ROOT='https://ecology-r1.its.utas.edu.au'
ACCESS_GROUPS='UNI-Ecology-Teaching-Shiny-Staff KPZ308'
HOST_WORKSPACE_ROOT='/srv/sa-container/ecology-teaching-shiny/data/kpz308-rpva-practical/workspaces'
CONTAINER_WORKSPACE_ROOT='/srv/rpva-workspaces/current'
```

Do not reuse rPVA-specific values for KPZ314 without evidence from the KPZ314
repo.

## Authority and Human-Handoff Boundaries

**Codex may perform local actions** when the user has requested the release:

- inspect Git/repo state and instructions;
- run repo tests and static validation;
- build and locally smoke an image;
- prepare token-safe login commands;
- push an authorized image and record non-secret provenance;
- write non-secret deployment evidence.

**Barry remains the normal interactive operator for:**

- GlobalProtect, Docker Desktop GUI, RDS, DUO, and PuTTY;
- `sudo` password entry;
- registry credentials entered into an interactive hidden prompt;
- live server commands supplied by Codex in bounded blocks;
- SAML/browser acceptance and file-download inspection.

An explicitly authorized computer-control route may replace the eyes-and-hands
handoff, but its observations and credentials must obey the same evidence and
secrecy rules.

**ITS owns:** DNS, TLS, SSO application registration, group creation and
membership plumbing, host patching, underlying backup/monitoring, and
platform/resource changes. Codex must request or report these; it must not
simulate their completion.

For PuTTY work, provide one bounded block at a time. State the expected result,
inspect Barry's returned output, and only then issue the next mutating block.
Never queue dev and prod mutations together.

## Evidence Model

Separate each statement as one of:

- **Observed:** command output or human browser result from this release;
- **Inferred:** conclusion supported by observations, with assumptions named;
- **Historical:** previously accepted evidence, not re-observed now;
- **Pending:** required evidence not yet obtained.

Record only non-secret evidence. Redact credentials and avoid copying full
SAML assertions or student identifiers. User IDs in ShinyProxy logs should be
omitted or redacted unless they are essential to an authorized incident.

Each gate records:

```text
gate=
status=pass | fail | blocked | not-run
observed_at_utc=
operator_or_tester_role=
commands_or_browser_workflow=
key_non_secret_output=
inference=
residual_risk=
```

## Gate 0: Reconcile Repo and Live Intent

### Preconditions

- The user has explicitly requested a deployment, promotion, addition, or
  rollback.
- The target repository and app are identified.

### Actions

1. Read global and repo-local `AGENTS.md` files and relevant source/deployment
   docs.
2. Inspect branch, worktree, remote, and recent commits.
3. Select one operation.
4. Populate the parameter contract without credentials.
5. Confirm whether the task includes local publication, live dev mutation,
   live prod mutation, or only preparation.
6. Confirm this is outside an active teaching session.

Use read-only local commands first:

```bash
pwd
git status --short --branch
git remote -v
git log -5 --oneline --decorate
find .. -name AGENTS.md -print
```

### Evidence to Record

- authorization scope;
- operation and app ID;
- repo path, branch, HEAD, upstream state, and worktree cleanliness;
- confirmed versus unresolved parameters;
- class/maintenance-window status.

### Pass Condition

The operation and allowed live surfaces are unambiguous, required parameters
for the next gate are resolved, and no active class is in scope.

### Stop Conditions

- unclear authorization for registry or server mutation;
- unresolved app identity or image repository;
- dirty source tree that cannot be separated safely;
- active teaching session;
- unrelated local changes overlap the release source.

## Gate 1: Validate the Reviewed Source

### Preconditions

- Gate 0 passed.
- `SOURCE_REF`, `DOCKERFILE`, and `BUILD_CONTEXT` are known.

### Actions

Fetch current refs and prove the build context matches the reviewed commit:

```bash
cd "${TARGET_REPO}"
git fetch --prune origin
git status --short --branch
HEAD_REF="$(git rev-parse HEAD)"
test "${HEAD_REF}" = "${SOURCE_REF}"
git show -s --format='source=%H%nsubject=%s' "${HEAD_REF}"
test -z "$(git status --porcelain)"
```

The last check must remain clean before and after validation. If tests or
bootstrap tools generate tracked changes, identify their exact source and
remove only changes created by this run; never discard pre-existing user work.

Use the target repo's own instructions and release tests. For rPVA Practical
1, run:

```bash
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter = "summary")'
bash deploy/shinyproxy/practical1/validate-scaffold.sh
git status --short --branch
```

The first bootstrap in a fresh WSL library may restore packages and take
several minutes. A timeout is not a pass or a test failure; rerun with a
suitable limit and report only completed test output. Investigate unexplained
`renv` drift rather than altering the lockfile to force release.

Passing rPVA tests is not evidence for KPZ314. The KPZ314 agent must use its
own repo's instructions, tests, and acceptance contract.

### Evidence to Record

- exact source commit and subject;
- source-tree cleanliness before and after checks;
- dependency status;
- exact test commands, duration, pass/fail/timeout counts;
- scaffold or deployment-config validation result;
- any generated local-cache behavior kept outside Git.

### Pass Condition

The reviewed committed source is clean, relevant release tests complete
successfully, deployment inputs exist, and no unexplained tracked changes
remain.

### Stop Conditions

- tests fail or do not complete;
- dependency state affecting the image is unexplained;
- build context differs from the recorded source;
- required Dockerfile or app content is absent;
- validation creates a tracked change whose provenance is unclear.

## Gate 2: Build and Smoke the Image

### Preconditions

- Gate 1 passed.
- Docker Desktop is running and integrated with WSL.
- `IMAGE_REPOSITORY` uses a confirmed lowercase registry namespace.

### Actions

Construct a source-linked immutable tag:

```bash
SHORT_SHA="$(git rev-parse --short=12 "${SOURCE_REF}")"
BUILD_DATE="$(date +%Y%m%d)"
IMAGE_TAG="dev-${BUILD_DATE}-${SHORT_SHA}"
IMAGE="${IMAGE_REPOSITORY}:${IMAGE_TAG}"
docker info
```

For rPVA Practical 1, build:

```bash
docker build \
  --platform linux/amd64 \
  -f "${DOCKERFILE}" \
  --build-arg RPVA_REF="${SOURCE_REF}" \
  -t "${IMAGE}" \
  "${BUILD_CONTEXT}"
```

Adapt build arguments for another repo; do not invent an `RPVA_REF` contract
for KPZ314.

Run this Practical 1 local smoke, or the target repo's equivalent:

```bash
SMOKE_NAME="teaching-app-smoke-${SHORT_SHA}"

if ss -ltn '( sport = :3838 )' | grep -q LISTEN; then
  echo 'Port 3838 is in use.' >&2
  exit 1
fi

cleanup_smoke() {
  docker rm -f "${SMOKE_NAME}" >/dev/null 2>&1 || true
}
trap cleanup_smoke EXIT

docker run -d \
  --name "${SMOKE_NAME}" \
  -p 127.0.0.1:3838:3838 \
  "${IMAGE}"

for attempt in $(seq 1 60); do
  STATUS="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "${SMOKE_NAME}")"
  [ "${STATUS}" = 'healthy' ] && break
  if [ "${STATUS}" = 'exited' ] || [ "${STATUS}" = 'unhealthy' ]; then
    docker logs "${SMOKE_NAME}"
    exit 1
  fi
  sleep 2
done

test "${STATUS}" = 'healthy'
curl -fsS http://127.0.0.1:3838/ > /tmp/teaching-app-smoke.html
grep -E 'KPZ308|Practical|rPVA|Shiny' /tmp/teaching-app-smoke.html
cleanup_smoke
trap - EXIT
```

### Evidence to Record

- image string, local image ID, architecture, and source label;
- build command and exit status;
- local container health and HTTP marker;
- app logs if any warning occurred;
- confirmation that the smoke container was removed.

### Pass Condition

The image builds for `linux/amd64`, becomes healthy, serves expected app
content, and leaves no smoke container running.

### Stop Conditions

- Docker daemon unavailable;
- uppercase or unconfirmed repository path;
- build failure;
- image health failure, exit, or timeout;
- HTTP or content-marker failure;
- unreviewed runtime difference from the target host contract.

## Gate 3: Publish the Immutable Image

### Preconditions

- Gate 2 passed.
- Registry publication is explicitly authorized.
- Barry has a valid Gitea credential but has not pasted it into chat.

### Actions

Have Barry enter credentials through a hidden prompt:

```bash
read -rp 'Gitea username: ' GITEA_USER
read -rsp 'Gitea token or password: ' GITEA_TOKEN
printf '\n'
printf '%s' "${GITEA_TOKEN}" | docker login git.its.utas.edu.au \
  --username "${GITEA_USER}" \
  --password-stdin
unset GITEA_TOKEN
```

If Docker reuses stale credentials, run
`docker logout git.its.utas.edu.au` and repeat the block.

Push without allowing `tee` to mask failure:

```bash
set -o pipefail
docker push "${IMAGE}" | tee "push-${IMAGE_TAG}.log"
docker image inspect "${IMAGE}" \
  --format 'id={{.Id}} repoDigests={{json .RepoDigests}}'
docker buildx imagetools inspect "${IMAGE}" \
  | tee "manifest-${IMAGE_TAG}.txt"
IMAGE_DIGEST="$(awk '/^Digest:/ {print $2; exit}' "manifest-${IMAGE_TAG}.txt")"
test -n "${IMAGE_DIGEST}"
```

Optionally log out after digest capture. Store only non-secret logs and
summaries.

### Evidence to Record

- full immutable image string;
- source commit;
- push exit status;
- registry digest and local image ID;
- manifest architecture when available;
- logout result class, if performed.

### Pass Condition

Push succeeds, the registry manifest resolves, and a digest is recorded for
the exact source-linked tag.

### Stop Conditions

- login denied or wrong account;
- push denied or partial;
- pipeline failure;
- manifest unavailable after a reported push;
- digest missing or inconsistent;
- any credential appears in output intended for chat or Git.

## Gate 4: Discover and Back Up Dev

### Preconditions

- Gate 3 passed, or a previously published accepted image is in scope.
- Dev mutation is authorized.
- Barry can reach the RDS jump host and DUO.

### Actions

Tell Barry to open the RDS portal, launch PuTTY, connect to
`ecology-r-dev1.its.utas.edu.au` as `bwbrook`, and run this first bounded block:

```bash
hostname -f
whoami
sudo -iu sa-container
whoami
cd /srv/sa-container/ecology-teaching-shiny
pwd
docker compose ps
docker compose config --services
curl -fsS http://127.0.0.1:9090/actuator/health
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
grep -nE '^[[:space:]]+- id:|container-image:|access-groups:|workspaces/' application.yml
```

Inspect the returned output before sending any mutation. Reconcile hostname,
user, path, service, ShinyProxy status/version, health endpoint, current app
IDs/images/groups/workspaces, and active `sp-container-*` sessions.

Then set remote-shell values with the exact published image and complete
expected inventory. WSL variables do not carry into PuTTY:

```bash
APP_ID='kpz308-rpva-practical'
IMAGE='git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-YYYYMMDD-SHORTSHA'
EXPECTED_APP_IDS='kpz308-rpva-practical'
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="application.yml.before-${APP_ID}-${STAMP}"
cp -p application.yml "${BACKUP}"
ls -l "${BACKUP}"
```

Replace metavariables before execution. Record the current selected image as
`PREVIOUS_DEV_TAG` and the backup as `DEV_CONFIG_BACKUP`.

### Evidence to Record

- actual dev hostname, user, path, compose service, proxy image, and health;
- current app ID/image/group/workspace inventory;
- active-session count and maintenance-window confirmation;
- previous dev image tag;
- timestamped config backup path and permissions.

### Pass Condition

Live dev matches or acceptably explains the infrastructure contract, no active
teaching session exists, all expected apps are inventoried, and a readable
backup exists before mutation.

### Stop Conditions

- wrong host or user;
- unexpected path, service, network, proxy version, or unhealthy state;
- active or unexplained `sp-container-*` session;
- missing expected app spec;
- current image or previous tag cannot be identified;
- backup fails;
- returned output includes secrets or unneeded personal identifiers.

## Gate 5: Update One Dev App Spec

### Preconditions

- Gate 4 passed.
- `BACKUP`, `APP_ID`, `IMAGE`, and the complete expected app inventory exist
  in the remote shell.

### Actions

For `refresh-existing`, instruct Barry to run `vi application.yml` and change
only the selected spec's `container-image` line.

For `add-new`, add a new list item under `proxy.specs`. Do not replace an
existing item. This is the confirmed Practical 2 shape; replace the immutable
tag with the Task 2 accepted tag.

```yaml
    - id: "kpz308-rpva-practical2"
      display-name: "KPZ308 rPVA Practical 2"
      description: "KPZ308 Practical 2"
      container-image: "git.its.utas.edu.au/utas/kpz308-rpva-practical2:dev-YYYYMMDD-SHORTSHA"
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

The immutable tag is a documentation value until replaced with the Task 2
accepted tag. Resource limits are validated Practical 1 values, not automatic
defaults. KPZ314 must use its confirmed environment and `KPZ314` student group.

For a new Practical 2 app, create its workspace parent as `sa-container`:

```bash
mkdir -p data/kpz308-rpva-practical2/workspaces
chmod 0750 data/kpz308-rpva-practical2 data/kpz308-rpva-practical2/workspaces
ls -ldZ data/kpz308-rpva-practical2 data/kpz308-rpva-practical2/workspaces
```

Use a distinct KPZ314 path. Do not alter SELinux labels manually; retain `:z`
and escalate access denial to ITS.

Review the edit and prove all app IDs remain:

```bash
diff -u "${BACKUP}" application.yml || true
grep -nE '^[[:space:]]+- id:' application.yml
for expected in ${EXPECTED_APP_IDS}; do
  grep -qE "^[[:space:]]+- id: [\"']?${expected}[\"']?[[:space:]]*$" application.yml || {
    echo "Missing app spec: ${expected}" >&2
    exit 1
  }
done
docker pull "${IMAGE}"
docker image inspect "${IMAGE}" \
  --format 'id={{.Id}} repoDigests={{json .RepoDigests}}'
```

For `add-new`, include the new ID in `EXPECTED_APP_IDS` before the loop.
Compare the pulled digest to Gate 3.

### Evidence to Record

- redacted before/after diff limited to the intended spec;
- complete app-ID inventory after edit;
- workspace parent ownership/SELinux context for a new app;
- pulled image string, image ID, and digest;
- confirmation that unrelated SAML, groups, specs, and workspaces are intact.

### Pass Condition

The dev config contains the intended one-app change, every expected app ID
remains, the selected image pulls with the published digest, and any new
workspace parent is ready.

### Stop Conditions

- unrelated config changed;
- expected app disappeared or a duplicate ID exists;
- new app identity/group/workspace remains provisional;
- image pull denied or digest mismatch;
- workspace ownership or SELinux access is wrong;
- complete config must be pasted into chat to continue.

## Gate 6: Restart and Verify ShinyProxy on Dev

### Preconditions

- Gate 5 passed.
- No active user sessions exist.
- Immediate config rollback is available.

### Actions

Use the ITS-confirmed restart path:

```bash
docker compose down
docker compose up -d
docker compose ps
HEALTH_OK=0
for attempt in $(seq 1 30); do
  if curl -fsS http://127.0.0.1:9090/actuator/health; then
    HEALTH_OK=1
    break
  fi
  sleep 2
done
test "${HEALTH_OK}" -eq 1
docker logs --tail 120 shinyproxy
```

A less disruptive restart may be substituted only after ITS confirms it
reloads the bind-mounted config.

If startup fails, restore the backup and recover the proxy before further
diagnosis:

```bash
cp -p "${BACKUP}" application.yml
docker compose down
docker compose up -d
curl -fsS http://127.0.0.1:9090/actuator/health
docker logs --tail 120 shinyproxy
```

### Evidence to Record

- compose down/up exit status;
- health response and time to readiness;
- compose state and ShinyProxy image;
- startup logs, with YAML/SAML/socket/image warnings highlighted;
- whether recovery was required.

### Pass Condition

ShinyProxy restarts, reports `UP`, retains the expected app specs, and shows no
release-blocking startup error.

### Stop Conditions

- proxy does not become healthy within the bounded wait;
- config/YAML parsing failure;
- Docker socket, network, SAML, or app-spec initialization failure;
- unexpected restart loop;
- backup recovery fails.

## Gate 7: Human SAML and Browser Acceptance on Dev

### Preconditions

- Gate 6 passed.
- An authorized staff tester can use SAML and the selected app.

### Actions

Ask Barry or the tester to open the dev root launcher in a normal browser:

```text
https://ecology-r-dev1.its.utas.edu.au
```

For Practical 1, request the result of each check separately:

1. SAML login succeeds.
2. Every expected app tile is present.
3. `kpz308-rpva-practical` opens and its container becomes healthy.
4. Baseline starts or restores.
5. One changed scenario runs; include environmental stochasticity in the
   established smoke.
6. Compare shows baseline plus the changed run.
7. CSV downloads, opens, has expected columns, and contains non-empty rows.
8. Markdown evidence notes download and include settings, provenance,
   comparison evidence, and interpretation prompts.
9. Returning to the launcher confirms unrelated app tiles remain.

For a new app, use its pre-approved equivalent: default/baseline workflow,
one changed workflow, main comparison/output, promised exports, and launcher
regression check. A tile opening is not sufficient.

Request supporting server output after app launch when useful:

```bash
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
docker logs --tail 120 shinyproxy | grep -Ei 'Starting proxy|Proxy activated|error|warn' || true
```

### Evidence to Record

- tester role, timestamp, browser root, app ID, and exact image tag;
- SAML, tile, workflow, comparison/output, and export results;
- selected app container health/activation;
- unrelated-app launcher result;
- warnings or deviations.

Do not record the tester's token, full SAML assertion, or unnecessary personal
identifier.

### Pass Condition

Every app-specific browser check and the cross-app launcher check passes, with
human-observed export evidence where applicable.

### Stop Conditions

- SAML/access denial;
- selected or unrelated app tile missing;
- app fails to start or becomes unhealthy;
- workflow, output, or export fails;
- tester result is ambiguous;
- only proxy health, curl, or server logs are available.

## Gate 8: Promote the Exact Accepted Tag to Prod

### Preconditions

- Gate 7 passed and is recorded.
- Prod mutation is explicitly authorized.
- `IMAGE` and `IMAGE_DIGEST` exactly match accepted dev evidence.
- No prod class or unexplained session is active.

### Actions

Before issuing prod commands, compare the accepted values:

```text
dev accepted image = IMAGE
dev accepted digest = IMAGE_DIGEST
prod proposed image = IMAGE
prod proposed digest = IMAGE_DIGEST
```

Do not rebuild or retag.

Have Barry connect through RDS/PuTTY to
`ecology-r1.its.utas.edu.au`, become `sa-container`, and run discovery:

```bash
hostname -f
sudo -iu sa-container
cd /srv/sa-container/ecology-teaching-shiny
docker compose ps
docker compose config --services
curl -fsS http://127.0.0.1:9090/actuator/health
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
grep -nE '^[[:space:]]+- id:|container-image:|access-groups:|workspaces/' application.yml
```

Inspect output. Then repeat Gates 4-6 on prod with freshly set remote values,
a prod timestamped backup, `PREVIOUS_PROD_TAG`, complete prod app inventory,
the exact accepted image pull/digest, and the ITS-confirmed restart. The
bounded prod mutation block is:

```bash
APP_ID='kpz308-rpva-practical'
IMAGE='git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-YYYYMMDD-SHORTSHA'
EXPECTED_APP_IDS='kpz308-rpva-practical'
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="application.yml.before-${APP_ID}-${STAMP}"
cp -p application.yml "${BACKUP}"
ls -l "${BACKUP}"
vi application.yml
diff -u "${BACKUP}" application.yml || true
for expected in ${EXPECTED_APP_IDS}; do
  grep -qE "^[[:space:]]+- id: [\"']?${expected}[\"']?[[:space:]]*$" application.yml || exit 1
done
docker pull "${IMAGE}"
docker image inspect "${IMAGE}" \
  --format 'id={{.Id}} repoDigests={{json .RepoDigests}}'
docker compose down
docker compose up -d
docker compose ps
HEALTH_OK=0
for attempt in $(seq 1 30); do
  if curl -fsS http://127.0.0.1:9090/actuator/health; then
    HEALTH_OK=1
    break
  fi
  sleep 2
done
test "${HEALTH_OK}" -eq 1
docker logs --tail 120 shinyproxy
```

Replace the tag and inventory before execution. For `add-new`, create the
confirmed prod workspace parent and include the new app ID in
`EXPECTED_APP_IDS` before the inventory loop.

### Evidence to Record

- prod pre-change infrastructure and app inventory;
- no-active-session confirmation;
- previous prod tag and config backup;
- exact equality of proposed prod and accepted dev image/digest;
- one-app diff, full post-edit inventory, pull digest;
- compose, health, and logs after restart.

### Pass Condition

Prod runs the exact dev-accepted image, ShinyProxy is healthy, all expected app
specs remain, and no release-blocking log error is present.

### Stop Conditions

- prod differs materially from accepted infrastructure without explanation;
- active user session;
- image/digest differs from dev acceptance;
- unrelated config change or missing app;
- pull, restart, health, or log failure;
- dev acceptance was never completed.

## Gate 9: Human SAML and Browser Acceptance on Prod

### Preconditions

- Gate 8 passed.
- An authorized staff tester can access prod.

### Actions

Repeat the complete Gate 7 workflow at:

```text
https://ecology-r1.its.utas.edu.au
```

Use the root launcher and selected app route. Verify the selected app's full
workflow and exports, plus every expected app tile.

### Evidence to Record

- tester role, timestamp, prod root, app ID, image and digest;
- SAML, tile, workflow, output, export, and unrelated-app results;
- selected app container health and activation logs;
- any difference from dev.

### Pass Condition

The full human browser workflow passes on prod and cross-app availability is
preserved.

### Stop Conditions

- any Gate 7 browser condition fails on prod;
- only host/proxy health evidence is available;
- prod behavior or exports differ unexpectedly from accepted dev behavior.

## Gate 10: Student-Release Readiness

### Preconditions

- Gate 9 passed.
- Release timing and intended class are known.

### Actions

Obtain explicit answers for:

- approved student-facing URL and teaching-channel wording;
- correct student group (`KPZ308` for both KPZ308 apps; `KPZ314` for KPZ314);
- staff group access and one current staff smoke;
- fallback documents and instructor route;
- support owner and ITS escalation path;
- rollback owner, previous image, and config backup;
- health/log/resource/disk/workspace monitoring plan;
- workspace retention and cleanup owner/date;
- class timing and a no-change window before teaching.

Do not rerun the historical 5/10/20/40/60-container capacity rehearsal for a
content-only update. Rerun it when runtime, resource limits, ShinyProxy, host
capacity, or expected concurrency changes materially. Historical capacity was
container/R-workload evidence, not 60 distinct SAML identities.

### Evidence to Record

- student-release decision and decision owner;
- URL, class group, staff smoke, fallback, support, rollback, monitoring, and
  cleanup readiness;
- capacity-retest decision and reason;
- release time and freeze window.

### Pass Condition

Technical prod acceptance and all teaching-release controls are green, and an
authorized human explicitly approves student release.

### Stop Conditions

- wrong or untested access group;
- unapproved URL or wording;
- no fallback, support owner, rollback, monitoring, or cleanup plan;
- material capacity/runtime change without appropriate rehearsal;
- pressure to infer student readiness from staff or container health alone.

## Rollback Protocol

Rollback is scoped to one app.

1. Stop new release activity and confirm no active class/session.
2. Record failing app, tag, digest, gate, symptom, and rollback decision owner.
3. Confirm the prior image is present or pullable.
4. Inspect changes since the backup.
5. If no unrelated config change occurred, restore the timestamped backup.
6. If another app or SSO setting changed, edit only the failed app's image back
   to its previous tag; do not restore the entire old config.
7. Verify every expected app ID remains.
8. Restart ShinyProxy, wait for health, and inspect logs.
9. Complete the app-specific browser smoke and root-launcher regression check.
10. Preserve the failed image, logs, and workspace until diagnosis is complete.

Immediate whole-backup restoration shape:

```bash
diff -u "${BACKUP}" application.yml || true
cp -p "${BACKUP}" application.yml
docker compose down
docker compose up -d
docker compose ps
curl -fsS http://127.0.0.1:9090/actuator/health
docker logs --tail 120 shinyproxy
```

Roll back prod first for a prod-only problem. Roll back dev too when the same
image is rejected there. Never remove unrelated app specs, images, or
workspaces during rollback.

## Known Failure Signatures

| Observation | Diagnosis/action |
| --- | --- |
| WSL `docker info` cannot reach the daemon | Docker Desktop or WSL integration is unavailable. Ask Barry to start/check Docker Desktop; do not install a second daemon. |
| Docker rejects uppercase repository name | Use lowercase `utas` in the image path. Uppercase `UTAS` belongs only to the source repository URL. |
| `docker login` silently reuses the wrong account/token | Log out of `git.its.utas.edu.au`, then use the hidden prompt and `--password-stdin`. |
| Docker build fails around `listenv` during restore | Verify the rPVA Practical 1 Dockerfile installs locked `listenv` 0.10.1 before `renv::restore()`. Do not apply this fix blindly to another repo. |
| Manual capacity container reports `NanoCPUs can not be set` | The RedHat/rootless kernel did not expose that CFS control. Omit `--cpus` from that manual rehearsal command; do not silently change ShinyProxy's configured limit. |
| Docker warns `IPv4 forwarding is disabled` | Record it and test the required workload. Historical R workloads passed; network-dependent app behavior still needs browser/runtime evidence. |
| Health request returns 404 | Verify port 9090 and `/actuator/health`. Port 8080 is the user route. |
| Curl to app route redirects to `/login` | Expected without SAML browser state. Use human browser acceptance. |
| Proxy health is `UP` but app fails | Inspect selected image, proxy activation logs, app container health/logs, network, workspace permissions/SELinux, and the browser workflow. |
| New app is absent from launcher | Check YAML indentation under `proxy.specs`, unique ID, access groups, SSO membership, restart logs, and whether the tester belongs to the allowed group. |
| Image pull is denied on a new repository | Stop and ask ITS/Gitea owners to grant the service account access. Do not transfer credentials into server config. |

## Capacity-Retest Decision

Historical prod rehearsal passed at 5, 10, 20, 40, and 60 temporary app
containers; every prescribed R workload succeeded and ITS reported CPU/RAM
headroom. Treat that as historical evidence only.

Retest capacity when at least one of these changes:

- base image, R runtime, or app process model;
- per-container memory or CPU limit;
- ShinyProxy version or Docker/rootless configuration;
- host sizing or competing workload;
- simulation workload complexity or memory profile;
- expected concurrency above the prior envelope.

Do not use `--cpus` in manual host rehearsal until ITS confirms CFS support.
A capacity retest does not replace SAML/browser concurrency evidence.

## Deployment Evidence Report Template

Use the target repo's established report location. If none exists, use:

```text
docs/ops/deployments/YYYY-MM-DD-<app-id>-deployment.md
```

Angle-bracket fields below are report schema markers to replace, never
credentials.

```markdown
# Deployment Report: <app-id> <immutable-tag>

## Outcome

Status: accepted | rolled back | blocked
Student release: go | no-go | pending

## Scope and Operation

- Operation:
- Authorized live surfaces:
- Maintenance window:

## Source and Image Provenance

- Source repository:
- Source commit:
- Dockerfile/build context:
- Image:
- Digest:
- Build and local-smoke result:

## Pre-Change Live State

- Dev previous tag and config backup:
- Prod previous tag and config backup:
- Expected app inventory:
- Active-session check:

## Dev Deployment

- Config delta:
- Pull/digest:
- Compose/health/logs:

## Dev Human Browser Acceptance

- Tester role and timestamp:
- SAML and tile result:
- Workflow/output/export result:
- Cross-app launcher result:

## Prod Deployment

- Exact dev/prod image equality:
- Config delta:
- Pull/digest:
- Compose/health/logs:

## Prod Human Browser Acceptance

- Tester role and timestamp:
- SAML and tile result:
- Workflow/output/export result:

## Cross-App Regression Check

- Expected app IDs:
- Dev launcher result:
- Prod launcher result:
- Workspace isolation result:

## Student-Release Decision

- URL/group:
- Staff smoke:
- Fallback/support/rollback/monitoring/cleanup:
- Decision and owner:

## Rollback Record

- Previous tags and backups:
- Rollback invoked:
- Recovery/browser result:

## Residual Risks and Follow-Up

- Observation:
- Inference and assumptions:
- Owner and due point:
```

## Interrupted-Session Resumption

Context loss is not authorization to rerun work.

1. Read the deployment report and last gate evidence.
2. Refresh Git state, registry manifest if relevant, and live server state.
3. Reconcile whether any human or agent changed the target since the last
   evidence.
4. Continue from the last freshly verified passing gate.
5. Never repush an image, re-edit config, restart a server, or repeat prod
   promotion merely because the chat history is unavailable.
6. If live state and recorded state disagree, stop and resolve the discrepancy
   before mutation.

## Completion Criteria

A deployment task is complete only when all in-scope gates have evidence and:

- source commit, immutable image, and digest are recorded;
- dev passed server and human browser acceptance;
- prod, when in scope, runs the exact dev-accepted image and passed human
  browser acceptance;
- every expected app remains visible and workspace identities are separate;
- student-release decision is explicit rather than inferred;
- previous tags, config backups, and rollback owner are recorded;
- no credentials or student identifiers were persisted;
- repo changes are limited to authorized non-secret evidence/docs;
- residual risks and owners are named;
- no required command session remains running.

If browser evidence is pending, say `server deployment complete; browser
acceptance pending`. If prod is not authorized, say `dev accepted; prod not
run`. Precise partial status is preferable to a false completion claim.
