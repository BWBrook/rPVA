# Plan

## 1. Confirm State

- Check branch, remote sync, untracked files, and ignored files.
- Verify that `docs/teaching/woodhen/` is currently ignored.
- Record starting state in `Log.md`.

## 2. Make Teaching Docs Visible

- Update `.gitignore` narrowly so `docs/teaching/` and its descendants are not
  ignored.
- Re-run `git check-ignore` and `git status --ignored=matching`.

## 3. Fix Known Teaching-Kit Issues

- Replace Practical 2's incorrect "20- and 100-year horizons" wording with
  wording that matches the current 40-, 5-, and 75-year Woodhen scenario
  horizons.
- Remove trailing whitespace in `docs/teaching/woodhen/`.

## 4. Validate Report Scaffold

- Inspect `report-scaffold.qmd` for path assumptions.
- If a tiny documentation-only setup edit makes it renderable from a normal
  repo-root workflow, make that edit.
- Run the cheapest appropriate scaffold validation and record the result.

## 5. Final Validation

- Run `git diff --check`.
- Run direct trailing-whitespace scan over `docs/teaching/woodhen/`.
- Confirm only allowed files changed.
- Record final git state.

## 6. Report

- Update `Log.md` with commands, outcomes, artefacts, residual risks, and final
  state.
- Return a concise final summary to the supervisor.
