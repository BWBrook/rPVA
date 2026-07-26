test_that("temporal profiles apply persistent step changes", {
  profile <- build_temporal_profile(
    baseline = 500,
    target = 250,
    years = 6,
    onset_year = 3,
    end_year = 5,
    shape = "step"
  )

  expect_equal(profile, c(500, 500, 250, 250, 250, 250))
})

test_that("linear temporal profiles are bounded by their onset and end years", {
  profile <- build_temporal_profile(
    baseline = 500,
    target = 250,
    years = 6,
    onset_year = 2,
    end_year = 5,
    shape = "linear"
  )

  expect_equal(profile, c(500, 500, 500 - 250 / 3, 500 - 500 / 3, 250, 250))
})

test_that("temporal profiles preserve stage-specific values", {
  profile <- build_temporal_profile(
    baseline = c(0.6, 0.8),
    target = c(0.4, 0.6),
    years = 3,
    onset_year = 1,
    end_year = 3,
    shape = "linear"
  )

  expect_equal(
    profile,
    matrix(c(0.6, 0.8, 0.5, 0.7, 0.4, 0.6), nrow = 3, byrow = TRUE)
  )
})

test_that("temporal profile builders reject malformed schedules", {
  expect_error(build_temporal_profile(1, 2, years = 0), "years")
  expect_error(build_temporal_profile(1, 2, years = 4, onset_year = 0), "onset_year")
  expect_error(build_temporal_profile(1, 2, years = 4, onset_year = 5), "onset_year")
  expect_error(build_temporal_profile(1, 2, years = 4, end_year = 5), "end_year")
  expect_error(
    build_temporal_profile(1, 2, years = 4, onset_year = 3, end_year = 2),
    "end_year.*onset_year"
  )
  expect_error(build_temporal_profile(1, 2, years = 4, shape = "curve"), "step.*linear")
  expect_error(build_temporal_profile(c(1, 2), 3, years = 4), "same length")
  expect_error(build_temporal_profile(numeric(0), numeric(0), years = 4), "non-empty")
  expect_error(build_temporal_profile(NA_real_, 1, years = 4), "finite")
  expect_error(build_temporal_profile(1, Inf, years = 4), "finite")
})

test_that("annual profile validation accepts supported ecological fields", {
  years <- 4
  profiles <- list(
    K = build_temporal_profile(500, 250, years, onset_year = 2, shape = "step"),
    K_sd = rep(20, years),
    env_sd = rep(0.1, years),
    cat_freq = rep(0.05, years),
    cat_surv = rep(0.6, years),
    cat_repro = rep(0.8, years),
    surv = build_temporal_profile(c(0.6, 0.8), c(0.5, 0.7), years),
    fecund = build_temporal_profile(c(0, 2), c(0, 1.5), years)
  )

  expect_identical(validate_annual_profiles(profiles, years, n_stage = 2), profiles)
})

test_that("annual profile validation rejects unsupported fields and dimensions", {
  expect_error(validate_annual_profiles(list(stasis = rep(0.5, 3)), 3, 2), "Unsupported")
  expect_error(validate_annual_profiles(list(K = c(100, 90)), 3, 2), "K.*length 3")
  expect_error(validate_annual_profiles(list(K = matrix(100, 3, 1)), 3, 2), "K.*vector")
  expect_error(validate_annual_profiles(list(surv = rep(0.5, 3)), 3, 2), "surv.*matrix")
  expect_error(validate_annual_profiles(list(surv = matrix(0.5, 2, 2)), 3, 2), "surv.*3.*2")
  expect_error(validate_annual_profiles(list(fecund = matrix(1, 3, 3)), 3, 2), "fecund.*3.*2")
  expect_error(validate_annual_profiles(list(K = c(100, NA, 80)), 3, 2), "finite")
})

test_that("annual profile validation enforces ecological bounds", {
  expect_error(validate_annual_profiles(list(K = c(100, -1)), 2, 2), "K.*non-negative")
  expect_error(validate_annual_profiles(list(K_sd = c(1, -1)), 2, 2), "K_sd.*non-negative")
  expect_error(validate_annual_profiles(list(env_sd = c(0.1, -0.1)), 2, 2), "env_sd.*non-negative")
  expect_error(validate_annual_profiles(list(cat_freq = c(0.1, 1.1)), 2, 2), "cat_freq.*\\[0, 1\\]")
  expect_error(validate_annual_profiles(list(cat_surv = c(0.5, -0.1)), 2, 2), "cat_surv.*\\[0, 1\\]")
  expect_error(validate_annual_profiles(list(cat_repro = c(0.8, -0.1)), 2, 2), "cat_repro.*\\[0, 1\\]")
  expect_error(validate_annual_profiles(list(cat_repro = c(0.8, 1.1)), 2, 2), "cat_repro.*\\[0, 1\\]")

  bad_survival <- build_temporal_profile(
    baseline = c(0.6, 0.8),
    target = c(0.5, 1.2),
    years = 2,
    onset_year = 1,
    shape = "step"
  )
  expect_error(
    validate_annual_profiles(list(surv = bad_survival), 2, 2),
    "surv.*\\[0, 1\\]"
  )
  expect_error(
    validate_annual_profiles(list(fecund = matrix(c(0, 1, 0, -1), 2, byrow = TRUE)), 2, 2),
    "fecund.*non-negative"
  )
})

test_that("normalization preserves annual profile structure", {
  spec <- read_test_spec()
  spec$years <- 3
  spec$annual_profiles <- list(
    K = build_temporal_profile(spec$K, 5, spec$years, onset_year = 2),
    surv = build_temporal_profile(spec$surv, spec$surv * 0.9, spec$years)
  )

  normalized <- normalize_pva_spec(spec, stasis = NULL)

  expect_true("annual_profiles" %in% allowed_pva_spec_fields())
  expect_identical(normalized$spec$annual_profiles$K, spec$annual_profiles$K)
  expect_identical(normalized$spec$annual_profiles$surv, spec$annual_profiles$surv)
})

test_that("year resolution changes only profiled fields in intended years", {
  spec <- read_test_spec()
  spec$years <- 5
  spec$env_sd <- 0.05
  reduced_survival <- spec$surv * 0.8
  increased_fecundity <- spec$fecund * 1.1
  spec$annual_profiles <- list(
    K = build_temporal_profile(500, 250, spec$years, onset_year = 2, end_year = 4, shape = "linear"),
    surv = build_temporal_profile(spec$surv, reduced_survival, spec$years, onset_year = 4),
    fecund = build_temporal_profile(spec$fecund, increased_fecundity, spec$years, onset_year = 4)
  )
  normalized <- normalize_pva_spec(spec, stasis = NULL)

  year_3 <- resolve_pva_year_spec(normalized$spec, normalized$stasis, year = 3)
  year_4 <- resolve_pva_year_spec(normalized$spec, normalized$stasis, year = 4)

  expect_equal(year_3$spec$K, 375)
  expect_equal(year_3$spec$surv, spec$surv)
  expect_equal(year_3$spec$fecund, spec$fecund)
  expect_equal(year_4$spec$K, 250)
  expect_equal(year_4$spec$surv, reduced_survival)
  expect_equal(year_4$spec$fecund, increased_fecundity)
  expect_equal(year_4$spec$cat_freq, normalized$spec$cat_freq)
  expect_identical(year_4$stasis, normalized$stasis)
  expect_false("annual_profiles" %in% names(year_4$spec))

  expected_env <- compute_env_beta_params(reduced_survival, spec$env_sd)
  expect_equal(year_4$env_alpha, expected_env$alpha)
  expect_equal(year_4$env_beta, expected_env$beta)
})

test_that("a step decrease in carrying capacity begins in the selected year", {
  spec <- read_test_spec()
  spec$years <- 5
  spec$reps <- 1
  spec$env_sd <- 0
  spec$demographic_stochasticity <- FALSE
  spec$genetics <- FALSE
  spec$K <- 1e6
  spec$K_sd <- 0
  spec$n0[] <- 60
  spec$annual_profiles <- list(
    K = build_temporal_profile(spec$K, 10, spec$years, onset_year = 3, shape = "step")
  )

  out <- run_pva_core(spec, keep_traj = TRUE, seed = 19)
  holder_totals <- apply(out$raw$traj[, -1, 1, drop = FALSE], 1, sum)

  expect_true(all(holder_totals[c(2, 3)] > 10))
  expect_true(all(holder_totals[4:6] <= 10))
})

test_that("an explicit NULL annual profile leaves every scalar result component unchanged", {
  spec <- build_woodhen_management_spec("sensitivity_default")
  spec$years <- 5
  spec$reps <- 4
  with_null <- spec
  with_null["annual_profiles"] <- list(NULL)

  scalar_result <- run_pva_core(spec, keep_traj = TRUE, seed = 8675309)
  null_result <- run_pva_core(with_null, keep_traj = TRUE, seed = 8675309)

  expect_identical(null_result, scalar_result)
})
