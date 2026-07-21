woodhen_project_schema_version <- function() {
  "woodhen-project-v1"
}

woodhen_project_package_format_version <- function() {
  "woodhen-project-package-v1"
}

woodhen_app_version <- function() {
  description <- tryCatch(
    utils::packageDescription("rPVA"),
    error = function(e) NULL
  )
  if (!is.null(description) && is.character(description$Version) &&
      length(description$Version) == 1L && nzchar(description$Version)) {
    return(description$Version)
  }
  if (file.exists("DESCRIPTION")) {
    value <- read.dcf("DESCRIPTION", fields = "Version")[[1L]]
    if (is.character(value) && length(value) == 1L && nzchar(value)) {
      return(value)
    }
  }
  stop("The rPVA DESCRIPTION version is unavailable.", call. = FALSE)
}

woodhen_project_time <- function(value, field) {
  normalized <- woodhen_normalize_record_time(value, field)
  if (is.na(normalized)) {
    stop("`", field, "` cannot be missing.", call. = FALSE)
  }
  normalized
}

woodhen_project_scalar_text <- function(value, field, optional = FALSE) {
  if (optional && is.null(value)) {
    return(NULL)
  }
  if (!is.character(value) || length(value) != 1L || is.na(value) || !nzchar(value)) {
    stop("`", field, "` must be one non-empty character value", if (optional) " or NULL" else "", ".", call. = FALSE)
  }
  enc2utf8(value)
}

woodhen_project_new_id <- function(kind, now) {
  nonce <- basename(tempfile(pattern = paste0("woodhen-", kind, "-")))
  suffix <- substr(woodhen_content_fingerprint(list(
    kind = kind,
    created_at = now,
    process_id = Sys.getpid(),
    nonce = nonce
  )), 1L, 16L)
  paste0("woodhen_", kind, "_", suffix)
}

woodhen_project_condition <- function(message,
                                      discovered_version,
                                      version_field,
                                      supported_version) {
  structure(
    list(
      message = message,
      call = NULL,
      discovered_version = discovered_version,
      version_field = version_field,
      supported_version = supported_version
    ),
    class = c("woodhen_unsupported_version", "error", "condition")
  )
}

woodhen_stop_unsupported_version <- function(discovered, field, supported) {
  stop(woodhen_project_condition(
    paste0(
      "Unsupported `", field, "` value `", discovered,
      "`; this reader supports `", supported, "`."
    ),
    discovered_version = discovered,
    version_field = field,
    supported_version = supported
  ))
}

woodhen_project_validate_version <- function(value, field, supported) {
  if (!is.character(value) || length(value) != 1L || is.na(value) ||
      !identical(value, supported)) {
    discovered <- if (length(value) == 0L) {
      "<missing>"
    } else {
      paste(as.character(value), collapse = ",")
    }
    woodhen_stop_unsupported_version(discovered, field, supported)
  }
  invisible(value)
}

woodhen_project_validate_scenario_record <- function(scenario) {
  if (is.list(scenario) && "record_schema_version" %in% names(scenario)) {
    woodhen_project_validate_version(
      scenario$record_schema_version,
      "record_schema_version",
      "woodhen-scenario-record-v1"
    )
  }
  woodhen_validate_scenario_record(scenario)
}

woodhen_project_fields <- function() {
  c(
    "project_schema_version", "project_id", "title", "owner_label",
    "created_at", "modified_at", "app_version", "model_version",
    "reference_library_version", "catalog_version", "scenarios",
    "scenario_versions", "runs", "observations", "evidence_ids",
    "provenance", "fingerprint_algorithm", "canonicalization_version",
    "project_fingerprint"
  )
}

woodhen_project_refresh <- function(project, now) {
  project$modified_at <- woodhen_project_time(now, "now")
  project$project_fingerprint <- woodhen_project_fingerprint(project)
  validate_woodhen_project(project)
  project
}

#' Create a local-first Woodhen investigation project
#'
#' @param title Optional project title.
#' @param owner_label Optional identity-light owner label.
#' @param now Project creation time.
#' @return A validated `woodhen_project` list.
#' @export
new_woodhen_project <- function(title = NULL, owner_label = NULL, now = Sys.time()) {
  timestamp <- woodhen_project_time(now, "now")
  project <- structure(
    list(
      project_schema_version = woodhen_project_schema_version(),
      project_id = woodhen_project_new_id("project", timestamp),
      title = woodhen_project_scalar_text(title, "title", optional = TRUE),
      owner_label = woodhen_project_scalar_text(owner_label, "owner_label", optional = TRUE),
      created_at = timestamp,
      modified_at = timestamp,
      app_version = woodhen_app_version(),
      model_version = woodhen_model_version(),
      reference_library_version = woodhen_reference_library_version(),
      catalog_version = woodhen_investigation_catalog_version(),
      scenarios = list(),
      scenario_versions = list(),
      runs = list(),
      observations = list(),
      evidence_ids = character(),
      provenance = list(imports = list(), exports = list()),
      fingerprint_algorithm = "sha256",
      canonicalization_version = "woodhen-project-canonical-v1",
      project_fingerprint = NA_character_
    ),
    class = c("woodhen_project", "list")
  )
  project$project_fingerprint <- woodhen_project_fingerprint(project)
  validate_woodhen_project(project)
  project
}

#' Compute the stable fingerprint of a Woodhen project
#'
#' Import and export provenance is intentionally excluded because it is volatile.
#'
#' @param project A Woodhen project list.
#' @return A SHA-256 fingerprint.
#' @export
woodhen_project_fingerprint <- function(project) {
  if (!is.list(project) || is.null(names(project)) || anyDuplicated(names(project))) {
    stop("`project` must be a named project list.", call. = FALSE)
  }
  stable <- project
  stable$project_fingerprint <- NULL
  stable$provenance <- NULL
  class(stable) <- NULL
  woodhen_content_fingerprint(stable)
}

woodhen_project_validate_id <- function(value, pattern, field) {
  valid <- is.character(value) && length(value) == 1L && !is.na(value) &&
    grepl(pattern, value, perl = TRUE)
  if (!valid) {
    stop("`", field, "` is malformed.", call. = FALSE)
  }
  invisible(value)
}

woodhen_project_integer <- function(value, field, minimum = 0L, maximum = Inf) {
  valid <- is.integer(value) && length(value) == 1L && !is.na(value) &&
    value >= minimum && value <= maximum
  if (!valid) {
    stop("`", field, "` must be one bounded integer.", call. = FALSE)
  }
  invisible(value)
}

woodhen_project_number <- function(value,
                                   field,
                                   minimum = -Inf,
                                   maximum = Inf,
                                   allow_na = FALSE) {
  valid <- is.numeric(value) && length(value) == 1L && is.null(dim(value)) &&
    ((allow_na && is.na(value)) ||
      (!is.na(value) && is.finite(value) && value >= minimum && value <= maximum))
  if (!valid) {
    stop("`", field, "` must be one bounded finite number", if (allow_na) " or NA" else "", ".", call. = FALSE)
  }
  invisible(value)
}

woodhen_project_validate_data_frame <- function(value, fields, path) {
  if (!is.data.frame(value) || anyDuplicated(names(value)) ||
      !identical(names(value), fields) || anyNA(names(value))) {
    stop("`", path, "` must be a data frame with exactly the supported columns.", call. = FALSE)
  }
  invisible(value)
}

woodhen_project_validate_probability_evidence <- function(value,
                                                          crossed_field,
                                                          first_field,
                                                          reps,
                                                          horizon,
                                                          path) {
  expected <- c(
    "total_reps", crossed_field, "probability_by_horizon", first_field,
    "cumulative", "conditional_median_year", "overall_median_year"
  )
  woodhen_require_exact_fields(value, expected, path)
  woodhen_project_integer(value$total_reps, paste0(path, "$total_reps"), 1L)
  woodhen_project_integer(value[[crossed_field]], paste0(path, "$", crossed_field), 0L, reps)
  if (!identical(value$total_reps, reps)) {
    stop("`", path, "$total_reps` does not match the run.", call. = FALSE)
  }
  woodhen_project_number(
    value$probability_by_horizon,
    paste0(path, "$probability_by_horizon"),
    0, 1
  )
  first <- value[[first_field]]
  if (!is.integer(first) || length(first) != reps ||
      any(!is.na(first) & (first < 0L | first > horizon))) {
    stop("`", path, "$", first_field, "` is not replicate-matched.", call. = FALSE)
  }
  woodhen_project_validate_data_frame(
    value$cumulative,
    c("year", "probability"),
    paste0(path, "$cumulative")
  )
  if (!identical(value$cumulative$year, 0:horizon) ||
      !is.numeric(value$cumulative$probability) ||
      length(value$cumulative$probability) != horizon + 1L ||
      any(!is.finite(value$cumulative$probability)) ||
      any(value$cumulative$probability < 0 | value$cumulative$probability > 1) ||
      any(diff(value$cumulative$probability) < 0)) {
    stop("`", path, "$cumulative` is not a bounded cumulative series.", call. = FALSE)
  }
  if (!isTRUE(all.equal(
    tail(value$cumulative$probability, 1L),
    value$probability_by_horizon,
    tolerance = 0,
    check.attributes = FALSE
  ))) {
    stop("`", path, "` has inconsistent horizon probability.", call. = FALSE)
  }
  woodhen_project_number(
    value$conditional_median_year,
    paste0(path, "$conditional_median_year"),
    0, horizon,
    allow_na = TRUE
  )
  woodhen_project_number(
    value$overall_median_year,
    paste0(path, "$overall_median_year"),
    0, horizon,
    allow_na = TRUE
  )
  observed <- first[!is.na(first)]
  expected_count <- as.integer(length(observed))
  expected_cumulative <- vapply(0:horizon, function(year) {
    mean(!is.na(first) & first <= year)
  }, numeric(1))
  expected_probability <- as.numeric(tail(expected_cumulative, 1L))
  expected_conditional <- if (length(observed)) {
    as.numeric(stats::median(observed))
  } else {
    NA_real_
  }
  expected_overall <- if (expected_probability >= 0.5) {
    as.numeric(which(expected_cumulative >= 0.5)[[1L]] - 1L)
  } else {
    NA_real_
  }
  if (!identical(value[[crossed_field]], expected_count) ||
      !identical(value$probability_by_horizon, expected_probability) ||
      !identical(as.numeric(value$cumulative$probability), expected_cumulative) ||
      !identical(value$conditional_median_year, expected_conditional) ||
      !identical(value$overall_median_year, expected_overall)) {
    stop("`", path, "` does not match its retained first-passage evidence.", call. = FALSE)
  }
  invisible(list(
    first = first,
    crossed = !is.na(first),
    count = expected_count,
    probability = expected_probability
  ))
}

woodhen_project_run_fields <- function() {
  c(
    "run_schema_version", "run_id", "scenario", "scenario_id", "family_id",
    "student_label", "scenario_type", "parent_id", "locked_baseline_id",
    "spec_fingerprint", "scientific_identity_fingerprint",
    "baseline_spec_fingerprint", "seed", "reps", "horizon", "summary",
    "diagnostics", "final_abundance", "annual_quantiles",
    "sampled_replicate_indices", "trajectory_sample", "extinction_evidence",
    "quasi_extinction_50_pairs", "difference_from_parent", "provenance"
  )
}

woodhen_project_validate_run <- function(run) {
  if (!inherits(run, "woodhen_compact_run")) {
    stop("Every `runs` entry must inherit from `woodhen_compact_run`.", call. = FALSE)
  }
  woodhen_require_exact_fields(run, woodhen_project_run_fields(), "run")
  woodhen_project_validate_version(
    run$run_schema_version,
    "run_schema_version",
    "woodhen-compact-run-v1"
  )
  woodhen_project_validate_id(run$run_id, "^woodhen_run_[0-9a-f]{16}$", "run$run_id")
  woodhen_project_validate_scenario_record(run$scenario)
  woodhen_project_integer(run$seed, "run$seed", 0L, .Machine$integer.max)
  woodhen_project_integer(run$reps, "run$reps", 1L, 1000000L)
  woodhen_project_integer(run$horizon, "run$horizon", 1L, 10000L)

  mirrored <- c(
    "scenario_id", "family_id", "student_label", "scenario_type", "parent_id",
    "locked_baseline_id", "spec_fingerprint", "scientific_identity_fingerprint"
  )
  if (any(!vapply(mirrored, function(field) {
    identical(run[[field]], run$scenario[[field]])
  }, logical(1)))) {
    stop("Run scenario identity fields do not match the embedded scenario.", call. = FALSE)
  }
  if (!identical(run$reps, as.integer(run$scenario$spec$reps)) ||
      !identical(run$horizon, as.integer(run$scenario$spec$years))) {
    stop("Run dimensions do not match the embedded scenario.", call. = FALSE)
  }
  expected_run_id <- paste0(
    "woodhen_run_",
    substr(woodhen_content_fingerprint(list(
      scenario_id = run$scenario_id,
      scientific_identity_fingerprint = run$scientific_identity_fingerprint,
      seed = run$seed,
      reps = run$reps
    )), 1L, 16L)
  )
  if (!identical(run$run_id, expected_run_id)) {
    stop("`run$run_id` does not match its scientific run identity.", call. = FALSE)
  }
  for (field in c(
    "baseline_spec_fingerprint", "spec_fingerprint",
    "scientific_identity_fingerprint"
  )) {
    woodhen_project_validate_id(run[[field]], "^[0-9a-f]{64}$", paste0("run$", field))
  }
  if (!identical(
    run$baseline_spec_fingerprint,
    woodhen_spec_fingerprint(woodhen_locked_future_spec())
  )) {
    stop("`run$baseline_spec_fingerprint` does not match the locked baseline.", call. = FALSE)
  }

  woodhen_project_validate_data_frame(
    run$summary,
    c(
      "scenario", "years", "reps", "PE", "Nmed", "Nlo95", "Nhi95",
      "extinct_reps", "surviving_reps", "trajectory_available"
    ),
    "run$summary"
  )
  if (nrow(run$summary) != 1L || !identical(run$summary$years, run$horizon) ||
      !identical(run$summary$reps, run$reps)) {
    stop("`run$summary` is not dimension-matched.", call. = FALSE)
  }
  summary <- run$summary
  valid_summary <- is.character(summary$scenario) && !is.na(summary$scenario) &&
    identical(summary$scenario, run$student_label) &&
    is.double(summary$PE) && is.finite(summary$PE) &&
    summary$PE >= 0 && summary$PE <= 1 &&
    all(vapply(summary[c("Nmed", "Nlo95", "Nhi95")], function(value) {
      is.double(value) && length(value) == 1L && is.finite(value) && value >= 0
    }, logical(1))) &&
    is.integer(summary$extinct_reps) && summary$extinct_reps >= 0L &&
    summary$extinct_reps <= run$reps &&
    is.integer(summary$surviving_reps) && summary$surviving_reps >= 0L &&
    summary$surviving_reps <= run$reps &&
    identical(summary$extinct_reps + summary$surviving_reps, run$reps) &&
    is.logical(summary$trajectory_available) && length(summary$trajectory_available) == 1L &&
    !is.na(summary$trajectory_available) && summary$trajectory_available
  if (!valid_summary) {
    stop("`run$summary` contains invalid or out-of-range compact evidence.", call. = FALSE)
  }
  woodhen_project_validate_data_frame(
    run$diagnostics,
    c("scenario", "code", "severity", "message"),
    "run$diagnostics"
  )
  if (any(!vapply(run$diagnostics, is.character, logical(1)))) {
    stop("`run$diagnostics` columns must be plain text.", call. = FALSE)
  }

  woodhen_require_exact_fields(
    run$final_abundance,
    c("values", "median", "q025", "q25", "q75", "q975"),
    "run$final_abundance"
  )
  if (!is.double(run$final_abundance$values) ||
      length(run$final_abundance$values) != run$reps ||
      any(!is.finite(run$final_abundance$values)) ||
      any(run$final_abundance$values < 0)) {
    stop("`run$final_abundance$values` is not replicate-matched.", call. = FALSE)
  }
  for (field in c("median", "q025", "q25", "q75", "q975")) {
    woodhen_project_number(run$final_abundance[[field]], paste0("run$final_abundance$", field), 0)
  }
  expected_final <- stats::quantile(
    run$final_abundance$values,
    probs = c(0.025, 0.25, 0.50, 0.75, 0.975),
    names = FALSE,
    type = 7
  )
  stored_final <- unlist(run$final_abundance[c("q025", "q25", "median", "q75", "q975")])
  if (!identical(as.numeric(stored_final), as.numeric(expected_final))) {
    stop("`run$final_abundance` quantiles do not match the retained values.", call. = FALSE)
  }

  quantile_fields <- c("year", "q025", "q25", "median", "q75", "q975")
  woodhen_project_validate_data_frame(run$annual_quantiles, quantile_fields, "run$annual_quantiles")
  if (!identical(run$annual_quantiles$year, 0:run$horizon) ||
      any(!vapply(run$annual_quantiles[-1L], function(value) {
        is.double(value) && length(value) == run$horizon + 1L &&
          all(is.finite(value)) && all(value >= 0)
      }, logical(1)))) {
    stop("`run$annual_quantiles` is not horizon-matched.", call. = FALSE)
  }
  annual_values <- as.matrix(run$annual_quantiles[-1L])
  if (any(apply(annual_values, 1L, function(value) any(diff(value) < 0)))) {
    stop("`run$annual_quantiles` has out-of-order quantiles.", call. = FALSE)
  }
  expected_final_row <- as.numeric(unlist(run$final_abundance[c(
    "q025", "q25", "median", "q75", "q975"
  )]))
  if (!identical(as.numeric(annual_values[nrow(annual_values), ]), expected_final_row)) {
    stop("The final `run$annual_quantiles` row does not match final abundance.", call. = FALSE)
  }

  indices <- run$sampled_replicate_indices
  if (!is.integer(indices) || length(indices) < 1L || anyNA(indices) ||
      any(indices < 1L | indices > run$reps) || anyDuplicated(indices) || is.unsorted(indices)) {
    stop("`run$sampled_replicate_indices` is invalid.", call. = FALSE)
  }
  woodhen_project_validate_data_frame(
    run$trajectory_sample,
    c("year", "replicate_index", "abundance"),
    "run$trajectory_sample"
  )
  expected_rows <- length(indices) * (run$horizon + 1L)
  sample_keys <- paste(
    run$trajectory_sample$replicate_index,
    run$trajectory_sample$year,
    sep = ":"
  )
  expected_keys <- paste(
    rep(indices, each = run$horizon + 1L),
    rep(0:run$horizon, times = length(indices)),
    sep = ":"
  )
  if (nrow(run$trajectory_sample) != expected_rows ||
      !is.integer(run$trajectory_sample$year) ||
      !is.integer(run$trajectory_sample$replicate_index) ||
      !is.double(run$trajectory_sample$abundance) ||
      any(!is.finite(run$trajectory_sample$abundance)) ||
      any(run$trajectory_sample$abundance < 0) ||
      !identical(sort(unique(run$trajectory_sample$replicate_index)), indices) ||
      anyDuplicated(sample_keys) || !setequal(sample_keys, expected_keys)) {
    stop("`run$trajectory_sample` is not sample-matched.", call. = FALSE)
  }
  horizon_sample <- run$trajectory_sample[
    run$trajectory_sample$year == run$horizon,
    c("replicate_index", "abundance")
  ]
  horizon_sample <- horizon_sample[match(indices, horizon_sample$replicate_index), ]
  if (!identical(
    as.numeric(horizon_sample$abundance),
    as.numeric(run$final_abundance$values[indices])
  )) {
    stop("The sampled horizon trajectory does not match final abundance.", call. = FALSE)
  }

  woodhen_project_validate_probability_evidence(
    run$extinction_evidence,
    "extinct_reps",
    "first_extinction_year",
    run$reps,
    run$horizon,
    "run$extinction_evidence"
  )
  if (!identical(summary$extinct_reps, run$extinction_evidence$extinct_reps) ||
      !identical(summary$surviving_reps, run$reps - summary$extinct_reps) ||
      !identical(summary$PE, run$extinction_evidence$probability_by_horizon) ||
      !identical(summary$Nmed, run$final_abundance$median) ||
      !identical(summary$Nlo95, run$final_abundance$q025) ||
      !identical(summary$Nhi95, run$final_abundance$q975)) {
    stop("`run$summary` does not match the retained compact evidence.", call. = FALSE)
  }
  woodhen_require_exact_fields(
    run$quasi_extinction_50_pairs,
    c(
      "threshold_pairs", "holder_stages", "total_reps", "crossed_reps",
      "probability_by_horizon", "first_crossing_year", "cumulative",
      "conditional_median_year", "overall_median_year", "minimum_breeding_pairs"
    ),
    "run$quasi_extinction_50_pairs"
  )
  quasi_core <- run$quasi_extinction_50_pairs[c(
    "total_reps", "crossed_reps", "probability_by_horizon",
    "first_crossing_year", "cumulative", "conditional_median_year",
    "overall_median_year"
  )]
  woodhen_project_validate_probability_evidence(
    quasi_core,
    "crossed_reps",
    "first_crossing_year",
    run$reps,
    run$horizon,
    "run$quasi_extinction_50_pairs"
  )
  woodhen_project_integer(
    run$quasi_extinction_50_pairs$threshold_pairs,
    "run$quasi_extinction_50_pairs$threshold_pairs",
    1L
  )
  holder_stages <- run$quasi_extinction_50_pairs$holder_stages
  if (!is.integer(holder_stages) || length(holder_stages) < 1L || anyNA(holder_stages) ||
      any(holder_stages < 1L | holder_stages > length(run$scenario$spec$n0)) ||
      anyDuplicated(holder_stages)) {
    stop("`run$quasi_extinction_50_pairs$holder_stages` is invalid.", call. = FALSE)
  }
  minimum_pairs <- run$quasi_extinction_50_pairs$minimum_breeding_pairs
  if (!is.double(minimum_pairs) || length(minimum_pairs) != run$reps ||
      any(!is.finite(minimum_pairs)) || any(minimum_pairs < 0)) {
    stop("`run$quasi_extinction_50_pairs$minimum_breeding_pairs` is invalid.", call. = FALSE)
  }
  minimum_crossed <- minimum_pairs < run$quasi_extinction_50_pairs$threshold_pairs
  first_crossed <- !is.na(run$quasi_extinction_50_pairs$first_crossing_year)
  if (!identical(minimum_crossed, first_crossed) ||
      !identical(as.integer(sum(minimum_crossed)),
        run$quasi_extinction_50_pairs$crossed_reps)) {
    stop("Quasi-extinction minima do not match the retained first-passage evidence.", call. = FALSE)
  }

  woodhen_require_exact_fields(
    run$difference_from_parent,
    c("parent_id", "status", "specification_changes", "outcomes"),
    "run$difference_from_parent"
  )
  status <- run$difference_from_parent$status
  if (!identical(run$difference_from_parent$parent_id, run$parent_id) ||
      !identical(run$difference_from_parent$specification_changes, run$scenario$changes) ||
      !is.character(status) || length(status) != 1L || is.na(status) ||
      !status %in% c("not_applicable", "pending_comparison", "computed")) {
    stop("`run$difference_from_parent` is inconsistent.", call. = FALSE)
  }
  outcomes <- run$difference_from_parent$outcomes
  if (!is.null(outcomes)) {
    woodhen_require_exact_fields(
      outcomes,
      c("extinction_probability", "quasi_extinction_probability", "final_median_abundance"),
      "run$difference_from_parent$outcomes"
    )
    if (any(!vapply(outcomes, function(value) {
      is.numeric(value) && length(value) == 1L && is.finite(value)
    }, logical(1)))) {
      stop("`run$difference_from_parent$outcomes` must contain finite scalars.", call. = FALSE)
    }
  }
  if (is.na(run$parent_id)) {
    zero_outcomes <- is.null(outcomes) || all(vapply(outcomes, function(value) {
      identical(as.numeric(value), 0)
    }, logical(1)))
    if (!identical(status, "not_applicable") || !zero_outcomes) {
      stop("A parentless run must have a not-applicable zero comparison.", call. = FALSE)
    }
  } else if (identical(status, "pending_comparison")) {
    if (!is.null(outcomes)) {
      stop("A pending parent comparison cannot contain outcomes.", call. = FALSE)
    }
  } else if (!identical(status, "computed") || is.null(outcomes)) {
    stop("A child run must have pending or computed parent comparison evidence.", call. = FALSE)
  }

  woodhen_require_exact_fields(
    run$provenance,
    c(
      "reference_library_version", "catalog_version", "model_version",
      "fingerprint_algorithm", "canonicalization_version"
    ),
    "run$provenance"
  )
  provenance_pairs <- c(
    reference_library_version = "reference_library_version",
    catalog_version = "catalog_version",
    model_version = "model_version",
    fingerprint_algorithm = "fingerprint_algorithm",
    canonicalization_version = "canonicalization_version"
  )
  if (any(!vapply(names(provenance_pairs), function(field) {
    identical(run$provenance[[field]], run$scenario[[provenance_pairs[[field]]]])
  }, logical(1)))) {
    stop("Run provenance does not match the embedded scenario.", call. = FALSE)
  }
  invisible(run)
}

woodhen_project_validate_parent_differences <- function(runs) {
  for (run in runs) {
    difference <- run$difference_from_parent
    if (is.na(run$parent_id) || !identical(difference$status, "computed")) {
      next
    }
    parent_matches <- vapply(runs, function(parent) {
      identical(parent$scenario_id, run$parent_id) &&
        identical(parent$family_id, run$family_id) &&
        identical(parent$seed, run$seed) &&
        identical(parent$reps, run$reps) &&
        identical(parent$horizon, run$horizon) &&
        identical(parent$baseline_spec_fingerprint, run$baseline_spec_fingerprint)
    }, logical(1))
    parents <- runs[parent_matches]
    if (length(parents) == 0L) {
      next
    }
    if (length(parents) != 1L) {
      stop("A computed parent comparison has ambiguous parent evidence.", call. = FALSE)
    }
    parent <- parents[[1L]]
    expected <- list(
      extinction_probability =
        run$extinction_evidence$probability_by_horizon -
        parent$extinction_evidence$probability_by_horizon,
      quasi_extinction_probability =
        run$quasi_extinction_50_pairs$probability_by_horizon -
        parent$quasi_extinction_50_pairs$probability_by_horizon,
      final_median_abundance =
        run$final_abundance$median - parent$final_abundance$median
    )
    if (!identical(difference$outcomes, expected)) {
      stop("Computed difference-from-parent outcomes do not match retained evidence.", call. = FALSE)
    }
  }
  invisible(runs)
}

woodhen_project_validate_scenario_version <- function(value, scenario_ids, versions, index) {
  path <- paste0("project$scenario_versions[[", index, "]]")
  woodhen_require_exact_fields(
    value,
    c(
      "scenario_version_schema", "scenario_id", "scenario_version",
      "supersedes_scenario_id", "added_at"
    ),
    path
  )
  woodhen_project_validate_version(
    value$scenario_version_schema,
    "scenario_version_schema",
    "woodhen-project-scenario-version-v1"
  )
  if (!identical(value$scenario_id, scenario_ids[[index]])) {
    stop("Scenario-version records must align one-to-one with scenarios.", call. = FALSE)
  }
  woodhen_project_integer(value$scenario_version, paste0(path, "$scenario_version"), 1L)
  woodhen_project_time(value$added_at, paste0(path, "$added_at"))
  supersedes <- value$supersedes_scenario_id
  if (is.null(supersedes)) {
    if (!identical(value$scenario_version, 1L)) {
      stop("A first scenario version must have version 1.", call. = FALSE)
    }
  } else {
    woodhen_project_scalar_text(supersedes, paste0(path, "$supersedes_scenario_id"))
    prior <- match(supersedes, scenario_ids)
    if (is.na(prior) || prior >= index) {
      stop("A superseded scenario must be an earlier project scenario.", call. = FALSE)
    }
    if (!identical(value$scenario_version, versions[[prior]] + 1L)) {
      stop("Scenario version numbers must follow their supersession ancestry.", call. = FALSE)
    }
  }
  invisible(value)
}

woodhen_project_validate_observation <- function(value, run_ids) {
  woodhen_require_exact_fields(
    value,
    c(
      "observation_schema_version", "observation_id", "title", "note",
      "run_ids", "created_at", "modified_at"
    ),
    "observation"
  )
  woodhen_project_validate_version(
    value$observation_schema_version,
    "observation_schema_version",
    "woodhen-observation-v1"
  )
  woodhen_project_validate_id(
    value$observation_id,
    "^woodhen_observation_[0-9a-f]{16}$",
    "observation$observation_id"
  )
  woodhen_project_scalar_text(value$title, "observation$title")
  woodhen_project_scalar_text(value$note, "observation$note")
  if (!is.character(value$run_ids) || length(value$run_ids) < 1L ||
      anyNA(value$run_ids) || any(!nzchar(value$run_ids)) || anyDuplicated(value$run_ids)) {
    stop("`observation$run_ids` must be an ordered duplicate-free run ID vector.", call. = FALSE)
  }
  unknown <- setdiff(value$run_ids, run_ids)
  if (length(unknown)) {
    stop("Unknown run ID in observation: ", unknown[[1L]], call. = FALSE)
  }
  woodhen_project_time(value$created_at, "observation$created_at")
  woodhen_project_time(value$modified_at, "observation$modified_at")
  invisible(value)
}

woodhen_project_validate_provenance <- function(provenance) {
  woodhen_require_exact_fields(provenance, c("imports", "exports"), "project$provenance")
  if (!is.list(provenance$imports) || !is.list(provenance$exports)) {
    stop("Project import/export provenance must use event lists.", call. = FALSE)
  }
  for (event in provenance$imports) {
    woodhen_require_exact_fields(
      event,
      c(
        "event_schema_version", "imported_at", "package_format_version",
        "source_project_id", "source_project_fingerprint"
      ),
      "project$provenance$imports event"
    )
    woodhen_project_validate_version(
      event$event_schema_version,
      "event_schema_version",
      "woodhen-import-event-v1"
    )
    woodhen_project_validate_version(
      event$package_format_version,
      "package_format_version",
      woodhen_project_package_format_version()
    )
    woodhen_project_time(event$imported_at, "imported_at")
    woodhen_project_validate_id(event$source_project_id, "^woodhen_project_[0-9a-f]{16}$", "source_project_id")
    woodhen_project_validate_id(event$source_project_fingerprint, "^[0-9a-f]{64}$", "source_project_fingerprint")
  }
  for (event in provenance$exports) {
    woodhen_require_exact_fields(
      event,
      c("event_schema_version", "exported_at", "package_format_version", "app_version"),
      "project$provenance$exports event"
    )
    woodhen_project_validate_version(
      event$event_schema_version,
      "event_schema_version",
      "woodhen-export-event-v1"
    )
    woodhen_project_validate_version(
      event$package_format_version,
      "package_format_version",
      woodhen_project_package_format_version()
    )
    woodhen_project_time(event$exported_at, "exported_at")
    woodhen_project_scalar_text(event$app_version, "app_version")
  }
  invisible(provenance)
}

#' Validate a local-first Woodhen investigation project
#'
#' @param project A project candidate.
#' @return The input invisibly, or an error.
#' @export
validate_woodhen_project <- function(project) {
  if (!inherits(project, "woodhen_project")) {
    stop("`project` must inherit from `woodhen_project`.", call. = FALSE)
  }
  woodhen_require_exact_fields(project, woodhen_project_fields(), "project")
  woodhen_project_validate_version(
    project$project_schema_version,
    "project_schema_version",
    woodhen_project_schema_version()
  )
  woodhen_project_validate_id(project$project_id, "^woodhen_project_[0-9a-f]{16}$", "project$project_id")
  woodhen_project_scalar_text(project$title, "project$title", optional = TRUE)
  woodhen_project_scalar_text(project$owner_label, "project$owner_label", optional = TRUE)
  woodhen_project_time(project$created_at, "project$created_at")
  woodhen_project_time(project$modified_at, "project$modified_at")
  for (field in c(
    "app_version", "model_version", "reference_library_version", "catalog_version",
    "fingerprint_algorithm", "canonicalization_version"
  )) {
    woodhen_project_scalar_text(project[[field]], paste0("project$", field))
  }
  if (!identical(project$fingerprint_algorithm, "sha256") ||
      !identical(project$canonicalization_version, "woodhen-project-canonical-v1")) {
    stop("The project fingerprint metadata is unsupported.", call. = FALSE)
  }
  if (any(!vapply(
    project[c("scenarios", "scenario_versions", "runs", "observations")],
    is.list,
    logical(1)
  ))) {
    stop("Project record collections must be lists.", call. = FALSE)
  }
  if (length(project$scenarios) != length(project$scenario_versions)) {
    stop("Scenarios and scenario-version records must align one-to-one.", call. = FALSE)
  }

  lapply(project$scenarios, woodhen_project_validate_scenario_record)
  scenario_ids <- vapply(project$scenarios, `[[`, character(1), "scenario_id")
  if (anyDuplicated(scenario_ids)) {
    stop("Project scenario IDs must be unique.", call. = FALSE)
  }
  if (length(project$scenarios)) {
    for (scenario in project$scenarios) {
      if (!is.na(scenario$parent_id) && !scenario$parent_id %in% scenario_ids) {
        stop("Scenario scientific parent is absent from the project: ", scenario$parent_id, call. = FALSE)
      }
      if (!identical(scenario$reference_library_version, project$reference_library_version) ||
          !identical(scenario$catalog_version, project$catalog_version) ||
          !identical(scenario$model_version, project$model_version)) {
        stop("Scenario version metadata does not match the project.", call. = FALSE)
      }
    }
    versions <- vapply(project$scenario_versions, `[[`, integer(1), "scenario_version")
    for (index in seq_along(project$scenario_versions)) {
      woodhen_project_validate_scenario_version(
        project$scenario_versions[[index]],
        scenario_ids,
        versions,
        index
      )
    }
  }

  lapply(project$runs, woodhen_project_validate_run)
  run_ids <- vapply(project$runs, `[[`, character(1), "run_id")
  if (anyDuplicated(run_ids)) {
    stop("Project run IDs must be unique.", call. = FALSE)
  }
  for (run in project$runs) {
    scenario_index <- match(run$scenario_id, scenario_ids)
    if (is.na(scenario_index) ||
        !identical(
          woodhen_content_fingerprint(run$scenario),
          woodhen_content_fingerprint(project$scenarios[[scenario_index]])
        )) {
      stop("Every run must retain the matching immutable project scenario.", call. = FALSE)
    }
  }
  woodhen_project_validate_parent_differences(project$runs)

  lapply(project$observations, woodhen_project_validate_observation, run_ids = run_ids)
  observation_ids <- vapply(project$observations, `[[`, character(1), "observation_id")
  if (anyDuplicated(observation_ids)) {
    stop("Project observation IDs must be unique.", call. = FALSE)
  }
  if (!is.character(project$evidence_ids) || anyNA(project$evidence_ids) ||
      any(!nzchar(project$evidence_ids)) || anyDuplicated(project$evidence_ids)) {
    stop("Project evidence IDs must be an ordered duplicate-free character vector.", call. = FALSE)
  }
  evidence_namespace <- c(run_ids, observation_ids)
  unknown_evidence <- setdiff(project$evidence_ids, evidence_namespace)
  if (length(unknown_evidence)) {
    stop("Unknown evidence ID: ", unknown_evidence[[1L]], call. = FALSE)
  }
  woodhen_project_validate_provenance(project$provenance)
  woodhen_project_validate_id(project$project_fingerprint, "^[0-9a-f]{64}$", "project$project_fingerprint")
  if (!identical(project$project_fingerprint, woodhen_project_fingerprint(project))) {
    stop("`project$project_fingerprint` does not match the stable project content.", call. = FALSE)
  }
  invisible(project)
}

#' Add an immutable scenario record to a Woodhen project
#'
#' @param project A validated project.
#' @param scenario A Task 3 scenario record.
#' @param now Modification time.
#' @param supersedes_scenario_id Optional project-only scenario ancestry link.
#' @return A new validated project list.
#' @export
add_woodhen_scenario <- function(project,
                                 scenario,
                                 now = Sys.time(),
                                 supersedes_scenario_id = NULL) {
  validate_woodhen_project(project)
  woodhen_project_validate_scenario_record(scenario)
  timestamp <- woodhen_project_time(now, "now")
  if (!identical(scenario$reference_library_version, project$reference_library_version) ||
      !identical(scenario$catalog_version, project$catalog_version) ||
      !identical(scenario$model_version, project$model_version)) {
    stop("Scenario version metadata does not match the project.", call. = FALSE)
  }
  scenario_ids <- vapply(project$scenarios, `[[`, character(1), "scenario_id")
  existing <- match(scenario$scenario_id, scenario_ids)
  if (!is.na(existing)) {
    if (!identical(project$scenarios[[existing]], scenario)) {
      stop("Scenario ID collision with different content.", call. = FALSE)
    }
    existing_supersedes <- project$scenario_versions[[existing]]$supersedes_scenario_id
    if (!is.null(supersedes_scenario_id) &&
        !identical(existing_supersedes, supersedes_scenario_id)) {
      stop("Scenario ID collision with different supersession ancestry.", call. = FALSE)
    }
    return(project)
  }
  if (!is.na(scenario$parent_id) && !scenario$parent_id %in% scenario_ids) {
    stop("Scenario scientific parent is absent from the project: ", scenario$parent_id, call. = FALSE)
  }
  supersedes_index <- NA_integer_
  if (!is.null(supersedes_scenario_id)) {
    woodhen_project_scalar_text(supersedes_scenario_id, "supersedes_scenario_id")
    supersedes_index <- match(supersedes_scenario_id, scenario_ids)
    if (is.na(supersedes_index)) {
      stop("Unknown superseded scenario ID: ", supersedes_scenario_id, call. = FALSE)
    }
  }
  scenario_version <- if (is.na(supersedes_index)) {
    1L
  } else {
    project$scenario_versions[[supersedes_index]]$scenario_version + 1L
  }
  candidate <- project
  candidate$scenarios[[length(candidate$scenarios) + 1L]] <- scenario
  candidate$scenario_versions[[length(candidate$scenario_versions) + 1L]] <- list(
    scenario_version_schema = "woodhen-project-scenario-version-v1",
    scenario_id = scenario$scenario_id,
    scenario_version = as.integer(scenario_version),
    supersedes_scenario_id = supersedes_scenario_id,
    added_at = timestamp
  )
  woodhen_project_refresh(candidate, timestamp)
}

#' Add compact immutable run evidence to a Woodhen project
#'
#' @param project A validated project.
#' @param run A Task 4 compact run.
#' @param now Modification time.
#' @return A new validated project list, or the original for an identical run.
#' @export
add_woodhen_run <- function(project, run, now = Sys.time()) {
  validate_woodhen_project(project)
  woodhen_project_validate_run(run)
  run_ids <- vapply(project$runs, `[[`, character(1), "run_id")
  existing <- match(run$run_id, run_ids)
  if (!is.na(existing)) {
    if (identical(project$runs[[existing]], run)) {
      return(project)
    }
    stop("Run ID collision with different content.", call. = FALSE)
  }
  scenario_ids <- vapply(project$scenarios, `[[`, character(1), "scenario_id")
  scenario_index <- match(run$scenario_id, scenario_ids)
  if (is.na(scenario_index)) {
    stop("Run scenario is absent from the project: ", run$scenario_id, call. = FALSE)
  }
  if (!identical(
    woodhen_content_fingerprint(run$scenario),
    woodhen_content_fingerprint(project$scenarios[[scenario_index]])
  )) {
    stop("Run scenario content differs from the immutable project scenario.", call. = FALSE)
  }
  candidate <- project
  candidate$runs[[length(candidate$runs) + 1L]] <- run
  woodhen_project_refresh(candidate, now)
}

#' Add a plain-text observation linked to existing run evidence
#'
#' @param project A validated project.
#' @param observation A list containing exactly `title`, `note`, and `run_ids`.
#' @param now Observation creation time.
#' @return A new validated project list.
#' @export
add_woodhen_observation <- function(project, observation, now = Sys.time()) {
  validate_woodhen_project(project)
  woodhen_require_exact_fields(observation, c("title", "note", "run_ids"), "observation")
  title <- woodhen_project_scalar_text(observation$title, "observation$title")
  note <- woodhen_project_scalar_text(observation$note, "observation$note")
  run_ids <- observation$run_ids
  if (!is.character(run_ids) || length(run_ids) < 1L || anyNA(run_ids) ||
      any(!nzchar(run_ids)) || anyDuplicated(run_ids)) {
    stop("`observation$run_ids` must be an ordered duplicate-free run ID vector.", call. = FALSE)
  }
  known_run_ids <- vapply(project$runs, `[[`, character(1), "run_id")
  unknown <- setdiff(run_ids, known_run_ids)
  if (length(unknown)) {
    stop("Unknown run ID in observation: ", unknown[[1L]], call. = FALSE)
  }
  timestamp <- woodhen_project_time(now, "now")
  value <- list(
    observation_schema_version = "woodhen-observation-v1",
    observation_id = woodhen_project_new_id("observation", timestamp),
    title = title,
    note = note,
    run_ids = run_ids,
    created_at = timestamp,
    modified_at = timestamp
  )
  woodhen_project_validate_observation(value, known_run_ids)
  candidate <- project
  candidate$observations[[length(candidate$observations) + 1L]] <- value
  woodhen_project_refresh(candidate, timestamp)
}

#' Select ordered project evidence
#'
#' @param project A validated project.
#' @param evidence_ids An ordered duplicate-free vector of run and observation IDs.
#' @param now Modification time.
#' @return A new validated project list.
#' @export
select_woodhen_evidence <- function(project, evidence_ids, now = Sys.time()) {
  validate_woodhen_project(project)
  if (!is.character(evidence_ids) || anyNA(evidence_ids) ||
      any(!nzchar(evidence_ids))) {
    stop("`evidence_ids` must be a character vector of existing evidence IDs.", call. = FALSE)
  }
  if (anyDuplicated(evidence_ids)) {
    stop("`evidence_ids` cannot contain duplicate IDs.", call. = FALSE)
  }
  namespace <- c(
    vapply(project$runs, `[[`, character(1), "run_id"),
    vapply(project$observations, `[[`, character(1), "observation_id")
  )
  unknown <- setdiff(evidence_ids, namespace)
  if (length(unknown)) {
    stop("Unknown evidence ID: ", unknown[[1L]], call. = FALSE)
  }
  if (identical(project$evidence_ids, evidence_ids)) {
    return(project)
  }
  candidate <- project
  candidate$evidence_ids <- evidence_ids
  woodhen_project_refresh(candidate, now)
}

woodhen_typed_atomic_names <- function(value) {
  value_names <- names(value)
  if (is.null(value_names)) {
    return(NULL)
  }
  as.list(enc2utf8(value_names))
}

woodhen_typed_scalar_values <- function(value) {
  unname(lapply(seq_along(value), function(index) {
    if (is.na(value[[index]])) {
      NULL
    } else if (is.double(value)) {
      sprintf("%a", unname(value[[index]]))
    } else {
      unname(value[[index]])
    }
  }))
}

woodhen_typed_integer_representation <- function(value) {
  if (!is.integer(value) || length(value) < 2L || anyNA(value) || !is.null(names(value)) ||
      !all(diff(value) == 1L)) {
    return("materialized")
  }
  materialized <- as.integer(value + 0L)
  if (identical(
    serialize(value, NULL, version = 3L),
    serialize(materialized, NULL, version = 3L)
  )) {
    "materialized"
  } else {
    "compact_sequence"
  }
}

woodhen_typed_list_classes <- function(value) {
  value_class <- class(value)
  allowed <- list(
    NULL,
    "list",
    c("pva_spec", "list"),
    c("woodhen_investigation_scenario", "list"),
    c("woodhen_compact_run", "list"),
    c("woodhen_project", "list")
  )
  if (!any(vapply(allowed, identical, logical(1), y = value_class))) {
    stop("A list has an unsupported portable class.", call. = FALSE)
  }
  if (is.null(value_class)) NULL else as.list(value_class)
}

woodhen_typed_validate_attributes <- function(value, allowed, path) {
  unexpected <- setdiff(names(attributes(value)), allowed)
  if (length(unexpected)) {
    stop(
      "`", path, "` has unsupported attribute(s): ",
      paste(unexpected, collapse = ", "), ".",
      call. = FALSE
    )
  }
  invisible(value)
}

woodhen_typed_storage <- function(value, path) {
  storage <- typeof(value)
  if (!storage %in% c("logical", "integer", "double", "character")) {
    stop("`", path, "` has unsupported atomic storage.", call. = FALSE)
  }
  if (identical(storage, "double") && any(is.nan(value) | is.infinite(value))) {
    stop("`", path, "` contains a forbidden non-finite number.", call. = FALSE)
  }
  if (identical(storage, "character") && !all(validUTF8(value[!is.na(value)]))) {
    stop("`", path, "` contains invalid UTF-8 text.", call. = FALSE)
  }
  storage
}

woodhen_typed_encode <- function(value, path = "value") {
  if (is.null(value)) {
    return(list(type = "null"))
  }
  if (is.data.frame(value)) {
    woodhen_typed_validate_attributes(value, c("names", "row.names", "class"), path)
    if (!identical(class(value), "data.frame") || anyDuplicated(names(value)) || anyNA(names(value))) {
      stop("`", path, "` is not a plain data frame.", call. = FALSE)
    }
    return(list(
      type = "data_frame",
      column_names = as.list(enc2utf8(names(value))),
      columns = unname(Map(function(column, name) {
        woodhen_typed_encode(column, paste0(path, "$", name))
      }, value, names(value))),
      row_names = woodhen_typed_encode(attr(value, "row.names"), paste0(path, "<row.names>")),
      number_rows = as.integer(nrow(value))
    ))
  }
  if (is.matrix(value)) {
    woodhen_typed_validate_attributes(value, c("dim", "dimnames"), path)
    storage <- woodhen_typed_storage(value, path)
    return(list(
      type = "matrix",
      storage = storage,
      dimensions = as.list(as.integer(dim(value))),
      values = woodhen_typed_scalar_values(as.vector(value)),
      dimnames = woodhen_typed_encode(dimnames(value), paste0(path, "<dimnames>"))
    ))
  }
  if (is.atomic(value)) {
    woodhen_typed_validate_attributes(value, "names", path)
    storage <- woodhen_typed_storage(value, path)
    return(list(
      type = "atomic",
      storage = storage,
      representation = woodhen_typed_integer_representation(value),
      values = woodhen_typed_scalar_values(value),
      names = woodhen_typed_atomic_names(value)
    ))
  }
  if (is.list(value)) {
    woodhen_typed_validate_attributes(value, c("names", "class"), path)
    classes <- woodhen_typed_list_classes(value)
    value_names <- names(value)
    if (is.null(value_names)) {
      return(list(
        type = "list",
        values = unname(lapply(seq_along(value), function(index) {
          woodhen_typed_encode(value[[index]], paste0(path, "[[", index, "]]"))
        })),
        classes = classes
      ))
    }
    if (anyNA(value_names) || any(!nzchar(value_names)) || anyDuplicated(value_names)) {
      stop("`", path, "` has invalid or duplicate object names.", call. = FALSE)
    }
    ordering <- order(value_names, method = "radix")
    value <- value[ordering]
    value_names <- enc2utf8(value_names[ordering])
    return(list(
      type = "object",
      names = as.list(value_names),
      values = unname(Map(function(child, name) {
        woodhen_typed_encode(child, paste0(path, "$", name))
      }, value, value_names)),
      classes = classes
    ))
  }
  stop("`", path, "` contains a forbidden ", typeof(value), " value.", call. = FALSE)
}

woodhen_typed_require_object <- function(value, fields, path) {
  if (!is.list(value) || is.null(names(value)) || anyDuplicated(names(value)) ||
      !setequal(names(value), fields)) {
    stop("`", path, "` must contain exactly: ", paste(fields, collapse = ", "), ".", call. = FALSE)
  }
  invisible(value)
}

woodhen_typed_array <- function(value, path) {
  if (!is.list(value) || !is.null(names(value))) {
    stop("`", path, "` must be a JSON array.", call. = FALSE)
  }
  value
}

woodhen_typed_character_array <- function(value, path, allow_empty = TRUE) {
  value <- woodhen_typed_array(value, path)
  result <- vapply(value, function(item) {
    if (!is.character(item) || length(item) != 1L || is.na(item) || !validUTF8(item)) {
      stop("`", path, "` must contain valid UTF-8 strings.", call. = FALSE)
    }
    item
  }, character(1))
  if (!allow_empty && (length(result) == 0L || any(!nzchar(result)))) {
    stop("`", path, "` cannot be empty.", call. = FALSE)
  }
  result
}

woodhen_typed_classes <- function(value, path) {
  if (is.null(value)) {
    return(NULL)
  }
  classes <- woodhen_typed_character_array(value, path)
  allowed <- list(
    "list",
    c("pva_spec", "list"),
    c("woodhen_investigation_scenario", "list"),
    c("woodhen_compact_run", "list"),
    c("woodhen_project", "list")
  )
  if (!any(vapply(allowed, identical, logical(1), y = classes))) {
    stop("`", path, "` contains an unsupported portable class.", call. = FALSE)
  }
  classes
}

woodhen_typed_decode_atomic <- function(storage,
                                        values,
                                        value_names,
                                        path,
                                        representation = "materialized") {
  if (!is.character(storage) || length(storage) != 1L || is.na(storage) ||
      !storage %in% c("logical", "integer", "double", "character")) {
    stop("`", path, "$storage` is unsupported.", call. = FALSE)
  }
  if (!is.character(representation) || length(representation) != 1L ||
      is.na(representation) ||
      !representation %in% c("materialized", "compact_sequence") ||
      (identical(representation, "compact_sequence") && !identical(storage, "integer"))) {
    stop("`", path, "$representation` is unsupported.", call. = FALSE)
  }
  values <- woodhen_typed_array(values, paste0(path, "$values"))
  result <- switch(
    storage,
    logical = logical(length(values)),
    integer = integer(length(values)),
    double = double(length(values)),
    character = character(length(values))
  )
  for (index in seq_along(values)) {
    item <- values[[index]]
    if (is.null(item)) {
      result[[index]] <- switch(
        storage,
        logical = NA,
        integer = NA_integer_,
        double = NA_real_,
        character = NA_character_
      )
      next
    }
    valid <- switch(
      storage,
      logical = is.logical(item) && length(item) == 1L && !is.na(item),
      integer = is.numeric(item) && length(item) == 1L && !is.na(item) &&
        is.finite(item) && item == round(item) && item >= -.Machine$integer.max - 1 &&
        item <= .Machine$integer.max,
      double = is.character(item) && length(item) == 1L && !is.na(item) &&
        grepl("^-?0x[0-9a-f]+(?:\\.[0-9a-f]+)?p[+-][0-9]+$", item, perl = TRUE) &&
        is.finite(suppressWarnings(as.numeric(item))),
      character = is.character(item) && length(item) == 1L && !is.na(item) && validUTF8(item)
    )
    if (!valid) {
      stop("`", path, "$values[[", index, "]]` does not match storage `", storage, "`.", call. = FALSE)
    }
    result[[index]] <- switch(
      storage,
      logical = as.logical(item),
      integer = as.integer(item),
      double = suppressWarnings(as.numeric(item)),
      character = enc2utf8(item)
    )
  }
  if (!is.null(value_names)) {
    decoded_names <- woodhen_typed_character_array(value_names, paste0(path, "$names"))
    if (length(decoded_names) != length(result)) {
      stop("`", path, "$names` must match the atomic vector length.", call. = FALSE)
    }
    names(result) <- decoded_names
  }
  if (identical(representation, "compact_sequence")) {
    if (length(result) < 2L || anyNA(result) || !is.null(names(result)) ||
        !all(diff(result) == 1L)) {
      stop("`", path, "` is not a valid compact integer sequence.", call. = FALSE)
    }
    result <- result[[1L]]:result[[length(result)]]
  }
  result
}

woodhen_typed_decode <- function(value, path = "value") {
  if (!is.list(value) || is.null(names(value)) || anyDuplicated(names(value)) ||
      !is.character(value$type) || length(value$type) != 1L || is.na(value$type)) {
    stop("`", path, "` is not one typed JSON object.", call. = FALSE)
  }
  type <- value$type
  if (identical(type, "null")) {
    woodhen_typed_require_object(value, "type", path)
    return(NULL)
  }
  if (identical(type, "atomic")) {
    woodhen_typed_require_object(
      value,
      c("type", "storage", "representation", "values", "names"),
      path
    )
    return(woodhen_typed_decode_atomic(
      value$storage,
      value$values,
      value$names,
      path,
      representation = value$representation
    ))
  }
  if (identical(type, "matrix")) {
    woodhen_typed_require_object(
      value,
      c("type", "storage", "dimensions", "values", "dimnames"),
      path
    )
    dimensions <- woodhen_typed_array(value$dimensions, paste0(path, "$dimensions"))
    if (length(dimensions) != 2L || any(!vapply(dimensions, function(item) {
      is.numeric(item) && length(item) == 1L && is.finite(item) &&
        item == round(item) && item >= 0 && item <= .Machine$integer.max
    }, logical(1)))) {
      stop("`", path, "$dimensions` must contain two bounded integers.", call. = FALSE)
    }
    dimensions <- as.integer(unlist(dimensions, use.names = FALSE))
    decoded <- woodhen_typed_decode_atomic(value$storage, value$values, NULL, path)
    if (length(decoded) != prod(dimensions)) {
      stop("`", path, "$values` does not match its matrix dimensions.", call. = FALSE)
    }
    dim(decoded) <- dimensions
    decoded_dimnames <- woodhen_typed_decode(value$dimnames, paste0(path, "$dimnames"))
    if (!is.null(decoded_dimnames)) {
      if (!is.list(decoded_dimnames) || length(decoded_dimnames) != 2L ||
          any(!vapply(seq_along(decoded_dimnames), function(index) {
            item <- decoded_dimnames[[index]]
            is.null(item) || (is.character(item) && length(item) == dimensions[[index]])
          }, logical(1)))) {
        stop("`", path, "$dimnames` does not match its matrix dimensions.", call. = FALSE)
      }
      dimnames(decoded) <- decoded_dimnames
    }
    return(decoded)
  }
  if (identical(type, "data_frame")) {
    woodhen_typed_require_object(
      value,
      c("type", "column_names", "columns", "row_names", "number_rows"),
      path
    )
    column_names <- woodhen_typed_character_array(value$column_names, paste0(path, "$column_names"))
    if (anyDuplicated(column_names)) {
      stop("`", path, "$column_names` contains duplicate names.", call. = FALSE)
    }
    columns <- woodhen_typed_array(value$columns, paste0(path, "$columns"))
    if (length(columns) != length(column_names)) {
      stop("`", path, "$columns` does not match its names.", call. = FALSE)
    }
    number_rows <- value$number_rows
    if (!is.numeric(number_rows) || length(number_rows) != 1L || !is.finite(number_rows) ||
        number_rows != round(number_rows) || number_rows < 0 ||
        number_rows > .Machine$integer.max) {
      stop("`", path, "$number_rows` is invalid.", call. = FALSE)
    }
    number_rows <- as.integer(number_rows)
    decoded_columns <- unname(lapply(seq_along(columns), function(index) {
      column <- woodhen_typed_decode(
        columns[[index]],
        paste0(path, "$columns[[", index, "]]" )
      )
      if (!is.atomic(column) || !is.null(dim(column)) || length(column) != number_rows) {
        stop("A decoded data-frame column is not row-matched.", call. = FALSE)
      }
      column
    }))
    names(decoded_columns) <- column_names
    decoded_row_names <- woodhen_typed_decode(value$row_names, paste0(path, "$row_names"))
    if (!is.character(decoded_row_names) && !is.integer(decoded_row_names)) {
      stop("`", path, "$row_names` is invalid.", call. = FALSE)
    }
    result <- decoded_columns
    attr(result, "row.names") <- decoded_row_names
    class(result) <- "data.frame"
    if (nrow(result) != number_rows) {
      stop("Decoded data-frame row names do not match its row count.", call. = FALSE)
    }
    return(result)
  }
  if (identical(type, "list")) {
    woodhen_typed_require_object(value, c("type", "values", "classes"), path)
    values <- woodhen_typed_array(value$values, paste0(path, "$values"))
    result <- unname(lapply(seq_along(values), function(index) {
      woodhen_typed_decode(values[[index]], paste0(path, "[[", index, "]]"))
    }))
    classes <- woodhen_typed_classes(value$classes, paste0(path, "$classes"))
    if (!is.null(classes)) {
      class(result) <- classes
    }
    return(result)
  }
  if (identical(type, "object")) {
    woodhen_typed_require_object(value, c("type", "names", "values", "classes"), path)
    object_names <- woodhen_typed_character_array(value$names, paste0(path, "$names"))
    if (any(!nzchar(object_names)) || anyDuplicated(object_names)) {
      stop("`", path, "$names` contains invalid or duplicate names.", call. = FALSE)
    }
    values <- woodhen_typed_array(value$values, paste0(path, "$values"))
    if (length(values) != length(object_names)) {
      stop("`", path, "$values` does not match its object names.", call. = FALSE)
    }
    result <- unname(lapply(seq_along(values), function(index) {
      woodhen_typed_decode(values[[index]], paste0(path, "$", object_names[[index]]))
    }))
    names(result) <- object_names
    classes <- woodhen_typed_classes(value$classes, paste0(path, "$classes"))
    if (!is.null(classes)) {
      class(result) <- classes
    }
    return(result)
  }
  stop("`", path, "$type` is unsupported: ", type, call. = FALSE)
}

woodhen_json_check_objects <- function(value, path = "JSON") {
  if (!is.list(value)) {
    return(invisible(value))
  }
  value_names <- names(value)
  if (!is.null(value_names) && anyDuplicated(value_names)) {
    stop("`", path, "` contains a duplicate JSON object key.", call. = FALSE)
  }
  for (index in seq_along(value)) {
    child <- if (is.null(value_names)) {
      paste0(path, "[[", index, "]]")
    } else {
      paste0(path, "$", value_names[[index]])
    }
    woodhen_json_check_objects(value[[index]], child)
  }
  invisible(value)
}

woodhen_json_bytes <- function(value) {
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("The locked `jsonlite` package is required for Woodhen project JSON.", call. = FALSE)
  }
  text <- jsonlite::toJSON(
    value,
    auto_unbox = TRUE,
    null = "null",
    na = "null",
    digits = NA,
    pretty = FALSE,
    force = TRUE
  )
  charToRaw(paste0(enc2utf8(text), "\n"))
}

woodhen_json_parse <- function(bytes, path = "JSON") {
  if (!is.raw(bytes)) {
    stop("`", path, "` must be supplied as exact raw bytes.", call. = FALSE)
  }
  text <- tryCatch(
    rawToChar(bytes),
    error = function(e) stop("`", path, "` is not valid UTF-8 JSON.", call. = FALSE)
  )
  Encoding(text) <- "UTF-8"
  if (!validUTF8(text) || !jsonlite::validate(text)) {
    stop("`", path, "` is not valid UTF-8 JSON.", call. = FALSE)
  }
  value <- tryCatch(
    jsonlite::fromJSON(
      text,
      simplifyVector = FALSE,
      simplifyDataFrame = FALSE,
      simplifyMatrix = FALSE
    ),
    error = function(e) stop("`", path, "` is not valid JSON: ", conditionMessage(e), call. = FALSE)
  )
  if (!is.list(value) || is.null(names(value))) {
    stop("`", path, "` must contain one top-level JSON object.", call. = FALSE)
  }
  woodhen_json_check_objects(value, path)
  value
}

woodhen_project_document <- function(project) {
  list(
    format_version = "woodhen-project-json-v1",
    project_schema_version = project$project_schema_version,
    project_id = project$project_id,
    project_fingerprint = project$project_fingerprint,
    payload = woodhen_typed_encode(project, "project")
  )
}

woodhen_project_browser_snapshot <- function(project) {
  validate_woodhen_project(project)
  bytes <- woodhen_json_bytes(woodhen_project_document(project))
  snapshot <- rawToChar(bytes)
  Encoding(snapshot) <- "UTF-8"
  snapshot
}

read_woodhen_project_browser_snapshot <- function(
    snapshot_json,
    max_bytes = 50 * 1024^2
) {
  max_bytes <- woodhen_project_limit(max_bytes, "max_bytes")
  if (!is.character(snapshot_json) || length(snapshot_json) != 1L ||
      is.na(snapshot_json)) {
    stop("`snapshot_json` must be one non-missing character scalar.", call. = FALSE)
  }
  if (!validUTF8(snapshot_json)) {
    stop("`snapshot_json` is not valid UTF-8.", call. = FALSE)
  }
  bytes <- charToRaw(enc2utf8(snapshot_json))
  if (length(bytes) > max_bytes) {
    stop("The browser snapshot exceeds the `max_bytes` size limit.", call. = FALSE)
  }

  document <- woodhen_json_parse(bytes, "browser snapshot")
  woodhen_validate_project_document(document)
  candidate <- woodhen_typed_decode(document$payload, "browser snapshot$payload")
  candidate <- woodhen_project_restore_schema_order(candidate)
  validate_woodhen_project(candidate)
  for (field in c("project_schema_version", "project_id", "project_fingerprint")) {
    if (!identical(candidate[[field]], document[[field]])) {
      stop("Browser snapshot metadata mismatch for `", field, "`.", call. = FALSE)
    }
  }
  candidate
}

woodhen_project_export_candidate <- function(project, now) {
  candidate <- project
  candidate$provenance$exports[[length(candidate$provenance$exports) + 1L]] <- list(
    event_schema_version = "woodhen-export-event-v1",
    exported_at = now,
    package_format_version = woodhen_project_package_format_version(),
    app_version = woodhen_app_version()
  )
  validate_woodhen_project(candidate)
  candidate
}

woodhen_project_manifest <- function(project, project_bytes, exported_at) {
  list(
    package_format_version = woodhen_project_package_format_version(),
    project_schema_version = project$project_schema_version,
    project_id = project$project_id,
    project_fingerprint = project$project_fingerprint,
    exported_at = exported_at,
    app_version = project$app_version,
    model_version = project$model_version,
    reference_library_version = project$reference_library_version,
    catalog_version = project$catalog_version,
    members = as.list(c("manifest.json", "project.json")),
    project_json_sha256 = digest::digest(
      project_bytes,
      algo = "sha256",
      serialize = FALSE
    ),
    digest_algorithm = "sha256"
  )
}

woodhen_project_limit <- function(value, field) {
  valid <- is.numeric(value) && length(value) == 1L && !is.na(value) &&
    is.finite(value) && value >= 0
  if (!valid) {
    stop("`", field, "` must be one finite non-negative byte limit.", call. = FALSE)
  }
  as.numeric(value)
}

woodhen_zip_preflight <- function(path, max_compressed_bytes, max_expanded_bytes) {
  max_compressed_bytes <- woodhen_project_limit(max_compressed_bytes, "max_compressed_bytes")
  max_expanded_bytes <- woodhen_project_limit(max_expanded_bytes, "max_expanded_bytes")
  if (!is.character(path) || length(path) != 1L || is.na(path) || !nzchar(path) ||
      !file.exists(path)) {
    stop("The Woodhen project package path is not one existing file.", call. = FALSE)
  }
  if (nzchar(Sys.readlink(path))) {
    stop("The Woodhen project package path cannot be a symlink.", call. = FALSE)
  }
  path_info <- file.info(path)
  if (is.na(path_info$isdir) || path_info$isdir || !file_test("-f", path)) {
    stop("The Woodhen project package path must be a regular file.", call. = FALSE)
  }
  if (!is.finite(path_info$size) || path_info$size < 0 ||
      path_info$size > max_compressed_bytes) {
    stop("The Woodhen project package exceeds the compressed-size limit.", call. = FALSE)
  }
  archive <- tryCatch(
    zip::zip_list(path),
    error = function(e) stop("The Woodhen project ZIP archive is malformed: ", conditionMessage(e), call. = FALSE)
  )
  required_columns <- c(
    "filename", "compressed_size", "uncompressed_size", "permissions", "type"
  )
  if (!all(required_columns %in% names(archive))) {
    stop("The Woodhen project ZIP archive lacks required member metadata.", call. = FALSE)
  }
  if (nrow(archive) != 2L) {
    stop("The Woodhen project ZIP must contain exactly two members.", call. = FALSE)
  }
  if (anyDuplicated(archive$filename)) {
    stop("The Woodhen project ZIP contains duplicate members.", call. = FALSE)
  }
  whitelist <- c("manifest.json", "project.json")
  if (!setequal(archive$filename, whitelist)) {
    stop("The Woodhen project ZIP members do not match the exact whitelist.", call. = FALSE)
  }
  if (any(archive$type != "file")) {
    stop("The Woodhen project ZIP members must be regular files.", call. = FALSE)
  }
  modes <- as.integer(archive$permissions)
  if (anyNA(modes) || any(bitwAnd(modes, as.integer(strtoi("111", base = 8L))) != 0L)) {
    stop("The Woodhen project ZIP cannot contain executable members.", call. = FALSE)
  }
  for (field in c("compressed_size", "uncompressed_size")) {
    sizes <- archive[[field]]
    if (!is.numeric(sizes) || any(!is.finite(sizes)) || any(sizes < 0) ||
        any(sizes != floor(sizes))) {
      stop("The Woodhen project ZIP contains invalid member sizes.", call. = FALSE)
    }
  }
  if (sum(archive$compressed_size) > max_compressed_bytes) {
    stop("The Woodhen project ZIP exceeds the compressed-size limit.", call. = FALSE)
  }
  if (sum(archive$uncompressed_size) > max_expanded_bytes) {
    stop("The Woodhen project ZIP exceeds the expanded-size limit.", call. = FALSE)
  }
  archive[match(whitelist, archive$filename), , drop = FALSE]
}

woodhen_zip_extract_checked <- function(path, archive, max_expanded_bytes) {
  directory <- tempfile("woodhen-project-import-")
  if (!dir.create(directory, mode = "0700")) {
    stop("Could not create a private Woodhen project import directory.", call. = FALSE)
  }
  tryCatch(
    zip::unzip(
      path,
      files = c("manifest.json", "project.json"),
      exdir = directory,
      overwrite = FALSE
    ),
    error = function(e) {
      unlink(directory, recursive = TRUE, force = TRUE)
      stop("The Woodhen project ZIP could not be safely extracted: ", conditionMessage(e), call. = FALSE)
    }
  )
  files <- list.files(
    directory,
    all.files = TRUE,
    no.. = TRUE,
    recursive = TRUE,
    include.dirs = TRUE
  )
  whitelist <- c("manifest.json", "project.json")
  if (!setequal(files, whitelist) || anyDuplicated(files)) {
    unlink(directory, recursive = TRUE, force = TRUE)
    stop("Extracted Woodhen project files do not match the exact whitelist.", call. = FALSE)
  }
  paths <- file.path(directory, whitelist)
  info <- file.info(paths)
  if (any(nzchar(Sys.readlink(paths))) || any(info$isdir) ||
      any(!vapply(paths, function(member_path) {
        file_test("-f", member_path)
      }, logical(1)))) {
    unlink(directory, recursive = TRUE, force = TRUE)
    stop("Extracted Woodhen project members must be direct regular files.", call. = FALSE)
  }
  expected_sizes <- archive$uncompressed_size[match(whitelist, archive$filename)]
  if (any(info$size != expected_sizes) || sum(info$size) > max_expanded_bytes) {
    unlink(directory, recursive = TRUE, force = TRUE)
    stop("Extracted Woodhen project member sizes do not match the ZIP metadata.", call. = FALSE)
  }
  list(directory = directory, paths = paths, sizes = info$size)
}

woodhen_read_exact_bytes <- function(path, size, label) {
  bytes <- readBin(path, what = "raw", n = size)
  if (length(bytes) != size) {
    stop("Could not read the exact `", label, "` bytes.", call. = FALSE)
  }
  bytes
}

woodhen_validate_manifest <- function(manifest) {
  fields <- c(
    "package_format_version", "project_schema_version", "project_id",
    "project_fingerprint", "exported_at", "app_version", "model_version",
    "reference_library_version", "catalog_version", "members",
    "project_json_sha256", "digest_algorithm"
  )
  woodhen_typed_require_object(manifest, fields, "manifest.json")
  woodhen_project_validate_version(
    manifest$package_format_version,
    "package_format_version",
    woodhen_project_package_format_version()
  )
  woodhen_project_validate_version(
    manifest$project_schema_version,
    "project_schema_version",
    woodhen_project_schema_version()
  )
  woodhen_project_validate_id(manifest$project_id, "^woodhen_project_[0-9a-f]{16}$", "manifest$project_id")
  woodhen_project_validate_id(manifest$project_fingerprint, "^[0-9a-f]{64}$", "manifest$project_fingerprint")
  woodhen_project_time(manifest$exported_at, "manifest$exported_at")
  for (field in c(
    "app_version", "model_version", "reference_library_version", "catalog_version"
  )) {
    woodhen_project_scalar_text(manifest[[field]], paste0("manifest$", field))
  }
  if (!identical(manifest$members, as.list(c("manifest.json", "project.json")))) {
    stop("`manifest$members` must name the exact ordered package whitelist.", call. = FALSE)
  }
  woodhen_project_validate_id(
    manifest$project_json_sha256,
    "^[0-9a-f]{64}$",
    "manifest$project_json_sha256"
  )
  if (!identical(manifest$digest_algorithm, "sha256")) {
    stop("The manifest digest algorithm is unsupported.", call. = FALSE)
  }
  invisible(manifest)
}

woodhen_validate_project_document <- function(document) {
  woodhen_typed_require_object(
    document,
    c(
      "format_version", "project_schema_version", "project_id",
      "project_fingerprint", "payload"
    ),
    "project.json"
  )
  woodhen_project_validate_version(
    document$format_version,
    "format_version",
    "woodhen-project-json-v1"
  )
  woodhen_project_validate_version(
    document$project_schema_version,
    "project_schema_version",
    woodhen_project_schema_version()
  )
  woodhen_project_validate_id(document$project_id, "^woodhen_project_[0-9a-f]{16}$", "project.json$project_id")
  woodhen_project_validate_id(document$project_fingerprint, "^[0-9a-f]{64}$", "project.json$project_fingerprint")
  invisible(document)
}

woodhen_project_reorder_fields <- function(value, expected) {
  if (!is.list(value) || is.null(names(value))) {
    return(value)
  }
  value_class <- attr(value, "class", exact = TRUE)
  value <- value[c(intersect(expected, names(value)), setdiff(names(value), expected))]
  if (!is.null(value_class)) {
    class(value) <- value_class
  }
  value
}

woodhen_project_restore_scenario_order <- function(scenario) {
  scenario <- woodhen_project_reorder_fields(
    scenario,
    woodhen_scenario_record_fields(scenario$scenario_type)
  )
  for (field in c("components", "changes", "temporal_profile")) {
    value <- scenario[[field]]
    if (is.list(value) && !is.null(names(value))) {
      scenario[[field]] <- value[order(names(value), method = "radix")]
    }
  }
  spec_fields <- c(
    "name", "years", "reps", "surv", "stasis", "fecund", "sex_ratio_init",
    "monogamy", "n0", "demographic_stochasticity", "env_sd", "K", "K_sd",
    "cat_freq", "cat_surv", "cat_repro", "genetics", "F_init",
    "lethal_equiv", "B_on_fec", "Ne_N_ratio", "Ne_window", "purge_kappa",
    "annual_profiles", "release_years", "release_vec"
  )
  scenario$spec <- woodhen_project_reorder_fields(scenario$spec, spec_fields)
  component_fields <- c(
    "component_id", "affected_fields", "affected_stages", "operator",
    "value", "temporal_profile"
  )
  change_fields <- c(
    "component_id", "affected_fields", "affected_stages", "operator",
    "before", "after", "temporal_profile"
  )
  profile_fields <- c("shape", "onset_year", "end_year")
  for (component_name in names(scenario$components)) {
    scenario$components[[component_name]] <- woodhen_project_reorder_fields(
      scenario$components[[component_name]], component_fields
    )
    scenario$components[[component_name]]$temporal_profile <-
      woodhen_project_reorder_fields(
        scenario$components[[component_name]]$temporal_profile,
        profile_fields
      )
  }
  for (change_name in names(scenario$changes)) {
    scenario$changes[[change_name]] <- woodhen_project_reorder_fields(
      scenario$changes[[change_name]], change_fields
    )
    scenario$changes[[change_name]]$temporal_profile <-
      woodhen_project_reorder_fields(
        scenario$changes[[change_name]]$temporal_profile,
        profile_fields
      )
  }
  for (profile_name in names(scenario$temporal_profile)) {
    scenario$temporal_profile[[profile_name]] <- woodhen_project_reorder_fields(
      scenario$temporal_profile[[profile_name]], profile_fields
    )
  }
  scenario
}

woodhen_project_restore_run_order <- function(run) {
  run <- woodhen_project_reorder_fields(run, woodhen_project_run_fields())
  run$scenario <- woodhen_project_restore_scenario_order(run$scenario)
  run$final_abundance <- woodhen_project_reorder_fields(
    run$final_abundance,
    c("values", "median", "q025", "q25", "q75", "q975")
  )
  evidence_fields <- c(
    "total_reps", "extinct_reps", "probability_by_horizon",
    "first_extinction_year", "cumulative", "conditional_median_year",
    "overall_median_year"
  )
  run$extinction_evidence <- woodhen_project_reorder_fields(
    run$extinction_evidence, evidence_fields
  )
  run$quasi_extinction_50_pairs <- woodhen_project_reorder_fields(
    run$quasi_extinction_50_pairs,
    c(
      "threshold_pairs", "holder_stages", "total_reps", "crossed_reps",
      "probability_by_horizon", "first_crossing_year", "cumulative",
      "conditional_median_year", "overall_median_year", "minimum_breeding_pairs"
    )
  )
  run$difference_from_parent <- woodhen_project_reorder_fields(
    run$difference_from_parent,
    c("parent_id", "status", "specification_changes", "outcomes")
  )
  if (!is.null(run$difference_from_parent$outcomes)) {
    run$difference_from_parent$outcomes <- woodhen_project_reorder_fields(
      run$difference_from_parent$outcomes,
      c(
        "extinction_probability", "quasi_extinction_probability",
        "final_median_abundance"
      )
    )
  }
  specification_changes <- run$difference_from_parent$specification_changes
  scenario_change_names <- names(run$scenario$changes)
  if (is.list(specification_changes) && !is.null(names(specification_changes))) {
    specification_changes <- specification_changes[c(
      intersect(scenario_change_names, names(specification_changes)),
      setdiff(names(specification_changes), scenario_change_names)
    )]
    for (change_name in names(specification_changes)) {
      specification_changes[[change_name]] <- woodhen_project_reorder_fields(
        specification_changes[[change_name]],
        c(
          "component_id", "affected_fields", "affected_stages", "operator",
          "before", "after", "temporal_profile"
        )
      )
      specification_changes[[change_name]]$temporal_profile <-
        woodhen_project_reorder_fields(
          specification_changes[[change_name]]$temporal_profile,
          c("shape", "onset_year", "end_year")
        )
    }
    run$difference_from_parent$specification_changes <- specification_changes
  }
  run$provenance <- woodhen_project_reorder_fields(
    run$provenance,
    c(
      "reference_library_version", "catalog_version", "model_version",
      "fingerprint_algorithm", "canonicalization_version"
    )
  )
  run
}

woodhen_project_restore_schema_order <- function(project) {
  project <- woodhen_project_reorder_fields(project, woodhen_project_fields())
  project$scenarios <- lapply(project$scenarios, woodhen_project_restore_scenario_order)
  project$scenario_versions <- lapply(project$scenario_versions, function(value) {
    woodhen_project_reorder_fields(value, c(
      "scenario_version_schema", "scenario_id", "scenario_version",
      "supersedes_scenario_id", "added_at"
    ))
  })
  project$runs <- lapply(project$runs, woodhen_project_restore_run_order)
  project$observations <- lapply(project$observations, function(value) {
    woodhen_project_reorder_fields(value, c(
      "observation_schema_version", "observation_id", "title", "note",
      "run_ids", "created_at", "modified_at"
    ))
  })
  project$provenance <- woodhen_project_reorder_fields(
    project$provenance, c("imports", "exports")
  )
  project$provenance$imports <- lapply(project$provenance$imports, function(value) {
    woodhen_project_reorder_fields(value, c(
      "event_schema_version", "imported_at", "package_format_version",
      "source_project_id", "source_project_fingerprint"
    ))
  })
  project$provenance$exports <- lapply(project$provenance$exports, function(value) {
    woodhen_project_reorder_fields(value, c(
      "event_schema_version", "exported_at", "package_format_version", "app_version"
    ))
  })
  project
}

#' Write a safe portable Woodhen project package
#'
#' @param project A validated Woodhen project.
#' @param path Destination ZIP path.
#' @param now Export time.
#' @return `path`, invisibly.
#' @export
write_woodhen_project_package <- function(project, path, now = Sys.time()) {
  validate_woodhen_project(project)
  if (!requireNamespace("zip", quietly = TRUE)) {
    stop("The locked `zip` package is required for Woodhen project packages.", call. = FALSE)
  }
  if (!is.character(path) || length(path) != 1L || is.na(path) || !nzchar(path)) {
    stop("`path` must be one non-empty destination path.", call. = FALSE)
  }
  destination_directory <- dirname(path)
  if (!dir.exists(destination_directory)) {
    stop("The destination directory does not exist.", call. = FALSE)
  }
  if (file.exists(path) && (dir.exists(path) || nzchar(Sys.readlink(path)))) {
    stop("The destination path cannot be a directory or symlink.", call. = FALSE)
  }
  exported_at <- woodhen_project_time(now, "now")
  candidate <- woodhen_project_export_candidate(project, exported_at)
  project_bytes <- woodhen_json_bytes(woodhen_project_document(candidate))
  manifest_bytes <- woodhen_json_bytes(
    woodhen_project_manifest(candidate, project_bytes, exported_at)
  )

  stage <- tempfile("woodhen-project-export-")
  if (!dir.create(stage, mode = "0700")) {
    stop("Could not create a private Woodhen project export directory.", call. = FALSE)
  }
  on.exit(unlink(stage, recursive = TRUE, force = TRUE), add = TRUE)
  writeBin(manifest_bytes, file.path(stage, "manifest.json"))
  writeBin(project_bytes, file.path(stage, "project.json"))
  Sys.chmod(file.path(stage, c("manifest.json", "project.json")), "0600", use_umask = FALSE)

  temporary_archive <- tempfile(
    pattern = paste0(".", basename(path), "-"),
    tmpdir = destination_directory,
    fileext = ".tmp"
  )
  on.exit(unlink(temporary_archive, force = TRUE), add = TRUE)
  zip::zip(
    temporary_archive,
    files = c("manifest.json", "project.json"),
    root = stage,
    mode = "mirror",
    compression_level = 9L,
    include_directories = FALSE
  )
  woodhen_zip_preflight(
    temporary_archive,
    max_compressed_bytes = 25 * 1024^2,
    max_expanded_bytes = 50 * 1024^2
  )
  if (!file.rename(temporary_archive, path)) {
    stop("Could not atomically move the completed Woodhen package into place.", call. = FALSE)
  }
  invisible(path)
}

#' Read and validate a safe portable Woodhen project package
#'
#' @param path Existing ZIP path.
#' @param max_compressed_bytes Maximum whole-archive compressed size.
#' @param max_expanded_bytes Maximum sum of expanded member sizes.
#' @return A fully validated `woodhen_project`.
#' @export
read_woodhen_project_package <- function(
    path,
    max_compressed_bytes = 25 * 1024^2,
    max_expanded_bytes = 50 * 1024^2
) {
  max_compressed_bytes <- woodhen_project_limit(max_compressed_bytes, "max_compressed_bytes")
  max_expanded_bytes <- woodhen_project_limit(max_expanded_bytes, "max_expanded_bytes")
  archive <- woodhen_zip_preflight(path, max_compressed_bytes, max_expanded_bytes)
  extracted <- woodhen_zip_extract_checked(path, archive, max_expanded_bytes)
  on.exit(unlink(extracted$directory, recursive = TRUE, force = TRUE), add = TRUE)
  manifest_bytes <- woodhen_read_exact_bytes(
    extracted$paths[[1L]], extracted$sizes[[1L]], "manifest.json"
  )
  project_bytes <- woodhen_read_exact_bytes(
    extracted$paths[[2L]], extracted$sizes[[2L]], "project.json"
  )

  manifest <- woodhen_json_parse(manifest_bytes, "manifest.json")
  woodhen_validate_manifest(manifest)
  actual_digest <- digest::digest(project_bytes, algo = "sha256", serialize = FALSE)
  if (!identical(actual_digest, manifest$project_json_sha256)) {
    stop("The exact `project.json` byte digest does not match the manifest.", call. = FALSE)
  }
  document <- woodhen_json_parse(project_bytes, "project.json")
  woodhen_validate_project_document(document)
  for (field in c("project_schema_version", "project_id", "project_fingerprint")) {
    if (!identical(document[[field]], manifest[[field]])) {
      stop("Manifest/project metadata mismatch for `", field, "`.", call. = FALSE)
    }
  }

  candidate <- woodhen_typed_decode(document$payload, "project.json$payload")
  candidate <- woodhen_project_restore_schema_order(candidate)
  validate_woodhen_project(candidate)
  for (field in c("project_schema_version", "project_id", "project_fingerprint")) {
    if (!identical(candidate[[field]], document[[field]])) {
      stop("Decoded project metadata mismatch for `", field, "`.", call. = FALSE)
    }
  }
  version_fields <- c(
    "app_version", "model_version", "reference_library_version", "catalog_version"
  )
  if (any(!vapply(version_fields, function(field) {
    identical(candidate[[field]], manifest[[field]])
  }, logical(1)))) {
    stop("Manifest version metadata does not match the decoded project.", call. = FALSE)
  }

  imported_at <- woodhen_project_time(Sys.time(), "imported_at")
  candidate$provenance$imports[[length(candidate$provenance$imports) + 1L]] <- list(
    event_schema_version = "woodhen-import-event-v1",
    imported_at = imported_at,
    package_format_version = manifest$package_format_version,
    source_project_id = candidate$project_id,
    source_project_fingerprint = candidate$project_fingerprint
  )
  validate_woodhen_project(candidate)
  candidate
}
