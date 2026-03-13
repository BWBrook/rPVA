allowed_pva_spec_fields <- function() {
  c(
    "name",
    "years",
    "reps",
    "surv",
    "stasis",
    "fecund",
    "n0",
    "env_sd",
    "demographic_stochasticity",
    "sex_ratio_init",
    "monogamy",
    "K",
    "K_sd",
    "cat_freq",
    "cat_surv",
    "cat_repro",
    "genetics",
    "F_init",
    "lethal_equiv",
    "B_on_fec",
    "Ne_N_ratio",
    "Ne_window",
    "purge_kappa",
    "removal_years",
    "removal_vec",
    "release_years",
    "release_vec"
  )
}

deprecated_pva_spec_message <- function() {
  paste0(
    "Field `demo_sd` has been renamed to `demographic_stochasticity`. ",
    "Update the spec key and pass a boolean value."
  )
}

flatten_yaml_sequence <- function(value) {
  if (is.list(value)) {
    return(unlist(value, recursive = TRUE, use.names = FALSE))
  }

  value
}

is_integerish_vector <- function(x) {
  is.numeric(x) && all(is.finite(x)) && all(abs(x - round(x)) < sqrt(.Machine$double.eps))
}

validate_scalar_character <- function(value, field) {
  if (!is.character(value) || length(value) != 1) {
    stop("`", field, "` must be a character scalar.", call. = FALSE)
  }

  value
}

validate_scalar_logical <- function(value, field) {
  if (!is.logical(value) || length(value) != 1 || is.na(value)) {
    stop("`", field, "` must be TRUE or FALSE.", call. = FALSE)
  }

  value
}

validate_scalar_numeric <- function(value, field, allow_null = FALSE) {
  if (allow_null && is.null(value)) {
    return(NULL)
  }

  value <- flatten_yaml_sequence(value)
  if (allow_null && is.numeric(value) && length(value) == 1 && is.na(value)) {
    return(as.numeric(value))
  }

  if (!is.numeric(value) || length(value) != 1 || is.na(value)) {
    stop("`", field, "` must be a numeric scalar.", call. = FALSE)
  }

  as.numeric(value)
}

validate_scalar_integerish <- function(value, field) {
  value <- flatten_yaml_sequence(value)
  if (!is_integerish_vector(value) || length(value) != 1) {
    stop("`", field, "` must be an integer-valued scalar.", call. = FALSE)
  }

  as.integer(round(value))
}

validate_numeric_vector <- function(value, field, integerish = FALSE) {
  value <- flatten_yaml_sequence(value)
  if (!is.numeric(value) || length(value) == 0 || any(is.na(value))) {
    stop("`", field, "` must be a numeric sequence.", call. = FALSE)
  }

  if (integerish) {
    if (!is_integerish_vector(value)) {
      stop("`", field, "` must be an integer-valued sequence.", call. = FALSE)
    }
    return(as.integer(round(value)))
  }

  as.numeric(value)
}

normalize_pva_spec_field <- function(field, value) {
  if (identical(field, "name")) {
    return(validate_scalar_character(value, field))
  }

  if (field %in% c("years", "reps", "Ne_window")) {
    return(validate_scalar_integerish(value, field))
  }

  if (field %in% c("demographic_stochasticity", "monogamy", "genetics")) {
    return(validate_scalar_logical(value, field))
  }

  if (field %in% c("sex_ratio_init", "env_sd", "K", "K_sd", "cat_freq", "cat_surv",
                   "cat_repro", "F_init", "B_on_fec", "Ne_N_ratio", "purge_kappa")) {
    return(validate_scalar_numeric(value, field, allow_null = field == "K"))
  }

  if (field %in% c("surv", "stasis", "fecund", "n0", "lethal_equiv")) {
    return(validate_numeric_vector(value, field))
  }

  if (field %in% c("removal_years", "release_years", "removal_vec", "release_vec")) {
    return(validate_numeric_vector(value, field, integerish = TRUE))
  }

  stop("Unhandled spec field `", field, "`.", call. = FALSE)
}

validate_pva_spec_keys <- function(spec) {
  fields <- names(spec)

  if ("demo_sd" %in% fields) {
    stop(deprecated_pva_spec_message(), call. = FALSE)
  }

  unknown <- setdiff(fields, allowed_pva_spec_fields())
  if (length(unknown) > 0) {
    if ("max_age" %in% unknown) {
      stop(
        "`max_age` is not a live spec field. Retain it only as a commented placeholder if needed.",
        call. = FALSE
      )
    }
    stop("Unknown spec field(s): ", paste(sort(unknown), collapse = ", "), call. = FALSE)
  }
}

normalize_pva_spec_fields <- function(spec) {
  validate_pva_spec_keys(spec)

  out <- spec
  for (field in names(spec)) {
    out[[field]] <- normalize_pva_spec_field(field, spec[[field]])
  }

  out
}

validate_probability_vector <- function(x, field) {
  if (any(x < 0 | x > 1)) {
    stop("`", field, "` values must lie in [0, 1].", call. = FALSE)
  }
}

validate_nonnegative_vector <- function(x, field) {
  if (any(x < 0)) {
    stop("`", field, "` values must be non-negative.", call. = FALSE)
  }
}

validate_stage_length <- function(x, field, n_stage) {
  if (length(x) != n_stage) {
    stop("`", field, "` must have length ", n_stage, ".", call. = FALSE)
  }
}

validate_year_index_vector <- function(x, field) {
  if (any(x < 1)) {
    stop("`", field, "` values must be positive integers.", call. = FALSE)
  }
}

validate_full_pva_spec <- function(spec) {
  required <- c("surv", "fecund", "n0", "env_sd", "demographic_stochasticity", "years", "reps")
  missing <- setdiff(required, names(spec))
  if (length(missing) > 0) {
    stop("spec must include: ", paste(required, collapse = ", "), call. = FALSE)
  }

  n_stage <- length(spec$surv)
  validate_stage_length(spec$fecund, "fecund", n_stage)
  validate_stage_length(spec$n0, "n0", n_stage)
  validate_probability_vector(spec$surv, "surv")
  validate_nonnegative_vector(spec$fecund, "fecund")
  validate_nonnegative_vector(spec$n0, "n0")

  if (!is.null(spec$stasis)) {
    validate_stage_length(spec$stasis, "stasis", n_stage)
    validate_probability_vector(spec$stasis, "stasis")
  }

  if (!is.null(spec$lethal_equiv)) {
    validate_stage_length(spec$lethal_equiv, "lethal_equiv", n_stage)
    validate_nonnegative_vector(spec$lethal_equiv, "lethal_equiv")
  }

  if (!is.null(spec$removal_vec)) {
    validate_stage_length(spec$removal_vec, "removal_vec", n_stage)
    validate_nonnegative_vector(spec$removal_vec, "removal_vec")
  }

  if (!is.null(spec$release_vec)) {
    validate_stage_length(spec$release_vec, "release_vec", n_stage)
    validate_nonnegative_vector(spec$release_vec, "release_vec")
  }

  if (!is.null(spec$sex_ratio_init) && (spec$sex_ratio_init < 0 || spec$sex_ratio_init > 1)) {
    stop("`sex_ratio_init` must lie in [0, 1].", call. = FALSE)
  }
  if (!is.null(spec$K_sd) && spec$K_sd < 0) {
    stop("`K_sd` must be non-negative.", call. = FALSE)
  }
  if (!is.null(spec$cat_freq) && (spec$cat_freq < 0 || spec$cat_freq > 1)) {
    stop("`cat_freq` must lie in [0, 1].", call. = FALSE)
  }
  if (!is.null(spec$cat_surv) && (spec$cat_surv < 0 || spec$cat_surv > 1)) {
    stop("`cat_surv` must lie in [0, 1].", call. = FALSE)
  }
  if (!is.null(spec$cat_repro) && spec$cat_repro < 0) {
    stop("`cat_repro` must be non-negative.", call. = FALSE)
  }
  if (!is.null(spec$F_init) && (spec$F_init < 0 || spec$F_init > 1)) {
    stop("`F_init` must lie in [0, 1].", call. = FALSE)
  }
  if (!is.null(spec$B_on_fec) && spec$B_on_fec < 0) {
    stop("`B_on_fec` must be non-negative.", call. = FALSE)
  }
  if (!is.null(spec$Ne_N_ratio) && spec$Ne_N_ratio <= 0) {
    stop("`Ne_N_ratio` must be positive.", call. = FALSE)
  }
  if (!is.null(spec$purge_kappa) && spec$purge_kappa < 0) {
    stop("`purge_kappa` must be non-negative.", call. = FALSE)
  }
  if (!is.null(spec$removal_years)) {
    validate_year_index_vector(spec$removal_years, "removal_years")
  }
  if (!is.null(spec$release_years)) {
    validate_year_index_vector(spec$release_years, "release_years")
  }

  spec
}
