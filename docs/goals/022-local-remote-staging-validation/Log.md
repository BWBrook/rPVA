# Log

## 2026-06-06 - SRF-A Branch Setup

- SRF-A directed `woodhen` to create Goal 022 for bounded local-plus-remote
  non-student staging validation.
- First checkpoint before editing:
  - CWD: `/Users/bwbrook/.codex/worktrees/a4af/rPVA`
  - branch: `codex/rpva-goal021-staging-gate-runbook`
  - HEAD:
    `260e3b2 (HEAD -> codex/rpva-goal021-staging-gate-runbook, origin/main, origin/codex/rpva-goal021-staging-gate-runbook, origin/HEAD, main) Add Practical 1 staging gate runbook`
  - status:
    `## codex/rpva-goal021-staging-gate-runbook...origin/codex/rpva-goal021-staging-gate-runbook`
- Ran `git fetch --prune origin`.
- Confirmed `origin/main` resolves to
  `260e3b20f3fed054cd668860b086bbcb8460efd5`.
- Confirmed no local or remote branch named
  `codex/rpva-goal022-local-remote-staging-validation` was present.
- Created and switched to branch:
  `codex/rpva-goal022-local-remote-staging-validation` from `origin/main`.
- Confirmed branch state after switching:
  - CWD: `/Users/bwbrook/.codex/worktrees/a4af/rPVA`
  - branch: `codex/rpva-goal022-local-remote-staging-validation`
  - HEAD:
    `260e3b2 (HEAD -> codex/rpva-goal022-local-remote-staging-validation, origin/main, origin/codex/rpva-goal021-staging-gate-runbook, origin/HEAD, main, codex/rpva-goal021-staging-gate-runbook) Add Practical 1 staging gate runbook`
  - status:
    `## codex/rpva-goal022-local-remote-staging-validation...origin/main`

## 2026-06-06 - Context Review

- Read:
  - `docs/codex/thread-handoff-2026-06-04.md`
  - `docs/teaching/shiny/README.md`
  - `docs/teaching/shiny/implementation-roadmap.md`
  - `docs/teaching/shiny/deep-server-hosting-feasibility.md`
  - `docs/teaching/shiny/platform-options-decision-matrix.md`
  - `docs/teaching/shiny/road-test-operations-plan.md`
  - `docs/teaching/shiny/student-workspace-and-export-design.md`
  - Goal 020 `Goal.md`, `Plan.md`, `Runbook.md`, and `Log.md`
  - Goal 021 `Goal.md`, `Plan.md`, `Runbook.md`, and `Log.md`
  - `deploy/shinyproxy/practical1/README.md`
  - `deploy/shinyproxy/practical1/Dockerfile.template`
  - `deploy/shinyproxy/practical1/application.example.yml`
  - `deploy/shinyproxy/practical1/nginx-practical1.example.conf`
  - `deploy/shinyproxy/practical1/staging-gate-checklist.md`
  - `deploy/shinyproxy/practical1/validate-scaffold.sh`
  - Nectar control-plane, resource-selection, project-integration,
    data-placement, and current-status docs.
- Context summary:
  - local launch path is `run_practical1_shiny()`;
  - accepted Goal 020 image is `rpva-practical1:goal020-6ed2445`;
  - Goal 021 made TLS, identity, workspace, image promotion, ShinyProxy,
    nginx route, route tests, monitoring, rollback, cleanup, support, and
    approval handoff explicit staging gates;
  - `/data/codex` remains the correct disposable remote workspace root;
  - future paper-facing Lord Howe woodhen analysis remains out of scope.

## 2026-06-06 - CI Failure Addendum

- SRF-A added CI health to Goal 022 after GitHub showed red `R CI` on `main`.
- Inspected GitHub Actions with `gh`:
  - run `27050337437`, title `Add Practical 1 staging gate runbook`, head
    `260e3b20f3fed054cd668860b086bbcb8460efd5`, conclusion `failure`;
  - run `27050148750`, title `Record Goal 020 image rebuild smoke`, head
    `d50cb51459cf9d6f55e8d5de83bdcdd3541a2631`, conclusion `failure`.
- Both failed in job `test`, step `Bootstrap`.
- `setup-r-dependencies` completed first and ran with:
  - `packages: deps::., any::sessioninfo`;
  - `dependencies: "all"`;
  - `R_LIB_FOR_PAK` inside the project `renv` library.
- The bootstrap failure then reported:
  - unrecorded packages installed and used:
    `beeswarm`, `Cairo`, `ggbeeswarm`, `ggrastr`, `pak`, `png`, `ragg`,
    `sessioninfo`, `systemfonts`, `textshaping`, and `vipor`;
  - `callr [3.7.6 != 3.8.0]`;
  - `renv::restore(confirm = FALSE, exclude = "renv")` attempted to update
    `callr [3.8.0 -> 3.7.6]`;
  - restore failed while creating:
    `/home/runner/.cache/R/renv/source/repository/callr`.
- Local evidence:
  - no `.github/workflows/r-ci.yaml`, `bootstrap.R`, `renv.lock`, or
    `DESCRIPTION` changes existed between green `38ef13f` and red `260e3b2`;
  - `DESCRIPTION` keeps `ggrastr` in `Suggests`;
  - repo docs explicitly state optional `ggrastr`/`Cairo` remain out of the
    default restore/check path;
  - `renv/settings.json` dependency fields are `Imports`, `Depends`, and
    `LinkingTo`;
  - after local `bootstrap.R`, `renv::status(sources = FALSE)` reported no
    issues.
- Diagnosis:
  - the workflow pre-seeded the project `renv` library with packages outside
    the lockfile/default dependency policy, then `bootstrap.R` attempted to
    reconcile that contaminated library back to `renv.lock`;
  - the immediate directory-creation error is a cache/path symptom during that
    restore, but the repo-level defect is the conflicting CI dependency setup.

## 2026-06-06 - CI Repair And Local Verification

- Changed `.github/workflows/r-ci.yaml` to remove the
  `r-lib/actions/setup-r-dependencies@v2` pre-bootstrap dependency install.
- Kept all substantive CI gates:
  - `Bootstrap`;
  - `renv status`;
  - `Test suite`;
  - `Woodhen smoke test`.
- Rationale:
  - `bootstrap.R` and `renv.lock` should be the single dependency authority;
  - CI should not install optional `ggrastr`/`Cairo` support packages unless a
    separate goal changes the default dependency policy;
  - the fix does not skip bootstrap, tests, or smoke validation.
- Ran CI-equivalent local sequence:
  - `Rscript -e 'source("bootstrap.R")'`
  - `Rscript -e 'renv::status(sources = FALSE)'`
  - `Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter = "summary")'`
  - `Rscript -e 'source("bootstrap.R"); print(run_scenarios("woodhen", csv_out = NULL, rds_out = NULL, keep_traj = FALSE, parallel = FALSE))'`
- Result: exit code `0`.
- Evidence:
  - bootstrap reported `No issues found -- the project is in a consistent state`;
  - test suite completed all test files through `13_practical1_shiny`;
  - Woodhen smoke returned five scenarios:
    `woodhen_no_intervention`, `woodhen_pig_control`,
    `woodhen_captive_pig`, `woodhen_rat_eradication`, and
    `woodhen_future_baseline`.

## 2026-06-06 - Track A Local Mac Mini Shiny Smoke

- Launch command class:
  - `Rscript -e 'source("bootstrap.R"); run_practical1_shiny(host = "127.0.0.1", port = 3892, launch.browser = FALSE)'`
- Port: `3892`.
- Bound to: `127.0.0.1` only.
- Curl command:
  - `curl --fail --silent --show-error --max-time 5 http://127.0.0.1:3892/`
- Result:
  - first attempt connected before the process was ready and failed locally;
  - second attempt passed;
  - response size: `9902` bytes;
  - response markers included `Practical 1` and `PVA`;
  - Shiny log reported `Listening on http://127.0.0.1:3892`.
- Cleanup:
  - stopped the temporary R/Shiny process;
  - `lsof -nP -iTCP:3892 -sTCP:LISTEN` returned no listener.
- No local Shiny process was left running for Goal 022.

## 2026-06-06 - Track B Read-Only Remote Discovery

- Gateway health:
  - tailnet route:
    `curl -k --max-time 10 https://100.96.185.60/_gateway-health`
    returned `deep-server app gateway ok`;
  - campus IP from the Mac mini route:
    `curl -k --max-time 10 https://131.217.90.193/_gateway-health`
    timed out after about `10` seconds.
- Remote identity:
  - SSH target: `deep-server-ts`;
  - hostname: `deep-server`;
  - architecture: `x86_64`;
  - user: `bwbrook`.
- Docker:
  - CLI: `Docker version 29.5.2, build 79eb04c`;
  - info summary:
    `ServerVersion=29.5.2 Architecture=x86_64 NCPU=64 MemTotal=135068536832 DockerRootDir=/var/lib/docker`;
  - accepted image:
    `rpva-practical1:goal020-6ed2445`;
  - image ID:
    `sha256:346260b5dd1739b758e8b918aaeeddfa0a6040776fb30d576e42919e52895d76`;
  - image size:
    `1786576408` bytes, about `1.79GB`;
  - image created:
    `2026-06-06T12:24:46.191673688+10:00`;
  - no `rpva` containers were reported by the filtered `docker ps -a`.
- ShinyProxy discovery:
  - `command -v shinyproxy` found no binary;
  - `systemctl status shinyproxy --no-pager` returned
    `Unit shinyproxy.service could not be found`;
  - `/etc/shinyproxy`, `/opt/shinyproxy`, and `/var/log/shinyproxy` were
    absent;
  - Java exists at `/usr/bin/java`, OpenJDK `21.0.11`.
- nginx/gateway discovery:
  - nginx binary exists at `/usr/sbin/nginx`;
  - `systemctl is-active nginx` returned `active`;
  - nginx has been running since `2026-06-02 15:46:24 AEST`;
  - unprivileged `nginx -t` failed because it could not read the private
    snakeoil TLS key;
  - `sudo -n nginx -t` passed:
    `nginx: configuration file /etc/nginx/nginx.conf test is successful`;
  - selected config summary showed:
    - `listen 443 ssl`;
    - `listen [::]:443 ssl`;
    - `server_name deep-server utas-ubuntu utas-ubuntu.tail77f589.ts.net 131.217.90.193 100.96.185.60 _`;
    - `location = /_gateway-health`;
    - `location /`;
    - `proxy_pass http://127.0.0.1:3838`.
- Listeners:
  - nginx listening on `0.0.0.0:443` and `[::]:443`;
  - no `127.0.0.1:3838` listener was reported.
- Data roots:
  - `/data` is `13T`, `8.1T` used, `4.5T` available, `65%`;
  - `/data/codex/teaching/rpva-2026` exists;
  - `/data/codex/teaching/rpva-2026/staging` does not yet exist.

## 2026-06-06 - Track B Decision

- Track B stopped after read-only discovery.
- Exact reason:
  - ShinyProxy is absent, including service, expected config directories, and
    log directory.
- This activates the Goal 022 stop rule:
  - if ShinyProxy is absent, stop Track B after discovery and recommend a
    Goal 023 service-bootstrap package.
- No Goal 022 staging workspace was created.
- No remote Docker build was run.
- No remote container was launched.
- No nginx, ShinyProxy, systemd, firewall, DNS, TLS, Docker daemon/service,
  account, credential, class workspace, or external-access state was changed.
- No Barry human-test URL is ready yet. The gateway health URL is live on the
  tailnet, but no Practical 1 app path is staged behind it.

## 2026-06-06 - Packet And Targeted Doc Updates

- Created:
  - `docs/goals/022-local-remote-staging-validation/Goal.md`
  - `docs/goals/022-local-remote-staging-validation/Plan.md`
  - `docs/goals/022-local-remote-staging-validation/Runbook.md`
  - `docs/goals/022-local-remote-staging-validation/Log.md`
- Updated:
  - `.github/workflows/r-ci.yaml`
  - `docs/teaching/shiny/README.md`
  - `docs/teaching/shiny/implementation-roadmap.md`
- No app, package, scenario, dependency, test, manuscript, or research-analysis
  files were changed.

## 2026-06-06 - Validation

- Ran `git status --short --branch`:
  - branch:
    `## codex/rpva-goal022-local-remote-staging-validation...origin/main`
  - modified:
    - `.github/workflows/r-ci.yaml`
    - `docs/teaching/shiny/README.md`
    - `docs/teaching/shiny/implementation-roadmap.md`
  - new:
    - `docs/goals/022-local-remote-staging-validation/`
- Ran `git diff --check`:
  - passed with no output.
- Ran workflow lint:
  - `actionlint .github/workflows/r-ci.yaml`
  - passed with no output.
- Ran marker scan over changed/new tracked text:
  - `.github/workflows/r-ci.yaml`
  - `docs/goals/022-local-remote-staging-validation`
  - `docs/teaching/shiny/README.md`
  - `docs/teaching/shiny/implementation-roadmap.md`
  - result: no hits.
- Ran shell syntax check:
  - `bash -n deploy/shinyproxy/practical1/validate-scaffold.sh`
  - passed.
- Ran scaffold validator:
  - `bash deploy/shinyproxy/practical1/validate-scaffold.sh`
  - output:
    `Practical 1 Shiny deployment scaffold static checks passed.`
- Ran explicit YAML parse:
  - `ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0)); puts "ruby yaml parse ok"' deploy/shinyproxy/practical1/application.example.yml`
  - output:
    `ruby yaml parse ok`
- Ran secret-pattern scan over changed/new tracked text:
  - hits were limited to policy/gate wording about accounts, tokens,
    credentials, secret scanning, and the scan command itself;
  - no real-looking secrets, keys, passwords, private TLS material, student
    identifiers, or plausible credentials were found.
- CI-equivalent local R verification was run because the workflow changed.
- No additional R package test suite was required for docs/log/runtime staging,
  but the CI-equivalent test suite was already included in the workflow repair
  verification.

## 2026-06-06 - Boundary Confirmation

- No student-facing release.
- No student accounts, class accounts, or class workspaces.
- No public, campus, tailnet, or student-facing app exposure.
- No ShinyProxy installation or configuration.
- No nginx, systemd, firewall, DNS, TLS certificate, Docker daemon/service,
  account, credential, class workspace, or external-access changes.
- No remote writes.
- No remote Docker build.
- No remote Docker container launch.
- No host package installs.
- No app, package, scenario, dependency, test, manuscript, or research-analysis
  code changes.
- No commit or push.

## 2026-06-09 - Closeout Validation

- Chief of Staff approved Goal 022 closeout and publication if validation
  supports it.
- Start state before touching the worktree:
  - CWD: `/Users/bwbrook/.codex/worktrees/a4af/rPVA`
  - repo root: `/Users/bwbrook/.codex/worktrees/a4af/rPVA`
  - branch: `codex/rpva-goal022-local-remote-staging-validation`
  - HEAD: `260e3b2`
  - status:
    `## codex/rpva-goal022-local-remote-staging-validation...origin/main`
  - branch contained no commits beyond `origin/main`; it contained only
    uncommitted Goal 022 work.
- Ran `git fetch --prune origin`.
- Confirmed `origin/main` was `260e3b2`.
- Ran `git diff --check`:
  - passed with no output.
- Ran scaffold checks:
  - `bash -n deploy/shinyproxy/practical1/validate-scaffold.sh`
  - `bash deploy/shinyproxy/practical1/validate-scaffold.sh`
  - `ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0)); puts "ruby yaml parse ok"' deploy/shinyproxy/practical1/application.example.yml`
  - all passed.
- Ran `actionlint .github/workflows/r-ci.yaml`:
  - passed with no output.
- Ran marker scan over changed/new text:
  - no hits.
- Ran secret-pattern scan over changed/new text:
  - hits were limited to policy wording and the scan command itself;
  - no real-looking secrets, credentials, private TLS material, or student
    identifiers were found.
- Reran CI-equivalent local verification:
  - `Rscript -e 'source("bootstrap.R")'`
  - `Rscript -e 'renv::status(sources = FALSE)'`
  - `Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter = "summary")'`
  - `Rscript -e 'source("bootstrap.R"); print(run_scenarios("woodhen", csv_out = NULL, rds_out = NULL, keep_traj = FALSE, parallel = FALSE))'`
  - result: exit code `0`.
- Reran local Shiny smoke:
  - bound to `127.0.0.1:3892`;
  - curl passed on attempt `3`;
  - response size was `9902` bytes with `Practical 1` and `PVA` markers;
  - temporary process was stopped;
  - `lsof -nP -iTCP:3892 -sTCP:LISTEN` returned no listener.
- Publication decision:
  - Goal 022 is safe to publish as a docs/CI/local-validation closeout;
  - the remote staging blocker remains explicitly documented as the next
    Goal 023 service-bootstrap/staging gate, not as a reason to hold the
    Goal 022 CI and discovery evidence off `main`.
