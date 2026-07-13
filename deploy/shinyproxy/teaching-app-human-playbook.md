# ITS Teaching Apps: Human Deployment Playbook

## What This Playbook Is For

Use this playbook to publish and deploy a teaching-app container to the shared
ITS ShinyProxy service. It is written for a human moving between Windows,
WSL, the ITS RDS jump host, PuTTY, and a normal web browser.

It covers three jobs:

1. refresh an existing app with a new image;
2. add a new app alongside the existing apps;
3. roll back one app after a failed release.

The platform is intended to host all three teaching apps at the same time:

- KPZ308 Practical 1;
- KPZ308 Practical 2;
- KPZ314 practical.

Do not use this playbook during an active class. Do not put passwords, access
tokens, student identifiers, or private keys into this repository, chat, or a
saved command transcript.

## Update This Playbook When

Update both this file and
`deploy/shinyproxy/teaching-app-codex-playbook.md` when any of these change:

- dev or prod hostname;
- deployment directory or service account;
- ShinyProxy version, Docker network, or restart procedure;
- Gitea registry path;
- application ID, image repository, port, environment, or workspace path;
- SSO/access-group name;
- workspace retention policy;
- required browser smoke workflow.

Historical goal packets are supporting evidence. This playbook is the normal
operational starting point.

## Choose Your Task

**Refresh an existing app:** build and push a new immutable image, change only
that app's `container-image` line on dev, test it, then promote the exact same
image to prod.

**Add a new app:** first confirm its stable app ID, image repository, runtime,
access groups, workspace path, SSO registration, and browser smoke. Add a new
item under `proxy.specs`; never overwrite another app's item.

**Roll back one app:** restore its previous image tag, or restore the complete
config backup only when no unrelated config changes have happened since the
backup. Then restart and repeat the browser smoke.

## Platform Map: Where Each Command Runs

Every command block is labelled. Do not paste a block into a different
environment.

| Label | Environment | Work performed there |
| --- | --- | --- |
| `WINDOWS` | Windows browser, PowerShell, and desktop | GlobalProtect, Docker Desktop startup, RDS web portal, DUO, PuTTY launch, and final browser smoke. |
| `WSL` | Ubuntu bash in WSL | Git checkout, R validation, Docker build, local smoke, Gitea login, push, and digest capture. |
| `PUTTY` | PuTTY reached through the RDS jump host | SSH to dev or prod and become `sa-container`. |
| `REMOTE` | RedHat shell as `sa-container` | Inspect and back up config, pull images, update ShinyProxy, check health/logs, and roll back. |

Variables set in WSL do not carry into PuTTY. Set the remote variables again
after entering each server.

## Current Shared Infrastructure

| Item | Current value |
| --- | --- |
| Dev host and browser root | `ecology-r-dev1.its.utas.edu.au` / `https://ecology-r-dev1.its.utas.edu.au` |
| Prod host and browser root | `ecology-r1.its.utas.edu.au` / `https://ecology-r1.its.utas.edu.au` |
| SSH login | `bwbrook` |
| Service account | `sa-container` |
| Deployment directory | `/srv/sa-container/ecology-teaching-shiny` |
| Compose service | `shinyproxy` |
| ShinyProxy image | `openanalytics/shinyproxy:3.2.4` |
| Health endpoint | `http://127.0.0.1:9090/actuator/health` |
| User-facing local proxy port | `127.0.0.1:8080` |
| Docker network | `shinyproxy-net` |
| Registry | `git.its.utas.edu.au` |
| RDS jump-host portal | `https://remoteapps.utas.edu.au/RDWeb/Pages/en-US/login.aspx?ReturnUrl=/RDWeb/Pages/en-US/Default.aspx` |
| Staff access group | `UNI-Ecology-Teaching-Shiny-Staff` |

Docker image paths must use lowercase `utas`, for example:

```text
git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-YYYYMMDD-SHORTSHA
```

The Gitea source repository owner may remain uppercase, for example:

```text
https://git.its.utas.edu.au/UTAS/kpz308-rpva-practical.git
```

Do not use uppercase `UTAS` in a Docker image name.

## Teaching App Inventory

| App | Stable ShinyProxy ID | Image repository | Host workspace subtree | Student group | Status |
| --- | --- | --- | --- | --- | --- |
| KPZ308 Practical 1 | `kpz308-rpva-practical` | `git.its.utas.edu.au/utas/kpz308-rpva-practical` | `data/kpz308-rpva-practical/workspaces` | `KPZ308` | Existing deployed identity; keep it stable. |
| KPZ308 Practical 2 | `kpz308-rpva-practical2` | Confirm before first deployment | Proposed: `data/kpz308-rpva-practical2/workspaces` | `KPZ308` | Recommended ID; Barry and ITS must confirm it. |
| KPZ314 practical | `kpz314-sdm-practical` | Confirm with the KPZ314 project and ITS | Proposed: `data/kpz314-sdm-practical/workspaces` | `KPZ314` | ID reserved; KPZ314 is registered in SSO but is not yet an app spec here. |

All three may be visible simultaneously. Each needs a separate app ID,
image, workspace subtree, and rollback record. The same staff group may be
used when ITS confirms its membership. Never add `KPZ314` to a KPZ308 app or
`KPZ308` to the KPZ314 app merely because they share a proxy.

The browser route for an app is normally `/app/<APP_ID>`, such as:

```text
https://ecology-r1.its.utas.edu.au/app/kpz308-rpva-practical
```

Use the root launcher during acceptance testing as well, because it proves
that unrelated app tiles remain present.

### Last Validated Practical 1 Baseline

Goal 043 recorded this image as passing dev and prod browser smokes, exports,
and the production capacity rehearsal:

```text
Image:  git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-20260626-9524304fb748
Digest: sha256:7aa013152b226d5ba3fcc34d31051fe049dd0f34c2c7e0187de83580523f4340
Source: 9524304fb74805baad7672f81f219b8455a4aac8
```

This is historical rollback/provenance evidence, not proof of current live
state. Read the actual dev and prod config before every deployment.

## Safety Rules

- Use a committed, reviewed source tree with no unexpected local changes.
- Build the exact source recorded in the release note.
- Use a readable immutable tag; never deploy `latest`.
- Record the digest, but keep the readable tag in `application.yml`.
- Deploy dev first. Prod receives the exact image accepted on dev.
- Stop if a class or unexplained `sp-container-*` session is active.
- Back up `application.yml` before every edit.
- Change one app spec at a time.
- Confirm all expected app IDs remain after editing.
- Keep one host workspace subtree per app and one directory per SSO user.
- Treat ShinyProxy health as infrastructure evidence, not proof that the app
  works in a browser.
- Keep the static teaching fallback ready before student release.
- Do not delete images, app specs, or workspaces as part of a normal update.

## Deployment Record

Write these values into a non-secret release note before changing dev. Do not
continue if you cannot identify the previous tag.

```text
OPERATION=refresh-existing | add-new | rollback
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

## Phase 1: Prepare Windows, VPN, and Docker Desktop

`WINDOWS` - connect GlobalProtect if the registry or ITS route requires it.
Start Docker Desktop from the Start menu, or use PowerShell:

```powershell
Start-Process "$Env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
wsl.exe --status
wsl.exe -d Ubuntu
```

Docker Desktop may already be running. The WSL-side `docker info` command in
Phase 2, not the Windows process alone, proves that WSL integration is ready.
DUO and GlobalProtect remain normal GUI interactions.

## Phase 2: Select and Validate Source in WSL

The commands below are the worked example for KPZ308 Practical 1 in this
repository. A KPZ308 Practical 2 or KPZ314 deployment must use that project's
actual checkout, tests, Dockerfile, and confirmed image repository.

`WSL` - enter the rPVA checkout and bring it to the reviewed commit. This
example uses the current checked-out commit, so first make sure `HEAD` is the
release you intend to deploy.

```bash
cd /home/bwbrook/git/rPVA
git fetch --prune origin
git status --short --branch
git show -s --format='source=%H%nsubject=%s' HEAD
```

Stop if the working tree is dirty, if the branch is not the reviewed release
branch, or if the displayed commit is not the intended source. The Dockerfile
copies the current build context; its `RPVA_REF` argument is a provenance
label, not a command that switches the source tree.

Set the Practical 1 build values:

```bash
APP_ID='kpz308-rpva-practical'
REVIEWED_REF="$(git rev-parse HEAD)"
SHORT_SHA="$(git rev-parse --short=12 HEAD)"
BUILD_DATE="$(date +%Y%m%d)"
IMAGE_REPOSITORY='git.its.utas.edu.au/utas/kpz308-rpva-practical'
TAG="dev-${BUILD_DATE}-${SHORT_SHA}"
IMAGE="${IMAGE_REPOSITORY}:${TAG}"
printf 'app=%s\nsource=%s\nimage=%s\n' "${APP_ID}" "${REVIEWED_REF}" "${IMAGE}"
```

Run the repo checks. `bootstrap.R` may populate the local `renv` cache on a
new machine, so allow time for the first run.

```bash
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter = "summary")'
bash deploy/shinyproxy/practical1/validate-scaffold.sh
docker info
```

Expected result: bootstrap completes, relevant tests pass, the scaffold
validator prints its success line, and `docker info` reports the Docker
Desktop engine. Investigate an unexplained `renv` difference; do not amend the
lockfile merely to make a deployment proceed.

## Phase 3: Build and Smoke the Image in WSL

`WSL` - build for the ITS hosts' `linux/amd64` architecture:

```bash
docker build \
  --platform linux/amd64 \
  -f deploy/shinyproxy/practical1/Dockerfile.template \
  --build-arg RPVA_REF="${REVIEWED_REF}" \
  -t "${IMAGE}" \
  .
```

Run a bounded smoke. It checks that port 3838 is free, waits for the image
health check, tests the page, and removes the test container even on failure.

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

docker run -d \
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

Stop if the build, health check, HTTP request, or expected page marker fails.
Do not publish an image that has not passed its local smoke.

## Phase 4: Log In, Push, and Record the Digest

`WSL` - use your Gitea username and an approved token or password. Input is
hidden and passed through standard input, so it does not appear as a command
argument.

```bash
read -rp 'Gitea username: ' GITEA_USER
read -rsp 'Gitea token or password: ' GITEA_TOKEN
printf '\n'
printf '%s' "${GITEA_TOKEN}" | docker login git.its.utas.edu.au \
  --username "${GITEA_USER}" \
  --password-stdin
unset GITEA_TOKEN
```

If Docker says it is authenticating with existing credentials and you need to
replace them, run:

```bash
docker logout git.its.utas.edu.au
```

Then repeat the safe login block.

Push with pipeline failure propagation and capture the registry manifest:

```bash
set -o pipefail
docker push "${IMAGE}" | tee "push-${TAG}.log"
docker image inspect "${IMAGE}" \
  --format 'id={{.Id}} repoDigests={{json .RepoDigests}}'
docker buildx imagetools inspect "${IMAGE}" | tee "manifest-${TAG}.txt"
DIGEST="$(awk '/^Digest:/ {print $2; exit}' "manifest-${TAG}.txt")"
test -n "${DIGEST}"
printf 'image=%s\ndigest=%s\nsource=%s\n' "${IMAGE}" "${DIGEST}" "${REVIEWED_REF}"
```

Record `IMAGE`, `DIGEST`, and `REVIEWED_REF` in the deployment record. Stop if
push or digest capture fails. Do not ask ITS to deploy a partially published
image.

You may log out after recording the manifest:

```bash
docker logout git.its.utas.edu.au
```

## Phase 5: Enter the ITS Jump Host and Open PuTTY

`WINDOWS` - open the RDS portal:

[UTAS RemoteApps](https://remoteapps.utas.edu.au/RDWeb/Pages/en-US/login.aspx?ReturnUrl=/RDWeb/Pages/en-US/Default.aspx)

Complete the UTAS login and DUO prompt. Launch the remote desktop or published
PuTTY application. In PuTTY, connect first to dev:

```text
ecology-r-dev1.its.utas.edu.au
```

Log in as `bwbrook`. When dev has passed and you reach Phase 10, open a new
PuTTY session to:

```text
ecology-r1.its.utas.edu.au
```

## Phase 6: Inspect Dev Before Changing It

`PUTTY` / `REMOTE` - verify the host, become the service user, and enter the
deployment directory:

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
```

Expected result: the hostname is dev, the second `whoami` is `sa-container`,
the compose service is `shinyproxy`, and health reports `"status":"UP"`.

Set remote values independently of WSL. Replace the date and short SHA with
the exact pushed tag. List every app ID that is currently meant to exist:

```bash
APP_ID='kpz308-rpva-practical'
IMAGE='git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-YYYYMMDD-SHORTSHA'
EXPECTED_APP_IDS='kpz308-rpva-practical'
```

After the other apps are deployed, a typical inventory will be:

```bash
EXPECTED_APP_IDS='kpz308-rpva-practical kpz308-rpva-practical2 kpz314-sdm-practical'
```

Inspect active containers and the redacted shape of the app specs:

```bash
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
grep -nE '^[[:space:]]+- id:|container-image:|access-groups:|workspaces/' application.yml
```

Stop if a class is under way or an unexplained `sp-container-*` session is
active. Ask the user to close the app and wait for ShinyProxy to release it;
do not force-remove student sessions during a normal deployment.

Confirm every expected app exists:

```bash
for expected in ${EXPECTED_APP_IDS}; do
  grep -qE "^[[:space:]]+- id: [\"']?${expected}[\"']?[[:space:]]*$" application.yml || {
    echo "Missing app spec: ${expected}" >&2
    exit 1
  }
done
```

Record the selected app's current image as `PREVIOUS_TAG_DEV` before editing.

## Phase 7: Back Up and Update Dev

`REMOTE` - make a timestamped, permission-preserving backup:

```bash
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="application.yml.before-${APP_ID}-${STAMP}"
cp -p application.yml "${BACKUP}"
ls -l "${BACKUP}"
```

Record the backup name. Open the config with the editor available on the host:

```bash
vi application.yml
```

For an existing app, change only its `container-image` value to `IMAGE`. Do
not alter SAML, another app, or the workspace mapping.

For a new app, add another item under `proxy.specs`. This is the proposed
KPZ308 Practical 2 shape; `CONFIRMED_REPOSITORY` and `IMMUTABLE_TAG` are
operator metavariables that must be replaced. Confirm the resource values and
environment with the app owner rather than copying them blindly.

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

KPZ314 needs its own confirmed environment variables, image, workspace path,
and `KPZ314` access group. Do not copy rPVA-specific variables into KPZ314
unless its project explicitly uses them.

For a first Practical 2 deployment, create its workspace parent as
`sa-container`:

```bash
mkdir -p data/kpz308-rpva-practical2/workspaces
chmod 0750 data/kpz308-rpva-practical2 data/kpz308-rpva-practical2/workspaces
ls -ldZ data/kpz308-rpva-practical2 data/kpz308-rpva-practical2/workspaces
```

Use a separate `data/kpz314-sdm-practical/workspaces` tree for KPZ314. Do not
change SELinux labels manually. Retain the `:z` bind-mount option and stop for
ITS help if the container is denied access.

Review the edit and confirm the app inventory:

```bash
diff -u "${BACKUP}" application.yml || true
grep -nE '^[[:space:]]+- id:' application.yml
for expected in ${EXPECTED_APP_IDS}; do
  grep -qE "^[[:space:]]+- id: [\"']?${expected}[\"']?[[:space:]]*$" application.yml || exit 1
done
```

For `add-new`, add the new ID to `EXPECTED_APP_IDS` before running the loop.
Read the diff carefully. If it changes unrelated config, restore the backup
and make the edit again.

Pull and inspect the exact image before stopping ShinyProxy:

```bash
docker pull "${IMAGE}"
docker image inspect "${IMAGE}" \
  --format 'id={{.Id}} repoDigests={{json .RepoDigests}}'
```

Stop if pull is denied, the tag is absent, or the digest differs from the
publication record.

## Phase 8: Restart and Check Dev

`REMOTE` - in a no-user maintenance window, use the restart path confirmed by
ITS:

```bash
docker compose down
docker compose up -d
docker compose ps
```

Wait for health without assuming immediate startup:

```bash
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

Expected result: health reports `UP`, `docker compose ps` shows ShinyProxy up,
and startup logs do not show YAML, image, Docker socket, SAML, or app-spec
errors.

A less disruptive restart may be used only after ITS confirms that it reloads
the bind-mounted `application.yml`. Until then, use the known down/up sequence
outside active sessions.

If ShinyProxy fails to start, restore the backup immediately:

```bash
cp -p "${BACKUP}" application.yml
docker compose down
docker compose up -d
curl -fsS http://127.0.0.1:9090/actuator/health
docker logs --tail 120 shinyproxy
```

## Phase 9: Perform the Dev Browser Acceptance Test

`WINDOWS` - open the dev launcher in a normal browser:

[ITS ShinyProxy dev](https://ecology-r-dev1.its.utas.edu.au)

Complete SAML login. For KPZ308 Practical 1, pass all of these checks:

- [ ] The expected app tiles are present; no unrelated app has disappeared.
- [ ] `KPZ308 rPVA Practical` opens.
- [ ] The new app container becomes healthy on the server.
- [ ] Start or restore the baseline.
- [ ] Run at least one changed scenario, including an environmental
      stochasticity run for the established Practical 1 smoke.
- [ ] Compare shows baseline plus the changed run.
- [ ] The comparison CSV downloads, opens, has expected columns, and has
      non-empty rows.
- [ ] The evidence-notes Markdown downloads and contains settings,
      provenance, comparison evidence, and interpretation prompts.
- [ ] Return to the launcher and confirm the other expected tiles remain.

For Practical 2 or KPZ314, the app owner must define an equivalent smoke before
first deployment: open the app, run its default/baseline workflow, run one
changed workflow, inspect its main comparison/output, and verify every student
export it promises. Do not claim a new app is accepted merely because its tile
opens.

While the app is open, `REMOTE` may capture non-secret supporting evidence:

```bash
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
docker logs --tail 120 shinyproxy | grep -Ei 'Starting proxy|Proxy activated|error|warn' || true
```

Record the dev browser result, tester role, timestamp, exact image tag, and any
warnings. Stop here if any browser or export check fails. Do not edit prod.

## Phase 10: Promote the Accepted Tag to Prod

Only continue after the dev browser result is accepted. Do not rebuild,
retag, or substitute a different digest.

`PUTTY` - open a new session to `ecology-r1.its.utas.edu.au`, then repeat the
remote entry and discovery steps:

```bash
hostname -f
sudo -iu sa-container
cd /srv/sa-container/ecology-teaching-shiny
APP_ID='kpz308-rpva-practical'
IMAGE='git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-YYYYMMDD-SHORTSHA'
EXPECTED_APP_IDS='kpz308-rpva-practical'
docker compose ps
curl -fsS http://127.0.0.1:9090/actuator/health
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
grep -nE '^[[:space:]]+- id:|container-image:|access-groups:|workspaces/' application.yml
```

Replace the tag with the exact dev-accepted tag and list every app expected on
prod. Stop for active sessions. Record `PREVIOUS_TAG_PROD`.

Back up prod, edit only the selected app, confirm all app IDs, and pull the
exact accepted image:

```bash
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="application.yml.before-${APP_ID}-${STAMP}"
cp -p application.yml "${BACKUP}"
vi application.yml
diff -u "${BACKUP}" application.yml || true
for expected in ${EXPECTED_APP_IDS}; do
  grep -qE "^[[:space:]]+- id: [\"']?${expected}[\"']?[[:space:]]*$" application.yml || exit 1
done
docker pull "${IMAGE}"
docker image inspect "${IMAGE}" \
  --format 'id={{.Id}} repoDigests={{json .RepoDigests}}'
```

Confirm the digest matches the publication and dev records. Restart and check
prod:

```bash
docker compose down
docker compose up -d
docker compose ps
docker logs --tail 120 shinyproxy
```

Use the health-wait loop from Phase 8, then confirm it returns `UP`.

`WINDOWS` - repeat the full browser acceptance at:

[ITS ShinyProxy prod](https://ecology-r1.its.utas.edu.au)

Record the prod result. The deployment is technically accepted only when
health, logs, the selected app workflow, exports, and unrelated app tiles all
pass.

## Roll Back One Application

Use rollback when the new app fails health, startup, workflow, exports, or a
student-release check.

1. Stop new logins and confirm no class is active.
2. Record the rollback reason and failing tag.
3. Confirm the previous image still exists locally or can be pulled.
4. Revert only the selected app's `container-image` to the previous tag.
5. Restart ShinyProxy, check health/logs, and repeat the browser smoke.

Restore the complete backup only when no unrelated config change has occurred
since it was created:

```bash
diff -u "${BACKUP}" application.yml || true
cp -p "${BACKUP}" application.yml
docker compose down
docker compose up -d
docker compose ps
docker logs --tail 120 shinyproxy
```

Use the health-wait loop from Phase 8 before starting the rollback browser
smoke.

If another app or SSO setting changed after the backup, use `vi` to revert
only the failed app's image line. Do not replace the whole config with an old
copy. Do not delete the failed image or workspace during incident recovery;
preserve evidence until the cause is understood.

Roll back prod first if the failure is prod-only. If the same image is faulty
on dev, roll back dev as well and mark that tag rejected.

## Add a New Application for the First Time

Do not edit `application.yml` until all of these are confirmed:

- stable app ID and browser route;
- Gitea image repository and server pull permission;
- reviewed source commit, Dockerfile, build context, and immutable tag;
- container port and health check;
- required environment variables and volume mounts;
- memory and CPU limits reviewed with ITS;
- staff and student access groups registered in SSO;
- separate host workspace subtree and SELinux-compatible mount;
- app-specific browser workflow and export acceptance checks;
- rollback owner and previous-config backup path.

Then add the spec on dev, create the workspace parent, verify all old app IDs
remain, and follow Phases 8-10. Adding one app must not replace Practical 1 or
any other existing spec.

## Pre-Class and Class-Day Checks

Run these shortly before students receive the link:

- [ ] Prod health reports `UP`.
- [ ] ShinyProxy and expected app containers show no restart loop.
- [ ] All expected app tiles are present.
- [ ] One staff member completes the app-specific smoke and export workflow.
- [ ] The correct student group can see the correct app.
- [ ] The approved URL and teaching-channel wording are ready.
- [ ] The previous image tag, config backup, rollback owner, and support path
      are written down.
- [ ] Disk/workspace state and container logs show no immediate concern.
- [ ] The static worksheet, expected outputs, demonstrator guidance, and
      fallback route are open and ready.
- [ ] Workspace retention and cleanup ownership are known.

The earlier production rehearsal passed at 5, 10, 20, 40, and 60 temporary
app containers, and ITS monitoring showed substantial headroom. That was a
host/container/R-workload test, not 60 separate SAML identities. Repeat it
only after a material change to runtime, resource limits, ShinyProxy, host
capacity, or expected concurrency.

During class, use:

```bash
docker compose ps
curl -fsS http://127.0.0.1:9090/actuator/health
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
docker stats --no-stream
docker logs --tail 120 shinyproxy
```

Switch to the static fallback if multiple students cannot start sessions, the
service remains unhealthy, exports fail broadly, or troubleshooting would
consume the teaching session.

## Known Problems and Proven Remedies

| Symptom | What to do |
| --- | --- |
| `docker info` cannot reach the daemon in WSL | Start Docker Desktop and confirm WSL integration, then retry. Do not install a second Linux Docker daemon. |
| Docker rejects the repository name because it is uppercase | Use lowercase `utas` in the image path. Keep uppercase `UTAS` only in the Gitea source URL. |
| `docker login` reuses the wrong account or token | Run `docker logout git.its.utas.edu.au`, then log in again with `--password-stdin`. |
| Build fails while restoring `listenv` | Confirm the Practical 1 Dockerfile installs locked `listenv` 0.10.1 before `renv::restore()`. |
| A manual capacity command says `NanoCPUs can not be set` | Omit `--cpus` from that manual `docker run`; the RedHat/rootless kernel did not expose that CFS control during rehearsal. Keep the ShinyProxy config limit unless ITS changes it. |
| Docker warns `IPv4 forwarding is disabled` | Record it and test the actual workload. The validated R workload succeeded, but investigate if the app needs networking and its browser/runtime check fails. |
| Health request returns 404 | Use port 9090 and `/actuator/health`. Port 8080 is the user-facing proxy route. |
| App URL redirects to `/login` | Expected without an authenticated SAML browser session. Complete acceptance in a normal browser. |
| ShinyProxy health is up but the app fails | Inspect `docker ps`, ShinyProxy activation logs, the app container health/logs, workspace permissions, image tag, and browser workflow. Health alone does not test the app. |
| New app is missing from the launcher | Recheck indentation under `proxy.specs`, its `access-groups`, SSO group membership, and ShinyProxy startup logs. Do not remove another spec while repairing it. |

## Completion Record

A completed deployment note should contain:

```text
Outcome: accepted | rolled back | blocked
Operation:
App ID:
Source commit:
Image and immutable tag:
Registry digest:
Previous dev tag:
Dev config backup:
Dev health and browser result:
Previous prod tag:
Prod config backup:
Prod health and browser result:
Other app tiles checked:
Student-release decision:
Rollback state:
Residual issue and owner:
```

Never include credentials or student identifiers. Keep the previous image tag
and config backup until the new release has survived its teaching window.
