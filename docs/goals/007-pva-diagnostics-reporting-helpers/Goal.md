# Goal: PVA Diagnostics And Reporting Helpers

## Objective

Add a small public helper layer that turns `run_pva_core()` outputs into
student/report-friendly summary tables and interpretation diagnostics. The goal
is to make Woodhen practical reports less dependent on students spelunking
through internal result-list fields, while keeping the simulation engine and
scenario science unchanged.

## Why This Matters

The Woodhen teaching kit now exists and is visible to git, but the worksheets
and report scaffold still repeat ad hoc summary code. Students need a stable,
named way to ask:

- what is the final extinction probability?
- what are the median and 95 percent final abundance interval?
- are trajectories available for plotting?
- what interpretation warnings should I mention in the report?

This is also a useful foundation for future RShiny work: a UI should call
stable helper functions rather than reimplementing result-list parsing.

This goal is deliberately more challenging than Goals 005 and 006. It is a real
package-code/API task with tests and documentation, but it remains bounded and
must not change engine behaviour or Woodhen scenario values.

## Operating Mode

Public helper/API implementation, tests, and teaching-doc integration.

## Model/Effort Policy

Recommended action-agent settings:

- `model = "gpt-5.5"`
- `thinking = "high"`

Rationale: this goal needs public API judgement, R package testing, and careful
teaching-facing semantics. It is more demanding than a Spark/xhigh executor
cleanup, but the supervisor has already scoped the design, so `gpt-5.5` with
high reasoning should be the initial sweet spot.

## Current Unlocked Envelope

Allowed:

- create one focused R helper file under `R/`
- update `NAMESPACE`
- add focused `testthat` coverage
- update teaching documents under `docs/teaching/woodhen/` to demonstrate the
  new helpers
- update this goal's `Log.md`
- run local R/test validation commands
- create a short `docs/codex/` implementation note if useful

Not allowed:

- change stochastic engine behaviour in `run_pva_core()` or helpers it depends
  on
- change Woodhen or toy scenario YAML values
- add package dependencies
- change CI, `renv.lock`, `DESCRIPTION`, package version, or metadata
- implement Shiny or any other UI
- commit, push, open PRs, merge, or delete branches
- launch remote/HPC jobs or long simulation campaigns

## Review Surface

Primary code surface:

- new helper file under `R/`
- `NAMESPACE`
- new focused tests under `tests/testthat/`

Teaching surface:

- `docs/teaching/woodhen/practical-2-woodhen-management.md`
- `docs/teaching/woodhen/report-scaffold.qmd`
- optionally `docs/teaching/woodhen/README.md` or `expected-outputs.md` if
  needed to show the helper workflow honestly

Goal surface:

- `docs/goals/007-pva-diagnostics-reporting-helpers/Log.md`

## Required Public Helpers

Implement these public functions unless inspection shows a better local naming
pattern. If names change, explain why in `Log.md`.

### `summarize_pva_result()`

Purpose: summarize one `run_pva_core()` result into a one-row data frame.

Required behaviour:

- accepts `out`, `scenario = NULL`, and `horizon = NULL`
- infers `scenario` from `out$params$name` when available
- infers final horizon from `out$params$years` when available
- reports:
  - `scenario`
  - `years`
  - `reps`
  - `PE`
  - `Nmed`
  - `Nlo95`
  - `Nhi95`
  - `extinct_reps`
  - `surviving_reps`
  - `trajectory_available`
- uses `out$ext_prob[horizon + 1]` for horizon-specific extinction probability
  when trajectory extinction probabilities are available
- falls back to `mean(out$Nend == 0)` for final-horizon extinction probability
  when `out$ext_prob` is unavailable
- if `horizon` is not final and `out$ext_prob` is unavailable, errors with a
  clear message explaining that horizon-specific PE requires `keep_traj = TRUE`
- does not require any new package dependencies

### `compare_pva_results()`

Purpose: summarize a named list of result objects into a scenario-comparison
table.

Required behaviour:

- accepts `results`, `scenarios = names(results)`, and `horizon = NULL`
- validates that `results` is a non-empty list
- uses `summarize_pva_result()` for each element
- preserves input order
- provides useful scenario labels even when the list is unnamed

### `diagnose_pva_result()`

Purpose: return compact interpretation diagnostics for one result.

Required behaviour:

- accepts at least:
  - `out`
  - `scenario = NULL`
  - `horizon = NULL`
  - `high_pe = 0.05`
  - `low_nmed = 50`
  - `wide_interval_ratio = 4`
- returns a data frame with:
  - `scenario`
  - `code`
  - `severity`
  - `message`
- includes deterministic, testable diagnostic codes for:
  - high extinction probability
  - low median final abundance
  - wide final abundance interval
  - no trajectory data available
  - zero observed extinctions
- uses concise student-facing messages suitable for report interpretation
- does not overstate ecological truth; diagnostics should be report prompts,
  not management decisions

## Teaching Integration

Update the Woodhen practical/report material so students see the new helper
workflow. Keep edits modest:

- Practical 2 should show `summarize_pva_result()`,
  `compare_pva_results()`, and `diagnose_pva_result()` in the reporting or
  interpretation section.
- `report-scaffold.qmd` should use the new helpers instead of defining a local
  duplicated `summarise()` function.
- Do not rewrite the whole teaching kit.

## Starting State Checks

Run first and record results in `Log.md`:

```sh
git status --short --branch --ignored=matching
git diff --check
renv::status(sources = FALSE)
```

Use this exact R command form for the renv check:

```sh
Rscript -e 'source("bootstrap.R"); print(renv::status(sources = FALSE))'
```

Expected state:

- branch is `main...origin/main`
- existing untracked management/teaching artefacts from Goals 004-007 may be
  present
- `.gitignore` is modified from Goal 006
- no tracked package source files should be dirty before Goal 007 starts

If tracked package source files are already dirty, stop and report.

## Required Work

1. Confirm the current repo state and read the relevant existing API/tests.
2. Design the helper implementation to be small, dependency-free, and stable.
3. Write focused tests before or alongside implementation.
4. Implement the three public helpers.
5. Export the helpers through `NAMESPACE`.
6. Update teaching docs/report scaffold modestly to use the helpers.
7. Run validation gates and record exact commands/results.
8. Recheck changed-file scope and final git state.

## Validation Gates

The goal is complete when:

- tests cover each public helper
- summary helpers work for both `keep_traj = TRUE` and `keep_traj = FALSE`
  outputs
- horizon-specific PE errors clearly when trajectories are unavailable
- diagnostics return deterministic codes/messages
- teaching docs reference the new helper workflow
- `git diff --check` passes
- focused tests pass
- no out-of-scope files changed

Suggested validation commands:

```sh
git diff --check
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-11_pva_helpers.R")'
Rscript -e 'source("bootstrap.R"); spec <- set_scenario("02_pig_control", "woodhen"); out <- run_pva_core(spec, keep_traj = TRUE, seed = 123, verbose = FALSE); print(summarize_pva_result(out)); print(diagnose_pva_result(out))'
```

If the new test filename differs, adjust the command and explain why.

## Deliverables

- new helper implementation under `R/`
- updated `NAMESPACE`
- new focused test file under `tests/testthat/`
- modest teaching-doc updates under `docs/teaching/woodhen/`
- updated `docs/goals/007-pva-diagnostics-reporting-helpers/Log.md`
- final response with changed files, validation results, residual risks, and
  model/goal-mode observations

## Decision Authority

You may decide:

- the exact helper file name
- minor helper-name adjustments if existing repo style demands it
- exact diagnostic message wording, provided diagnostic codes remain stable
- exact teaching snippets that best demonstrate the helpers

You must pause before:

- changing engine semantics
- changing scenario YAML values
- adding dependencies
- changing package metadata, `DESCRIPTION`, `renv.lock`, or CI
- broad rewriting of the teaching kit
- implementing Shiny
- committing or pushing

## Stop Conditions

Stop when one of these is true:

- the helper API, tests, teaching snippets, and validation are complete
- tracked package source files are unexpectedly dirty before starting
- implementing the goal would require dependency or engine-behaviour changes
- a scientific judgement from Barry is required to keep diagnostics honest
