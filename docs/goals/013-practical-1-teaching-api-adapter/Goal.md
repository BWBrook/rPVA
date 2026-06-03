# Goal 013: Practical 1 Teaching API Adapter

## Objective

Implement a small, tested, package-level teaching API adapter for Practical 1.
This adapter should turn safe teaching-stage controls into validated rPVA specs
and labelled result bundles that a future Shiny app can call.

This is not a Shiny implementation goal and not a deployment goal.

## Context

Goal 011 identified that the Practical 1 Shiny concept lab needs a thin
teaching-facing API before UI implementation. Goal 012 established that
`deep-server` with ShinyProxy is now the likely hosting path, but the app code
still needs a stable package interface independent of the hosting platform.

The adapter should preserve the existing simulator as the scientific core. Do
not refactor `run_pva_core()` or the model engine. Build a narrow layer around
the existing toy scenario and reporting helpers.

## Required Sources

Read and use:

- `docs/teaching/shiny/engine-affordance-audit.md`
- `docs/teaching/shiny/implementation-roadmap.md`
- `docs/teaching/shiny/practical-1-design-brief.md`
- `R/run_toy_demo.R`
- `R/pva_helpers.R`
- `R/set_scenario.R`
- `R/run_pva_core.R`
- `inst/extdata/toy/toy_demo.yaml`
- `tests/testthat/test-11_pva_helpers.R`

You may read additional package files as needed.

## Required Implementation

Create a teaching adapter with this minimum public surface:

1. `teaching_stage_catalog()`
   - returns a data frame describing supported Practical 1 stages
   - include stable stage IDs, display labels, short concepts, and whether the
     stage is implemented by the current engine
   - include enough metadata for a future Shiny app to render the linear
     concept path

2. `build_teaching_spec(stage, controls = list(), base = "toy")`
   - starts from the toy base scenario by default
   - accepts only known stage IDs from the catalog
   - applies bounded, stage-appropriate controls
   - validates the resulting spec with existing package validation
   - returns a `pva_spec`
   - does not expose YAML editing or arbitrary `modifyList()` behaviour to the
     caller

3. `run_teaching_pva(stage, controls = list(), keep_traj = TRUE, seed = 42, verbose = FALSE)`
   - builds the teaching spec
   - calls `run_pva_core()`
   - returns a list bundle with at least:
     - `stage`
     - `label`
     - `spec`
     - `result`
     - `summary`
     - `diagnostics`
     - `settings`
   - uses existing `summarize_pva_result()` and `diagnose_pva_result()`
   - avoids console progress output by default

4. `compare_teaching_runs(runs)`
   - accepts a non-empty list of bundles returned by `run_teaching_pva()`
   - preserves stage order and labels
   - returns a compact list or data frame suitable for Shiny/report use
   - should use `compare_pva_results()` where appropriate

5. `teaching_settings_record(stage, controls, spec)`
   - returns a compact data frame or list of settings suitable for export later
   - does not write files

Use names that match the required public surface unless you find a strong
package-pattern reason to adjust them. If you adjust a name, explain why in
`Log.md`.

## Supported Stage Scope

The first adapter should support the minimum viable Practical 1 stages:

- deterministic baseline
- ceiling carrying capacity
- demographic stochasticity
- environmental stochasticity
- genetic stochasticity
- catastrophe
- simple intervention/release or carrying-capacity improvement
- combined extinction-vortex comparison if it can be represented as a
  controlled stage without broad engine changes

If Allee effects or correlated bad years cannot be represented honestly without
new engine work, include them in the catalog as not-yet-implemented or
explain their omission in `Log.md`. Do not fake a formal engine feature.

## Boundaries

Allowed changes:

- add one focused R file for the teaching adapter, such as
  `R/teaching_api.R`
- add focused tests, such as `tests/testthat/test-12_teaching_api.R`
- update `NAMESPACE` for new exports if roxygen tooling is not run
- update `docs/teaching/shiny/engine-affordance-audit.md` or
  `docs/teaching/shiny/implementation-roadmap.md` only if needed to reflect
  the now-implemented adapter
- update `docs/goals/013-practical-1-teaching-api-adapter/Log.md`

Do not:

- implement Shiny UI
- add Shiny dependencies
- edit deployment/deep-server service files
- edit scenario YAML files
- refactor the PVA engine broadly
- edit Goal 010 assessment drafts
- create export files or write to student workspaces
- commit or push

## Validation

Before reporting back:

- run the focused teaching API tests
- run the full package tests:
  `Rscript -e 'source("bootstrap.R"); testthat::test_local()'`
- run `git diff --check`
- run `rg -n "TODO|TBD|PLACEHOLDER" R tests docs/teaching/shiny docs/goals/013-practical-1-teaching-api-adapter`
  and either remove placeholders or explain intentional hits in the log
- run `git status --short --branch --untracked-files=all`
- confirm no Shiny implementation, dependency, scenario YAML, deployment,
  service, Goal 010 assessment, commit, or push occurred

## Report Back

Report:

- files changed
- implemented public API
- supported stages and any explicit omissions
- validation results
- current git status
- residual risks or follow-up recommendations
- confirmation that no Shiny/deployment work, commit, or push occurred
