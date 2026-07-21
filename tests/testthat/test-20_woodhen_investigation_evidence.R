synthetic_woodhen_investigation_result <- function(scenario,
                                                   abundance_shift = 0,
                                                   seed = scenario$seed) {
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
  normalized <- normalize_pva_spec(scenario$spec, stasis = NULL)

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
    params = c(
      normalized$spec,
      list(
        years = years,
        reps = reps,
        stasis = normalized$stasis,
        seed = seed
      )
    ),
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

test_that("compaction verifies executable provenance, seed, and final totals", {
  family <- build_woodhen_sensitivity_family("K", c(350, 250), seed = 405L)
  baseline <- family$scenarios[[1L]]
  altered <- family$scenarios[[2L]]
  baseline_result <- synthetic_woodhen_investigation_result(baseline)

  expect_error(
    compact_woodhen_run(baseline_result, altered),
    "executable specification"
  )

  incomplete_provenance <- baseline_result
  runtime_year <- tail(which(names(incomplete_provenance$params) == "years"), 1L)
  incomplete_provenance$params <- incomplete_provenance$params[-runtime_year]
  expect_error(
    compact_woodhen_run(incomplete_provenance, baseline),
    "executable provenance"
  )

  missing_seed <- baseline_result
  missing_seed$params$seed <- NULL
  expect_error(
    compact_woodhen_run(missing_seed, baseline),
    "stored result seed"
  )

  invalid_seed <- baseline_result
  invalid_seed$params$seed <- 1.5
  expect_error(
    compact_woodhen_run(invalid_seed, baseline),
    "stored result seed"
  )

  inconsistent_final <- baseline_result
  inconsistent_final$Nend[[1L]] <- inconsistent_final$Nend[[1L]] + 1
  expect_error(
    compact_woodhen_run(inconsistent_final, baseline),
    "final trajectory"
  )

  alternate_seed <- synthetic_woodhen_investigation_result(baseline, seed = 999L)
  compact <- compact_woodhen_run(alternate_seed, baseline)
  expect_equal(compact$seed, 999L)
  expect_equal(compact$scenario$seed, 405L)
})

test_that("retained scenarios use a strict portable schema", {
  scenarios <- c(
    build_woodhen_sensitivity_family("K", c(350, 250))$scenarios,
    build_woodhen_prospective_family(
      "increased_cyclone_pressure",
      list(response = list(intervention_id = "emergency_response"))
    )$scenarios
  )
  for (scenario in scenarios) {
    expect_silent(compact_woodhen_run(
      synthetic_woodhen_investigation_result(scenario),
      scenario,
      sample_trajectories = 2L
    ))
  }

  baseline <- scenarios[[1L]]
  raw <- synthetic_woodhen_investigation_result(baseline)
  unexpected <- baseline
  unexpected$extra_payload <- "not part of the scenario schema"
  expect_error(compact_woodhen_run(raw, unexpected), "unexpected.*field")

  forbidden_payloads <- list(
    closure = function() NULL,
    environment = new.env(parent = emptyenv()),
    external_pointer = new("externalptr"),
    language = quote(x + 1),
    raw_vector = as.raw(1:3),
    raw_array = array(1, dim = c(2L, 2L, 2L))
  )
  rejected <- vapply(names(forbidden_payloads), function(payload_name) {
    nonportable <- baseline
    nonportable$notes <- forbidden_payloads[[payload_name]]
    inherits(try(
      compact_woodhen_run(raw, nonportable),
      silent = TRUE
    ), "try-error")
  }, logical(1))
  expect_true(
    all(rejected),
    info = paste("not rejected:", paste(names(rejected)[!rejected], collapse = ", "))
  )
})

test_that("scenario payload shapes cannot hide full trajectories", {
  scenario <- build_woodhen_sensitivity_family(
    "K", c(350, 250), seed = 515L
  )$scenarios[[2L]]
  result <- synthetic_woodhen_investigation_result(scenario)
  component_id <- names(scenario$components)[[1L]]

  matrix_payload <- scenario
  matrix_payload$components[[component_id]]$value <- matrix(
    1,
    nrow = 76L,
    ncol = 1000L
  )
  matrix_payload$scientific_identity_fingerprint <-
    woodhen_record_scientific_fingerprint(matrix_payload)
  expect_error(
    compact_woodhen_run(result, matrix_payload),
    "component.*value|stage-matched|matrix"
  )

  flattened_payload <- scenario
  flattened_payload$changes[[component_id]]$before <- rep(1, 76L * 1000L)
  flattened_payload$scientific_identity_fingerprint <-
    woodhen_record_scientific_fingerprint(flattened_payload)
  expect_error(
    compact_woodhen_run(result, flattened_payload),
    "change.*before|profile|length"
  )

  metadata_payload <- scenario
  metadata_payload$student_label <- rep("flattened-trajectory-value", 76L * 1000L)
  expect_error(
    compact_woodhen_run(result, metadata_payload),
    "student_label.*character value|scalar"
  )
})

test_that("legitimate survival and fecundity profile matrices remain portable", {
  family <- build_woodhen_prospective_family(list(
    threat_id = "novel_disease",
    components = list(fecundity_effect = list(
      field = "fecund",
      operator = "multiply",
      value = 0.80
    ))
  ))
  scenario <- family$scenarios[[2L]]

  expect_equal(dim(scenario$spec$annual_profiles$surv), c(75L, 7L))
  expect_equal(dim(scenario$spec$annual_profiles$fecund), c(75L, 7L))
  expect_true(all(vapply(
    scenario$changes,
    function(change) identical(dim(change$before), c(75L, 7L)) &&
      identical(dim(change$after), c(75L, 7L)),
    logical(1)
  )))
  expect_silent(compact_woodhen_run(
    synthetic_woodhen_investigation_result(scenario),
    scenario,
    sample_trajectories = 3L
  ))
})

test_that("compact extinction evidence preserves exact timing and probability", {
  baseline <- build_woodhen_sensitivity_family(
    "K", c(350, 250), seed = 606L
  )$scenarios[[1L]]
  result <- synthetic_woodhen_investigation_result(baseline)
  result$traj[3:76, , 1L] <- 0
  result$traj[4:76, , 2L] <- 0
  result$raw$traj <- result$traj
  totals <- apply(result$traj, c(1L, 3L), sum)
  result$Nend <- totals[76L, ]
  result$raw$Nend <- result$Nend
  result$ext_prob <- rowMeans(totals == 0)

  compact <- compact_woodhen_run(result, baseline, sample_trajectories = 4L)
  evidence <- compact$extinction_evidence

  expect_equal(evidence$extinct_reps, 2L)
  expect_equal(evidence$probability_by_horizon, 0.002)
  expect_equal(evidence$first_extinction_year[1:3], c(2L, 3L, NA_integer_))
  expect_equal(evidence$cumulative$probability[1:5], c(0, 0, 0.001, 0.002, 0.002))
  expect_equal(evidence$conditional_median_year, 2.5)
  expect_true(is.na(evidence$overall_median_year))
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
  expect_equal(comparison$table$quasi_extinction_probability, c(0, 1, 0))
  expect_equal(comparison$table$delta_quasi_extinction_probability, c(0, 1, -1))
  expect_s3_class(plot_woodhen_family_comparison(reloaded), "ggplot")

  annotated <- reloaded
  annotated$awkward_comparison <- TRUE
  annotated$awkward_annotation <- "The intervention uses a different validation seed."
  annotated_plot <- plot_woodhen_family_comparison(annotated)
  expect_match(annotated_plot$labels$caption, "Awkward comparison")
  expect_match(annotated_plot$labels$caption, "different validation seed")
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

  mixed_seed <- runs
  mixed_seed[[2L]] <- compact_woodhen_run(
    synthetic_woodhen_investigation_result(
      family$scenarios[[2L]],
      seed = 999L
    ),
    family$scenarios[[2L]],
    sample_trajectories = 5L
  )
  expect_error(
    compare_woodhen_run_family(mixed_seed, family$family_id),
    "incompatible.*seed"
  )
  awkward_seed <- compare_woodhen_run_family(
    mixed_seed,
    family$family_id,
    allow_awkward = TRUE,
    awkward_annotation = "A different seed is shown as a robustness check."
  )
  awkward_plot <- plot_woodhen_sensitivity_response(awkward_seed)
  expect_match(awkward_plot$labels$caption, "Awkward comparison")
  expect_match(awkward_plot$labels$caption, "different seed")

  mixed_reps <- runs
  mixed_reps[[3L]]$reps <- 999L
  expect_error(
    compare_woodhen_run_family(mixed_reps, family$family_id),
    "incompatible.*replicate"
  )
})
