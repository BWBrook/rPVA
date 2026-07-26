validate_temporal_year_arg <- function(value, field, upper = NULL) {
  valid <- is.numeric(value) &&
    length(value) == 1 &&
    is.finite(value) &&
    abs(value - round(value)) < sqrt(.Machine$double.eps) &&
    value >= 1

  if (!valid) {
    stop("`", field, "` must be a positive integer scalar.", call. = FALSE)
  }

  value <- as.integer(round(value))
  if (!is.null(upper) && value > upper) {
    stop("`", field, "` must lie between 1 and `years`.", call. = FALSE)
  }

  value
}

validate_temporal_endpoint <- function(value, field) {
  if (!is.numeric(value) || length(value) == 0 || !is.null(dim(value))) {
    stop("`", field, "` must be a non-empty numeric vector.", call. = FALSE)
  }
  if (any(!is.finite(value))) {
    stop("`", field, "` values must be finite.", call. = FALSE)
  }

  as.numeric(value)
}

build_temporal_profile <- function(
    baseline,
    target,
    years,
    onset_year = 1L,
    end_year = years,
    shape = c("step", "linear")
) {
  years <- validate_temporal_year_arg(years, "years")
  onset_year <- validate_temporal_year_arg(onset_year, "onset_year", years)
  end_year <- validate_temporal_year_arg(end_year, "end_year", years)
  if (end_year < onset_year) {
    stop("`end_year` must not precede `onset_year`.", call. = FALSE)
  }

  shape <- match.arg(shape)
  baseline <- validate_temporal_endpoint(baseline, "baseline")
  target <- validate_temporal_endpoint(target, "target")
  if (length(baseline) != length(target)) {
    stop("`baseline` and `target` must have the same length.", call. = FALSE)
  }

  weights <- numeric(years)
  if (identical(shape, "step") || onset_year == end_year) {
    weights[onset_year:years] <- 1
  } else {
    transition_years <- onset_year:end_year
    weights[transition_years] <- seq(0, 1, length.out = length(transition_years))
    if (end_year < years) {
      weights[(end_year + 1L):years] <- 1
    }
  }

  baseline_matrix <- matrix(rep(baseline, each = years), nrow = years)
  profile <- baseline_matrix + tcrossprod(weights, target - baseline)
  if (length(baseline) == 1) {
    return(as.numeric(profile[, 1]))
  }

  profile
}

validate_annual_profiles <- function(profiles, years, n_stage) {
  if (is.null(profiles)) {
    return(NULL)
  }
  if (!is.list(profiles)) {
    stop("`annual_profiles` must be a named list.", call. = FALSE)
  }
  if (length(profiles) == 0) {
    return(profiles)
  }
  if (is.null(names(profiles)) || any(!nzchar(names(profiles))) || anyDuplicated(names(profiles))) {
    stop("`annual_profiles` must have unique, non-empty field names.", call. = FALSE)
  }

  years <- validate_temporal_year_arg(years, "years")
  n_stage <- validate_temporal_year_arg(n_stage, "n_stage")
  scalar_fields <- c("K", "K_sd", "env_sd", "cat_freq", "cat_surv", "cat_repro")
  stage_fields <- c("surv", "fecund")
  unsupported <- setdiff(names(profiles), c(scalar_fields, stage_fields))
  if (length(unsupported) > 0) {
    stop(
      "Unsupported annual profile field(s): ",
      paste(sort(unsupported), collapse = ", "),
      ".",
      call. = FALSE
    )
  }

  for (field in names(profiles)) {
    value <- profiles[[field]]
    label <- paste0("annual_profiles$", field)

    if (field %in% scalar_fields) {
      if (!is.numeric(value) || !is.null(dim(value)) || length(value) != years) {
        stop("`", label, "` must be a numeric vector of length ", years, ".", call. = FALSE)
      }
    } else if (!is.matrix(value) || !is.numeric(value) || !identical(dim(value), c(years, n_stage))) {
      stop(
        "`", label, "` must be a numeric matrix with ", years,
        " rows and ", n_stage, " columns.",
        call. = FALSE
      )
    }

    if (any(!is.finite(value))) {
      stop("`", label, "` values must be finite.", call. = FALSE)
    }

    if (field %in% c("cat_freq", "cat_surv", "cat_repro", "surv")) {
      validate_probability_vector(value, label)
    } else if (field %in% c("K", "K_sd", "env_sd", "fecund")) {
      validate_nonnegative_vector(value, label)
    }
  }

  profiles
}
