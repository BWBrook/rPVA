# Runbook

## Required First Commands

```sh
git status --short --branch
git log --oneline --decorate --max-count=8
gh pr view 2 --repo BWBrook/rPVA --json number,state,mergedAt,mergeCommit,url
```

Stop if the repo is not on clean `main` synced with `origin/main`.

## Suggested Cheap Checks

Use these if they still make sense after reading current state:

```sh
git diff --check HEAD
Rscript -e 'st <- renv::status(sources = FALSE); cat("synchronized=", isTRUE(st$synchronized), "\n")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-09_scenarios.R", reporter = "summary")'
```

Do not run full `R CMD check` unless the audit finds a reason.

## Audit Memo Shape

Use this structure unless a better one emerges:

```md
# rPVA Post-Merge Readiness Audit - 2026-06-01

## Executive Summary
## Current State
## Teaching Road-Test Target
## Package Hygiene
## Woodhen Case Study Readiness
## Tutorial And Pedagogy
## Engine/API Usability
## Diagnostics, Plotting, And Reporting
## Interface Options, Including RShiny
## Testing And CI
## Ranked Roadmap
## Recommended Next Goals
## Residual Risks
```

## Ranking Rules

Must do before road test:

- blocks installation, running, or teaching
- creates likely student confusion during the practical
- undermines Woodhen case-study credibility
- prevents assessable report production

Should do if time allows:

- improves polish, speed, or demonstrator support
- reduces known friction but has a workaround
- prepares later Shiny or reporting work without depending on it

Defer:

- substantial new UI or model expansion
- optional plotting dependency work
- non-Woodhen case-study expansion
- scientific changes needing Barry's domain judgement

## Boundaries

Do not edit package code, YAML scenarios, dependencies, CI, README, or tests in
this goal. Create only the audit memo and update `Log.md`.
