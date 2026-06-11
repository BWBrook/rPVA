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
branch: codex/rpva-goal032-student-launch-pack
base: d394b27 Add Practical 1 delivery-candidate rehearsal pack
```

Stop if there is unexpected dirty state beyond the Goal 032 packet.

## Sources To Read

Read at minimum:

- `docs/goals/032-practical-1-student-launch-pack/Goal.md`
- `docs/goals/032-practical-1-student-launch-pack/Plan.md`
- `docs/goals/032-practical-1-student-launch-pack/Runbook.md`
- `docs/teaching/shiny/README.md`
- `docs/teaching/shiny/practical-1-mission-tutorial.md`
- `docs/teaching/woodhen/README.md`
- `docs/teaching/woodhen/practical-1-mission-worksheet.md`
- `docs/teaching/woodhen/practical-1-day-of-class-pack.md`
- `docs/teaching/woodhen/practical-1-go-no-go-checklist.md`
- `docs/teaching/woodhen/practical-1-instructor-beat-sheet.md`
- `docs/teaching/woodhen/practical-1-fallback-pack.md`
- `docs/teaching/woodhen/troubleshooting.md`
- `docs/teaching/woodhen/expected-outputs.md`
- `docs/teaching/woodhen/report-scaffold.qmd`
- `docs/goals/031-practical-1-delivery-candidate-rehearsal-pack/delivery-rehearsal-report.md`

## Student-Zero Browser Rehearsal

Use a local app route unless a fully approved class route is explicitly green.

Example local launch:

```sh
Rscript -e 'source("bootstrap.R"); run_practical1_shiny(host = "127.0.0.1", port = 3899, launch.browser = FALSE)'
```

Suggested evidence directory:

```sh
mkdir -p /tmp/rpva-goal032-student-zero
```

Exercise:

1. Start baseline.
2. Carrying capacity.
3. Environmental or demographic stochasticity.
4. Catastrophe or genetic stochasticity.
5. Simple intervention or extinction-vortex comparison.
6. Compare.
7. CSV export.
8. Evidence-notes Markdown export.
9. Transfer.

Stop the Shiny process after the rehearsal and confirm the port is closed:

```sh
lsof -nP -iTCP:3899 -sTCP:LISTEN
```

## Validation Commands

```sh
git diff --check
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
```

Render report scaffold sequentially if it is included in the launch package:

```sh
quarto render docs/teaching/woodhen/report-scaffold.qmd --to docx --output-dir /tmp/rpva-goal032-report
quarto render docs/teaching/woodhen/report-scaffold.qmd --to pdf --output-dir /tmp/rpva-goal032-report
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

Raw-IP/insecure-route check:

```sh
files=$( { git diff --name-only --diff-filter=ACMRTUXB; git ls-files --others --exclude-standard; } | sort -u )
test -z "$files" || printf "%s\n" "$files" | xargs rg -n "131\\.217\\.90\\.193|100\\.96\\.185\\.60|raw-IP|insecure HTTPS|browser-warning|not secure" || true
```

Classify any hits. It is acceptable and expected for instructor/boundary docs
to warn against raw-IP or insecure HTTPS routes. Student-facing launch files
must not direct students to use such routes as release-ready.

## Report Contents

`student-zero-rehearsal-report.md` should include:

- starting branch/base/status;
- files reviewed;
- launch materials created;
- student-zero rehearsal path;
- screenshot and download evidence paths;
- report-render evidence if run;
- validation results;
- scan classifications;
- hosted student URL readiness judgement;
- remaining blockers or next gate.

## Final Response To Orchestrator

Include:

- branch, HEAD, and final status;
- changed/new files;
- concise description of launch pack and Moodle manifest;
- student-zero evidence paths;
- validation results;
- scan classification;
- boundaries observed;
- recommendation for closeout or revision.
