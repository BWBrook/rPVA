# Plan

## Phase 1: Orient And Record Start State

- Read `Goal.md`, `Plan.md`, `Runbook.md`, and existing teaching/Shiny docs
  named in the goal.
- Confirm branch, HEAD, and status.
- Record start state in `Log.md`.

## Phase 2: Baseline Checks

- Run bootstrap and `renv::status(sources = FALSE)`.
- Run focused teaching API and Practical 1 Shiny tests.
- Render the report scaffold to DOCX.
- Attempt PDF render and record the exact result.

## Phase 3: Browser Dress Rehearsal

- Launch Practical 1 Shiny locally.
- Use Chrome plugin control if available.
- If Chrome is unavailable, record the blocker and use in-app Browser,
  Playwright/Chromium, or Computer Use fallback as appropriate.
- Exercise the Start, Concept Lab, Compare, and Transfer flow.
- Download and inspect the comparison CSV and evidence-notes Markdown.
- Capture screenshot evidence under `/tmp` unless a small committed screenshot
  is intentionally part of the fallback pack.
- Stop the app and confirm the port is closed.

## Phase 4: Rough-Edge And Fallback Review

- Run at least one rapid-click, rerun, or backtracking path.
- Compare before/after repo status to prove app use does not write repo
  runtime artefacts.
- Identify confusing instructions, labels, or missing fallback guidance.
- Draft or update the lightweight fallback pack.

## Phase 5: Narrow Fixes

- Make only small documentation, checklist, troubleshooting, fallback, or UI
  wording changes justified by evidence.
- Avoid science, deployment, authentication, persistence, or assessment-design
  changes.

## Phase 6: Final Validation And Report

- Run validation gates from `Goal.md`.
- Run marker and secret-pattern scans over changed/new tracked text.
- Write `dry-run-report.md`.
- Update `Log.md`.
- Report changed files, evidence paths, residual risks, and recommendation.
