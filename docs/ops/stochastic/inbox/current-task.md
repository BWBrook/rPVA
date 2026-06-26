# Current Task For `stochastic`: Goal 042 ITS Gitea Dev Image Publication

## Objective

Perform the first controlled ITS Gitea registry image publication for the
KPZ308 rPVA ShinyProxy app, then report back through a dedicated GitHub report
branch with non-secret evidence only.

This task gives enough autonomy to build, locally smoke-test, log in to the ITS
Gitea registry with Barry-entered credentials, push one immutable image tag,
capture the digest, prepare a Mark-ready return note, and report back.

## Role And Source Of Truth

- Work only inside Barry's WSL clone of the rPVA repository.
- Mac mini plus the rPVA orchestrator plus `woodhen` remain the source-of-truth
  project lane.
- Treat this repo-local task file as the active instruction source.
- Do not contact Mark, ITS, students, Moodle admins, Chief, or any other
  people from this agent.
- Do not contact unrelated external services. Only GitHub origin and the ITS
  Gitea host/registry operations explicitly authorized by this task are
  allowed.
- Do not read Chief of Staff, Goal Composer, sibling projects, archive
  material, or any non-rPVA repository.

## Branch And Report Protocol

1. Fetch/prune GitHub origin and update from current `origin/main` if the local
   tree is clean:

   ```sh
   git fetch --prune origin
   git status --short --branch
   ```

2. If source files are dirty unexpectedly, stop and report. Planned report and
   evidence files are allowed only after the report branch exists.
3. Create a dedicated report branch from current `origin/main`:

   ```sh
   BASE_REPORT_BRANCH=codex/rpva-stochastic-goal042-image-publication
   REPORT_BRANCH="${BASE_REPORT_BRANCH}"
   if git show-ref --verify --quiet "refs/heads/${REPORT_BRANCH}" || \
      git ls-remote --exit-code --heads origin "${REPORT_BRANCH}" >/dev/null 2>&1; then
     REPORT_BRANCH="${BASE_REPORT_BRANCH}-$(date +%Y%m%d%H%M%S)"
   fi
   git switch -c "${REPORT_BRANCH}" origin/main
   ```

4. Do not push `main`.
5. Do not push to the ITS Gitea source repository.
6. You may push only the dedicated GitHub report branch back to GitHub origin,
   and only with non-secret report/evidence files.
7. If GitHub report-branch push fails, leave the report locally and ask Barry
   to paste or otherwise relay
   `docs/ops/stochastic/outbox/current-report.md`. Do not attempt workaround
   pushes.

## Failure Handling And Reporting Rule

Every outcome must still produce a report.

If build, local smoke, login, push, or manifest inspection fails:

- stop the unsafe or downstream live portion;
- skip downstream operations as appropriate;
- preserve concise non-secret evidence;
- still write `docs/ops/stochastic/outbox/current-report.md`;
- still commit report/evidence files on the dedicated report branch if possible;
- still push the dedicated GitHub report branch if possible.

Examples:

- Build failure means no smoke, login, or push.
- Smoke failure means no login or push.
- Login failure means no push.
- Push failure means no Mark deployment request.
- Manifest inspection failure after a successful push is a partial success;
  report the pushed image and digest if available.

## Reviewed Source Ref And Image Naming

Build from the exact current `origin/main`/report-branch base commit after
pulling this task:

```sh
SOURCE_REF=$(git rev-parse HEAD)
SHORT_SHA=$(git rev-parse --short=12 HEAD)
TAG="dev-$(date +%Y%m%d)-${SHORT_SHA}"
IMAGE="git.its.utas.edu.au/UTAS/kpz308-rpva-practical:${TAG}"
```

Rules:

- Target image path is exactly
  `git.its.utas.edu.au/UTAS/kpz308-rpva-practical:<TAG>`.
- Default tag must be immutable and source-linked, such as
  `dev-YYYYMMDD-<SHORT_SHA>`.
- If that tag already exists or is rejected as existing/immutable, choose a
  clearly related non-overwriting variant such as
  `dev-YYYYMMDD-<SHORT_SHA>-r2` and report the reason.
- Do not use or push `latest`.
- Do not overwrite an existing tag intentionally.
- Report `SOURCE_REF`, `SHORT_SHA`, `TAG`, and `IMAGE`.

## WSL Preflight Checks

Report:

- `pwd`;
- branch, HEAD, and `git status --short --branch`;
- OS/kernel;
- Git version;
- Docker CLI version;
- Docker daemon architecture, version, and CPU count;
- non-secret reachability of `https://git.its.utas.edu.au/`;
- whether R is available.

Suggested non-secret commands:

```sh
pwd
git branch --show-current
git rev-parse HEAD
git status --short --branch
uname -a
cat /etc/os-release
git --version
docker --version
docker info --format 'server={{.ServerVersion}} arch={{.Architecture}} cpus={{.NCPU}}'
curl -I --max-time 10 https://git.its.utas.edu.au/
command -v Rscript >/dev/null && Rscript -e 'renv::status(sources = FALSE)' || true
```

If R is absent, record that and continue. The Docker build is the relevant
Linux proof for this task.

Do not install system packages. Do not use `sudo`.

## Evidence Directory

Use a small non-secret evidence directory:

```sh
EVIDENCE_DIR=docs/ops/stochastic/outbox/evidence/goal042
mkdir -p "${EVIDENCE_DIR}"
```

Keep evidence concise. Do not commit full build logs if they are large; instead
commit sanitized summaries and small text files.

## Build Command And Allowed Autonomy

Build a `linux/amd64` image from the repo root using the existing Dockerfile
template:

```sh
docker build \
  --platform linux/amd64 \
  -f deploy/shinyproxy/practical1/Dockerfile.template \
  --build-arg RPVA_REF="${SOURCE_REF}" \
  -t "${IMAGE}" \
  .
```

Allowed autonomy:

- choose safe local variable names and a timestamped evidence file name;
- retry one clearly transient Docker/network pull failure once;
- clean up your own temporary smoke-test container;
- capture concise sanitized failure signatures.

Not allowed:

- patch app/source/Dockerfile/YAML to make the build pass;
- install packages on WSL;
- use `sudo`;
- commit large full build logs;
- continue to push if the build fails after one transient retry.

## Local Container Smoke Before Push

Run the built image locally on WSL before pushing.

1. Choose a free localhost port, starting with `3904`:

   ```sh
   PORT=3904
   if ss -ltn | grep -q ":${PORT} "; then PORT=3905; fi
   SMOKE_NAME="rpva-goal042-${SHORT_SHA}"
   ```

2. Start the container:

   ```sh
   docker run --rm -d \
     --name "${SMOKE_NAME}" \
     -p "127.0.0.1:${PORT}:3838" \
     "${IMAGE}"
   ```

3. Wait briefly and check HTTP:

   ```sh
   SMOKE_OK=0
   SMOKE_HTML_TMP=$(mktemp)
   for attempt in $(seq 1 30); do
     if curl -fsS -L "http://127.0.0.1:${PORT}/" > "${SMOKE_HTML_TMP}"; then
       SMOKE_OK=1
       break
     fi
     sleep 2
   done
   if [ "${SMOKE_OK}" -ne 1 ] || [ ! -s "${SMOKE_HTML_TMP}" ]; then
     docker logs "${SMOKE_NAME}" > "${EVIDENCE_DIR}/smoke-container-log.txt" 2>&1 || true
     docker rm -f "${SMOKE_NAME}" >/dev/null 2>&1 || true
     printf 'Local smoke failed; image was not pushed.\n' > "${EVIDENCE_DIR}/smoke-summary.txt"
     rm -f "${SMOKE_HTML_TMP}"
     # Stop the live path here: no login or push. Continue to report writing.
   fi
   ```

4. Record a small summary, not the full page if it is large:

   ```sh
   if [ "${SMOKE_OK}" -eq 1 ]; then
     wc -c "${SMOKE_HTML_TMP}" > "${EVIDENCE_DIR}/smoke-summary.txt"
     grep -E "KPZ308|Practical|rPVA|Shiny" "${SMOKE_HTML_TMP}" \
       | head -20 >> "${EVIDENCE_DIR}/smoke-summary.txt" || true
   fi
   ```

5. Stop/remove the smoke container before finishing, even on failure:

   ```sh
   docker rm -f "${SMOKE_NAME}" >/dev/null 2>&1 || true
   ```

6. Remove the temporary full HTML by default:

   ```sh
   if [ "${SMOKE_OK}" -eq 1 ]; then
     HTML_BYTES=$(wc -c < "${SMOKE_HTML_TMP}")
     if [ "${HTML_BYTES}" -le 20000 ]; then
       cp "${SMOKE_HTML_TMP}" "${EVIDENCE_DIR}/smoke-home.html"
       printf 'Temporary HTML classified as small and non-secret before commit.\n' \
         >> "${EVIDENCE_DIR}/smoke-summary.txt"
     fi
   fi
   rm -f "${SMOKE_HTML_TMP}"
   ```

Full HTML is temporary by default. Commit only `smoke-summary.txt` unless the
HTML is tiny, clearly useful, classified as non-secret, and copied explicitly
as above. If copied HTML later looks noisy or unnecessary, remove it before
staging.

If local smoke fails after a reasonable wait or retry, do not push the image.
Skip the registry login and push sections, report the failure, and push the
report branch if possible.

## Gitea Registry Login And Credential Safety

If not already logged in to `git.its.utas.edu.au`, ask Barry to enter the
Gitea username and credential interactively. Credential entry is the only
expected human interaction during this task.

Use hidden input and standard input:

```sh
read -rp "Gitea username: " GITEA_USER
read -rsp "Gitea registry credential (input hidden): " GITEA_REGISTRY_CREDENTIAL
printf '\n'
printf '%s' "${GITEA_REGISTRY_CREDENTIAL}" | docker login git.its.utas.edu.au \
  --username "${GITEA_USER}" \
  --password-stdin
unset GITEA_REGISTRY_CREDENTIAL
```

Never print, paste, echo, store, commit, screenshot, or report credentials,
tokens, passwords, Docker login config, shell history, `.env`, private keys, or
full environment dumps.

If login fails, allow one careful retry. If still blocked, do not push. Report
the error class without secrets and push the report branch if possible.

## Push And Digest Capture

Push only the registry image:

```sh
PUSH_OUTPUT="${EVIDENCE_DIR}/push-output.txt"
if ( set -o pipefail; docker push "${IMAGE}" | tee "${PUSH_OUTPUT}" ); then
  PUSH_STATUS=0
else
  PUSH_STATUS=$?
fi
printf 'push_status=%s\n' "${PUSH_STATUS}" > "${EVIDENCE_DIR}/push-status.txt"
```

If `PUSH_STATUS` is not zero, the push failed. Do not treat digest extraction
as success and do not prepare a Mark deployment request. Report the failure and
push the report branch if possible.

Capture the digest from `docker push` only after a successful push:

```sh
if [ "${PUSH_STATUS}" -eq 0 ]; then
  if ! grep -E "digest: sha256:" "${PUSH_OUTPUT}" > "${EVIDENCE_DIR}/digest.txt"; then
    printf 'Push succeeded, but digest extraction did not find a digest line.\n' \
      > "${EVIDENCE_DIR}/digest.txt"
  fi
fi
```

If available, inspect the manifest:

```sh
if [ "${PUSH_STATUS}" -eq 0 ]; then
  docker buildx imagetools inspect "${IMAGE}" \
    > "${EVIDENCE_DIR}/manifest.txt" 2> "${EVIDENCE_DIR}/manifest-stderr.txt" || true
else
  printf 'Manifest inspection skipped because push failed.\n' \
    > "${EVIDENCE_DIR}/manifest-stderr.txt"
fi
```

Record final `IMAGE`, `TAG`, `SOURCE_REF`, `SHORT_SHA`, digest, push result,
and manifest inspection result.

Do not push to the ITS source repo. Only registry image publication is
authorized.

After push and manifest capture, run registry credential cleanup unless Barry
explicitly tells you to keep the Docker session authenticated for this goal:

```sh
if [ "${PUSH_STATUS:-1}" -eq 0 ]; then
  LOGOUT_OUTPUT_TMP=$(mktemp)
  if docker logout git.its.utas.edu.au > "${LOGOUT_OUTPUT_TMP}" 2>&1; then
    printf 'logout_result=success\n' > "${EVIDENCE_DIR}/docker-logout-summary.txt"
  else
    printf 'logout_result=failed_or_not_logged_in\n' > "${EVIDENCE_DIR}/docker-logout-summary.txt"
  fi
  rm -f "${LOGOUT_OUTPUT_TMP}"
fi
```

Report only the logout result class. Do not inspect or print Docker credential
config.

## Mark-Ready Return Note

After a successful registry push, create:

```text
docs/ops/stochastic/outbox/evidence/goal042/mark-ready-return-note.md
```

It must be concise and sendable by Barry to Mark. Include only non-secret
details:

- image path and tag;
- digest;
- source commit;
- local WSL smoke result;
- note that no secrets or student data are included;
- request that Mark deploy/link it to the dev server and return:
  - dev URL;
  - SSO/access-group expectation;
  - service-user home path;
  - deployment directory;
  - restart path;
  - whether future ShinyProxy config should be pinned by tag or digest.

If build, smoke, login, or push failed, do not prepare a Mark deployment
request. Instead, report that the Mark-ready note was skipped because upstream
publication did not complete.

Do not contact Mark directly.

## Report Contents

Write:

```text
docs/ops/stochastic/outbox/current-report.md
```

Include:

- start and end time;
- report branch, HEAD, and status;
- WSL/Docker/Gitea posture;
- `SOURCE_REF`, `SHORT_SHA`, `TAG`, and `IMAGE`;
- build result, or `skipped because upstream failed`;
- local smoke result, or `skipped because upstream failed`;
- login result, or `skipped because upstream failed`;
- push/digest result, or `skipped because upstream failed`;
- manifest inspection result, or `skipped because upstream failed`;
- logout result class, if login/push occurred;
- Mark-ready note path and content summary;
- evidence file list and checksums;
- exact blockers if any;
- explicit boundary confirmation.

Put small non-secret evidence under:

```text
docs/ops/stochastic/outbox/evidence/goal042/
```

Evidence may include digest text, manifest text, short smoke response summary,
command versions, checksums, and the Mark-ready note. Avoid large logs.

Create checksums. Prefer `sha256sum` on Ubuntu; fall back to
`shasum -a 256` if needed. If neither tool is available, record that in the
report and continue; do not fail the task solely because checksums could not
be generated.

```sh
(
  cd docs/ops/stochastic/outbox/evidence/goal042
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum * > SHA256SUMS.txt
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 * > SHA256SUMS.txt
  else
    printf 'No sha256sum or shasum checksum tool available; record this in the report.\n' >&2
  fi
)
```

Commit only report/evidence files on the dedicated report branch:

```sh
git add docs/ops/stochastic/outbox/current-report.md \
  docs/ops/stochastic/outbox/evidence/goal042/
git diff --cached --name-only
git commit -m "Record stochastic Goal 042 image publication report"
git push -u origin "${REPORT_BRANCH}"
```

If the report branch push fails, do not try alternate push destinations. Ask
Barry to relay the report manually.

## Boundaries For This Task

Authorized for Goal 042 only:

- GitHub fetch/pull and report-branch push;
- Docker build;
- local container smoke;
- safe Docker login to ITS Gitea registry with Barry-entered credentials;
- registry image push;
- digest capture;
- non-secret evidence/report writing.

Not authorized:

- source push to ITS Gitea;
- `main` branch push;
- source/app/Dockerfile/YAML edits;
- dev-server SSH/login;
- compose down/up;
- service restart;
- ShinyProxy/nginx/systemd/firewall/DNS/TLS changes;
- token creation;
- credential capture;
- student/Moodle contact;
- student release;
- KPZ314 work;
- Practical 2 implementation;
- external contact;
- public exposure.

After writing and, if possible, pushing the report branch, wait for Barry to
relay the result back to the rPVA orchestrator.
