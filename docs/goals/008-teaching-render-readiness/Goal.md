# Goal: Teaching Report Render Readiness

## Objective

Make the Woodhen teaching report scaffold and setup guidance classroom-ready:
the scaffold should render cleanly from a normal repo-root workflow, required
render dependencies should be declared and locked, and the teaching docs should
tell students and demonstrators how to diagnose the common setup failures.

## Why This Matters

The next road test is a third-year undergraduate class in about two months.
Goals 005-007 created and exposed the Woodhen teaching kit and added
student/report-facing diagnostics, but the report scaffold has not yet been
render-tested because the active `renv` environment does not include the
top-level report-render packages. Students need the final report path to work
predictably before the practicals can become a true zero-to-hero teaching
sequence.

This goal should turn the scaffold from plausible text into a validated
teaching-room artefact without broadening into Shiny, scientific model changes,
or a major teaching rewrite.

## Operating Mode

Dependency and render-readiness cleanup for the teaching kit.

## Current Unlocked Envelope

Allowed:

- update `DESCRIPTION` only for narrowly required report-render dependencies
  in `Suggests`
- update `renv.lock` only to synchronize those dependencies and their
  transitive requirements
- edit `docs/teaching/woodhen/report-scaffold.qmd` to make it render reliably
  from a normal repo-root or documented Quarto workflow
- edit `docs/teaching/woodhen/README.md`, `troubleshooting.md`,
  `instructor-guide.md`, or add one small setup/checklist file under
  `docs/teaching/woodhen/` if that improves classroom readiness
- edit `.gitignore` only if a narrow generated-report artefact rule is needed
  after inspection
- update this goal's `Log.md`
- create a short `docs/codex/` note if useful
- run local validation commands, including Quarto renders and package tests

Not allowed:

- change package engine behaviour under `R/`
- change YAML scenarios under `inst/extdata/`
- change tests, CI, package version, licensing, or release metadata
- change scientific assumptions, model defaults, Woodhen scenario values, or
  expected classroom interpretation
- broadly rewrite the teaching kit
- implement or prototype Shiny
- commit, push, open PRs, merge, or delete branches
- launch remote/HPC jobs or long simulation campaigns

## Review Surface

Primary files:

- `DESCRIPTION`
- `renv.lock`
- `docs/teaching/woodhen/report-scaffold.qmd`
- targeted teaching setup/troubleshooting docs under `docs/teaching/woodhen/`
- `docs/goals/008-teaching-render-readiness/Log.md`

Secondary review surface:

- `.gitignore` if touched
- optional `docs/codex/` note
- final git state and render artefact cleanup

## Scope

In scope:

- confirm whether `knitr`, `rmarkdown`, and any other required render packages
  are missing from the active `renv` lock/library
- add the minimal top-level render dependencies needed for the scaffold
- make the scaffold robust to Quarto's execution directory rules without using
  Barry-specific absolute paths
- render the scaffold to DOCX and PDF where local system tools allow it
- avoid committing rendered binary outputs; render to a temp directory or clean
  outputs afterward
- document the student/demonstrator setup path, including how to run
  `source("bootstrap.R")`, how to render the report, and what common failures
  mean
- run package-level regression checks after dependency changes
- update this goal log with starting state, commands, changes, validation
  evidence, residual risks, and final git state

Out of scope:

- converting the whole teaching kit to Quarto
- making a polished final example report
- adding new PVA helper APIs
- changing plots or scenario outputs for aesthetics
- designing the future Shiny interface

## Read First

- `DESCRIPTION`
- `renv.lock`
- `bootstrap.R`
- `docs/teaching/woodhen/README.md`
- `docs/teaching/woodhen/report-scaffold.qmd`
- `docs/teaching/woodhen/troubleshooting.md`
- `docs/goals/006-woodhen-teaching-kit-publication-cleanup/Log.md`
- `docs/goals/007-pva-diagnostics-reporting-helpers/Log.md`

## Starting State Checks

Run these first and record results in `Log.md`:

```sh
git status --short --branch --ignored=matching
git log --oneline --decorate --max-count=8
jq '.Packages.knitr, .Packages.rmarkdown, .Packages.quarto' renv.lock
quarto --version
Rscript -e 'source("bootstrap.R"); print(renv::status(sources = FALSE))'
```

Expected state:

- branch is `main...origin/main`
- only ignored `renv/staging/` noise is present before this goal starts
- current head includes `4649ac9 Publish Goals 004-007 teaching and diagnostics work`
- `knitr`, `rmarkdown`, and `quarto` are not top-level locked packages before
  this goal

If tracked package source or teaching files are dirty before you start, stop
and report the mismatch.

## Required Work

1. Confirm starting state and read the relevant teaching/render docs.
2. Attempt or inspect a baseline scaffold render enough to identify the real
   blocker. Record the blocker in `Log.md`.
3. Add the minimal render dependencies to `DESCRIPTION` and `renv.lock`.
   Usually this should mean `knitr` and `rmarkdown`; do not add the R package
   `quarto` unless inspection shows it is actually required.
4. Make `report-scaffold.qmd` render from a normal documented workflow. Prefer
   a portable repo-root discovery or Quarto/knitr root-dir solution over
   Barry-specific absolute paths.
5. Add or update concise setup/troubleshooting guidance for students and
   demonstrators.
6. Render the scaffold to DOCX and PDF into a temp directory, or remove any
   generated outputs after validation.
7. Run regression checks and changed-file hygiene checks.
8. Record exact commands/results, final git state, and residual risks in
   `Log.md`.

## Validation Gates

The goal is complete when:

- `DESCRIPTION` declares the minimal report-render dependencies if they are
  required
- `renv.lock` is synchronized with those dependency declarations
- `Rscript -e 'source("bootstrap.R"); print(renv::status(sources = FALSE))'`
  reports a synchronized project
- the report scaffold renders to DOCX locally
- the report scaffold renders to PDF locally, or a system-tool-only PDF blocker
  is recorded with exact error text while DOCX still passes
- no rendered DOCX/PDF/HTML artefacts are left unintentionally in the worktree
- `Rscript -e 'source("bootstrap.R"); testthat::test_local()'` passes
- `git diff --check` passes
- only allowed files changed

Suggested render commands:

```sh
rm -rf /tmp/rpva-goal008-render
mkdir -p /tmp/rpva-goal008-render/docx /tmp/rpva-goal008-render/pdf
quarto render docs/teaching/woodhen/report-scaffold.qmd --to docx --output-dir /tmp/rpva-goal008-render/docx
quarto render docs/teaching/woodhen/report-scaffold.qmd --to pdf --output-dir /tmp/rpva-goal008-render/pdf
find /tmp/rpva-goal008-render -maxdepth 3 -type f | sort
```

If `--output-dir` is inappropriate after inspection, use the nearest clean
equivalent and remove generated worktree artefacts before final status.

## Deliverables

- updated render dependency declarations if needed
- renderable `docs/teaching/woodhen/report-scaffold.qmd`
- updated teaching setup/troubleshooting guidance
- updated `docs/goals/008-teaching-render-readiness/Log.md`
- final response with validation results, final git state, residual risks, and
  whether formal goal mode was active

## Decision Authority

You may decide:

- whether `knitr` and `rmarkdown` are sufficient, or whether another narrowly
  justified render dependency is required
- the portable scaffold path/root-dir implementation
- the exact shape of concise teaching setup/troubleshooting guidance
- whether to render into temp directories or clean generated outputs afterward

You must pause before:

- changing engine code, scenarios, tests, CI, package version, or science
- adding broad documentation frameworks or converting the whole teaching kit
- implementing Shiny
- committing or pushing

## Stop Conditions

Stop when one of these is true:

- DOCX and PDF render gates pass and logs/docs are updated
- PDF fails only because of an external system-tool issue, DOCX passes, and the
  blocker is recorded precisely
- dependency restoration fails in a way that requires supervisor decision
- a scientific judgement from Barry is required before the scaffold can be
  made honest
