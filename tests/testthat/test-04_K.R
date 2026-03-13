context("Checkpoint 4 – carrying capacity ceiling (floaters exempt)")

spec_K <- read_test_spec()
spec_K$env_sd  <- 0
spec_K$demo_sd <- FALSE
spec_K$years   <- 1
spec_K$reps    <- 1
spec_K$K       <- 50
spec_K$K_sd    <- 0
spec_K$n0[]    <- 60   # all stages start at 60

out1 <- run_pva_core(spec_K, keep_traj = TRUE)
spec_noK <- spec_K
spec_noK$K <- 1e6
out1_noK <- run_pva_core(spec_noK, keep_traj = TRUE)

test_that("ceiling scales holders down exactly to K in first step", {
  # sum only stages 2..n at t = 1 should equal K
  holders <- out1$traj[2, -1, 1]
  expect_equal(sum(holders), spec_K$K)
})

test_that("floaters (stage 1) are not counted in K", {
  expect_equal(out1$traj[2, 1, 1], out1_noK$traj[2, 1, 1])
})

test_that("holders never exceed K over multiple years", {
  spec_K$years <- 40
  out40 <- run_pva_core(spec_K, keep_traj = TRUE)
  # for each year, sum of stages 2..n ≤ K
  holder_totals <- apply(out40$traj[-1, -1, 1, drop = FALSE], 1, sum)
  expect_true(all(holder_totals <= spec_K$K))
})
