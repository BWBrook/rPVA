# Runbook

## Source Material

Use the current Practical 1 landing copy plus repo-local teaching notes:

- `docs/teaching/intake-2026-06-02-legacy-assessment-materials/1_rPVA_overview.md`
- `docs/teaching/woodhen/practical-1-pva-foundations.md`
- `docs/teaching/shiny/practical-1-design-brief.md`
- `inst/shiny/practical1/app.R`

## Validation Commands

```sh
git diff --check
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
```

Browser smoke should prove:

1. landing screen is visible;
2. `Explore PVA` opens the deep-dive;
3. the close action works;
4. `Start baseline` moves to Concept Lab with baseline as run 1;
5. `Introduction` returns to Start;
6. Compare/export remains reachable after at least one non-baseline run.

Run marker and strict secret/private-key/token/student-identifier scans over
changed and untracked text. Generated image binaries are not involved in this
goal.
