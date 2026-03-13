#' Internal: melt trajectory array to long tibble
#' @keywords internal
traj_to_long <- function(traj) {
  if (is.null(traj)) stop("Trajectories not stored (keep_traj = FALSE)")
  df <- reshape2::melt(traj, varnames = c("Year", "stage", "Rep"), value.name = "N")
  df$Year <- as.numeric(as.character(df$Year))
  df$Rep  <- as.integer(as.character(df$Rep))
  df
}

#' Plot all (or sampled) Monte-Carlo trajectories
#'
#' @param out     list from `run_pva_core(..., keep_traj = TRUE)`
#' @param alpha   transparency for the lines
#' @param sample  integer; if > 0, randomly sample this many replicates
#'                before plotting. 0 ⇒ plot all replicates (default = 0).
#' @param raster  logical; if TRUE use ggrastr::geom_line_rast() which
#'                rasterises the polylines for speed.
#' @export
plot_pva_traj <- function(out,
                          alpha  = 0.3,
                          sample = 0,
                          raster = FALSE,
                          dpi    = 96) {

  # reshape --------------------------------------------------------------
  df <- traj_to_total_df(extract_traj(out))

  # optional subsample ---------------------------------------------------
  if (sample > 0) {
    reps_all <- unique(df$Rep)
    keep     <- sample(reps_all, min(sample, length(reps_all)))
    df       <- dplyr::filter(df, Rep %in% keep)
  }

  # build base plot ------------------------------------------------------
  p <- ggplot2::ggplot(df, ggplot2::aes(Year, N, group = Rep)) +
       ggplot2::geom_line(alpha = alpha) +
       ggplot2::labs(title = "Population trajectories",
                     y = "Total N") +
       ggplot2::theme_minimal()

  # optionally rasterise the line layer ---------------------------------
  if (raster) {
    if (!requireNamespace("ggrastr", quietly = TRUE))
      stop("Install the ggrastr package or set raster = FALSE")

    # rasterise *only* the geom_line layer (class 'GeomLine')
    p <- ggrastr::rasterize(p,
                            layers = "GeomLine",
                            dpi    = dpi)
  }

  print(p)
  invisible(p)
}

#' Plot PVA summary: ribbon (95 %), unconditional mean ± SE, and conditional mean
#' @param out   list returned by `run_pva_core(…, keep_traj = TRUE)`
#' @param probs two-element numeric: lower & upper quantiles for the ribbon
#' @export
plot_pva_summary <- function(out, probs = c(0.025, 0.975)) {
  plot_data <- build_summary_plot_data(out, probs)
  df_uncond <- plot_data$unconditional
  df_plot <- plot_data$conditional

  p <- ggplot2::ggplot(df_uncond, ggplot2::aes(x = Year)) +
    ## 95 % envelope
    ggplot2::geom_ribbon(
      ggplot2::aes(ymin = Lo95, ymax = Hi95),
      fill = "grey80", alpha = 0.7, show.legend = FALSE
    ) +
    ## unconditional mean ± SE (blue dashed)
    ggplot2::geom_line(
      data = df_plot,
      ggplot2::aes(y = Mean,
                   linetype = "Unconditional",
                   colour   = "Unconditional"),
      linewidth = 1
    ) +
    ## conditional mean (solid green)
    ggplot2::geom_line(
      data = df_plot,
      ggplot2::aes(y = Mean_cond,
                   linetype = "Conditional",
                   colour   = "Conditional"),
      linewidth = 1
    ) +
    ## manual legend
    ggplot2::scale_colour_manual(
      name   = "",
      values = c(Unconditional = "blue", Conditional = "green")
    ) +
    ggplot2::labs(
      y     = "Total N",
      title = "Pop. trajectories (blue: mean ±95% CI): green = extant"
    ) +
    ggplot2::theme_minimal() +
    ggplot2::guides(colour = "none", linetype = "none")

  print(p)         # side‐effect: always draws the plot
  invisible(p)     # returns p invisibly
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

#' Plot extinction probability together with mean F and mean sex-ratio
#'
#' @param out   result list from `run_pva_core(... , keep_traj = TRUE)`
#' @param lab_F character label for the inbreeding-coefficient line (default "Mean F")
#' @param lab_sr character label for the sex-ratio line (default "Mean SR")
#' @export
plot_ext <- function(out,
                     lab_F  = "Mean F",
                     lab_sr = "Mean SR") {

  if (is.null(out$ext_prob))
    stop("Must run with keep_traj = TRUE")

  df <- build_extinction_plot_data(out)
  med_t <- median_extinction_time(df$ext_prob)

  # --- now build plot with vline ----------------------------------------
  p <- ggplot2::ggplot(df, ggplot2::aes(x = Year)) +
    ggplot2::geom_line(                                    # extinction
      ggplot2::aes(y = ext_prob, colour = "Extinction prob.",
                   linetype = "Extinction prob."),
      linewidth = 1.2
    ) +
    ggplot2::geom_line(                                    # mean F
      ggplot2::aes(y = F_mean, colour = lab_F, linetype = lab_F),
      linewidth = 0.8
    ) +
    ggplot2::geom_line(                                    # mean SR
      ggplot2::aes(y = sr_mean, colour = lab_sr, linetype = lab_sr),
      linewidth = 0.8
    ) +
    # scales and legend
    {
      col_vals  <- setNames(c("red", "blue", "grey40"),
                            c("Extinction prob.", lab_F, lab_sr))
      line_vals <- setNames(c("solid", "dashed", "dotted"),
                            c("Extinction prob.", lab_F, lab_sr))
      ggplot2::scale_colour_manual(name = "", values = col_vals)
    } +
    ggplot2::scale_linetype_manual(values = line_vals, guide = "none") +
    ggplot2::labs(
      y     = "Proportion / Mean (0-1)",
      title = "Extinction probability with median TE (yellow), plus mean F and SR"
    ) +
    ggplot2::theme_minimal()

  if (is.finite(med_t)) {
    p <- p + ggplot2::geom_vline(
      xintercept = med_t,
      colour     = "yellow",
      linetype   = "dashed",
      linewidth  = 1
    )
  }

  print(p)
  invisible(p)
}

#' Combine PVA plots into a 2×1 panel
#'
#' Takes three ggplot objects (e.g. trajectory, summary, extinction) and
#' arranges them so that the first two sit side‐by‐side on the top row and
#' the third spans the bottom row.
#'
#' @param p1 A ggplot object (e.g. output of `plot_pva_traj()`)
#' @param p2 A ggplot object (e.g. output of `plot_pva_summary()`)
#' @param p3 A ggplot object (e.g. output of `plot_ext()`)
#' @return A patchwork composite
#' @export
plot_pva_panel <- function(p1, p2, p3) {
  # Ensure patchwork is available
  if (!requireNamespace("patchwork", quietly = TRUE)) {
    stop("Please install the patchwork package to use plot_pva_panel().")
  }
  # Top row: p1 + p2; bottom row: p3
  p <- patchwork::wrap_plots(
    (p1 + p2),   # side-by-side
    p3,          # full-width below
    ncol    = 1,    # one column of two rows
    heights = c(1, 1) # equal row heights (tweak as needed)
  )
  print(p)
  invisible(p)  
}
