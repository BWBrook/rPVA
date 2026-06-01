# Runbook

## Required First Commands

```sh
git status --short --branch --ignored=matching
git log --oneline --decorate --max-count=8
git check-ignore -v docs/teaching/woodhen/README.md || true
rg -n "[ \t]+$" docs/teaching/woodhen || true
```

Stop if tracked package source files are dirty before you begin.

## Read-First Commands

```sh
sed -n '1,120p' .gitignore
sed -n '1,220p' docs/goals/005-woodhen-teaching-practical-kit/Log.md
sed -n '1,180p' docs/teaching/woodhen/practical-2-woodhen-management.md
sed -n '1,180p' docs/teaching/woodhen/report-scaffold.qmd
```

## Narrow Edit Targets

Allowed files are:

```text
.gitignore
docs/teaching/woodhen/*
docs/goals/006-woodhen-teaching-kit-publication-cleanup/Log.md
docs/codex/<optional-short-note>.md
```

Do not edit package source, scenarios, tests, metadata, dependencies, CI, or
Goal 005 files except by reading them.

## Suggested `.gitignore` Shape

The existing docs block is expected to look like:

```gitignore
docs/*
!docs/codex/
!docs/codex/**
!docs/goals/
!docs/goals/**
```

Add narrow exceptions for teaching docs:

```gitignore
!docs/teaching/
!docs/teaching/**
```

Keep generic pkgdown output under `docs/*` ignored.

## Practical 2 Wording

Replace the current question about "20- and 100-year horizons" with wording
like:

```text
Which scenario is the strongest practical intervention across the scenario
horizons used in this teaching setup?
```

If useful, mention that the current table includes 40-year intervention
scenarios, a 5-year rat-eradication demonstration, and a 75-year future
baseline.

## Report Scaffold Validation

Prefer the cheapest validation that proves the scaffold is not obviously
broken. Options include:

```sh
quarto render docs/teaching/woodhen/report-scaffold.qmd --to html
```

or a narrower R snippet check if Quarto render is blocked by working-directory
assumptions. If rendering creates `report-scaffold.html` or support files, leave
them ignored or remove them after recording the result.

Do not add dependencies to make the scaffold render.

## Final Checks

```sh
git check-ignore -v docs/teaching/woodhen/README.md || true
git status --short --branch --ignored=matching
rg -n "[ \t]+$" docs/teaching/woodhen || true
git diff --check
```

Also inspect changed-file scope:

```sh
git diff --name-only
git ls-files --others --exclude-standard docs/teaching/woodhen
```

## Final Response Shape

Include:

- whether `docs/teaching/woodhen/` is now visible to git
- files changed
- validation commands and outcomes
- report-scaffold render/check result
- residual risks
- final git status
- recommended next supervisor decision
