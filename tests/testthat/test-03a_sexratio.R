context("Checkpoint 3a – sex-ratio limitation")

spec_sr <- read_test_spec()
spec_sr$monogamy       <- TRUE
spec_sr$sex_ratio_init <- 0.30   # female-poor
spec_sr$env_sd         <- 0
spec_sr$demo_sd        <- FALSE
spec_sr$years <- spec_sr$reps <- 1

out <- run_pva_core(spec_sr, keep_traj = TRUE)

test_that("female shortage reduces first-year recruits", {
  lambda_unlim <- sum(spec_sr$fecund * spec_sr$n0)   # λ with SR = 0.5
  expect_lt(out$traj[2, 1, 1], lambda_unlim)         # fewer juveniles
})
