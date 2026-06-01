# Practical 1: PVA Foundations with the Toy Model

## Aim

Build core understanding of population viability analysis before touching real
Woodhen scenarios.

## Learning outcomes

- Run a complete toy PVA workflow and read the outputs.
- Explain what changes when density regulation, demographic stochasticity,
  environmental stochasticity, and genetics are added.
- Interpret `PE` and `Nmed` without confusion over missing trajectories.

## Time allocation (3 hours)

1. Orientation and setup (20 min)
2. Mechanism-by-mechanism runs (95 min)
3. Comparative interpretation (40 min)
4. Reporting draft responses (45 min)

## Setup

At the start of your session:

```r
source("bootstrap.R")
```

Expected message: environment ready and package loaded.

## Part A — one clean baseline run

Run the five toy scenarios in one call. Keep trajectory objects for plotting.

```r
toy <- run_toy_demo(
  keep_traj = TRUE,
  plot_matrix = TRUE,
  verbose = FALSE
)
```

`run_toy_demo()` returns:

- `toy$results`: named list of outputs for each mechanism.
- `toy$summary`: short table with `scenario`, `PE`, `N_med`.

```r
toy$summary
```

Expected observations:

- `det` and `ceiling` have deterministic outcomes in this seed setup.
- In this reference run, the only non-zero extinction risk in the toy set is for
  `genetics`.

## Part B — mechanism checkpoints (plot-and-interpret sequence)

The first two scenarios use the baseline and the carrying capacity (density) cap.

```r
plot_pva_summary(toy$results$det)
plot_pva_summary(toy$results$ceiling)
```

Checkpoint 1:

- What happens to median total abundance when `K` is enforced?
- Why do trajectories become bounded?

Now inspect demography and environment.

```r
plot_pva_traj(toy$results$demographic_stochasticity, sample = 20)
plot_pva_summary(toy$results$demographic_stochasticity)
plot_pva_traj(toy$results$env_sd, sample = 20)
plot_pva_summary(toy$results$env_sd)
plot_ext(toy$results$env_sd)
```

Checkpoint 2:

- Why does `env_sd` produce a wider prediction range than deterministic+K alone?
- Where is uncertainty coming from?

Finally inspect the genetics case.

```r
plot_pva_traj(toy$results$genetics, sample = 20)
plot_pva_summary(toy$results$genetics)
plot_ext(toy$results$genetics)
```

Checkpoint 3:

- In what way do extinction and inbreeding indicators move together (not always perfectly)?
- What would `plot_ext()` be missing if `keep_traj = FALSE`?

## Part C — data checks students must run (and why)

1) Confirm the `PE` index is taken from the final year.

```r
toy$summary$PE
```

2) Confirm total population for final year.

```r
toy$results$genetics$Nend_summary
```

3) Check if students are using the seeded run consistently.

```r
run_toy_demo(keep_traj = FALSE, plot_matrix = FALSE, verbose = FALSE)$summary
```

## Part D — short report responses

Answer these in your practical notebook:

- What is the ecological meaning of density regulation in this toy example?
- Which mechanism most strongly increases uncertainty in later years?
- How would management recommendations differ if you only looked at deterministic output?

## Submission-ready checkpoint

Each group must include in their log:

- the command log,
- one trajectory plot,
- one summary plot,
- one extinction curve,
- their three checkpoint answers.
