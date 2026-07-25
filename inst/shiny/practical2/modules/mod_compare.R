compare_or <- function(value, default) {
  if (is.null(value) || length(value) == 0L) default else value
}

compare_probability <- function(value) {
  ifelse(
    is.na(value),
    "Not observed",
    sprintf("%.1f%%", 100 * as.numeric(value))
  )
}

compare_whole_birds <- function(value) {
  format(
    round(as.numeric(value)),
    big.mark = ",",
    scientific = FALSE,
    trim = TRUE
  )
}

compare_cumulative_curve <- function(years, final_probability, midpoint, scale) {
  if (final_probability == 0) return(rep(0, length(years)))
  raw <- stats::plogis((years - midpoint) / scale)
  start <- raw[[1L]]
  finish <- raw[[length(raw)]]
  final_probability * (raw - start) / (finish - start)
}

compare_abundance_series <- function(scenario,
                                     years,
                                     median,
                                     q025,
                                     q975) {
  data.frame(
    scenario = scenario,
    projection_year = years,
    calendar_year = 2025L + years,
    q025 = pmax(0, q025),
    median = pmax(0, median),
    q975 = pmax(0, q975),
    stringsAsFactors = FALSE
  )
}

compare_first_passage_rows <- function(scenario, years, cumulative) {
  probability <- pmax(0, diff(c(0, cumulative)))
  data.frame(
    scenario = scenario,
    projection_start = years,
    projection_end = pmin(years + 4L, 75L),
    calendar_start = 2025L + years,
    calendar_end = 2029L + years,
    probability = probability,
    count = as.integer(round(1000 * probability)),
    stringsAsFactors = FALSE
  )
}

compare_probe_future_evidence <- function() {
  years <- seq.int(0L, 75L, 5L)
  scenarios <- c(
    "Common future",
    "Severe rat-return stress test",
    "Rat return with renewed control"
  )

  common_median <- c(
    1654, 2226, 2214, 2243, 2218, 2214, 2222, 2206,
    2187, 2197, 2186, 2200, 2216, 2178, 2166, 2163
  )
  common_q025 <- c(
    1654, 1658, 1708, 1584, 1620, 1620, 1686, 1648,
    1644, 1612, 1598, 1634, 1628, 1582, 1598, 1580
  )
  common_q975 <- c(
    1654, 2992, 2920, 2946, 2904, 2930, 2938, 2914,
    2950, 2958, 2900, 2962, 2988, 2925, 2892, 2884
  )

  threat_median <- 178 + (1654 - 178) * ((75 - years) / 75)^1.35
  threat_q025 <- pmax(0, threat_median - 900 * (years / 75)^0.8)
  threat_q975 <- threat_median + (1346 - 178) * (years / 75)^0.9

  managed_median <- 1786 +
    (1654 - 1786) * exp(-years / 14) +
    115 * sin(pi * years / 75)
  managed_q025 <- managed_median - (managed_median - 1180) * (years / 75)
  managed_q975 <- managed_median + (2316 - managed_median) * (years / 75)

  abundance <- do.call(rbind, list(
    compare_abundance_series(
      scenarios[[1L]], years, common_median, common_q025, common_q975
    ),
    compare_abundance_series(
      scenarios[[2L]], years, threat_median, threat_q025, threat_q975
    ),
    compare_abundance_series(
      scenarios[[3L]], years, managed_median, managed_q025, managed_q975
    )
  ))
  rownames(abundance) <- NULL

  threat_warning <- compare_cumulative_curve(years, 0.923, 23, 8)
  managed_warning <- compare_cumulative_curve(years, 0.015, 38, 10)
  risk <- data.frame(
    scenario = rep(scenarios, each = length(years)),
    projection_year = rep(years, times = length(scenarios)),
    calendar_year = rep(2025L + years, times = length(scenarios)),
    metric = "Fewer than 100 pairs",
    probability = c(rep(0, length(years)), threat_warning, managed_warning),
    stringsAsFactors = FALSE
  )

  passage_years <- seq.int(1L, 71L, 5L)
  threat_passage <- approx(
    years, threat_warning, xout = passage_years, rule = 2
  )$y
  managed_passage <- approx(
    years, managed_warning, xout = passage_years, rule = 2
  )$y
  first_passage <- rbind(
    compare_first_passage_rows(
      scenarios[[2L]], passage_years, threat_passage
    ),
    compare_first_passage_rows(
      scenarios[[3L]], passage_years, managed_passage
    )
  )

  summary <- data.frame(
    scenario = scenarios,
    period = "2025-2100",
    horizon = 75L,
    final_median_abundance = c(2163, 178, 1786),
    final_q025 = c(1580, 0, 1180),
    final_q975 = c(2884, 1346, 2316),
    extinction_probability = c(0, 0.179, 0),
    warning_probability = c(0, 0.923, 0.015),
    crossed_reps = c(0L, 923L, 15L),
    conditional_median_crossing_year = c(NA, 25, 40),
    reps = 1000L,
    stringsAsFactors = FALSE
  )

  list(
    summary = summary,
    abundance = abundance,
    risk = risk,
    first_passage = first_passage,
    differences = list(
      final_median_birds = 1608,
      extinction_percentage_points = -17.9,
      warning_percentage_points = -90.8
    )
  )
}

compare_probe_sensitivity_evidence <- function() {
  years <- seq.int(0L, 75L, 5L)
  settings <- c(150, 325, 500)
  scenarios <- c(
    "Lower capacity: 150 territories",
    "Current setting: 325 territories",
    "Higher capacity: 500 territories"
  )
  final_median <- c(984, 2163, 3398)
  final_q025 <- c(576, 1580, 2600)
  final_q975 <- c(1470, 2884, 4406)
  warning <- c(0.998, 0, 0)

  abundance <- do.call(rbind, lapply(seq_along(settings), function(index) {
    median <- final_median[[index]] +
      (1654 - final_median[[index]]) * exp(-years / 11)
    q025 <- median - (median - final_q025[[index]]) * (years / 75)
    q975 <- median + (final_q975[[index]] - median) * (years / 75)
    compare_abundance_series(
      scenarios[[index]], years, median, q025, q975
    )
  }))
  rownames(abundance) <- NULL

  low_warning <- compare_cumulative_curve(years, warning[[1L]], 9, 4)
  risk <- data.frame(
    scenario = rep(scenarios, each = length(years)),
    projection_year = rep(years, times = length(scenarios)),
    calendar_year = rep(2025L + years, times = length(scenarios)),
    metric = "Fewer than 100 pairs",
    probability = c(low_warning, rep(0, 2L * length(years))),
    stringsAsFactors = FALSE
  )
  passage_years <- seq.int(1L, 71L, 5L)
  low_passage <- approx(
    years, low_warning, xout = passage_years, rule = 2
  )$y

  summary <- data.frame(
    scenario = scenarios,
    period = "2025-2100",
    horizon = 75L,
    final_median_abundance = final_median,
    final_q025 = final_q025,
    final_q975 = final_q975,
    extinction_probability = 0,
    warning_probability = warning,
    crossed_reps = as.integer(round(1000 * warning)),
    conditional_median_crossing_year = c(9, NA, NA),
    reps = 1000L,
    stringsAsFactors = FALSE
  )

  list(
    summary = summary,
    abundance = abundance,
    risk = risk,
    first_passage = compare_first_passage_rows(
      scenarios[[1L]], passage_years, low_passage
    ),
    response = data.frame(
      factor_id = "K",
      setting_value = settings,
      setting_label = scenarios,
      final_median_abundance = final_median,
      final_q025 = final_q025,
      final_q975 = final_q975,
      extinction_probability = 0,
      quasi_extinction_probability = warning,
      quasi_extinction_conditional_median_year = c(9, NA, NA),
      reps = 1000L,
      stringsAsFactors = FALSE
    )
  )
}

compare_probe_context_evidence <- function() {
  list(summary = data.frame(
    scenario = c(
      "Post-eradication recovery check",
      "Common future outlook"
    ),
    purpose = c(
      "Historical consistency check",
      "No-change reference for future comparisons"
    ),
    period = c("2019-2024", "2025-2100"),
    horizon = c(5L, 75L),
    final_median_abundance = c(1638, 2163),
    final_q025 = c(1290, 1580),
    final_q975 = c(2075, 2884),
    extinction_probability = c(0, 0),
    warning_probability = c(NA, 0),
    crossed_reps = c(NA_integer_, 0L),
    conditional_median_crossing_year = c(NA, NA),
    reps = 1000L,
    stringsAsFactors = FALSE
  ))
}

compare_probe_catalog <- function() {
  list(
    future = list(
      id = "future",
      group = "Threat and management",
      label = "Rat return and renewed control",
      question = "How much does renewed control recover after a severe rat-return stress test?",
      purpose = paste(
        "Use the common future to measure the modelled threat effect, then compare",
        "renewed control with that same threatened future."
      ),
      compatible = TRUE,
      compatibility_title = "Direct comparison",
      compatibility = paste(
        "All three scenarios begin from the same 2025 population, use the same",
        "75-year horizon and 1,000 simulated futures, and belong to one",
        "threat-management family. Only the stated threat and response differ."
      ),
      held_constant = "Starting population, horizon, simulation effort and all non-target assumptions.",
      scenario_roles = c("No-change reference", "Threatened future", "Managed threatened future"),
      evidence = compare_probe_future_evidence()
    ),
    sensitivity = list(
      id = "sensitivity",
      group = "Sensitivity",
      label = "Breeding-territory capacity",
      question = "How strongly does the future outlook depend on breeding-territory capacity?",
      purpose = paste(
        "Bracket the current no-change assumption with one lower and one higher",
        "setting while every other model assumption remains fixed."
      ),
      compatible = TRUE,
      compatibility_title = "Direct comparison",
      compatibility = paste(
        "These three runs share the 2025 starting population, 75-year horizon,",
        "1,000 simulated futures and common-future assumptions. Only the",
        "breeding-territory ceiling changes."
      ),
      held_constant = "Vital rates, environmental variability, catastrophe settings and warning threshold.",
      scenario_roles = c("Lower setting", "No-change setting", "Higher setting"),
      evidence = compare_probe_sensitivity_evidence()
    ),
    context = list(
      id = "context",
      group = "Context only",
      label = "Recovery check beside future outlook",
      question = "What does each time period contribute to the Woodhen case study?",
      purpose = paste(
        "Inspect the historical recovery check beside the future reference without",
        "treating their final values as one management experiment."
      ),
      compatible = FALSE,
      compatibility_title = "Context only - do not rank these outcomes as one experiment",
      compatibility = paste(
        "The 2019-2024 recovery check and 2025-2100 future outlook differ in",
        "starting population, calendar period, purpose and horizon. Discuss what",
        "each contributes, but use a matched family to estimate a management effect."
      ),
      held_constant = "Nothing sufficient for a direct effect comparison.",
      scenario_roles = c("Historical consistency check", "Future no-change reference"),
      evidence = compare_probe_context_evidence()
    )
  )
}

compare_probe_family <- function(family_id) {
  catalog <- compare_probe_catalog()
  if (!is.character(family_id) || length(family_id) != 1L ||
      is.na(family_id) || !family_id %in% names(catalog)) {
    stop("Choose one available comparison.", call. = FALSE)
  }
  catalog[[family_id]]
}

compare_probe_choices <- function() {
  list(
    "Threat and management" = c(
      "Rat return and renewed control" = "future"
    ),
    "Sensitivity" = c(
      "Breeding-territory capacity" = "sensitivity"
    ),
    "Context only" = c(
      "Recovery check beside future outlook" = "context"
    )
  )
}

compare_view_choices <- function(family_id) {
  if (identical(family_id, "context")) {
    return(c("Context overview" = "context"))
  }
  c(
    "Population through time" = "population",
    "Warning risk through time" = "risk",
    "Final abundance" = "final",
    "When the warning threshold was crossed" = "passage",
    "Change summary" = "response"
  )
}

compare_palette <- function(labels) {
  colours <- vapply(labels, function(label) {
    if (grepl(
      "threat|stress test|lower capacity",
      label,
      ignore.case = TRUE
    )) {
      "#a23b4a"
    } else if (grepl(
      "managed|control|response|higher capacity",
      label,
      ignore.case = TRUE
    )) {
      "#4f7a3d"
    } else {
      "#236b70"
    }
  }, character(1))
  stats::setNames(colours, labels)
}

compare_plot_theme <- function() {
  ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      legend.position = "bottom",
      legend.title = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(face = "bold")
    )
}

compare_population_plot <- function(evidence) {
  data <- evidence$abundance
  labels <- evidence$summary$scenario
  data$scenario <- factor(data$scenario, levels = labels)
  ggplot2::ggplot(
    data,
    ggplot2::aes(
      x = calendar_year,
      y = median,
      colour = scenario,
      fill = scenario
    )
  ) +
    ggplot2::geom_ribbon(
      ggplot2::aes(ymin = q025, ymax = q975),
      alpha = 0.16,
      colour = NA
    ) +
    ggplot2::geom_line(linewidth = 0.9) +
    ggplot2::facet_wrap(~scenario, nrow = 1L) +
    ggplot2::scale_colour_manual(values = compare_palette(labels)) +
    ggplot2::scale_fill_manual(values = compare_palette(labels)) +
    ggplot2::scale_x_continuous(
      breaks = seq.int(2025L, 2100L, 25L),
      limits = c(2025, 2100)
    ) +
    ggplot2::scale_y_continuous(
      labels = compare_whole_birds,
      expand = ggplot2::expansion(mult = c(0.02, 0.05))
    ) +
    ggplot2::labs(
      title = "Population outcomes through time",
      subtitle = "Median and 95% simulation interval across 1,000 futures",
      x = "Calendar year",
      y = "Number of birds"
    ) +
    compare_plot_theme() +
    ggplot2::theme(legend.position = "none")
}

compare_risk_plot <- function(evidence) {
  data <- evidence$risk
  labels <- evidence$summary$scenario
  data$scenario <- factor(data$scenario, levels = labels)
  ggplot2::ggplot(
    data,
    ggplot2::aes(
      x = calendar_year,
      y = probability,
      colour = scenario
    )
  ) +
    ggplot2::geom_line(linewidth = 1) +
    ggplot2::scale_colour_manual(values = compare_palette(labels)) +
    ggplot2::scale_x_continuous(
      breaks = seq.int(2025L, 2100L, 15L),
      limits = c(2025, 2100)
    ) +
    ggplot2::scale_y_continuous(
      limits = c(0, 1),
      breaks = seq(0, 1, by = 0.2),
      labels = function(value) paste0(round(100 * value), "%"),
      expand = ggplot2::expansion(mult = c(0, 0))
    ) +
    ggplot2::labs(
      title = "Cumulative 100-pair warning risk",
      subtitle = "Probability of having fallen below 100 territory-holding pairs",
      x = "Calendar year",
      y = "Cumulative probability"
    ) +
    compare_plot_theme()
}

compare_final_plot <- function(evidence) {
  data <- evidence$summary
  data$scenario <- factor(data$scenario, levels = rev(data$scenario))
  ggplot2::ggplot(
    data,
    ggplot2::aes(x = scenario, y = final_median_abundance)
  ) +
    ggplot2::geom_errorbar(
      ggplot2::aes(ymin = final_q025, ymax = final_q975),
      width = 0.16,
      linewidth = 0.9,
      colour = "#4b7474"
    ) +
    ggplot2::geom_point(size = 3.4, colour = "#126a73") +
    ggplot2::coord_flip() +
    ggplot2::scale_y_continuous(
      labels = compare_whole_birds,
      expand = ggplot2::expansion(mult = c(0.03, 0.08))
    ) +
    ggplot2::labs(
      title = "Final abundance",
      subtitle = "Median and 95% simulation interval in 2100",
      x = NULL,
      y = "Number of birds"
    ) +
    compare_plot_theme() +
    ggplot2::theme(legend.position = "none")
}

compare_passage_plot <- function(evidence) {
  data <- evidence$first_passage
  data <- data[data$probability > 0, , drop = FALSE]
  data$calendar_midpoint <- (data$calendar_start + data$calendar_end) / 2
  labels <- unique(data$scenario)
  ggplot2::ggplot(
    data,
    ggplot2::aes(
      x = calendar_midpoint,
      y = probability,
      fill = scenario
    )
  ) +
    ggplot2::geom_col(
      position = ggplot2::position_dodge(width = 4),
      width = 3.6
    ) +
    ggplot2::scale_fill_manual(values = compare_palette(labels)) +
    ggplot2::scale_x_continuous(
      breaks = seq.int(2030L, 2100L, 10L),
      limits = c(2025, 2101)
    ) +
    ggplot2::scale_y_continuous(
      labels = function(value) paste0(round(100 * value, 1), "%"),
      expand = ggplot2::expansion(mult = c(0, 0.08))
    ) +
    ggplot2::labs(
      title = "First passage below 100 pairs",
      subtitle = paste(
        "Percentage of all 1,000 futures first crossing in each five-year",
        "period; bars sum to the risk by 2100"
      ),
      x = "Calendar-year period",
      y = "Percentage of all futures"
    ) +
    compare_plot_theme()
}

compare_management_response_plot <- function(evidence) {
  data <- evidence$summary[2:3, , drop = FALSE]
  data$scenario <- factor(data$scenario, levels = data$scenario)
  abundance_limit <- max(data$final_q975) * 1.08

  abundance <- ggplot2::ggplot(
    data,
    ggplot2::aes(x = scenario, y = final_median_abundance, group = 1L)
  ) +
    ggplot2::geom_line(linewidth = 0.8, colour = "#78908e") +
    ggplot2::geom_point(size = 3.3, colour = "#126a73") +
    ggplot2::geom_errorbar(
      ggplot2::aes(ymin = final_q025, ymax = final_q975),
      width = 0.12,
      linewidth = 0.8,
      colour = "#4a7779"
    ) +
    ggplot2::scale_y_continuous(
      limits = c(0, abundance_limit),
      labels = compare_whole_birds
    ) +
    ggplot2::labs(
      title = "Final abundance in 2100",
      subtitle = "Median and 95% simulation interval",
      x = NULL,
      y = "Number of birds"
    ) +
    compare_plot_theme() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 10, hjust = 1),
      legend.position = "none"
    )

  risk <- ggplot2::ggplot(
    data,
    ggplot2::aes(x = scenario, y = warning_probability, group = 1L)
  ) +
    ggplot2::geom_line(linewidth = 0.9, colour = "#b23a48") +
    ggplot2::geom_point(size = 3.3, colour = "#b23a48") +
    ggplot2::geom_text(
      ggplot2::aes(
        label = sprintf("%.1f%%", 100 * warning_probability),
        vjust = ifelse(warning_probability > 0.9, 1.5, -0.8)
      ),
      size = 3.8,
      colour = "#7d2631"
    ) +
    ggplot2::scale_y_continuous(
      limits = c(0, 1),
      breaks = seq(0, 1, by = 0.2),
      labels = function(value) paste0(round(100 * value), "%"),
      expand = ggplot2::expansion(mult = c(0, 0.03))
    ) +
    ggplot2::labs(
      title = "Risk of falling below 100 pairs",
      subtitle = "Probability at any time from 2025 to 2100",
      x = NULL,
      y = "Probability"
    ) +
    compare_plot_theme() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 10, hjust = 1),
      legend.position = "none"
    )

  patchwork::wrap_plots(abundance, risk, widths = c(1.12, 1)) +
    patchwork::plot_annotation(
      title = "Management response compared with the same threat",
      caption = paste(
        "Renewed control is added to the same rat-return stress test;",
        "it is not compared with an unrelated run."
      ),
      theme = ggplot2::theme(
        plot.title = ggplot2::element_text(size = 15, face = "bold"),
        plot.caption = ggplot2::element_text(colour = "#4f5d5d")
      )
    )
}

compare_probe_table <- function(family) {
  data <- family$evidence$summary
  timing <- vapply(seq_len(nrow(data)), function(index) {
    if (is.na(data$conditional_median_crossing_year[[index]])) {
      "Not observed"
    } else {
      paste0(
        2025 + round(data$conditional_median_crossing_year[[index]]),
        " (among futures that crossed)"
      )
    }
  }, character(1))
  warning <- compare_probability(data$warning_probability)
  if (identical(family$id, "context")) {
    warning[[1L]] <- "Not comparable for this short historical check"
  }
  data.frame(
    Scenario = data$scenario,
    Period = data$period,
    `Final modelled median birds (95% interval)` = paste0(
      compare_whole_birds(data$final_median_abundance), " (",
      compare_whole_birds(data$final_q025), " - ",
      compare_whole_birds(data$final_q975), ")"
    ),
    `Below 100 pairs` = warning,
    `Conditional median crossing year` = timing,
    `Extinction by final year` = compare_probability(
      data$extinction_probability
    ),
    check.names = FALSE
  )
}

compare_help_modal <- function() {
  modalDialog(
    title = "How to build a defensible comparison",
    div(
      class = "help-modal-content",
      render_markdown_content(file.path(
        practical2_app_dir, "content", "help-compare.md"
      ))
    ),
    footer = modalButton("Close"),
    easyClose = TRUE,
    size = "l"
  )
}

compare_evidence_help_modal <- function() {
  modalDialog(
    title = "How selected evidence moves forward",
    div(
      class = "help-modal-content",
      p(
        "Choose the current plot, the compact table, or both when they directly",
        "support the claim you are recording below."
      ),
      tags$ul(
        tags$li(
          strong("Current plot: "),
          "the evidence view now displayed on this page."
        ),
        tags$li(
          strong("Compact comparison table: "),
          "the numerical record for the same matched comparison."
        )
      ),
      p(
        "Selecting a box does not save anything by itself. When you select",
        strong("Save comparison notes"),
        "the chosen evidence, your interpretation, and your caveat will form one",
        "comparison item for Evidence Studio."
      ),
      p(
        "Evidence Studio is where you will later review, trim, and export a",
        "deliberate evidence dossier. Keep only material that helps you make or",
        "qualify a conservation claim."
      )
    ),
    footer = modalButton("Close"),
    easyClose = TRUE,
    size = "m"
  )
}

compare_run_library <- function() {
  data.frame(
    family_id = c(
      rep("future", 3L),
      rep("sensitivity", 3L),
      rep("context", 2L)
    ),
    type = c(
      rep("Threat and management", 3L),
      rep("Sensitivity", 3L),
      rep("Context only", 2L)
    ),
    label = c(
      "Common future",
      "Severe rat-return stress test",
      "Rat return with renewed control",
      "Lower capacity: 150 territories",
      "Current setting: 325 territories",
      "Higher capacity: 500 territories",
      "Post-eradication recovery check",
      "Common future outlook"
    ),
    period = c(rep("2025-2100", 6L), "2019-2024", "2025-2100"),
    family = c(
      rep("Rat return and renewed control", 3L),
      rep("Breeding-territory capacity", 3L),
      rep("Recovery check beside future outlook", 2L)
    ),
    stringsAsFactors = FALSE
  )
}

compare_run_library_modal <- function(ns) {
  modalDialog(
    title = "Browse representative project runs",
    div(
      class = "compare-library-tools",
      textInput(
        ns("library_search"),
        "Search runs",
        placeholder = "Try habitat, rat, future or recovery"
      ),
      selectInput(
        ns("library_type"),
        "Show",
        choices = c(
          "All run types" = "all",
          "Threat and management" = "Threat and management",
          "Sensitivity" = "Sensitivity",
          "Context only" = "Context only"
        )
      )
    ),
    p(
      class = "compare-library-note",
      "The active comparison remains dominant. This library helps you find",
      "ecologically related runs without turning Compare into a session-history list."
    ),
    uiOutput(ns("library_results")),
    footer = modalButton("Close"),
    easyClose = TRUE,
    size = "l"
  )
}

compare_ui <- function(id) {
  ns <- NS(id)
  div(
    class = "page-shell compare-shell",
    tags$header(
      class = "compare-header",
      div(
        span(class = "section-eyebrow", "Compare project evidence"),
        h1("Build one defensible comparison"),
        p(
          "Choose a matched scenario family, inspect its outcomes together,",
          "and retain only the evidence that informs your conservation advice."
        )
      ),
      div(
        class = "compare-header-actions",
        actionButton(
          ns("open_library"),
          "Browse project runs",
          icon = icon("magnifying-glass"),
          class = "btn-default btn-sm"
        ),
        actionButton(
          ns("open_help"),
          "Comparison guide",
          icon = icon("circle-info"),
          class = "btn-default btn-sm"
        )
      )
    ),
    tags$section(
      class = "compare-family-band",
      div(
        class = "compare-family-choice",
        selectInput(
          ns("family"),
          "Active comparison",
          choices = compare_probe_choices(),
          selected = "future"
        ),
        p(
          "Start from a named family. The run library shows related evidence",
          "without letting the complete project history dominate this page."
        )
      ),
      uiOutput(ns("family_summary"))
    ),
    uiOutput(ns("compatibility")),
    tags$section(
      class = "compare-active-workspace",
      div(
        class = "compare-question-row",
        div(
          span(class = "workspace-label", "Active question"),
          uiOutput(ns("question"))
        ),
        uiOutput(ns("scenario_chips"))
      ),
      uiOutput(ns("view_controls")),
      uiOutput(ns("evidence_view")),
      div(
        class = "compare-evidence-actions",
        div(
          class = "compare-evidence-choice",
          div(
            class = "compare-evidence-choice-heading",
            div(
              span(class = "workspace-label", "Evidence handoff"),
              h3("Choose for Evidence Studio")
            ),
            actionButton(
              ns("open_evidence_help"),
              "How this works",
              icon = icon("circle-info"),
              class = "btn-default btn-sm"
            )
          ),
          p(
            "Tick the plot, table, or both if they support the claim you will",
            "record below. Selection alone does not save them."
          ),
          uiOutput(ns("keep_controls"))
        ),
        div(
          class = "compare-keep-status",
          icon("bookmark"),
          textOutput(ns("keep_count"), inline = TRUE)
        )
      )
    ),
    tags$section(
      class = "compare-table-band",
      div(
        class = "compare-section-heading",
        div(
          span(class = "workspace-label", "Quantitative check"),
          h2("Compact comparison record")
        ),
        p(
          "Use the table to verify magnitudes and timing; use a plot to show the",
          "pattern that matters for your claim."
        )
      ),
      div(
        class = "compare-table-wrap",
        tableOutput(ns("comparison_table"))
      ),
      uiOutput(ns("table_note"))
    ),
    tags$section(
      class = "compare-reasoning-band",
      span(class = "workspace-label", "Interpret before exporting"),
      h2("Record the claim and its boundary"),
      p(
        "A useful evidence item needs both an interpretation and a caveat.",
        "These prompts are optional, but they make later report writing much easier."
      ),
      div(
        class = "compare-reasoning-grid",
        textAreaInput(
          ns("interpretation"),
          "What pattern does this comparison support?",
          rows = 3,
          placeholder = paste(
            "Which difference matters for the management question?",
            "Do abundance and warning risk support the same interpretation?"
          )
        ),
        textAreaInput(
          ns("caveat"),
          "What uncertainty or limitation qualifies that pattern?",
          rows = 3,
          placeholder = paste(
            "What uncertainty is represented by these simulated futures?",
            "What important uncertainty is not represented?"
          )
        )
      ),
      actionButton(
        ns("save_reasoning"),
        "Save comparison notes",
        icon = icon("note-sticky"),
        class = "btn-default",
        disabled = "disabled",
        `aria-disabled` = "true"
      ),
      div(
        class = "compare-preview-note",
        icon("circle-info"),
        span(
          "Design preview: the evidence bundle is visible here, but saving it",
          "into Evidence Studio is enabled in the next build stage."
        )
      )
    )
  )
}

compare_server <- function(id, project = NULL) {
  moduleServer(id, function(input, output, session) {
    active_family_id <- reactive({
      compare_or(input$family, "future")
    })
    active_family <- reactive({
      compare_probe_family(active_family_id())
    })

    observeEvent(input$open_help, {
      showModal(compare_help_modal())
    })
    observeEvent(input$open_library, {
      showModal(compare_run_library_modal(session$ns))
    })
    observeEvent(input$open_evidence_help, {
      showModal(compare_evidence_help_modal())
    })

    output$family_summary <- renderUI({
      family <- active_family()
      div(
        class = "compare-family-summary",
        div(
          span("Purpose"),
          strong(family$group)
        ),
        div(
          span("Held constant"),
          strong(family$held_constant)
        )
      )
    })

    output$compatibility <- renderUI({
      family <- active_family()
      div(
        class = paste(
          "compare-compatibility",
          if (family$compatible) "is-compatible" else "is-context"
        ),
        icon(if (family$compatible) "circle-check" else "triangle-exclamation"),
        div(
          strong(family$compatibility_title),
          span(family$compatibility)
        )
      )
    })

    output$question <- renderUI({
      family <- active_family()
      tagList(
        h2(family$question),
        p(family$purpose)
      )
    })

    output$scenario_chips <- renderUI({
      family <- active_family()
      summary <- family$evidence$summary
      div(
        class = "compare-scenario-chips",
        lapply(seq_len(nrow(summary)), function(index) {
          span(
            class = "compare-scenario-chip",
            tags$small(family$scenario_roles[[index]]),
            strong(summary$scenario[[index]])
          )
        })
      )
    })

    output$view_controls <- renderUI({
      choices <- compare_view_choices(active_family_id())
      selected <- if (!is.null(input$view) &&
          input$view %in% unname(choices)) {
        input$view
      } else {
        unname(choices)[[1L]]
      }
      div(
        class = "compare-view-switch",
        radioButtons(
          session$ns("view"),
          "Evidence view",
          choices = choices,
          selected = selected,
          inline = TRUE
        )
      )
    })

    output$evidence_view <- renderUI({
      family <- active_family()
      if (!family$compatible) {
        return(div(
          class = "compare-context-overview",
          icon("scale-balanced"),
          div(
            h3("Use these runs as context, not as a ranked experiment"),
            p(
              "The recovery check asks whether a short historical reconstruction",
              "is broadly consistent with survey evidence. The future outlook asks",
              "what the supplied no-change model projects over 75 years."
            ),
            p(
              strong("Next move: "),
              "return to a matched sensitivity or threat-management family before",
              "estimating an effect."
            )
          )
        ))
      }
      view <- compare_or(input$view, "population")
      output_id <- switch(
        view,
        population = "population_plot",
        risk = "risk_plot",
        final = "final_plot",
        passage = "passage_plot",
        response = "response_plot",
        "population_plot"
      )
      div(
        class = "compare-plot-region",
        role = "img",
        `aria-label` = paste(view, "evidence for", family$label),
        plotOutput(session$ns(output_id), height = "500px")
      )
    })

    output$population_plot <- renderPlot({
      family <- active_family()
      req(family$compatible)
      compare_population_plot(family$evidence)
    }, res = 96)

    output$risk_plot <- renderPlot({
      family <- active_family()
      req(family$compatible)
      compare_risk_plot(family$evidence)
    }, res = 96)

    output$final_plot <- renderPlot({
      family <- active_family()
      req(family$compatible)
      compare_final_plot(family$evidence)
    }, res = 96)

    output$passage_plot <- renderPlot({
      family <- active_family()
      req(family$compatible)
      compare_passage_plot(family$evidence)
    }, res = 96)

    output$response_plot <- renderPlot({
      family <- active_family()
      req(family$compatible)
      if (identical(family$id, "sensitivity")) {
        investigate_sensitivity_probe_plot(family$evidence$response)
      } else {
        compare_management_response_plot(family$evidence)
      }
    }, res = 96)

    output$comparison_table <- renderTable({
      compare_probe_table(active_family())
    }, striped = TRUE, bordered = FALSE, spacing = "s", rownames = FALSE)

    output$keep_controls <- renderUI({
      plot_label <- if (identical(active_family_id(), "context")) {
        "Current context overview"
      } else {
        "Current plot"
      }
      checkboxGroupInput(
        session$ns("keep_items"),
        label = NULL,
        choices = stats::setNames(
          c("plot", "table"),
          c(plot_label, "Compact comparison table")
        ),
        selected = compare_or(input$keep_items, character())
      )
    })

    output$table_note <- renderUI({
      family <- active_family()
      if (!family$compatible) return(NULL)
      zero_extinctions <- all(
        family$evidence$summary$extinction_probability == 0
      )
      div(
        class = "compare-table-note",
        icon("circle-info"),
        span(
          if (zero_extinctions) {
            paste(
              "No extinctions occurred in 1,000 simulated futures under these",
              "settings; this does not prove extinction is impossible."
            )
          } else {
            paste(
              "The 100-pair threshold is a shared working warning level, not a",
              "universal minimum viable population or proven tipping point."
            )
          }
        )
      )
    })

    output$keep_count <- renderText({
      count <- length(compare_or(input$keep_items, character()))
      if (count == 0L) {
        "No evidence selected yet"
      } else {
        paste0(
          count,
          if (count == 1L) {
            " item selected for this comparison note"
          } else {
            " items selected for this comparison note"
          }
        )
      }
    })

    output$library_results <- renderUI({
      library <- compare_run_library()
      search <- tolower(trimws(compare_or(input$library_search, "")))
      type <- compare_or(input$library_type, "all")
      keep <- rep(TRUE, nrow(library))
      if (nzchar(search)) {
        haystack <- tolower(paste(library$label, library$family, library$period))
        keep <- keep & grepl(search, haystack, fixed = TRUE)
      }
      if (!identical(type, "all")) keep <- keep & library$type == type
      library <- library[keep, , drop = FALSE]
      if (nrow(library) == 0L) {
        return(div(
          class = "compare-library-empty",
          "No representative runs match this search."
        ))
      }
      div(
        class = "compare-run-library",
        lapply(seq_len(nrow(library)), function(index) {
          row <- library[index, ]
          tags$article(
            class = paste(
              "compare-run-card",
              if (identical(row$family_id, active_family_id())) "is-active" else ""
            ),
            div(
              span(class = "compare-run-type", row$type),
              if (identical(row$family_id, active_family_id())) {
                span(class = "compare-run-selected", icon("circle-check"), "Active family")
              }
            ),
            h4(row$label),
            p(row$family),
            tags$small(paste(row$period, "|", ifelse(
              row$period == "2019-2024", "5-year check", "75-year future"
            )))
          )
        })
      )
    })

    list(
      family_id = active_family_id,
      family = active_family,
      evidence_selection = reactive(compare_or(input$keep_items, character()))
    )
  })
}
