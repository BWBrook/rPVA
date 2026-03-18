context("Checkpoint 6 – removals")

spec_rm <- read_spec(system.file("testdata", "test_01.yaml", package = "rPVA"))
spec_rm$env_sd  <- 0
spec_rm$demo_sd <- 0        # deterministic
spec_rm$K       <- 1e6
spec_rm$years   <- 7
spec_rm$reps    <- 1
spec_rm$release_years <- NULL
set.seed(123)

spec_yes <- spec_rm                       # with removals
spec_no  <- spec_rm; spec_no$removal_years <- NULL   # control

out_yes <- run_pva_core(spec_yes, keep_traj = TRUE)
out_no  <- run_pva_core(spec_no,  keep_traj = TRUE)

test_that("removals widen the gap by ≥ remN in the scheduled years", {
  remN <- sum(spec_rm$removal_vec)
  for (yr in spec_rm$removal_years) {
    gap_before <- sum(out_no$traj[yr,   , 1]) -
                  sum(out_yes$traj[yr,   , 1])
    gap_after  <- sum(out_no$traj[yr+1, , 1]) -
                  sum(out_yes$traj[yr+1, , 1])
    expect_gte(gap_after - gap_before, remN)
  }
})

test_that("treatment population is always ≤ control", {
  for (yr in 0:spec_rm$years) {
    expect_lte(sum(out_yes$raw$traj[yr + 1, , 1]),
               sum(out_no $raw$traj[yr + 1, , 1]))
  }
})
