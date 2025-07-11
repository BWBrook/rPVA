# Woodhen PVA

This repository houses **woodhenPVA**, an internal R package used in the  
UTAS unit KPZ308 to replace the old VORTEX based practical. The goal is a  
cross-platform, fully reproducible population viability analysis (PVA)  
tool for the Lord Howe Island woodhen case study.  

The Lord Howe Island woodhen (*Hypotaenidia sylvestris*) is a unique and  
iconic flightless rail endemic to Lord Howe Island, an eroded volcanic  
remnant roughly 11 km long and 2.8 km wide, located 630 km off the east  
coast of Australia. The woodhen declined precipitously in numbers following  
the introduction of pigs in the early 1800s, and later European settlement.  
The pigs destroyed large areas of natural vegetation, and preyed directly  
upon the birdlife. The woodhen was also over-exploited by the human settlers  
as a subsidiary source of food. Only 19 years after first settlement, the  
woodhen was already noted as being rare, and by the early 1970s, less than  
ten breeding pairs remained, restricted to the summits of island’s two  
highest peaks. It was critically endangered, listed among the world’s most  
threatened birds, and appeared to be on the brink of extinction. Bold and  
risky actions were needed.

In the early 1980s, a recovery program was launched, involving a captive  
breeding scheme based at a purpose-built facility on the island, in  
combination with the island-wide eradication of the feral pigs. The last four  
known breeding pairs were taken to a captive breeding centre located on the  
island, whilst the feral pigs were eliminated through culling. This proved  
highly successful, the release of ~80 captive bred birds occurred, the woodhen  
population recovered to numbers that stabilised at over 150 breeding pairs.  
Following the recovery programme, rodents were eradicated from the island in  
2019, and the woodhen numbers thereafter exploded to over 1600 birds (as of  
2024). As such, it is held up as a flagship of a conservation success story. 

In this exercise, we will use a PVA model written in R  to simulate the various  
recovery options that were available to the managers on Lord Howe Island in  
1980, to determine ‘retrospectively’ the most effective strategy given limited  
resources. We will then explore the a range of potential threats the apparently  
'secure' woodhen population may face in the future, and determine its prospects  
for long-term persistence. Basic input data will be supplied, but part of the  
exercise is for you to experiement with various scenarios/permutations, by  
changing the input values or adding new processes to the PVA model. 

The code currently implements:

* an age-structured stochastic simulation engine (`run_pva_core()`)
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
   library(woodhenPVA)                        # or devtools::load_all()
   spec <- read_spec(system.file("extdata", "woodhen_no_mgmt.yaml",
                                package = "woodhenPVA"))
   out  <- run_pva_core(spec, keep_traj = TRUE)
   plot_pva_traj(out)                         # basic plots
   ```
   or
      ```r
      library(woodhenPVA)                        # or devtools::load_all()
      run_scenarios(csv_out = NULL)              # returns a tidy data.frame
   ```

All functions can be called interactively as above.

## Repository structure

```
R/                   # PVA engine and helpers
inst/extdata/        # YAML scenario files
man/                 # function documentation
renv/                # renv bootstrap and lock file
tests/testthat/      # unit tests (students can ignore this)
```

## 👾 Toy-model warm-up (recommended first stop)

Before diving into the Lord Howe Island woodhen, spend five minutes with the
built-in **toy species**.  
This three-stage model is stripped to the essentials and lets you see—one layer
at a time—how *K*, demographic noise, environmental noise and inbreeding
depression alter population trajectories.

```r
# 1  Open the project or install & attach the package, then:

pkgload::load_all(".")          # or devtools::load_all(".")

# 2  Run the helper that generates five preset scenarios
toy <- run_toy_demo()        # returns $results and a summary table
toy$summary                  # extinction probabilities & median N

# ── Step-wise exploration ────────────────────────────────────────────────

## (a) Deterministic growth
plot_pva_summary(toy$results$det)

## (b) Add K = 250 ceiling
plot_pva_summary(toy$results$ceiling)

## (c) + Demographic stochasticity (10 replicates)
plot_pva_traj(toy$results$demo_sd, sample = 10)
plot_pva_summary(toy$results$demo_sd)

## (d) + Environmental σ_env = 0.30
plot_pva_traj(toy$results$env_sd,  sample = 10)
plot_pva_summary(toy$results$env_sd)
plot_ext(toy$results$env_sd)          # extinction curve + mean F/SR

## (e) + Genetics module on
plot_pva_traj(toy$results$genetics, sample = 10)
plot_pva_summary(toy$results$genetics)
plot_ext(toy$results$genetics)
```
What to watch for:
Step a: Classic exponential curve (λ ≈ 1.07).  
Step b: Population hits the ceiling, then flattens.  
Step c: Trajectories diverge—chance leads or lags.  
Step d: Fan widens; some replicates dip below K.  
Step e: Yellow dashed line (median T<sub>E</sub>) appears earlier; mean  
inbreeding F steadily climbs.  

Once you are comfortable interpreting these plots and the $summary table,  
move on to the full woodhen case study with:

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
| `toy$summary` | Quick numeric comparison (Pe, median N) shown right in the console. |
| `plot_*` calls | Visualise each stage so students see cause → effect. |
| `set_scenario()` | Bridges to the “real” woodhen YAML scenarios. |

This section keeps the main README tight, yet gives every user—especially
students—a low-stakes playground to build intuition before tackling the
full-featured woodhen analyses.


The project is released under the MIT license (see `LICENSE.md`).
