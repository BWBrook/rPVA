context("Checkpoint 5 – supplementation")

spec_rel <- read_spec(system.file("extdata", "woodhen_test.yaml",
                                  package = "woodhenPVA"))

spec_rel$env_sd <- spec_rel$demo_sd <- 0
spec_rel$K      <- 1e6   # disable ceiling to isolate releases
spec_rel$years  <- 5
spec_rel$reps   <- 1
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
  nonrel <- setdiff(1:spec_rel$years, spec_rel$release_years)
  addN <- sum(spec_rel$release_vec)
  for (yr in nonrel) {
    delta <- sum(out_yes$traj[yr + 1, , 1]) - sum(out_yes$traj[yr, , 1])
    expect_false(delta == addN)
  }
})
