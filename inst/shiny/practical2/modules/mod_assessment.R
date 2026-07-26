assessment_ilos <- function() {
  c(
    "Discuss the requirements for success in effective species conservation by integrating theory and case studies.",
    "Diagnose and solve biodiversity problems by applying fundamental principles from population and community ecology, genetics and ecosystem science.",
    "Evaluate the causes of uncertainty and controversy in the development of strategies for species conservation.",
    "Communicate a conservation problem to scientific peers and relevant stakeholders."
  )
}

assessment_criteria <- function() {
  data.frame(
    criterion = paste0("C", 1:4),
    marks = c(5L, 6L, 8L, 6L),
    assessment_criteria = c(
      "Describe the uses and limitations of simulation modelling in conservation decision-making.",
      "Model stochastic processes and causes of threat.",
      "Undertake scenario testing to compare the relative effectiveness of alternative management options.",
      "Translate simulation results and communicate them as conservation recommendations."
    ),
    stringsAsFactors = FALSE
  )
}

assessment_family_counts <- function(runs) {
  counts <- c(sensitivity = 0L, future = 0L)
  if (!is.list(runs) || length(runs) == 0L) return(counts)
  valid_identifier <- function(value) {
    is.character(value) && length(value) == 1L && !is.na(value) &&
      nzchar(value)
  }
  valid <- vapply(runs, function(run) {
    is.list(run) &&
      valid_identifier(run$family_id) &&
      valid_identifier(run$scenario_type)
  }, logical(1))
  if (!all(valid)) stop("Run identity is unavailable.", call. = FALSE)

  families <- split(runs, vapply(runs, `[[`, character(1), "family_id"))
  for (family in families) {
    types <- vapply(family, `[[`, character(1), "scenario_type")
    type_counts <- table(types)
    count_type <- function(type) {
      if (type %in% names(type_counts)) {
        as.integer(type_counts[[type]])
      } else {
        0L
      }
    }
    sensitivity <- all(types %in% c("locked_baseline", "sensitivity")) &&
      identical(count_type("locked_baseline"), 1L) &&
      count_type("sensitivity") >= 2L
    future <- all(types %in% c(
      "locked_baseline", "threat", "intervention"
    )) &&
      identical(count_type("locked_baseline"), 1L) &&
      identical(count_type("threat"), 1L) &&
      count_type("intervention") >= 1L
    if (isTRUE(sensitivity)) {
      counts[["sensitivity"]] <- counts[["sensitivity"]] + 1L
    } else if (isTRUE(future)) {
      counts[["future"]] <- counts[["future"]] + 1L
    }
  }
  counts
}

assessment_project_summary <- function(project) {
  required <- c(
    "title", "owner_label", "runs", "observations", "evidence_items"
  )
  if (!is.list(project) || !all(required %in% names(project))) {
    stop("Project summary fields are unavailable.", call. = FALSE)
  }
  counts <- assessment_family_counts(project$runs)
  historical <- vapply(project$runs, function(run) {
    identical(run$scenario_type, "reference") &&
      run$scenario_id %in% c(
        "01_no_mgmt", "02_pig_control", "03_captive_pig",
        "04_rodent_eradication"
      )
  }, logical(1))
  list(
    status = "available",
    title = project$title,
    owner_label = project$owner_label,
    historical_count = as.integer(sum(historical)),
    sensitivity_count = unname(counts[["sensitivity"]]),
    future_count = unname(counts[["future"]]),
    observation_count = as.integer(length(project$observations)),
    portfolio_count = as.integer(length(project$evidence_items))
  )
}

assessment_safe_project_summary <- function(project) {
  if (is.null(project)) {
    return(list(
      status = "empty", title = NULL, owner_label = NULL,
      historical_count = 0L, sensitivity_count = 0L, future_count = 0L,
      observation_count = 0L, portfolio_count = 0L
    ))
  }
  tryCatch(
    assessment_project_summary(project),
    error = function(...) list(
      status = "unavailable", title = NULL, owner_label = NULL,
      historical_count = 0L, sensitivity_count = 0L, future_count = 0L,
      observation_count = 0L, portfolio_count = 0L
    )
  )
}

assessment_criterion_questions <- function() {
  c(
    C1 = paste(
      "What conservation decision does the model help inform?",
      "Which data, structural, scenario, and unmodelled-process limits matter?"
    ),
    C2 = paste(
      "Which stochastic processes and threat mechanisms matter in your",
      "comparisons, and which assumptions were deliberately held constant?"
    ),
    C3 = paste(
      "What matched quantitative evidence shows the effect of management",
      "relative to the same threatened future?"
    ),
    C4 = paste(
      "What action does the evidence support, how confident are you,",
      "and what information or outcome could change that advice?"
    )
  )
}

assessment_outcomes_ui <- function() {
  criteria <- assessment_criteria()
  questions <- assessment_criterion_questions()
  ilos <- assessment_ilos()
  shiny::tags$section(
    class = "assessment-band",
    shiny::span(class = "workspace-label", "Unit and task alignment"),
    shiny::h2("What is assessed"),
    shiny::p(
      "The Intended Learning Outcomes describe the wider unit.",
      "C1-C4 focus those outcomes on this assessment."
    ),
    shiny::tags$ol(
      class = "assessment-ilo-list",
      lapply(seq_along(ilos), function(index) {
        shiny::tags$li(
          shiny::span(
            class = "assessment-ilo-label",
            paste("ILO", index)
          ),
          ilos[[index]]
        )
      })
    ),
    shiny::div(
      class = "assessment-criteria-grid",
      lapply(seq_len(nrow(criteria)), function(index) {
        row <- criteria[index, , drop = FALSE]
        shiny::tags$article(
          class = "assessment-criterion",
          shiny::div(
            class = "assessment-criterion-heading",
            shiny::h3(row$criterion),
            shiny::span(paste(row$marks, "marks"))
          ),
          shiny::p(row$assessment_criteria),
          shiny::tags$details(
            shiny::tags$summary("Questions to ask yourself"),
            shiny::p(unname(questions[[row$criterion]]))
          )
        )
      })
    )
  )
}

assessment_markdown_band <- function(label, path) {
  shiny::tags$section(
    class = "assessment-band assessment-guidance-band",
    shiny::span(class = "workspace-label", label),
    shiny::div(
      class = "assessment-reading-width",
      render_markdown_content(file.path(
        practical2_app_dir, "content", path
      ))
    )
  )
}

assessment_report_guidance_ui <- function() {
  assessment_markdown_band(
    "Argument and evidence", "report-guidance.md"
  )
}

assessment_research_ui <- function() {
  assessment_markdown_band(
    "Ecological context", "woodhen-research.md"
  )
}

assessment_deepening_ui <- function() {
  assessment_markdown_band(
    "Optional extension", "ways-to-deepen.md"
  )
}

assessment_navigation_ui <- function(ns) {
  shiny::tags$nav(
    class = "assessment-navigation-actions",
    `aria-label` = "Open investigation workspace",
    shiny::actionButton(
      ns("go_calibrate"), "Open Calibrate",
      icon = shiny::icon("clock-rotate-left"),
      class = "btn-default btn-sm"
    ),
    shiny::actionButton(
      ns("go_investigate"), "Open Investigate",
      icon = shiny::icon("flask"),
      class = "btn-default btn-sm"
    ),
    shiny::actionButton(
      ns("go_compare"), "Open Compare",
      icon = shiny::icon("scale-balanced"),
      class = "btn-default btn-sm"
    ),
    shiny::actionButton(
      ns("go_evidence"), "Open Evidence Studio",
      icon = shiny::icon("folder-open"),
      class = "btn-default btn-sm"
    )
  )
}

assessment_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::div(
    class = "page-shell assessment-shell",
    shiny::tags$header(
      class = "assessment-header",
      shiny::div(
        shiny::span(class = "section-eyebrow", "Assessment Task"),
        shiny::h1("Woodhen Conservation Advice"),
        shiny::p(
          "Develop an evidence-led recommendation as a present-day",
          "conservation adviser. The report is approximately 2,000 words;",
          "display items and references are excluded."
        )
      ),
      shiny::div(
        class = "assessment-mylo-reminder",
        shiny::icon("circle-info"),
        shiny::span("Check official submission details in MyLO")
      )
    ),
    shiny::tags$section(
      class = "assessment-band assessment-glance-band",
      shiny::span(class = "workspace-label", "Current project"),
      shiny::h2("Your investigation at a glance"),
      shiny::p(
        "This summary reports what is available in the current project.",
        "Use it as a neutral reminder of your working record."
      ),
      shiny::div(
        class = "assessment-summary-region",
        role = "status",
        `aria-live` = "polite",
        `aria-atomic` = "true",
        shiny::uiOutput(ns("investigation_summary"))
      ),
      assessment_navigation_ui(ns)
    ),
    shiny::tags$section(
      class = "assessment-band",
      shiny::span(class = "workspace-label", "Scientific journey"),
      shiny::h2("The investigation"),
      shiny::div(
        class = "assessment-phase-grid",
        shiny::div(
          class = "assessment-phase",
          shiny::h3("Phase 1: Reconstruct the management history"),
          shiny::p(
            "Use historical comparisons as plausibility evidence for the",
            "model's ability to reproduce broad patterns of management",
            "history. Assess independent model validation as a separate",
            "evidentiary claim."
          )
        ),
        shiny::div(
          class = "assessment-phase",
          shiny::h3("Phase 2: Advise from the present"),
          shiny::p(
            "Use one-factor sensitivity evidence and a matched",
            "threat-management comparison to develop prospective advice."
          )
        )
      )
    ),
    assessment_outcomes_ui(),
    assessment_report_guidance_ui(),
    assessment_research_ui(),
    assessment_deepening_ui()
  )
}

assessment_availability <- function(
    count,
    singular,
    plural = paste0(singular, "s")
) {
  label <- if (count == 1L) singular else plural
  list(
    available = count > 0L,
    value = if (count > 0L) {
      paste(count, label, "available")
    } else {
      paste("Not yet in this project:", plural)
    }
  )
}

assessment_summary_ui <- function(ns, summary) {
  if (identical(summary$status, "empty")) {
    return(shiny::div(
      class = "assessment-summary-empty",
      shiny::p(shiny::strong("No project is currently loaded.")),
      shiny::p(
        "Create, resume, or import a project on Start to show your",
        "investigation record here. The guidance below remains available."
      )
    ))
  }
  if (identical(summary$status, "unavailable")) {
    return(shiny::div(
      class = "assessment-summary-empty",
      shiny::p(shiny::strong("Project summary unavailable")),
      shiny::p(
        "Your assessment guidance is still available. Return to Start if",
        "you need to resume or import the project again."
      )
    ))
  }

  history <- assessment_availability(
    summary$historical_count,
    "historical result",
    "historical results"
  )
  sensitivity <- assessment_availability(
    summary$sensitivity_count,
    "sensitivity comparison",
    "sensitivity comparisons"
  )
  future <- assessment_availability(
    summary$future_count,
    "threat-management comparison",
    "threat-management comparisons"
  )
  record <- paste(
    summary$observation_count,
    if (summary$observation_count == 1L) "saved note" else "saved notes",
    "and",
    summary$portfolio_count,
    if (summary$portfolio_count == 1L) {
      "portfolio item"
    } else {
      "portfolio items"
    },
    "available"
  )

  shiny::div(
    class = "assessment-summary",
    shiny::p(
      class = "assessment-project-identity",
      shiny::strong(summary$title),
      if (!is.null(summary$owner_label) && nzchar(summary$owner_label)) {
        paste(" - ", summary$owner_label)
      }
    ),
    shiny::div(
      class = "assessment-status-grid",
      project_status_ui(
        "Historical reconstruction", history$value,
        "neutral",
        "clock-rotate-left"
      ),
      project_status_ui(
        "Sensitivity evidence", sensitivity$value,
        "neutral",
        "chart-line"
      ),
      project_status_ui(
        "Threat and management evidence", future$value,
        "neutral",
        "shield-halved"
      ),
      project_status_ui(
        "Working record", record, "neutral", "folder-open"
      )
    )
  )
}

assessment_navigation_targets <- function() {
  c("calibrate", "investigate", "compare", "evidence")
}

validate_assessment_navigation_event <- function(event) {
  if (!is.list(event) ||
      !identical(names(event), c("section", "event_id")) ||
      !is.character(event$section) || length(event$section) != 1L ||
      !event$section %in% assessment_navigation_targets() ||
      !is.numeric(event$event_id) || length(event$event_id) != 1L ||
      !is.finite(event$event_id) || event$event_id < 1L ||
      event$event_id != as.integer(event$event_id)) {
    stop("Assessment navigation event is invalid.", call. = FALSE)
  }
  event$section
}

assessment_server <- function(id, project = NULL) {
  shiny::moduleServer(id, function(input, output, session) {
    navigate <- shiny::reactiveVal(NULL)
    event_id <- shiny::reactiveVal(0L)
    project_value <- shiny::reactive({
      if (is.function(project)) project() else project
    })
    summary <- shiny::reactive({
      assessment_safe_project_summary(project_value())
    })

    output$investigation_summary <- shiny::renderUI({
      assessment_summary_ui(session$ns, summary())
    })

    targets <- assessment_navigation_targets()
    for (target_value in targets) {
      local({
        target <- target_value
        shiny::observeEvent(input[[paste0("go_", target)]], {
          next_id <- shiny::isolate(event_id()) + 1L
          event_id(next_id)
          navigate(list(section = target, event_id = next_id))
        }, ignoreInit = TRUE)
      })
    }
    list(navigate = navigate, summary = summary)
  })
}
