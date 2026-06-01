# Woodhen Practical Glossary

## Core model terms

`PVA`
Population viability analysis: simulation of future population trajectories to assess persistence risk.

`PE`
Extinction probability at the end of the simulation horizon, computed from final-year extinction status.

`Nmed`
Median final abundance across Monte-Carlo replicates.

`Nlo95`, `Nhi95`
95% quantile bounds for final abundance across replicates.

`K`
Carrying capacity, the upper ecological limit on population size under current
habitat assumptions.

`K_sd`
Environmental variation in carrying capacity.

`env_sd`
Environmental stochasticity in vital rates.

`run_toy_demo`
Convenience function that runs the toy model in incremental mechanism steps.

`run_scenarios`
Batch helper that runs many YAML scenarios and returns a summary table.

`set_scenario`
Loads one named scenario and merges it with defaults.

`run_pva_core`
Runs one scenario with full model machinery.

`keep_traj = TRUE`
Stores replicate trajectories so plots (`plot_pva_traj`, `plot_ext`) are available.

`keep_traj = FALSE`
Faster and smaller output; useful for summary tables.

## Population dynamics terms

`Demographic stochasticity`
Randomness in births and deaths due to chance in individual-level events in finite
populations.

`Environmental stochasticity`
Year-to-year variation in survival and reproduction from changing conditions.

`Density regulation`
Mechanism that reduces growth as population approaches carrying capacity.

`Inbreeding depression`
Fitness reduction associated with reduced genetic diversity and higher homozygosity.

`Extinction trajectory`
Population history of replicate trajectories reaching zero and staying at zero.

`Conditional mean`
Mean population trajectory among non-extinct replicates only (shown in
`plot_pva_summary()`).

`Unconditional mean`
Mean across all replicates including those that have gone extinct.

`Median time to extinction (TE)`
Median simulation year at which extinction is reached in the extinction curve.
