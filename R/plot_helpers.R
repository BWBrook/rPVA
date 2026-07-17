extract_traj <- function(out) {
  if (!is.null(out$traj)) {
    return(out$traj)
  }

  out$raw$traj
}

traj_to_total_df <- function(traj) {
  traj_to_long(traj) |>
    dplyr::group_by(Year, Rep) |>
    dplyr::summarise(N = sum(N), .groups = "drop")
}

build_summary_plot_data <- function(out, probs) {
  df_tot <- traj_to_total_df(extract_traj(out))
  df_uncond <- df_tot |>
    dplyr::group_by(Year) |>
    dplyr::summarise(
      Mean = mean(N),
      SE = sd(N) / sqrt(dplyr::n()),
      Lo95 = quantile(N, probs[1]),
      Hi95 = quantile(N, probs[2]),
      .groups = "drop"
    )

  df_cond <- dplyr::tibble(
    Year = df_uncond$Year,
    Mean_cond = rowSums(out$traj_mean)
  )

  list(
    unconditional = df_uncond,
    conditional = dplyr::left_join(
      dplyr::select(df_uncond, Year, Mean),
      df_cond,
      by = "Year"
    )
  )
}

build_extinction_plot_data <- function(out) {
  data.frame(
    Year = seq_along(out$ext_prob) - 1L,
    ext_prob = out$ext_prob,
    F_mean = out$F_mean,
    sr_mean = out$sr_mean
  )
}

total_population_trajectories <- function(out) {
  traj <- extract_traj(out)
  if (is.null(traj) || length(dim(traj)) != 3L) {
    stop("Risk plots require a three-dimensional trajectory array.", call. = FALSE)
  }

  totals <- apply(traj, c(1, 3), sum)
  matrix(
    totals,
    nrow = dim(traj)[[1]],
    ncol = dim(traj)[[3]]
  )
}

build_extinction_timing_data <- function(out) {
  totals <- total_population_trajectories(out)
  first_extinction_year <- apply(totals, 2, function(trajectory) {
    extinct <- which(trajectory == 0)
    if (length(extinct)) extinct[[1]] - 1L else NA_integer_
  })
  first_extinction_year <- as.integer(first_extinction_year)
  probability <- rowMeans(totals == 0)

  list(
    cumulative = data.frame(
      Year = seq_len(nrow(totals)) - 1L,
      Probability = probability
    ),
    first_extinction_year = first_extinction_year,
    extinct_reps = as.integer(sum(!is.na(first_extinction_year))),
    total_reps = as.integer(ncol(totals)),
    median_extinction_year = median_extinction_time(probability)
  )
}

build_quasi_extinction_plot_data <- function(out, K, max_fraction = 0.5) {
  if (!is.numeric(K) || length(K) != 1L || !is.finite(K) || K <= 0) {
    stop("`K` must be a finite positive number.", call. = FALSE)
  }
  if (!is.numeric(max_fraction) || length(max_fraction) != 1L ||
      !is.finite(max_fraction) || max_fraction <= 0 || max_fraction > 1) {
    stop("`max_fraction` must be in (0, 1].", call. = FALSE)
  }

  totals <- total_population_trajectories(out)
  minimum_abundance <- apply(totals, 2, min)
  thresholds <- seq.int(0L, as.integer(floor(K * max_fraction)))

  data.frame(
    Threshold = thresholds,
    Probability = vapply(
      thresholds,
      function(threshold) mean(minimum_abundance <= threshold),
      numeric(1)
    )
  )
}

median_extinction_time <- function(ext_prob) {
  if (length(ext_prob) == 0 || all(is.na(ext_prob))) {
    return(NA_real_)
  }

  years <- seq_along(ext_prob) - 1L
  if (any(ext_prob == 0.5, na.rm = TRUE)) {
    return(years[which(ext_prob == 0.5)[1]])
  }

  i2 <- which(ext_prob > 0.5)[1]
  if (is.na(i2)) {
    return(NA_real_)
  }
  if (i2 == 1) {
    return(years[1])
  }

  i1 <- i2 - 1L
  years[i1] + (0.5 - ext_prob[i1]) / (ext_prob[i2] - ext_prob[i1]) * (years[i2] - years[i1])
}
