# Plan

1. Orient and protect the branch.
   - Check `main`, fetch origin, verify no divergence, and inspect dirty state.
   - Read the required prior goal logs and package metadata.

2. Regenerate package documentation.
   - Run roxygen through `bootstrap.R`.
   - Inspect generated `NAMESPACE` and `man/` changes.
   - Make only narrow roxygen-comment fixes if a generated help page is broken.

3. Validate before commit.
   - Run focused tests, full tests, `renv::status()`, `git diff --check`,
     marker scan, and legacy-material size/identifier scans.
   - Run package build/check and move artifacts outside the repo.
   - Record all outcomes in `Log.md`.

4. Split commits cleanly.
   - Commit 1: accepted Goals 010-012 teaching, assessment, Shiny, hosting,
     and legacy-context documentation.
   - Commit 2: Goal 013 teaching API, tests, generated package docs, and Goal
     013-014 records.
   - Confirm staged files before each commit.

5. Push and report.
   - Push `main` to `origin`.
   - Confirm final status is clean and synced.
   - Report commit SHAs, validation evidence, and recommended next goal.
