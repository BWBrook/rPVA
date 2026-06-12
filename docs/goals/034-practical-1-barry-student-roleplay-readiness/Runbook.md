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
branch: codex/rpva-goal034-barry-student-roleplay-readiness
base: 1fe1a38 Add Practical 1 Moodle-ready bundle
```

Stop if there is unexpected dirty state beyond the Goal 034 packet.

## Sources To Read

Read at minimum:

- `docs/goals/034-practical-1-barry-student-roleplay-readiness/Goal.md`
- `docs/goals/034-practical-1-barry-student-roleplay-readiness/Plan.md`
- `docs/goals/034-practical-1-barry-student-roleplay-readiness/Runbook.md`
- `docs/teaching/woodhen/README.md`
- `docs/teaching/woodhen/instructor-guide.md`
- `docs/teaching/woodhen/practical-1-student-launch-page.md`
- `docs/teaching/woodhen/practical-1-mission-worksheet.md`
- `docs/teaching/woodhen/practical-1-moodle-ready-bundle/README.md`
- `docs/teaching/woodhen/practical-1-moodle-ready-bundle/moodle-section-text.md`
- `docs/teaching/woodhen/practical-1-moodle-ready-bundle/manifest.md`
- `docs/teaching/woodhen/practical-1-day-of-class-pack.md`
- `docs/teaching/woodhen/practical-1-go-no-go-checklist.md`
- `docs/goals/033-practical-1-moodle-ready-artefact-bundle/artefact-bundle-report.md`

## Local Roleplay Rehearsal

Use a local app route unless a fully approved class route is explicitly green.

Suggested evidence directory:

```sh
mkdir -p /tmp/rpva-goal034-roleplay-readiness
```

Suggested local app launch:

```sh
Rscript -e 'source("bootstrap.R"); run_practical1_shiny(host = "127.0.0.1", port = 3900, launch.browser = FALSE)'
```

Exercise:

1. Open roleplay script.
2. Open launch page and worksheet.
3. Start baseline.
4. Carrying capacity.
5. Environmental or demographic stochasticity.
6. Catastrophe or genetic stochasticity.
7. Simple intervention or extinction-vortex comparison.
8. Compare.
9. CSV export.
10. Evidence-notes Markdown export.
11. Worksheet evidence-recording section.
12. Transfer.

Stop Shiny after the rehearsal and confirm no listener remains:

```sh
lsof -nP -iTCP:3900 -sTCP:LISTEN
```

## Artefact Regeneration

Run from repo root:

```sh
mkdir -p /tmp/rpva-goal034-rendered /tmp/rpva-goal034-report
pandoc docs/teaching/woodhen/practical-1-mission-worksheet.md -o /tmp/rpva-goal034-rendered/practical-1-mission-worksheet.docx
pandoc docs/teaching/woodhen/practical-1-student-launch-page.md -o /tmp/rpva-goal034-rendered/practical-1-student-launch-page.docx
quarto render docs/teaching/woodhen/report-scaffold.qmd --to docx --output-dir /tmp/rpva-goal034-report
quarto render docs/teaching/woodhen/report-scaffold.qmd --to pdf --output-dir /tmp/rpva-goal034-report
```

Check files:

```sh
ls -l /tmp/rpva-goal034-rendered/* /tmp/rpva-goal034-report/*
shasum -a 256 /tmp/rpva-goal034-rendered/* /tmp/rpva-goal034-report/*
file /tmp/rpva-goal034-rendered/* /tmp/rpva-goal034-report/*
pdfinfo /tmp/rpva-goal034-report/report-scaffold.pdf
```

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

Student-visible route wording check:

```sh
rg -n "131\\.217\\.90\\.193|100\\.96\\.185\\.60|raw-IP|insecure HTTPS|browser-warning|not secure|release-ready" \
  docs/teaching/woodhen/practical-1-student-launch-page.md \
  docs/teaching/woodhen/practical-1-mission-worksheet.md \
  docs/teaching/woodhen/practical-1-moodle-ready-bundle/moodle-section-text.md \
  docs/teaching/woodhen/practical-1-barry-roleplay-script.md \
  docs/teaching/woodhen/practical-1-roleplay-notes-template.md 2>/dev/null || true
```

Classify any hits. Student-facing roleplay material must not direct Barry to
use an unapproved route as if it were student-ready.

## Report Contents

`roleplay-readiness-report.md` should include:

- starting branch/base/status;
- files reviewed;
- roleplay pack files created;
- local roleplay rehearsal path and evidence;
- generated artefact evidence;
- validation results;
- scan classifications;
- hosted student URL readiness judgement;
- readiness for Barry roleplay execution;
- recommended next gate.

## Final Response To Orchestrator

Include:

- branch, HEAD, and final status;
- changed/new files;
- roleplay pack summary;
- local rehearsal evidence paths;
- generated artefact verification;
- validation results;
- scan classification;
- boundaries observed;
- whether this is ready for the Barry roleplay execution goal.
