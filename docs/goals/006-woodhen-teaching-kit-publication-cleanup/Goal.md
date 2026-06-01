# Goal: Woodhen Teaching Kit Publication Cleanup

## Objective

Make the Goal 005 Woodhen teaching kit publishable and minimally delivery-ready:
ensure it is visible to git, fix the known scenario-horizon wording issue,
clean whitespace in the new teaching documents, and validate the report
scaffold as far as is cheap and local.

## Why This Matters

Goal 005 produced a useful first teaching kit, but supervisor review found that
the primary deliverable is currently hidden by `.gitignore`. That means the kit
exists locally but is not commit-ready or review-ready. A small cleanup pass is
needed before the project moves on to broader Goal 006+ teaching/reporting
development.

This goal is also the first road test of the supervisor/action-agent model
policy: the action agent should run a clear, bounded executor goal with
`gpt-5.3-codex-spark` and extra-high reasoning.

## Operating Mode

Publication cleanup, documentation validation, no package-code changes.

## Current Unlocked Envelope

Allowed:

- edit `.gitignore` only enough to make `docs/teaching/` and its contents
  visible to git
- edit files under `docs/teaching/woodhen/`
- update this goal's `Log.md`
- run local, cheap validation commands
- create a short note under `docs/codex/` if useful

Not allowed:

- edit package code under `R/`
- edit YAML scenarios under `inst/extdata/`
- edit tests, CI, dependencies, `renv.lock`, `DESCRIPTION`, or package metadata
- change scientific assumptions, model defaults, or Woodhen scenario values
- implement Shiny or any other UI
- commit, push, open PRs, merge, or delete branches
- launch remote/HPC jobs or long simulation campaigns

## Review Surface

Primary files:

- `.gitignore`
- `docs/teaching/woodhen/`
- `docs/goals/006-woodhen-teaching-kit-publication-cleanup/Log.md`

Secondary review surface:

- `git status --short --branch --ignored=matching`
- direct whitespace scan over `docs/teaching/woodhen/`
- any report-scaffold validation artefact or note

## Scope

In scope:

- adjust ignore rules so `docs/teaching/woodhen/` is no longer ignored
- fix Practical 2 wording that currently asks about "20- and 100-year horizons"
  even though the current Woodhen teaching scenarios use 40-, 5-, and 75-year
  horizons
- remove trailing whitespace from the teaching Markdown/Quarto files
- check that the report scaffold has a plausible execution path from the repo
  root, and either render it cheaply or record why a full render is not yet
  appropriate
- update this goal log with starting state, commands, changes, residual risks,
  and final git state

Out of scope:

- rewriting the teaching kit for pedagogy
- adding helper functions
- changing exported APIs
- changing Woodhen scenario values or model assumptions
- making a polished final PDF/DOCX
- implementing RShiny
- committing or pushing

## Read First

- `docs/goals/005-woodhen-teaching-practical-kit/Goal.md`
- `docs/goals/005-woodhen-teaching-practical-kit/Log.md`
- `docs/teaching/woodhen/README.md`
- `docs/teaching/woodhen/practical-2-woodhen-management.md`
- `docs/teaching/woodhen/report-scaffold.qmd`
- `.gitignore`

## Starting State Checks

Run these first and record results in `Log.md`:

```sh
git status --short --branch --ignored=matching
git check-ignore -v docs/teaching/woodhen/README.md || true
rg -n "[ \t]+$" docs/teaching/woodhen || true
```

Expected state:

- branch is `main...origin/main`
- Goal 004 and Goal 005 management artefacts are untracked
- `docs/teaching/` is ignored before cleanup

If tracked package source files are dirty before you start, stop and report the
mismatch.

## Required Work

1. Confirm the current repo state and inspect the Goal 005 supervisor caveats.
2. Update `.gitignore` so `docs/teaching/` and `docs/teaching/**` are visible
   while the rest of pkgdown-style `docs/*` output remains ignored.
3. Fix the Practical 2 horizon wording to match the current Woodhen scenario
   horizons.
4. Remove trailing whitespace in `docs/teaching/woodhen/`.
5. Inspect `report-scaffold.qmd` for repo-root execution assumptions. Make the
   scaffold runnable from a normal repo-root workflow if a narrow documentation
   edit is enough.
6. Run validation gates and record exact commands/results.
7. Recheck final git state and report exactly what changed.

## Validation Gates

The goal is complete when:

- `git check-ignore -v docs/teaching/woodhen/README.md` no longer reports that
  the teaching kit is ignored
- `git status --short --branch --ignored=matching` shows `docs/teaching/` as
  untracked rather than ignored
- the Practical 2 horizon wording matches the current scenario horizons
- `rg -n "[ \t]+$" docs/teaching/woodhen || true` reports no trailing
  whitespace
- `git diff --check` passes
- the report scaffold is either cheaply render-tested or its current render
  blocker is recorded in `Log.md`
- only allowed files changed

Suggested checks:

```sh
git check-ignore -v docs/teaching/woodhen/README.md || true
git status --short --branch --ignored=matching
rg -n "[ \t]+$" docs/teaching/woodhen || true
git diff --check
```

For the report scaffold, prefer a cheap local check. If a full Quarto render is
attempted, do not leave rendered HTML/PDF/DOCX artefacts in the worktree unless
they are intentionally ignored and reported.

## Deliverables

- updated `.gitignore`
- cleaned `docs/teaching/woodhen/` files
- updated `docs/goals/006-woodhen-teaching-kit-publication-cleanup/Log.md`
- final response with validation results, git state, and residual risks

## Decision Authority

You may decide:

- the exact `.gitignore` exception syntax needed to expose `docs/teaching/`
- the exact wording that replaces the horizon error
- whether the report scaffold needs a tiny path/setup edit to support local
  validation

You must pause before:

- changing package code, scenarios, tests, dependencies, or CI
- broad rewriting of the teaching kit
- making commits, pushes, PRs, or branch changes
- implementing interface work

## Stop Conditions

Stop when one of these is true:

- the teaching kit is no longer ignored and the cleanup checks pass
- tracked package source files are unexpectedly dirty
- validating the report scaffold requires package-code or dependency changes
- a scientific judgement from Barry is required before the wording can be made
  honest
