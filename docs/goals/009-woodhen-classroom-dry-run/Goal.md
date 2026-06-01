# Goal: Woodhen Classroom Dry-Run Audit

## Objective

Walk the Woodhen teaching kit as a classroom road-test path and make the
lowest-risk fixes needed for a third-year undergraduate practical: Practical 1,
Practical 2, and the report scaffold should have runnable code, current
reference outputs, clear timing, and explicit student/demonstrator checkpoints.

## Why This Matters

The project now has a tested engine, a visible teaching kit, public diagnostic
helpers, and a renderable report scaffold. The next risk is pedagogical and
operational: a class can still fail if the instructions ask too much, examples
drift from current outputs, or demonstrators do not know where students are
likely to stumble.

This goal should convert the current teaching materials into a more reliable
two-practical road-test path without changing the science, engine, scenario
values, or user interface direction.

## Operating Mode

Classroom dry-run audit and teaching-document polish.

## Current Unlocked Envelope

Allowed:

- edit teaching documents under `docs/teaching/woodhen/`
- add one concise classroom dry-run or delivery checklist under
  `docs/teaching/woodhen/` if useful
- update this goal's `Log.md`
- create one short audit note under `docs/codex/` if useful
- run local R/Quarto commands needed to verify worksheet code, plots, tables,
  and report rendering
- update expected-output values only if current validated commands prove they
  are stale

Not allowed:

- change package engine code under `R/`
- change `NAMESPACE`, tests, `DESCRIPTION`, `renv.lock`, CI, package version,
  or release metadata
- change YAML scenarios under `inst/extdata/`
- change scientific assumptions, model defaults, Woodhen scenario values, or
  interpretation framing that needs Barry's judgement
- implement or prototype Shiny
- commit, push, open PRs, merge, or delete branches
- launch remote/HPC jobs or long simulation campaigns

## Review Surface

Primary files:

- `docs/teaching/woodhen/practical-1-pva-foundations.md`
- `docs/teaching/woodhen/practical-2-woodhen-management.md`
- `docs/teaching/woodhen/instructor-guide.md`
- `docs/teaching/woodhen/expected-outputs.md`
- `docs/teaching/woodhen/report-scaffold.qmd`
- `docs/teaching/woodhen/troubleshooting.md`
- optional new `docs/teaching/woodhen/classroom-dry-run-checklist.md`
- `docs/goals/009-woodhen-classroom-dry-run/Log.md`

Secondary review surface:

- optional `docs/codex/woodhen-classroom-dry-run-2026-06-01.md`
- final git state and temp render output hygiene

## Scope

In scope:

- read the full Woodhen teaching kit as a student-facing sequence
- run the Practical 1 toy-model commands and plotting calls in a headless-safe
  way
- run the Practical 2 Woodhen scenario, diagnostic-helper, plotting, and
  sensitivity commands
- render the report scaffold to DOCX and PDF into temp directories
- compare current outputs against `expected-outputs.md` and update only proven
  stale values
- identify places where students could lose the thread between PVA concept,
  code command, output interpretation, and report writing
- make small text edits that improve sequence, timing, setup clarity,
  demonstrator cues, and assessment readiness
- produce a concise dry-run checklist or audit note that Barry/demonstrators
  can use before class
- record exact commands, results, changes, residual risks, and final status in
  `Log.md`

Out of scope:

- adding new helper APIs or wrappers
- changing any model result to make teaching easier
- adding dependencies
- turning the teaching kit into a Shiny workflow
- wholesale rewriting or expanding the teaching kit beyond classroom-readiness
  polish

## Read First

- `docs/teaching/woodhen/README.md`
- `docs/teaching/woodhen/practical-1-pva-foundations.md`
- `docs/teaching/woodhen/practical-2-woodhen-management.md`
- `docs/teaching/woodhen/instructor-guide.md`
- `docs/teaching/woodhen/expected-outputs.md`
- `docs/teaching/woodhen/report-scaffold.qmd`
- `docs/teaching/woodhen/troubleshooting.md`
- `docs/goals/008-teaching-render-readiness/Log.md`

## Starting State Checks

Run these first and record results in `Log.md`:

```sh
git status --short --branch --ignored=matching
git log --oneline --decorate --max-count=8
Rscript -e 'source("bootstrap.R"); print(renv::status(sources = FALSE))'
```

Expected state:

- `main` is synced with `origin/main`
- current head is `f5c569e Publish Goal 008 teaching render readiness`
- no action-repo changes are present except the new untracked Goal 009 packet
  and ignored `renv/staging/`

If any tracked package source, metadata, scenario, dependency, or teaching file
is dirty before implementation, stop and report the mismatch.

## Required Work

1. Confirm the clean post-Goal-008 starting state.
2. Read the teaching kit in delivery order and note likely student friction.
3. Run a Practical 1 dry-run command set:
   - bootstrap
   - `run_toy_demo()` with and without trajectories
   - representative summary/extinction/trajectory plotting calls under a temp
     graphics device
4. Run a Practical 2 dry-run command set:
   - `run_scenarios("woodhen", ...)`
   - one scenario with `summarize_pva_result()` and `diagnose_pva_result()`
   - a headless-safe `plot_pva_panel(...)`
   - the bounded sensitivity block with `compare_pva_results()`
5. Render the report scaffold to DOCX and PDF into temp directories.
6. Compare validated outputs against `expected-outputs.md`.
7. Make only low-risk teaching-doc edits needed for classroom usability.
8. Add a concise dry-run/delivery checklist if it will help Barry or
   demonstrators.
9. Run final validation and changed-file hygiene checks.
10. Update `Log.md` and report exactly what changed.

## Validation Gates

The goal is complete when:

- Practical 1 code path has been run or faithfully smoke-tested and results
  recorded
- Practical 2 code path has been run or faithfully smoke-tested and results
  recorded
- report scaffold renders to DOCX and PDF into temp output directories
- any expected-output changes are backed by validated command output
- no package engine, scenario, metadata, dependency, test, CI, or Shiny files
  changed
- `Rscript -e 'source("bootstrap.R"); testthat::test_local()'` passes
- `git diff --check` passes
- no rendered DOCX/PDF/HTML/knit artefacts or local Quarto helper `.gitignore`
  remain unintentionally in `docs/teaching/woodhen/`

Suggested validation commands:

```sh
Rscript -e 'source("bootstrap.R"); toy <- run_toy_demo(keep_traj = TRUE, plot_matrix = FALSE, verbose = FALSE); print(toy$summary); pdf(tempfile(fileext = ".pdf")); plot_pva_summary(toy$results$genetics); plot_ext(toy$results$genetics); dev.off()'
Rscript -e 'source("bootstrap.R"); tbl <- run_scenarios("woodhen", csv_out = NULL, rds_out = NULL, keep_traj = FALSE, parallel = FALSE); print(tbl)'
Rscript -e 'source("bootstrap.R"); spec <- set_scenario("02_pig_control", "woodhen"); sim <- run_pva_core(spec, keep_traj = TRUE, seed = 123, verbose = FALSE); print(summarize_pva_result(sim)); print(diagnose_pva_result(sim)); pdf(tempfile(fileext = ".pdf")); print(plot_pva_panel(plot_pva_traj(sim, sample = 50), plot_pva_summary(sim), plot_ext(sim))); dev.off()'
Rscript -e 'source("bootstrap.R"); base <- set_scenario("sensitivity_analysis", "woodhen"); s1 <- run_pva_core(base, keep_traj = FALSE, seed = 123); s2 <- run_pva_core(modifyList(base, list(surv = base$surv * 0.90)), keep_traj = FALSE, seed = 123); s3 <- run_pva_core(modifyList(base, list(K = 250)), keep_traj = FALSE, seed = 123); s4 <- run_pva_core(modifyList(base, list(cat_freq = 0.10)), keep_traj = FALSE, seed = 123); print(compare_pva_results(list(s1, s2, s3, s4), scenarios = c("baseline", "survival_minus_10pct", "K_250", "cat_freq_0.10")))'
rm -rf /tmp/rpva-goal009-render
mkdir -p /tmp/rpva-goal009-render/docx /tmp/rpva-goal009-render/pdf
quarto render docs/teaching/woodhen/report-scaffold.qmd --to docx --output-dir /tmp/rpva-goal009-render/docx
quarto render docs/teaching/woodhen/report-scaffold.qmd --to pdf --output-dir /tmp/rpva-goal009-render/pdf
Rscript -e 'source("bootstrap.R"); testthat::test_local()'
git diff --check
git status --short --branch --ignored=matching
```

Adapt commands if needed, but keep the evidence comparable.

## Deliverables

- updated teaching documents under `docs/teaching/woodhen/` if dry-run
  evidence justifies edits
- optional `docs/teaching/woodhen/classroom-dry-run-checklist.md`
- updated `docs/goals/009-woodhen-classroom-dry-run/Log.md`
- final report with validation evidence, changed files, residual risks, final
  git state, and whether formal goal mode was active

## Decision Authority

You may decide:

- which small wording/order/timing fixes improve classroom usability
- whether a dry-run checklist should be a new file or folded into the
  instructor guide
- whether an expected-output value is demonstrably stale from current validated
  code

You must pause before:

- changing package code, scenarios, dependencies, tests, CI, or metadata
- changing the scientific story or management recommendation beyond wording
  polish
- making major rewrites of the teaching kit
- committing, pushing, opening PRs, or implementing Shiny

## Stop Conditions

Stop when one of these is true:

- the dry-run is complete and low-risk teaching fixes are made
- a code path fails in a way that requires engine/scenario/dependency changes
- the teaching material needs Barry's scientific or assessment judgement before
  it can be made honest
- unexpected dirty state appears outside the allowed surface
