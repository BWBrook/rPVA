investigate_or <- function(value, default) {
  if (is.null(value) || length(value) == 0L) default else value
}

investigate_catalog_row <- function(catalog, id, label) {
  row <- catalog[catalog$id == id, , drop = FALSE]
  if (nrow(row) != 1L) {
    stop("Choose one valid ", label, ".", call. = FALSE)
  }
  row
}

investigate_control_step <- function(range) {
  if (range[["max"]] > 2) 1 else 0.01
}

investigate_choice_value <- function(choice, custom, row, label) {
  if (!is.character(choice) || length(choice) != 1L || is.na(choice)) {
    stop("Choose one ", label, " setting.", call. = FALSE)
  }
  value <- if (identical(choice, "custom")) custom else choice
  rPVA:::woodhen_resolve_bounded_value(value, row, label = label)
}

investigate_sensitivity_values <- function(factor_id,
                                           first_choice,
                                           second_choice,
                                           first_custom,
                                           second_custom) {
  row <- investigate_catalog_row(
    rPVA::woodhen_sensitivity_catalog(), factor_id, "sensitivity factor"
  )
  values <- c(
    investigate_choice_value(first_choice, first_custom, row, "first altered setting"),
    investigate_choice_value(second_choice, second_custom, row, "second altered setting")
  )
  baseline <- row$locked_baseline[[1L]]
  if (any(values == baseline)) {
    stop(
      "Alternative settings must differ from the current no-change assumption.",
      call. = FALSE
    )
  }
  if (anyDuplicated(values)) {
    stop("Choose two different alternative settings.", call. = FALSE)
  }
  rPVA::build_woodhen_sensitivity_family(factor_id, values, seed = 123L)
  values
}

investigate_compatible_interventions <- function(threat_id) {
  investigate_catalog_row(rPVA::woodhen_threat_catalog(), threat_id, "threat")
  catalog <- rPVA::woodhen_intervention_catalog()
  compatible <- vapply(catalog$id, function(intervention_id) {
    config <- list(list(
      intervention_id = intervention_id,
      intensity = "moderate"
    ))
    names(config) <- "management"
    !inherits(try(
      rPVA::build_woodhen_prospective_family(threat_id, config, seed = 123L),
      silent = TRUE
    ), "try-error")
  }, logical(1))
  catalog$id[compatible]
}

investigate_build_future_family <- function(threat_id,
                                            threat_choice,
                                            threat_custom,
                                            intervention_id,
                                            intervention_choice,
                                            intervention_custom) {
  threat_row <- investigate_catalog_row(
    rPVA::woodhen_threat_catalog(), threat_id, "threat"
  )
  if (!is.character(intervention_id) || length(intervention_id) != 1L ||
      is.na(intervention_id) || !nzchar(intervention_id)) {
    stop("Choose one compatible intervention; no-intervention is not a core route.", call. = FALSE)
  }
  compatible <- investigate_compatible_interventions(threat_id)
  if (!intervention_id %in% compatible) {
    stop("The selected intervention is not compatible with this threat.", call. = FALSE)
  }
  intervention_row <- investigate_catalog_row(
    rPVA::woodhen_intervention_catalog(), intervention_id, "intervention"
  )
  threat_value <- investigate_choice_value(
    threat_choice, threat_custom, threat_row, "threat intensity"
  )
  intervention_value <- investigate_choice_value(
    intervention_choice, intervention_custom, intervention_row,
    "intervention intensity"
  )
  sea_level <- identical(threat_id, "sea_level_rise_pathway")
  threat <- list(
    threat_id = threat_id,
    intensity = threat_value,
    temporal_shape = if (sea_level) "linear" else "step",
    onset_year = 1L,
    end_year = if (sea_level) 75L else 1L
  )
  intervention <- list(management = list(
    intervention_id = intervention_id,
    intensity = intervention_value
  ))
  rPVA::build_woodhen_prospective_family(
    threat = threat,
    interventions = intervention,
    seed = 123L
  )
}

investigate_begin_batch <- function(busy) {
  if (isTRUE(busy())) return(FALSE)
  busy(TRUE)
  TRUE
}

investigate_family_key <- function(family_id, family_type) {
  catalog_ids <- if (identical(family_type, "sensitivity")) {
    rPVA::woodhen_sensitivity_catalog()$id
  } else {
    rPVA::woodhen_threat_catalog()$id
  }
  prefix <- paste0(family_type, "_", catalog_ids, "_")
  suffix <- substring(family_id, nchar(prefix) + 1L)
  match_index <- which(
    startsWith(family_id, prefix) &
      nchar(suffix) == 12L & grepl("^[0-9a-f]{12}$", suffix)
  )
  if (length(match_index) == 1L) catalog_ids[[match_index]] else NA_character_
}

investigate_sensitivity_factor_id <- function(comparison) {
  sensitivity_runs <- comparison$runs[vapply(comparison$runs, function(run) {
    identical(run$scenario_type, "sensitivity")
  }, logical(1))]
  component_ids <- unique(unlist(lapply(sensitivity_runs, function(run) {
    names(run$scenario$components)
  }), use.names = FALSE))
  catalog <- rPVA::woodhen_sensitivity_catalog()
  catalog_components <- vapply(
    catalog$mapping,
    function(mapping) names(mapping)[[1L]],
    character(1)
  )
  matches <- match(component_ids, catalog_components)
  if (length(component_ids) != 1L || anyNA(matches)) {
    stop("A restored sensitivity family has no exact catalogue component.", call. = FALSE)
  }
  catalog$id[[matches[[1L]]]]
}

investigate_completed_family_ids <- function(project, family_type) {
  if (is.null(project) || !is.list(project$runs) || length(project$runs) == 0L) {
    return(character())
  }
  ids <- unique(vapply(project$runs, `[[`, character(1), "family_id"))
  ids[vapply(ids, function(family_id) {
    runs <- project$runs[vapply(project$runs, function(run) {
      identical(run$family_id, family_id)
    }, logical(1))]
    types <- vapply(runs, `[[`, character(1), "scenario_type")
    if (identical(family_type, "sensitivity")) {
      identical(types, c("locked_baseline", "sensitivity", "sensitivity"))
    } else {
      length(types) >= 3L && identical(types[1:3], c(
        "locked_baseline", "threat", "intervention"
      ))
    }
  }, logical(1))]
}

investigate_latest_family_id <- function(project, family_type) {
  ids <- investigate_completed_family_ids(project, family_type)
  if (length(ids) == 0L) NULL else tail(ids, 1L)
}

investigate_project_comparison <- function(project, family_id) {
  if (is.null(project) || is.null(family_id)) return(NULL)
  runs <- project$runs[vapply(project$runs, function(run) {
    identical(run$family_id, family_id)
  }, logical(1))]
  if (length(runs) < 3L) return(NULL)
  rPVA::compare_woodhen_run_family(runs, family_id)
}

investigate_restored_controls <- function(project) {
  sensitivity_id <- investigate_latest_family_id(project, "sensitivity")
  prospective_id <- investigate_latest_family_id(project, "prospective")
  sensitivity <- investigate_project_comparison(project, sensitivity_id)
  prospective <- investigate_project_comparison(project, prospective_id)

  sensitivity_state <- NULL
  if (!is.null(sensitivity)) {
    factor_id <- investigate_sensitivity_factor_id(sensitivity)
    row <- investigate_catalog_row(
      rPVA::woodhen_sensitivity_catalog(), factor_id, "sensitivity factor"
    )
    values <- unname(sensitivity$table$setting_value[-1L])
    sensitivity_state <- list(
      family_id = sensitivity_id,
      factor_id = factor_id,
      values = values,
      choices = unname(vapply(
        values, investigate_named_choice, character(1),
        anchors = row$anchors[[1L]]
      ))
    )
  }

  future_state <- NULL
  if (!is.null(prospective)) {
    threat_id <- investigate_family_key(prospective_id, "prospective")
    threat_run <- prospective$runs[[which(
      prospective$table$scenario_type == "threat"
    )[[1L]]]]
    intervention_run <- prospective$runs[[which(
      prospective$table$scenario_type == "intervention"
    )[[1L]]]]
    threat_value <- as.numeric(threat_run$scenario$components[[1L]]$value)
    direct_names <- names(intervention_run$scenario$components)
    direct_names <- direct_names[!startsWith(direct_names, "threat__")]
    if (length(direct_names) == 0L) {
      stop("A restored intervention family has no direct intervention component.", call. = FALSE)
    }
    intervention_id <- intervention_run$scenario$intervention_id
    intervention_value <- as.numeric(
      intervention_run$scenario$components[[direct_names[[1L]]]]$value
    )
    threat_row <- investigate_catalog_row(
      rPVA::woodhen_threat_catalog(), threat_id, "threat"
    )
    intervention_row <- investigate_catalog_row(
      rPVA::woodhen_intervention_catalog(), intervention_id, "intervention"
    )
    future_state <- list(
      family_id = prospective_id,
      threat_id = threat_id,
      threat_value = threat_value,
      threat_choice = investigate_named_choice(
        threat_value, threat_row$anchors[[1L]]
      ),
      intervention_id = intervention_id,
      intervention_value = intervention_value,
      intervention_choice = investigate_named_choice(
        intervention_value, intervention_row$anchors[[1L]]
      )
    )
  }
  list(sensitivity = sensitivity_state, future = future_state)
}

investigate_named_choice <- function(value, anchors) {
  matches <- names(anchors)[anchors == value]
  if (length(matches)) matches[[1L]] else "custom"
}

investigate_format_number <- function(value, digits = 3L) {
  format(round(value, digits), trim = TRUE, big.mark = ",", scientific = FALSE)
}

investigate_format_probability <- function(value) {
  sprintf("%.1f%%", 100 * value)
}

investigate_format_timing <- function(value, overall = FALSE) {
  if (is.na(value)) {
    if (overall) "Overall median not reached" else "No crossing futures"
  } else {
    paste0(investigate_format_number(value, 1L), " years")
  }
}

investigate_sensitivity_probe_data <- function() {
  data.frame(
    setting_value = c(325, 225, 160),
    setting_label = c(
      "Current no-change assumption",
      "225 breeding territories",
      "160 breeding territories"
    ),
    final_median_abundance = c(2163, 1502, 1055),
    final_q025 = c(1580, 986, 606),
    final_q975 = c(2884, 2068, 1528),
    extinction_probability = c(0, 0, 0),
    quasi_extinction_probability = c(0, 0, 0.064),
    quasi_extinction_conditional_median_year = c(NA, NA, 39),
    reps = c(1000L, 1000L, 1000L),
    stringsAsFactors = FALSE
  )
}

investigate_sensitivity_display_data <- function(comparison = NULL) {
  if (is.null(comparison)) return(investigate_sensitivity_probe_data())
  table <- comparison$table
  values <- as.numeric(table$setting_value)
  data.frame(
    setting_value = values,
    setting_label = ifelse(
      table$scenario_type == "locked_baseline",
      "Current no-change assumption",
      paste0(investigate_format_number(values, 0L), " breeding territories")
    ),
    final_median_abundance = table$final_median_abundance,
    final_q025 = table$final_q025,
    final_q975 = table$final_q975,
    extinction_probability = table$extinction_probability,
    quasi_extinction_probability = table$quasi_extinction_probability,
    quasi_extinction_conditional_median_year =
      table$quasi_extinction_conditional_median_year,
    reps = table$reps,
    stringsAsFactors = FALSE
  )
}

investigate_sensitivity_probe_plot <- function(data) {
  data <- data[order(data$setting_value), , drop = FALSE]
  territory_breaks <- sort(unique(data$setting_value))
  abundance_limit <- max(data$final_q975) * 1.08
  percent_labels <- function(values) paste0(round(100 * values), "%")

  abundance <- ggplot2::ggplot(
    data,
    ggplot2::aes(x = setting_value, y = final_median_abundance)
  ) +
    ggplot2::geom_errorbar(
      ggplot2::aes(ymin = final_q025, ymax = final_q975),
      width = 8,
      linewidth = 0.8,
      colour = "#4a7779"
    ) +
    ggplot2::geom_line(linewidth = 0.9, colour = "#006d77") +
    ggplot2::geom_point(size = 3.1, colour = "#006d77") +
    ggplot2::scale_x_continuous(breaks = territory_breaks) +
    ggplot2::scale_y_continuous(
      limits = c(0, abundance_limit),
      labels = function(values) format(round(values), big.mark = ",", scientific = FALSE)
    ) +
    ggplot2::labs(
      title = "Final abundance in 2100",
      subtitle = "Median and 95% simulation interval",
      x = "Breeding territories available",
      y = "Number of birds"
    ) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(face = "bold")
    )

  risk <- ggplot2::ggplot(
    data,
    ggplot2::aes(x = setting_value, y = quasi_extinction_probability)
  ) +
    ggplot2::geom_line(linewidth = 0.9, colour = "#b23a48") +
    ggplot2::geom_point(size = 3.1, colour = "#b23a48") +
    ggplot2::geom_text(
      ggplot2::aes(label = sprintf("%.1f%%", 100 * quasi_extinction_probability)),
      vjust = -0.8,
      size = 3.8,
      colour = "#7d2631"
    ) +
    ggplot2::scale_x_continuous(breaks = territory_breaks) +
    ggplot2::scale_y_continuous(
      limits = c(0, 1),
      breaks = seq(0, 1, 0.2),
      labels = percent_labels,
      expand = ggplot2::expansion(mult = c(0, 0.03))
    ) +
    ggplot2::labs(
      title = "Risk of falling below 50 pairs",
      subtitle = "Probability at any time from 2025 to 2100",
      x = "Breeding territories available",
      y = "Probability"
    ) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(face = "bold")
    )

  patchwork::wrap_plots(abundance, risk, widths = c(1.12, 1)) +
    patchwork::plot_annotation(
      title = "How breeding-territory capacity changes future outcomes",
      caption = paste(
        "Only breeding-territory capacity changes; each setting uses",
        "1,000 simulated futures."
      ),
      theme = ggplot2::theme(
        plot.title = ggplot2::element_text(size = 15, face = "bold"),
        plot.caption = ggplot2::element_text(colour = "#4f5d5d")
      )
    )
}

investigate_sensitivity_probe_table <- function(data) {
  crossing_text <- vapply(seq_len(nrow(data)), function(index) {
    year <- data$quasi_extinction_conditional_median_year[[index]]
    count <- round(data$quasi_extinction_probability[[index]] * data$reps[[index]])
    if (is.na(year) || count == 0L) return("Not observed in these futures")
    paste0(
      "Around ", 2025 + round(year), " among the ", count,
      " futures that crossed"
    )
  }, character(1))
  data.frame(
    Setting = data$setting_label,
    `Final birds in 2100 (95% interval)` = paste0(
      investigate_format_number(data$final_median_abundance, 0L), " (",
      investigate_format_number(data$final_q025, 0L), " - ",
      investigate_format_number(data$final_q975, 0L), ")"
    ),
    `Extinction by 2100` = investigate_format_probability(
      data$extinction_probability
    ),
    `Below 50 pairs by 2100` = investigate_format_probability(
      data$quasi_extinction_probability
    ),
    `When the 50-pair threshold was crossed` = crossing_text,
    check.names = FALSE
  )
}

investigate_mapping_text <- function(row) {
  mapping <- row$mapping[[1L]][[1L]]
  stages <- mapping$affected_stages
  stage_text <- if (is.numeric(stages)) {
    paste(stages, collapse = ", ")
  } else {
    paste(stages, collapse = ", ")
  }
  paste0(
    paste(mapping$affected_fields, collapse = ", "),
    " | stages: ", stage_text,
    " | operation: ", mapping$operator
  )
}

investigate_help_modal <- function() {
  modalDialog(
    title = "How to use sensitivity analysis",
    div(
      class = "help-modal-content",
      render_markdown_content(file.path(
        practical2_app_dir, "content", "help-sensitivity.md"
      ))
    ),
    footer = modalButton("Close"),
    easyClose = TRUE,
    size = "m"
  )
}

investigate_prompt_inputs <- function(ns, prefix) {
  if (identical(prefix, "sensitivity")) {
    return(tagList(
      textAreaInput(
        ns("sensitivity_research_question"),
        "What are you testing? (optional)",
        rows = 2,
        placeholder = paste(
          "For example: How does reducing breeding-territory capacity affect",
          "projected abundance and the chance of falling below 50 breeding pairs?"
        )
      ),
      textAreaInput(
        ns("sensitivity_expected_direction"),
        "Your prediction and reasoning (optional)",
        rows = 2,
        placeholder = paste(
          "Which outcome do you expect to change: final abundance, 50-pair risk,",
          "or both? State the direction and explain how access to breeding",
          "territories could produce it."
        )
      )
    ))
  }
  tagList(
    textAreaInput(
      ns(paste0(prefix, "_research_question")),
      "Optional research question",
      rows = 2
    ),
    textAreaInput(
      ns(paste0(prefix, "_biological_reason")),
      "Optional biological reason",
      rows = 2
    ),
    textAreaInput(
      ns(paste0(prefix, "_expected_direction")),
      "Optional expected direction",
      rows = 2
    )
  )
}

investigate_result_prompts <- function(ns, prefix, design_probe = FALSE) {
  save_button <- actionButton(
    ns(paste0("save_", prefix, "_notes")),
    if (identical(prefix, "sensitivity")) {
      "Save observation to project"
    } else {
      "Save result observations"
    },
    icon = icon("note-sticky"),
    class = "btn-default btn-sm"
  )
  if (design_probe) {
    save_button <- tagAppendAttributes(
      save_button,
      disabled = "disabled",
      `aria-disabled` = "true"
    )
  }
  div(
    class = "investigate-result-prompts",
    textAreaInput(
      ns(paste0(prefix, "_interpretation")),
      if (identical(prefix, "sensitivity")) {
        "What did the simulations show, and why? (optional)"
      } else {
        "Optional interpretation"
      },
      rows = 2,
      placeholder = if (identical(prefix, "sensitivity")) {
        paste(
          "Describe the pattern across the three territory settings, including",
          "uncertainty and 50-pair risk. Then explain which conclusion appears",
          "sensitive to habitat capacity and which appears robust."
        )
      } else {
        NULL
      }
    ),
    textAreaInput(
      ns(paste0(prefix, "_caveat")),
      if (identical(prefix, "sensitivity")) {
        "What limits this conclusion? (optional)"
      } else {
        "Optional caveat"
      },
      rows = 2,
      placeholder = if (identical(prefix, "sensitivity")) {
        paste(
          "Identify one assumption, uncertainty or omitted process that limits",
          "how confidently this result could guide management."
        )
      } else {
        NULL
      }
    ),
    save_button
  )
}

investigate_disable_run_actions_js <- function(ns) {
  ids <- paste0('"', c(ns("run_sensitivity"), ns("run_future")), '"')
  paste0(
    "[", paste(ids, collapse = ","), "].forEach(function(id){",
    "var button=document.getElementById(id);",
    "if(button){button.disabled=true;",
    "button.setAttribute('aria-disabled','true');}});"
  )
}

investigate_run_action <- function(ns, route, busy, design_probe = FALSE) {
  is_sensitivity <- identical(route, "sensitivity")
  button <- actionButton(
    ns(if (is_sensitivity) "run_sensitivity" else "run_future"),
    if (is_sensitivity) "Run sensitivity comparison" else "Run threat-intervention family",
    icon = icon("play"),
    class = "btn-primary investigate-run-action",
    onclick = investigate_disable_run_actions_js(ns),
    `aria-disabled` = if (busy || design_probe) "true" else "false"
  )
  if (busy || design_probe) {
    tagAppendAttributes(button, disabled = "disabled")
  } else {
    button
  }
}

investigate_ui <- function(id) {
  ns <- NS(id)

  div(
    class = "page-shell investigate-shell",
    tags$header(
      class = "investigate-header",
      div(
        span(class = "section-eyebrow", "Phase 2: Advise from the present"),
        h1("Test an uncertain ecological assumption"),
        p(
          "Sensitivity analysis asks whether your conclusion changes when one",
          "plausible assumption changes and the rest of the future stays the same."
        )
      ),
      actionButton(
        ns("open_investigate_help"),
        "Sensitivity guide",
        icon = icon("circle-info"),
        class = "btn-default btn-sm"
      )
    ),
    div(
      class = "investigate-anchor-band",
      uiOutput(ns("anchor_status"), `aria-live` = "polite", `aria-atomic` = "true"),
      conditionalPanel(
        condition = sprintf("output['%s'] !== true", ns("anchor_ready")),
        actionButton(
          ns("go_calibrate"),
          "Go to Calibrate",
          icon = icon("arrow-left"),
          class = "btn-primary"
        )
      )
    ),
    tags$section(
      class = "sensitivity-purpose-band",
      `aria-labelledby` = ns("sensitivity_question_heading"),
      span(class = "workspace-label", "Sensitivity question"),
      h2(
        id = ns("sensitivity_question_heading"),
        "How strongly does future Woodhen status depend on breeding habitat?"
      ),
      p(
        "The no-change future assumes Lord Howe Island can support 325",
        "territory-holding breeding pairs. Compare that assumption with two",
        "lower capacities and ask whether the conservation outlook changes."
      ),
      div(
        class = "sensitivity-fair-comparison",
        div(
          class = "sensitivity-comparison-item is-changed",
          icon("sliders"),
          div(
            strong("What changes"),
            span("Only the number of breeding territories available.")
          )
        ),
        div(
          class = "sensitivity-comparison-item",
          icon("lock"),
          div(
            strong("What stays the same"),
            span(paste(
              "The 2025 starting population, vital rates, environmental and",
              "catastrophe settings, 75 years, and 1,000 simulated futures."
            ))
          )
        )
      ),
      p(
        class = "sensitivity-territory-note",
        strong("Important: "),
        "breeding-territory capacity limits territory holders, not every bird.",
        "Young and non-territory-holding birds remain in the total abundance,",
        "so bird numbers can be much higher than the number of territories."
      )
    ),
    tags$section(
      class = "sensitivity-workspace",
      `aria-labelledby` = ns("sensitivity_heading"),
      div(
        class = "sensitivity-workspace-heading",
        div(
          span(class = "workspace-label", "Set up the comparison"),
          h2(id = ns("sensitivity_heading"), "Compare three habitat capacities"),
          p(
            "The current no-change assumption is retained as a reference.",
            "Choose two lower values, then make a prediction before you run."
          )
        ),
        selectInput(
          ns("factor_id"), "Ecological assumption to test",
          choices = c("Breeding-territory capacity" = "K"),
          selected = "K"
        )
      ),
      div(
        class = "sensitivity-setting-grid",
        div(
          class = "sensitivity-setting is-baseline",
          span(class = "setting-kicker", "Current no-change assumption"),
          strong("325"),
          span("breeding territories"),
          tags$small("Kept as the common reference")
        ),
        div(
          class = "sensitivity-setting",
          span(class = "setting-kicker", "Alternative 1"),
          numericInput(
            ns("sensitivity_first_custom"),
            "Breeding territories",
            value = 225, min = 150, max = 750, step = 1
          ),
          tags$small("A 31% reduction from the no-change assumption")
        ),
        div(
          class = "sensitivity-setting",
          span(class = "setting-kicker", "Alternative 2"),
          numericInput(
            ns("sensitivity_second_custom"),
            "Breeding territories",
            value = 160, min = 150, max = 750, step = 1
          ),
          tags$small("About half the no-change capacity")
        )
      ),
      uiOutput(ns("sensitivity_preview")),
      div(
        class = "sensitivity-prediction-band",
        h3("Pause before running: what do you expect?"),
        p(
          "A prediction makes the comparison a test of reasoning, not just a",
          "button press. These notes are optional and can be revised later."
        ),
        div(
          class = "investigate-prompts",
          investigate_prompt_inputs(ns, "sensitivity")
        )
      ),
      div(
        class = "sensitivity-run-band",
        div(
          uiOutput(ns("sensitivity_run_control")),
          p(
            "The comparison runs 1,000 futures for each setting and may take",
            "about a minute. Progress remains visible throughout."
          )
        ),
        uiOutput(ns("sensitivity_progress")),
        uiOutput(
          ns("sensitivity_status"),
          `aria-live` = "polite",
          `aria-atomic` = "true"
        ),
        uiOutput(ns("sensitivity_completion"))
      )
    ),
    tags$section(
      class = "sensitivity-results",
      `aria-labelledby` = ns("sensitivity_results_heading"),
      div(
        class = "sensitivity-results-heading",
        div(
          span(class = "workspace-label", "Read the response"),
          h2(
            id = ns("sensitivity_results_heading"),
            "Look for conclusions that change across the three settings"
          )
        ),
        uiOutput(ns("sensitivity_result_context"))
      ),
      p(
        "The left panel shows how the final population responds. The right",
        "panel asks whether the same change also alters the chance of crossing",
        "the working 50-pair warning threshold."
      ),
      div(
        class = "investigate-threshold-note",
        h3("What does \"below 50 pairs\" mean?"),
        p(
          "In each simulated future, the app records whether the population ever",
          "falls below 50 territory-holding breeding pairs between 2025 and 2100.",
          "In PVA, this is a quasi-extinction threshold: it flags a serious decline",
          "before complete extinction."
        ),
        p(
          "The same working warning level is used across scenarios so their risks",
          "can be compared consistently. It is not a universal minimum viable",
          "population or a proven biological tipping point."
        )
      ),
      div(
        class = "investigate-plot sensitivity-response-plot",
        role = "img",
        `aria-label` = paste(
          "Final abundance and probability of falling below 50 breeding pairs",
          "across three breeding-territory settings"
        ),
        plotOutput(ns("sensitivity_plot"), height = "450px")
      ),
      div(
        class = "sensitivity-table-region",
        h3("Comparison record"),
        p(
          "The timing column describes only those simulated futures that",
          "actually crossed the threshold. It is not a prediction that every",
          "future will cross at that time."
        ),
        div(class = "investigate-table-scroll", tableOutput(ns("sensitivity_table")))
      ),
      div(
        class = "sensitivity-observation-band",
        h3("Record what the comparison means"),
        p(
          "Separate the pattern you observed from a limitation or uncertainty.",
          "That distinction will matter when you turn model output into advice."
        ),
        investigate_result_prompts(ns, "sensitivity")
      )
    )
  )
}

investigate_server <- function(
    id,
    project,
    scenario_runner = rPVA::run_woodhen_investigation_scenario) {
  moduleServer(id, function(input, output, session) {
    busy <- reactiveVal(FALSE)
    project_update_state <- reactiveVal(NULL)
    observation_update_state <- reactiveVal(NULL)
    navigation_state <- reactiveVal(NULL)
    event_counter <- reactiveVal(0L)
    status_state <- reactiveVal(c(
      sensitivity = "Choose two alternative territory capacities, then run the comparison.",
      future = "Choose a threat and compatible intervention."
    ))
    progress_state <- reactiveVal(list(
      sensitivity = c(scenario = 0L, scenarios = 3L, completed = 0L, total = 1000L),
      future = c(scenario = 0L, scenarios = 3L, completed = 0L, total = 1000L)
    ))
    progress_history_state <- reactiveVal(list(sensitivity = list(), future = list()))
    active_sensitivity_family <- reactiveVal(investigate_latest_family_id(
      isolate(project()), "sensitivity"
    ))
    active_future_family <- reactiveVal(investigate_latest_family_id(
      isolate(project()), "prospective"
    ))

    publish <- function(target, value) {
      next_event <- shiny::isolate(event_counter()) + 1L
      event_counter(next_event)
      value$event_id <- next_event
      target(value)
      invisible(value)
    }

    set_status <- function(route, value) {
      status <- shiny::isolate(status_state())
      status[[route]] <- value
      status_state(status)
    }

    release_batch_after_flush <- function() {
      session$onFlushed(function() {
        if (isTRUE(shiny::isolate(busy()))) busy(FALSE)
      }, once = TRUE)
      invisible(NULL)
    }

    set_progress <- function(route, scenario, scenarios, completed, total) {
      progress <- shiny::isolate(progress_state())
      progress[[route]] <- c(
        scenario = as.integer(scenario), scenarios = as.integer(scenarios),
        completed = as.integer(completed), total = as.integer(total)
      )
      progress_state(progress)
      history <- shiny::isolate(progress_history_state())
      history[[route]][[length(history[[route]]) + 1L]] <- progress[[route]]
      progress_history_state(history)
      set_status(route, paste0(
        "Scenario ", scenario, "/", scenarios, ": ",
        format(completed, big.mark = ","), "/", format(total, big.mark = ","),
        " futures completed."
      ))
    }

    project_fingerprint <- reactive({
      candidate <- project()
      if (is.null(candidate)) "no-active-project" else candidate$project_fingerprint
    })

    observeEvent(project_fingerprint(), {
      candidate <- project()
      active_sensitivity_family(investigate_latest_family_id(candidate, "sensitivity"))
      active_future_family(investigate_latest_family_id(candidate, "prospective"))
      progress_history_state(list(sensitivity = list(), future = list()))
      restored <- investigate_restored_controls(candidate)
      if (!is.null(restored$sensitivity)) {
        state <- restored$sensitivity
        updateSelectInput(session, "factor_id", selected = state$factor_id)
        updateSelectInput(session, "sensitivity_first_choice", selected = state$choices[[1L]])
        updateSelectInput(session, "sensitivity_second_choice", selected = state$choices[[2L]])
        updateNumericInput(session, "sensitivity_first_custom", value = state$values[[1L]])
        updateNumericInput(session, "sensitivity_second_custom", value = state$values[[2L]])
      }
      if (!is.null(restored$future)) {
        state <- restored$future
        compatible <- investigate_compatible_interventions(state$threat_id)
        catalog <- rPVA::woodhen_intervention_catalog()
        updateSelectInput(session, "threat_id", selected = state$threat_id)
        updateSelectInput(session, "threat_choice", selected = state$threat_choice)
        updateNumericInput(session, "threat_custom", value = state$threat_value)
        updateSelectInput(
          session, "intervention_id",
          choices = stats::setNames(
            compatible, catalog$label[match(compatible, catalog$id)]
          ),
          selected = state$intervention_id
        )
        updateSelectInput(
          session, "intervention_choice", selected = state$intervention_choice
        )
        updateNumericInput(
          session, "intervention_custom", value = state$intervention_value
        )
      }
    }, ignoreInit = FALSE)

    observeEvent(input$open_investigate_help, {
      showModal(investigate_help_modal())
    })

    observeEvent(input$go_calibrate, {
      publish(navigation_state, list(section = "calibrate"))
    })

    observeEvent(input$factor_id, {
      row <- investigate_catalog_row(
        rPVA::woodhen_sensitivity_catalog(), input$factor_id, "sensitivity factor"
      )
      range <- row$custom_range[[1L]]
      restored <- investigate_restored_controls(project())$sensitivity
      restored_values <- if (!is.null(restored) &&
          identical(restored$factor_id, input$factor_id)) restored$values else NULL
      updateNumericInput(
        session, "sensitivity_first_custom",
        value = investigate_or(restored_values[[1L]], row$anchors[[1L]][["moderate"]]),
        min = range[["min"]], max = range[["max"]],
        step = investigate_control_step(range)
      )
      updateNumericInput(
        session, "sensitivity_second_custom",
        value = investigate_or(restored_values[[2L]], row$anchors[[1L]][["high"]]),
        min = range[["min"]], max = range[["max"]],
        step = investigate_control_step(range)
      )
    }, ignoreInit = FALSE)

    observeEvent(input$threat_id, {
      row <- investigate_catalog_row(rPVA::woodhen_threat_catalog(), input$threat_id, "threat")
      range <- row$custom_range[[1L]]
      restored <- investigate_restored_controls(project())$future
      restored_value <- if (!is.null(restored) &&
          identical(restored$threat_id, input$threat_id)) restored$threat_value else NULL
      updateNumericInput(
        session, "threat_custom",
        value = investigate_or(restored_value, row$anchors[[1L]][["moderate"]]),
        min = range[["min"]], max = range[["max"]],
        step = investigate_control_step(range)
      )
      ids <- investigate_compatible_interventions(input$threat_id)
      catalog <- rPVA::woodhen_intervention_catalog()
      selected <- if (!is.null(restored) &&
          identical(restored$threat_id, input$threat_id) &&
          restored$intervention_id %in% ids) restored$intervention_id else ids[[1L]]
      updateSelectInput(
        session, "intervention_id",
        choices = stats::setNames(ids, catalog$label[match(ids, catalog$id)]),
        selected = selected
      )
    }, ignoreInit = FALSE)

    observeEvent(input$intervention_id, {
      if (is.null(input$intervention_id) || !nzchar(input$intervention_id)) return()
      row <- investigate_catalog_row(
        rPVA::woodhen_intervention_catalog(), input$intervention_id, "intervention"
      )
      range <- row$custom_range[[1L]]
      restored <- investigate_restored_controls(project())$future
      restored_value <- if (!is.null(restored) &&
          identical(restored$intervention_id, input$intervention_id)) {
        restored$intervention_value
      } else {
        NULL
      }
      updateNumericInput(
        session, "intervention_custom",
        value = investigate_or(restored_value, row$anchors[[1L]][["moderate"]]),
        min = range[["min"]], max = range[["max"]],
        step = investigate_control_step(range)
      )
    }, ignoreInit = FALSE)

    output$anchor_ready <- reactive({
      identical(rPVA:::woodhen_locked_anchor_status(project())$status, "ready")
    })
    outputOptions(output, "anchor_ready", suspendWhenHidden = FALSE)

    output$anchor_status <- renderUI({
      anchor <- rPVA:::woodhen_locked_anchor_status(project())
      div(
        class = paste0("anchor-status is-", anchor$status),
        strong(switch(anchor$status,
          ready = "Common future comparison ready",
          stale = "Common future comparison needs to be rerun",
          "Common future comparison not yet run"
        )),
        span(anchor$action)
      )
    })

    output$sensitivity_preview <- renderUI({
      req(input$factor_id)
      row <- investigate_catalog_row(
        rPVA::woodhen_sensitivity_catalog(), input$factor_id, "sensitivity factor"
      )
      values <- tryCatch(investigate_sensitivity_values(
        input$factor_id,
        "custom",
        "custom",
        investigate_or(input$sensitivity_first_custom, row$anchors[[1L]][["moderate"]]),
        investigate_or(input$sensitivity_second_custom, row$anchors[[1L]][["high"]])
      ), error = function(error) error)
      if (inherits(values, "error")) {
        return(div(
          class = "investigate-preview is-invalid",
          icon("triangle-exclamation"),
          strong("Adjust the comparison: "),
          conditionMessage(values)
        ))
      }
      div(
        class = "investigate-preview",
        icon("circle-check"),
        div(
          strong("Fair comparison ready"),
          span(paste0(
            "325, ", investigate_format_number(values[[1L]], 0L), " and ",
            investigate_format_number(values[[2L]], 0L),
            " breeding territories; every other model assumption is unchanged."
          ))
        )
      )
    })

    output$future_preview <- renderUI({
      req(input$threat_id)
      threat <- investigate_catalog_row(rPVA::woodhen_threat_catalog(), input$threat_id, "threat")
      compatible <- investigate_compatible_interventions(input$threat_id)
      intervention_id <- investigate_or(input$intervention_id, compatible[[1L]])
      intervention <- investigate_catalog_row(
        rPVA::woodhen_intervention_catalog(), intervention_id, "intervention"
      )
      threat_value <- tryCatch(investigate_choice_value(
        investigate_or(input$threat_choice, "moderate"),
        investigate_or(input$threat_custom, threat$anchors[[1L]][["moderate"]]),
        threat, "threat intensity"
      ), error = function(error) conditionMessage(error))
      intervention_value <- tryCatch(investigate_choice_value(
        investigate_or(input$intervention_choice, "moderate"),
        investigate_or(input$intervention_custom, intervention$anchors[[1L]][["moderate"]]),
        intervention, "intervention intensity"
      ), error = function(error) conditionMessage(error))
      sea_level <- identical(input$threat_id, "sea_level_rise_pathway")
      div(
        class = "investigate-preview",
        h3(paste(threat$label[[1L]], "then", intervention$label[[1L]])),
        p(threat$biological_meaning[[1L]]),
        p(strong("Threat mapping: "), investigate_mapping_text(threat)),
        p(strong("Threat value: "), as.character(threat_value)),
        p(strong("Threat temporal profile: "), if (sea_level) {
          "Gradual linear habitat-capacity pathway across years 1-75"
        } else {
          "Immediate persistent step from year 1"
        }),
        p(strong("Threat limitation: "), threat$limitation[[1L]]),
        p(intervention$biological_meaning[[1L]]),
        p(strong("Intervention mapping: "), investigate_mapping_text(intervention)),
        p(strong("Intervention value: "), as.character(intervention_value)),
        p(strong("Intervention limitation: "), intervention$limitation[[1L]]),
        p(class = "locked-machinery", "Held constant: starting population | 75 years | 1,000 futures | common age structure")
      )
    })

    output$sensitivity_run_control <- renderUI({
      investigate_run_action(session$ns, "sensitivity", busy())
    })
    output$future_run_control <- renderUI({
      investigate_run_action(session$ns, "future", busy())
    })

    run_route <- function(route, family, prompt, batch_started = FALSE) {
      prompt <- force(prompt)
      if (!batch_started && !investigate_begin_batch(busy)) {
        set_status(route, "A family is already running; the repeated submission was ignored.")
        return(NULL)
      }
      if (batch_started && !isTRUE(shiny::isolate(busy()))) {
        stop("An accepted investigation batch must retain the shared busy guard.", call. = FALSE)
      }
      candidate <- project()
      base_project_fingerprint <- candidate$project_fingerprint
      anchor <- rPVA:::woodhen_locked_anchor_status(candidate)
      if (!identical(anchor$status, "ready")) {
        set_status(route, paste("Run blocked.", anchor$action))
        publish(project_update_state, list(
          ok = FALSE,
          message = paste("Run blocked.", anchor$action),
          base_project_fingerprint = base_project_fingerprint
        ))
        release_batch_after_flush()
        return(NULL)
      }
      progress <- progress_state()
      progress[[route]] <- c(scenario = 0L, scenarios = length(family$scenarios), completed = 0L, total = 1000L)
      progress_state(progress)
      history <- progress_history_state()
      history[[route]] <- list()
      progress_history_state(history)
      set_status(route, "Preparing the complete family in session scratch.")
      session$onFlushed(function() {
        on.exit(release_batch_after_flush(), add = TRUE)
        live_project <- shiny::isolate(project())
        live_project_fingerprint <- if (is.null(live_project)) {
          NULL
        } else {
          live_project$project_fingerprint
        }
        if (!identical(live_project_fingerprint, base_project_fingerprint)) {
          message <- paste(
            "Family run cancelled because the active project changed",
            "before simulation began. No candidate was created."
          )
          set_status(route, message)
          publish(project_update_state, list(
            ok = FALSE,
            message = message,
            base_project_fingerprint = base_project_fingerprint
          ))
          return(NULL)
        }
        action <- withProgress(
          message = if (identical(route, "sensitivity")) {
            "Running sensitivity comparison"
          } else {
            "Running threat-intervention comparison"
          },
          value = 0.01,
          {
            setProgress(
              0.01,
              detail = paste("Preparing", length(family$scenarios), "comparable settings")
            )
            tryCatch(
              rPVA:::woodhen_run_investigation_family_project(
                candidate,
                family,
                prompt = prompt,
                progress = function(scenario, scenarios, completed, total) {
                  set_progress(route, scenario, scenarios, completed, total)
                  overall <- ((scenario - 1L) * total + completed) /
                    (scenarios * total)
                  setProgress(
                    0.02 + 0.96 * overall,
                    detail = paste0(
                      "Setting ", scenario, " of ", scenarios, ": ",
                      format(completed, big.mark = ","), " of ",
                      format(total, big.mark = ","), " futures"
                    )
                  )
                },
                runner = scenario_runner
              ),
              error = function(error) error
            )
          }
        )
        if (inherits(action, "error")) {
          message <- paste(
            "Family run failed; no partial evidence was inserted:",
            conditionMessage(action)
          )
          set_status(route, message)
          publish(project_update_state, list(
            ok = FALSE,
            message = message,
            base_project_fingerprint = base_project_fingerprint
          ))
          return(NULL)
        }
        message <- if (action$reused) {
          "Exact completed family reused; no duplicate scenarios or runs were created."
        } else {
          "Complete family ready for project activation."
        }
        if (action$prompt_saved) {
          message <- paste(message, "The non-empty pre-run prompt was recorded.")
        }
        set_status(route, message)
        publish(project_update_state, list(
          ok = TRUE,
          candidate = action$project,
          family_id = action$family$family_id,
          route = route,
          reused = action$reused,
          message = message,
          base_project_fingerprint = base_project_fingerprint
        ))
        action
      }, once = TRUE)
      invisible(TRUE)
    }

    observeEvent(input$run_sensitivity, {
      if (!investigate_begin_batch(busy)) {
        set_status("sensitivity", "A family is already running; the repeated submission was ignored.")
        return()
      }
      values <- tryCatch(investigate_sensitivity_values(
        input$factor_id,
        "custom",
        "custom",
        input$sensitivity_first_custom,
        input$sensitivity_second_custom
      ), error = function(error) error)
      if (inherits(values, "error")) {
        set_status("sensitivity", conditionMessage(values))
        release_batch_after_flush()
        return()
      }
      family <- tryCatch(
        rPVA::build_woodhen_sensitivity_family(
          input$factor_id, values, seed = 123L
        ),
        error = function(error) error
      )
      if (inherits(family, "error")) {
        set_status("sensitivity", conditionMessage(family))
        release_batch_after_flush()
        return()
      }
      run_route("sensitivity", family, list(
        research_question = investigate_or(input$sensitivity_research_question, ""),
        biological_reason = "",
        expected_direction = investigate_or(input$sensitivity_expected_direction, "")
      ), batch_started = TRUE)
    })

    observeEvent(input$run_future, {
      if (!investigate_begin_batch(busy)) {
        set_status("future", "A family is already running; the repeated submission was ignored.")
        return()
      }
      family <- tryCatch(investigate_build_future_family(
        input$threat_id,
        input$threat_choice,
        input$threat_custom,
        input$intervention_id,
        input$intervention_choice,
        input$intervention_custom
      ), error = function(error) error)
      if (inherits(family, "error")) {
        set_status("future", conditionMessage(family))
        release_batch_after_flush()
        return()
      }
      run_route("future", family, list(
        research_question = investigate_or(input$future_research_question, ""),
        biological_reason = investigate_or(input$future_biological_reason, ""),
        expected_direction = investigate_or(input$future_expected_direction, "")
      ), batch_started = TRUE)
    })

    sensitivity_comparison <- reactive({
      investigate_project_comparison(project(), active_sensitivity_family())
    })
    future_comparison <- reactive({
      investigate_project_comparison(project(), active_future_family())
    })

    completion_state <- reactive({
      list(
        sensitivity = if (is.null(sensitivity_comparison())) FALSE else {
          "Three sensitivity settings available"
        },
        future = if (is.null(future_comparison())) FALSE else {
          "Threat-intervention family complete"
        }
      )
    })

    output$sensitivity_progress <- renderUI({
      state <- progress_state()$sensitivity
      scenario <- as.integer(state[["scenario"]])
      scenarios <- as.integer(state[["scenarios"]])
      per_scenario <- as.integer(state[["total"]])
      completed <- as.integer(state[["completed"]])
      overall_completed <- if (scenario < 1L) {
        0L
      } else {
        (scenario - 1L) * per_scenario + completed
      }
      overall_total <- scenarios * per_scenario
      percent <- round(100 * overall_completed / overall_total)
      first_value <- investigate_or(input$sensitivity_first_custom, 225)
      second_value <- investigate_or(input$sensitivity_second_custom, 160)
      labels <- c(
        "No-change: 325 territories",
        paste0(investigate_format_number(first_value, 0L), " territories"),
        paste0(investigate_format_number(second_value, 0L), " territories")
      )
      step_class <- vapply(seq_len(scenarios), function(index) {
        if (scenario > index || (scenario == index && completed >= per_scenario)) {
          "is-complete"
        } else if (scenario == index && completed < per_scenario) {
          "is-active"
        } else {
          "is-pending"
        }
      }, character(1))
      div(
        class = "investigate-progress",
        div(
          class = "investigate-progress-heading",
          strong(if (scenario < 1L) {
            "Ready to simulate three comparable settings"
          } else if (overall_completed >= overall_total) {
            "Sensitivity comparison complete"
          } else {
            paste0("Simulating setting ", scenario, " of ", scenarios)
          }),
          span(paste0(format(overall_completed, big.mark = ","), " of ",
            format(overall_total, big.mark = ","), " futures"))
        ),
        div(
          class = "investigate-progress-track",
          role = "progressbar",
          `aria-valuemin` = "0",
          `aria-valuemax` = as.character(overall_total),
          `aria-valuenow` = as.character(overall_completed),
          `aria-label` = "Sensitivity comparison simulation progress",
          div(
            class = "investigate-progress-fill",
            style = paste0("width: ", percent, "%")
          )
        ),
        div(
          class = "investigate-progress-steps",
          lapply(seq_along(labels), function(index) {
            span(
              class = paste("investigate-progress-step", step_class[[index]]),
              icon(if (identical(step_class[[index]], "is-complete")) {
                "circle-check"
              } else {
                "circle"
              }),
              labels[[index]]
            )
          })
        )
      )
    })
    output$future_progress <- renderUI({
      state <- progress_state()$future
      div(
        class = "investigate-progress",
        role = "progressbar",
        `aria-valuemin` = "0",
        `aria-valuemax` = as.character(state[["total"]]),
        `aria-valuenow` = as.character(state[["completed"]]),
        `aria-label` = "Future advice family simulation progress",
        paste0(
          "Scenario ", state[["scenario"]], "/", state[["scenarios"]],
          ": ", format(state[["completed"]], big.mark = ","), "/",
          format(state[["total"]], big.mark = ","), " futures"
        )
      )
    })
    output$sensitivity_status <- renderUI({
      div(class = "investigate-state", status_state()[["sensitivity"]])
    })
    output$future_status <- renderUI({
      div(class = "investigate-state", status_state()[["future"]])
    })
    output$sensitivity_completion <- renderUI({
      state <- completion_state()$sensitivity
      if (identical(state, FALSE)) return(NULL)
      div(class = "investigate-completion", icon("circle-check"), state)
    })
    output$future_completion <- renderUI({
      state <- completion_state()$future
      if (identical(state, FALSE)) return(NULL)
      div(class = "investigate-completion", icon("circle-check"), state)
    })

    output$sensitivity_result_context <- renderUI({
      if (is.null(sensitivity_comparison())) {
        div(
          class = "sensitivity-result-context is-example",
          icon("eye"),
          span("Representative completed comparison for this design review")
        )
      } else {
        div(
          class = "sensitivity-result-context is-current",
          icon("circle-check"),
          span("Results from your current project")
        )
      }
    })

    output$sensitivity_plot <- renderPlot({
      comparison <- sensitivity_comparison()
      investigate_sensitivity_probe_plot(
        investigate_sensitivity_display_data(comparison)
      )
    }, res = 96)
    output$future_plot <- renderPlot({
      comparison <- future_comparison()
      req(comparison)
      rPVA::plot_woodhen_family_comparison(comparison)
    }, res = 96)

    result_table <- function(comparison) {
      if (is.null(comparison)) return(NULL)
      table <- comparison$table
      data.frame(
        Scenario = table$student_label,
        `Final median (95% interval)` = paste0(
          investigate_format_number(table$final_median_abundance), " (",
          investigate_format_number(table$final_q025), "-",
          investigate_format_number(table$final_q975), ")"
        ),
        `Extinction by year 75` = investigate_format_probability(table$extinction_probability),
        `Extinction timing (conditional)` = vapply(
          table$extinction_conditional_median_year,
          investigate_format_timing, character(1)
        ),
        `Fewer than 50 pairs` = investigate_format_probability(table$quasi_extinction_probability),
        `50-pair timing (conditional)` = vapply(
          table$quasi_extinction_conditional_median_year,
          investigate_format_timing, character(1)
        ),
        `50-pair timing (overall)` = vapply(
          table$quasi_extinction_overall_median_year,
          investigate_format_timing, character(1), overall = TRUE
        ),
        `Parent difference: final median` = investigate_format_number(
          table$delta_final_median_abundance
        ),
        check.names = FALSE
      )
    }

    output$sensitivity_table <- renderTable({
      investigate_sensitivity_probe_table(
        investigate_sensitivity_display_data(sensitivity_comparison())
      )
    }, striped = TRUE, bordered = FALSE, spacing = "s", rownames = FALSE)
    output$future_table <- renderTable({
      result_table(future_comparison())
    }, striped = TRUE, bordered = FALSE, spacing = "s", rownames = FALSE)

    save_result_notes <- function(route, comparison, interpretation, caveat) {
      notes <- c(Interpretation = trimws(investigate_or(interpretation, "")),
        Caveat = trimws(investigate_or(caveat, "")))
      notes <- notes[nzchar(notes)]
      if (length(notes) == 0L) {
        set_status(route, "No result observation was saved because both fields are empty.")
        return()
      }
      if (is.null(comparison)) {
        set_status(route, "Run a complete family before saving result observations.")
        return()
      }
      observation <- list(
        title = if (identical(route, "sensitivity")) {
          "Sensitivity result observation"
        } else {
          "Future advice result observation"
        },
        note = paste(paste0(names(notes), ": ", notes), collapse = "\n"),
        run_ids = comparison$table$run_id
      )
      saved <- tryCatch(
        rPVA:::woodhen_add_prompt_once(project(), observation, Sys.time()),
        error = function(error) error
      )
      if (inherits(saved, "error")) {
        set_status(route, paste("Observation was not saved:", conditionMessage(saved)))
        return()
      }
      if (!saved$saved) {
        set_status(route, "The identical result observation was already recorded.")
        return()
      }
      set_status(route, "Result observation ready for project activation.")
      publish(observation_update_state, list(
        ok = TRUE,
        candidate = saved$project,
        family_id = comparison$family_id,
        route = route,
        message = "Result observation saved.",
        base_project_fingerprint = project()$project_fingerprint
      ))
    }

    observeEvent(input$save_sensitivity_notes, {
      save_result_notes(
        "sensitivity", sensitivity_comparison(),
        input$sensitivity_interpretation, input$sensitivity_caveat
      )
    })
    observeEvent(input$save_future_notes, {
      save_result_notes(
        "future", future_comparison(),
        input$future_interpretation, input$future_caveat
      )
    })

    list(
      project_update = reactive(project_update_state()),
      observation_update = reactive(observation_update_state()),
      navigate = reactive(navigation_state()),
      progress_state = reactive(progress_state()),
      progress_history = reactive(progress_history_state()),
      busy_state = reactive(busy()),
      status_state = reactive(status_state()),
      sensitivity_comparison = sensitivity_comparison,
      future_comparison = future_comparison,
      completion_state = completion_state
    )
  })
}
