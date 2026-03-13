# toy_demo.R
pkgload::load_all(".")

# Run all scenarios for the toy model
toy <- run_toy_demo(keep_traj = TRUE, plot_matrix = TRUE, verbose = FALSE)
toy$summary # table of results

# Now let's look at the results in detail!

# 0. Deterministic scenario
plot_pva_summary(toy$results$det)

# 1. Deterministic scenario with ceiling K
plot_pva_summary(toy$results$ceiling)

# 2. Ceiling K with demographic stochasticity
plot_pva_traj(toy$results$demographic_stochasticity, sample = 10)
plot_pva_summary(toy$results$demographic_stochasticity)

# 3. Ceiling K with demographic and environmental stochasticity
plot_pva_traj(toy$results$env_sd, sample = 10)
plot_pva_summary(toy$results$env_sd)
dplyr::glimpse(toy$results$env_sd$params[1:10]) # look at the inputs
toy$results$env_sd[1:3] # look at the numerical output
plot_ext(toy$results$env_sd)

# 4. Ceiling K with demographic and environmental stochasticity and inbreeding
plot_pva_traj(toy$results$genetics, sample = 10)
plot_pva_summary(toy$results$genetics)
plot_ext(toy$results$genetics)

# Equipped With this understanding, you're ready to move on to the woodhen!
