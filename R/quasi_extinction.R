quasi_extinction_trajectory_array <- function(result) {
  traj <- result$traj
  if (is.null(traj) && is.list(result$raw)) {
    traj <- result$raw$traj
  }

  if (is.null(traj)) {
    stop(
      "Quasi-extinction evidence requires trajectories; rerun with keep_traj = TRUE.",
      call. = FALSE
    )
  }
  if (length(dim(traj)) != 3L) {
    stop("Quasi-extinction evidence requires a three-dimensional trajectory array.", call. = FALSE)
  }
  if (!is.numeric(traj) || any(!is.finite(traj)) || any(traj < 0)) {
    stop("Trajectory counts must be finite, non-negative numbers.", call. = FALSE)
  }

  traj
}

normalize_holder_stages <- function(holder_stages, n_stages) {
  if (is.null(holder_stages)) {
    if (n_stages < 2L) {
      stop("Breeding-pair evidence requires at least two model stages.", call. = FALSE)
    }
    return(seq.int(2L, n_stages))
  }

  valid <- is.numeric(holder_stages) && length(holder_stages) > 0L &&
    all(is.finite(holder_stages)) &&
    all(holder_stages == as.integer(holder_stages))
  if (!valid) {
    stop("`holder_stages` must contain whole-number stage indices.", call. = FALSE)
  }

  holder_stages <- as.integer(holder_stages)
  if (any(holder_stages == 1L)) {
    stop("Model stage 1 contains floaters and cannot be counted as breeding pairs.", call. = FALSE)
  }
  if (any(holder_stages < 2L) || any(holder_stages > n_stages)) {
    stop("`holder_stages` contains an index outside the trajectory array.", call. = FALSE)
  }

  unique(holder_stages)
}

#' Extract territory-holding breeding-pair trajectories
#'
#' Stage 1 contains non-territorial floaters. By default, stages 2 onward are
#' summed as territory-holding breeding pairs for every year and replicate.
#'
#' @param result A result from `run_pva_core(..., keep_traj = TRUE)`.
#' @param holder_stages Optional whole-number indices for holder stages. Stage 1
#'   is never eligible because it contains floaters.
#' @return A year-by-replicate matrix of breeding-pair counts.
#' @export
breeding_pair_trajectories <- function(result, holder_stages = NULL) {
  traj <- quasi_extinction_trajectory_array(result)
  holder_stages <- normalize_holder_stages(holder_stages, dim(traj)[[2L]])
  pairs <- apply(traj[, holder_stages, , drop = FALSE], c(1L, 3L), sum)

  matrix(pairs, nrow = dim(traj)[[1L]], ncol = dim(traj)[[3L]])
}

validate_pair_threshold <- function(threshold_pairs) {
  valid <- is.numeric(threshold_pairs) && length(threshold_pairs) == 1L &&
    is.finite(threshold_pairs) && threshold_pairs > 0 &&
    threshold_pairs == as.integer(threshold_pairs)
  if (!valid) {
    stop("`threshold_pairs` must be a single positive whole number.", call. = FALSE)
  }

  as.integer(threshold_pairs)
}

woodhen_warning_threshold_pairs <- function() {
  100L
}

#' Summarise risk of falling below a breeding-pair threshold
#'
#' @param result A result from `run_pva_core(..., keep_traj = TRUE)`.
#' @param threshold_pairs Positive whole-number breeding-pair threshold. A
#'   crossing is strictly fewer than this value.
#' @param holder_stages Optional whole-number indices for holder stages.
#' @return A list containing first-passage and cumulative-risk evidence.
#' @export
summarize_quasi_extinction <- function(result,
                                       threshold_pairs = 50L,
                                       holder_stages = NULL) {
  threshold_pairs <- validate_pair_threshold(threshold_pairs)
  traj <- quasi_extinction_trajectory_array(result)
  holder_stages <- normalize_holder_stages(holder_stages, dim(traj)[[2L]])
  pairs <- breeding_pair_trajectories(result, holder_stages = holder_stages)
  crossed <- pairs < threshold_pairs

  first_crossing_year <- vapply(seq_len(ncol(crossed)), function(rep_index) {
    crossing_rows <- which(crossed[, rep_index])
    if (length(crossing_rows) == 0L) {
      return(NA_integer_)
    }
    as.integer(crossing_rows[[1L]] - 1L)
  }, integer(1))

  cumulative_crossing <- crossed
  for (rep_index in seq_len(ncol(crossed))) {
    cumulative_crossing[, rep_index] <- cummax(crossed[, rep_index])
  }
  cumulative <- data.frame(
    year = seq_len(nrow(pairs)) - 1L,
    probability = rowMeans(cumulative_crossing)
  )

  crossing_years <- first_crossing_year[!is.na(first_crossing_year)]
  conditional_median_year <- if (length(crossing_years) > 0L) {
    as.numeric(stats::median(crossing_years))
  } else {
    NA_real_
  }
  probability_by_horizon <- tail(cumulative$probability, 1L)
  overall_median_year <- if (probability_by_horizon >= 0.5) {
    as.numeric(cumulative$year[which(cumulative$probability >= 0.5)[[1L]]])
  } else {
    NA_real_
  }

  list(
    threshold_pairs = threshold_pairs,
    holder_stages = holder_stages,
    total_reps = as.integer(ncol(pairs)),
    crossed_reps = as.integer(length(crossing_years)),
    probability_by_horizon = as.numeric(probability_by_horizon),
    first_crossing_year = first_crossing_year,
    cumulative = cumulative,
    conditional_median_year = conditional_median_year,
    overall_median_year = overall_median_year,
    breeding_pair_trajectories = pairs,
    minimum_breeding_pairs = apply(pairs, 2L, min)
  )
}
