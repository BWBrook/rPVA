context("Checkpoint 2b - survival-phase")

test_that("survival_phase conserves survivors under deterministic input", {
  # 3-stage example, adults have stasis only
  N          <- c(20, 10, 5)
  surv_t     <- c(0.5, 0.0, 0.0)   # progression probs (juvenile→subadult)
  stasis_t   <- c(0.2, 0.6, 0.8)   # stay in same stage
  spec       <- list()             # unused flags
  demo       <- FALSE              # deterministic

  N_next <- survival_phase(N, surv_t, stasis_t, spec, demo)

  # juveniles progressed
  juv_prog <- round(20 * 0.5)
  # subadults that stayed
  sub_stay <- round(10 * 0.6)
  expect_equal(N_next[2], juv_prog + sub_stay)

  # adults: 0.8 survive
  expect_equal(N_next[3], round(5 * 0.8))
})

test_that("last-stage stasis is honoured", {
  spec <- read_spec(system.file("testdata", "woodhen_test.yaml",
                                package = "woodhenPVA"))
  spec$years <- spec$reps <- 1
  spec$env_sd <- 0; spec$demo_sd <- FALSE
  spec$surv   <- c(0.6, 0.8, 0.0)   # progression only
  spec$stasis <- c(0, 0, 0.8)

  adults_keep <- run_pva_core(spec, keep_traj = TRUE)$traj[2,3,1]

  spec$stasis[3] <- 0
  adults_die  <- run_pva_core(spec, keep_traj = TRUE)$traj[2,3,1]

  expect_gt(adults_keep, adults_die)
})
