woodhen_or <- function(value, default) {
  if (is.null(value)) default else value
}

woodhen_validate_seed <- function(seed) {
  valid <- is.numeric(seed) && length(seed) == 1L && is.finite(seed) &&
    abs(seed - round(seed)) < sqrt(.Machine$double.eps)
  if (!valid) {
    stop("`seed` must be a finite integer scalar.", call. = FALSE)
  }
  as.integer(round(seed))
}

woodhen_normalize_record_time <- function(value, field) {
  if (is.null(value)) {
    return(NA_character_)
  }
  if (is.character(value) && length(value) == 1L && is.na(value)) {
    return(NA_character_)
  }
  if (inherits(value, "POSIXt") && length(value) == 1L && !is.na(value)) {
    return(format(value, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"))
  }
  valid <- is.character(value) && length(value) == 1L && !is.na(value) &&
    grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$", value)
  if (valid) {
    parsed <- as.POSIXct(strptime(value, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"))
    valid <- length(parsed) == 1L && !is.na(parsed) &&
      identical(format(parsed, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), value)
  }
  if (!valid) {
    stop(
      "`", field, "` must use the UTC ISO-8601 representation YYYY-MM-DDTHH:MM:SSZ.",
      call. = FALSE
    )
  }
  value
}

woodhen_model_version <- function() {
  tryCatch(
    as.character(utils::packageVersion("rPVA")),
    error = function(e) "0.0.1.000"
  )
}

woodhen_canonical_value <- function(value) {
  if (is.matrix(value)) {
    return(list(
      type = "matrix",
      dim = as.integer(dim(value)),
      values = as.numeric(value)
    ))
  }
  if (is.list(value)) {
    value <- unclass(value)
    if (!is.null(names(value))) {
      value <- value[order(names(value))]
    }
    return(lapply(value, woodhen_canonical_value))
  }
  if (is.integer(value)) {
    return(as.integer(unname(value)))
  }
  if (is.numeric(value)) {
    return(as.numeric(unname(value)))
  }
  if (is.logical(value)) {
    return(as.logical(unname(value)))
  }
  unname(value)
}

woodhen_content_fingerprint <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop(
      "The locked `digest` package is required for Woodhen SHA-256 fingerprints.",
      call. = FALSE
    )
  }
  digest::digest(
    woodhen_canonical_value(value),
    algo = "sha256",
    serialize = TRUE,
    serializeVersion = 3L
  )
}

woodhen_spec_fingerprint <- function(spec) {
  executable <- unclass(spec)
  executable$name <- NULL
  executable <- executable[order(names(executable))]
  woodhen_content_fingerprint(executable)
}

woodhen_reference_spec <- function(reference_id) {
  row <- woodhen_catalog_match(woodhen_reference_catalog(), reference_id, "reference scenario")
  set_scenario(row$id[[1]], "woodhen")
}

#' Load a fresh immutable Woodhen future anchor
#'
#' @return The exact validated `05_future_baseline.yaml` specification.
#' @export
woodhen_locked_future_spec <- function() {
  woodhen_reference_spec("05_future_baseline")
}

woodhen_spec_field_profile <- function(spec, field) {
  profile <- spec$annual_profiles[[field]]
  if (!is.null(profile)) {
    return(profile)
  }
  value <- spec[[field]]
  if (field %in% c("surv", "fecund")) {
    return(matrix(rep(value, each = spec$years), nrow = spec$years))
  }
  rep(value, spec$years)
}

woodhen_put_field_profile <- function(spec, field, profile) {
  profiles <- woodhen_or(spec$annual_profiles, list())
  profiles[[field]] <- profile
  spec$annual_profiles <- profiles
  spec
}

woodhen_profile_row <- function(profile, year) {
  if (is.matrix(profile)) as.numeric(profile[year, ]) else profile[[year]]
}

woodhen_preflight_spec <- function(spec, locked = woodhen_locked_future_spec()) {
  for (field in c("n0", "years", "reps", "stasis")) {
    if (!identical(spec[[field]], locked[[field]])) {
      stop("Student scenarios cannot change locked field `", field, "`.", call. = FALSE)
    }
  }

  spec <- normalize_pva_spec_fields(spec)
  spec <- validate_full_pva_spec(spec)
  if (!is.null(spec$release_years) && any(spec$release_years > spec$years)) {
    stop("`release_years` must lie between 1 and `years`.", call. = FALSE)
  }
  if (!is.null(spec$removal_years) && any(spec$removal_years > spec$years)) {
    stop("`removal_years` must lie between 1 and `years`.", call. = FALSE)
  }

  surv_profile <- woodhen_spec_field_profile(spec, "surv")
  env_profile <- woodhen_spec_field_profile(spec, "env_sd")
  k_profile <- woodhen_spec_field_profile(spec, "K")
  k_sd_profile <- woodhen_spec_field_profile(spec, "K_sd")

  for (year in seq_len(spec$years)) {
    compute_env_beta_params(
      woodhen_profile_row(surv_profile, year),
      woodhen_profile_row(env_profile, year)
    )
    annual_k <- woodhen_profile_row(k_profile, year)
    annual_k_sd <- woodhen_profile_row(k_sd_profile, year)
    if (!is.finite(annual_k) || annual_k < 150) {
      stop("Every annual practical state must have K >= 150.", call. = FALSE)
    }
    if (!is.finite(annual_k_sd) || annual_k_sd < 0 || annual_k < 3 * annual_k_sd) {
      stop("Every annual practical state must satisfy K >= 3*K_sd.", call. = FALSE)
    }
  }

  if (!is.null(spec$cat_repro) && (spec$cat_repro < 0 || spec$cat_repro > 1)) {
    stop("`cat_repro` must lie in [0, 1] for Woodhen investigations.", call. = FALSE)
  }
  if (!is.null(spec$annual_profiles$cat_repro)) {
    validate_probability_vector(spec$annual_profiles$cat_repro, "annual_profiles$cat_repro")
  }

  class(spec) <- c("pva_spec", setdiff(class(spec), "pva_spec"))
  spec
}

woodhen_new_record <- function(spec,
                               scenario_id,
                               family_id,
                               student_label,
                               scenario_type,
                               parent_id,
                               components,
                               changes,
                               seed,
                               created_at,
                               modified_at,
                               notes = NULL,
                               locked = woodhen_locked_future_spec()) {
  woodhen_validate_composed_record_names(components, changes)
  spec <- woodhen_preflight_spec(spec, locked = locked)
  structure(
    list(
      record_schema_version = "woodhen-scenario-record-v1",
      scenario_id = scenario_id,
      family_id = family_id,
      student_label = student_label,
      scenario_type = scenario_type,
      parent_id = parent_id,
      locked_baseline_id = "05_future_baseline",
      components = components,
      changes = changes,
      temporal_profile = lapply(components, `[[`, "temporal_profile"),
      spec = spec,
      seed = seed,
      reference_library_version = woodhen_reference_library_version(),
      catalog_version = woodhen_investigation_catalog_version(),
      model_version = woodhen_model_version(),
      created_at = created_at,
      modified_at = modified_at,
      notes = notes,
      spec_fingerprint = woodhen_spec_fingerprint(spec),
      fingerprint_algorithm = "sha256",
      canonicalization_version = "woodhen-spec-canonical-v1"
    ),
    class = c("woodhen_investigation_scenario", "list")
  )
}

woodhen_new_family <- function(family_id,
                               family_type,
                               scenarios,
                               seed,
                               ...) {
  structure(
    list(
      family_id = family_id,
      family_type = family_type,
      seed = seed,
      scenarios = scenarios,
      ...
    ),
    class = c("woodhen_investigation_family", "list")
  )
}

woodhen_validate_composed_record_names <- function(components, changes) {
  for (entry in list(components = components, changes = changes)) {
    if (length(entry) > 0L &&
        (is.null(names(entry)) || anyNA(names(entry)) ||
          any(!nzchar(names(entry))) || anyDuplicated(names(entry)))) {
      stop(
        "Component/change name collision: fully composed records require unique names.",
        call. = FALSE
      )
    }
  }
  if (!identical(names(components), names(changes))) {
    stop("Fully composed component and change names must match exactly.", call. = FALSE)
  }
  invisible(TRUE)
}

woodhen_finalize_family_identity <- function(family_type,
                                             scientific_key,
                                             scenarios,
                                             scenario_keys = NULL) {
  fingerprints <- vapply(scenarios, `[[`, character(1), "spec_fingerprint")
  if (identical(family_type, "sensitivity")) {
    content <- list(
      family_type = family_type,
      scientific_key = scientific_key,
      altered_specs = sort(fingerprints[-1L])
    )
  } else {
    managed <- if (length(fingerprints) > 2L) sort(fingerprints[-c(1L, 2L)]) else character()
    content <- list(
      family_type = family_type,
      scientific_key = scientific_key,
      threat_spec = fingerprints[[2L]],
      intervention_specs = managed
    )
  }
  suffix <- substr(woodhen_content_fingerprint(content), 1L, 12L)
  family_id <- paste0(family_type, "_", scientific_key, "_", suffix)

  scenarios[[1L]]$family_id <- family_id
  scenarios[[1L]]$scenario_id <- paste0(family_id, "__baseline")
  scenarios[[1L]]$parent_id <- NA_character_
  scenarios[[1L]]$locked_baseline_id <- scenarios[[1L]]$scenario_id

  if (identical(family_type, "sensitivity")) {
    for (i in seq_along(scenarios)[-1L]) {
      scenarios[[i]]$family_id <- family_id
      scenarios[[i]]$scenario_id <- paste0(
        family_id, "__setting_", substr(scenarios[[i]]$spec_fingerprint, 1L, 12L)
      )
      scenarios[[i]]$parent_id <- scenarios[[1L]]$scenario_id
      scenarios[[i]]$locked_baseline_id <- scenarios[[1L]]$scenario_id
    }
  } else {
    scenarios[[2L]]$family_id <- family_id
    scenarios[[2L]]$scenario_id <- paste0(
      family_id, "__threat_", substr(scenarios[[2L]]$spec_fingerprint, 1L, 12L)
    )
    scenarios[[2L]]$parent_id <- scenarios[[1L]]$scenario_id
    scenarios[[2L]]$locked_baseline_id <- scenarios[[1L]]$scenario_id
    if (length(scenarios) > 2L) {
      stopifnot(length(scenario_keys) == length(scenarios) - 2L)
      for (i in seq.int(3L, length(scenarios))) {
        key <- scenario_keys[[i - 2L]]
        scenarios[[i]]$family_id <- family_id
        scenarios[[i]]$scenario_id <- paste0(
          family_id, "__intervention_", key, "_",
          substr(scenarios[[i]]$spec_fingerprint, 1L, 12L)
        )
        scenarios[[i]]$parent_id <- scenarios[[2L]]$scenario_id
        scenarios[[i]]$locked_baseline_id <- scenarios[[1L]]$scenario_id
      }
    }
  }

  ids <- vapply(scenarios, `[[`, character(1), "scenario_id")
  if (anyDuplicated(ids)) {
    stop("Scientific family construction produced duplicate scenario identities.", call. = FALSE)
  }
  list(family_id = family_id, scenarios = scenarios)
}

woodhen_catalog_match <- function(catalog, id, kind) {
  row <- catalog[catalog$id == id, , drop = FALSE]
  if (nrow(row) != 1L) {
    stop("Unknown Woodhen ", kind, ": ", id, call. = FALSE)
  }
  row
}

woodhen_factor_id <- function(factor_id) {
  if (!is.character(factor_id) || length(factor_id) != 1L || is.na(factor_id)) {
    stop("`factor_id` must be one Woodhen sensitivity factor ID.", call. = FALSE)
  }
  aliases <- c(
    breeding_territory_capacity = "K",
    all_stage_survival = "surv",
    juvenile_survival = "juvenile_surv",
    fecundity = "fecund",
    catastrophe_probability = "cat_freq",
    catastrophe_survival = "cat_surv",
    environmental_variability = "env_sd",
    habitat_capacity_variability = "K_sd"
  )
  if (factor_id %in% names(aliases)) aliases[[factor_id]] else factor_id
}

woodhen_resolve_bounded_value <- function(value, row, label = "value") {
  if (is.character(value) && length(value) == 1L && value %in% names(row$anchors[[1]])) {
    value <- row$anchors[[1]][[value]]
  }
  valid <- is.numeric(value) && length(value) == 1L && is.finite(value)
  if (!valid) {
    stop("`", label, "` must be one finite number or a named anchor.", call. = FALSE)
  }
  bounds <- row$custom_range[[1]]
  if (value < bounds[["min"]] || value > bounds[["max"]]) {
    stop(
      "`", label, "` must lie between ", bounds[["min"]], " and ",
      bounds[["max"]], " for `", row$id[[1]], "`.",
      call. = FALSE
    )
  }
  as.numeric(value)
}

woodhen_setting_id <- function(value) {
  label <- format(value, scientific = FALSE, trim = TRUE, digits = 12)
  label <- sub("^-", "m", label)
  gsub("\\.", "p", label)
}

woodhen_sensitivity_change <- function(spec, row, value) {
  mapping <- row$mapping[[1]][[1]]
  field <- mapping$affected_fields[[1]]
  stages <- mapping$affected_stages
  before <- spec[[field]]

  if (identical(row$id[[1]], "surv")) {
    spec$surv <- spec$surv * value
  } else if (identical(row$id[[1]], "juvenile_surv")) {
    spec$surv[1:2] <- spec$surv[1:2] * value
  } else if (identical(row$id[[1]], "fecund")) {
    spec$fecund <- spec$fecund * value
  } else {
    spec[[field]] <- value
  }

  component_id <- names(row$mapping[[1]])[[1]]
  component <- list(
    component_id = component_id,
    affected_fields = field,
    affected_stages = stages,
    operator = mapping$operator,
    value = value,
    temporal_profile = list(shape = "fixed_setting", onset_year = 1L, end_year = spec$years)
  )
  change <- list(
    component_id = component_id,
    affected_fields = field,
    affected_stages = stages,
    operator = mapping$operator,
    before = before,
    after = spec[[field]],
    temporal_profile = component$temporal_profile
  )
  list(spec = spec, component = component, change = change)
}

#' Build a bounded one-factor Woodhen sensitivity family
#'
#' @param factor_id Sensitivity factor ID from `woodhen_sensitivity_catalog()`.
#' @param values At least two altered settings. The locked baseline is added once.
#' @param seed Common integer comparison seed.
#' @param created_at Optional caller-supplied creation timestamp.
#' @param modified_at Optional caller-supplied modification timestamp.
#' @return A `woodhen_investigation_family` with baseline and sensitivity records.
#' @export
build_woodhen_sensitivity_family <- function(factor_id,
                                             values,
                                             seed = 123L,
                                             created_at = NULL,
                                             modified_at = created_at) {
  factor_id <- woodhen_factor_id(factor_id)
  row <- woodhen_catalog_match(woodhen_sensitivity_catalog(), factor_id, "sensitivity factor")
  if (!is.numeric(values) || length(values) == 0L || any(!is.finite(values))) {
    stop("`values` must be a finite numeric vector.", call. = FALSE)
  }
  baseline_value <- row$locked_baseline[[1]]
  values <- unique(as.numeric(values[values != baseline_value]))
  if (length(values) < 2L) {
    stop("A sensitivity family requires at least two altered settings.", call. = FALSE)
  }
  values <- vapply(values, woodhen_resolve_bounded_value, numeric(1), row = row, label = "values")
  seed <- woodhen_validate_seed(seed)
  created_at <- woodhen_normalize_record_time(created_at, "created_at")
  modified_at <- woodhen_normalize_record_time(modified_at, "modified_at")
  locked <- woodhen_locked_future_spec()
  family_id <- paste0("sensitivity_", factor_id)

  baseline <- woodhen_new_record(
    spec = locked,
    scenario_id = paste0(family_id, "_baseline"),
    family_id = family_id,
    student_label = paste0(row$label[[1]], " - locked baseline"),
    scenario_type = "locked_baseline",
    parent_id = NA_character_,
    components = list(),
    changes = list(),
    seed = seed,
    created_at = created_at,
    modified_at = modified_at,
    locked = locked
  )

  altered <- lapply(values, function(value) {
    changed <- woodhen_sensitivity_change(woodhen_locked_future_spec(), row, value)
    component_id <- changed$component$component_id
    woodhen_new_record(
      spec = changed$spec,
      scenario_id = paste0(family_id, "_", woodhen_setting_id(value)),
      family_id = family_id,
      student_label = paste0(row$label[[1]], " = ", format(value, trim = TRUE)),
      scenario_type = "sensitivity",
      parent_id = baseline$scenario_id,
      components = stats::setNames(list(changed$component), component_id),
      changes = stats::setNames(list(changed$change), component_id),
      seed = seed,
      created_at = created_at,
      modified_at = modified_at,
      locked = locked
    )
  })

  scenarios <- c(list(baseline), altered)
  identity <- woodhen_finalize_family_identity(
    family_type = "sensitivity",
    scientific_key = factor_id,
    scenarios = scenarios
  )
  woodhen_new_family(
    family_id = identity$family_id,
    family_type = "sensitivity",
    scenarios = identity$scenarios,
    seed = seed,
    factor_id = factor_id,
    values = c(baseline_value, values),
    locked_baseline_id = identity$scenarios[[1L]]$scenario_id
  )
}

woodhen_validate_no_locked_controls <- function(config) {
  locked_names <- intersect(names(config), c("n0", "years", "reps", "stasis", "seed"))
  if (length(locked_names)) {
    stop(
      "Student scenarios cannot change locked field(s): ",
      paste(locked_names, collapse = ", "), ".",
      call. = FALSE
    )
  }
}

woodhen_validate_named_components <- function(components, label) {
  if (is.null(components) || length(components) == 0L) {
    return(list())
  }
  if (!is.list(components)) {
    stop("`", label, "` must be a named list.", call. = FALSE)
  }
  if (is.null(names(components)) || anyNA(names(components)) ||
      any(!nzchar(names(components))) || anyDuplicated(names(components))) {
    stop("Every multi-factor component must be named with a unique, non-empty ID.", call. = FALSE)
  }
  components
}

woodhen_normalize_shape <- function(config, row, years) {
  shape <- woodhen_or(config$temporal_shape, woodhen_or(config$shape, row$default_temporal_shape[[1]]))
  allowed <- row$allowed_temporal_shapes[[1]]
  if (!is.character(shape) || length(shape) != 1L || !shape %in% allowed) {
    stop(
      "Temporal shape `", paste(shape, collapse = ""), "` is not allowed for `",
      row$id[[1]], "`; choose ", paste(allowed, collapse = " or "), ".",
      call. = FALSE
    )
  }
  onset_year <- validate_temporal_year_arg(woodhen_or(config$onset_year, 1L), "onset_year", years)
  end_default <- if (identical(shape, "linear")) years else onset_year
  end_year <- validate_temporal_year_arg(woodhen_or(config$end_year, end_default), "end_year", years)
  if (end_year < onset_year) {
    stop("`end_year` must not precede `onset_year`.", call. = FALSE)
  }
  list(shape = shape, onset_year = onset_year, end_year = end_year)
}

woodhen_effect_weights <- function(years, temporal_profile) {
  build_temporal_profile(
    baseline = 0,
    target = 1,
    years = years,
    onset_year = temporal_profile$onset_year,
    end_year = temporal_profile$end_year,
    shape = temporal_profile$shape
  )
}

woodhen_component_stages <- function(stages, field, n_stage) {
  if (!field %in% c("surv", "fecund")) {
    return("not_applicable")
  }
  if (is.null(stages) || identical(stages, "all")) {
    return(seq_len(n_stage))
  }
  if (!is.numeric(stages) || any(!is.finite(stages)) || any(stages != round(stages)) ||
      any(stages < 1 | stages > n_stage)) {
    stop("Vital-rate component stages must be valid stage indices or `all`.", call. = FALSE)
  }
  unique(as.integer(stages))
}

woodhen_validate_component_value <- function(field, operator, value, stages, locked) {
  if (field %in% c("surv", "fecund")) {
    expected <- length(stages)
    if (!(length(value) %in% c(1L, expected))) {
      stop(
        "Vital-rate component `", field, "` must provide one scalar or exactly ",
        expected, " values for the selected stages.",
        call. = FALSE
      )
    }
  } else if (length(value) != 1L) {
    stop("Scalar component `", field, "` must have one value.", call. = FALSE)
  }
  bounds <- NULL
  if (operator %in% c("recover_toward_locked_baseline", "recover_toward_one")) {
    bounds <- c(min = 0, max = 1)
  } else if (identical(operator, "absolute")) {
    bounds <- switch(
      field,
      K = c(min = 150, max = 750),
      K_sd = c(min = 0, max = 150),
      env_sd = c(min = 0, max = 0.30),
      cat_freq = c(min = 0, max = 0.20),
      cat_surv = c(min = 0.20, max = 1),
      cat_repro = c(min = 0, max = 1),
      surv = c(min = 0, max = 1),
      fecund = c(min = 0, max = max(locked$fecund) * 1.20)
    )
  } else if (identical(operator, "multiply")) {
    bounds <- switch(
      field,
      surv = c(min = 0.50, max = 1.10),
      fecund = c(min = 0.40, max = 1.20),
      NULL
    )
  }
  if (is.null(bounds)) {
    stop("Unsupported component operator `", operator, "` for field `", field, "`.", call. = FALSE)
  }
  if (any(value < bounds[["min"]] | value > bounds[["max"]])) {
    stop(
      "Component `", field, "` values must lie between ", bounds[["min"]],
      " and ", bounds[["max"]], ".",
      call. = FALSE
    )
  }
  invisible(value)
}

woodhen_apply_profile_component <- function(spec,
                                            locked,
                                            component_id,
                                            field,
                                            operator,
                                            value,
                                            stages,
                                            temporal_profile) {
  allowed_fields <- c("K", "K_sd", "env_sd", "cat_freq", "cat_surv", "cat_repro", "surv", "fecund")
  if (!is.character(field) || length(field) != 1L || !field %in% allowed_fields) {
    stop("Unsupported or locked component field `", paste(field, collapse = ""), "`.", call. = FALSE)
  }
  if (!is.numeric(value) || length(value) == 0L || any(!is.finite(value))) {
    stop("Component `", component_id, "` must have finite numeric `value`.", call. = FALSE)
  }
  stages <- woodhen_component_stages(stages, field, length(spec$surv))
  woodhen_validate_component_value(field, operator, value, stages, locked)
  before <- woodhen_spec_field_profile(spec, field)
  locked_profile <- woodhen_spec_field_profile(locked, field)
  weights <- woodhen_effect_weights(spec$years, temporal_profile)
  after <- before

  if (field %in% c("surv", "fecund")) {
    stage_values <- if (length(value) == 1L) rep(value, length(stages)) else value
    for (year in seq_len(spec$years)) {
      current <- as.numeric(before[year, ])
      baseline <- as.numeric(locked_profile[year, ])
      if (identical(operator, "absolute")) {
        target <- current
        target[stages] <- stage_values
        current[stages] <- current[stages] + weights[[year]] * (target[stages] - current[stages])
      } else if (identical(operator, "multiply")) {
        current[stages] <- current[stages] * (1 + weights[[year]] * (stage_values - 1))
      } else if (identical(operator, "recover_toward_locked_baseline")) {
        current[stages] <- current[stages] +
          weights[[year]] * stage_values * (baseline[stages] - current[stages])
      } else {
        stop("Unsupported vital-rate component operator `", operator, "`.", call. = FALSE)
      }
      after[year, ] <- current
    }
  } else {
    if (identical(operator, "absolute")) {
      after <- before + weights * (value - before)
    } else if (identical(operator, "multiply")) {
      after <- before * (1 + weights * (value - 1))
    } else if (identical(operator, "recover_toward_locked_baseline")) {
      after <- before + weights * value * (locked_profile - before)
    } else if (identical(operator, "recover_toward_one")) {
      after <- before + weights * value * (1 - before)
    } else {
      stop("Unsupported scalar component operator `", operator, "`.", call. = FALSE)
    }
  }

  spec <- woodhen_put_field_profile(spec, field, after)
  component <- list(
    component_id = component_id,
    affected_fields = field,
    affected_stages = stages,
    operator = operator,
    value = value,
    temporal_profile = temporal_profile
  )
  change <- list(
    component_id = component_id,
    affected_fields = field,
    affected_stages = stages,
    operator = operator,
    before = before,
    after = after,
    temporal_profile = temporal_profile
  )
  list(spec = spec, component = component, change = change)
}

woodhen_advanced_temporal_profile <- function(component, default, years) {
  shape <- woodhen_or(component$temporal_shape, woodhen_or(component$shape, default$shape))
  if (!is.character(shape) || length(shape) != 1L || !shape %in% c("step", "linear")) {
    stop("Advanced component temporal shape is not allowed; choose step or linear.", call. = FALSE)
  }
  onset <- validate_temporal_year_arg(
    woodhen_or(component$onset_year, default$onset_year),
    "onset_year",
    years
  )
  end_default <- if (identical(shape, "linear")) default$end_year else onset
  end <- validate_temporal_year_arg(
    woodhen_or(component$end_year, end_default),
    "end_year",
    years
  )
  if (end < onset) {
    stop("`end_year` must not precede `onset_year`.", call. = FALSE)
  }
  list(shape = shape, onset_year = onset, end_year = end)
}

woodhen_apply_advanced_components <- function(spec,
                                              locked,
                                              components,
                                              default_temporal_profile) {
  applied_components <- list()
  changes <- list()
  for (component_id in names(components)) {
    config <- components[[component_id]]
    if (!is.list(config)) {
      stop("Advanced component `", component_id, "` must be a list.", call. = FALSE)
    }
    woodhen_validate_no_locked_controls(config)
    temporal_profile <- woodhen_advanced_temporal_profile(
      config,
      default_temporal_profile,
      spec$years
    )
    applied <- woodhen_apply_profile_component(
      spec = spec,
      locked = locked,
      component_id = component_id,
      field = config$field,
      operator = woodhen_or(config$operator, "absolute"),
      value = config$value,
      stages = config$stages,
      temporal_profile = temporal_profile
    )
    spec <- applied$spec
    applied_components[[component_id]] <- applied$component
    changes[[component_id]] <- applied$change
  }
  list(spec = spec, components = applied_components, changes = changes)
}

woodhen_normalize_threat <- function(threat, locked) {
  if (is.character(threat) && length(threat) == 1L && !is.na(threat)) {
    config <- list(threat_id = threat)
  } else if (is.list(threat)) {
    config <- threat
  } else {
    stop("`threat` must be a threat ID or a named threat configuration.", call. = FALSE)
  }
  woodhen_validate_no_locked_controls(config)
  threat_id <- woodhen_or(config$threat_id, config$id)
  if (!is.character(threat_id) || length(threat_id) != 1L || is.na(threat_id)) {
    stop("A threat configuration must include one `threat_id`.", call. = FALSE)
  }
  row <- woodhen_catalog_match(woodhen_threat_catalog(), threat_id, "threat")
  intensity <- woodhen_resolve_bounded_value(
    woodhen_or(config$intensity, "moderate"),
    row,
    label = "threat intensity"
  )
  temporal_profile <- woodhen_normalize_shape(config, row, locked$years)
  components <- woodhen_validate_named_components(config$components, "threat components")
  list(
    config = config,
    row = row,
    threat_id = threat_id,
    intensity = intensity,
    temporal_profile = temporal_profile,
    components = components
  )
}

woodhen_build_threat_scenario <- function(threat,
                                          locked,
                                          family_id,
                                          baseline,
                                          seed,
                                          created_at,
                                          modified_at) {
  normalized <- woodhen_normalize_threat(threat, locked)
  mapping <- normalized$row$mapping[[1]][[1]]
  primary_id <- names(normalized$row$mapping[[1]])[[1]]
  applied <- woodhen_apply_profile_component(
    spec = woodhen_locked_future_spec(),
    locked = locked,
    component_id = primary_id,
    field = mapping$affected_fields[[1]],
    operator = mapping$operator,
    value = normalized$intensity,
    stages = mapping$affected_stages,
    temporal_profile = normalized$temporal_profile
  )
  components <- stats::setNames(list(applied$component), primary_id)
  changes <- stats::setNames(list(applied$change), primary_id)

  if (length(normalized$components)) {
    advanced <- woodhen_apply_advanced_components(
      spec = applied$spec,
      locked = locked,
      components = normalized$components,
      default_temporal_profile = normalized$temporal_profile
    )
    applied$spec <- advanced$spec
    components <- c(components, advanced$components)
    changes <- c(changes, advanced$changes)
  }

  intensity_label <- names(normalized$row$anchors[[1]])[
    normalized$row$anchors[[1]] == normalized$intensity
  ][1]
  if (is.na(intensity_label)) {
    intensity_label <- format(normalized$intensity, trim = TRUE)
  }
  scenario <- woodhen_new_record(
    spec = applied$spec,
    scenario_id = paste0(family_id, "_threat"),
    family_id = family_id,
    student_label = woodhen_or(
      normalized$config$label,
      paste0(normalized$row$label[[1]], " - ", intensity_label)
    ),
    scenario_type = "threat",
    parent_id = baseline$scenario_id,
    components = components,
    changes = changes,
    seed = seed,
    created_at = created_at,
    modified_at = modified_at,
    notes = normalized$config$notes,
    locked = locked
  )
  list(scenario = scenario, normalized = normalized)
}

woodhen_normalize_interventions <- function(interventions) {
  if (is.null(interventions) || length(interventions) == 0L) {
    return(list())
  }
  if (is.character(interventions)) {
    normalized <- lapply(interventions, function(id) list(intervention_id = id))
    names(normalized) <- interventions
    interventions <- normalized
  } else if (!is.list(interventions)) {
    stop("`interventions` must be a named list of independent alternatives.", call. = FALSE)
  }
  if (is.null(names(interventions)) || any(!nzchar(names(interventions)))) {
    if (length(interventions) == 1L && is.list(interventions[[1]])) {
      inferred <- woodhen_or(interventions[[1]]$intervention_id, interventions[[1]]$id)
      if (is.character(inferred) && length(inferred) == 1L && !is.na(inferred)) {
        names(interventions) <- inferred
      }
    }
  }
  if (is.null(names(interventions)) || anyNA(names(interventions)) ||
      any(!nzchar(names(interventions))) || anyDuplicated(names(interventions))) {
    stop("Every intervention alternative must have a unique, non-empty name.", call. = FALSE)
  }
  reserved <- c("baseline", "threat")
  if (any(tolower(names(interventions)) %in% reserved)) {
    stop("Intervention alternative names `baseline` and `threat` are reserved.", call. = FALSE)
  }
  valid_ids <- grepl("^[A-Za-z][A-Za-z0-9_-]*$", names(interventions))
  if (!all(valid_ids)) {
    stop(
      "Intervention alternative names must begin with a letter and contain only letters, numbers, `_`, or `-`.",
      call. = FALSE
    )
  }
  interventions
}

woodhen_normalize_intervention <- function(config, alternative_id, locked) {
  if (is.character(config) && length(config) == 1L && !is.na(config)) {
    config <- list(intervention_id = config)
  }
  if (!is.list(config)) {
    stop("Intervention alternative `", alternative_id, "` must be a configuration list.", call. = FALSE)
  }
  woodhen_validate_no_locked_controls(config)
  intervention_id <- woodhen_or(config$intervention_id, woodhen_or(config$id, alternative_id))
  row <- woodhen_catalog_match(woodhen_intervention_catalog(), intervention_id, "intervention")
  intensity <- woodhen_resolve_bounded_value(
    woodhen_or(config$intensity, "moderate"),
    row,
    label = "intervention intensity"
  )
  components <- woodhen_validate_named_components(config$components, "intervention components")
  temporal_profile <- if (identical(intervention_id, "captive_breeding_supplementation")) {
    onset <- validate_temporal_year_arg(woodhen_or(config$onset_year, 1L), "onset_year", locked$years)
    list(shape = "scheduled_pulses", onset_year = onset, end_year = onset + 2L)
  } else {
    woodhen_normalize_shape(config, row, locked$years)
  }
  list(
    config = config,
    row = row,
    intervention_id = intervention_id,
    intensity = intensity,
    temporal_profile = temporal_profile,
    components = components
  )
}

woodhen_threat_changes_for <- function(threat_scenario, fields) {
  threat_scenario$changes[vapply(threat_scenario$changes, function(change) {
    any(change$affected_fields %in% fields)
  }, logical(1))]
}

woodhen_apply_recovery_changes <- function(spec,
                                           locked,
                                           parent_changes,
                                           intervention_id,
                                           intensity,
                                           temporal_profile) {
  components <- list()
  changes <- list()
  for (parent_name in names(parent_changes)) {
    parent_change <- parent_changes[[parent_name]]
    component_id <- paste0(intervention_id, "__", parent_name)
    applied <- woodhen_apply_profile_component(
      spec = spec,
      locked = locked,
      component_id = component_id,
      field = parent_change$affected_fields[[1]],
      operator = "recover_toward_locked_baseline",
      value = intensity,
      stages = parent_change$affected_stages,
      temporal_profile = temporal_profile
    )
    spec <- applied$spec
    components[[component_id]] <- applied$component
    changes[[component_id]] <- applied$change
  }
  list(spec = spec, components = components, changes = changes)
}

woodhen_build_intervention_scenario <- function(config,
                                                alternative_id,
                                                threat_scenario,
                                                threat_id,
                                                locked,
                                                family_id,
                                                seed,
                                                created_at,
                                                modified_at) {
  normalized <- woodhen_normalize_intervention(config, alternative_id, locked)
  intervention_id <- normalized$intervention_id
  spec <- threat_scenario$spec
  components <- list()
  changes <- list()

  if (identical(intervention_id, "habitat_protection_restoration")) {
    parent_changes <- woodhen_threat_changes_for(threat_scenario, "K")
    if (length(parent_changes) == 0L) {
      stop("Habitat restoration requires a parent threat with a named K component.", call. = FALSE)
    }
    applied <- woodhen_apply_recovery_changes(
      spec, locked, parent_changes, intervention_id,
      normalized$intensity, normalized$temporal_profile
    )
    spec <- applied$spec
    components <- applied$components
    changes <- applied$changes
  } else if (identical(intervention_id, "biosecurity_eradication")) {
    if (!identical(threat_id, "predator_reinvasion")) {
      stop("Biosecurity or eradication requires a predator-reinvasion parent threat.", call. = FALSE)
    }
    parent_changes <- woodhen_threat_changes_for(threat_scenario, c("surv", "fecund"))
    applied <- woodhen_apply_recovery_changes(
      spec, locked, parent_changes, intervention_id,
      normalized$intensity, normalized$temporal_profile
    )
    spec <- applied$spec
    components <- applied$components
    changes <- applied$changes
  } else if (identical(intervention_id, "targeted_vital_rate_improvement")) {
    parent_changes <- woodhen_threat_changes_for(threat_scenario, c("surv", "fecund"))
    target_component <- normalized$config$target_component
    if (!is.null(target_component)) {
      if (!is.character(target_component) || length(target_component) != 1L ||
          is.na(target_component) || !nzchar(target_component)) {
        stop("`target_component` must uniquely match one named parent component.", call. = FALSE)
      }
      matches <- which(names(parent_changes) == target_component)
      if (length(matches) != 1L) {
        stop("`target_component` must uniquely match one named survival or fecundity parent component.", call. = FALSE)
      }
      parent_changes <- parent_changes[matches]
    } else if (length(parent_changes) > 1L) {
      stop(
        "`target_component` is required when multiple survival or fecundity parent components are eligible.",
        call. = FALSE
      )
    }
    if (length(parent_changes) == 0L) {
      stop("Targeted vital-rate improvement requires a named survival or fecundity parent component.", call. = FALSE)
    }
    applied <- woodhen_apply_recovery_changes(
      spec, locked, parent_changes, intervention_id,
      normalized$intensity, normalized$temporal_profile
    )
    spec <- applied$spec
    components <- applied$components
    changes <- applied$changes
  } else if (identical(intervention_id, "captive_breeding_supplementation")) {
    if (normalized$intensity != round(normalized$intensity)) {
      stop("Supplementation intensity must be a whole number of stage-2 female-equivalent breeding pairs.", call. = FALSE)
    }
    release_years <- normalized$temporal_profile$onset_year + 0:2
    if (tail(release_years, 1L) > locked$years) {
      stop("A three-year supplementation schedule must finish within `years`.", call. = FALSE)
    }
    release_vec <- integer(length(locked$surv))
    release_vec[[2]] <- as.integer(normalized$intensity)
    before <- list(release_years = spec$release_years, release_vec = spec$release_vec)
    spec$release_years <- as.integer(release_years)
    spec$release_vec <- release_vec
    component_id <- "three_year_stage_2_release"
    components[[component_id]] <- list(
      component_id = component_id,
      affected_fields = c("release_years", "release_vec"),
      affected_stages = 2L,
      operator = "annual_release_schedule",
      value = as.integer(normalized$intensity),
      temporal_profile = normalized$temporal_profile
    )
    changes[[component_id]] <- list(
      component_id = component_id,
      affected_fields = c("release_years", "release_vec"),
      affected_stages = 2L,
      operator = "annual_release_schedule",
      before = before,
      after = list(release_years = spec$release_years, release_vec = spec$release_vec),
      temporal_profile = normalized$temporal_profile
    )
  } else if (identical(intervention_id, "emergency_response")) {
    if (!identical(threat_id, "increased_cyclone_pressure")) {
      stop("Emergency response requires an increased-cyclone-pressure parent threat.", call. = FALSE)
    }
    component_id <- "catastrophe_survival_recovery"
    applied <- woodhen_apply_profile_component(
      spec = spec,
      locked = locked,
      component_id = component_id,
      field = "cat_surv",
      operator = "recover_toward_one",
      value = normalized$intensity,
      stages = "not_applicable",
      temporal_profile = normalized$temporal_profile
    )
    spec <- applied$spec
    components[[component_id]] <- applied$component
    changes[[component_id]] <- applied$change
  }

  if (length(normalized$components)) {
    advanced <- woodhen_apply_advanced_components(
      spec = spec,
      locked = locked,
      components = normalized$components,
      default_temporal_profile = normalized$temporal_profile
    )
    spec <- advanced$spec
    components <- c(components, advanced$components)
    changes <- c(changes, advanced$changes)
  }

  inherited_components <- threat_scenario$components
  names(inherited_components) <- paste0("threat__", names(inherited_components))
  inherited_changes <- threat_scenario$changes
  names(inherited_changes) <- paste0("threat__", names(inherited_changes))
  record_components <- c(inherited_components, components)
  record_changes <- c(inherited_changes, changes)

  woodhen_new_record(
    spec = spec,
    scenario_id = paste0(family_id, "_", alternative_id),
    family_id = family_id,
    student_label = woodhen_or(normalized$config$label, normalized$row$label[[1]]),
    scenario_type = "intervention",
    parent_id = threat_scenario$scenario_id,
    components = record_components,
    changes = record_changes,
    seed = seed,
    created_at = created_at,
    modified_at = modified_at,
    notes = normalized$config$notes,
    locked = locked
  )
}

#' Build a Woodhen baseline-threat-intervention family
#'
#' @param threat Threat ID or named configuration.
#' @param interventions Named list of independent intervention alternatives.
#' @param seed Common integer comparison seed.
#' @param created_at Optional caller-supplied creation timestamp.
#' @param modified_at Optional caller-supplied modification timestamp.
#' @return A `woodhen_investigation_family` of validated scenario records.
#' @export
build_woodhen_prospective_family <- function(threat,
                                             interventions = list(),
                                             seed = 123L,
                                             created_at = NULL,
                                             modified_at = created_at) {
  seed <- woodhen_validate_seed(seed)
  created_at <- woodhen_normalize_record_time(created_at, "created_at")
  modified_at <- woodhen_normalize_record_time(modified_at, "modified_at")
  locked <- woodhen_locked_future_spec()
  normalized_threat <- woodhen_normalize_threat(threat, locked)
  threat_id <- normalized_threat$threat_id
  family_id <- paste0("prospective_", threat_id)

  baseline <- woodhen_new_record(
    spec = locked,
    scenario_id = paste0(family_id, "_baseline"),
    family_id = family_id,
    student_label = "Locked future baseline",
    scenario_type = "locked_baseline",
    parent_id = NA_character_,
    components = list(),
    changes = list(),
    seed = seed,
    created_at = created_at,
    modified_at = modified_at,
    locked = locked
  )
  built_threat <- woodhen_build_threat_scenario(
    threat = threat,
    locked = locked,
    family_id = family_id,
    baseline = baseline,
    seed = seed,
    created_at = created_at,
    modified_at = modified_at
  )
  intervention_configs <- woodhen_normalize_interventions(interventions)
  managed <- lapply(names(intervention_configs), function(alternative_id) {
    woodhen_build_intervention_scenario(
      config = intervention_configs[[alternative_id]],
      alternative_id = alternative_id,
      threat_scenario = built_threat$scenario,
      threat_id = threat_id,
      locked = locked,
      family_id = family_id,
      seed = seed,
      created_at = created_at,
      modified_at = modified_at
    )
  })
  names(managed) <- names(intervention_configs)
  scenarios <- c(list(baseline, built_threat$scenario), managed)
  identity <- woodhen_finalize_family_identity(
    family_type = "prospective",
    scientific_key = threat_id,
    scenarios = scenarios,
    scenario_keys = names(intervention_configs)
  )

  woodhen_new_family(
    family_id = identity$family_id,
    family_type = "prospective",
    scenarios = identity$scenarios,
    seed = seed,
    threat_id = threat_id,
    intervention_ids = names(intervention_configs),
    locked_baseline_id = identity$scenarios[[1L]]$scenario_id,
    composition_order = c(
      "locked_baseline", "threat_components",
      "intervention_recovery_components", "intervention_direct_components",
      "full_validation"
    )
  )
}
