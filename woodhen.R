# woodhen.R

devtools::load_all()

spec <- read_spec(system.file("extdata", "woodhen_no_mgmt.yaml", package="woodhenPVA"))
plot_pva_matrix(spec) # returns patchwork composite or a list

# Run stochastic scenario
sim  <- run_pva_core(spec, keep_traj = TRUE, verbose = TRUE, seed = 1234)
p1 <- plot_pva_traj(sim, sample = 250)
p2 <- plot_pva_summary(sim)
p3 <- plot_ext(sim)
panel <- plot_pva_panel(p1, p2, p3)
sim[1:5] # show core results data
