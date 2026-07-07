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

### Report scaffold says repo root is missing

The scaffold now searches upward for `bootstrap.R` and `DESCRIPTION`, but this
still fails if the working directory is outside the repository.

- Check `getwd()` and, if needed, `setwd("/Users/bwbrook/git/rPVA")`.
- Render using an absolute path from that root:

```sh
RPVA_DECISION_LENS="classroom validation" \
RPVA_SELECTED_SCENARIO_ID="02_pig_control" \
RPVA_CHOSEN_SENSITIVITY_ID="K_350" \
RPVA_SENSITIVITY_REASON="Habitat recovery may be incomplete." \
RPVA_EXPECTED_DIRECTION="A lower habitat ceiling should reduce final abundance." \
RPVA_ADVICE_CHANGE_CONDITION="Advice would change if lower habitat capacity sharply reduced recovery confidence." \
quarto render docs/teaching/woodhen/report-scaffold.qmd --to docx --output-dir /tmp/rpva-teaching-report
```

If the error says `Complete the student choice fields before rendering`, fill
the scaffold's decision lens, selected scenario, chosen sensitivity, reason,
expected direction, and advice-change condition before rendering.

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
- Keep management actions in place unless discussing a specific “what-if” with
  written justification.
- Keep `years`, `n0`, `reps`, and stage lengths fixed in the same run as a
  sensitivity exercise.

## Practical 1 Shiny fallback

### The app is unavailable or too slow

Use `practical-1-fallback-pack.md` and keep the class session focused on
interpretation. The fallback keeps the same teaching target by using
`run_toy_demo()`, expected output tables, and report-scaffold rendering.

### Evidence downloads fail

Ask the student to retry the Compare-screen downloads once. If the CSV or
Markdown file is still missing, continue with the fallback pack and ask the
student to save the visible comparison table or command-line toy summary as
evidence.

### Students read the export as the answer

Use this wording:

*The export records what you ran and what the model returned. It supports your
interpretation; your report still needs to explain the ecological mechanism
and the uncertainty.*
