# rPVA

Open-source, cross-platform, and fully reproducible population viability analysis (PVA) toolkit for R.  
Designed for rapid scenario-building, robust teaching, and defensible conservation decision-making.

## Features

- **Stochastic, age-structured PVA engine** (`run_pva_core`): Leslie/Lefkovitch, any stage structure
- **Demographic and environmental stochasticity**: binomial/Poisson, lognormal/Beta noise
- **Catastrophe module**: rare-event survival and reproduction shocks
- **Density regulation**: carrying-capacity ceiling (with floaters exempt)
- **Genetics module**: inbreeding depression, purging, genetic drift, immigration rescue
- **Management actions**: removals (harvest/capture), release supplementation, scheduled interventions
- **Batch scenario execution**: parallel runs, YAML-driven configuration (`run_scenarios`)
- **Flexible scenario specification**: modular YAMLs, fully documented and version-controlled
- **Pedagogical ramp**: toy-model walk-through, testable and modifiable at every stage
- **Extensive plotting**: trajectories, summaries, extinction curves, matrix diagnostics
- **Comprehensive test suite**: function- and scenario-level tests

## Getting started

1. **Clone the repository** and open `rPVA.Rproj` in RStudio, or launch an R session in this directory.
2. **Quick setup**: *Source the bootstrap script* (recommended for new users). In the project root:
   ```r
   source("bootstrap.R")
   ```
   This will install/restore all dependencies (`renv`), and load the package for immediate use.
3. **Manual setup** (alternative):
   ```r
   install.packages("renv")   # only needed once
   renv::restore()            # restores locked package versions
   pkgload::load_all(".")
   ```
   Optional: install `ggrastr` only if you want rasterized trajectory plotting on large Monte Carlo runs.
   The default package restore no longer requires `ggrastr` or `Cairo`.
4. **Run a scenario or demo**: Try the toy-model walk-through to verify core features:
   ```r
   toy <- run_toy_demo(keep_traj = TRUE, plot_matrix = TRUE, verbose = FALSE)
   toy$summary
   plot_pva_summary(toy$results$det)
   ```
   Or batch-run all scenarios for a case study (e.g. woodhen):
   ```r
   run_scenarios("woodhen", csv_out = NULL, rds_out = NULL, keep_traj = FALSE)
   ```
All functions can be called interactively, scripted, or batch-run.  
See case-specific folders in `inst/extdata/` for scenario YAMLs and runnable scripts.

## Optional plotting extras

- `plot_pva_traj(..., raster = TRUE)` uses `ggrastr` when installed.
- On Homebrew R for macOS, source installs of `ggrastr` may also need `pkgconf` so `Cairo` can discover the local graphics libraries.
- This plotting stack is optional; core modelling, tests, and teaching workflows do not require it.

## Repository structure

```
R/                      # PVA engine and helper functions
inst/extdata/           # Case-study folders (YAML + scripts per species/system)
  woodhen/
  thylacine/
  toy/
inst/testdata/          # YAML files used exclusively for testthat unit/integration tests
man/                    # Function documentation (roxygen2, .Rd)
renv/                   # renv bootstrap and lock file for reproducible environments
tests/testthat/         # Unit and integration tests
bootstrap.R             # Turnkey setup script
```

*For folder-level detail, see README.md in each subdirectory.*

## 👾 Toy-model warm-up (recommended first stop)

This three-stage model is stripped to the essentials and lets you see, one layer at a time,  
how *K*, demographic noise, environmental noise and inbreeding depression alter population  
trajectories.

   ```r
   # 1  Open the project or install & attach the package, then:

   pkgload::load_all(".")

   # 2  Run the helper that generates five preset scenarios
   toy <- run_toy_demo(keep_traj = TRUE, plot_matrix = TRUE, verbose = FALSE)
                            # returns $results and a summary table
   toy$summary               # extinction probabilities & median N

   # ── Step-wise exploration ─────────────────────────────────────

   ## (a) Deterministic growth
   plot_pva_summary(toy$results$det)

   ## (b) Add K = 250 ceiling
   plot_pva_summary(toy$results$ceiling)

   ## (c) + Demographic stochasticity (10 replicates)
   plot_pva_traj(toy$results$demographic_stochasticity, sample = 10)
   plot_pva_summary(toy$results$demographic_stochasticity)

   ## (d) + Environmental σ_env = 0.30
   plot_pva_traj(toy$results$env_sd,  sample = 10)
   plot_pva_summary(toy$results$env_sd)
   plot_ext(toy$results$env_sd)      # extinction curve + mean F/SR

   ## (e) + Genetics module on
   plot_pva_traj(toy$results$genetics, sample = 10)
   plot_pva_summary(toy$results$genetics)
   plot_ext(toy$results$genetics)
   ```
What to watch for:  
Step a: Classic exponential curve (λ ~ 1.07).  
Step b: Population hits the ceiling, then flattens.  
Step c: Trajectories diverge: chance leads or lags.  
Step d: Fan widens; some replicates dip below K.  
Step e: Yellow dashed line (median T<sub>E</sub>) appears earlier; mean  
inbreeding F steadily climbs.  

Once you are comfortable interpreting these plots and the $summary table,  
move on to the full case study, such as the Lord Howe Island woodhen, with:

   ```r
   spec <- set_scenario("01_no_mgmt")     # or any 01–06 scenario
   out  <- run_pva_core(spec, keep_traj = TRUE)
   plot_pva_panel(
   plot_pva_traj(out, sample = 250),
   plot_pva_summary(out),
   plot_ext(out)
   )
   ```

Happy modelling!


*Explanation of pieces*

| File/function | Purpose in the README snippet |
|---------------|-------------------------------|
| `run_toy_demo()` | Generates the five incremental scenarios (det → genetics) in one call. |
| `toy$summary` | Quick numeric comparison (PE, median N) shown right in the console. |
| `plot_*` calls | Visualise each stage so students see cause → effect. |
| `set_scenario()` | Bridges to the “real” YAML scenarios. |

This section keeps the main README tight, yet gives every user—especially students: a low-stakes  
playground to build intuition before tackling full-featured analyses.


The project is released under the MIT license (see `LICENSE.md`).
