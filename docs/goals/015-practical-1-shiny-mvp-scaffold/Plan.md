# Plan

1. Orient and protect the branch.
   - Confirm `main` is synced with `origin/main`.
   - Read Goal 015 plus the Shiny design docs, teaching API, plot helpers,
     package metadata, and Goal 014 publication log.

2. Add the Shiny package surface.
   - Add a small exported launcher, preferably `run_practical1_shiny()`.
   - Add `shiny` to `DESCRIPTION` `Suggests` and synchronize `renv.lock`.
   - Regenerate roxygen docs and `NAMESPACE`.

3. Build the MVP app.
   - Add `inst/shiny/practical1/app.R`.
   - Add `inst/shiny/practical1/www/styles.css`.
   - Implement Start, Concept Lab, Compare, and Transfer sections.
   - Use the existing teaching API and plot helpers; do not edit the engine.

4. Test and browser-check.
   - Add focused Shiny tests.
   - Run focused and full tests.
   - Run `renv::status()`, `git diff --check`, marker scan, and launch smoke.
   - Capture desktop and mobile screenshots into the Goal 015 evidence folder.

5. Publish if clean.
   - Update the Goal 015 log with validation evidence.
   - Commit the implementation as `Add Practical 1 Shiny MVP scaffold`.
   - Push `main`.
   - Report commit SHA, screenshot paths, final status, residual risks, and the
     recommended next goal.
