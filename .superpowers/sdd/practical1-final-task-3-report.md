# Practical 1 Final Task 3 Execution Report

Date: 2026-07-15
Task: Build the grouped mission rail and accurate soft progress

## Commits

- Base commit: `c4cb7cd960c244075b8ced940fcea957d25f635a`
- Head implementation commit: `dd07758` (`Guide Practical 1 through Core missions`)

## Changed files

- `inst/shiny/practical1/app.R`
- `tests/testthat/test-13_practical1_shiny.R`

The report is the only additional requested artefact and is kept separate from
the implementation commit so the implementation commit retains the brief's
exact message.

## Implementation notes

- Sourced the existing `session_helpers.R` module and adopted its approved Core,
  Explore Further, completion, and session-run-ID rules.
- Replaced the static stage selector rail with grouped, clickable Core and
  Explore Further mission links, status labels, and soft current/completed
  states.
- Added `make_practical1_server(execute_stage = run_stage)` with explicit
  display-only baseline state, `selected_stage`, `baseline_started`, empty
  initial history, and monotonic session run IDs.
- Made Start baseline create session run 1 and mark baseline progress only after
  the action succeeds. Kept retained controls, help, diagnostics, plots,
  downloads, substantive teaching text, defaults, and seed 42 unchanged; the
  intentional mission-label updates and `Run mission` label change are excluded
  from that statement.
- Updated only the stale Task 3 selector/initial-state tests and added the
  specified `testServer()` baseline contract.

## RED evidence

After adding the Task 3 contracts and before changing `app.R`, the focused test
command exited non-zero. Failures identified the missing helper source/state,
grouped rail links, server factory, explicit baseline state, and deleted stage
selector contract. This confirmed the new tests were exercising absent Task 3
behaviour rather than passing against the old implementation.

## GREEN and final verification

Command run twice after implementation:

```text
Rscript -e 'pkgload::load_all(".", quiet = TRUE); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
```

Result: exit 0; all 28 tests in `test-13_practical1_shiny.R` completed with no
failures or errors.

Additional checks:

- `Rscript --vanilla -e 'parse(file = "inst/shiny/practical1/app.R")'`: passed.
- `git diff --check`: passed before commit.
- `renv/activate.R`: restored after the documented R startup whitespace drift;
  no renv diff remained before commit.
- Commit scope was verified: the implementation commit contains only
  `app.R` and `test-13_practical1_shiny.R`.

## Concerns and caveats

- The test command reports the known renv pak inconsistency warning, but did not
  require changing `renv.lock` or any environment files.
- Browser viewport acceptance, Practical 2 checks, and later Task 4 recovery
  behaviour were not part of this Task 3 scope.
