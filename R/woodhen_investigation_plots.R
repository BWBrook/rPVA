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
