library(shiny)

catalog <- rPVA::woodhen_management_catalog()
core_scenario_ids <- c("01_no_mgmt", "02_pig_control", "03_captive_pig", "04_rodent_eradication", "05_future_baseline")
sensitivity_scenario_ids <- c(
  "sensitivity_default",
  "survival_minus_10pct",
  "K_250",
  "K_350",
  "cat_freq_0.10",
  "cat_surv_0.40",
  "fecund_minus_20pct",
  "juvenile_survival_minus_15pct",
  "env_sd_0.15"
)
sensitivity_default_ids <- c("sensitivity_default", "survival_minus_10pct", "K_250", "cat_freq_0.10")

core_catalog <- catalog[catalog$scenario_id %in% core_scenario_ids, , drop = FALSE]
sensitivity_catalog <- catalog[catalog$scenario_id %in% sensitivity_scenario_ids, , drop = FALSE]

core_choices <- stats::setNames(core_catalog$scenario_id, core_catalog$label)
sensitivity_choices <- stats::setNames(sensitivity_catalog$scenario_id, sensitivity_catalog$label)
student_sensitivity_choices <- stats::setNames(
  sensitivity_catalog$scenario_id[sensitivity_catalog$scenario_id != "sensitivity_default"],
  sensitivity_catalog$label[sensitivity_catalog$scenario_id != "sensitivity_default"]
)

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

  horizon_warning <- NULL
  if (length(unique(comparison$years)) > 1) {
    horizon_warning <- div(
      class = "horizon-warning",
      strong("Compare horizons before ranking scenarios. "),
      "These rows use different time spans, so cite each horizon with its result."
    )
  }

  tagList(
    horizon_warning,
    div(
      class = "scenario-card-grid",
      lapply(seq_len(nrow(comparison)), function(i) {
        row <- comparison[i, , drop = FALSE]
        pe_note <- NULL
        if (isTRUE(row$PE == 0)) {
          pe_note <- p(
            class = "pe-note",
            "PE = 0 means zero observed extinctions in this simulation, with this seed and replicate count."
          )
        }
        div(
          class = "scenario-card",
          span(class = "scenario-card-kicker", row$section),
          h3(row$label),
          p(class = "muted", row$change_label),
          p(class = "muted", row$horizon_note),
          div(
            class = "scenario-card-metrics",
            span(strong("PE"), ": ", sprintf("%.3f", row$PE)),
            span(strong("Nmed"), ": ", row$Nmed),
            span(strong("95% interval"), ": ", paste0(row$Nlo95, "-", row$Nhi95))
          ),
          pe_note,
          div(
            class = "evidence-prompt",
            strong("Use this as evidence: "),
            row$evidence_prompt
          )
        )
      })
    )
  )
}

scenario_help_panel <- function(rows, title) {
  div(
    class = "scenario-help-list",
    h4(title),
    lapply(seq_len(nrow(rows)), function(i) {
      row <- rows[i, , drop = FALSE]
      div(
        class = "scenario-help",
        strong(if (identical(row$section, "core_management")) "What changed?" else "Why test this?"),
        span(" ", row$label),
        p(row$teaching_note),
        p(class = "muted", row$choice_prompt)
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
  out[, c("scenario_id", "label", "years", "reps", "PE", "Nmed", "Nlo95", "Nhi95", "changed_parameter", "change_label", "horizon_note"), drop = FALSE]
}

comparison_table_for_export <- function(run_set) {
  if (is.null(run_set)) {
    return(data.frame())
  }

  out <- run_set$comparison
  out[, c("scenario_id", "section", "label", "years", "reps", "PE", "Nmed", "Nlo95", "Nhi95", "changed_parameter", "change_label"), drop = FALSE]
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
    ),
    uiOutput("active_report_bridge")
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
          p(class = "muted", "Run the full set first, then rerun a smaller set if your comparison needs focus."),
          scenario_help_panel(core_catalog, "Scenario guide")
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
            selected = sensitivity_default_ids
          ),
          h3("Your sensitivity choice"),
          selectInput(
            "chosen_sensitivity_focus",
            "Chosen sensitivity ID",
            choices = student_sensitivity_choices
          ),
          selectInput(
            "decision_lens",
            "Decision lens",
            choices = c(
              "reduce near-term extinction risk",
              "maximise long-term abundance",
              "test robustness to future uncertainty",
              "identify monitoring priorities",
              "balance model support with implementation constraints"
            )
          ),
          textAreaInput("sensitivity_reason", "Biological reason", value = "", rows = 3, width = "100%"),
          textAreaInput("expected_direction", "Expected direction before reading the result", value = "", rows = 3, width = "100%"),
          textAreaInput("observed_result", "Observed result", value = "", rows = 3, width = "100%"),
          textAreaInput("confidence_change", "How this changed confidence", value = "", rows = 3, width = "100%"),
          textAreaInput("choice_caveat", "Choice caveat", value = "", rows = 3, width = "100%"),
          actionButton("run_sensitivity_scenarios", "Run sensitivity scenarios", class = "btn-primary"),
          p(class = "muted", "Each preset changes one factor so the result remains interpretable."),
          scenario_help_panel(sensitivity_catalog, "Sensitivity guide")
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
      p("Save the core comparison CSV, sensitivity comparison CSV, and evidence-notes Markdown after you have run both scenario sets."),
      p(class = "muted", "This export contains core management results and bounded sensitivity results. Check both sections before writing your report."),
      textAreaInput("woodhen_interpretation", "Draft interpretation note", value = "", rows = 5, width = "100%"),
      div(
        class = "download-row",
        downloadButton("download_woodhen_core_comparison", "Download core comparison CSV"),
        downloadButton("download_woodhen_sensitivity_comparison", "Download sensitivity comparison CSV"),
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
      selected <- unique(c("sensitivity_default", input$sensitivity_scenarios, input$chosen_sensitivity_focus))
      run_set <- rPVA::run_woodhen_management_set(selected, keep_traj = FALSE, seed = 123, verbose = FALSE)
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

  choice_note <- reactive({
    list(
      decision_lens = input$decision_lens,
      chosen_sensitivity = input$chosen_sensitivity_focus,
      biological_reason = input$sensitivity_reason,
      expected_direction = input$expected_direction,
      observed_result = input$observed_result,
      confidence_change = input$confidence_change,
      caveat = input$choice_caveat
    )
  })

  available_run_sets <- reactive({
    Filter(Negate(is.null), list(core_run_set(), sensitivity_run_set()))
  })

  combined_comparison <- reactive({
    run_sets <- available_run_sets()
    if (!length(run_sets)) {
      return(data.frame())
    }
    out <- do.call(rbind, lapply(run_sets, `[[`, "comparison"))
    rownames(out) <- NULL
    out
  })

  evidence_export <- reactive({
    req(length(available_run_sets()) > 0)
    rPVA::build_woodhen_management_evidence_export(
      available_run_sets(),
      seed = 123,
      interpretation = input$woodhen_interpretation,
      choice_note = choice_note()
    )
  })

  output$download_woodhen_core_comparison <- downloadHandler(
    filename = function() paste0("woodhen-core-management-comparison-", Sys.Date(), ".csv"),
    content = function(file) {
      req(core_run_set())
      utils::write.csv(comparison_table_for_export(core_run_set()), file, row.names = FALSE)
    }
  )

  output$download_woodhen_sensitivity_comparison <- downloadHandler(
    filename = function() paste0("woodhen-sensitivity-comparison-", Sys.Date(), ".csv"),
    content = function(file) {
      req(sensitivity_run_set())
      utils::write.csv(comparison_table_for_export(sensitivity_run_set()), file, row.names = FALSE)
    }
  )

  output$download_woodhen_evidence <- downloadHandler(
    filename = function() paste0("woodhen-management-evidence-notes-", Sys.Date(), ".md"),
    content = function(file) {
      writeLines(evidence_export()$notes, file)
    }
  )

  output$active_report_bridge <- renderUI({
    comparison <- combined_comparison()
    if (!nrow(comparison)) {
      return(p(class = "muted", "Run the core and sensitivity scenarios before using this bridge."))
    }

    chosen <- comparison[comparison$scenario_id == input$chosen_sensitivity_focus, , drop = FALSE]
    tagList(
      h3("Active evidence bridge"),
      p("Use one row as evidence: quote PE, Nmed, the 95% interval, and the horizon."),
      if (nrow(chosen)) {
        div(
          class = "active-evidence-row",
          strong(chosen$label[[1]]),
          p(paste0(
            "PE ", sprintf("%.3f", chosen$PE[[1]]),
            "; Nmed ", chosen$Nmed[[1]],
            "; 95% interval ", chosen$Nlo95[[1]], "-",
            chosen$Nhi95[[1]],
            "; horizon ", chosen$years[[1]], " years."
          )),
          p("Name the result that changed your confidence. Then state the caveat that limits that confidence.")
        )
      } else {
        p(class = "muted", "Run the chosen sensitivity preset to populate this evidence row.")
      }
    )
  })
}

shinyApp(ui, server)
