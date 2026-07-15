# Practical 1 Task 5 Verification Report

## Revision and scope

- Base requested by the plan: `9b95a7f`
- Implementation commit: `30e1639` (`Separate Practical 1 history and evidence`)
- Follow-up durable-regression commit: `32d5e94cfac74f4312544c36c884f339e7dd8917` (`Test duplicate Practical 1 evidence attempts`)
- Final verified source/test range: `9b95a7f..32d5e94`
- Changed implementation/test files: `inst/shiny/practical1/app.R` and `tests/testthat/test-13_practical1_shiny.R`; the follow-up changed only the test file.
- Report file: `.superpowers/sdd/practical1-final-task-5-report.md`
- `progress.md`, Practical 2, dependencies, persistence, lockfiles, and `renv/` were not changed.

## RED/GREEN evidence

### RED

Before the `app.R` implementation, the focused test command failed as expected:

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
```

The new server test failed because `selected_evidence_ids()` did not exist. The new static contracts also failed because the Compare view had no session-history/selected-evidence split.

### GREEN

The same focused command was run twice after implementation. Both runs completed with exit code 0, zero failures, and the full `13_practical1_shiny` focused file green.

The implementation covers ordered successful-run history, exactly three selected evidence IDs, pinned baseline, separate risk/action radio choices, latest-suitable defaults, stable run IDs/settings, selected-only cards/table/exports, readiness checks, interpretation signatures, stale-selection review, and text preservation on selection change.

The follow-up adds one durable `testServer()` regression covering four successful monotonic runs, two distinguishable environmental attempts, eligible risk choices, selection back to the earlier attempt, selected IDs/rows/cards, preserved interpretation text, stale readiness, and explicit reconfirmation.

## Additional verification

- Mechanical duplicate-attempt inspection via `shiny::testServer()` passed: four successful history runs had unique IDs; two environmental attempts retained different settings; selected evidence remained exactly three runs; selected cards exposed the selected run labels; changing the selected risk made interpretation readiness stale without deleting the interpretation text.
- The durable duplicate-attempt regression initially exposed only an overly strict test assertion: choice labels include run settings after the run number. The assertion was corrected to match the user-facing labels; no production defect or `app.R` change was required.
- The required pkgload-based focused command was run twice after the test repair; both runs exited 0 with zero failures.
- `Rscript --vanilla -e 'invisible(parse(file = "inst/shiny/practical1/app.R")); cat("app.R parse OK\\n")'` passed.
- `git diff --check` passed after the test repair.
- Final scope check found only the requested test/report changes after the implementation commit; no `renv/` or `renv.lock` diff remained.

## Caveats

- Browser/Playwright acceptance was not run; the durable duplicate-attempt check is now covered in `test-13` without expanding into later browser-acceptance scope.
- The focused R runs reported the existing project environment warning that `pak` is installed but not recorded/used by renv. No renv files or lockfiles were changed. The repository startup hook also rewrote whitespace in `renv/activate.R` during non-vanilla R commands; that incidental change was restored to `HEAD` before scope checks and commits.
- Task 6 download gating and Transfer checklist behavior were intentionally not implemented.
