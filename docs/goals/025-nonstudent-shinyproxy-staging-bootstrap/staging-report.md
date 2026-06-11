# Goal 025 Staging Report

## Status

Goal 025 produced a non-student Practical 1 ShinyProxy staging service on
`deep-server` for commit `5c9d5004266f57b5bc1c48df042ca60d0a501dfe`.

The staging service is left running, authenticated, and non-student only.
No student/class accounts, class tokens, class workspaces, DNS changes,
firewall changes, TLS certificate/trust-chain changes, Docker daemon/service
changes, science/YAML changes, dependencies, commits, pushes, merges, or PRs
were made.

## Start State

- Local repo: `/Users/bwbrook/git/rPVA`
- Branch: `codex/rpva-goal025-nonstudent-staging`
- Start `HEAD`: `5c9d5004266f57b5bc1c48df042ca60d0a501dfe`
- Start status: only the Goal 025 packet was untracked
- Repo-local `AGENTS.md`: absent

## Remote Preflight

Remote read-only preflight via `deep-server-ts` found:

- host: `deep-server`, `x86_64`, user `bwbrook`
- non-interactive sudo: available
- Docker: `29.5.2`, 64 CPUs, root `/var/lib/docker`
- Java: OpenJDK `21.0.11`
- nginx: active/enabled; `sudo -n nginx -t` passed
- ShinyProxy: absent before Goal 025
- port `3838`: not listening before Goal 025
- `/data/codex/teaching/rpva-2026`: present
- tailnet gateway health: HTTP 200
- campus-IP health: initially timed out, later HTTP 200 for `_gateway-health`

## Source And Image

- Remote source path:
  `/data/codex/repos/rpva-goal025-5c9d500`
- Source commit marker:
  `5c9d5004266f57b5bc1c48df042ca60d0a501dfe`
- Image tag: `rpva-practical1:goal025-5c9d500`
- Image id:
  `sha256:29511a9d2e583b38c724c56b8c0f8b947d99f10e0e533c1e9a79d4127b40ab79`
- Image size: `1794286296` bytes
- Transient localhost image smoke: passed and the smoke container was removed

## ShinyProxy Bootstrap

Official sources checked:

- ShinyProxy downloads: `https://www.shinyproxy.io/downloads/`
- ShinyProxy configuration: `https://www.shinyproxy.io/documentation/configuration/`
- ShinyProxy security and reverse-proxy guidance:
  `https://www.shinyproxy.io/documentation/security/`

Installed/configured:

- ShinyProxy version: `3.2.4`
- JAR path: `/opt/shinyproxy/shinyproxy-3.2.4.jar`
- JAR SHA256:
  `0bd68e3ba31b5288b5523ee250e90f316f5e0524bd11bcc18645499ede1ee57e`
- service: `/etc/systemd/system/shinyproxy.service`
- config: `/etc/shinyproxy/application.yml`
- config permissions: `root:bwbrook 640`
- credential path:
  `/data/codex/teaching/rpva-2026/staging/credentials/goal025-nonstudent-password.txt`
- credential permissions: `bwbrook:bwbrook 600`
- staging workspace:
  `/data/codex/teaching/rpva-2026/staging/workspaces/rpva_goal025_nonstudent`
- staging workspace permissions: `bwbrook:bwbrook 775`
- one non-student staging identity:
  `rpva_goal025_nonstudent`

Secret value handling:

- The generated password was not written to the repo.
- It was not printed in terminal summaries, logs, this report, or chat.
- Temporary local password copies used for smoke tests were removed.

Two narrow startup/route fixes were made:

- The systemd config-location argument was changed from a `file:` URI to the
  absolute path `/etc/shinyproxy/application.yml`, because ShinyProxy treated
  the URI as a literal file path during startup.
- `server.forward-headers-strategy: native` was added to
  `/etc/shinyproxy/application.yml`, matching ShinyProxy reverse-proxy guidance,
  so HTTPS gateway authentication redirects stay on HTTPS.

No nginx edit was required.

## Route And Browser Evidence

Local service evidence:

- `systemctl is-active shinyproxy`: active
- `systemctl is-active nginx`: active
- ShinyProxy listener: `127.0.0.1:3838`
- app container:
  `rpva-practical1:goal025-5c9d500`, healthy, bound to `127.0.0.1:20000->3838`

Gateway evidence:

- Tailnet health: `https://100.96.185.60/_gateway-health` returned HTTP 200
- Tailnet authenticated curl:
  `https://100.96.185.60/login` -> HTTP 200 at
  `https://100.96.185.60/auth-success`; app path
  `https://100.96.185.60/app/practical1` returned HTTP 200
- Campus health: `https://131.217.90.193/_gateway-health` returned HTTP 200
- Campus login/app authentication: best-effort check timed out from this local
  origin; no campus/student release decision should be inferred from the
  health endpoint alone

Browser evidence:

- Chrome plugin attempt: unavailable for the tailnet URL in this thread because
  Chrome returned `net::ERR_BLOCKED_BY_CLIENT`
- Browser fallback: Playwright with installed Chrome channel and
  `ignoreHTTPSErrors` in the local browser context
- Tailnet browser path:
  `https://100.96.185.60/app/practical1`
- Browser flow completed:
  authenticated non-student login, Start baseline, Concept Lab
  `carrying_capacity` run, Compare, comparison CSV download, evidence-notes
  Markdown download, Transfer
- Screenshot evidence:
  - `/tmp/rpva-goal025-tailnet-start.png`
  - `/tmp/rpva-goal025-tailnet-compare.png`
  - `/tmp/rpva-goal025-tailnet-transfer.png`
- Download evidence:
  - `/tmp/rpva-goal025-tailnet-practical1-comparison.csv` (`342` bytes)
  - `/tmp/rpva-goal025-tailnet-practical1-evidence-notes.md` (`2260` bytes)

## Final Remote Posture

The staging service is intentionally left running because authenticated tailnet
browser smoke passed.

Current live posture:

- ShinyProxy active
- nginx active
- Practical 1 app image present:
  `rpva-practical1:goal025-5c9d500`
- one ShinyProxy-managed app container healthy after the final browser smoke
- staging authentication configured for the single non-student identity only
- credential remains in the remote staging credential file with `600`
  permissions

## Rollback And Cleanup

Use these commands if the orchestrator decides to stop or remove staging:

```sh
ssh deep-server-ts '
set -eu
sudo systemctl stop shinyproxy || true
sudo systemctl disable shinyproxy || true
sudo rm -f /etc/systemd/system/shinyproxy.service
sudo systemctl daemon-reload
ids=$(docker ps -aq --filter ancestor=rpva-practical1:goal025-5c9d500)
test -z "$ids" || docker rm -f $ids
docker image rm rpva-practical1:goal025-5c9d500 || true
sudo rm -rf /etc/shinyproxy /opt/shinyproxy /var/log/shinyproxy
rm -rf /data/codex/repos/rpva-goal025-5c9d500
rm -rf /data/codex/teaching/rpva-2026/staging
'
```

If only stopping exposure temporarily:

```sh
ssh deep-server-ts 'sudo systemctl stop shinyproxy'
```

To resume after a temporary stop:

```sh
ssh deep-server-ts 'sudo systemctl start shinyproxy'
```

## Changed Files

Repo-local changes for Goal 025:

- `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/Goal.md`
- `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/Plan.md`
- `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/Runbook.md`
- `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/Log.md`
- `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/staging-report.md`
- `docs/teaching/shiny/README.md`

Remote changes were limited to the Goal 025 authorized ShinyProxy/source/image
and staging paths, plus the small ShinyProxy forwarded-header config needed to
make the existing nginx HTTPS gateway behave correctly.

## Validation

Completed:

- `git fetch --prune origin`: passed
- `git diff --check`: passed
- `bash -n deploy/shinyproxy/practical1/validate-scaffold.sh`: passed
- `bash deploy/shinyproxy/practical1/validate-scaffold.sh`: passed
- Ruby YAML parse for `application.example.yml`: passed
- `Rscript -e 'renv::status(sources = FALSE)'`: passed
- focused teaching API test:
  `tests/testthat/test-12_teaching_api.R`: passed
- focused Practical 1 Shiny test:
  `tests/testthat/test-13_practical1_shiny.R`: passed
- Docker image build: passed
- transient image localhost smoke: passed
- authenticated tailnet gateway curl: passed
- authenticated tailnet browser smoke: passed
- local temporary credential copy cleanup: passed
- marker scan over changed/untracked files: no unresolved marker hits
- secret-pattern scan over changed/untracked files: policy/report wording and
  credential path references only; no real secret values found

Full test suite was not run because the repo-local implementation and package
science were not changed; the focused teaching/Shiny tests and scaffold checks
cover the touched surface.

## Residual Risks

- The tailnet browser smoke used `ignoreHTTPSErrors` because the existing
  gateway certificate is not trusted by the local browser context. Goal 025 did
  not change TLS certificate or trust-chain state.
- Campus/public-IP login from this local origin timed out even though the
  `_gateway-health` endpoint returned HTTP 200. Treat campus/student access as
  unapproved and unproven.
- Simple authentication stores the staging password in the remote ShinyProxy
  config. The config is permissioned, and this is acceptable only for this
  non-student staging bootstrap.
- No load test was performed.
- No student/class accounts or persistent student workspace model exists yet.

## Next Recommended Action

Have the rPVA orchestrator review this staging evidence and decide whether to
keep the non-student staging service running for supervisor inspection, request
a narrow campus-route/TLS-readiness goal, or roll back using the commands above.
