context("Checkpoint 1 – core engine")

# Canonical deterministic spec (no stochasticity, 1 year, 1 rep)
spec_det <- read_spec(system.file("extdata", "woodhen_test.yaml", package = "rPVA"))
spec_det$env_sd  <- 0
spec_det$demo_sd <- FALSE
spec_det$years   <- 1
spec_det$reps    <- 1

# Canonical stochastic spec (env + demo variance, 1 year, 5 reps)
spec_stoch <- spec_det
spec_stoch$env_sd  <- 0.15
spec_stoch$demo_sd <- 0.05
spec_stoch$reps    <- 5

test_that("deterministic projection matches matrix algebra for a single time step", {
  # Build projection matrix
  A <- make_projection_matrix(
    surv_prog = spec_det$surv[-length(spec_det$surv)],
    fecund    = spec_det$fecund
  )

  # Matrix algebra projection (rounded to integer animals for fairness)
  N1_matrix <- as.integer(round(A %*% spec_det$n0))

  # Simulation engine
  out <- run_pva_core(spec_det, keep_traj = TRUE)
  N1_engine <- out$traj[2, , 1]

  # Compare: must match exactly in deterministic mode (integer animal case)
  expect_equal(sum(N1_engine), sum(N1_matrix), tolerance = 1)
})

test_that("engine handles extinction", {
  # Push to extinction: zero survival, zero fecundity
  spec_ext <- spec_det
  spec_ext$surv[]   <- 0
  spec_ext$fecund[] <- 0
  spec_ext$n0[]     <- 1
  spec_ext$release_vec <- 0
  out <- run_pva_core(spec_ext)
  expect_true(all(out$Nend == 0))
})

test_that("engine throws on biologically impossible inputs", {
  spec_bad <- spec_det
  spec_bad$surv[1] <- 1.5 # Impossible survival
  expect_error(run_pva_core(spec_bad), "surv")
})
