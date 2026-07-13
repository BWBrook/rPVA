context("PVA reporting helpers")

test_that("summarize_pva_result reports one trajectory-backed result", {
  spec <- read_test_spec()
  spec$name <- "test_scenario"
  spec$years <- 4
  spec$reps <- 3
  spec$env_sd <- 0
  spec$demographic_stochasticity <- FALSE

  out <- run_pva_core(spec, keep_traj = TRUE, seed = 11, verbose = FALSE)
  summary <- summarize_pva_result(out)

  expect_equal(summary$scenario, "test_scenario")
  expect_equal(summary$years, 4L)
  expect_equal(summary$reps, 3L)
  expect_equal(summary$PE, 0)
  expect_equal(summary$Nmed, 17)
  expect_equal(summary$Nlo95, 9)
  expect_equal(summary$Nhi95, 23)
  expect_equal(summary$extinct_reps, 0)
  expect_equal(summary$surviving_reps, 3)
  expect_true(summary$trajectory_available)
})

test_that("summarize_pva_result falls back to final Nend extinction probability", {
  spec <- read_test_spec()
  spec$years <- 4
  spec$reps <- 3
  spec$env_sd <- 0
  spec$demographic_stochasticity <- FALSE

  out <- run_pva_core(spec, keep_traj = FALSE, seed = 11, verbose = FALSE)
  summary <- summarize_pva_result(out, scenario = "summary_only")

  expect_equal(summary$scenario, "summary_only")
  expect_equal(summary$PE, mean(out$Nend == 0))
  expect_false(summary$trajectory_available)
})

test_that("summarize_pva_result requires trajectories for non-final horizons", {
  spec <- read_test_spec()
  spec$years <- 4
  spec$reps <- 3
  spec$env_sd <- 0
  spec$demographic_stochasticity <- FALSE

  out <- run_pva_core(spec, keep_traj = FALSE, seed = 11, verbose = FALSE)

  expect_error(
    summarize_pva_result(out, horizon = 2),
    "requires keep_traj = TRUE"
  )
})

test_that("compare_pva_results preserves order and useful labels", {
  spec <- read_test_spec()
  spec$years <- 4
  spec$reps <- 3
  spec$env_sd <- 0
  spec$demographic_stochasticity <- FALSE

  full <- run_pva_core(spec, keep_traj = TRUE, seed = 11, verbose = FALSE)
  lite <- run_pva_core(spec, keep_traj = FALSE, seed = 11, verbose = FALSE)

  named <- compare_pva_results(list(full = full, lite = lite))
  unnamed <- compare_pva_results(list(full, lite))

  expect_equal(named$scenario, c("full", "lite"))
  expect_equal(unnamed$scenario, c("scenario_1", "scenario_2"))
  expect_equal(named$Nmed, c(17, 17))
})

test_that("compare_pva_results validates list inputs and scenario labels", {
  expect_error(compare_pva_results(list()), "non-empty list")
  expect_error(compare_pva_results("not a list"), "non-empty list")
  expect_error(
    compare_pva_results(list(list(Nend = c(1, 2))), scenarios = c("a", "b")),
    "one label per result"
  )
})

test_that("diagnose_pva_result returns deterministic student-facing codes", {
  out <- list(
    Nend = c(0, 10, 200, 1000),
    traj = NULL,
    ext_prob = c(0, 0.10, 0.25),
    Nend_summary = list(median = 40, lo95 = 5, hi95 = 200),
    params = list(name = "diagnostic", years = 2, reps = 4)
  )

  diagnostics <- diagnose_pva_result(out)

  expect_equal(
    diagnostics$code,
    c(
      "high_extinction_probability",
      "low_median_final_abundance",
      "wide_final_abundance_interval",
      "no_trajectory_data"
    )
  )
  expect_equal(diagnostics$severity, c("warning", "warning", "note", "note"))
  expect_true(all(nzchar(diagnostics$message)))
  expect_true(grepl("discuss this as a material risk", diagnostics$message[[1]], fixed = TRUE))
  expect_false(grepl("not a certainty", diagnostics$message[[1]], fixed = TRUE))
  expect_true(grepl("emphasise uncertainty", diagnostics$message[[3]], fixed = TRUE))
  expect_false(grepl("emphasize", diagnostics$message[[3]], fixed = TRUE))
})

test_that("diagnose_pva_result prompts care when no extinctions are observed", {
  out <- list(
    Nend = c(100, 200, 300),
    traj = array(1L, dim = c(3, 1, 3)),
    ext_prob = c(0, 0, 0),
    Nend_summary = list(median = 200, lo95 = 100, hi95 = 300),
    params = list(name = "low_risk", years = 2, reps = 3)
  )

  diagnostics <- diagnose_pva_result(out)

  expect_equal(diagnostics$code, "zero_observed_extinction")
  expect_equal(diagnostics$severity, "note")
  expect_match(diagnostics$message, "keep uncertainty visible")
})
