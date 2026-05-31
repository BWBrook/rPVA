# Goal: Pull Request Readiness Package

## Objective

Prepare `codex/refactor-pva-core` for human review by opening a draft pull
request against `main` with a high-quality review package, without merging it.

## Operating Mode

Review/audit plus repo readiness.

## Scope

In scope:

- refresh branch and remote state
- review the branch diff since `origin/main`
- verify the semantic audit artefacts are present and consistent
- update this goal's `Log.md` as the live completion record
- run a narrow final validation set appropriate for PR creation
- open a draft PR against `main` if validation passes and no PR already exists
- clearly call out management artefacts under `docs/goals/`

Out of scope:

- merging the PR
- broad scientific/model/API changes
- rerunning the full semantic equivalence harness unless evidence suggests the
  audited package-code state is stale
- running remote/HPC jobs
- changing optional dependency policy

## Deliverables

- updated `docs/goals/003-pr-readiness-package/Log.md`
- draft GitHub PR against `main`, unless blocked by existing PR state or
  validation failure
- final response with PR URL, validation evidence, residual risks, and
  recommended reviewer focus

## Done When

- branch state and PR state are known
- no duplicate PR is created
- final validation passes
- draft PR exists and links/summarises the semantic audit
- this goal log records commits, validation, PR URL, and residual risks
- branch is clean and pushed

## Review Surface

The supervisor will review:

- draft PR body
- current branch diff
- this goal log
- final validation evidence
- whether `docs/goals/` should remain in the merge candidate or be removed
  before final merge
