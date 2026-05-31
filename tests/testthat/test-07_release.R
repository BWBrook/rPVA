context("Checkpoint 7 – supplementation")

spec_rel <- read_test_spec()

spec_rel$env_sd  <- 0
spec_rel$demographic_stochasticity <- FALSE
spec_rel$K       <- 1e6   # disable ceiling to isolate releases
spec_rel$years   <- 5
spec_rel$reps    <- 1
spec_rel$release_years <- c(2, 4)
spec_rel$release_vec   <- c(0, 0, 10, 0, 0, 0, 0)
spec_rel$removal_years <- NULL
set.seed(42)

spec_yes <- spec_rel                       # has releases
spec_no  <- spec_rel
spec_no$release_years <- NULL
spec_no$release_vec   <- rep(0L, length(spec_rel$release_vec))

out_yes <- run_pva_core(spec_yes, keep_traj = TRUE)
out_no  <- run_pva_core(spec_no,  keep_traj = TRUE)

test_that("supplementation lifts population by ≥ addN", {
  addN <- sum(spec_rel$release_vec)
  for (yr in spec_rel$release_years) {
    diff_after <- sum(out_yes$traj[yr + 1, , 1]) -
                  sum(out_no $traj[yr + 1, , 1])
    expect_gte(diff_after, addN)
  }
})

test_that("release schedule is only applied in configured years", {
  baseline <- rep(10L, length(spec_rel$release_vec))
  expect_equal(
    rPVA:::apply_releases(baseline, spec_rel$release_years[1], spec_rel),
    baseline + spec_rel$release_vec
  )
  expect_equal(rPVA:::apply_releases(baseline, 1L, spec_rel), baseline)
})
