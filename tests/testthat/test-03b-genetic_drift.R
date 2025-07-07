context("Checkpoint 3b – genetic drift increases F")

spec <- read_spec(system.file("extdata", "woodhen_test.yaml",
                              package = "woodhenPVA"))
spec$env_sd <- 0
spec$demo_sd <- FALSE
spec$years <- 30; spec$reps <- 1
spec$release_vec <- spec$removal_vec <- 0
out <- run_pva_core(spec, keep_traj = TRUE)

test_that("F monotonically increases without rescue", {
  expect_equal(out$F_traj, sort(out$F_traj))
})
