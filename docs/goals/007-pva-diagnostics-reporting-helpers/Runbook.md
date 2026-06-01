# Runbook

## Required First Commands

```sh
git status --short --branch --ignored=matching
git diff --check
Rscript -e 'source("bootstrap.R"); print(renv::status(sources = FALSE))'
```

Stop if tracked package source files under `R/`, `tests/`, `DESCRIPTION`,
`NAMESPACE`, or `inst/extdata/` are already dirty before starting.

Expected pre-existing dirty state includes management/teaching artefacts from
Goals 004-007 and the `.gitignore` change from Goal 006.

## Read-First Commands

```sh
sed -n '1,140p' R/run_pva_core.R
sed -n '180,270p' R/run_pva_core_helpers.R
sed -n '1,130p' R/run_scenarios.R
sed -n '1,120p' tests/testthat/test-00_contracts.R
sed -n '1,150p' docs/teaching/woodhen/practical-2-woodhen-management.md
sed -n '1,140p' docs/teaching/woodhen/report-scaffold.qmd
```

## Implementation Notes

Preferred helper file:

```text
R/pva_helpers.R
```

Preferred test file:

```text
tests/testthat/test-11_pva_helpers.R
```

Preferred exported functions:

```text
summarize_pva_result
compare_pva_results
diagnose_pva_result
```

Use roxygen comments if consistent with the surrounding code, but update
`NAMESPACE` manually if roxygen tooling is not available.

## Behaviour Details

`summarize_pva_result()` should use:

- `out$params$name` for scenario label when present
- `out$params$years` for final horizon when present
- `out$params$reps` or `length(out$Nend)` for replicate count
- `out$Nend_summary` for abundance interval
- `out$ext_prob[horizon + 1]` when `out$ext_prob` is available
- `mean(out$Nend == 0)` for final PE when `out$ext_prob` is unavailable

`compare_pva_results()` should call `summarize_pva_result()` and preserve order.

`diagnose_pva_result()` should build deterministic rows with stable `code`
values. Suggested codes:

```text
high_extinction_probability
low_median_final_abundance
wide_final_abundance_interval
no_trajectory_data
zero_observed_extinction
```

## Validation Commands

```sh
git diff --check
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-11_pva_helpers.R")'
Rscript -e 'source("bootstrap.R"); spec <- set_scenario("02_pig_control", "woodhen"); out <- run_pva_core(spec, keep_traj = TRUE, seed = 123, verbose = FALSE); print(summarize_pva_result(out)); print(diagnose_pva_result(out))'
git status --short --branch --ignored=matching
```

If a command fails because of missing tooling, record the exact error and run
the nearest focused substitute. Do not install new dependencies for this goal.

## Final Response Shape

Include:

- model/effort used
- whether formal goal mode appeared or behavioural delegation only
- helper functions added
- files changed
- validation outcomes
- residual risks
- final git status
