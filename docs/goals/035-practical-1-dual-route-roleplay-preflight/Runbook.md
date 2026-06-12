# Runbook

## Start Guard

```sh
pwd
git rev-parse --abbrev-ref HEAD
git rev-parse HEAD
git status --short --branch
git log -1 --oneline
```

Expected:

```text
pwd: /Users/bwbrook/git/rPVA
branch: codex/rpva-goal035-dual-route-roleplay-preflight
base: dfe4be4 Add Practical 1 roleplay readiness pack
```

Stop if there is unexpected dirty state beyond the Goal 035 packet.

## Sources To Read

Read at minimum:

- `docs/goals/035-practical-1-dual-route-roleplay-preflight/Goal.md`
- `docs/goals/035-practical-1-dual-route-roleplay-preflight/Plan.md`
- `docs/goals/035-practical-1-dual-route-roleplay-preflight/Runbook.md`
- `docs/teaching/woodhen/README.md`
- `docs/teaching/woodhen/instructor-guide.md`
- `docs/teaching/shiny/README.md`
- `docs/teaching/woodhen/practical-1-student-launch-page.md`
- `docs/teaching/woodhen/practical-1-mission-worksheet.md`
- `docs/teaching/woodhen/practical-1-barry-roleplay-script.md`
- `docs/teaching/woodhen/practical-1-roleplay-notes-template.md`
- `docs/teaching/woodhen/practical-1-roleplay-go-no-go.md`
- `docs/teaching/woodhen/practical-1-moodle-ready-bundle/README.md`
- `docs/teaching/woodhen/practical-1-moodle-ready-bundle/moodle-section-text.md`
- `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/staging-report.md`
- `docs/goals/026-campus-route-tls-readiness/campus-tls-readiness-report.md`
- `docs/goals/027-trusted-class-hostname-tls-gate/trusted-class-hostname-tls-report.md`
- `docs/goals/028-campus-it-tls-request-pack/campus-it-tls-request-pack.md`
- `inst/shiny/practical1/app.R`

## Local Mac Route Preflight

Use a local app route and keep evidence out of the repo.

Suggested evidence directory:

```sh
mkdir -p /tmp/rpva-goal035-local-route/screenshots /tmp/rpva-goal035-local-route/downloads
```

Suggested local app launch:

```sh
Rscript -e 'source("bootstrap.R"); run_practical1_shiny(host = "127.0.0.1", port = 3901, launch.browser = FALSE)'
```

Use Browser, Chrome, or Playwright to exercise `http://127.0.0.1:3901/`.

Exercise:

1. open the route-aware runbook and current launch/worksheet materials;
2. click `Start baseline`;
3. run carrying capacity;
4. run environmental or demographic stochasticity;
5. run catastrophe or genetic stochasticity;
6. run simple intervention or extinction-vortex comparison;
7. open Compare;
8. download comparison CSV;
9. download evidence-notes Markdown;
10. inspect the worksheet evidence-recording section;
11. reach Transfer.

Record screenshots and export paths in the report. Inspect exports for the
accepted shape:

- comparison CSV keeps the `run_id, stage, label, scenario, years, reps, PE`
  leading columns;
- baseline remains run 1;
- evidence notes retain the evidence-not-answer framing.

Stop Shiny after the rehearsal and confirm no listener remains:

```sh
lsof -nP -iTCP:3901 -sTCP:LISTEN
```

## Hosted Deep-Server Route Posture

Use read-only checks only. Do not repair anything.

Record the current checks in
`docs/goals/035-practical-1-dual-route-roleplay-preflight/dual-route-preflight-report.md`.

Suggested non-secret checks:

```sh
curl -k --max-time 10 -sS -o /tmp/rpva-goal035-tailnet-health.txt -w '%{http_code} %{url_effective}\n' https://100.96.185.60/_gateway-health
curl --max-time 10 -sS -o /tmp/rpva-goal035-tailnet-health-trusted.txt -w '%{http_code} %{ssl_verify_result} %{url_effective}\n' https://100.96.185.60/_gateway-health || true
curl -k --max-time 10 -sS -o /tmp/rpva-goal035-campus-health.txt -w '%{http_code} %{url_effective}\n' https://131.217.90.193/_gateway-health || true
curl -k --max-time 10 -sS -o /tmp/rpva-goal035-campus-login.html -w '%{http_code} %{url_effective}\n' https://131.217.90.193/login || true
```

TLS metadata checks, if available:

```sh
printf '' | openssl s_client -connect 100.96.185.60:443 -servername 100.96.185.60 2>/tmp/rpva-goal035-tailnet-sclient.err | openssl x509 -noout -subject -issuer -ext subjectAltName > /tmp/rpva-goal035-tailnet-cert.txt || true
printf '' | openssl s_client -connect 131.217.90.193:443 -servername 131.217.90.193 2>/tmp/rpva-goal035-campus-sclient.err | openssl x509 -noout -subject -issuer -ext subjectAltName > /tmp/rpva-goal035-campus-cert.txt || true
```

If login or `/app/practical1` testing requires credentials, use only an
already-authorised non-student staging credential flow that avoids writing,
printing, screenshotting, or committing the credential. If that is not clearly
available, stop that subcheck and report it as a human-action gate.

Do not:

- edit nginx, ShinyProxy, systemd, firewall, DNS, TLS, Docker, account, token,
  or credential state;
- copy secrets from remote hosts;
- store route credentials in the repo;
- mark the hosted warning route as student-ready.

## Route-Aware Materials

The new runbook should tell Barry:

- Stage A happens first on the controlled local Mac route;
- Stage B happens second on the hosted deep-server route from Windows 11, only
  if the orchestrator supplies the exact route and credentials out of band;
- the browser warning is expected for Stage B while IT/TLS remains pending;
- he should record the warning/access friction, accept it only for this
  instructor-controlled test, and keep moving if the app works;
- he should stop and report if he cannot reach login, cannot authenticate,
  cannot open Practical 1, cannot export evidence, or feels the guidance is
  unclear;
- the same hosted path must not be given to students until the trusted-route
  gate is passed.

The feedback-return template should support quick notes for:

- local route access;
- hosted route warning/access/login;
- first confusion point;
- mission pacing;
- app control clarity;
- worksheet burden;
- evidence export;
- Transfer prompt;
- overall engagement;
- must-fix before students;
- nice-to-fix before students.

## Validation Commands

```sh
git diff --check
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
```

Marker scan:

```sh
files=$( { git diff --name-only --diff-filter=ACMRTUXB; git ls-files --others --exclude-standard; } | sort -u )
pattern="$(printf '%s|%s|%s|%s|%s|%s' 'TO''DO' 'T''BD' 'FIX''ME' 'PLACE''HOLDER' 'X''XX' 'CHANGE''ME')"
test -z "$files" || printf "%s\n" "$files" | xargs rg -n --pcre2 "(?i)($pattern)" || true
```

Secret/private-key scan:

```sh
files=$( { git diff --name-only --diff-filter=ACMRTUXB; git ls-files --others --exclude-standard; } | sort -u )
test -z "$files" || printf "%s\n" "$files" | xargs rg -n --pcre2 "(?i)(api[_-]?key|secret|token|password|credential|passwd|private[ _-]?key|BEGIN (RSA|OPENSSH|EC|PRIVATE) KEY)" || true
```

Stricter scan:

```sh
files=$( { git diff --name-only --diff-filter=ACMRTUXB; git ls-files --others --exclude-standard; } | sort -u )
test -z "$files" || printf "%s\n" "$files" | xargs rg -n --pcre2 "(?i)(api[_-]?key|secret|token|password|credential|passwd)\s*[:=]\s*['\"]?[^'\"[:space:]]{8,}|BEGIN (RSA|OPENSSH|EC|PRIVATE) KEY" || true
```

Student-visible and roleplay-route wording check:

```sh
rg -n "131\\.217\\.90\\.193|100\\.96\\.185\\.60|raw-IP|insecure HTTPS|browser-warning|not secure|self-signed|release-ready|student-ready" \
  docs/teaching/woodhen/practical-1-student-launch-page.md \
  docs/teaching/woodhen/practical-1-mission-worksheet.md \
  docs/teaching/woodhen/practical-1-moodle-ready-bundle/moodle-section-text.md \
  docs/teaching/woodhen/practical-1-barry-roleplay-script.md \
  docs/teaching/woodhen/practical-1-roleplay-notes-template.md \
  docs/teaching/woodhen/practical-1-dual-route-roleplay-runbook.md \
  docs/teaching/woodhen/practical-1-roleplay-feedback-return-template.md 2>/dev/null || true
```

Classify any hits. Barry-roleplay materials may describe the warning-accepted
hosted route only as instructor-controlled testing. Student launch material must
not present the route as student-ready.

## Report Contents

`dual-route-preflight-report.md` should include:

- starting branch/base/status;
- files reviewed;
- route-aware materials created or updated;
- local route rehearsal path and evidence;
- hosted route posture checks and evidence;
- exact Windows 11 checks still reserved for Barry;
- validation results;
- scan classifications;
- readiness judgement for Barry's two-stage roleplay;
- student release judgement;
- recommended next gate.

## Final Response To Orchestrator

Include:

- branch, HEAD, and final status;
- changed/new files;
- local route evidence;
- hosted route posture evidence;
- runbook/template summary;
- validation results;
- scan classification;
- boundaries observed;
- whether this is ready for Barry's two-stage roleplay execution goal.
