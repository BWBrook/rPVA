# Plan

## 1. Confirm State

- Check git status and diff hygiene.
- Confirm no tracked package source files are dirty before Goal 007 starts.
- Record starting state in `Log.md`.

## 2. Inspect Existing Contracts

- Read `run_pva_core()` and helper result contracts.
- Read `run_scenarios()` summary-table logic.
- Read existing public-contract tests.
- Decide the narrowest helper implementation that avoids changing engine
  behaviour.

## 3. Add Tests

- Add focused tests for:
  - one-result summary with trajectories
  - one-result summary without trajectories
  - horizon-specific error when `keep_traj = FALSE`
  - comparison of named and unnamed result lists
  - diagnostics codes for low abundance, high PE, wide interval, missing
    trajectories, and zero observed extinctions

## 4. Implement Helpers

- Create one focused R file for the public helpers.
- Use base R data frames and existing result fields.
- Avoid new dependencies.
- Export the public helpers via `NAMESPACE`.

## 5. Integrate With Teaching Docs

- Update Practical 2 with a short helper-based comparison/diagnostics snippet.
- Update `report-scaffold.qmd` to use helper functions instead of a duplicated
  local summarise function.
- Keep edits targeted.

## 6. Validate

- Run `git diff --check`.
- Run focused helper tests.
- Run one Woodhen smoke command that prints summary and diagnostics.
- Confirm changed-file scope.

## 7. Finalize

- Update `Log.md` with commands, outcomes, residual risks, and final git state.
- Report model/effort settings and whether formal goal mode appeared.
