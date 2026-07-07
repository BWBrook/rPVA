# Platinum Teaching Product Build Pass Report

## Summary

Goal 049 lifts the KPZ308 teaching package into a coherent Practical 1,
Practical 2, and AT1 pathway. Practical 1 now gives students a clearer guided
mission experience and captures interpretation in the evidence export. Practical
2 now has a bounded Woodhen teaching API and first Shiny Management Lab surface.
The report scaffold and assessment documents now connect model outputs to
conservation advice writing.

## Sidecar input used

- Practical 2 API sidecar: recommended catalogued scenario helpers, one-factor
  sensitivity presets, run bundles, set comparisons, and evidence exports.
- Assessment sidecar: recommended an AT1 conservation advice report scaffold,
  evidence-to-sentence guidance, horizon language, and feedback prompts for
  exact evidence and caveats.
- Delivery-doc sidecar: recommended current ITS-route separation, validated
  local teaching language, and stale-route cleanup.

## Practical 1 changes

- `compare_teaching_runs()` can include baseline-relative deltas.
- Practical 1 evidence exports can include the student's interpretation note.
- Concept Lab now includes a mission rail and next-mission control.
- Compare now includes run cards, baseline deltas, uncertainty-change language,
  and an interpretation capture box.
- Barry's Markdown modal content remains file-backed and editable.

## Practical 2 changes

- Added `woodhen_management_catalog()`.
- Added `build_woodhen_management_spec()`.
- Added `run_woodhen_management_scenario()`.
- Added `run_woodhen_management_set()`.
- Added `build_woodhen_management_evidence_export()`.
- Added `run_practical2_shiny()`.
- Added `inst/shiny/practical2/` with bounded core-management and sensitivity
  scenario choices, comparison tables, evidence exports, diagnostics, and report
  bridge prompts.

## Assessment and delivery changes

- `report-scaffold.qmd` is now an AT1 Woodhen PVA Conservation Advice Report
  scaffold using the Practical 2 API.
- `assessment-brief-2026-draft.md` now includes direct evidence-to-sentence
  guidance.
- `assessment-design-crosswalk-2026.md` now states scenario-horizon logic and
  current Shiny/export implications.
- `feedback-template-2026-draft.md` now prompts markers for exact evidence,
  scenario horizon, one-factor sensitivity, and caveat quality.
- Added `practical-2-student-launch-page.md`.
- Updated teaching README, instructor guide, and Shiny planning README for the
  two-app learning pathway.

## Boundary

No science/YAML/model-default changes were made. No remote ITS, Gitea, Docker,
Moodle, student-release, Practical 2 research-grade analysis, or KPZ314 work was
performed.

## Validation evidence

- `git diff --check`: passed.
- `Rscript -e 'source("bootstrap.R")'`: passed.
- `Rscript -e 'renv::status(sources = FALSE)'`: passed.
- Focused teaching/API/app tests passed:
  - `test-11_pva_helpers.R`
  - `test-12_teaching_api.R`
  - `test-13_practical1_shiny.R`
  - `test-14_practical2_woodhen_api.R`
  - `test-15_practical2_shiny.R`
- Full `testthat::test_dir("tests/testthat", reporter = "summary")`: passed.
- Report scaffold DOCX render:
  `/tmp/rpva-goal049-report/docx/report-scaffold.docx`.
- Report scaffold PDF render:
  `/tmp/rpva-goal049-report/pdf/report-scaffold.pdf`.
- Practical 1 browser smoke:
  `/tmp/rpva-goal049-browser/practical1/compare.png`,
  `/tmp/rpva-goal049-browser/practical1/comparison.csv`, and
  `/tmp/rpva-goal049-browser/practical1/evidence-notes.md`.
- Practical 2 browser smoke:
  `/tmp/rpva-goal049-browser/practical2/evidence-pack.png`,
  `/tmp/rpva-goal049-browser/practical2/report-bridge.png`,
  `/tmp/rpva-goal049-browser/practical2/woodhen-comparison-fresh.csv`, and
  `/tmp/rpva-goal049-browser/practical2/woodhen-evidence-notes-fresh.md`.
- Both local Shiny ports were closed after testing.
- Marker scan: clean.
- Strict secret/private-key/token/student-identifier scan: no real sensitive
  values found.
- Student-facing prose/internal-route scan: no actionable leaks; remaining
  route-word hits were false positives inside words such as `limitations` and
  `stochastic`.
