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
branch: codex/rpva-goal033-moodle-ready-artefact-bundle
base: 55e2bf6 Add Practical 1 student launch pack
```

Stop if there is unexpected dirty state beyond the Goal 033 packet.

## Sources To Read

Read at minimum:

- `docs/goals/033-practical-1-moodle-ready-artefact-bundle/Goal.md`
- `docs/goals/033-practical-1-moodle-ready-artefact-bundle/Plan.md`
- `docs/goals/033-practical-1-moodle-ready-artefact-bundle/Runbook.md`
- `docs/teaching/woodhen/.gitignore`
- `.gitignore`
- `docs/teaching/woodhen/README.md`
- `docs/teaching/woodhen/instructor-guide.md`
- `docs/teaching/woodhen/practical-1-student-launch-page.md`
- `docs/teaching/woodhen/practical-1-mission-worksheet.md`
- `docs/teaching/woodhen/practical-1-moodle-upload-manifest.md`
- `docs/teaching/woodhen/practical-1-day-of-class-pack.md`
- `docs/teaching/woodhen/practical-1-go-no-go-checklist.md`
- `docs/goals/032-practical-1-student-launch-pack/student-zero-rehearsal-report.md`

## Suggested Artefact Commands

Use the repo's existing tools and avoid adding dependencies.

Report scaffold:

```sh
mkdir -p /tmp/rpva-goal033-report
quarto render docs/teaching/woodhen/report-scaffold.qmd --to docx --output-dir /tmp/rpva-goal033-report
quarto render docs/teaching/woodhen/report-scaffold.qmd --to pdf --output-dir /tmp/rpva-goal033-report
```

Markdown-to-PDF or Markdown-to-DOCX artefacts, if useful:

```sh
mkdir -p /tmp/rpva-goal033-rendered
pandoc docs/teaching/woodhen/practical-1-mission-worksheet.md -o /tmp/rpva-goal033-rendered/practical-1-mission-worksheet.docx
pandoc docs/teaching/woodhen/practical-1-student-launch-page.md -o /tmp/rpva-goal033-rendered/practical-1-student-launch-page.docx
```

Only commit generated artefacts if they are intentionally part of the handoff
bundle and not blocked by repo ignore policy. Otherwise record `/tmp` paths,
commands, sizes, and checksums in the report and manifest.

Checksum examples:

```sh
shasum -a 256 /tmp/rpva-goal033-rendered/* /tmp/rpva-goal033-report/* 2>/dev/null || true
```

File checks:

```sh
file /tmp/rpva-goal033-rendered/* /tmp/rpva-goal033-report/* 2>/dev/null || true
pdfinfo /tmp/rpva-goal033-report/report-scaffold.pdf
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
  docs/teaching/woodhen/practical-1-moodle-ready-bundle 2>/dev/null || true
```

Classify any hits. It is acceptable for manifest or instructor-facing bundle
notes to warn against raw-IP or insecure HTTPS routes. Student-facing paste
text must not direct students to use such routes.

## Report Contents

`artefact-bundle-report.md` should include:

- starting branch/base/status;
- files reviewed;
- bundle shape;
- generated artefacts and whether they are committed or temp-only;
- file type, size, checksum, and PDF metadata evidence;
- validation results;
- scan classifications;
- hosted student URL readiness judgement;
- readiness for Barry-as-student roleplay;
- recommended next gate.

## Final Response To Orchestrator

Include:

- branch, HEAD, and final status;
- changed/new files;
- bundle folder and artefact summary;
- render/checksum evidence;
- validation results;
- scan classification;
- boundaries observed;
- whether this is ready for the Barry roleplay checkpoint or needs one more
  packaging pass.
