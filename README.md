# Woodhen PVA

This repository houses **woodhenPVA**, an internal R package used in the UTAS unit KPZ308 to replace the old VORTEX based practical.  
The goal is a cross-platform, fully reproducible population viability analysis (PVA) tool for the Lord Howe Island woodhen case study.  

The Lord Howe Island woodhen (*Hypotaenidia sylvestris*) is a unique and iconic flightless rail endemic to Lord Howe Island, an eroded volcanic remnant roughly 11 km long and 2.8 km wide, located 630 km off the east coast of Australia. The woodhen declined precipitously in numbers following the introduction of pigs in the early 1800s, and later European settlement. The pigs destroyed large areas of natural vegetation, and preyed directly upon the birdlife. The woodhen was also over-exploited by the human settlers as a subsidiary source of food. Only 19 years after first settlement, the woodhen was already noted as being rare, and by the early 1970s, less than ten breeding pairs remained, restricted to the summits of island’s two highest peaks. It was critically endangered, listed among the world’s most threatened birds, and appeared to be on the brink of extinction. Bold and risky actions were needed.

In the early 1980s, a recovery program was launched, involving a captive breeding scheme based at a purpose-built facility on the island, in combination with the island-wide eradication of the feral pigs. The last three known breeding pairs were taken to a captive breeding centre located on the island, whilst the feral pigs were eliminated through culling. This proved highly successful, the release of ~80 captive bred birds occurred, the woodhen population recovered to numbers that stabilised at over 150 breeding pairs. Following the recovery programme, its IUCN status was downgraded from endangered to vulnerable. As such, it is held up as a flagship of a conservation success story.

In this exercise, we will use a PVA model written in R  to simulate the various recovery options that were available to the managers on Lord Howe Island in 1980, to determine ‘retrospectively’ the most effective strategy given limited resources. We will then explore the a range of potential threats the apparently 'secure' woodhen population may face in the future, and determine its prospects for long-term persistence. Basic input data will be supplied, but part of the exercise is for you to experiement with various scenarios/permutations, by changing the input values or adding new processes to the PVA model.

The code currently implements:

* a stage-structured stochastic simulation engine (`run_pva_core()`)
* optional carrying-capacity ceiling via `apply_ceiling_K()`
* demographic and environmental stochasticity, catastrophes, inbreeding depression
* removals and release supplementation
* convenience helpers to read YAML scenario files (`read_spec()`)
* plotting functions for trajectories and summaries (`plot_pva_*`)

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
