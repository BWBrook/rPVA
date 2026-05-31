# Plan

## Milestone 1: Establish Baseline And Authority

Acceptance criteria:

- current branch/remote state is known
- no work is done on `main`
- a temporary or detached `origin/main` comparison checkout is created without
  disturbing the primary checkout
- expected intentional changes are listed before running comparisons

Validation:

- `git status --short --branch`
- `git fetch --prune origin`
- `git merge-base --is-ancestor origin/main HEAD`
- record `origin/main` and `HEAD` SHAs

## Milestone 2: Build Comparison Harness

Acceptance criteria:

- comparison code lives under `docs/codex/`
- harness can run both `origin/main` and `HEAD` in separate R processes or
  otherwise avoids package-version contamination
- harness includes enough comments or README text to rerun it
- temporary worktrees/build artefacts are cleaned up or clearly excluded

Suggested cases:

- deterministic minimal programmatic spec with stochasticity disabled
- fixed-seed demographic stochasticity case
- management-action case covering removal/release or carrying capacity
- woodhen scenario summary smoke comparison, allowing documented intentional
  spec-key translation

Validation:

- harness runs to completion
- output paths are recorded in the audit memo

## Milestone 3: Classify Behaviour

Acceptance criteria:

- preserved behaviour is separated from intentional branch changes
- any unexpected differences have a short root-cause note
- narrow defects are fixed only if the evidence is clear and the fix is small
- important missing invariants get tests

Validation:

- audit memo includes a comparison table
- tests added/changed only where justified

## Milestone 4: Final Validation

Acceptance criteria:

- package checks remain green
- comparison harness still runs
- generated artefacts are either tracked intentionally under `docs/codex/` or
  cleaned up

Validation:

- comparison script command
- `git diff --check origin/main...HEAD`
- `Rscript -e 'renv::status()'`
- `Rscript -e 'source("bootstrap.R")'`
- full `testthat`
- woodhen smoke test
- `R CMD build`
- `R CMD check` with `_R_CHECK_FORCE_SUGGESTS_=false`

## Milestone 5: Commit And Push

Acceptance criteria:

- commit message names the audit or any narrow fix
- branch is pushed if validation passes
- final response gives supervisor enough evidence to review

Validation:

- `git status --short --branch`
- `git log --oneline --decorate -5`
- `git ls-remote --heads origin codex/refactor-pva-core`
