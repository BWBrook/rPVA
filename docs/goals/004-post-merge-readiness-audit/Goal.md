# Goal: Post-Merge Readiness Audit

## Objective

Produce a no-code post-merge readiness audit for `rPVA` on `main`, with a
ranked roadmap for making the package ready for a Woodhen-centred third-year
undergraduate teaching road test in about two months.

## Why This Matters

The refactor branch has been merged. The project now needs to become a
release-quality research and teaching package, not merely a working engine.

Barry used rPVA for teaching last year and wants the next version to be a
zero-to-hero teaching tool: students should start with no PVA background and,
after two three-hour practical classes, be able to run, diagnose, extend, and
write an assessable report on the Woodhen case study.

RShiny may be a good future interface for students and professionals, but this
goal should evaluate that option rather than implement it.

## Operating Mode

Review or audit, with teaching-product and scientific-workflow orientation.

## Review Surface

Primary review surface:

- `docs/codex/post-merge-readiness-audit-2026-06-01.md`

Secondary review surface:

- updated `docs/goals/004-post-merge-readiness-audit/Log.md`
- final response summary with git state, validation, ranked recommendations,
  and residual risks

## Scope

In scope:

- inspect the current `main` branch and package structure
- inspect README, exported functions, scenario scripts, tests, CI, docs, and
  prior Codex audit artefacts
- assess teaching-readiness for two three-hour practical classes
- assess Woodhen case-study readiness as the anchor road test
- assess whether package hygiene issues should be fixed before new features
- identify what a student/professional interface should support
- compare interface directions at a high level, including RShiny
- rank near-term implementation priorities for the next four to eight weeks

Out of scope:

- editing package code
- editing YAML scenarios
- implementing Shiny or any other UI
- changing scientific assumptions or defaults
- changing dependency policy
- committing, pushing, opening PRs, or merging
- launching remote/HPC jobs

## Read First

- `README.md` - current user-facing promise and setup path
- `DESCRIPTION` - package dependencies and exported package intent
- `.github/workflows/r-ci.yaml` - current CI coverage
- `R/` - current engine and interface surface
- `inst/extdata/woodhen/` - anchor case study and teaching road-test material
- `inst/extdata/toy/` - beginner ramp material
- `tests/testthat/` - current behaviour and regression coverage
- `docs/codex/refactor-branch-review-2026-05-30.md` - prior readiness evidence
- `docs/codex/semantic-equivalence-audit-2026-05-30.md` - behavioural baseline
- `docs/goals/003-pr-readiness-package/Log.md` - prior PR-readiness record

## Starting State Checks

Run these first and record the results in `Log.md`:

```sh
git status --short --branch
git log --oneline --decorate --max-count=8
gh pr view 2 --repo BWBrook/rPVA --json number,state,mergedAt,mergeCommit,url
```

If the repo is not on clean `main` synced with `origin/main`, stop and report
the mismatch before auditing.

## Git And Publication Policy

Do not commit or push in this goal.

The supervisor has published this goal packet into the action repo. Treat the
new `docs/goals/004-post-merge-readiness-audit/` files as expected dirty
management state. Update `Log.md` as part of the deliverable.

## Data, Compute, And Staging Policy

This is a local audit. Do not run heavy simulations or remote jobs.

Small local commands are allowed when they improve confidence, for example:

```sh
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-09_scenarios.R", reporter = "summary")'
```

Do not generate large artefacts. If you inspect generated examples, keep them
in temporary locations and clean them up.

## Required Work

1. Verify current repo and PR state.
2. Inspect the package through the eyes of a student, a teaching demonstrator,
   a professional user, and a package maintainer.
3. Identify readiness issues in these categories:
   - package hygiene and installation
   - engine/API usability
   - scenario authoring and validation
   - Woodhen case-study workflow
   - toy/tutorial learning ramp
   - diagnostics and interpretation support
   - plotting and reporting
   - CI/testing/reproducibility
   - optional UI/RShiny path
4. Rank recommended next work into:
   - must do before the two-month teaching road test
   - should do if time allows
   - defer until after road test
5. Propose the next two or three action-agent goals after this audit.

## Validation Gates

The goal is complete when:

- starting state is recorded in `Log.md`
- the audit memo exists and answers the teaching-readiness question
- recommendations are ranked by urgency and risk
- any commands run are recorded with pass/fail status
- `Log.md` records artefacts, residual risks, and final git state

This is orientation/audit validation. Full package checks are not required
unless the current state appears inconsistent with prior evidence.

## Deliverables

- `docs/codex/post-merge-readiness-audit-2026-06-01.md`
- updated `docs/goals/004-post-merge-readiness-audit/Log.md`
- final response with:
  - current branch and git state
  - commands run and outcomes
  - audit memo path
  - top five recommendations
  - suggested next goal
  - uncommitted/tracked/untracked file status

## Decision Authority

You may decide:

- how to structure the audit memo
- which files to inspect beyond the read-first list
- which cheap local checks are worthwhile
- how to rank implementation priorities based on evidence

You must pause before:

- implementing code or UI changes
- modifying scenarios
- changing package dependencies
- changing scientific assumptions
- committing or pushing
- deleting historical `docs/goals/` or `docs/codex/` artefacts

## Stop Conditions

Stop when one of these is true:

- the audit memo and log are complete
- repo state is not the expected clean `main`
- a high-level decision from Barry is needed before ranking can be honest

## Final Response Requirements

Report succinctly:

- what you inspected
- what you produced
- what validation ran
- the top recommendations
- the suggested next goal
- final git status
