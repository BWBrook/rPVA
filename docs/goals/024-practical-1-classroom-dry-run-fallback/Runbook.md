# Runbook

## Contract

Read `Goal.md` first. This runbook gives a safe execution order and does not
authorize broadening into deployment or science work.

## Start

From `/Users/bwbrook/git/rPVA`:

```sh
pwd
git branch --show-current
git rev-parse --short HEAD
git status --short --branch
test -f AGENTS.md && sed -n '1,180p' AGENTS.md || true
```

Expected branch:

```text
codex/rpva-goal024-classroom-dry-run
```

Expected start commit:

```text
3b61507
```

If branch or status is unexpected, record it in `Log.md` before editing and
pause if unrelated modifications are present.

## Read Context

Read the files listed in `Goal.md`, especially:

```text
docs/teaching/woodhen/classroom-dry-run-checklist.md
docs/teaching/woodhen/practical-1-pva-foundations.md
docs/teaching/woodhen/expected-outputs.md
docs/teaching/woodhen/instructor-guide.md
docs/teaching/woodhen/troubleshooting.md
docs/teaching/shiny/README.md
docs/teaching/shiny/practical-1-design-brief.md
inst/shiny/practical1/README.md
inst/shiny/practical1/app.R
docs/goals/023-practical-1-evidence-export-road-test-hardening/Log.md
```

## Local Baseline Commands

Run:

```sh
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
```

Render the report scaffold to temporary output:

```sh
rm -rf /tmp/rpva-goal024-report
mkdir -p /tmp/rpva-goal024-report
quarto render docs/teaching/woodhen/report-scaffold.qmd --to docx --output-dir /tmp/rpva-goal024-report
quarto render docs/teaching/woodhen/report-scaffold.qmd --to pdf --output-dir /tmp/rpva-goal024-report
```

If PDF fails but DOCX succeeds, record the PDF error and continue unless the
failure reveals a repo bug rather than local tooling.

## Shiny Launch

Choose an unused local port, for example `3895`.

Suggested launch command:

```sh
Rscript -e 'source("bootstrap.R"); rPVA::run_practical1_shiny(host = "127.0.0.1", port = 3895)'
```

Before and after app use:

```sh
git status --short --branch
lsof -nP -iTCP:3895 -sTCP:LISTEN || true
```

Stop the Shiny process at the end and confirm the port has no listener.

## Browser Dress Rehearsal

Preferred path:

- use the Chrome plugin to drive `http://127.0.0.1:<port>/`.

Fallback paths:

- if Chrome plugin control is unavailable, record the exact blocker and use
  in-app Browser or Playwright/Chromium;
- if browser automation cannot prove a visible local GUI behaviour, use
  Computer Use only for local app UI checks.

Exercise:

1. Load the app from a fresh browser context.
2. Start the baseline.
3. Run at least three Concept Lab stages, including one carrying-capacity run
   and one stochastic or genetics/catastrophe run if implemented.
4. Try one rerun or backtracking action.
5. Open Compare.
6. Confirm at least three comparison rows.
7. Confirm the table is readable or horizontally scrollable.
8. Download comparison CSV and evidence-notes Markdown.
9. Inspect downloads for stage labels, run settings, seed/provenance wording,
   and the phrase `evidence, not an answer`.
10. Open Transfer and check that the student prompt still makes sense.
11. Save screenshot evidence under `/tmp`.

## Fallback Pack

Create or update a lightweight fallback surface, such as:

```text
docs/teaching/woodhen/practical-1-fallback-pack.md
```

It should include:

- when to use the fallback;
- what the demonstrator should show or hand out;
- where expected output tables live;
- what static screenshots or `/tmp` screenshot paths were generated during the
  dry run;
- how students can use comparison CSV and evidence notes if Shiny is available;
- how to continue with command-line Practical 1 material if Shiny is not
  available.

Avoid committing large binary artefacts unless they are deliberately small and
useful.

## Final Validation

Run:

```sh
git status --short --branch
git diff --check
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
```

If implementation code changed, run:

```sh
Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter = "summary")'
```

Marker scan:

```sh
git diff --name-only --diff-filter=ACMRTUXB | \
  xargs rg -n "$(printf '%s|%s|%s' 'TO''DO' 'T''BD' 'PLACE''HOLDER')" || true
```

Run a secret-pattern scan over changed/new tracked text. Review all hits
manually; policy wording can be a false positive, plausible credentials cannot.

## Final Report

Create `docs/goals/024-practical-1-classroom-dry-run-fallback/dry-run-report.md`
and update `Log.md`.

Include:

- browser method used and any fallback;
- local port and app cleanup result;
- dry-run path completed;
- download artefact paths and content checks;
- report render outcomes;
- repo-write check result;
- docs or UI changes made;
- changed files;
- validation outcomes;
- residual risks;
- recommendation for the next goal.
