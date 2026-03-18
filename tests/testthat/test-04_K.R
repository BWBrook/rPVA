context("Checkpoint 4 – carrying capacity ceiling (floaters exempt)")

spec_K <- read_spec(system.file("testdata", "test_01.yaml", package = "rPVA"))
spec_K$env_sd  <- 0
spec_K$demo_sd <- FALSE
spec_K$years   <- 1
spec_K$reps    <- 1
spec_K$K       <- 50
spec_K$K_sd    <- 0
spec_K$n0[]    <- 60   # all stages start at 60

out1 <- run_pva_core(spec_K, keep_traj = TRUE)

test_that("ceiling scales holders down exactly to K in first step", {
  # sum only stages 2..n at t = 1 should equal K
  holders <- out1$raw$traj[2, -1, 1]
  expect_equal(sum(holders), spec_K$K)
})

test_that("floaters (stage 1) are not counted in K", {
  capped <- rPVA:::apply_ceiling_K(c(60L, 60L, 60L, 60L), 50)
  expect_equal(capped[1], 60L)
  expect_equal(sum(capped[-1]), 50)
})

test_that("holders never exceed K over multiple years", {
  spec_K$years <- 40
  out40 <- run_pva_core(spec_K, keep_traj = TRUE)
  # for each year, sum of stages 2..n ≤ K
  holder_totals <- apply(out40$raw$traj[, -1, 1, drop = FALSE], 1, sum)
  expect_true(all(holder_totals[-1] <= spec_K$K))
})
