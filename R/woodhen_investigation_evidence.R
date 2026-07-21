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

woodhen_scenario_record_fields <- function(scenario_type) {
  common <- c(
    "record_schema_version", "scenario_id", "family_id", "student_label",
    "scenario_type", "parent_id", "locked_baseline_id", "components",
    "changes", "temporal_profile", "spec", "seed",
    "reference_library_version", "catalog_version", "model_version",
    "created_at", "modified_at", "notes", "spec_fingerprint",
    "fingerprint_algorithm", "canonicalization_version",
    "scientific_identity_fingerprint"
  )
  if (identical(scenario_type, "intervention")) {
    c(common, "intervention_id")
  } else {
    common
  }
}

woodhen_reference_family_id <- function(reference_id) {
  if (reference_id %in% c("01_no_mgmt", "02_pig_control", "03_captive_pig")) {
    return("woodhen_reference_1980_crisis")
  }
  if (identical(reference_id, "04_rodent_eradication")) {
    return("woodhen_reference_2019_recovery")
  }
  "woodhen_reference_2025_anchor"
}

woodhen_reference_record_raw <- function(reference_id) {
  catalog <- woodhen_reference_catalog()
  row <- woodhen_catalog_match(catalog, reference_id, "reference scenario")
  spec <- woodhen_reference_spec(reference_id)
  portable_spec_order <- c(
    "name", "years", "reps", "surv", "stasis", "fecund", "sex_ratio_init",
    "monogamy", "n0", "demographic_stochasticity", "env_sd", "K", "K_sd",
    "cat_freq", "cat_surv", "cat_repro", "genetics", "F_init",
    "lethal_equiv", "B_on_fec", "Ne_N_ratio", "Ne_window", "purge_kappa",
    "annual_profiles", "release_years", "release_vec"
  )
  spec <- spec[c(
    intersect(portable_spec_order, names(spec)),
    sort(setdiff(names(spec), portable_spec_order), method = "radix")
  )]
  class(spec) <- c("pva_spec", "list")
  scenario <- structure(
    list(
      record_schema_version = "woodhen-scenario-record-v1",
      scenario_id = reference_id,
      family_id = woodhen_reference_family_id(reference_id),
      student_label = row$label[[1L]],
      scenario_type = "reference",
      parent_id = NA_character_,
      locked_baseline_id = "05_future_baseline",
      components = list(),
      changes = list(),
      temporal_profile = list(),
      spec = spec,
      seed = 123L,
      reference_library_version = woodhen_reference_library_version(),
      catalog_version = woodhen_investigation_catalog_version(),
      model_version = woodhen_model_version(),
      created_at = NA_character_,
      modified_at = NA_character_,
      notes = NULL,
      spec_fingerprint = woodhen_spec_fingerprint(spec),
      fingerprint_algorithm = "sha256",
      canonicalization_version = "woodhen-spec-canonical-v1",
      scientific_identity_fingerprint = NA_character_
    ),
    class = c("woodhen_investigation_scenario", "list")
  )
  scenario$scientific_identity_fingerprint <-
    woodhen_record_scientific_fingerprint(scenario)
  scenario
}

woodhen_validate_reference_scenario <- function(scenario) {
  reference_ids <- woodhen_reference_catalog()$id
  if (!is.character(scenario$scenario_id) || length(scenario$scenario_id) != 1L ||
      is.na(scenario$scenario_id) || !scenario$scenario_id %in% reference_ids) {
    stop("A reference record must use an exact catalogued reference ID.", call. = FALSE)
  }
  expected <- woodhen_reference_record_raw(scenario$scenario_id)
  if (!identical(scenario, expected)) {
    stop(
      "The reference record does not match its exact catalogued specification and metadata.",
      call. = FALSE
    )
  }
  invisible(scenario)
}

woodhen_reference_scenario <- function(reference_id) {
  scenario <- woodhen_reference_record_raw(reference_id)
  woodhen_validate_scenario_record(scenario)
  scenario
}

woodhen_validate_portable_value <- function(value, path = "scenario") {
  value_type <- typeof(value)
  allowed_types <- c("NULL", "logical", "integer", "double", "character", "list")
  if (!value_type %in% allowed_types) {
    stop(
      "`", path, "` contains a forbidden non-portable ", value_type, " value.",
      call. = FALSE
    )
  }
  if (identical(value_type, "double") &&
      any(is.nan(value) | is.infinite(value))) {
    stop("`", path, "` contains a forbidden non-finite number.", call. = FALSE)
  }
  dimensions <- dim(value)
  if (!is.null(dimensions) && length(dimensions) > 2L) {
    stop("`", path, "` contains a forbidden raw array.", call. = FALSE)
  }
  value_class <- attr(value, "class", exact = TRUE)
  allowed_classes <- c("woodhen_investigation_scenario", "pva_spec", "list")
  if (!is.null(value_class) && any(!value_class %in% allowed_classes)) {
    stop(
      "`", path, "` contains a forbidden non-portable class.",
      call. = FALSE
    )
  }
  value_attributes <- attributes(value)
  if (!is.null(value_attributes)) {
    allowed_attributes <- c("names", "dim", "dimnames", "class")
    unexpected_attributes <- setdiff(names(value_attributes), allowed_attributes)
    if (length(unexpected_attributes) > 0L) {
      stop(
        "`", path, "` contains forbidden attribute(s): ",
        paste(unexpected_attributes, collapse = ", "), ".",
        call. = FALSE
      )
    }
    for (attribute_name in intersect(names(value_attributes), allowed_attributes)) {
      woodhen_validate_portable_value(
        value_attributes[[attribute_name]],
        paste0(path, "<", attribute_name, ">")
      )
    }
  }
  if (is.list(value)) {
    value_names <- names(value)
    for (index in seq_along(value)) {
      child_name <- if (!is.null(value_names) && nzchar(value_names[[index]])) {
        value_names[[index]]
      } else {
        as.character(index)
      }
      woodhen_validate_portable_value(
        value[[index]],
        paste0(path, "$", child_name)
      )
    }
  }
  invisible(value)
}

woodhen_require_exact_fields <- function(value, expected, path) {
  if (!is.list(value) || is.null(names(value)) || anyDuplicated(names(value)) ||
      !setequal(names(value), expected)) {
    stop(
      "`", path, "` must contain exactly: ", paste(expected, collapse = ", "), ".",
      call. = FALSE
    )
  }
  invisible(value)
}

woodhen_validate_temporal_profile_record <- function(profile, years, path) {
  woodhen_require_exact_fields(
    profile,
    c("shape", "onset_year", "end_year"),
    path
  )
  valid_shape <- is.character(profile$shape) && length(profile$shape) == 1L &&
    !is.na(profile$shape) &&
    profile$shape %in% c("fixed_setting", "step", "linear", "scheduled_pulses")
  valid_year <- function(value) {
    is.numeric(value) && length(value) == 1L && is.finite(value) &&
      value == as.integer(value) && value >= 1L && value <= years
  }
  if (!valid_shape || !valid_year(profile$onset_year) || !valid_year(profile$end_year) ||
      profile$end_year < profile$onset_year) {
    stop("`", path, "` is not a valid bounded temporal profile.", call. = FALSE)
  }
  shape_valid <- switch(
    profile$shape,
    fixed_setting = profile$onset_year == 1L && profile$end_year == years,
    step = profile$end_year == profile$onset_year,
    linear = profile$end_year >= profile$onset_year,
    scheduled_pulses = profile$end_year == profile$onset_year + 2L
  )
  if (!shape_valid) {
    stop("`", path, "` has inconsistent bounds for its temporal shape.", call. = FALSE)
  }
  invisible(profile)
}

woodhen_validate_release_state <- function(value, years, n_stage, path) {
  woodhen_require_exact_fields(value, c("release_years", "release_vec"), path)
  release_years <- value$release_years
  release_vec <- value$release_vec
  if (!is.null(release_years)) {
    valid_years <- is.numeric(release_years) && length(release_years) <= years &&
      all(is.finite(release_years)) && all(release_years == as.integer(release_years)) &&
      all(release_years >= 1L & release_years <= years)
    if (!valid_years) {
      stop("`", path, "$release_years` has an invalid length or value.", call. = FALSE)
    }
  }
  if (!is.null(release_vec)) {
    valid_vector <- is.numeric(release_vec) && length(release_vec) == n_stage &&
      is.null(dim(release_vec)) && all(is.finite(release_vec))
    if (!valid_vector) {
      stop("`", path, "$release_vec` must be one stage-matched vector.", call. = FALSE)
    }
  }
  invisible(value)
}

woodhen_validate_change_profile <- function(value,
                                            affected_fields,
                                            years,
                                            n_stage,
                                            path) {
  if (identical(affected_fields, c("release_years", "release_vec"))) {
    return(woodhen_validate_release_state(value, years, n_stage, path))
  }
  if (!is.numeric(value) || length(value) == 0L || any(!is.finite(value))) {
    stop("`", path, "` must contain finite numeric change evidence.", call. = FALSE)
  }
  field <- affected_fields[[1L]]
  if (field %in% c("surv", "fecund")) {
    valid <- if (is.null(dim(value))) {
      length(value) == n_stage
    } else {
      identical(as.integer(dim(value)), c(as.integer(years), as.integer(n_stage)))
    }
    if (!valid) {
      stop(
        "`", path, "` vital-rate profile must be stage-matched or exactly years x stages.",
        call. = FALSE
      )
    }
  } else if (!is.null(dim(value)) || !length(value) %in% c(1L, years)) {
    stop(
      "`", path, "` scalar-field profile must have length one or exactly years.",
      call. = FALSE
    )
  }
  invisible(value)
}

woodhen_validate_spec_payload <- function(spec) {
  base_fields <- c(
    "name", "years", "reps", "surv", "stasis", "fecund", "sex_ratio_init",
    "monogamy", "n0", "demographic_stochasticity", "env_sd", "K", "K_sd",
    "cat_freq", "cat_surv", "cat_repro", "genetics", "F_init",
    "lethal_equiv", "B_on_fec", "Ne_N_ratio", "Ne_window", "purge_kappa"
  )
  optional_fields <- intersect(c("annual_profiles", "release_years", "release_vec"), names(spec))
  expected_fields <- c(base_fields, optional_fields)
  woodhen_require_exact_fields(spec, expected_fields, "scenario$spec")
  if (xor("release_years" %in% names(spec), "release_vec" %in% names(spec))) {
    stop("`scenario$spec` must store release years and vector together.", call. = FALSE)
  }

  years <- as.integer(spec$years)
  n_stage <- length(spec$n0)
  stage_fields <- c("surv", "stasis", "fecund", "n0", "lethal_equiv")
  for (field in stage_fields) {
    value <- spec[[field]]
    if (!is.numeric(value) || !is.null(dim(value)) || length(value) != n_stage ||
        any(!is.finite(value))) {
      stop("`scenario$spec$", field, "` must be one stage-matched vector.", call. = FALSE)
    }
  }
  scalar_fields <- setdiff(base_fields, c("name", stage_fields))
  for (field in scalar_fields) {
    value <- spec[[field]]
    if (length(value) != 1L || !is.null(dim(value))) {
      stop("`scenario$spec$", field, "` must be scalar.", call. = FALSE)
    }
  }
  if ("release_years" %in% names(spec)) {
    woodhen_validate_release_state(
      list(release_years = spec$release_years, release_vec = spec$release_vec),
      years,
      n_stage,
      "scenario$spec"
    )
  }

  if ("annual_profiles" %in% names(spec)) {
    profiles <- spec$annual_profiles
    allowed_profiles <- c(
      "surv", "fecund", "K", "K_sd", "env_sd", "cat_freq", "cat_surv", "cat_repro"
    )
    if (!is.list(profiles) || is.null(names(profiles)) || anyDuplicated(names(profiles)) ||
        any(!names(profiles) %in% allowed_profiles)) {
      stop("`scenario$spec$annual_profiles` contains an unsupported profile.", call. = FALSE)
    }
    for (field in names(profiles)) {
      value <- profiles[[field]]
      path <- paste0("scenario$spec$annual_profiles$", field)
      if (!is.numeric(value) || any(!is.finite(value))) {
        stop("`", path, "` must contain finite numeric values.", call. = FALSE)
      }
      if (field %in% c("surv", "fecund")) {
        if (!identical(as.integer(dim(value)), c(years, as.integer(n_stage)))) {
          stop("`", path, "` must be exactly years x stages.", call. = FALSE)
        }
      } else if (!is.null(dim(value)) || length(value) != years) {
        stop("`", path, "` must be one scalar-field value per year.", call. = FALSE)
      }
    }
  }
  invisible(spec)
}

woodhen_validate_component_payloads <- function(scenario) {
  components <- scenario$components
  changes <- scenario$changes
  temporal_profiles <- scenario$temporal_profile
  if (!is.list(components) || !is.list(changes) || !is.list(temporal_profiles)) {
    stop("Scenario components, changes, and temporal profiles must be lists.", call. = FALSE)
  }
  if (length(components) == 0L) {
    if (length(changes) != 0L || length(temporal_profiles) != 0L) {
      stop("A component-free scenario cannot retain changes or profiles.", call. = FALSE)
    }
    return(invisible(scenario))
  }
  component_names <- names(components)
  if (is.null(component_names) || anyDuplicated(component_names) ||
      !identical(component_names, names(changes)) ||
      !identical(component_names, names(temporal_profiles))) {
    stop("Scenario component, change, and profile names must match exactly.", call. = FALSE)
  }

  years <- as.integer(scenario$spec$years)
  n_stage <- length(scenario$spec$n0)
  allowed_fields <- c(
    "K", "K_sd", "env_sd", "cat_freq", "cat_surv", "cat_repro",
    "surv", "fecund", "release_years", "release_vec"
  )
  for (component_name in component_names) {
    component <- components[[component_name]]
    change <- changes[[component_name]]
    component_path <- paste0("scenario$components$", component_name)
    change_path <- paste0("scenario$changes$", component_name)
    woodhen_require_exact_fields(
      component,
      c(
        "component_id", "affected_fields", "affected_stages", "operator",
        "value", "temporal_profile"
      ),
      component_path
    )
    woodhen_require_exact_fields(
      change,
      c(
        "component_id", "affected_fields", "affected_stages", "operator",
        "before", "after", "temporal_profile"
      ),
      change_path
    )
    metadata_fields <- c(
      "component_id", "affected_fields", "affected_stages", "operator", "temporal_profile"
    )
    if (!identical(component$component_id, component_name) ||
        !all(vapply(metadata_fields, function(field) {
          identical(component[[field]], change[[field]])
        }, logical(1))) ||
        !identical(component$temporal_profile, temporal_profiles[[component_name]])) {
      stop("Component/change metadata must match its named scenario profile.", call. = FALSE)
    }

    affected_fields <- component$affected_fields
    valid_fields <- is.character(affected_fields) && length(affected_fields) > 0L &&
      all(affected_fields %in% allowed_fields) &&
      (length(affected_fields) == 1L ||
        identical(affected_fields, c("release_years", "release_vec")))
    if (!valid_fields) {
      stop("`", component_path, "$affected_fields` is not supported.", call. = FALSE)
    }
    valid_operators <- c(
      "absolute", "multiply", "recover_toward_locked_baseline",
      "recover_toward_one", "annual_release_schedule"
    )
    if (!is.character(component$operator) || length(component$operator) != 1L ||
        is.na(component$operator) || !component$operator %in% valid_operators) {
      stop("`", component_path, "$operator` is not supported.", call. = FALSE)
    }
    affected_stages <- component$affected_stages
    if (affected_fields[[1L]] %in% c("surv", "fecund")) {
      valid_stages <- is.numeric(affected_stages) && length(affected_stages) > 0L &&
        all(is.finite(affected_stages)) &&
        all(affected_stages == as.integer(affected_stages)) &&
        all(affected_stages >= 1L & affected_stages <= n_stage) &&
        !anyDuplicated(affected_stages)
    } else if (identical(affected_fields, c("release_years", "release_vec"))) {
      valid_stages <- identical(as.integer(affected_stages), 2L)
    } else {
      valid_stages <- identical(affected_stages, "not_applicable")
    }
    if (!valid_stages) {
      stop("`", component_path, "$affected_stages` is not stage-matched.", call. = FALSE)
    }

    value <- component$value
    max_value_length <- if (affected_fields[[1L]] %in% c("surv", "fecund")) {
      length(affected_stages)
    } else {
      1L
    }
    if (!is.numeric(value) || !is.null(dim(value)) || length(value) == 0L ||
        !length(value) %in% c(1L, max_value_length) || any(!is.finite(value))) {
      stop(
        "`", component_path, "$value` must be scalar or stage-matched, never a matrix.",
        call. = FALSE
      )
    }
    woodhen_validate_temporal_profile_record(
      component$temporal_profile,
      years,
      paste0(component_path, "$temporal_profile")
    )
    woodhen_validate_change_profile(
      change$before,
      affected_fields,
      years,
      n_stage,
      paste0(change_path, "$before")
    )
    woodhen_validate_change_profile(
      change$after,
      affected_fields,
      years,
      n_stage,
      paste0(change_path, "$after")
    )
  }
  invisible(scenario)
}

woodhen_validate_scenario_payload_shapes <- function(scenario) {
  woodhen_validate_spec_payload(scenario$spec)
  woodhen_validate_component_payloads(scenario)
  invisible(scenario)
}

woodhen_validate_scenario_metadata <- function(scenario) {
  required_character <- c(
    "record_schema_version", "scenario_id", "family_id", "student_label",
    "scenario_type", "locked_baseline_id", "reference_library_version",
    "catalog_version", "model_version", "spec_fingerprint",
    "fingerprint_algorithm", "canonicalization_version",
    "scientific_identity_fingerprint"
  )
  if (identical(scenario$scenario_type, "intervention")) {
    required_character <- c(required_character, "intervention_id")
  }
  for (field in required_character) {
    value <- scenario[[field]]
    if (!is.character(value) || length(value) != 1L || is.na(value) || !nzchar(value)) {
      stop(
        "`scenario$", field, "` must be one non-empty character value.",
        call. = FALSE
      )
    }
  }
  for (field in c("parent_id", "created_at", "modified_at")) {
    value <- scenario[[field]]
    if (!is.character(value) || length(value) != 1L ||
        (!is.na(value) && !nzchar(value))) {
      stop(
        "`scenario$", field, "` must be one character value or NA.",
        call. = FALSE
      )
    }
  }
  if (!identical(scenario$record_schema_version, "woodhen-scenario-record-v1")) {
    stop("`scenario$record_schema_version` is not supported.", call. = FALSE)
  }
  if (!is.null(scenario$notes) &&
      (!is.character(scenario$notes) || length(scenario$notes) != 1L ||
        is.na(scenario$notes))) {
    stop("`scenario$notes` must be NULL or one portable character value.", call. = FALSE)
  }
  woodhen_validate_seed(scenario$seed)
  invisible(scenario)
}

woodhen_validate_scenario_record <- function(scenario) {
  if (!is.list(scenario) || is.null(names(scenario)) || anyDuplicated(names(scenario))) {
    stop("`scenario` must be a complete Woodhen investigation scenario record.", call. = FALSE)
  }
  if (!is.character(scenario$scenario_type) || length(scenario$scenario_type) != 1L ||
      is.na(scenario$scenario_type) ||
      !scenario$scenario_type %in% c(
        "reference", "locked_baseline", "sensitivity", "threat", "intervention"
      )) {
    stop("`scenario$scenario_type` is not a supported investigation type.", call. = FALSE)
  }
  expected_fields <- woodhen_scenario_record_fields(scenario$scenario_type)
  missing_fields <- setdiff(expected_fields, names(scenario))
  unexpected_fields <- setdiff(names(scenario), expected_fields)
  if (length(missing_fields) > 0L) {
    stop(
      "`scenario` is missing required field(s): ",
      paste(missing_fields, collapse = ", "), ".",
      call. = FALSE
    )
  }
  if (length(unexpected_fields) > 0L) {
    stop(
      "`scenario` has unexpected field(s): ",
      paste(unexpected_fields, collapse = ", "), ".",
      call. = FALSE
    )
  }
  woodhen_validate_scenario_metadata(scenario)
  woodhen_validate_portable_value(scenario)
  if (!identical(woodhen_spec_fingerprint(scenario$spec), scenario$spec_fingerprint)) {
    stop("`scenario$spec_fingerprint` does not match its executable specification.", call. = FALSE)
  }
  if (identical(scenario$scenario_type, "reference")) {
    woodhen_validate_reference_scenario(scenario)
  } else {
    woodhen_validate_scenario_payload_shapes(scenario)
    woodhen_preflight_spec(scenario$spec)
  }
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

woodhen_result_provenance <- function(result, scenario) {
  params <- result$params
  if (!is.list(params) || is.null(names(params))) {
    stop("`result$params` must contain normalized executable provenance.", call. = FALSE)
  }
  seed_positions <- which(names(params) == "seed")
  if (length(seed_positions) != 1L || is.null(params[[seed_positions[[1L]]]])) {
    stop("The stored result seed is missing or ambiguous.", call. = FALSE)
  }
  seed <- tryCatch(
    woodhen_validate_seed(params[[seed_positions[[1L]]]]),
    error = function(e) {
      stop("The stored result seed is invalid.", call. = FALSE)
    }
  )

  normalized <- normalize_pva_spec(scenario$spec, stasis = NULL)
  expected_spec <- normalized$spec
  expected_param_names <- c(names(expected_spec), "years", "reps", "stasis", "seed")
  if (!identical(names(params), expected_param_names)) {
    stop(
      "The result executable provenance does not match the run_pva_core structure.",
      call. = FALSE
    )
  }

  mismatched <- vapply(names(expected_spec), function(field) {
    positions <- which(names(params) == field)
    if (length(positions) == 0L) {
      return(TRUE)
    }
    any(!vapply(positions, function(position) {
      identical(
        woodhen_canonical_value(params[[position]]),
        woodhen_canonical_value(expected_spec[[field]])
      )
    }, logical(1)))
  }, logical(1))
  if (any(mismatched)) {
    stop(
      "The result normalized executable specification does not match the scenario for field(s): ",
      paste(names(expected_spec)[mismatched], collapse = ", "), ".",
      call. = FALSE
    )
  }

  list(spec = expected_spec, stasis = normalized$stasis, seed = seed)
}

#' Store compact evidence from a completed Woodhen investigation
#'
#' @param result A retained-trajectory result from `run_pva_core()`.
#' @param scenario A validated Woodhen investigation scenario record.
#' @param sample_trajectories Maximum number of deterministic trajectories to retain.
#' @return A compact, serialisable `woodhen_compact_run`.
#' @export
compact_woodhen_run <- function(result, scenario, sample_trajectories = 100L) {
  woodhen_validate_scenario_record(scenario)
  provenance <- woodhen_result_provenance(result, scenario)
  total_trajectories <- woodhen_total_trajectories(result)
  reps <- as.integer(ncol(total_trajectories))
  horizon <- as.integer(nrow(total_trajectories) - 1L)
  if (!is.numeric(result$Nend) || length(result$Nend) != reps) {
    stop("`result$Nend` must contain one final abundance per replicate.", call. = FALSE)
  }
  final_trajectory_abundance <- as.numeric(total_trajectories[nrow(total_trajectories), ])
  if (!isTRUE(all.equal(
    as.numeric(result$Nend),
    final_trajectory_abundance,
    tolerance = 0,
    check.attributes = FALSE
  ))) {
    stop(
      "`result$Nend` does not match the final trajectory total abundance.",
      call. = FALSE
    )
  }
  if (!identical(reps, as.integer(scenario$spec$reps)) ||
      !identical(horizon, as.integer(scenario$spec$years))) {
    stop("The result replicate count and horizon must match the scenario specification.", call. = FALSE)
  }
  seed <- provenance$seed
  indices <- woodhen_sample_replicate_indices(reps, sample_trajectories)
  quasi_extinction <- summarize_quasi_extinction(
    result,
    threshold_pairs = 50L,
    holder_stages = seq.int(2L, dim(result$traj)[[2L]])
  )
  quasi_extinction$breeding_pair_trajectories <- NULL
  final_abundance <- woodhen_final_abundance_evidence(result$Nend)
  extinction_evidence <- woodhen_extinction_evidence(total_trajectories)
  summary <- summarize_pva_result(result, scenario = scenario$student_label)
  summary$PE <- extinction_evidence$probability_by_horizon
  summary$Nmed <- final_abundance$median
  summary$Nlo95 <- final_abundance$q025
  summary$Nhi95 <- final_abundance$q975
  summary$extinct_reps <- extinction_evidence$extinct_reps
  summary$surviving_reps <- reps - extinction_evidence$extinct_reps
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

  run <- structure(
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
      final_abundance = final_abundance,
      annual_quantiles = woodhen_annual_quantiles(total_trajectories),
      sampled_replicate_indices = indices,
      trajectory_sample = woodhen_sample_trajectory_data(total_trajectories, indices),
      extinction_evidence = extinction_evidence,
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
  woodhen_project_validate_run(run)
  run
}

#' Run one Woodhen investigation and immediately discard raw simulation arrays
#'
#' @param scenario A validated Woodhen investigation scenario record.
#' @param seed Integer run seed.
#' @param sample_trajectories Maximum number of deterministic trajectories to retain.
#' @param progress Optional progress callback passed to `run_pva_core()`.
#' @return A compact, serialisable `woodhen_compact_run`.
#' @export
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

woodhen_reference_run_id <- function(scenario, seed = scenario$seed) {
  seed <- woodhen_validate_seed(seed)
  paste0(
    "woodhen_run_",
    substr(woodhen_content_fingerprint(list(
      scenario_id = scenario$scenario_id,
      scientific_identity_fingerprint = scenario$scientific_identity_fingerprint,
      seed = seed,
      reps = as.integer(scenario$spec$reps)
    )), 1L, 16L)
  )
}

woodhen_reference_project_versions_match <- function(project) {
  identical(project$reference_library_version, woodhen_reference_library_version()) &&
    identical(project$catalog_version, woodhen_investigation_catalog_version()) &&
    identical(project$model_version, woodhen_model_version())
}

woodhen_reference_run_in_project <- function(project, reference_id) {
  scenario <- woodhen_reference_scenario(reference_id)
  expected_run_id <- woodhen_reference_run_id(scenario)
  run_ids <- vapply(project$runs, `[[`, character(1), "run_id")
  index <- match(expected_run_id, run_ids)
  if (is.na(index)) NULL else project$runs[[index]]
}

woodhen_run_reference_project_result <- function(project, reference_id, run, now) {
  scenario <- woodhen_reference_scenario(reference_id)
  woodhen_validate_compact_run(run)
  if (!identical(run$scenario, scenario) ||
      !identical(run$run_id, woodhen_reference_run_id(scenario)) ||
      !identical(run$seed, 123L) ||
      !identical(run$reps, 1000L) ||
      !identical(run$horizon, as.integer(scenario$spec$years))) {
    stop("The completed reference run does not match its exact reference identity.", call. = FALSE)
  }
  candidate <- add_woodhen_scenario(project, scenario, now = now)
  candidate <- add_woodhen_run(candidate, run, now = now)
  list(project = candidate, scenario = scenario, run = run, reused = FALSE)
}

woodhen_run_reference_project_reuse <- function(project, reference_id) {
  existing <- woodhen_reference_run_in_project(project, reference_id)
  if (is.null(existing)) return(NULL)
  scenario <- woodhen_reference_scenario(reference_id)
  if (!identical(existing$scenario, scenario) ||
      !identical(existing$seed, 123L) ||
      !identical(existing$reps, 1000L) ||
      !identical(existing$horizon, as.integer(scenario$spec$years))) {
    stop("An existing reference run has stale or incompatible identity.", call. = FALSE)
  }
  list(project = project, scenario = scenario, run = existing, reused = TRUE)
}

woodhen_validate_reference_action_args <- function(project, runner, sample_trajectories) {
  validate_woodhen_project(project)
  if (!woodhen_reference_project_versions_match(project)) {
    stop(
      "This project uses an incompatible reference library. Start or import a current compatible project.",
      call. = FALSE
    )
  }
  if (!is.function(runner)) {
    stop("`runner` must be a function.", call. = FALSE)
  }
  woodhen_validate_sample_count(sample_trajectories)
  invisible(project)
}

woodhen_call_reference_runner <- function(
    runner,
    scenario,
    sample_trajectories,
    progress
) {
  runner(
    scenario = scenario,
    seed = scenario$seed,
    sample_trajectories = sample_trajectories,
    progress = progress
  )
}

run_woodhen_reference_project <- function(
    project,
    reference_id,
    progress = NULL,
    runner = run_woodhen_investigation_scenario,
    sample_trajectories = 100L,
    now = Sys.time()
) {
  woodhen_validate_reference_action_args(project, runner, sample_trajectories)
  if (!is.null(progress) && !is.function(progress)) {
    stop("`progress` must be a function or NULL.", call. = FALSE)
  }
  scenario <- woodhen_reference_scenario(reference_id)
  existing <- woodhen_run_reference_project_reuse(project, reference_id)
  if (!is.null(existing)) return(existing)

  run <- woodhen_call_reference_runner(
    runner,
    scenario,
    sample_trajectories,
    progress
  )
  woodhen_run_reference_project_result(project, reference_id, run, now)
}

compare_woodhen_1980_references <- function(runs) {
  expected_ids <- c("01_no_mgmt", "02_pig_control", "03_captive_pig")
  if (!is.list(runs) || length(runs) != length(expected_ids)) {
    stop("The 1980 comparison requires exactly 01_no_mgmt, 02_pig_control, and 03_captive_pig.", call. = FALSE)
  }
  lapply(runs, woodhen_validate_compact_run)
  scenario_ids <- vapply(runs, `[[`, character(1), "scenario_id")
  if (anyDuplicated(scenario_ids) || !setequal(scenario_ids, expected_ids)) {
    stop("The 1980 comparison requires exactly 01_no_mgmt, 02_pig_control, and 03_captive_pig.", call. = FALSE)
  }
  runs <- runs[match(expected_ids, scenario_ids)]
  for (index in seq_along(runs)) {
    expected <- woodhen_reference_scenario(expected_ids[[index]])
    if (!identical(runs[[index]]$scenario, expected) ||
        !identical(runs[[index]]$seed, 123L) ||
        !identical(runs[[index]]$reps, 1000L) ||
        !identical(runs[[index]]$horizon, 40L)) {
      stop("The 1980 comparison includes stale or incompatible reference evidence.", call. = FALSE)
    }
  }
  table <- do.call(rbind, lapply(runs, woodhen_run_metric_row))
  rownames(table) <- NULL
  structure(
    list(
      comparison_id = "woodhen_reference_1980_crisis",
      reference_ids = expected_ids,
      table = table,
      runs = runs,
      interpretation = paste(
        "These cases share the 1980 decision context, starting state,",
        "40-year horizon, seed 123, and 1,000 simulated futures."
      )
    ),
    class = c("woodhen_1980_reference_comparison", "list")
  )
}

woodhen_calibration_history <- function() {
  future <- woodhen_reference_spec("05_future_baseline")
  list(
    crisis_1980 = list(
      period = "1980-2020",
      heading = "1980 crisis and 40-year management alternatives",
      reference_ids = c("01_no_mgmt", "02_pig_control", "03_captive_pig"),
      observed_history = paste(
        "By 1980, only about 4-6 viable breeding pairs remained in restricted",
        "upland habitat while pigs excluded Woodhens from the lowlands."
      ),
      horizon = 40L
    ),
    recovery_2019_2024 = list(
      period = "2019-2024",
      heading = "2019-2024 rodent-eradication recovery check",
      reference_ids = "04_rodent_eradication",
      observed_history = "The observed historical milestone was over 1,600 birds by 2024.",
      model_state = list(
        total_birds = as.integer(2 * sum(future$n0)),
        breeding_pairs = as.integer(sum(future$n0[-1L])),
        label = paste(
          "The supplied 2024 model state is exactly 1,654 birds and about",
          "330 breeding pairs; it is not an independently precise empirical census."
        )
      ),
      warning = paste(
        "Short-horizon warning: this five-year recovery check must not be ranked",
        "against the three 40-year cases."
      ),
      horizon = 5L
    ),
    future_2025_2100 = list(
      period = "2025-2100",
      heading = "2025-2100 locked future baseline",
      reference_ids = "05_future_baseline",
      observed_history = paste(
        "This no-change projection begins from the supplied 2024 model state",
        "and establishes the common future anchor for Act 2."
      ),
      horizon = 75L
    )
  )
}

woodhen_locked_anchor_expected_identity <- function() {
  scenario <- woodhen_reference_scenario("05_future_baseline")
  list(
    scenario_id = scenario$scenario_id,
    scenario_type = scenario$scenario_type,
    run_id = woodhen_reference_run_id(scenario),
    spec_fingerprint = scenario$spec_fingerprint,
    scientific_identity_fingerprint = scenario$scientific_identity_fingerprint,
    seed = 123L,
    reps = 1000L,
    horizon = 75L,
    reference_library_version = woodhen_reference_library_version(),
    catalog_version = woodhen_investigation_catalog_version(),
    model_version = woodhen_model_version()
  )
}

woodhen_locked_anchor_observed_identity <- function(project, scenario, run) {
  field_or_na <- function(value, field, type = "character") {
    result <- if (is.list(value)) value[[field]] else NULL
    if (!is.null(result) && length(result) == 1L) return(result)
    switch(type, integer = NA_integer_, character = NA_character_)
  }
  list(
    scenario_id = field_or_na(scenario, "scenario_id"),
    scenario_type = field_or_na(scenario, "scenario_type"),
    run_id = field_or_na(run, "run_id"),
    spec_fingerprint = field_or_na(run, "spec_fingerprint"),
    scientific_identity_fingerprint = field_or_na(run, "scientific_identity_fingerprint"),
    seed = field_or_na(run, "seed", "integer"),
    reps = field_or_na(run, "reps", "integer"),
    horizon = field_or_na(run, "horizon", "integer"),
    reference_library_version = field_or_na(project, "reference_library_version"),
    catalog_version = field_or_na(project, "catalog_version"),
    model_version = field_or_na(project, "model_version")
  )
}

woodhen_locked_anchor_result <- function(status, expected, observed, action) {
  list(status = status, expected = expected, observed = observed, action = action)
}

woodhen_locked_anchor_status <- function(project) {
  expected <- woodhen_locked_anchor_expected_identity()
  run_action <- "Run the locked future baseline."
  project_action <- "Start or import a current compatible project."
  if (is.null(project)) {
    return(woodhen_locked_anchor_result("missing", expected, NULL, run_action))
  }
  if (!is.list(project)) {
    return(woodhen_locked_anchor_result("stale", expected, NULL, project_action))
  }
  project_current <- woodhen_reference_project_versions_match(project)
  scenarios <- if (is.list(project$scenarios)) project$scenarios else list()
  runs <- if (is.list(project$runs)) project$runs else list()
  scenario_ids <- vapply(scenarios, function(value) {
    if (is.list(value) && is.character(value$scenario_id) && length(value$scenario_id) == 1L) {
      value$scenario_id
    } else {
      NA_character_
    }
  }, character(1))
  scenario <- if ("05_future_baseline" %in% scenario_ids) {
    scenarios[[match("05_future_baseline", scenario_ids)]]
  } else {
    NULL
  }
  run_scenario_ids <- vapply(runs, function(value) {
    if (is.list(value) && is.character(value$scenario_id) && length(value$scenario_id) == 1L) {
      value$scenario_id
    } else {
      NA_character_
    }
  }, character(1))
  run <- if ("05_future_baseline" %in% run_scenario_ids) {
    runs[[match("05_future_baseline", run_scenario_ids)]]
  } else {
    NULL
  }
  observed <- woodhen_locked_anchor_observed_identity(project, scenario, run)
  if (!project_current) {
    return(woodhen_locked_anchor_result("stale", expected, observed, project_action))
  }
  if (is.null(scenario) && is.null(run)) {
    return(woodhen_locked_anchor_result("missing", expected, observed, run_action))
  }
  expected_scenario <- woodhen_reference_scenario("05_future_baseline")
  if (is.null(run)) {
    status <- if (identical(scenario, expected_scenario)) "missing" else "stale"
    action <- if (identical(status, "missing")) run_action else project_action
    return(woodhen_locked_anchor_result(status, expected, observed, action))
  }
  validated <- !inherits(try(validate_woodhen_project(project), silent = TRUE), "try-error")
  identity_matches <- identical(scenario, expected_scenario) &&
    identical(observed, expected) &&
    identical(run$scenario, expected_scenario) &&
    identical(run$baseline_spec_fingerprint, expected$spec_fingerprint) &&
    identical(run$provenance$reference_library_version, expected$reference_library_version) &&
    identical(run$provenance$catalog_version, expected$catalog_version) &&
    identical(run$provenance$model_version, expected$model_version)
  status <- if (validated && identity_matches) "ready" else "stale"
  action <- if (identical(status, "ready")) "The locked future baseline is ready." else project_action
  woodhen_locked_anchor_result(status, expected, observed, action)
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
  seeds <- vapply(runs, `[[`, integer(1), "seed")
  if (length(unique(seeds)) != 1L) {
    issues <- c(issues, "seed differs")
  }
  replicate_counts <- vapply(runs, `[[`, integer(1), "reps")
  if (length(unique(replicate_counts)) != 1L) {
    issues <- c(issues, "replicate count differs")
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
  baseline_value <- if (identical(first_change$operator, "multiply")) {
    1
  } else if (is.numeric(first_change$before) && length(first_change$before) == 1L) {
    as.numeric(first_change$before)
  } else {
    NA_real_
  }
  baseline <- which(vapply(runs, function(run) is.na(run$parent_id), logical(1)))
  values[baseline] <- baseline_value
  for (index in altered) {
    component <- runs[[index]]$scenario$components[[1L]]
    if (is.numeric(component$value) && length(component$value) == 1L) {
      values[[index]] <- as.numeric(component$value)
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
    extinction_conditional_median_year =
      run$extinction_evidence$conditional_median_year,
    extinction_overall_median_year = run$extinction_evidence$overall_median_year,
    quasi_extinction_probability = run$quasi_extinction_50_pairs$probability_by_horizon,
    quasi_extinction_conditional_median_year =
      run$quasi_extinction_50_pairs$conditional_median_year,
    quasi_extinction_overall_median_year =
      run$quasi_extinction_50_pairs$overall_median_year,
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
#' @export
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

woodhen_family_expected_run_id <- function(scenario) {
  woodhen_reference_run_id(scenario, seed = scenario$seed)
}

woodhen_validate_core_family <- function(family) {
  if (!inherits(family, "woodhen_investigation_family") ||
      !is.list(family$scenarios) || length(family$scenarios) < 3L ||
      !family$family_type %in% c("sensitivity", "prospective")) {
    stop(
      "An investigation action requires a complete sensitivity or prospective family.",
      call. = FALSE
    )
  }
  lapply(family$scenarios, woodhen_validate_scenario_record)
  if (!identical(
    unname(vapply(family$scenarios, `[[`, character(1), "family_id")),
    rep(family$family_id, length(family$scenarios))
  )) {
    stop("Every scenario must share the supplied family identity.", call. = FALSE)
  }
  scenario_types <- unname(vapply(
    family$scenarios, `[[`, character(1), "scenario_type"
  ))
  expected_prefix <- if (identical(family$family_type, "sensitivity")) {
    c("locked_baseline", "sensitivity", "sensitivity")
  } else {
    c("locked_baseline", "threat", "intervention")
  }
  if (!identical(scenario_types[seq_along(expected_prefix)], expected_prefix)) {
    stop("The investigation family does not have the required scenario ancestry.", call. = FALSE)
  }
  locked <- woodhen_locked_future_spec()
  ordinary_controls <- vapply(family$scenarios, function(scenario) {
    identical(scenario$seed, 123L) && identical(scenario$spec$reps, 1000L) &&
      identical(scenario$spec$years, 75L) && identical(scenario$spec$n0, locked$n0)
  }, logical(1))
  if (!all(ordinary_controls)) {
    stop(
      "Core investigations require the locked starting population, 75 years, 1,000 futures, and seed 123.",
      call. = FALSE
    )
  }
  invisible(family)
}

woodhen_reconcile_family_scenarios <- function(project, family) {
  scenario_ids <- vapply(project$scenarios, `[[`, character(1), "scenario_id")
  scenarios <- family$scenarios
  for (index in seq_along(scenarios)) {
    existing <- match(scenarios[[index]]$scenario_id, scenario_ids)
    if (is.na(existing)) next
    stored <- project$scenarios[[existing]]
    same_science <- identical(
      stored$scientific_identity_fingerprint,
      scenarios[[index]]$scientific_identity_fingerprint
    ) && identical(stored$spec_fingerprint, scenarios[[index]]$spec_fingerprint) &&
      identical(stored$parent_id, scenarios[[index]]$parent_id)
    if (!same_science) {
      stop("Scenario ID collision with different scientific content.", call. = FALSE)
    }
    scenarios[[index]] <- stored
  }
  family$scenarios <- scenarios
  family
}

woodhen_existing_family_runs <- function(project, family) {
  expected_ids <- vapply(family$scenarios, woodhen_family_expected_run_id, character(1))
  run_ids <- vapply(project$runs, `[[`, character(1), "run_id")
  matches <- match(expected_ids, run_ids)
  if (anyNA(matches)) return(NULL)
  runs <- project$runs[matches]
  same_science <- vapply(seq_along(runs), function(index) {
    identical(
      runs[[index]]$scientific_identity_fingerprint,
      family$scenarios[[index]]$scientific_identity_fingerprint
    ) && identical(runs[[index]]$scenario_id, family$scenarios[[index]]$scenario_id) &&
      identical(runs[[index]]$seed, 123L) && identical(runs[[index]]$reps, 1000L) &&
      identical(runs[[index]]$horizon, 75L)
  }, logical(1))
  if (!all(same_science)) {
    stop("An existing family run has stale or incompatible identity.", call. = FALSE)
  }
  runs
}

woodhen_prompt_observation <- function(prompt, family_type, run_ids) {
  if (is.null(prompt) || length(prompt) == 0L) return(NULL)
  if (!is.list(prompt)) {
    stop("`prompt` must be a named list of pre-run responses or NULL.", call. = FALSE)
  }
  fields <- c("research_question", "biological_reason", "expected_direction")
  labels <- c(
    research_question = "Research question",
    biological_reason = "Biological reason",
    expected_direction = "Expected direction"
  )
  values <- vapply(fields, function(field) {
    value <- prompt[[field]]
    if (is.null(value)) return("")
    if (!is.character(value) || length(value) != 1L || is.na(value)) {
      stop("Every pre-run prompt response must be one plain-text value.", call. = FALSE)
    }
    trimws(value)
  }, character(1))
  keep <- nzchar(values)
  if (!any(keep)) return(NULL)
  list(
    title = if (identical(family_type, "sensitivity")) {
      "Sensitivity pre-run prompt"
    } else {
      "Future advice pre-run prompt"
    },
    note = paste(paste0(labels[keep], ": ", values[keep]), collapse = "\n"),
    run_ids = sort(run_ids)
  )
}

woodhen_add_prompt_once <- function(project, observation, now) {
  if (is.null(observation)) {
    return(list(project = project, saved = FALSE))
  }
  observation$run_ids <- sort(observation$run_ids)
  duplicate <- vapply(project$observations, function(existing) {
    identical(existing$title, observation$title) &&
      identical(existing$note, observation$note) &&
      identical(sort(existing$run_ids), observation$run_ids)
  }, logical(1))
  if (any(duplicate)) {
    return(list(project = project, saved = FALSE))
  }
  list(
    project = add_woodhen_observation(project, observation, now = now),
    saved = TRUE
  )
}

woodhen_call_family_runner <- function(runner,
                                       scenario,
                                       scenario_index,
                                       scenario_count,
                                       sample_trajectories,
                                       progress) {
  last_completed <- 0L
  callback <- function(completed, total) {
    completed <- as.integer(completed)
    total <- as.integer(total)
    if (total != 1000L || completed < last_completed || completed > total) {
      stop("Family progress must be monotonic within 1,000 futures.", call. = FALSE)
    }
    last_completed <<- completed
    if (!is.null(progress)) {
      progress(scenario_index, scenario_count, completed, total)
    }
  }
  run <- runner(
    scenario = scenario,
    seed = scenario$seed,
    sample_trajectories = sample_trajectories,
    progress = callback
  )
  if (last_completed < 1000L) callback(1000L, 1000L)
  run
}

woodhen_run_investigation_family_project <- function(
    project,
    family,
    prompt = NULL,
    progress = NULL,
    runner = run_woodhen_investigation_scenario,
    sample_trajectories = 100L,
    now = Sys.time()) {
  anchor <- woodhen_locked_anchor_status(project)
  if (!identical(anchor$status, "ready")) {
    stop(
      "A ready current-library locked future baseline is required. ",
      anchor$action,
      call. = FALSE
    )
  }
  validate_woodhen_project(project)
  woodhen_validate_core_family(family)
  if (!is.function(runner)) stop("`runner` must be a function.", call. = FALSE)
  if (!is.null(progress) && !is.function(progress)) {
    stop("`progress` must be a function or NULL.", call. = FALSE)
  }
  woodhen_validate_sample_count(sample_trajectories)
  timestamp <- woodhen_project_time(now, "now")
  family <- woodhen_reconcile_family_scenarios(project, family)
  runs <- woodhen_existing_family_runs(project, family)
  reused <- !is.null(runs)

  if (is.null(runs)) {
    runs <- lapply(seq_along(family$scenarios), function(index) {
      run <- woodhen_call_family_runner(
        runner = runner,
        scenario = family$scenarios[[index]],
        scenario_index = index,
        scenario_count = length(family$scenarios),
        sample_trajectories = sample_trajectories,
        progress = progress
      )
      woodhen_validate_compact_run(run)
      expected_id <- woodhen_family_expected_run_id(family$scenarios[[index]])
      if (!identical(run$run_id, expected_id) ||
          !identical(run$scenario, family$scenarios[[index]])) {
        stop("A completed family run does not match its exact scenario identity.", call. = FALSE)
      }
      run
    })
  } else if (!is.null(progress)) {
    for (index in seq_along(runs)) {
      progress(index, length(runs), 1000L, 1000L)
    }
  }

  comparison <- compare_woodhen_run_family(runs, family$family_id)
  candidate <- project
  if (!reused) {
    for (scenario in family$scenarios) {
      candidate <- add_woodhen_scenario(candidate, scenario, now = timestamp)
    }
    for (run in comparison$runs) {
      candidate <- add_woodhen_run(candidate, run, now = timestamp)
    }
  }
  run_ids <- vapply(comparison$runs, `[[`, character(1), "run_id")
  observation <- woodhen_prompt_observation(prompt, family$family_type, run_ids)
  prompted <- woodhen_add_prompt_once(candidate, observation, timestamp)
  candidate <- prompted$project
  validate_woodhen_project(candidate)

  list(
    project = candidate,
    family = family,
    comparison = comparison,
    runs = comparison$runs,
    reused = reused,
    prompt_saved = prompted$saved
  )
}
