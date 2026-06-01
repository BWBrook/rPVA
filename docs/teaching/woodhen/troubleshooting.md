# Troubleshooting Guide

## Package and bootstrap issues

### `bootstrap.R` says environment not synchronized

Run:

```r
renv::status(sources = FALSE)
```

If `synchronized = FALSE`, rerun `source("bootstrap.R")` from project root and
rerun the command that failed.

### `source("bootstrap.R")` not found

- Ensure your R working directory is the repo root (`/Users/bwbrook/git/rPVA`).
- Run `getwd()` and `setwd("/Users/bwbrook/git/rPVA")` if needed.

### Report scaffold says repo root cannot be found

The scaffold now searches upward for `bootstrap.R` and `DESCRIPTION`, but this
still fails if the working directory is outside the repository.

- Check `getwd()` and, if needed, `setwd("/Users/bwbrook/git/rPVA")`.
- Render using an absolute path from that root:

```sh
quarto render docs/teaching/woodhen/report-scaffold.qmd --to docx --output-dir /tmp/rpva-teaching-report
```

### `quarto render ...` fails with missing render packages

If the error includes packages like `rmarkdown` or `knitr`, run:

```r
source("bootstrap.R")
renv::status(sources = FALSE)
```

Then rerun the render. If `status()` is not synchronized, exit and reopen R,
then run `source("bootstrap.R")` again.

## Simulation command issues

### Nothing appears in `plot_pva_traj()` or `plot_ext()`

These plots require trajectories.

- Confirm `keep_traj = TRUE` in your upstream `run_pva_core()` call.
- Re-run with:

```r
sim <- run_pva_core(spec, keep_traj = TRUE, seed = 123, verbose = FALSE)
```

### `run_pva_core` output says `N` jumps to zero too often

Check whether one of these changed at once:

- `surv`, `cat_freq`, `cat_surv`, `fecund` in a sensitivity change,
- `K` reduced to a low value,
- `reps` accidentally set very large with unstable parameters.

### `PE = 0` and students think scenario is risk free

Use this wording:

*No extinctions were observed in this replicate horizon, but the uncertainty band may still be wide and ecological uncertainty outside this model remains.*

### “No output from `run_scenarios("woodhen")`”

If no messages or rows appear:

- ensure package is loaded (`pkgload::load_all(".")` or `source("bootstrap.R")`),
- ensure your current R path is inside the repository,
- check that you did not rename scenario filenames.

## Interpretation traps

### Confusing unconditional and conditional summary

`plot_pva_summary()` includes both lines:

- unconditional mean: includes extinct replicates,
- conditional mean: excludes extinct replicates.

The distance between them is an uncertainty clue.

### Treating one run as absolute truth

Single-seed and unseeded runs are stochastic snapshots. For class reproducibility,
fix one seed.

```r
seed <- 123
sim <- run_pva_core(spec, keep_traj = TRUE, seed = seed)
```

### Comparing scenario tables with different `reps`

Keep reporting runs at equal replicate counts unless explicitly exploring
sampling error.

## Scenario editing guardrails for class

- Only change one factor per sensitivity run.
- Do not remove management actions entirely unless discussing a specific
  “what-if” with written justification.
- Do not edit `years`, `n0`, `reps`, or stage lengths in the same run as a
  sensitivity exercise.
