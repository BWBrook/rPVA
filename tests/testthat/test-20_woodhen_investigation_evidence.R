synthetic_woodhen_investigation_result <- function(scenario, abundance_shift = 0) {
  years <- scenario$spec$years
  reps <- scenario$spec$reps
  replicate_effect <- (seq_len(reps) %% 31L) - 15L
  total <- outer(0:years, replicate_effect, function(year, effect) {
    pmax(0, round(650 + abundance_shift + 2 * year + effect))
  })
  traj <- array(0, dim = c(years + 1L, length(scenario$spec$n0), reps))
  traj[, 1L, ] <- round(total * 0.20)
  traj[, 2L, ] <- total - traj[, 1L, ]
  nend <- total[years + 1L, ]
  extinct <- total == 0

  list(
    Nend = nend,
    traj = traj,
    sr_traj = matrix(0.5, nrow = years + 1L, ncol = reps),
    F_traj = matrix(0, nrow = years + 1L, ncol = reps),
    LE_traj = matrix(0, nrow = years + 1L, ncol = reps),
    ext_prob = rowMeans(extinct),
    Nend_summary = list(
      median = as.numeric(stats::median(nend)),
      lo95 = as.numeric(stats::quantile(nend, 0.025, names = FALSE)),
      hi95 = as.numeric(stats::quantile(nend, 0.975, names = FALSE))
    ),
    params = c(scenario$spec, list(seed = scenario$seed)),
    raw = list(
      Nend = nend,
      traj = traj,
      sr_traj = matrix(0.5, nrow = years + 1L, ncol = reps),
      F_traj = matrix(0, nrow = years + 1L, ncol = reps),
      LE_traj = matrix(0, nrow = years + 1L, ncol = reps)
    )
  )
}

compact_object_names <- function(x) {
  if (!is.list(x)) {
    return(character())
  }
  c(names(x), unlist(lapply(x, compact_object_names), use.names = FALSE))
}

compact_object_types <- function(x) {
  c(typeof(x), if (is.list(x)) unlist(lapply(x, compact_object_types), use.names = FALSE))
}

test_that("a seeded locked baseline becomes reproducible compact evidence", {
  baseline <- build_woodhen_sensitivity_family(
    "K", c(350, 250), seed = 9401L
  )$scenarios[[1L]]
  raw <- synthetic_woodhen_investigation_result(baseline)

  first <- compact_woodhen_run(raw, baseline, sample_trajectories = 17L)
  second <- compact_woodhen_run(raw, baseline, sample_trajectories = 17L)

  expect_s3_class(first, "woodhen_compact_run")
  expect_equal(first$scenario, baseline)
  expect_equal(first$spec_fingerprint, baseline$spec_fingerprint)
  expect_equal(first$scientific_identity_fingerprint, baseline$scientific_identity_fingerprint)
  expect_equal(first$seed, 9401L)
  expect_equal(first$reps, 1000L)
  expect_equal(first$horizon, 75L)
  expect_equal(first$sampled_replicate_indices, second$sampled_replicate_indices)
  expect_equal(first$trajectory_sample, second$trajectory_sample)
  expect_length(first$sampled_replicate_indices, 17L)
  expect_true(all(first$sampled_replicate_indices >= 1L))
  expect_true(all(first$sampled_replicate_indices <= first$reps))
  expect_equal(
    sort(unique(first$trajectory_sample$replicate_index)),
    first$sampled_replicate_indices
  )

  expect_named(first, c(
    "run_schema_version", "run_id", "scenario", "scenario_id", "family_id",
    "student_label", "scenario_type", "parent_id", "locked_baseline_id",
    "spec_fingerprint", "scientific_identity_fingerprint",
    "baseline_spec_fingerprint", "seed", "reps", "horizon", "summary",
    "diagnostics", "final_abundance", "annual_quantiles",
    "sampled_replicate_indices", "trajectory_sample", "extinction_evidence",
    "quasi_extinction_50_pairs", "difference_from_parent", "provenance"
  ), ignore.order = TRUE)
  expect_equal(first$annual_quantiles$year, 0:75)
  expect_equal(first$final_abundance$values, raw$Nend)
  expect_equal(first$quasi_extinction_50_pairs$threshold_pairs, 50L)
  expect_equal(first$difference_from_parent$status, "not_applicable")
  expect_s3_class(plot_woodhen_trajectories(first), "ggplot")
  expect_s3_class(plot_woodhen_final_abundance(first), "ggplot")
  expect_s3_class(plot_woodhen_risk_evidence(first), "ggplot")

  forbidden <- c("traj", "sr_traj", "F_traj", "LE_traj", "raw", "result", "params")
  expect_length(intersect(compact_object_names(first), forbidden), 0L)
  expect_false(any(compact_object_types(first) %in% c("closure", "environment")))

  compact_path <- tempfile(fileext = ".rds")
  saveRDS(first, compact_path)
  reloaded <- readRDS(compact_path)
  expect_equal(reloaded$sampled_replicate_indices, first$sampled_replicate_indices)
  expect_equal(ggplot2::ggplot_build(plot_woodhen_trajectories(reloaded))$data,
               ggplot2::ggplot_build(plot_woodhen_trajectories(first))$data)
})

test_that("the scenario runner returns compact evidence and reports progress", {
  scenario <- build_woodhen_sensitivity_family(
    "K", c(350, 250), seed = 712L
  )$scenarios[[1L]]
  progress_calls <- list()

  run <- run_woodhen_investigation_scenario(
    scenario,
    sample_trajectories = 2L,
    progress = function(completed, total) {
      progress_calls[[length(progress_calls) + 1L]] <<- c(completed, total)
    }
  )

  expect_s3_class(run, "woodhen_compact_run")
  expect_equal(run$seed, 712L)
  expect_equal(run$reps, 1000L)
  expect_equal(tail(progress_calls, 1L)[[1L]], c(1000L, 1000L))
  expect_length(run$sampled_replicate_indices, 2L)
})

test_that("the scenario runner preserves locked ordinary controls", {
  scenario <- build_woodhen_sensitivity_family(
    "K", c(350, 250), seed = 712L
  )$scenarios[[1L]]
  scenario$spec$reps <- 3L
  scenario$spec_fingerprint <- woodhen_spec_fingerprint(scenario$spec)
  scenario$scientific_identity_fingerprint <- woodhen_record_scientific_fingerprint(scenario)

  expect_error(
    run_woodhen_investigation_scenario(scenario, sample_trajectories = 2L),
    "locked field `reps`"
  )
})

test_that("sensitivity comparison derives response and parent differences", {
  family <- build_woodhen_sensitivity_family("K", c(350, 250), seed = 81L)
  shifts <- c(0, -100, -220)
  runs <- Map(function(scenario, shift) {
    compact_woodhen_run(
      synthetic_woodhen_investigation_result(scenario, shift),
      scenario,
      sample_trajectories = 9L
    )
  }, family$scenarios, shifts)

  comparison <- compare_woodhen_run_family(runs, family$family_id)

  expect_s3_class(comparison, "woodhen_run_family_comparison")
  expect_equal(comparison$family_id, family$family_id)
  expect_false(comparison$awkward_comparison)
  expect_equal(comparison$table$setting_value, c(500, 350, 250))
  expect_equal(comparison$table$parent_id[-1L], rep(runs[[1L]]$scenario_id, 2L))
  expect_equal(comparison$table$delta_final_median_abundance, c(0, -100, -220))
  expect_true(all(vapply(comparison$runs[-1L], function(run) {
    identical(run$difference_from_parent$status, "computed") &&
      is.numeric(run$difference_from_parent$outcomes$final_median_abundance)
  }, logical(1))))
  expect_s3_class(plot_woodhen_sensitivity_response(comparison), "ggplot")
})

test_that("prospective comparison supports compact baseline-threat-intervention plots", {
  family <- build_woodhen_prospective_family(
    "increased_cyclone_pressure",
    list(response = list(
      intervention_id = "emergency_response", intensity = "moderate"
    )),
    seed = 918L
  )
  runs <- Map(function(scenario, shift) {
    compact_woodhen_run(
      synthetic_woodhen_investigation_result(scenario, shift),
      scenario,
      sample_trajectories = 11L
    )
  }, family$scenarios, c(0, -610, -300))

  comparison <- compare_woodhen_run_family(runs, family$family_id)
  comparison_path <- tempfile(fileext = ".rds")
  saveRDS(comparison, comparison_path)
  reloaded <- readRDS(comparison_path)

  expect_equal(
    comparison$table$scenario_type,
    c("locked_baseline", "threat", "intervention")
  )
  expect_equal(comparison$table$parent_id[[2L]], runs[[1L]]$scenario_id)
  expect_equal(comparison$table$parent_id[[3L]], runs[[2L]]$scenario_id)
  expect_true(all(c(
    "delta_extinction_probability", "delta_quasi_extinction_probability",
    "delta_final_median_abundance"
  ) %in% names(comparison$table)))
  expect_s3_class(plot_woodhen_family_comparison(reloaded), "ggplot")
})

test_that("family comparison refuses incompatible science unless annotated", {
  family <- build_woodhen_sensitivity_family("K", c(350, 250), seed = 22L)
  runs <- lapply(family$scenarios, function(scenario) {
    compact_woodhen_run(
      synthetic_woodhen_investigation_result(scenario),
      scenario,
      sample_trajectories = 5L
    )
  })

  wrong_horizon <- runs
  wrong_horizon[[3L]]$horizon <- 74L
  expect_error(
    compare_woodhen_run_family(wrong_horizon, family$family_id),
    "incompatible.*horizon"
  )
  expect_error(
    compare_woodhen_run_family(
      wrong_horizon, family$family_id, allow_awkward = TRUE
    ),
    "annotation"
  )
  awkward <- compare_woodhen_run_family(
    wrong_horizon,
    family$family_id,
    allow_awkward = TRUE,
    awkward_annotation = "One run has a shorter validation horizon."
  )
  expect_true(awkward$awkward_comparison)
  expect_match(awkward$compatibility_issues, "horizon")
  expect_equal(
    awkward$awkward_annotation,
    "One run has a shorter validation horizon."
  )

  wrong_baseline <- runs
  wrong_baseline[[2L]]$baseline_spec_fingerprint <- "different-baseline"
  expect_error(
    compare_woodhen_run_family(wrong_baseline, family$family_id),
    "incompatible.*baseline"
  )
})
