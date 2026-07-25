validate_woodhen_risk_evidence <- function(evidence) {
  required <- c(
    "threshold_pairs", "total_reps", "crossed_reps", "probability_by_horizon",
    "first_crossing_year", "cumulative", "conditional_median_year",
    "overall_median_year", "minimum_breeding_pairs"
  )
  missing <- setdiff(required, names(evidence))
  if (length(missing) > 0L) {
    stop(
      "`evidence` is missing quasi-extinction field(s): ",
      paste(missing, collapse = ", "),
      call. = FALSE
    )
  }

  evidence
}

woodhen_risk_context <- function(evidence) {
  horizon <- tail(evidence$cumulative$year, 1L)
  list(
    horizon = horizon,
    subtitle = paste0(
      "Focal event: fewer than ", evidence$threshold_pairs,
      " breeding pairs | ", horizon, "-year horizon | ",
      evidence$total_reps, " futures"
    ),
    conditional_caption = if (evidence$crossed_reps == 0L) {
      "Conditional median: not available because no crossing futures were observed."
    } else {
      paste0(
        "Conditional median among crossing futures: ",
        format(evidence$conditional_median_year, trim = TRUE), " years."
      )
    }
  )
}

woodhen_probability_scale <- function() {
  ggplot2::scale_y_continuous(
    limits = c(0, 1),
    breaks = seq(0, 1, by = 0.25),
    labels = function(x) paste0(round(100 * x), "%"),
    expand = ggplot2::expansion(mult = c(0, 0.06))
  )
}

#' Plot cumulative risk of falling below the breeding-pair threshold
#'
#' @param evidence Output from `summarize_quasi_extinction()`.
#' @return A ggplot object.
#' @export
plot_woodhen_risk_over_time <- function(evidence) {
  evidence <- validate_woodhen_risk_evidence(evidence)
  context <- woodhen_risk_context(evidence)

  plot <- ggplot2::ggplot(
    evidence$cumulative,
    ggplot2::aes(x = year, y = probability)
  ) +
    ggplot2::geom_line(linewidth = 0.9, colour = "#006D77") +
    ggplot2::geom_point(size = 1.8, colour = "#006D77") +
    woodhen_probability_scale() +
    ggplot2::labs(
      title = paste0(
        "Risk of fewer than ", evidence$threshold_pairs, " breeding pairs"
      ),
      subtitle = context$subtitle,
      x = "Projection year",
      y = paste0(
        "Probability of ever reaching fewer than ", evidence$threshold_pairs,
        " breeding pairs"
      ),
      caption = context$conditional_caption
    ) +
    ggplot2::theme_minimal(base_size = 11)

  if (evidence$crossed_reps == 0L) {
    plot <- plot + ggplot2::annotate(
      "text",
      x = context$horizon / 2,
      y = 0.08,
      label = "No crossings observed",
      colour = "#4A4A4A"
    )
  }

  plot
}

#' Plot the first-passage distribution for the breeding-pair threshold
#'
#' @param evidence Output from `summarize_quasi_extinction()`.
#' @return A ggplot object.
#' @export
plot_woodhen_first_passage <- function(evidence) {
  evidence <- validate_woodhen_risk_evidence(evidence)
  context <- woodhen_risk_context(evidence)
  crossing_years <- evidence$first_crossing_year[!is.na(evidence$first_crossing_year)]
  plot_data <- data.frame(
    year = 0:context$horizon,
    futures = tabulate(crossing_years + 1L, nbins = context$horizon + 1L)
  )

  plot <- ggplot2::ggplot(
    plot_data,
    ggplot2::aes(x = year, y = futures)
  ) +
    ggplot2::geom_col(width = 0.85, fill = "#E76F51") +
    ggplot2::labs(
      title = paste0(
        "First passage to fewer than ", evidence$threshold_pairs, " breeding pairs"
      ),
      subtitle = context$subtitle,
      x = "First crossing year (crossing futures only)",
      y = "Number of futures",
      caption = context$conditional_caption
    ) +
    ggplot2::theme_minimal(base_size = 11)

  if (evidence$crossed_reps == 0L) {
    plot <- plot + ggplot2::annotate(
      "text",
      x = context$horizon / 2,
      y = 0.5,
      label = "No crossings observed",
      colour = "#4A4A4A"
    )
  }

  plot
}

#' Plot risk across breeding-pair thresholds
#'
#' @param evidence Output from `summarize_quasi_extinction()`.
#' @param max_threshold Optional positive whole-number upper threshold.
#' @return A ggplot object.
#' @export
plot_woodhen_threshold_curve <- function(evidence, max_threshold = NULL) {
  evidence <- validate_woodhen_risk_evidence(evidence)
  context <- woodhen_risk_context(evidence)
  if (is.null(max_threshold)) {
    max_threshold <- evidence$threshold_pairs
  }
  max_threshold <- validate_pair_threshold(max_threshold)

  plot_data <- data.frame(threshold = seq_len(max_threshold))
  plot_data$probability <- vapply(
    plot_data$threshold,
    function(threshold) mean(evidence$minimum_breeding_pairs < threshold),
    numeric(1)
  )

  ggplot2::ggplot(
    plot_data,
    ggplot2::aes(x = threshold, y = probability)
  ) +
    ggplot2::geom_line(linewidth = 0.9, colour = "#006D77") +
    ggplot2::geom_vline(
      xintercept = evidence$threshold_pairs,
      linetype = "dashed",
      colour = "#E76F51"
    ) +
    woodhen_probability_scale() +
    ggplot2::labs(
      title = "Risk across thresholds for breeding pairs",
      subtitle = context$subtitle,
      x = "Breeding-pair threshold (event is fewer than threshold)",
      y = "Probability by the horizon",
      caption = context$conditional_caption
    ) +
    ggplot2::theme_minimal(base_size = 11)
}

validate_woodhen_plot_run <- function(run) {
  woodhen_validate_compact_run(run)
  required <- c(
    "student_label", "trajectory_sample", "annual_quantiles",
    "final_abundance", "extinction_evidence", "quasi_extinction_50_pairs"
  )
  missing <- setdiff(required, names(run))
  if (length(missing) > 0L) {
    stop(
      "`run` is missing compact plotting field(s): ",
      paste(missing, collapse = ", "),
      call. = FALSE
    )
  }
  run
}

woodhen_compact_plot_subtitle <- function(run, units = "total birds") {
  paste0(
    run$student_label, " | ", units, " | ", run$horizon,
    "-year horizon | ", run$reps, " futures"
  )
}

#' Plot sampled and summarised Woodhen trajectories from compact evidence
#'
#' @param run A `woodhen_compact_run`.
#' @return A ggplot object.
#' @export
plot_woodhen_trajectories <- function(run) {
  run <- validate_woodhen_plot_run(run)
  ggplot2::ggplot(
    run$trajectory_sample,
    ggplot2::aes(
      x = year,
      y = abundance,
      group = factor(replicate_index)
    )
  ) +
    ggplot2::geom_line(colour = "#7A8C8D", alpha = 0.20, linewidth = 0.35) +
    ggplot2::geom_ribbon(
      data = run$annual_quantiles,
      ggplot2::aes(x = year, ymin = q025, ymax = q975),
      inherit.aes = FALSE,
      fill = "#9CC5C8",
      alpha = 0.45
    ) +
    ggplot2::geom_line(
      data = run$annual_quantiles,
      ggplot2::aes(x = year, y = median),
      inherit.aes = FALSE,
      colour = "#006D77",
      linewidth = 0.9
    ) +
    ggplot2::labs(
      title = "Population trajectories and annual uncertainty",
      subtitle = woodhen_compact_plot_subtitle(run),
      x = "Projection year",
      y = "Total abundance (birds)",
      caption = paste0(
        "Median and 95% interval across all futures; ",
        length(run$sampled_replicate_indices),
        " deterministically selected trajectories shown."
      )
    ) +
    ggplot2::theme_minimal(base_size = 11)
}

#' Plot the final-abundance distribution from compact evidence
#'
#' @param run A `woodhen_compact_run`.
#' @return A ggplot object.
#' @export
plot_woodhen_final_abundance <- function(run) {
  run <- validate_woodhen_plot_run(run)
  plot_data <- data.frame(abundance = run$final_abundance$values)
  ggplot2::ggplot(plot_data, ggplot2::aes(x = abundance)) +
    ggplot2::geom_histogram(bins = 30L, fill = "#4C956C", colour = "white") +
    ggplot2::geom_vline(
      xintercept = run$final_abundance$median,
      colour = "#1D3557",
      linewidth = 0.9
    ) +
    ggplot2::labs(
      title = "Final-abundance distribution",
      subtitle = woodhen_compact_plot_subtitle(run),
      x = "Final total abundance (birds)",
      y = "Number of futures",
      caption = paste0(
        "Median ", format(run$final_abundance$median, trim = TRUE),
        "; all-future 95% interval ",
        format(run$final_abundance$q025, trim = TRUE), "-",
        format(run$final_abundance$q975, trim = TRUE), "."
      )
    ) +
    ggplot2::theme_minimal(base_size = 11)
}

#' Plot cumulative extinction and warning-threshold risk from compact evidence
#'
#' @param run A `woodhen_compact_run`.
#' @return A ggplot object.
#' @export
plot_woodhen_risk_evidence <- function(run) {
  run <- validate_woodhen_plot_run(run)
  extinction <- run$extinction_evidence$cumulative
  extinction$event <- "Extinction (0 birds)"
  quasi <- run$quasi_extinction_50_pairs$cumulative
  threshold <- run$quasi_extinction_50_pairs$threshold_pairs
  quasi$event <- paste("Fewer than", threshold, "breeding pairs")
  plot_data <- rbind(extinction, quasi)
  conditional <- run$quasi_extinction_50_pairs$conditional_median_year
  conditional_caption <- if (is.na(conditional)) {
    paste0(
      "Conditional ", threshold,
      "-pair first-passage median: not available; no crossing futures were observed."
    )
  } else {
    paste0(
      "Conditional ", threshold,
      "-pair first-passage median among crossing futures: ",
      format(conditional, trim = TRUE), " years."
    )
  }

  ggplot2::ggplot(
    plot_data,
    ggplot2::aes(x = year, y = probability, colour = event)
  ) +
    ggplot2::geom_line(linewidth = 0.9) +
    woodhen_probability_scale() +
    ggplot2::scale_colour_manual(values = c("#B23A48", "#006D77")) +
    ggplot2::labs(
      title = "Cumulative population risk",
      subtitle = woodhen_compact_plot_subtitle(run, "birds and breeding pairs"),
      x = "Projection year",
      y = "Probability of ever reaching the event",
      colour = "Event",
      caption = conditional_caption
    ) +
    ggplot2::theme_minimal(base_size = 11) +
    ggplot2::theme(legend.position = "bottom")
}

validate_woodhen_plot_comparison <- function(comparison, family_type = NULL) {
  if (!inherits(comparison, "woodhen_run_family_comparison") ||
      !is.data.frame(comparison$table) || nrow(comparison$table) == 0L) {
    stop("`comparison` must be a compact Woodhen family comparison.", call. = FALSE)
  }
  if (!is.null(family_type) && !identical(comparison$family_type, family_type)) {
    stop("This plot requires a ", family_type, " family comparison.", call. = FALSE)
  }
  comparison
}

woodhen_comparison_caption <- function(comparison, normal_caption) {
  if (comparison$awkward_comparison) {
    paste0("Awkward comparison: ", comparison$awkward_annotation)
  } else {
    normal_caption
  }
}

#' Plot a compact one-factor sensitivity response
#'
#' @param comparison A sensitivity `woodhen_run_family_comparison`.
#' @return A ggplot object.
#' @export
plot_woodhen_sensitivity_response <- function(comparison) {
  comparison <- validate_woodhen_plot_comparison(comparison, "sensitivity")
  plot_data <- comparison$table
  if (anyNA(plot_data$setting_value)) {
    stop("Sensitivity plotting requires one scalar setting value per run.", call. = FALSE)
  }
  plot_data <- plot_data[order(plot_data$setting_value), , drop = FALSE]
  horizon <- unique(plot_data$horizon)
  reps <- unique(plot_data$reps)

  ggplot2::ggplot(
    plot_data,
    ggplot2::aes(x = setting_value, y = final_median_abundance)
  ) +
    ggplot2::geom_ribbon(
      ggplot2::aes(ymin = final_q025, ymax = final_q975),
      fill = "#9CC5C8",
      alpha = 0.45
    ) +
    ggplot2::geom_line(colour = "#006D77", linewidth = 0.9) +
    ggplot2::geom_point(colour = "#006D77", size = 2.2) +
    ggplot2::labs(
      title = "Sensitivity response across settings",
      subtitle = paste0(
        comparison$family_id, " | total birds | ",
        paste(horizon, collapse = "/"), "-year horizon | ",
        paste(reps, collapse = "/"), " futures"
      ),
      x = "Ecological factor setting",
      y = "Final total abundance (median and 95% interval)",
      caption = woodhen_comparison_caption(
        comparison,
        "Each setting differs from the locked baseline in one named factor."
      )
    ) +
    ggplot2::theme_minimal(base_size = 11)
}

#' Plot a compact baseline-threat-intervention comparison
#'
#' @param comparison A prospective `woodhen_run_family_comparison`.
#' @return A ggplot object.
#' @export
plot_woodhen_family_comparison <- function(comparison) {
  comparison <- validate_woodhen_plot_comparison(comparison, "prospective")
  table <- comparison$table
  n <- nrow(table)
  thresholds <- unique(vapply(
    comparison$runs,
    function(run) run$quasi_extinction_50_pairs$threshold_pairs,
    integer(1)
  ))
  if (length(thresholds) != 1L) {
    stop("Prospective comparison runs must share one warning threshold.", call. = FALSE)
  }
  warning_metric <- paste("Probability of fewer than", thresholds[[1L]], "breeding pairs")
  plot_data <- data.frame(
    student_label = rep(table$student_label, 3L),
    scenario_type = rep(table$scenario_type, 3L),
    scenario_order = rep(seq_len(n), 3L),
    metric = factor(
      rep(c(
        "Final total abundance (birds)",
        "Extinction probability",
        warning_metric
      ), each = n),
      levels = c(
        "Final total abundance (birds)",
        "Extinction probability",
        warning_metric
      )
    ),
    value = c(
      table$final_median_abundance,
      table$extinction_probability,
      table$quasi_extinction_probability
    ),
    lower = c(table$final_q025, table$extinction_probability, table$quasi_extinction_probability),
    upper = c(table$final_q975, table$extinction_probability, table$quasi_extinction_probability)
  )
  plot_data$student_label <- factor(
    plot_data$student_label,
    levels = unique(table$student_label)
  )

  ggplot2::ggplot(
    plot_data,
    ggplot2::aes(x = student_label, y = value, colour = scenario_type)
  ) +
    ggplot2::geom_errorbar(
      ggplot2::aes(ymin = lower, ymax = upper),
      width = 0.16,
      linewidth = 0.65
    ) +
    ggplot2::geom_point(size = 2.2) +
    ggplot2::facet_wrap(~metric, scales = "free_y", ncol = 1L) +
    ggplot2::scale_colour_manual(values = c(
      locked_baseline = "#006D77",
      threat = "#B23A48",
      intervention = "#4C956C"
    )) +
    ggplot2::labs(
      title = "Baseline, threat, and intervention evidence",
      subtitle = paste0(
        comparison$family_id, " | ", paste(unique(table$horizon), collapse = "/"),
        "-year horizon | ", paste(unique(table$reps), collapse = "/"), " futures"
      ),
      x = NULL,
      y = NULL,
      colour = "Scenario order",
      caption = woodhen_comparison_caption(
        comparison,
        "Risk probabilities are proportions; final abundance shows the all-future 95% interval."
      )
    ) +
    ggplot2::theme_minimal(base_size = 11) +
    ggplot2::theme(
      legend.position = "none",
      axis.text.x = ggplot2::element_text(angle = 20, hjust = 1)
    )
}

# Stable descriptive aliases for callers that name the evidence rather than the display.
plot_woodhen_trajectory_evidence <- plot_woodhen_trajectories
plot_woodhen_final_distribution <- plot_woodhen_final_abundance
plot_woodhen_baseline_threat_intervention <- plot_woodhen_family_comparison
