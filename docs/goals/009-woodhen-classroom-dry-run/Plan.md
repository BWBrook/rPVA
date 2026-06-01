# Plan

## 1. Confirm Clean Starting State

- Verify `main` is synced with `origin/main` at Goal 008 publication commit.
- Confirm only the new Goal 009 packet and ignored `renv/staging/` are present.
- Record the starting state in `Log.md`.

## 2. Read The Teaching Flow

- Read the Woodhen teaching kit in delivery order.
- Note likely friction for students and demonstrators before editing.

## 3. Dry-Run Practical 1

- Run the toy model commands.
- Exercise representative plotting calls under a temp graphics device.
- Compare outputs against `expected-outputs.md`.

## 4. Dry-Run Practical 2

- Run Woodhen scenario table, helper diagnostics, plotting, and bounded
  sensitivity commands.
- Compare outputs against the practical and expected-output tables.

## 5. Dry-Run Report Scaffold

- Render DOCX and PDF into temp output directories.
- Confirm no rendered artefacts remain in the repo.

## 6. Make Low-Risk Teaching Fixes

- Fix stale values, broken commands, unclear setup/timing, or demonstrator
  guidance that is directly supported by the dry-run.
- Add a concise classroom dry-run checklist if useful.

## 7. Validate And Report

- Run full local tests and diff hygiene.
- Record exact validation evidence and final status in `Log.md`.
- Return a concise final report to the supervisor.
