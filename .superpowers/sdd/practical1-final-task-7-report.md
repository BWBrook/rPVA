# Practical 1 Task 7 Verification Report

Date: 2026-07-15

## Completed action

Task 7 was implemented at the approved base `e6b7a943` and committed as:

```text
9b2a1a781209b342d8524f84ecc0953fed86c318
Polish Practical 1 classroom guidance
```

Changed implementation files:

- `inst/shiny/practical1/www/styles.css`
- `inst/shiny/practical1/app.R`
- `tests/testthat/test-13_practical1_shiny.R`
- `inst/shiny/practical1/README.md`
- `docs/teaching/shiny/practical-1-mission-tutorial.md`
- `docs/teaching/woodhen/practical-1-student-launch-page.md`
- `docs/teaching/woodhen/practical-1-mission-worksheet.md`
- `docs/teaching/woodhen/practical-1-day-of-class-pack.md`
- `docs/teaching/woodhen/practical-1-instructor-beat-sheet.md`
- `docs/teaching/woodhen/practical-1-moodle-ready-bundle/moodle-section-text.md`

`progress.md`, Practical 2 files, model/default/seed/state/dependency code, and
raw data were not changed.

## Implementation notes

- Added the stable laptop hierarchy with `minmax(0, ...)` tracks, grouped Core
  and Explore Further mission styling, readable status text and symbols,
  readiness/download state styling, visible `:focus-visible` outlines, and
  780px stacking for the main grids and evidence downloads.
- Added the `readiness-checklist` class while retaining the existing evidence
  readiness behavior and shortened the Transfer bridge to avoid Practical 2
  depth claims.
- Added CSS and copy contracts, updated the stale worksheet assertions to the
  approved five-mission route, and preserved all existing contextual action IDs.
- Aligned all listed Week 1 guidance to the exact Core/Explore route, three-hour
  timing, three-run evidence target, both download requests, and temporary
  session warning.

## Verification performed

- TDD red phase: the new selector/copy contracts failed before implementation
  because the required selectors and aligned copy were absent.
- Focused test:

  ```text
  Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
  ```

  Passed with no test failures after implementation. The project emitted its
  existing renv out-of-sync warning for `pak`; no renv file change was retained.
- Exact requested `rg` copy consistency scan: passed, with 66 matching lines.
- `app.R` parse: passed.
- `git diff --check`: passed before the implementation commit and the worktree
  is clean afterward.
- Horizontal-layout anti-pattern scan: no newly introduced fixed-width,
  `nowrap`, or hidden-overflow rules were found.
- No resident Practical 1 app/server was found after verification. An unrelated
  existing `kpz314-sdm-local` Shiny server on port 39314 was observed and left
  untouched.
- Incidental `renv/activate.R` whitespace was restored before committing.

## Remaining caveats

- The full repository test suite was started but intentionally interrupted by
  the user; it must not be represented as passed.
- No browser/Playwright visual acceptance was run in this Task 7 session, so
  1366x768, 1440x900, and narrow-screen rendering remain unverified here.
