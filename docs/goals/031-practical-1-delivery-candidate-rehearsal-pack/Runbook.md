# Runbook

Goal 031 is a local delivery-rehearsal and class-packaging goal. Do not change
live services, remote state, science defaults, or assessment policy.

## Local Guard

```sh
pwd
git branch --show-current
git rev-parse HEAD
git rev-parse origin/main
git status --short --branch
```

Expected:

```text
branch: codex/rpva-goal031-delivery-candidate-rehearsal
HEAD/origin-main base: d4855fc Add Practical 1 mission-mode app affordances
```

The only expected starting dirty state is the untracked Goal 031 packet
directory created by the orchestrator.

## Source Facts To Use

Use accepted repo-local records and live repo files:

- `docs/teaching/shiny/practical-1-mission-tutorial.md`
- `docs/teaching/woodhen/practical-1-mission-worksheet.md`
- `docs/teaching/woodhen/practical-1-instructor-beat-sheet.md`
- `docs/teaching/woodhen/practical-1-fallback-pack.md`
- `docs/teaching/woodhen/classroom-dry-run-checklist.md`
- `docs/teaching/woodhen/instructor-guide.md`
- `docs/goals/030-practical-1-mission-mode-app-affordance-polish/Log.md`
- `inst/shiny/practical1/app.R`

Do not read Chief of Staff, Goal Composer, sibling project folders, KPZ314
materials, or archive material.

## Rehearsal Shape

Exercise a realistic but time-bounded path:

1. Start baseline.
2. Carrying capacity.
3. Environmental or demographic stochasticity.
4. Catastrophe or genetics.
5. Simple intervention or extinction vortex.
6. Compare table and guidance.
7. Comparison CSV download.
8. Evidence-notes Markdown download.
9. Transfer screen.

Record whether the path supports the Goal 029 timing and whether any wording
or delivery-pack gap would confuse students or demonstrators.

## Delivery Pack Content

The day-of-class pack should include:

- pre-class checks;
- student opening instructions;
- Barry priming script bullets;
- recap beats;
- mission timing;
- expected student evidence;
- download failure response;
- fallback switch rule;
- local/in-room readiness note;
- hosted student URL release note;
- post-class observations to capture.

Use neutral app URL text such as `[class app URL]`; do not imply that the
current raw-IP or insecure HTTPS route is student-ready.

## Go/No-Go Checklist Content

Use separate sections:

1. Local/in-room teaching go/no-go.
2. Hosted route/TLS/student-release go/no-go.
3. Fallback readiness.
4. Day-after cleanup/notes.

The hosted route section should explicitly say that trusted hostname/TLS,
student access model, and any class-account/workspace decisions are outside
Goal 031 and remain future-gated.

## Commands

Focused validation:

```sh
git status --short --branch
git diff --check
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
```

Report scaffold render if needed:

```sh
quarto render docs/teaching/woodhen/report-scaffold.qmd --to docx --output-dir /tmp/rpva-goal031-report
quarto render docs/teaching/woodhen/report-scaffold.qmd --to pdf --output-dir /tmp/rpva-goal031-report
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

## Browser Evidence

Save screenshots and downloads outside the repo, preferably under:

```text
/tmp/rpva-goal031-browser/
```

Record:

- app URL and port;
- browser automation path used;
- screenshots;
- downloaded CSV and Markdown paths;
- proof the Shiny process stopped and the port closed.

## Final Report Checklist

Include:

- branch, HEAD, and status;
- changed files;
- rehearsal path;
- day-of-class pack path;
- go/no-go checklist path;
- evidence paths;
- validation results;
- readiness judgement;
- remaining hosted-route blockers;
- boundaries observed.
