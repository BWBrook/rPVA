# Woodhen PVA

This repository houses **woodhenPVA**, an internal R package used in the UTAS
unit KPZ308 to replace the old VORTEX based practical.  The goal is a
cross&#8209;platform, fully reproducible population viability analysis (PVA) tool
for the Lord Howe Island woodhen case study.

The code currently implements:

* a stage&#8209;structured stochastic simulation engine (`run_pva_core()`)
* optional carrying&#8209;capacity ceiling via `apply_ceiling_K()`
* convenience helpers to read YAML scenario files (`read_spec()`)
* plotting functions for trajectories and summaries (`plot_pva_*`)

Catastrophes and release supplementation are planned but not yet in the code
base.

## Getting started

1. **Clone the repository** and open the `woodhenPVA.Rproj` in RStudio (or start
   an R session in this directory).
2. **Restore the package environment**.  The project uses
   [renv](https://rstudio.github.io/renv/) for reproducible dependencies.  In a
   fresh R session run:

   ```r
   install.packages("renv")       # only needed once
   renv::restore()                # installs the locked package versions
   ```

   This step may take a few minutes the first time.
3. **Load the package and run a scenario**:

   ```r
   devtools::load_all()                                       # or library(woodhenPVA)
   spec <- read_spec(system.file("extdata", "woodhen_no_mgmt.yaml",
                                package = "woodhenPVA"))
   out  <- run_pva_core(spec, keep_traj = TRUE)
   plot_pva_traj(out)                                         # basic plots
   ```

4. **Run the tests** (optional):

   ```r
   testthat::test_dir("tests/testthat")
   ```

A `targets` workflow will be added later for larger scenario batches.  For now
all functions can be called interactively as above.

## Repository structure

```
R/                   # PVA engine and helpers
inst/extdata/        # YAML scenario files
man/                 # function documentation
renv/                # renv bootstrap and lock file
tests/testthat/      # unit tests
```

The project is released under the MIT license (see `LICENSE.md`).
