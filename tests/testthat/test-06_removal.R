context("Checkpoint 6 – removals")

spec_rm <- read_test_spec()
spec_rm$env_sd  <- 0
spec_rm$demo_sd <- 0        # deterministic
spec_rm$K       <- 1e6
spec_rm$years   <- 7
spec_rm$reps    <- 1
spec_rm$removal_years <- c(2, 4)
spec_rm$removal_vec   <- c(0, 1, 2, 0, 0, 0, 0)
spec_rm$release_years <- NULL
set.seed(123)

spec_yes <- spec_rm                       # with removals
spec_no  <- spec_rm; spec_no$removal_years <- NULL   # control

out_yes <- run_pva_core(spec_yes, keep_traj = TRUE)
out_no  <- run_pva_core(spec_no,  keep_traj = TRUE)

test_that("removal schedule is only applied in configured years", {
  baseline <- rep(10L, length(spec_rm$removal_vec))
  expect_equal(
    apply_removals(baseline, spec_rm$removal_years[1], spec_rm),
    pmax(baseline - spec_rm$removal_vec, 0L)
  )
  expect_equal(apply_removals(baseline, 1L, spec_rm), baseline)
})

test_that("treatment population is always ≤ control", {
  for (yr in 0:spec_rm$years) {
    expect_lte(sum(out_yes$traj[yr + 1, , 1]),
               sum(out_no $traj[yr + 1, , 1]))
  }
})
