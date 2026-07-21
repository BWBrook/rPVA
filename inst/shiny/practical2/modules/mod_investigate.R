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
    stop("Altered sensitivity settings must differ from the locked baseline.", call. = FALSE)
  }
  if (anyDuplicated(values)) {
    stop("Choose two distinct altered sensitivity settings.", call. = FALSE)
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
  match_index <- which(startsWith(family_id, prefix))
  if (length(match_index) == 1L) catalog_ids[[match_index]] else NA_character_
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
    factor_id <- investigate_family_key(sensitivity_id, "sensitivity")
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
    title = "Investigating sensitivity and future advice",
    div(
      class = "help-modal-content",
      render_markdown_content(file.path(
        practical2_app_dir, "content", "help-investigate.md"
      ))
    ),
    footer = modalButton("Close"),
    easyClose = TRUE,
    size = "m"
  )
}

investigate_prompt_inputs <- function(ns, prefix) {
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

investigate_result_prompts <- function(ns, prefix) {
  div(
    class = "investigate-result-prompts",
    textAreaInput(
      ns(paste0(prefix, "_interpretation")),
      "Optional interpretation",
      rows = 2
    ),
    textAreaInput(
      ns(paste0(prefix, "_caveat")),
      "Optional caveat",
      rows = 2
    ),
    actionButton(
      ns(paste0("save_", prefix, "_notes")),
      "Save result observations",
      icon = icon("note-sticky"),
      class = "btn-default btn-sm"
    )
  )
}

investigate_ui <- function(id) {
  ns <- NS(id)
  sensitivity <- rPVA::woodhen_sensitivity_catalog()
  threats <- rPVA::woodhen_threat_catalog()
  interventions <- rPVA::woodhen_intervention_catalog()
  default_interventions <- investigate_compatible_interventions(threats$id[[1L]])

  div(
    class = "page-shell investigate-shell",
    tags$header(
      class = "investigate-header",
      div(
        span(class = "section-eyebrow", "Act 2: Advise from the present"),
        h1("Investigate sensitivity and future advice"),
        p(
          "Branch from the exact 2025-2100 anchor, keep the comparison machinery",
          "locked, and retain both response and management evidence."
        )
      ),
      actionButton(
        ns("open_investigate_help"),
        "Interpretation help",
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
    div(
      class = "investigate-workspaces",
      tags$section(
        class = "investigate-workspace sensitivity-workspace",
        `aria-labelledby` = ns("sensitivity_heading"),
        span(class = "workspace-label", "Sensitivity"),
        h2(id = ns("sensitivity_heading"), "Trace one ecological response"),
        p(
          "Run the locked baseline plus two altered settings while every",
          "non-target field remains identical."
        ),
        div(
          class = "investigate-control-grid",
          selectInput(
            ns("factor_id"), "Ecological factor",
            choices = stats::setNames(sensitivity$id, sensitivity$label),
            selected = "K"
          ),
          selectInput(
            ns("sensitivity_first_choice"), "First altered setting",
            choices = c("Moderate anchor" = "moderate", "High anchor" = "high", "Custom" = "custom"),
            selected = "moderate"
          ),
          numericInput(
            ns("sensitivity_first_custom"), "First custom value",
            value = 350, min = 150, max = 750, step = 1
          ),
          selectInput(
            ns("sensitivity_second_choice"), "Second altered setting",
            choices = c("Moderate anchor" = "moderate", "High anchor" = "high", "Custom" = "custom"),
            selected = "high"
          ),
          numericInput(
            ns("sensitivity_second_custom"), "Second custom value",
            value = 250, min = 150, max = 750, step = 1
          )
        ),
        uiOutput(ns("sensitivity_preview")),
        div(
          class = "investigate-prompts",
          investigate_prompt_inputs(ns, "sensitivity")
        ),
        actionButton(
          ns("run_sensitivity"),
          "Run three-setting family",
          icon = icon("play"),
          class = "btn-primary investigate-run-action"
        ),
        uiOutput(ns("sensitivity_progress")),
        uiOutput(ns("sensitivity_status"), `aria-live` = "polite", `aria-atomic` = "true"),
        uiOutput(ns("sensitivity_completion")),
        div(
          class = "investigate-plot",
          role = "img",
          `aria-label` = "Sensitivity response across three settings",
          plotOutput(ns("sensitivity_plot"), height = "300px")
        ),
        div(class = "investigate-table-scroll", tableOutput(ns("sensitivity_table"))),
        investigate_result_prompts(ns, "sensitivity")
      ),
      tags$section(
        class = "investigate-workspace future-workspace",
        `aria-labelledby` = ns("future_heading"),
        span(class = "workspace-label", "Future advice"),
        h2(id = ns("future_heading"), "Test a threat and compatible action"),
        p(
          "Run an exact family: locked baseline, named threat, then one",
          "intervention applied to that threatened future."
        ),
        div(
          class = "investigate-control-grid",
          selectInput(
            ns("threat_id"), "Plausible threat",
            choices = stats::setNames(threats$id, threats$label),
            selected = threats$id[[1L]]
          ),
          selectInput(
            ns("threat_choice"), "Threat severity",
            choices = c(
              "Low anchor" = "low", "Moderate anchor" = "moderate",
              "High anchor" = "high", "Custom" = "custom"
            ),
            selected = "moderate"
          ),
          numericInput(
            ns("threat_custom"), "Custom threat value",
            value = threats$anchors[[1L]][["moderate"]],
            min = threats$custom_range[[1L]][["min"]],
            max = threats$custom_range[[1L]][["max"]],
            step = investigate_control_step(threats$custom_range[[1L]])
          ),
          selectInput(
            ns("intervention_id"), "Compatible intervention",
            choices = stats::setNames(
              default_interventions,
              interventions$label[match(default_interventions, interventions$id)]
            ),
            selected = default_interventions[[1L]]
          ),
          selectInput(
            ns("intervention_choice"), "Intervention intensity",
            choices = c(
              "Low anchor" = "low", "Moderate anchor" = "moderate",
              "High anchor" = "high", "Custom" = "custom"
            ),
            selected = "moderate"
          ),
          numericInput(
            ns("intervention_custom"), "Custom intervention value",
            value = 0.5, min = 0, max = 1, step = 0.01
          )
        ),
        uiOutput(ns("future_preview")),
        div(
          class = "investigate-prompts",
          investigate_prompt_inputs(ns, "future")
        ),
        actionButton(
          ns("run_future"),
          "Run threat-intervention family",
          icon = icon("play"),
          class = "btn-primary investigate-run-action"
        ),
        uiOutput(ns("future_progress")),
        uiOutput(ns("future_status"), `aria-live` = "polite", `aria-atomic` = "true"),
        uiOutput(ns("future_completion")),
        div(
          class = "investigate-plot",
          role = "img",
          `aria-label` = "Baseline threat and intervention comparison",
          plotOutput(ns("future_plot"), height = "340px")
        ),
        div(class = "investigate-table-scroll", tableOutput(ns("future_table"))),
        investigate_result_prompts(ns, "future")
      )
    ),
    tags$details(
      class = "investigate-advanced-placeholder",
      tags$summary("Advanced exploration"),
      p(
        "Multi-factor scenarios and timing controls are not yet implemented.",
        "They remain optional headroom for a later build stage."
      )
    ),
    p(
      class = "investigate-threshold-note",
      "Risk uses strictly fewer than 50 breeding pairs, stages 2 onward,",
      "across 75 years (elapsed years 0-75) and 1,000 simulated futures."
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
    navigation_state <- reactiveVal(NULL)
    event_counter <- reactiveVal(0L)
    status_state <- reactiveVal(c(
      sensitivity = "Choose settings and run the complete family.",
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
      next_event <- event_counter() + 1L
      event_counter(next_event)
      value$event_id <- next_event
      target(value)
      invisible(value)
    }

    set_status <- function(route, value) {
      status <- status_state()
      status[[route]] <- value
      status_state(status)
    }

    set_progress <- function(route, scenario, scenarios, completed, total) {
      progress <- progress_state()
      progress[[route]] <- c(
        scenario = as.integer(scenario), scenarios = as.integer(scenarios),
        completed = as.integer(completed), total = as.integer(total)
      )
      progress_state(progress)
      history <- progress_history_state()
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
          ready = "Locked future baseline ready",
          stale = "Locked future baseline is incompatible",
          "Locked future baseline missing"
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
        investigate_or(input$sensitivity_first_choice, "moderate"),
        investigate_or(input$sensitivity_second_choice, "high"),
        investigate_or(input$sensitivity_first_custom, row$anchors[[1L]][["moderate"]]),
        investigate_or(input$sensitivity_second_custom, row$anchors[[1L]][["high"]])
      ), error = function(error) error)
      proposed <- if (inherits(values, "error")) {
        conditionMessage(values)
      } else {
        paste(investigate_format_number(c(row$locked_baseline[[1L]], values)), collapse = " | ")
      }
      div(
        class = "investigate-preview",
        h3(row$label[[1L]]),
        p(row$biological_meaning[[1L]]),
        p(strong("Exact model mapping: "), investigate_mapping_text(row)),
        p(strong("Baseline and proposed settings: "), proposed),
        p(strong("Limitation: "), row$limitation[[1L]]),
        p(class = "locked-machinery", "Locked: supplied starting population | 75 years | 1,000 futures | seed 123 | every non-target field")
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
        p(class = "locked-machinery", "Locked: supplied starting population | 75 years | 1,000 futures | seed 123 | common stage structure")
      )
    })

    run_route <- function(route, family, prompt) {
      if (!investigate_begin_batch(busy)) {
        set_status(route, "A family is already running; the repeated submission was ignored.")
        return(NULL)
      }
      on.exit(busy(FALSE), add = TRUE)
      candidate <- project()
      anchor <- rPVA:::woodhen_locked_anchor_status(candidate)
      if (!identical(anchor$status, "ready")) {
        set_status(route, paste("Run blocked.", anchor$action))
        publish(project_update_state, list(ok = FALSE, message = paste("Run blocked.", anchor$action)))
        return(NULL)
      }
      progress <- progress_state()
      progress[[route]] <- c(scenario = 0L, scenarios = length(family$scenarios), completed = 0L, total = 1000L)
      progress_state(progress)
      history <- progress_history_state()
      history[[route]] <- list()
      progress_history_state(history)
      set_status(route, "Preparing the complete family in session scratch.")
      action <- tryCatch(
        rPVA:::woodhen_run_investigation_family_project(
          candidate,
          family,
          prompt = prompt,
          progress = function(scenario, scenarios, completed, total) {
            set_progress(route, scenario, scenarios, completed, total)
          },
          runner = scenario_runner
        ),
        error = function(error) error
      )
      if (inherits(action, "error")) {
        message <- paste("Family run failed; no partial evidence was inserted:", conditionMessage(action))
        set_status(route, message)
        publish(project_update_state, list(ok = FALSE, message = message))
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
        message = message
      ))
      action
    }

    observeEvent(input$run_sensitivity, {
      values <- tryCatch(investigate_sensitivity_values(
        input$factor_id,
        input$sensitivity_first_choice,
        input$sensitivity_second_choice,
        input$sensitivity_first_custom,
        input$sensitivity_second_custom
      ), error = function(error) error)
      if (inherits(values, "error")) {
        set_status("sensitivity", conditionMessage(values))
        return()
      }
      family <- rPVA::build_woodhen_sensitivity_family(
        input$factor_id, values, seed = 123L
      )
      run_route("sensitivity", family, list(
        research_question = investigate_or(input$sensitivity_research_question, ""),
        biological_reason = investigate_or(input$sensitivity_biological_reason, ""),
        expected_direction = investigate_or(input$sensitivity_expected_direction, "")
      ))
    })

    observeEvent(input$run_future, {
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
        return()
      }
      run_route("future", family, list(
        research_question = investigate_or(input$future_research_question, ""),
        biological_reason = investigate_or(input$future_biological_reason, ""),
        expected_direction = investigate_or(input$future_expected_direction, "")
      ))
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
      div(
        class = "investigate-progress",
        role = "progressbar",
        `aria-valuemin` = "0",
        `aria-valuemax` = as.character(state[["total"]]),
        `aria-valuenow` = as.character(state[["completed"]]),
        `aria-label` = "Sensitivity family simulation progress",
        paste0(
          "Scenario ", state[["scenario"]], "/", state[["scenarios"]],
          ": ", format(state[["completed"]], big.mark = ","), "/",
          format(state[["total"]], big.mark = ","), " futures"
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

    output$sensitivity_plot <- renderPlot({
      comparison <- sensitivity_comparison()
      req(comparison)
      rPVA::plot_woodhen_sensitivity_response(comparison)
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
      result_table(sensitivity_comparison())
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
      publish(project_update_state, list(
        ok = TRUE,
        candidate = saved$project,
        route = route,
        message = "Result observation saved."
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
      navigate = reactive(navigation_state()),
      progress_state = reactive(progress_state()),
      progress_history = reactive(progress_history_state()),
      busy_state = reactive(busy()),
      sensitivity_comparison = sensitivity_comparison,
      future_comparison = future_comparison,
      completion_state = completion_state
    )
  })
}
