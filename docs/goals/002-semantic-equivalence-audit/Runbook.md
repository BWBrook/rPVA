# Runbook

## Read First

- `/Users/bwbrook/git/rPVA/docs/codex/refactor-branch-review-2026-05-30.md`
- `/Users/bwbrook/git/rPVA/R/run_pva_core.R`
- `/Users/bwbrook/git/rPVA/R/run_pva_core_helpers.R`
- `/Users/bwbrook/git/rPVA/R/spec_validation.R`
- `/Users/bwbrook/git/rPVA/tests/testthat/test-00_contracts.R`
- `/Users/bwbrook/git/rPVA/tests/testthat/test-10_validation.R`

## Operating Rules

- Work only in `/Users/bwbrook/git/rPVA` and temporary comparison worktrees.
- Stay on `codex/refactor-pva-core` in the primary checkout.
- Do not merge to `main`.
- Do not open a PR.
- Do not launch remote/HPC jobs.
- Keep optional `ggrastr`/`Cairo` policy unchanged.
- Prefer evidence and classification over speculative refactoring.

## Decision Authority

The executor may autonomously:

- create temporary git worktrees for comparison
- add files under `docs/codex/`
- add small comparison scripts under `docs/codex/`
- add tests for clear behavioural invariants
- fix narrow defects with direct evidence from the audit

The executor must stop or ask Barry before:

- changing model assumptions
- altering public API beyond already-intended branch changes
- changing scenario scientific parameters
- resolving non-trivial merge conflicts from a moved `origin/main`
- making broad rewrites of the PVA engine

## Comparison Guidance

`origin/main` uses `demo_sd`; the refactor branch uses
`demographic_stochasticity`. Treat this as an intentional spec/API migration.
For behaviour comparisons, construct equivalent specs for each branch rather
than requiring old code to read new YAML keys or new code to accept old keys.

The refactor branch also intentionally changed defaults toward leaner output:
`run_pva_core()` defaults to `keep_traj = FALSE` and `verbose = FALSE`.
Compare explicit calls where necessary.

## Reporting Rules

The audit memo should include:

- exact SHAs compared
- comparison method
- cases run
- pass/fail/equivalent/different table
- intentional differences
- unexpected differences and action taken
- validation commands
- residual risks
- recommended next goal
