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

compare_live_evidence <- function(comparison) {
  runs <- comparison$runs
  table <- comparison$table
  labels <- vapply(seq_along(runs), function(index) {
    if (identical(runs[[index]]$scenario_type, "locked_baseline")) {
      "Common future"
    } else {
      runs[[index]]$student_label
    }
  }, character(1))
  summary <- data.frame(
    scenario = labels,
    period = "2025-2100",
    horizon = table$horizon,
    final_median_abundance = table$final_median_abundance,
    final_q025 = table$final_q025,
    final_q975 = table$final_q975,
    extinction_probability = table$extinction_probability,
    warning_probability = table$quasi_extinction_probability,
    crossed_reps = vapply(
      runs,
      function(run) run$quasi_extinction_50_pairs$crossed_reps,
      integer(1)
    ),
    conditional_median_crossing_year =
      table$quasi_extinction_conditional_median_year,
    reps = table$reps,
    stringsAsFactors = FALSE
  )
  abundance <- do.call(rbind, lapply(seq_along(runs), function(index) {
    values <- runs[[index]]$annual_quantiles
    data.frame(
      scenario = labels[[index]],
      projection_year = values$year,
      calendar_year = 2025L + values$year,
      q025 = values$q025,
      median = values$median,
      q975 = values$q975,
      stringsAsFactors = FALSE
    )
  }))
  risk <- do.call(rbind, lapply(seq_along(runs), function(index) {
    values <- runs[[index]]$quasi_extinction_50_pairs$cumulative
    data.frame(
      scenario = labels[[index]],
      projection_year = values$year,
      calendar_year = 2025L + values$year,
      metric = "Fewer than 100 pairs",
      probability = values$probability,
      stringsAsFactors = FALSE
    )
  }))
  starts <- seq.int(1L, 71L, 5L)
  first_passage <- do.call(rbind, lapply(seq_along(runs), function(index) {
    years <- runs[[index]]$quasi_extinction_50_pairs$first_crossing_year
    years <- years[!is.na(years)]
    counts <- vapply(starts, function(start) {
      sum(years >= start & years <= start + 4L)
    }, integer(1))
    data.frame(
      scenario = labels[[index]],
      projection_start = starts,
      projection_end = starts + 4L,
      calendar_start = 2025L + starts,
      calendar_end = 2029L + starts,
      probability = counts / runs[[index]]$reps,
      count = counts,
      stringsAsFactors = FALSE
    )
  }))
  evidence <- list(
    summary = summary,
    abundance = abundance,
    risk = risk,
    first_passage = first_passage
  )
  if (identical(comparison$family_type, "sensitivity")) {
    evidence$response <- investigate_sensitivity_display_data(comparison)
  } else {
    threat <- which(table$scenario_type == "threat")[[1L]]
    managed <- which(table$scenario_type == "intervention")[[1L]]
    evidence$differences <- list(
      comparison = "Management versus the same threat without management",
      final_median_birds = table$final_median_abundance[[managed]] -
        table$final_median_abundance[[threat]],
      extinction_percentage_points = 100 * (
        table$extinction_probability[[managed]] -
          table$extinction_probability[[threat]]
      ),
      warning_percentage_points = 100 * (
        table$quasi_extinction_probability[[managed]] -
          table$quasi_extinction_probability[[threat]]
      )
    )
  }
  evidence
}

compare_live_family <- function(comparison) {
  sensitivity <- identical(comparison$family_type, "sensitivity")
  runs <- comparison$runs
  if (sensitivity) {
    factor_id <- investigate_sensitivity_factor_id(comparison)
    model <- investigate_sensitivity_factor_model(factor_id)
    label <- model$label
    question <- model$question
    purpose <- model$intro
    held_constant <- paste(
      "Every model setting except",
      tolower(model$input_label),
      "and its linked biological process."
    )
    roles <- c("No-change setting", "Higher setting", "Lower setting")
  } else {
    threat_label <- runs[[which(vapply(
      runs,
      function(run) identical(run$scenario_type, "threat"),
      logical(1)
    ))[[1L]]]]$student_label
    managed_label <- runs[[which(vapply(
      runs,
      function(run) identical(run$scenario_type, "intervention"),
      logical(1)
    ))[[1L]]]]$student_label
    label <- paste(threat_label, "and management")
    question <- paste(
      "How does", tolower(threat_label),
      "change the outlook, and how much does management recover?"
    )
    purpose <- paste(
      "Compare the threat with the common future, then compare",
      tolower(managed_label), "with that same threatened future."
    )
    held_constant <- paste(
      "Starting population, horizon, simulation effort and all assumptions",
      "outside the stated threat and response."
    )
    roles <- c("No-change reference", "Threatened future", "Managed future")
  }
  list(
    id = comparison$family_id,
    group = if (sensitivity) "Sensitivity" else "Threat and management",
    label = label,
    question = question,
    purpose = purpose,
    compatible = TRUE,
    compatibility_title = "Direct comparison",
    compatibility = paste(
      "These runs share the same 2025 starting population, 75-year horizon,",
      "1,000 simulated futures and one comparison family."
    ),
    held_constant = held_constant,
    scenario_roles = roles,
    evidence = compare_live_evidence(comparison)
  )
}

compare_live_catalog <- function(project) {
  if (is.null(project) || !is.list(project$runs) || length(project$runs) == 0L) {
    return(list())
  }
  family_ids <- unique(vapply(project$runs, `[[`, character(1), "family_id"))
  values <- lapply(family_ids, function(family_id) {
    comparison <- tryCatch(
      investigate_project_comparison(project, family_id),
      error = function(...) NULL
    )
    if (is.null(comparison) || length(comparison$runs) != 3L) return(NULL)
    types <- vapply(comparison$runs, `[[`, character(1), "scenario_type")
    expected <- if (identical(comparison$family_type, "sensitivity")) {
      c("locked_baseline", "sensitivity", "sensitivity")
    } else {
      c("locked_baseline", "threat", "intervention")
    }
    if (!identical(types, expected)) return(NULL)
    list(
      comparison = comparison,
      family = compare_live_family(comparison)
    )
  })
  keep <- !vapply(values, is.null, logical(1))
  values <- values[keep]
  names(values) <- family_ids[keep]
  values
}

compare_live_choices <- function(catalog) {
  if (length(catalog) == 0L) {
    return(list("Context only" = c(
      "Recovery check beside future outlook" = "context"
    )))
  }
  groups <- split(
    names(catalog),
    vapply(catalog, function(entry) entry$family$group, character(1))
  )
  lapply(groups, function(ids) {
    stats::setNames(
      ids,
      vapply(catalog[ids], function(entry) entry$family$label, character(1))
    )
  })
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
  if (nrow(data) == 0L) {
    return(
      ggplot2::ggplot() +
        ggplot2::annotate(
          "text",
          x = 2062.5,
          y = 0.5,
          label = paste(
            "None of the simulated futures first crossed",
            "below 100 pairs under these settings."
          ),
          colour = "#526768",
          size = 4.2
        ) +
        ggplot2::scale_x_continuous(limits = c(2025, 2100)) +
        ggplot2::scale_y_continuous(limits = c(0, 1)) +
        ggplot2::labs(
          title = "First passage below 100 pairs",
          x = "Calendar year",
          y = NULL
        ) +
        compare_plot_theme() +
        ggplot2::theme(
          axis.text.y = ggplot2::element_blank(),
          axis.ticks.y = ggplot2::element_blank()
        )
    )
  }
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

compare_run_library <- function(project, catalog = compare_live_catalog(project)) {
  if (length(catalog) == 0L) {
    return(data.frame(
      family_id = character(),
      type = character(),
      label = character(),
      period = character(),
      family = character(),
      stringsAsFactors = FALSE
    ))
  }
  do.call(rbind, lapply(catalog, function(entry) {
    runs <- entry$comparison$runs
    data.frame(
      family_id = entry$comparison$family_id,
      type = entry$family$group,
      label = vapply(runs, function(run) {
        if (identical(run$scenario_type, "locked_baseline")) {
          "Common future"
        } else {
          run$student_label
        }
      }, character(1)),
      period = "2025-2100",
      family = entry$family$label,
      stringsAsFactors = FALSE
    )
  }))
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
      "Choose a completed matched comparison here, then add its current plot,",
      "table, or a note to the Evidence Portfolio from the main Compare page."
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
          "and save any useful plots, tables, or notes to your Evidence Portfolio."
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
        uiOutput(ns("family_control")),
        p(
          "Completed matched families from Investigate appear here. The run",
          "library helps you revisit their individual scenarios."
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
              h3("Add evidence to your portfolio")
            ),
            actionButton(
              ns("add_plot"),
              "Add current plot to Evidence Portfolio",
              icon = icon("chart-line"),
              class = "btn-default btn-sm"
            ),
            actionButton(
              ns("add_table"),
              "Add comparison table to Evidence Portfolio",
              icon = icon("table"),
              class = "btn-default btn-sm"
            )
          ),
          p(
            "Add anything that may help your investigation. You can inspect,",
            "order, and export it later without narrowing the collection here."
          ),
          textOutput(ns("portfolio_status"), inline = TRUE)
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
      span(class = "workspace-label", "Interpret while you investigate"),
      h2("Record the claim and its boundary"),
      p(
        "These prompts are optional. Recording an interpretation and a caveat",
        "now can make the comparison easier to understand when you return later."
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
        "Add note to Evidence Portfolio",
        icon = icon("note-sticky"),
        class = "btn-default"
      ),
      textOutput(ns("note_status"), inline = TRUE)
    )
  )
}

compare_server <- function(id, project = NULL) {
  moduleServer(id, function(input, output, session) {
    event_counter <- reactiveVal(0L)
    portfolio_event <- reactiveVal(NULL)
    portfolio_status <- reactiveVal(
      "Choose an action to add evidence to your portfolio."
    )
    note_status <- reactiveVal("")
    registered_library_families <- new.env(parent = emptyenv())
    project_value <- reactive({
      if (is.function(project)) project() else project
    })
    live_catalog <- reactive({
      compare_live_catalog(project_value())
    })
    active_family_id <- reactive({
      available <- names(live_catalog())
      requested <- compare_or(input$family, NULL)
      if (!is.null(requested) && requested %in% c(available, "context")) {
        return(requested)
      }
      if (length(available)) available[[1L]] else "context"
    })
    active_entry <- reactive({
      if (identical(active_family_id(), "context")) return(NULL)
      live_catalog()[[active_family_id()]]
    })
    active_family <- reactive({
      entry <- active_entry()
      if (is.null(entry)) compare_probe_family("context") else entry$family
    })
    publish_portfolio <- function(kind, title, view_id, note = NULL) {
      candidate <- project_value()
      entry <- active_entry()
      if (is.null(candidate) || is.null(entry)) {
        return(FALSE)
      }
      run_ids <- vapply(entry$comparison$runs, `[[`, character(1), "run_id")
      n <- shiny::isolate(event_counter()) + 1L
      event_counter(n)
      portfolio_event(list(
        ok = TRUE,
        action = "add",
        kind = kind,
        source_family_id = entry$comparison$family_id,
        source_run_ids = run_ids,
        view_id = view_id,
        title = title,
        note = note,
        base_project_fingerprint = candidate$project_fingerprint,
        event_id = n,
        message = paste(title, "added to the Evidence Portfolio.")
      ))
      portfolio_status(paste(title, "sent to the portfolio."))
      TRUE
    }

    output$family_control <- renderUI({
      choices <- compare_live_choices(live_catalog())
      selectInput(
        session$ns("family"),
        "Active comparison",
        choices = choices,
        selected = active_family_id()
      )
    })

    observeEvent(input$open_help, {
      showModal(compare_help_modal())
    })
    observeEvent(input$open_library, {
      showModal(compare_run_library_modal(session$ns))
    })
    observeEvent(live_catalog(), {
      family_ids <- names(live_catalog())
      new_ids <- family_ids[!vapply(
        family_ids,
        exists,
        logical(1),
        envir = registered_library_families,
        inherits = FALSE
      )]
      lapply(new_ids, function(value) {
        local({
          family_id <- value
          input_id <- paste0(
            "select_family_",
            gsub("[^A-Za-z0-9_-]", "_", family_id)
          )
          registered_library_families[[family_id]] <- TRUE
          observeEvent(input[[input_id]], {
            updateSelectInput(
              session,
              "family",
              selected = family_id
            )
            removeModal()
          }, ignoreInit = TRUE)
        })
      })
    }, ignoreInit = FALSE)
    observeEvent(input$add_plot, {
      view <- compare_or(input$view, "population")
      view_choices <- compare_view_choices(active_family_id())
      view_label <- names(view_choices)[match(view, unname(view_choices))]
      title <- paste(active_family()$label, "-", view_label)
      if (!publish_portfolio("plot", title, view)) {
        showNotification(
          "Complete a matched family in Investigate before adding this plot.",
          type = "warning"
        )
      }
    })
    observeEvent(input$add_table, {
      title <- paste(active_family()$label, "- comparison table")
      if (!publish_portfolio("table", title, "comparison_table")) {
        showNotification(
          "Complete a matched family in Investigate before adding this table.",
          type = "warning"
        )
      }
    })
    observeEvent(input$save_reasoning, {
      interpretation <- trimws(compare_or(input$interpretation, ""))
      caveat <- trimws(compare_or(input$caveat, ""))
      if (!nzchar(interpretation) && !nzchar(caveat)) {
        note_status("Add an interpretation or caveat before saving a note.")
        return()
      }
      title <- paste(active_family()$label, "- comparison note")
      saved <- publish_portfolio(
        "observation",
        title,
        "comparison_note",
        paste(
          c(
            if (nzchar(interpretation)) {
              paste("Interpretation:", interpretation)
            },
            if (nzchar(caveat)) paste("Caveat:", caveat)
          ),
          collapse = "\n"
        )
      )
      if (saved) {
        note_status("Note sent to the Evidence Portfolio.")
      } else {
        note_status("Complete a matched family before saving this note.")
      }
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
      if (identical(family$group, "Sensitivity")) {
        investigate_sensitivity_probe_plot(family$evidence$response)
      } else {
        compare_management_response_plot(family$evidence)
      }
    }, res = 96)

    output$comparison_table <- renderTable({
      compare_probe_table(active_family())
    }, striped = TRUE, bordered = FALSE, spacing = "s", rownames = FALSE)

    output$portfolio_status <- renderText(portfolio_status())

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

    output$note_status <- renderText(note_status())

    output$library_results <- renderUI({
      library <- compare_run_library(project_value(), live_catalog())
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
          "No completed matched project runs match this search."
        ))
      }
      first_for_family <- !duplicated(library$family_id)
      div(
        class = "compare-run-library",
        lapply(seq_len(nrow(library)), function(index) {
          row <- library[index, ]
          active <- identical(row$family_id, active_family_id())
          input_id <- paste0(
            "select_family_",
            gsub("[^A-Za-z0-9_-]", "_", row$family_id)
          )
          tags$article(
            class = paste(
              "compare-run-card",
              if (active) "is-active" else ""
            ),
            div(
              span(class = "compare-run-type", row$type),
              if (active) {
                span(class = "compare-run-selected", icon("circle-check"), "Active family")
              }
            ),
            h4(row$label),
            p(row$family),
            tags$small(paste(row$period, "|", "part of one matched comparison")),
            if (first_for_family[[index]] && !active) {
              actionButton(
                session$ns(input_id),
                "Use this comparison",
                icon = icon("arrow-right"),
                class = "btn-default btn-sm"
              )
            }
          )
        })
      )
    })

    list(
      family_id = active_family_id,
      family = active_family,
      portfolio_event = reactive(portfolio_event())
    )
  })
}
