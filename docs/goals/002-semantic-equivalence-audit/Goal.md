# Goal: Semantic Equivalence And Merge-Readiness Audit

## Objective

Determine whether `codex/refactor-pva-core` preserves the intended scientific
and public-contract behaviour of `origin/main`, while documenting intentional
API/spec changes and any residual merge risks.

This is a review/audit goal with permission for narrow fixes when evidence
shows a clear defect.

## Operating Mode

Scientific workflow plus review/audit.

## Scope

In scope:

- compare the refactor branch against `origin/main` using small reproducible
  PVA cases
- document intentional API/spec changes, especially `demo_sd` to
  `demographic_stochasticity`, lean default outputs, and stricter validation
- build a reusable comparison harness under `docs/codex/`
- add or tighten tests if the audit reveals an important untested invariant
- fix narrow, low-risk defects found by the audit
- rerun validation and push if green

Out of scope:

- merging to `main`
- opening a PR unless explicitly asked
- broad scientific/model redesign
- large ensemble/HPC runs
- changing optional dependency policy

## Deliverables

- `docs/codex/semantic-equivalence-audit-2026-05-30.md`
- a reusable comparison script or scripts under `docs/codex/`
- any narrow tests/fixes needed to support the audit conclusions
- committed and pushed branch if validation passes
- final response summarising behaviour preserved, intentional changes, defects
  found/fixed, validation, and residual risks

## Done When

- the audit compares current branch behaviour with `origin/main` for a small
  but meaningful set of deterministic and fixed-seed stochastic cases
- intentional differences are documented
- unexpected differences are either fixed, covered by tests, or clearly logged
  as residual risks
- validation gates pass
- branch is clean and pushed, unless a real regression blocks the goal

## Review Surface

The supervisor will review:

- semantic audit memo
- comparison script
- tests or fixes added
- validation evidence
- branch diff since `c6d5db8`
