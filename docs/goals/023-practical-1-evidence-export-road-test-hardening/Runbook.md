# Runbook

## Contract

Read `Goal.md` first. This runbook gives an execution order, not permission to
broaden scope.

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
codex/rpva-goal023-evidence-export-hardening
```

If branch or status is unexpected, record it in `Log.md` before editing. Pause
if there are unrelated modifications.

## Read Context

Read the files listed in `Goal.md`, especially:

```text
inst/shiny/practical1/app.R
inst/shiny/practical1/README.md
R/shiny_practical1.R
R/teaching_api.R
tests/testthat/test-13_practical1_shiny.R
docs/teaching/shiny/practical-1-design-brief.md
docs/teaching/shiny/student-workspace-and-export-design.md
docs/teaching/woodhen/classroom-dry-run-checklist.md
docs/goals/022-local-remote-staging-validation/Log.md
```

## Implementation Notes

- Keep export content compact.
- Prefer existing dependencies and base R.
- Use temporary files only for download generation.
- Do not write into the repository during ordinary app construction or use.
- Do not expose raw trajectory arrays by default.
- Make labels understandable to students and demonstrators.
- If a single archive bundle is brittle, use separate downloads with clear
  labels.

Good export contents include:

- comparison table;
- stage labels and settings/controls;
- seed or reproducibility note;
- short README or interpretation prompt;
- optional small selected plot only if robust.

## Validation

Run from repo root:

```sh
git status --short --branch
git diff --check
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R")'
Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter = "summary")'
```

Run a marker scan over changed/new tracked text:

```sh
git diff --name-only --diff-filter=ACMRTUXB | \
  xargs rg -n "$(printf '%s|%s|%s' 'TO''DO' 'T''BD' 'PLACE''HOLDER')" || true
```

Run a secret-pattern scan over changed/new tracked text. Review all hits
manually; policy wording can be false positive, plausible credentials cannot.

## Browser Smoke

Launch locally on `127.0.0.1` using `run_practical1_shiny()`.

Exercise:

1. Start baseline.
2. Run at least one non-baseline stage.
3. Open Compare.
4. Trigger the export/download path.
5. Inspect downloaded artefact(s) for expected comparison/settings markers.
6. Stop the app.
7. Confirm the port has no listener.

Use the in-app Browser if available. If unavailable, use Playwright/Chromium or
another local browser automation fallback and record the fallback in `Log.md`.

## Final Report

Include:

- changed files;
- export shape;
- validation outcomes;
- browser evidence;
- final branch/status;
- residual risks;
- recommendation for the next goal.
