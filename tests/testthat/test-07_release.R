context("Checkpoint 7 – supplementation")

spec_rel <- read_spec(system.file("testdata", "test_01.yaml", package = "rPVA"))

spec_rel$env_sd  <- 0
spec_rel$demo_sd <- FALSE
spec_rel$K       <- 1e6   # disable ceiling to isolate releases
spec_rel$years   <- 5
spec_rel$reps    <- 1
spec_rel$removal_years <- NULL
set.seed(42)

spec_yes <- spec_rel                       # has releases
spec_no  <- spec_rel; spec_no$release_years <- NULL

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

test_that("no supplementation outside schedule", {
  N <- c(10L, 10L, 10L, 10L, 10L, 10L, 10L)
  untouched <- rPVA:::apply_releases(N, 1, spec_rel)

  expect_equal(untouched, N)
})
