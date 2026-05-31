# Plan

## Milestone 1: State And PR Check

Acceptance criteria:

- current branch is `codex/refactor-pva-core`
- upstream state is clean or intentionally updated
- `origin/main` is fetched
- existing PR state is checked

Validation:

- `git status --short --branch`
- `git fetch --prune origin`
- `gh pr list --repo BWBrook/rPVA --head codex/refactor-pva-core`

## Milestone 2: Review Package Assembly

Acceptance criteria:

- PR body summarises the refactor, semantic audit, validation, intentional API
  changes, residual risks, and reviewer focus
- PR body links to repo artefacts under `docs/codex/`
- management artefacts under `docs/goals/` are explicitly called out

Validation:

- inspect `docs/codex/semantic-equivalence-audit-2026-05-30.md`
- inspect current diff/stat against `origin/main`

## Milestone 3: Final Validation

Acceptance criteria:

- cheap hygiene and package state checks pass
- targeted test coverage for the semantic-audit fix passes
- full package validation is run if needed based on any new changes

Minimum validation:

- `git diff --check origin/main...HEAD`
- `Rscript -e 'renv::status()'`
- `Rscript -e 'source("bootstrap.R")'`
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-10_validation.R", reporter = "summary")'`
- inspect `docs/codex/semantic-equivalence-results-2026-05-30.csv` for no
  `different` rows

Full validation is not required if only the goal log or PR text changes, because
the previous semantic audit already ran the full gates.

## Milestone 4: Draft PR

Acceptance criteria:

- draft PR is created only if no duplicate exists
- PR targets `main`
- PR URL is recorded in this goal log
- branch remains clean and pushed

Validation:

- `gh pr view <url>`
- `git status --short --branch`
