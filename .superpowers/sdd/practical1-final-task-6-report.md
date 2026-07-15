# Practical 1 Task 6 execution report

Date: 2026-07-15
Base revision: `309e95b`
Implementation revision: `11997c1dcca1200ffc992049a2f91bb7b5d310f6`

## Completed action and changed files

Implemented Task 6, “Gate Downloads And Complete The Transfer Checklist”, in:

- `inst/shiny/practical1/app.R`
- `tests/testthat/test-13_practical1_shiny.R`

The implementation commit is `11997c1dcca1200ffc992049a2f91bb7b5d310f6`, with
exact message `Gate Practical 1 evidence downloads`.

The execution report is intentionally separate from that implementation commit.

## Implementation notes

- `evidence_export()` now requires `evidence_readiness_state()$ready`, exports
  `selected_evidence_runs()`, and passes
  `session_run_count = length(run_history())`.
- Compare renders disabled native buttons with `aria-disabled="true"` while
  evidence is not ready, and real `downloadButton()` controls once ready.
- Comparison and Markdown request state starts false and is set only after the
  corresponding artifact write succeeds. Student-facing state says
  `Download requested`; no `Evidence saved` claim was added.
- Transfer renders independent Comparison CSV and Evidence notes checklist
  states plus a next action while either request is missing.
- Confirmed reset clears the Task 5 selection/signature state and both Task 6
  request flags.
- Existing science, defaults, fixed seed, help/plots, recovery behaviour,
  Practical 2 code, persistence boundary, and package dependencies were not
  changed.

## Verification performed

TDD red/green:

- Added the Task 6 tests first.
- The pre-implementation focused Practical 1 run failed on the absent request
  state, gated-download UI, and reset state, as expected. The duplicate-run
  fixture was then aligned with the existing Task 5 successful sequence.
- The post-implementation focused Practical 1 run passed.

Commands and results:

```text
Rscript -e 'pkgload::load_all(".", quiet=TRUE); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'
PASS (exit 0)

Rscript -e 'pkgload::load_all(".", quiet=TRUE); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
PASS (exit 0)

Rscript -e 'pkgload::load_all(".", quiet=TRUE); testthat::test_dir("tests/testthat", reporter = "summary")'
PASS (exit 0; completed in 249.7 seconds)
```

The full suite reported `══ DONE ══` and included the Practical 2 API and Shiny
suites. It did not stop on an unrelated Practical 2 or environment failure.

Additional checks:

- `parse(file = "inst/shiny/practical1/app.R")`: PASS.
- `git diff --check`: PASS before the implementation commit.
- Only the two owned files were staged for the implementation commit.
- Incidental trailing whitespace in `renv/activate.R` was stripped after each
  R run; no renv file remained modified.

## Caveat

An additional direct `testServer` rendered-UI smoke was attempted. It confirmed
`evidence_readiness_state()$ready == TRUE`, but `testServer` retained the
initial disabled `renderUI` HTML after the first output access, so the smoke
exited non-zero when checking for the post-readiness link. This did not occur in
the focused or full test suites, and the branch logic, readiness predicate, and
successful download-handler tests passed. No production or unrelated test
failure was inferred from this harness-specific observation.
