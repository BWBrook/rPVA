library(shiny)

catalog <- rPVA::woodhen_management_catalog()
core_scenario_ids <- c("01_no_mgmt", "02_pig_control", "03_captive_pig", "04_rodent_eradication", "05_future_baseline")
sensitivity_scenario_ids <- c("sensitivity_default", "survival_minus_10pct", "K_250", "cat_freq_0.10")

core_catalog <- catalog[catalog$scenario_id %in% core_scenario_ids, , drop = FALSE]
sensitivity_catalog <- catalog[catalog$scenario_id %in% sensitivity_scenario_ids, , drop = FALSE]

core_choices <- stats::setNames(core_catalog$scenario_id, core_catalog$label)
sensitivity_choices <- stats::setNames(sensitivity_catalog$scenario_id, sensitivity_catalog$label)

scenario_intro_ui <- function() {
  div(
    class = "lab-hero",
    div(
      class = "lab-hero-copy",
      span(class = "lab-kicker", "Practical 2"),
      h1("Woodhen Management Lab"),
      p("Use PVA evidence to compare management options for the Lord Howe Island woodhen. Your task is to turn scenario output into clear conservation advice."),
      tags$ul(
        tags$li("Run a core set of management scenarios."),
        tags$li("Check one bounded sensitivity question at a time."),
        tags$li("Save evidence and translate it into report-ready claims.")
      )
    ),
    div(
      class = "lab-hero-panel",
      h2("Your management question"),
      p("Which action gives the strongest support for reducing extinction risk while keeping abundance and uncertainty in view?"),
      p(class = "muted", "Use model results as evidence. Keep assumptions visible when you make a recommendation.")
    )
  )
}

scenario_card_grid <- function(comparison) {
  if (is.null(comparison) || !nrow(comparison)) {
    return(tags$p(class = "muted", "Run a scenario set to create comparison cards."))
  }

  div(
    class = "scenario-card-grid",
    lapply(seq_len(nrow(comparison)), function(i) {
      row <- comparison[i, , drop = FALSE]
      div(
        class = "scenario-card",
        span(class = "scenario-card-kicker", row$section),
        h3(row$label),
        p(class = "muted", row$change_label),
        div(
          class = "scenario-card-metrics",
          span(strong("PE"), ": ", sprintf("%.3f", row$PE)),
          span(strong("Nmed"), ": ", row$Nmed),
          span(strong("95% interval"), ": ", paste0(row$Nlo95, "-", row$Nhi95))
        )
      )
    })
  )
}

diagnostic_panel <- function(run_set) {
  if (is.null(run_set) || !length(run_set$runs)) {
    return(tags$p(class = "muted", "Scenario diagnostics will appear after a run."))
  }

  rows <- do.call(
    rbind,
    lapply(run_set$runs, function(run) {
      diagnostics <- run$diagnostics
      if (!nrow(diagnostics)) {
        return(data.frame(
          Scenario = run$label,
          Message = "No major diagnostic warning for this scenario. Keep assumptions visible.",
          stringsAsFactors = FALSE
        ))
      }
      data.frame(
        Scenario = diagnostics$scenario,
        Message = diagnostics$message,
        stringsAsFactors = FALSE
      )
    })
  )
  rownames(rows) <- NULL
  tableOutput("diagnostic_table")
}

comparison_table_for_display <- function(run_set) {
  if (is.null(run_set)) {
    return(data.frame())
  }

  out <- run_set$comparison
  out[, c("scenario_id", "label", "years", "reps", "PE", "Nmed", "Nlo95", "Nhi95", "changed_parameter", "change_label"), drop = FALSE]
}

report_bridge_ui <- function() {
  div(
    class = "report-bridge",
    h2("Turn evidence into advice"),
    p("Your report needs a claim, the evidence supporting it, and a caveat that explains the limits of the model."),
    tags$ol(
      tags$li(strong("Claim: "), "name the management option or assumption that matters most."),
      tags$li(strong("Evidence: "), "quote PE, median final abundance, and the uncertainty interval from your saved comparison."),
      tags$li(strong("Interpretation: "), "explain why the result matters biologically."),
      tags$li(strong("Caveat: "), "state one assumption, missing process, or data limit that affects confidence.")
    ),
    div(
      class = "sentence-frame",
      "A strong sentence can follow this pattern: The strongest support for [action] is [evidence], because [biological interpretation], with [caveat] limiting confidence."
    )
  )
}

run_status <- function(run_set) {
  if (is.null(run_set)) {
    return("No scenarios have been run in this browser session.")
  }
  paste0(nrow(run_set$comparison), " scenarios ready for comparison and export.")
}

ui <- fluidPage(
  tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")),
  titlePanel("Woodhen Management Lab"),
  tabsetPanel(
    id = "practical2_tabs",
    tabPanel(
      "Overview",
      scenario_intro_ui()
    ),
    tabPanel(
      "Management scenarios",
      sidebarLayout(
        sidebarPanel(
          h3("Core scenario set"),
          checkboxGroupInput(
            "core_scenarios",
            "Choose scenarios",
            choices = core_choices,
            selected = core_scenario_ids
          ),
          actionButton("run_core_scenarios", "Run management scenarios", class = "btn-primary"),
          p(class = "muted", "Run the full set first, then rerun a smaller set if your comparison needs focus.")
        ),
        mainPanel(
          h2("Scenario comparison"),
          textOutput("core_status"),
          div(class = "compare-table", tableOutput("core_comparison_table")),
          uiOutput("core_scenario_cards")
        )
      )
    ),
    tabPanel(
      "Bounded sensitivity",
      sidebarLayout(
        sidebarPanel(
          h3("One-factor checks"),
          checkboxGroupInput(
            "sensitivity_scenarios",
            "Choose sensitivity presets",
            choices = sensitivity_choices,
            selected = sensitivity_scenario_ids
          ),
          actionButton("run_sensitivity_scenarios", "Run sensitivity scenarios", class = "btn-primary"),
          p(class = "muted", "Each preset changes one factor so the result remains interpretable.")
        ),
        mainPanel(
          h2("Sensitivity comparison"),
          textOutput("sensitivity_status"),
          div(class = "compare-table", tableOutput("sensitivity_comparison_table")),
          uiOutput("sensitivity_scenario_cards")
        )
      )
    ),
    tabPanel(
      "Evidence pack",
      h2("Save your evidence"),
      p("Save the comparison CSV and evidence-notes Markdown from the scenario set you most recently ran."),
      textAreaInput("woodhen_interpretation", "Draft interpretation note", value = "", rows = 5, width = "100%"),
      div(
        class = "download-row",
        downloadButton("download_woodhen_comparison", "Download comparison CSV"),
        downloadButton("download_woodhen_evidence", "Download evidence notes")
      ),
      h3("Diagnostics"),
      div(class = "compare-table", tableOutput("diagnostic_table"))
    ),
    tabPanel(
      "Report bridge",
      report_bridge_ui()
    )
  )
)

server <- function(input, output, session) {
  active_run_set <- reactiveVal(NULL)
  core_run_set <- reactiveVal(NULL)
  sensitivity_run_set <- reactiveVal(NULL)

  observeEvent(input$run_core_scenarios, {
    req(input$core_scenarios)
    withProgress(message = "Running Woodhen management scenarios", value = 0.2, {
      run_set <- rPVA::run_woodhen_management_set(input$core_scenarios, keep_traj = FALSE, seed = 123, verbose = FALSE)
      incProgress(0.8)
      core_run_set(run_set)
      active_run_set(run_set)
    })
  })

  observeEvent(input$run_sensitivity_scenarios, {
    req(input$sensitivity_scenarios)
    withProgress(message = "Running bounded sensitivity scenarios", value = 0.2, {
      run_set <- rPVA::run_woodhen_management_set(input$sensitivity_scenarios, keep_traj = FALSE, seed = 123, verbose = FALSE)
      incProgress(0.8)
      sensitivity_run_set(run_set)
      active_run_set(run_set)
    })
  })

  output$core_status <- renderText(run_status(core_run_set()))
  output$sensitivity_status <- renderText(run_status(sensitivity_run_set()))

  output$core_comparison_table <- renderTable({
    comparison_table_for_display(core_run_set())
  }, striped = TRUE, bordered = TRUE, spacing = "s")

  output$sensitivity_comparison_table <- renderTable({
    comparison_table_for_display(sensitivity_run_set())
  }, striped = TRUE, bordered = TRUE, spacing = "s")

  output$core_scenario_cards <- renderUI({
    run_set <- core_run_set()
    scenario_card_grid(if (is.null(run_set)) NULL else run_set$comparison)
  })

  output$sensitivity_scenario_cards <- renderUI({
    run_set <- sensitivity_run_set()
    scenario_card_grid(if (is.null(run_set)) NULL else run_set$comparison)
  })

  output$diagnostic_table <- renderTable({
    run_set <- active_run_set()
    if (is.null(run_set)) {
      return(data.frame(Scenario = character(), Message = character()))
    }
    rows <- do.call(
      rbind,
      lapply(run_set$runs, function(run) {
        diagnostics <- run$diagnostics
        if (!nrow(diagnostics)) {
          return(data.frame(
            Scenario = run$label,
            Message = "No major diagnostic warning for this scenario. Keep assumptions visible.",
            stringsAsFactors = FALSE
          ))
        }
        data.frame(
          Scenario = diagnostics$scenario,
          Message = diagnostics$message,
          stringsAsFactors = FALSE
        )
      })
    )
    rownames(rows) <- NULL
    rows
  }, striped = TRUE, bordered = TRUE, spacing = "s")

  evidence_export <- reactive({
    req(active_run_set())
    rPVA::build_woodhen_management_evidence_export(
      active_run_set(),
      seed = 123,
      interpretation = input$woodhen_interpretation
    )
  })

  output$download_woodhen_comparison <- downloadHandler(
    filename = function() paste0("woodhen-management-comparison-", Sys.Date(), ".csv"),
    content = function(file) {
      utils::write.csv(evidence_export()$comparison, file, row.names = FALSE)
    }
  )

  output$download_woodhen_evidence <- downloadHandler(
    filename = function() paste0("woodhen-management-evidence-notes-", Sys.Date(), ".md"),
    content = function(file) {
      writeLines(evidence_export()$notes, file)
    }
  )
}

shinyApp(ui, server)
