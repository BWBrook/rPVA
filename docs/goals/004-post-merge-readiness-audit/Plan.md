# Plan

## 1. Confirm State

- Check branch, remote sync, and dirty state.
- Confirm PR #2 is merged and identify the merge commit.
- Record results in `Log.md`.

## 2. Inspect Current Surfaces

- Read the README, DESCRIPTION, CI workflow, prior Codex audit docs, and goal
  logs.
- Skim exported R functions and tests to understand current user-facing
  workflow.
- Inspect `inst/extdata/woodhen/` and `inst/extdata/toy/` as the teaching
  anchor and beginner ramp.

## 3. Audit Teaching Readiness

Assess the package as:

- a first-time PVA student
- a teaching demonstrator
- a professional conservation user
- a package maintainer

Record concrete friction points and supporting file references.

## 4. Audit Interface Options

Describe what a better interface needs to do before choosing technology.

Compare at least:

- improved scripted/tutorial workflow
- lightweight R helpers/report templates
- RShiny interface

Recommend whether Shiny should be explored now, prototyped later, or deferred.

## 5. Rank Roadmap

Create a ranked roadmap:

- must do before road test
- should do if time allows
- defer until after road test

Include likely next action-agent goals.

## 6. Finalize

- Write `docs/codex/post-merge-readiness-audit-2026-06-01.md`.
- Update this goal's `Log.md`.
- Recheck final git state.
- Respond with paths, validation, recommendations, and risks.
