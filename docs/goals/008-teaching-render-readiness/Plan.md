# Plan

## 1. Confirm State

- Check branch, remote sync, ignored files, and recent commits.
- Confirm current `renv.lock` top-level package state for `knitr`,
  `rmarkdown`, and `quarto`.
- Record Quarto CLI version and starting `renv::status()`.

## 2. Identify Render Blocker

- Read the current report scaffold and setup/troubleshooting docs.
- Attempt a narrow baseline render or otherwise inspect enough to confirm
  whether the failure is missing R packages, execution directory handling, or
  a system rendering tool.
- Record the actual failure mode in `Log.md`.

## 3. Synchronize Minimal Dependencies

- Add only required report-render packages to `DESCRIPTION` `Suggests`.
- Install/restore/snapshot with `renv` so `renv.lock` is synchronized.
- Avoid adding the R package `quarto` unless it is truly required; the Quarto
  CLI is the expected render driver.

## 4. Make Scaffold Portable

- Remove the current assumption that the scaffold is always executed with
  `bootstrap.R` in the current working directory.
- Use a portable repo-root discovery or supported Quarto/knitr root-dir setup.
- Keep code chunks clear enough for students to inspect.

## 5. Improve Teaching-Room Guidance

- Add a concise render/setup path to existing teaching docs or one small
  checklist.
- Include common failures: wrong working directory, missing render packages,
  failed bootstrap, and PDF/TeX tool failures.

## 6. Validate

- Render DOCX and PDF into temp output locations where possible.
- Run full local testthat tests after dependency changes.
- Run `renv::status()`, `git diff --check`, and final status.
- Confirm generated outputs are not accidentally left in the worktree.

## 7. Report

- Update `Log.md` with commands, outcomes, changed files, residual risks, final
  status, and whether formal goal mode was active.
- Return a concise final report to the supervisor.
