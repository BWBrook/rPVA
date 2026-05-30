# Runbook

## Read First

- `docs/codex/refactor-branch-review-2026-05-30.md`
- `docs/codex/semantic-equivalence-audit-2026-05-30.md`
- `docs/codex/semantic-equivalence-results-2026-05-30.csv`
- `docs/goals/002-semantic-equivalence-audit/Log.md`

## Operating Rules

- Work only in `/Users/bwbrook/git/rPVA`.
- Stay on `codex/refactor-pva-core`.
- Do not merge to `main`.
- Open at most one draft PR.
- Do not rerun remote/HPC jobs.
- Keep optional `ggrastr`/`Cairo` policy unchanged.
- Update `docs/goals/003-pr-readiness-package/Log.md` before final response.

## Decision Authority

The executor may autonomously:

- create or update a draft PR
- update this goal log
- run local validation
- make tiny documentation-only corrections needed for PR clarity

The executor must stop or ask Barry before:

- changing package/model code
- changing scenario parameters
- removing `docs/goals/` management artefacts
- merging the PR
- force-pushing or rewriting history

## PR Body Should Include

- concise summary
- main implementation changes
- semantic equivalence audit result
- intentional API/spec changes
- validation commands
- residual risks
- reviewer focus
- note that `docs/goals/` are experimental action-agent goal artefacts and may
  be removed before final merge if Barry prefers
