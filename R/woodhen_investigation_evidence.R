woodhen_validate_sample_count <- function(sample_trajectories) {
  valid <- is.numeric(sample_trajectories) && length(sample_trajectories) == 1L &&
    is.finite(sample_trajectories) && sample_trajectories >= 1 &&
    sample_trajectories == as.integer(sample_trajectories)
  if (!valid) {
    stop("`sample_trajectories` must be a positive whole number.", call. = FALSE)
  }
  as.integer(sample_trajectories)
}

woodhen_sample_replicate_indices <- function(reps, sample_trajectories) {
  sample_trajectories <- min(woodhen_validate_sample_count(sample_trajectories), reps)
  as.integer(round(seq(1, reps, length.out = sample_trajectories)))
}

woodhen_total_trajectories <- function(result) {
  traj <- result$traj
  if (is.null(traj) && is.list(result$raw)) {
    traj <- result$raw$traj
  }
  if (is.null(traj) || length(dim(traj)) != 3L) {
    stop(
      "Compact Woodhen evidence requires a three-dimensional trajectory array.",
      call. = FALSE
    )
  }
  if (!is.numeric(traj) || any(!is.finite(traj)) || any(traj < 0)) {
    stop("Woodhen trajectory counts must be finite and non-negative.", call. = FALSE)
  }
  apply(traj, c(1L, 3L), sum)
}

woodhen_first_passage_evidence <- function(event_matrix) {
  event_matrix <- as.matrix(event_matrix)
  cumulative_event <- event_matrix
  first_year <- vapply(seq_len(ncol(event_matrix)), function(rep_index) {
    event_rows <- which(event_matrix[, rep_index])
    if (length(event_rows) == 0L) {
      return(NA_integer_)
    }
    as.integer(event_rows[[1L]] - 1L)
  }, integer(1))
  for (rep_index in seq_len(ncol(cumulative_event))) {
    cumulative_event[, rep_index] <- cummax(cumulative_event[, rep_index])
  }
  cumulative <- data.frame(
    year = seq_len(nrow(cumulative_event)) - 1L,
    probability = rowMeans(cumulative_event)
  )
  observed_years <- first_year[!is.na(first_year)]
  probability <- tail(cumulative$probability, 1L)

  list(
    total_reps = as.integer(ncol(event_matrix)),
    crossed_reps = as.integer(length(observed_years)),
    probability_by_horizon = as.numeric(probability),
    first_crossing_year = first_year,
    cumulative = cumulative,
    conditional_median_year = if (length(observed_years)) {
      as.numeric(stats::median(observed_years))
    } else {
      NA_real_
    },
    overall_median_year = if (probability >= 0.5) {
      as.numeric(cumulative$year[which(cumulative$probability >= 0.5)[[1L]]])
    } else {
      NA_real_
    }
  )
}

woodhen_extinction_evidence <- function(total_trajectories) {
  evidence <- woodhen_first_passage_evidence(total_trajectories == 0)
  names(evidence)[names(evidence) == "crossed_reps"] <- "extinct_reps"
  names(evidence)[names(evidence) == "first_crossing_year"] <- "first_extinction_year"
  evidence
}

woodhen_annual_quantiles <- function(total_trajectories) {
  probabilities <- c(0.025, 0.25, 0.50, 0.75, 0.975)
  quantiles <- t(apply(
    total_trajectories,
    1L,
    stats::quantile,
    probs = probabilities,
    names = FALSE,
    type = 7
  ))
  data.frame(
    year = seq_len(nrow(total_trajectories)) - 1L,
    q025 = quantiles[, 1L],
    q25 = quantiles[, 2L],
    median = quantiles[, 3L],
    q75 = quantiles[, 4L],
    q975 = quantiles[, 5L]
  )
}

woodhen_final_abundance_evidence <- function(values) {
  quantiles <- stats::quantile(
    values,
    probs = c(0.025, 0.25, 0.50, 0.75, 0.975),
    names = FALSE,
    type = 7
  )
  list(
    values = as.numeric(values),
    median = as.numeric(quantiles[[3L]]),
    q025 = as.numeric(quantiles[[1L]]),
    q25 = as.numeric(quantiles[[2L]]),
    q75 = as.numeric(quantiles[[4L]]),
    q975 = as.numeric(quantiles[[5L]])
  )
}

woodhen_sample_trajectory_data <- function(total_trajectories, indices) {
  sampled <- total_trajectories[, indices, drop = FALSE]
  data.frame(
    year = rep(seq_len(nrow(sampled)) - 1L, times = ncol(sampled)),
    replicate_index = rep(indices, each = nrow(sampled)),
    abundance = as.numeric(sampled)
  )
}

woodhen_validate_scenario_record <- function(scenario) {
  required <- c(
    "scenario_id", "family_id", "student_label", "scenario_type", "parent_id",
    "locked_baseline_id", "spec", "seed", "spec_fingerprint",
    "scientific_identity_fingerprint"
  )
  if (!is.list(scenario) || length(setdiff(required, names(scenario))) > 0L) {
    stop("`scenario` must be a complete Woodhen investigation scenario record.", call. = FALSE)
  }
  if (!identical(woodhen_spec_fingerprint(scenario$spec), scenario$spec_fingerprint)) {
    stop("`scenario$spec_fingerprint` does not match its executable specification.", call. = FALSE)
  }
  woodhen_validate_seed(scenario$seed)
  woodhen_preflight_spec(scenario$spec)
  if (!identical(
    woodhen_record_scientific_fingerprint(scenario),
    scenario$scientific_identity_fingerprint
  )) {
    stop(
      "`scenario$scientific_identity_fingerprint` does not match its scientific record.",
      call. = FALSE
    )
  }
  invisible(scenario)
}

#' Store compact evidence from a completed Woodhen investigation
#'
#' @param result A retained-trajectory result from `run_pva_core()`.
#' @param scenario A validated Woodhen investigation scenario record.
#' @param sample_trajectories Maximum number of deterministic trajectories to retain.
#' @return A compact, serialisable `woodhen_compact_run`.
compact_woodhen_run <- function(result, scenario, sample_trajectories = 100L) {
  woodhen_validate_scenario_record(scenario)
  total_trajectories <- woodhen_total_trajectories(result)
  reps <- as.integer(ncol(total_trajectories))
  horizon <- as.integer(nrow(total_trajectories) - 1L)
  if (!is.numeric(result$Nend) || length(result$Nend) != reps) {
    stop("`result$Nend` must contain one final abundance per replicate.", call. = FALSE)
  }
  if (!identical(reps, as.integer(scenario$spec$reps)) ||
      !identical(horizon, as.integer(scenario$spec$years))) {
    stop("The result replicate count and horizon must match the scenario specification.", call. = FALSE)
  }
  seed <- woodhen_validate_seed(woodhen_or(result$params$seed, scenario$seed))
  indices <- woodhen_sample_replicate_indices(reps, sample_trajectories)
  quasi_extinction <- summarize_quasi_extinction(
    result,
    threshold_pairs = 50L,
    holder_stages = seq.int(2L, dim(result$traj)[[2L]])
  )
  quasi_extinction$breeding_pair_trajectories <- NULL
  summary <- summarize_pva_result(result, scenario = scenario$student_label)
  diagnostics <- diagnose_pva_result(result, scenario = scenario$student_label)
  baseline_spec_fingerprint <- woodhen_spec_fingerprint(woodhen_locked_future_spec())
  run_id <- paste0(
    "woodhen_run_",
    substr(woodhen_content_fingerprint(list(
      scenario_id = scenario$scenario_id,
      scientific_identity_fingerprint = scenario$scientific_identity_fingerprint,
      seed = seed,
      reps = reps
    )), 1L, 16L)
  )
  difference_status <- if (is.na(scenario$parent_id)) "not_applicable" else "pending_comparison"

  structure(
    list(
      run_schema_version = "woodhen-compact-run-v1",
      run_id = run_id,
      scenario = scenario,
      scenario_id = scenario$scenario_id,
      family_id = scenario$family_id,
      student_label = scenario$student_label,
      scenario_type = scenario$scenario_type,
      parent_id = scenario$parent_id,
      locked_baseline_id = scenario$locked_baseline_id,
      spec_fingerprint = scenario$spec_fingerprint,
      scientific_identity_fingerprint = scenario$scientific_identity_fingerprint,
      baseline_spec_fingerprint = baseline_spec_fingerprint,
      seed = seed,
      reps = reps,
      horizon = horizon,
      summary = summary,
      diagnostics = diagnostics,
      final_abundance = woodhen_final_abundance_evidence(result$Nend),
      annual_quantiles = woodhen_annual_quantiles(total_trajectories),
      sampled_replicate_indices = indices,
      trajectory_sample = woodhen_sample_trajectory_data(total_trajectories, indices),
      extinction_evidence = woodhen_extinction_evidence(total_trajectories),
      quasi_extinction_50_pairs = quasi_extinction,
      difference_from_parent = list(
        parent_id = scenario$parent_id,
        status = difference_status,
        specification_changes = scenario$changes,
        outcomes = NULL
      ),
      provenance = list(
        reference_library_version = scenario$reference_library_version,
        catalog_version = scenario$catalog_version,
        model_version = scenario$model_version,
        fingerprint_algorithm = scenario$fingerprint_algorithm,
        canonicalization_version = scenario$canonicalization_version
      )
    ),
    class = c("woodhen_compact_run", "list")
  )
}

#' Run one Woodhen investigation and immediately discard raw simulation arrays
#'
#' @param scenario A validated Woodhen investigation scenario record.
#' @param seed Integer run seed.
#' @param sample_trajectories Maximum number of deterministic trajectories to retain.
#' @param progress Optional progress callback passed to `run_pva_core()`.
#' @return A compact, serialisable `woodhen_compact_run`.
run_woodhen_investigation_scenario <- function(
    scenario,
    seed = scenario$seed,
    sample_trajectories = 100L,
    progress = NULL
) {
  woodhen_validate_scenario_record(scenario)
  seed <- woodhen_validate_seed(seed)
  result <- run_pva_core(
    scenario$spec,
    keep_traj = TRUE,
    seed = seed,
    progress = progress
  )
  compact_woodhen_run(result, scenario, sample_trajectories = sample_trajectories)
}

woodhen_validate_compact_run <- function(run) {
  required <- c(
    "run_schema_version", "scenario_id", "family_id", "scenario_type",
    "parent_id", "baseline_spec_fingerprint", "horizon", "reps",
    "final_abundance", "extinction_evidence", "quasi_extinction_50_pairs"
  )
  if (!inherits(run, "woodhen_compact_run") ||
      length(setdiff(required, names(run))) > 0L) {
    stop("Every `runs` entry must be a complete woodhen_compact_run.", call. = FALSE)
  }
  invisible(run)
}

woodhen_family_compatibility_issues <- function(runs, family_id) {
  issues <- character()
  run_family_ids <- vapply(runs, `[[`, character(1), "family_id")
  if (any(run_family_ids != family_id)) {
    issues <- c(issues, "family identity differs")
  }
  horizons <- vapply(runs, `[[`, integer(1), "horizon")
  if (length(unique(horizons)) != 1L) {
    issues <- c(issues, "horizon differs")
  }
  baselines <- vapply(runs, `[[`, character(1), "baseline_spec_fingerprint")
  if (length(unique(baselines)) != 1L) {
    issues <- c(issues, "baseline specification differs")
  }
  unique(issues)
}

woodhen_sensitivity_setting_values <- function(runs) {
  values <- rep(NA_real_, length(runs))
  altered <- which(vapply(runs, function(run) {
    length(run$scenario$changes) == 1L
  }, logical(1)))
  if (length(altered) == 0L) {
    return(values)
  }
  first_change <- runs[[altered[[1L]]]]$scenario$changes[[1L]]
  if (is.numeric(first_change$before) && length(first_change$before) == 1L) {
    baseline <- which(vapply(runs, function(run) is.na(run$parent_id), logical(1)))
    values[baseline] <- first_change$before
  }
  for (index in altered) {
    after <- runs[[index]]$scenario$changes[[1L]]$after
    if (is.numeric(after) && length(after) == 1L) {
      values[[index]] <- after
    }
  }
  values
}

woodhen_run_metric_row <- function(run) {
  data.frame(
    run_id = run$run_id,
    scenario_id = run$scenario_id,
    student_label = run$student_label,
    scenario_type = run$scenario_type,
    parent_id = run$parent_id,
    seed = run$seed,
    reps = run$reps,
    horizon = run$horizon,
    extinction_probability = run$extinction_evidence$probability_by_horizon,
    quasi_extinction_probability = run$quasi_extinction_50_pairs$probability_by_horizon,
    final_median_abundance = run$final_abundance$median,
    final_q025 = run$final_abundance$q025,
    final_q975 = run$final_abundance$q975,
    stringsAsFactors = FALSE
  )
}

woodhen_add_parent_differences <- function(table, runs) {
  table$delta_extinction_probability <- 0
  table$delta_quasi_extinction_probability <- 0
  table$delta_final_median_abundance <- 0
  for (index in seq_len(nrow(table))) {
    parent_id <- table$parent_id[[index]]
    if (is.na(parent_id)) {
      runs[[index]]$difference_from_parent$outcomes <- list(
        extinction_probability = 0,
        quasi_extinction_probability = 0,
        final_median_abundance = 0
      )
      next
    }
    parent_index <- match(parent_id, table$scenario_id)
    if (is.na(parent_index)) {
      stop(
        "Family comparison requires the appropriate parent run for `",
        table$scenario_id[[index]], "`.",
        call. = FALSE
      )
    }
    differences <- c(
      extinction_probability = table$extinction_probability[[index]] -
        table$extinction_probability[[parent_index]],
      quasi_extinction_probability = table$quasi_extinction_probability[[index]] -
        table$quasi_extinction_probability[[parent_index]],
      final_median_abundance = table$final_median_abundance[[index]] -
        table$final_median_abundance[[parent_index]]
    )
    table$delta_extinction_probability[[index]] <- differences[[1L]]
    table$delta_quasi_extinction_probability[[index]] <- differences[[2L]]
    table$delta_final_median_abundance[[index]] <- differences[[3L]]
    runs[[index]]$difference_from_parent$status <- "computed"
    runs[[index]]$difference_from_parent$outcomes <- as.list(differences)
  }
  list(table = table, runs = runs)
}

#' Compare a compact Woodhen investigation family
#'
#' @param runs Compact Woodhen runs including every selected run's parent.
#' @param family_id Family identifier for the comparison record.
#' @param allow_awkward Permit an incompatible comparison when explicitly annotated.
#' @param awkward_annotation Required explanation for an incompatible comparison.
#' @return A `woodhen_run_family_comparison` with parent-relative outcomes.
compare_woodhen_run_family <- function(runs,
                                       family_id,
                                       allow_awkward = FALSE,
                                       awkward_annotation = NULL) {
  if (!is.list(runs) || length(runs) == 0L) {
    stop("`runs` must be a non-empty list of compact Woodhen runs.", call. = FALSE)
  }
  lapply(runs, woodhen_validate_compact_run)
  if (!is.character(family_id) || length(family_id) != 1L || is.na(family_id) ||
      !nzchar(family_id)) {
    stop("`family_id` must be one non-empty character value.", call. = FALSE)
  }
  if (!is.logical(allow_awkward) || length(allow_awkward) != 1L || is.na(allow_awkward)) {
    stop("`allow_awkward` must be TRUE or FALSE.", call. = FALSE)
  }
  scenario_ids <- vapply(runs, `[[`, character(1), "scenario_id")
  if (anyDuplicated(scenario_ids)) {
    stop("Family comparison requires unique scenario runs.", call. = FALSE)
  }
  issues <- woodhen_family_compatibility_issues(runs, family_id)
  awkward <- length(issues) > 0L
  if (awkward && !allow_awkward) {
    stop(
      "The runs are scientifically incompatible: ",
      paste(issues, collapse = "; "),
      ". Use the explicitly annotated awkward-comparison path to continue.",
      call. = FALSE
    )
  }
  if (awkward) {
    valid_annotation <- is.character(awkward_annotation) &&
      length(awkward_annotation) == 1L && !is.na(awkward_annotation) &&
      nzchar(trimws(awkward_annotation))
    if (!valid_annotation) {
      stop("An awkward comparison requires a non-empty `awkward_annotation`.", call. = FALSE)
    }
  }

  table <- do.call(rbind, lapply(runs, woodhen_run_metric_row))
  rownames(table) <- NULL
  differences <- woodhen_add_parent_differences(table, runs)
  table <- differences$table
  runs <- differences$runs
  family_type <- if (all(table$scenario_type %in% c("locked_baseline", "sensitivity"))) {
    "sensitivity"
  } else {
    "prospective"
  }
  table$setting_value <- if (identical(family_type, "sensitivity")) {
    woodhen_sensitivity_setting_values(runs)
  } else {
    NA_real_
  }

  structure(
    list(
      comparison_schema_version = "woodhen-run-family-comparison-v1",
      family_id = family_id,
      family_type = family_type,
      runs = runs,
      table = table,
      awkward_comparison = awkward,
      compatibility_issues = issues,
      awkward_annotation = if (awkward) awkward_annotation else NULL
    ),
    class = c("woodhen_run_family_comparison", "list")
  )
}
