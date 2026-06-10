# Plan

## Goal 023 Plan

Status: Not started by `woodhen`.

1. Confirm starting state.
   - Record `pwd`, branch, short HEAD, and `git status --short --branch`.
   - Confirm no repo-local `AGENTS.md` exists.

2. Read the contract and context.
   - Read `Goal.md`, `Plan.md`, `Runbook.md`, and `Log.md`.
   - Read the listed app, teaching, and recent-goal files.

3. Define the export contract.
   - Decide single bundle versus separate downloads.
   - Specify fields for comparison output and settings/provenance.
   - Keep the artefact compact and student-readable.

4. Implement narrowly.
   - Add the export UI in the Compare/Transfer part of the app.
   - Add any small helper needed for export content.
   - Keep ordinary app use repo-clean and session-local.

5. Test.
   - Add focused tests for helper/app wiring.
   - Preserve existing Practical 1 Shiny tests.

6. Update documentation.
   - Update only the app or teaching notes needed for the export workflow.
   - Keep deployment and service docs untouched unless a stale pointer must be
     corrected.

7. Validate.
   - Run the required R validation ladder.
   - Run marker and secret scans over changed/new text.
   - Run browser-visible Shiny export smoke and cleanup.

8. Report.
   - Update `Log.md`.
   - Report changed files, validation, browser evidence, residual risks, and
     next recommendation.
