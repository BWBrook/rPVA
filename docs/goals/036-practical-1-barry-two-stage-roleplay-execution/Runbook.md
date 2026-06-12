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
branch: codex/rpva-goal036-barry-two-stage-roleplay
base: 93601e7 Add Practical 1 dual-route roleplay preflight
```

Stop if there is unexpected dirty state beyond the Goal 036 packet.

## Sources To Read

Read at minimum:

- `docs/goals/036-practical-1-barry-two-stage-roleplay-execution/Goal.md`
- `docs/goals/036-practical-1-barry-two-stage-roleplay-execution/Plan.md`
- `docs/goals/036-practical-1-barry-two-stage-roleplay-execution/Runbook.md`
- `docs/goals/036-practical-1-barry-two-stage-roleplay-execution/Log.md`
- `docs/goals/035-practical-1-dual-route-roleplay-preflight/dual-route-preflight-report.md`
- `docs/teaching/woodhen/practical-1-dual-route-roleplay-runbook.md`
- `docs/teaching/woodhen/practical-1-roleplay-feedback-return-template.md`
- `docs/teaching/woodhen/practical-1-dual-route-go-no-go.md`
- `docs/teaching/woodhen/practical-1-barry-roleplay-script.md`
- `docs/teaching/woodhen/practical-1-roleplay-notes-template.md`
- `docs/teaching/woodhen/practical-1-roleplay-go-no-go.md`
- `docs/teaching/woodhen/practical-1-student-launch-page.md`
- `docs/teaching/woodhen/practical-1-mission-worksheet.md`
- `docs/teaching/woodhen/practical-1-moodle-ready-bundle/moodle-section-text.md`
- `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/staging-report.md`
- `docs/goals/026-campus-route-tls-readiness/campus-tls-readiness-report.md`
- `docs/goals/027-trusted-class-hostname-tls-gate/trusted-class-hostname-tls-report.md`
- `docs/goals/028-campus-it-tls-request-pack/campus-it-tls-request-pack.md`
- `inst/shiny/practical1/app.R`

## Local Stage A Proof

Use a local app route and keep evidence out of the repo.

Suggested evidence directory:

```sh
mkdir -p /tmp/rpva-goal036-stage-a/screenshots /tmp/rpva-goal036-stage-a/downloads
```

Suggested local app launch:

```sh
Rscript -e 'source("bootstrap.R"); run_practical1_shiny(host = "127.0.0.1", port = 3902, launch.browser = FALSE)'
```

Exercise `http://127.0.0.1:3902/` with Browser, Chrome, or Playwright:

1. click `Start baseline`;
2. run carrying capacity;
3. run environmental or demographic stochasticity;
4. run catastrophe or genetic stochasticity;
5. run simple intervention or extinction-vortex comparison;
6. open Compare;
7. download comparison CSV;
8. download evidence-notes Markdown;
9. inspect the worksheet evidence-recording section;
10. reach Transfer.

Record screenshots and export paths in the report. Inspect exports for:

- comparison CSV leading columns beginning with
  `run_id, stage, label, scenario, years, reps, PE`;
- baseline as run 1;
- evidence notes retaining the evidence-not-answer framing.

Stop Shiny after the proof and confirm no listener remains:

```sh
lsof -nP -iTCP:3902 -sTCP:LISTEN
```

## Hosted Stage B Posture

Use read-only checks only. Do not repair anything.

Suggested non-secret checks:

```sh
curl -k --max-time 10 -sS -o /tmp/rpva-goal036-tailnet-health.txt -w '%{http_code} %{url_effective}\n' https://100.96.185.60/_gateway-health
curl --max-time 10 -sS -o /tmp/rpva-goal036-tailnet-health-trusted.txt -w '%{http_code} %{ssl_verify_result} %{url_effective}\n' https://100.96.185.60/_gateway-health || true
curl -k --max-time 10 -sS -o /tmp/rpva-goal036-campus-health.txt -w '%{http_code} %{url_effective}\n' https://131.217.90.193/_gateway-health || true
curl -k --max-time 10 -sS -o /tmp/rpva-goal036-campus-login.html -w '%{http_code} %{url_effective}\n' https://131.217.90.193/login || true
curl -k --max-time 10 -sS -o /tmp/rpva-goal036-tailnet-login.html -w '%{http_code} %{url_effective}\n' https://100.96.185.60/login || true
curl -k --max-time 10 -sS -o /tmp/rpva-goal036-tailnet-app.html -w '%{http_code} %{redirect_url} %{url_effective}\n' https://100.96.185.60/app/practical1 || true
```

TLS metadata checks, if available:

```sh
printf '' | openssl s_client -connect 100.96.185.60:443 -servername 100.96.185.60 2>/tmp/rpva-goal036-tailnet-sclient.err | openssl x509 -noout -subject -issuer -ext subjectAltName > /tmp/rpva-goal036-tailnet-cert.txt || true
printf '' | openssl s_client -connect 131.217.90.193:443 -servername 131.217.90.193 2>/tmp/rpva-goal036-campus-sclient.err | openssl x509 -noout -subject -issuer -ext subjectAltName > /tmp/rpva-goal036-campus-cert.txt || true
```

Optional remote read-only posture through `deep-server-ts` is allowed if it
only checks service activity and localhost health/login. Do not print, copy, or
commit secrets or private keys.

If login or `/app/practical1` testing requires credentials, report that the
human Stage B pass needs out-of-band access details. Do not place credentials
in docs or logs.

## Session Brief Content

The session brief should give the orchestrator a paste-ready human handoff. It
should include:

- purpose and expected duration;
- materials Barry should open;
- evidence folder convention;
- Stage A route and evidence expectations;
- Stage B warning-route boundary and evidence expectations;
- stop rules;
- what Barry should return;
- post-roleplay triage path.

The brief may name exact non-secret routes if they are clearly marked
instructor-only and are not added to student launch, worksheet, or Moodle
content.

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

Route wording check:

```sh
rg -n "131\\.217\\.90\\.193|100\\.96\\.185\\.60|raw-IP|insecure HTTPS|browser-warning|not secure|self-signed|release-ready|student-ready|warning" \
  docs/teaching/woodhen/practical-1-student-launch-page.md \
  docs/teaching/woodhen/practical-1-mission-worksheet.md \
  docs/teaching/woodhen/practical-1-moodle-ready-bundle/moodle-section-text.md \
  docs/teaching/woodhen/practical-1-barry-roleplay-script.md \
  docs/teaching/woodhen/practical-1-roleplay-notes-template.md \
  docs/teaching/woodhen/practical-1-roleplay-feedback-return-template.md \
  docs/teaching/woodhen/practical-1-dual-route-roleplay-runbook.md \
  docs/teaching/woodhen/practical-1-barry-roleplay-session-brief.md 2>/dev/null || true
```

Classify any hits. Exact route or warning text may appear in
orchestrator/instructor-facing roleplay materials, but not as student release
instructions.

## Final Response To Orchestrator

Include:

- branch, HEAD, and final status;
- changed/new files;
- session brief summary;
- local Stage A proof evidence;
- hosted Stage B posture evidence;
- validation results;
- scan classification;
- whether Barry can now run Stage A, Stage B, both, or neither;
- what Barry should return for Checkpoint B triage;
- boundaries observed.
