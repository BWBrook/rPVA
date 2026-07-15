# Practical 1 Task 4 execution report

Date: 2026-07-15

## Base and head

- Base: `9e1a2c4115f9f45162f7ff5a5d774907bd81bc98`
- Implementation head: `8608562c7c9b661e5ae41b13e44619fa85eefbb6`
- Implementation commit: `Make Practical 1 session recovery explicit`

Review repair:

- Repair base: `3b66157d5cb7fd2621a20ff8da455275c334ad1e`
- Repair head: `1cef909` (`Recover failed Practical 1 baseline runs`)

## Changed files

- `inst/shiny/practical1/app.R`
- `inst/shiny/practical1/www/practical1.js`
- `tests/testthat/test-13_practical1_shiny.R`

Task 5 selection/history separation, Practical 2 files, `progress.md`, raw
data, dependencies, and lockfiles were not changed.

## RED evidence

Added the failed-run, confirmation-gated reset, and static recovery contract
tests before implementation. Ran:

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
```

The new tests failed as intended: the failed-run case reached the bounded
executor error and then found no `run_error`; the reset case observed history
cleared before confirmation; and the static contract reported the missing
`practical1.js` file. The testthat command reported five new failures/errors in
the RED run.

## GREEN evidence

After implementation, the same focused command was run twice. Both runs
reported:

```text
13_practical1_shiny: ...
══ DONE ════════════════════════════════════════════════════════════════════════
```

The tests cover failed-run history/progress non-mutation, reset confirmation
and clearing, three exact session notices, the JavaScript include and busy/idle
hooks, the alert error contract, and the successful completion state.

## Exact verification

- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'` — passed twice.
- `Rscript -e 'parse(file = "inst/shiny/practical1/app.R"); cat("app.R parse OK\\n")'` — `app.R parse OK`.
- `node --check inst/shiny/practical1/www/practical1.js` — passed.
- `git diff --check` — passed.
- Confirmed no diff or untracked change under `renv`, `renv.lock`, `.Rprofile`, or `.Rproj.user`.
- Confirmed only the three owned implementation files were staged for the implementation commit.

## Concerns

`bootstrap.R` consistently reports the pre-existing environment mismatch:
`pak` is installed and used but not recorded by renv. Bootstrap also rewrites
whitespace in tracked `renv/activate.R`; that generated change was restored to
the exact base content after each run and is absent from the implementation
commit. The full repository test suite and browser acceptance were not run in
this scoped Task 4 pass.

## Review repair

The repair wraps baseline execution through the injected `execute_stage` in
the same guarded pattern as mission runs. A failed baseline now reports an
inline error without changing baseline/current run, history, run ID, progress,
or completion state. A successful baseline rerun clears stale error and
completion-cue state before resetting the session to baseline run 1.

Added behavioral coverage for failed baseline non-mutation, successful
baseline rerun cleanup, rendered completion-cue mission/next-Core text and
stable `data-run-id`, plus reset run ID/baseline assertions and the
interpretation-clear contract.

The repair RED run used:

```bash
Rscript -e 'pkgload::load_all("."); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
```

It reported four expected failures/errors: baseline failure propagated with no
`run_error`, and successful baseline rerun retained stale error/completion
state. The completion-cue test passed against the existing renderer.

The final focused suite was run twice with `pkgload::load_all(".")`. Both runs
passed; the second reported `test_blocks=35` for the 35 `test_that` blocks in
`test-13_practical1_shiny.R`.

Final repair verification also passed:

- `Rscript -e 'parse(file = "inst/shiny/practical1/app.R"); cat("app.R parse OK\\n")'`.
- `node --check inst/shiny/practical1/www/practical1.js`.
- `git diff --check`.
- No diff or untracked change under `renv`, `renv.lock`, `.Rprofile`, or `.Rproj.user`.

The repair changed only `inst/shiny/practical1/app.R` and
`tests/testthat/test-13_practical1_shiny.R`; the existing JavaScript was not
changed. The pre-existing pak/renv mismatch remains as documented above.
