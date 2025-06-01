#' Internal: melt trajectory array to long tibble
#' @keywords internal
traj_to_long <- function(traj) {
  if (is.null(traj)) stop("Trajectories not stored (keep_traj = FALSE)")
  df <- reshape2::melt(traj, varnames = c("Year", "stage", "Rep"), value.name = "N")
  df$Year <- as.numeric(as.character(df$Year))
  df$Rep  <- as.integer(as.character(df$Rep))
  df
}

#' Plot all Monte-Carlo trajectories
#' @param out list returned by run_pva_core(…, keep_traj = TRUE)
#' @param alpha line transparency
#' @export
plot_pva_traj <- function(out, alpha = 0.3) {
  df <- traj_to_long(out$traj) |>
        dplyr::group_by(Year, Rep) |>
        dplyr::summarise(N = sum(N), .groups = "drop")

  ggplot2::ggplot(df, ggplot2::aes(Year, N, group = Rep)) +
    ggplot2::geom_line(alpha = alpha) +
    ggplot2::labs(title = "Population trajectories",
                  y = "Total N") +
    ggplot2::theme_minimal()
}

#' Plot mean ± SE ± 95 % envelope
#' @param probs two-element numeric: lower & upper quantiles (default 2.5 % & 97.5 %)
#' @export
plot_pva_summary <- function(out, probs = c(0.025, 0.975)) {
  df <- traj_to_long(out$traj)
  # Sum across stages per Year and Rep
  df_tot <- df |>
    dplyr::group_by(Year, Rep) |>
    dplyr::summarise(N = sum(N), .groups = "drop")
  # Now summarise across reps for each year
  df_sum <- df_tot |>
    dplyr::group_by(Year) |>
    dplyr::summarise(
      Mean = mean(N),
      SE   = stats::sd(N) / sqrt(dplyr::n()),
      Lo95 = stats::quantile(N, probs[1]),
      Hi95 = stats::quantile(N, probs[2]),
      .groups = "drop"
    )
  ggplot2::ggplot(df_sum, ggplot2::aes(Year, Mean)) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = Lo95, ymax = Hi95),
                         fill = "grey80", alpha = 0.7) +
    ggplot2::geom_line(linewidth = 1.2) +
    ggplot2::geom_line(ggplot2::aes(y = Mean + SE),
                       linetype = "dashed", colour = "blue") +
    ggplot2::geom_line(ggplot2::aes(y = Mean - SE),
                       linetype = "dashed", colour = "blue") +
    ggplot2::labs(title = "Population: mean, SE, and 95% envelope",
                  y = "Total N") +
    ggplot2::theme_minimal()
}

#' Plot matrix diagnostics (2 × 2 panel; lambda and SSD printed to console)
#' @param spec List with surv, fecund, stasis
#' @export
plot_pva_matrix <- function(spec) {
  A <- make_projection_matrix(
    surv_prog = spec$surv[-length(spec$surv)],
    fecund    = spec$fecund,
    stasis    = if (!is.null(spec$stasis)) spec$stasis else rep(0, length(spec$surv))
  )
  ea  <- popbio::eigen.analysis(A)

  # Print lambda and stable stage dist to console
  cat(sprintf("\nlambda (λ): %.4f\n\n", ea$lambda1))
  cat("Stable stage distribution (SSD/SAD):\n")
  print(round(ea$stable.stage, 4))

  # Set n0 to nearest-integer SSD (with drift correction)
  N0_total <- sum(spec$n0)
  n0_ssd <- round(ea$stable.stage * N0_total)
  # Correction for rounding drift
  diff <- N0_total - sum(n0_ssd)
  if (diff != 0) {
    idx <- which.max(n0_ssd)
    n0_ssd[idx] <- n0_ssd[idx] + diff
  }
  cat("\nInitial stage vector for SAD (rounded to sum = ", N0_total, "):\n", sep = "")
  print(n0_ssd)

  # Projection matrix (heatmap with numbers)
  df_A <- reshape2::melt(A, varnames = c("to", "from"), value.name = "A")
  df_A$to <- factor(df_A$to, levels = rev(levels(df_A$to)))  # flip y axis
  p_A <- ggplot2::ggplot(df_A, ggplot2::aes(x = from, y = to, fill = A)) +
    ggplot2::geom_tile() +
    ggplot2::geom_text(ggplot2::aes(label = round(A, 2)), size = 3) +
    ggplot2::scale_fill_viridis_c(option = "D") +
    ggplot2::labs(title = "Projection matrix A") +
    ggplot2::theme_minimal() +
    ggplot2::theme(axis.title = ggplot2::element_blank())

  # SSD barplot (for ggplot panel)
  df_ssd <- data.frame(stage = factor(names(ea$stable.stage), levels = names(ea$stable.stage)),
                      prop = ea$stable.stage)
  p_ssd <- ggplot2::ggplot(df_ssd, ggplot2::aes(stage, prop)) +
    ggplot2::geom_col(fill = "steelblue") +
    ggplot2::labs(title = "Stable stage distribution (SSD/SAD)", y = "Proportion") +
    ggplot2::theme_minimal()

  # RV barplot (for ggplot panel)
  df_rv <- data.frame(stage = factor(names(ea$repro.value), levels = names(ea$repro.value)),
                      value = ea$repro.value)
  p_rv <- ggplot2::ggplot(df_rv, ggplot2::aes(stage, value)) +
    ggplot2::geom_col(fill = "darkorange") +
    ggplot2::labs(title = "Reproductive value", y = "Relative value") +
    ggplot2::theme_minimal()

  # Elasticity matrix
  elas_plot <- t(ea$elasticities)
  df_el <- reshape2::melt(elas_plot, varnames = c("to", "from"), value.name = "elas")
  df_el$from <- factor(df_el$from, levels = rev(unique(df_el$from)))
  p_el <- ggplot2::ggplot(df_el, ggplot2::aes(x = to, y = from, fill = elas)) +
    ggplot2::geom_tile() +
    ggplot2::scale_fill_viridis_c(option = "C") +
    ggplot2::labs(title = "Elasticity matrix") +
    ggplot2::theme_minimal() +
    ggplot2::theme(axis.title = ggplot2::element_blank())

  # Compose and print 2x2 grid
  if (requireNamespace("patchwork", quietly = TRUE)) {
    p <- patchwork::wrap_plots(p_A, p_ssd, p_rv, p_el, ncol = 2)
    print(p)
  } else {
    print(p_A); print(p_ssd); print(p_rv); print(p_el)
  }
  invisible(p)
}
