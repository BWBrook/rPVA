context("Checkpoint 3c – immigration lowers F")

spec_r <- read_spec(system.file("extdata", "woodhen_test.yaml", package = "rPVA"))
spec_r$env_sd <- 0
spec_r$demo_sd <- FALSE
spec_r$years  <- 10; spec_r$reps <- 1
spec_r$release_years <- 5
spec_r$release_vec   <- c(0,0,10,0,0,0,0)

out_rescue <- run_pva_core(spec_r, keep_traj = TRUE)

test_that("F drops in release year", {
  expect_lt(out_rescue$F_traj[6], out_rescue$F_traj[5])
})
