context("Checkpoint 2a - recruit-phase")

test_that("recruit_phase returns expected recruits and SR update", {
  # deterministic inputs
  N      <- c(10, 5, 0)                # 15 birds
  fec_t  <- c(0, 2, 2)                 # only adults reproduce
  sr_in  <- 0.40                       # female-poor
  spec   <- list(monogamy = TRUE)      # throttle on
  demo   <- FALSE                      # deterministic branch

  out <- rPVA:::recruit_phase(N, fec_t, sr_in, spec, demo)

  lambda       <- sum(fec_t * N) * (sr_in / 0.5)   # throttled expectation
  expect_equal(out$recruits, as.integer(round(lambda)))

  # SR should satisfy internal mass balance
  total_before <- sum(N)
  total_after  <- total_before + out$recruits

  n_f_est <- out$sr * total_after - sr_in * total_before

  expect_true(abs(n_f_est - round(n_f_est)) < 1e-8)     # must be integer females
  expect_true(n_f_est >= 0 && n_f_est <= out$recruits)  # within logical bounds
})
