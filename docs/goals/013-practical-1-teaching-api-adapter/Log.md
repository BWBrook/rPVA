# Log

## 2026-06-02 - Supervisor Goal Publication

- Supervisor created Goal 013 after Barry confirmed the `deep-server` gateway
  is open on `443` and Posit Connect is not expected to be available for the
  class platform.
- Strategic decision: move the software lane forward independently of
  ShinyProxy installation by implementing the Practical 1 teaching-facing API
  adapter first.
- Goal 013 is a package helper implementation goal. It must not implement
  Shiny UI, touch deployment services, edit scenario YAML, or commit/push.

## 2026-06-02 - Execution Start

- Formal goal mode appeared active for this action-thread run.
- Started from `/Users/bwbrook/git/rPVA` on `main`.
- Read the Goal 013 packet:
  - `Goal.md`
  - `Plan.md`
  - `Runbook.md`
  - `Log.md`
- Starting `git status --short --branch --untracked-files=all` showed:
  - `## main...origin/main`
  - pre-existing tracked edits in:
    - `docs/teaching/woodhen/README.md`
    - `docs/teaching/woodhen/instructor-guide.md`
  - pre-existing untracked Goal 010, Goal 011, Goal 012, legacy intake,
    assessment draft, and Shiny design/feasibility files.
  - untracked Goal 013 packet files.
- Boundary confirmed: add the teaching API adapter and focused tests, update
  exports if needed, and update this Goal 013 `Log.md`; no Shiny UI,
  deployment/service changes, scenario YAML edits, Goal 010 assessment edits,
  export/workspace files, commit, or push.

## 2026-06-02 - Implementation And Focused Tests

- Read required design and code sources:
  - `docs/teaching/shiny/engine-affordance-audit.md`
  - `docs/teaching/shiny/implementation-roadmap.md`
  - `docs/teaching/shiny/practical-1-design-brief.md`
  - `R/run_toy_demo.R`
  - `R/pva_helpers.R`
  - `R/set_scenario.R`
  - `R/run_pva_core.R`
  - `inst/extdata/toy/toy_demo.yaml`
  - `tests/testthat/test-11_pva_helpers.R`
- Added focused tests first in `tests/testthat/test-12_teaching_api.R`.
- Initial focused test run failed as expected because the new public API did
  not yet exist.
- Implemented the bounded teaching adapter in `R/teaching_api.R`.
- Updated `NAMESPACE` with exports for:
  - `teaching_stage_catalog()`
  - `build_teaching_spec()`
  - `run_teaching_pva()`
  - `compare_teaching_runs()`
  - `teaching_settings_record()`
- Supported implemented stages:
  - `deterministic_baseline`
  - `carrying_capacity`
  - `demographic_stochasticity`
  - `environmental_stochasticity`
  - `genetic_stochasticity`
  - `catastrophe`
  - `intervention`
  - `extinction_vortex`
- Explicitly catalogued but did not implement:
  - `allee_effect`
  - `correlated_events`
  because the current engine does not expose named formal features for them.
- Ran focused tests:
  - `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R")'`
  - result: passed, `64` assertions.

## 2026-06-02 - Validation

- Ran full package tests:
  - `Rscript -e 'source("bootstrap.R"); testthat::test_local()'`
  - result: passed, `174` assertions, `0` failures, `0` warnings, `0` skips.
- Ran `git diff --check`:
  - passed with no whitespace or patch hygiene issues.
- Ran the required marker scan across `R`, `tests`, `docs/teaching/shiny`, and
  the Goal 013 packet:
  - no hits in `R/`, `tests/`, or `docs/teaching/shiny/`.
  - intentional hits remain only in the Goal 013 contract text where `Goal.md`
    and `Runbook.md` quote the validation command itself.
- Ran a narrow trailing-whitespace scan over the new/updated Goal 013 files:
  - no matches.
- Ran `git status --short --branch --untracked-files=all`:
  - `## main...origin/main`
  - Goal 013 tracked change: `NAMESPACE`
  - Goal 013 untracked additions:
    - `R/teaching_api.R`
    - `tests/testthat/test-12_teaching_api.R`
    - `docs/goals/013-practical-1-teaching-api-adapter/Goal.md`
    - `docs/goals/013-practical-1-teaching-api-adapter/Log.md`
    - `docs/goals/013-practical-1-teaching-api-adapter/Plan.md`
    - `docs/goals/013-practical-1-teaching-api-adapter/Runbook.md`
  - pre-existing tracked edits remain in:
    - `docs/teaching/woodhen/README.md`
    - `docs/teaching/woodhen/instructor-guide.md`
  - pre-existing untracked Goal 010, Goal 011, Goal 012, legacy intake,
    assessment draft, and Shiny design/feasibility files remain visible.
- Allowed-surface check:
  - Goal 013 changes were limited to `R/teaching_api.R`,
    `tests/testthat/test-12_teaching_api.R`, `NAMESPACE`, and this Goal 013
    `Log.md` plus the pre-existing untracked Goal 013 packet files.
  - No Shiny UI, Shiny dependency, deployment/deep-server service file,
    scenario YAML, broad engine refactor, Goal 010 assessment file,
    export/student workspace file, commit, push, branch, or PR occurred.
