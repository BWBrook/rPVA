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
