context("Checkpoint 2 – core engine")

spec_det <- read_spec("data/woodhen_no_mgmt.yaml")
spec_det$env_sd  <- 0
spec_det$demo_sd <- 0
spec_det$years   <- 1
spec_det$reps    <- 1

spec_stoch <- spec_det
spec_stoch$env_sd  <- 0.15
spec_stoch$demo_sd <- 0.05
spec_stoch$reps    <- 5   # many reps to show variance

test_that("deterministic projection matches popbio lambda", {
  A <- popbio::leslie.matrix(spec_det$surv, spec_det$fecund)
  lambda_det <- as.numeric(popbio::lambda(A))

  out <- run_pva_core(spec_det, keep_traj = TRUE)
  growth_ratio <- sum(out$traj[2, , 1]) / sum(spec_det$n0)

  expect_equal(growth_ratio, lambda_det, tolerance = 1e-6)
})

test_that("stochastic run varies across reps", {
  out <- run_pva_core(spec_stoch)
  expect_gt(length(unique(out$Nend)), 1)
})
