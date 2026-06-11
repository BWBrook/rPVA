# Log

## 2026-06-11 - Orchestrator Packet Creation

- Goal 024 was accepted, committed, and published to `origin/main` before this
  branch was created.
- Starting base for Goal 025:
  - branch: `codex/rpva-goal025-nonstudent-staging`;
  - base commit: `5c9d500 Add Practical 1 classroom dry-run fallback pack`;
  - source: `origin/main`.
- Goal purpose:
  - bootstrap a non-student Practical 1 Shiny staging service on `deep-server`;
  - authorize narrow ShinyProxy/service work only after live preflight checks;
  - use the existing HTTPS gateway where possible;
  - prove authenticated non-student browser access before any student release;
  - keep class accounts, class workspaces, DNS, firewall, TLS certificate work,
    public/student release, Practical 2 mode, assessment design, and science
    changes out of scope.
- Packet files:
  - `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/Goal.md`
  - `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/Plan.md`
  - `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/Runbook.md`
  - `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/Log.md`

Status: packet ready for `woodhen`; execution not yet started.

## 2026-06-11 - Woodhen Execution Start

- Read the active packet first: `Goal.md`, `Plan.md`, `Runbook.md`, and
  `Log.md`.
- Reconfirmed starting local state:
  - `pwd`: `/Users/bwbrook/git/rPVA`;
  - branch: `codex/rpva-goal025-nonstudent-staging`;
  - `HEAD`: `5c9d5004266f57b5bc1c48df042ca60d0a501dfe`;
  - short status: `## codex/rpva-goal025-nonstudent-staging...origin/main`
    plus untracked `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/`.
- No repo-local `AGENTS.md` was present; the supplied global AGENTS context and
  the active Goal 025 packet are the local contract.
- Read the required local context before remote work: project `README.md`,
  Codex handoff notes, Goal 020-024 packet/report context, Shiny teaching docs,
  and the existing Practical 1 ShinyProxy deploy scaffold under
  `deploy/shinyproxy/practical1/`.
- Boundary being followed: local work only in `/Users/bwbrook/git/rPVA`; live
  remote writes only after preflight and only in the Goal 025 authorized paths;
  no student/class identities, public release, DNS/firewall/TLS changes, broad
  host maintenance, Docker daemon/service changes, science/YAML changes, new R
  dependencies, commits, pushes, merges, or PRs.

## 2026-06-11 - Local And Remote Preflight

- Local repository preflight:
  - `git fetch --prune origin`: passed;
  - branch: `codex/rpva-goal025-nonstudent-staging`;
  - `HEAD`: `5c9d5004266f57b5bc1c48df042ca60d0a501dfe`;
  - `origin/main`: `5c9d500`;
  - status: only the Goal 025 packet is untracked/edited;
  - `git diff --check`: passed;
  - `bash -n deploy/shinyproxy/practical1/validate-scaffold.sh`: passed;
  - `ruby -e 'require "yaml"; YAML.load_file(...)'`: passed for
    `application.example.yml`;
  - `bash deploy/shinyproxy/practical1/validate-scaffold.sh`: passed;
  - `Rscript -e 'renv::status(sources = FALSE)'`: passed.
- Official ShinyProxy documentation checked before installation design:
  - current download page lists ShinyProxy `3.2.4`, released 2026-04-30, with a
    platform-independent JAR and Ubuntu 24.04 `.deb` option;
  - ShinyProxy Docker access documentation says the Unix socket is the secure
    path and that Docker TCP port exposure should be avoided;
  - configuration documentation says the Docker backend is the default and, if
    `proxy.docker.url` is omitted, ShinyProxy tries the Docker Unix socket;
  - simple authentication stores passwords in `application.yml`, so the staging
    config must stay permissioned and the generated non-student secret must not
    be written to this repo, logs, or chat.
- Remote read-only preflight via `deep-server-ts`:
  - host: `deep-server`, `x86_64`, current user `bwbrook`;
  - non-interactive `sudo -n true`: passed;
  - Docker: `29.5.2`, 64 CPUs, Docker root `/var/lib/docker`;
  - Java: OpenJDK `21.0.11`;
  - nginx: active/enabled; `sudo -n nginx -t` passed;
  - port 3838 was not listening before Goal 025 work;
  - ShinyProxy binary/service/config paths were absent;
  - existing Practical 1 image: `rpva-practical1:goal020-6ed2445`;
  - `/data/codex/teaching/rpva-2026` exists; Goal 025 staging directories were
    not yet present;
  - tailnet gateway health `https://100.96.185.60/_gateway-health`: HTTP 200;
  - campus-IP health `https://131.217.90.193/_gateway-health`: timed out from
    this local origin after 10 seconds.
- Preflight decision: no stop rule triggered. It is safe to proceed with the
  authorized non-student staging bootstrap using existing Docker, existing Java,
  existing nginx, and ShinyProxy bound to `127.0.0.1:3838` with Docker Unix
  socket access under the existing `bwbrook` account.

## 2026-06-11 - Source, Image, And Service Bootstrap

- Staged exact local `HEAD` source by archive to:
  `/data/codex/repos/rpva-goal025-5c9d500`.
- Wrote remote source marker:
  `5c9d5004266f57b5bc1c48df042ca60d0a501dfe`.
- Built image:
  - tag: `rpva-practical1:goal025-5c9d500`;
  - image id:
    `sha256:29511a9d2e583b38c724c56b8c0f8b947d99f10e0e533c1e9a79d4127b40ab79`;
  - size: `1794286296` bytes.
- Transient image smoke:
  - ran `rpva-practical1:goal025-5c9d500` on
    `127.0.0.1:3925->3838`;
  - confirmed HTTP 200 and expected Practical 1/PVA/Compare/Woodhen text;
  - removed the smoke container.
- Installed ShinyProxy using the official platform-independent JAR:
  - version: `3.2.4`;
  - path: `/opt/shinyproxy/shinyproxy-3.2.4.jar`;
  - official SHA256 matched:
    `0bd68e3ba31b5288b5523ee250e90f316f5e0524bd11bcc18645499ede1ee57e`.
- Created one non-student staging identity:
  `rpva_goal025_nonstudent`.
- Secret handling:
  - generated the password on `deep-server`;
  - stored it only under
    `/data/codex/teaching/rpva-2026/staging/credentials/goal025-nonstudent-password.txt`;
  - final remote permissions: `bwbrook:bwbrook 600`;
  - copied it to local `/tmp` only for smoke tests and removed the local temp
    file after each use;
  - did not print or commit the value.
- Created staging workspace:
  `/data/codex/teaching/rpva-2026/staging/workspaces/rpva_goal025_nonstudent`
  with final permissions `bwbrook:bwbrook 775`.
- Created ShinyProxy config:
  - path: `/etc/shinyproxy/application.yml`;
  - final permissions: `root:bwbrook 640`;
  - app image: `rpva-practical1:goal025-5c9d500`;
  - app id: `practical1`;
  - port/bind: `127.0.0.1:3838`.
- Created systemd service:
  `/etc/systemd/system/shinyproxy.service`, running as existing user
  `bwbrook` with Docker supplementary group access.
- Startup fix applied:
  - first service launch failed because the systemd `ExecStart` passed
    `--spring.config.location=file:/etc/shinyproxy/application.yml`;
  - ShinyProxy treated that as a literal path during startup and could not read
    the config;
  - changed the service argument to
    `--spring.config.location=/etc/shinyproxy/application.yml`;
  - reloaded systemd and restarted successfully.
- Gateway redirect fix applied:
  - authenticated HTTPS gateway `curl -L` initially followed a redirect toward
    plain HTTP port 80;
  - nginx already supplied `X-Forwarded-Proto https`;
  - official ShinyProxy security documentation says HTTPS reverse-proxy setups
    require `server.forward-headers-strategy: native`;
  - added that setting under `server:` in `/etc/shinyproxy/application.yml`;
  - restarted ShinyProxy successfully;
  - no nginx edit was required.

## 2026-06-11 - Route And Browser Smoke

- Local ShinyProxy auth/app curl:
  - authenticated to `http://127.0.0.1:3838/login`;
  - reached `/app/practical1` with HTTP 200 and expected Practical 1 content.
- Tailnet gateway health:
  - `https://100.96.185.60/_gateway-health`: HTTP 200.
- Tailnet authenticated gateway curl after forwarded-header fix:
  - login final URL: `https://100.96.185.60/auth-success`;
  - app final URL: `https://100.96.185.60/app/practical1`;
  - app HTTP: 200 with expected Practical 1 content.
- Campus-IP route:
  - `_gateway-health` later returned HTTP 200;
  - `/login` timed out from this local origin after 10 seconds;
  - authenticated campus app smoke remains best-effort blocked and is not a
    student-access proof.
- Chrome plugin attempt:
  - Chrome tool was available;
  - opening `https://100.96.185.60/app/practical1` returned
    `net::ERR_BLOCKED_BY_CLIENT`;
  - recorded as a Chrome/client blocker, then used Playwright/installed Chrome
    fallback.
- Browser fallback:
  - Playwright package was available from the local npx cache;
  - installed Chrome channel was used;
  - browser context used `ignoreHTTPSErrors` only for this smoke because the
    existing gateway certificate is not trusted locally;
  - no TLS certificate/trust-chain state was changed.
- Full tailnet HTTPS browser smoke passed at:
  `https://100.96.185.60/app/practical1`.
- Browser flow completed:
  1. authenticated non-student login;
  2. Start baseline;
  3. Concept Lab `carrying_capacity` run;
  4. Compare;
  5. comparison CSV download;
  6. evidence-notes Markdown download;
  7. Transfer.
- Browser evidence under `/tmp`:
  - `/tmp/rpva-goal025-tailnet-start.png`;
  - `/tmp/rpva-goal025-tailnet-compare.png`;
  - `/tmp/rpva-goal025-tailnet-transfer.png`;
  - `/tmp/rpva-goal025-tailnet-practical1-comparison.csv` (`342` bytes);
  - `/tmp/rpva-goal025-tailnet-practical1-evidence-notes.md` (`2260` bytes).
- Final remote posture after smoke:
  - ShinyProxy active;
  - nginx active;
  - app container healthy:
    `rpva-practical1:goal025-5c9d500`, `127.0.0.1:20000->3838`;
  - staging service intentionally left running because authenticated tailnet
    browser smoke passed.
- Local cleanup completed:
  - closed the temporary Playwright CLI session;
  - closed the loopback SSH tunnel used during intermediate browser fallback;
  - removed local temporary password copies;
  - finalized the Chrome automation session.
- Created `staging-report.md` with rollback/cleanup commands and updated
  `docs/teaching/shiny/README.md` to record the non-student staging boundary.

## 2026-06-11 - Final Validation

- `git diff --check`: passed.
- `bash -n deploy/shinyproxy/practical1/validate-scaffold.sh`: passed.
- `bash deploy/shinyproxy/practical1/validate-scaffold.sh`: passed.
- Ruby YAML parse for
  `deploy/shinyproxy/practical1/application.example.yml`: passed.
- `Rscript -e 'renv::status(sources = FALSE)'`: passed.
- Focused tests:
  - `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'`:
    passed as part of the combined focused-test command;
  - `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'`:
    passed as part of the combined focused-test command.
- Full test suite not run: Goal 025 changed remote staging/config docs and did
  not change package implementation, science, or test code; focused
  teaching/Shiny tests were proportionate.
- Marker scan over changed/untracked files:
  no unresolved marker hits.
- Secret-pattern scan over changed/untracked files:
  only policy/report wording and credential path references were found; no real
  secret value was present in repo files or terminal summaries.
- Final local status before handoff:
  - branch: `codex/rpva-goal025-nonstudent-staging`;
  - tracked modified file: `docs/teaching/shiny/README.md`;
  - untracked packet directory:
    `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/`.
