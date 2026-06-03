# Goal 014: Publication Hygiene And Clean Push

## Objective

Convert the accepted Goals 010-013 working-tree stack into clean, validated,
pushed package history.

This goal is primarily a publication-hygiene and repository-state goal. It
should regenerate package documentation for the new teaching API exports, run
package-level validation, split the accepted work into reviewable commits, and
push `main`.

## Context

Goals 010-013 have been accepted by the supervisor and Lab Leader:

- Goal 010 redesigned the 2026 AT1 assessment around the Lord Howe Island
  woodhen case study.
- Goal 011 produced the Practical 1 Shiny concept-lab design spike.
- Goal 012 assessed `deep-server` as the likely Shiny hosting path. The
  gateway has since been opened on `443`, so the remaining platform work is
  ShinyProxy/service implementation rather than network access discovery.
- Goal 013 implemented the package-level Practical 1 teaching API adapter.

Goal 013 passed focused and full tests, but its log records one remaining
publication note: generated `man/` pages were not created for the new exported
functions. This goal closes that gap and publishes the accepted stack.

## Required Sources

Read:

- `docs/goals/010-woodhen-at1-assessment-redesign/Log.md`
- `docs/goals/011-practical-1-shiny-design-spike/Log.md`
- `docs/goals/012-deep-server-shiny-platform-feasibility/Log.md`
- `docs/goals/013-practical-1-teaching-api-adapter/Log.md`
- `R/teaching_api.R`
- `tests/testthat/test-12_teaching_api.R`
- `DESCRIPTION`
- `NAMESPACE`
- `.Rbuildignore`
- `.gitignore`

You may inspect additional files as needed.

## Required Work

1. Confirm repository state.
   - Work in `/Users/bwbrook/git/rPVA` on `main`.
   - Run `git fetch --prune origin`.
   - Confirm the branch has not diverged from `origin/main`. If it has
     diverged, stop and report rather than rebasing, resetting, or force
     pushing.
   - Confirm the dirty worktree corresponds to the accepted Goals 010-013
     stack plus this Goal 014 packet.

2. Regenerate package documentation.
   - Run the repo-consistent roxygen path, expected to be:
     `Rscript -e 'source("bootstrap.R"); roxygen2::roxygenise()'`
   - If `roxygen2` is missing, install it into the local R/renv environment
     using the narrowest repo-consistent method, record the command in
     `Log.md`, and do not commit library/cache artifacts.
   - Inspect generated `man/` files for the new teaching API exports.
   - Keep documentation churn limited to roxygen-generated `NAMESPACE` and
     `man/` changes caused by the new API.

3. Run validation gates before committing.
   - focused teaching API tests
   - full package tests
   - package build and check without manual or vignette building
   - `renv::status()`
   - `git diff --check`
   - marker scan for `TODO|TBD|PLACEHOLDER`
   - a staging/sensitivity scan for large files and obvious direct student
     identifiers in the legacy intake materials

4. Stage and commit the accepted work in a reviewable split.
   - Commit 1 should contain the accepted teaching, assessment, Shiny, hosting,
     and legacy-context documentation from Goals 010-012.
   - Commit 2 should contain the Practical 1 teaching API adapter, its tests,
     generated package docs, and Goal 013-014 goal records.
   - Do not commit build artifacts, check directories, package tarballs,
     library/cache files, `.Rproj.user`, or unrelated local files.

5. Push `main` to `origin`.
   - Push only after validation and commits have succeeded.
   - Do not force-push.

6. Update `docs/goals/014-publication-hygiene-and-clean-push/Log.md`.
   - Record commands run, validation outcomes, commit SHAs, push result, any
     intentional marker-scan hits, and residual risks.

## Boundaries

Allowed:

- regenerate package docs with roxygen
- add generated `man/` files for the new Goal 013 exports
- adjust roxygen comments in `R/teaching_api.R` only if required for correct
  generated help pages
- update `NAMESPACE` only through roxygen or equivalent generated-doc hygiene
- commit the already accepted Goals 010-013 work and this Goal 014 record
- push `main` after validation

Do not:

- implement Shiny UI
- add Shiny dependencies
- edit deployment/service files on `deep-server`
- change model-engine behaviour
- edit scenario YAML files
- redesign assessment content beyond publication hygiene
- rewrite accepted teaching docs except to remove a publication blocker
- commit generated build/check artifacts
- rebase, reset, force-push, or discard existing work

## Validation

Minimum required validation:

```sh
Rscript -e 'source("bootstrap.R"); roxygen2::roxygenise()'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R")'
Rscript -e 'source("bootstrap.R"); testthat::test_local()'
Rscript -e 'source("bootstrap.R"); renv::status()'
git diff --check
rg -n "TODO|TBD|PLACEHOLDER" R tests man docs/goals/010-woodhen-at1-assessment-redesign docs/goals/011-practical-1-shiny-design-spike docs/goals/012-deep-server-shiny-platform-feasibility docs/goals/013-practical-1-teaching-api-adapter docs/goals/014-publication-hygiene-and-clean-push docs/teaching
find docs/teaching/intake-2026-06-02-legacy-assessment-materials -type f -size +25M -print
rg -n --pcre2 "[A-Z][a-z]+ [A-Z][a-z]+|student id|student number|email|@|\\b[0-9]{6,}\\b" docs/teaching/intake-2026-06-02-legacy-assessment-materials docs/teaching/woodhen docs/teaching/shiny
```

Package build/check:

```sh
check_root=$(mktemp -d)
R CMD build --no-manual --no-build-vignettes --resave-data=no .
pkg_tar=$(ls -t rPVA_*.tar.gz | head -1)
mv "$pkg_tar" "$check_root"/
R CMD check --no-manual --no-build-vignettes "$check_root/$(basename "$pkg_tar")"
mv rPVA.Rcheck "$check_root"/
echo "Package check artifacts moved to $check_root"
```

If a validation command needs adjustment for the local R tooling, use the
closest equivalent and explain it in `Log.md`.

## Report Back

Report:

- validation commands and outcomes
- generated `man/` files
- staged/committed file groups
- commit subjects and SHAs
- push result
- final `git status --short --branch`
- any intentional marker or identifier-scan hits
- residual risks and recommended next goal
