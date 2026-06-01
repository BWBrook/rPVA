# Runbook

## Required First Commands

```sh
git status --short --branch --ignored=matching
git log --oneline --decorate --max-count=8
jq '.Packages.knitr, .Packages.rmarkdown, .Packages.quarto' renv.lock
quarto --version
Rscript -e 'source("bootstrap.R"); print(renv::status(sources = FALSE))'
```

Stop if tracked package source, teaching docs, metadata, or lockfiles are dirty
before the goal starts.

## Read-First Commands

```sh
sed -n '1,180p' DESCRIPTION
sed -n '1,220p' bootstrap.R
sed -n '1,220p' docs/teaching/woodhen/report-scaffold.qmd
sed -n '1,220p' docs/teaching/woodhen/README.md
sed -n '1,220p' docs/teaching/woodhen/troubleshooting.md
sed -n '1,220p' docs/goals/006-woodhen-teaching-kit-publication-cleanup/Log.md
sed -n '1,240p' docs/goals/007-pva-diagnostics-reporting-helpers/Log.md
```

## Narrow Edit Targets

Allowed files are:

```text
DESCRIPTION
renv.lock
docs/teaching/woodhen/report-scaffold.qmd
docs/teaching/woodhen/README.md
docs/teaching/woodhen/troubleshooting.md
docs/teaching/woodhen/instructor-guide.md
docs/teaching/woodhen/<optional-one-small-setup-file>.md
docs/goals/008-teaching-render-readiness/Log.md
docs/codex/<optional-short-note>.md
.gitignore only if generated-report artefact handling requires it
```

Do not edit package source under `R/`, scenario YAML, tests, CI, package
version, or Shiny/interface files.

## Dependency Guidance

Expected minimal dependency direction:

- add `knitr` and `rmarkdown` to `Suggests` if render inspection confirms they
  are needed
- synchronize `renv.lock` after dependency changes
- avoid adding the R package `quarto` unless a concrete render or tooling need
  justifies it

Possible commands, to be adapted after inspection:

```sh
Rscript -e 'source("bootstrap.R"); renv::install(c("knitr", "rmarkdown")); renv::snapshot(prompt = FALSE)'
Rscript -e 'source("bootstrap.R"); print(renv::status(sources = FALSE))'
```

If `renv::install()` is not the right route because packages are already in the
global/cache state, use the least surprising `renv` workflow and document it.

## Scaffold Path Guidance

The scaffold should not depend on Barry-specific absolute paths such as
`/Users/bwbrook/git/rPVA`.

If Quarto executes chunks from `docs/teaching/woodhen/`, make the setup chunk
discover the repo root portably and use that root for `bootstrap.R` and later
chunks. A small helper in the setup chunk is acceptable if it stays readable.

## Render Validation

Prefer temp output directories so the worktree stays clean:

```sh
rm -rf /tmp/rpva-goal008-render
mkdir -p /tmp/rpva-goal008-render/docx /tmp/rpva-goal008-render/pdf
quarto render docs/teaching/woodhen/report-scaffold.qmd --to docx --output-dir /tmp/rpva-goal008-render/docx
quarto render docs/teaching/woodhen/report-scaffold.qmd --to pdf --output-dir /tmp/rpva-goal008-render/pdf
find /tmp/rpva-goal008-render -maxdepth 3 -type f | sort
```

If Quarto writes beside the source despite this, remove generated artefacts
after recording the result.

## Regression And Hygiene Checks

Required before final report:

```sh
Rscript -e 'source("bootstrap.R"); print(renv::status(sources = FALSE))'
Rscript -e 'source("bootstrap.R"); testthat::test_local()'
git diff --check
git status --short --branch --ignored=matching
git diff --name-only
git ls-files --others --exclude-standard docs/teaching/woodhen
```

Also confirm no accidental rendered report outputs are left:

```sh
find docs/teaching/woodhen -maxdepth 1 -type f \( -name 'report-scaffold.pdf' -o -name 'report-scaffold.docx' -o -name 'report-scaffold.html' \) -print
```

## Final Response Shape

Include:

- whether formal goal mode was active
- changed files
- dependency changes made and why
- DOCX/PDF render outcomes
- test and hygiene outcomes
- any generated artefacts and whether they were cleaned
- residual risks
- final git status
