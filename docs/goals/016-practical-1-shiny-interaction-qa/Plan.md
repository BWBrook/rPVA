# Plan

1. Orient and protect the branch.
   - Confirm `main` is synced with `origin/main`.
   - Read Goal 016 plus Goal 015 log, Shiny design docs, app files, tests, and
     package metadata.

2. Prepare browser QA.
   - Define the target flow in `Log.md`.
   - Check Browser/IAB availability if exposed.
   - Otherwise confirm `npx` and the Playwright CLI wrapper are available.
   - Launch the Shiny app locally on `127.0.0.1:3862`.

3. Exercise the student flow.
   - Load Start.
   - Run all implemented stages from Concept Lab.
   - Verify summaries, diagnostics, plots, compare growth, reset, and Transfer.
   - Check desktop/laptop and mobile widths.
   - Capture screenshot evidence.

4. Harden scoped issues.
   - Fix confusing labels, missing guards, layout breakage, blank states, or
     interaction rough edges found during QA.
   - Add or adjust focused Shiny tests when behaviour changes.

5. Validate.
   - Focused Shiny tests.
   - Full package tests.
   - `renv::status()`.
   - `git diff --check`.
   - Marker scan.
   - Confirm the Shiny server is stopped.

6. Publish if clean.
   - Write `qa-report.md`.
   - Update `Log.md`.
   - Commit as `Harden Practical 1 Shiny interactions`.
   - Push `main`.
   - Report evidence, final status, residual risks, and next goal.
