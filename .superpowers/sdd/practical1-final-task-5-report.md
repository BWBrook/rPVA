# Practical 1 Task 5 Verification Report

## Revision and scope

- Base requested by the plan: `9b95a7f`
- Implementation commit: `30e1639` (`Separate Practical 1 history and evidence`)
- Changed implementation files: `inst/shiny/practical1/app.R` and `tests/testthat/test-13_practical1_shiny.R`
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

## Additional verification

- Mechanical duplicate-attempt inspection via `shiny::testServer()` passed: four successful history runs had unique IDs; two environmental attempts retained different settings; selected evidence remained exactly three runs; selected cards exposed the selected run labels; changing the selected risk made interpretation readiness stale without deleting the interpretation text.
- `Rscript --vanilla -e 'invisible(parse(file = "inst/shiny/practical1/app.R")); cat("app.R parse OK\\n")'` passed.
- `git diff --check` passed before the implementation commit.
- Final pre-commit scope check found only `inst/shiny/practical1/app.R` and `tests/testthat/test-13_practical1_shiny.R` changed; no `renv/` or `renv.lock` diff remained.

## Caveats

- Browser/Playwright acceptance was not run; that is the later browser-acceptance scope, while the brief's duplicate-attempt check was executable mechanically and was completed above.
- The focused R runs reported the existing project environment warning that `pak` is installed but not recorded/used by renv. No renv files or lockfiles were changed. The repository startup hook also rewrote whitespace in `renv/activate.R` during non-vanilla R commands; that incidental change was restored to `HEAD` before scope checks and commits.
- Task 6 download gating and Transfer checklist behavior were intentionally not implemented.
