# Practical 1 Final Task 9 State Freshness Fix

Date: 2026-07-15
Base: `4d57dfd`
Implementation commit: `052e65b` (`Fix Practical 1 evidence state freshness`)

## RED

Added focused regressions in `tests/testthat/test-13_practical1_shiny.R` for:

- repeated Start baseline after baseline, risk, action, interpretation, and
  both requested downloads;
- monotonic IDs after adding another risk and action;
- export identity based on ordered selected IDs plus trimmed interpretation;
- invalidation after selection changes and interpretation edits;
- independent comparison and notes request completion; and
- reset clearing recorded artifact signatures as well as request flags.

The focused test command failed before the app repair. The observed failures
included the old destructive baseline-rerun expectations and the new
non-destructive-history assertions, confirming that the regressions exercised
the missing behaviour.

## GREEN

`inst/shiny/practical1/app.R` now:

- executes Start baseline only while `baseline_started()` is false;
- returns later Start clicks to the stored baseline/current baseline view,
  preserves history, IDs, evidence selection, interpretation, and download
  state, and navigates to Concept Lab;
- records a per-artifact export signature only after the CSV or Markdown write
  succeeds;
- clears both request flags and recorded signatures whenever selected evidence
  or interpretation input changes;
- requires each transfer request to match the current export signature; and
- clears recorded signatures and flags on confirmed reset.

The Start copy now states: “First click creates baseline run 1; later clicks
return to run 1 without changing your session.”

## Verification

- Focused test run 1: exit 0; `13_practical1_shiny` completed with no failures.
- Focused test run 2: exit 0; `13_practical1_shiny` completed with no failures.
- App parse: `Rscript -e 'parse(file="inst/shiny/practical1/app.R")'`; exit 0.
- `git diff --check`: exit 0.
- Scoped source diff before commit contained only `inst/shiny/practical1/app.R`
  and `tests/testthat/test-13_practical1_shiny.R`.

## Caveats

`renv::status(sources = FALSE)` remains unsynchronized because `pak` is
installed and used but not recorded in `renv.lock` (`installed=y`,
`recorded=n`, `used=y`). This pre-dates the repair; no lockfile or package
state was changed.

The browser script and browser acceptance workflow were intentionally left
untouched for the next sequential repair.
