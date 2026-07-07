library(shiny)

catalog <- rPVA::teaching_stage_catalog()
implemented <- catalog[catalog$implemented, , drop = FALSE]
deferred <- catalog[!catalog$implemented, , drop = FALSE]

stage_choices <- stats::setNames(implemented$stage, implemented$label)
stage_questions <- c(
  deterministic_baseline = "What does a fixed life cycle do when nothing is random?",
  carrying_capacity = "How does a habitat ceiling change an otherwise favourable projection?",
  demographic_stochasticity = "How much do individual births and deaths matter in a small population?",
  environmental_stochasticity = "What happens when good and bad years affect the whole population?",
  genetic_stochasticity = "How can inbreeding and small population size compound recovery limits?",
  catastrophe = "Can rare bad years dominate risk even when ordinary years look acceptable?",
  intervention = "Does a bounded habitat improvement change risk, abundance, and uncertainty?",
  extinction_vortex = "What changes when several small-population pressures act together?"
)
stage_prompts <- c(
  deterministic_baseline = "Use this as the reference run. Later runs should be compared against it.",
  carrying_capacity = "Look for flattening trajectories and final abundance near a ceiling.",
  demographic_stochasticity = "Notice whether replicate paths stay together or spread apart.",
  environmental_stochasticity = "Focus on the uncertainty interval as well as the median.",
  genetic_stochasticity = "Check whether risk appears even when the habitat ceiling is unchanged.",
  catastrophe = "Compare extinction risk with the baseline, not just the final median.",
  intervention = "Ask whether abundance improves without ignoring remaining uncertainty.",
  extinction_vortex = "Use this as a warning that mechanisms can reinforce each other."
)
stage_missions <- c(
  deterministic_baseline = "Mission 1: Baseline compass",
  carrying_capacity = "Mission 2: Island ceiling",
  demographic_stochasticity = "Mission 3: Individual chance",
  environmental_stochasticity = "Mission 4: Shared bad years",
  genetic_stochasticity = "Mission 5: Small-population pressure",
  catastrophe = "Mission 6: Rare bad years",
  intervention = "Mission 7a: Rescue attempt",
  extinction_vortex = "Mission 7b: Vortex comparison"
)
stage_mission_guidance <- c(
  deterministic_baseline = "Use this stage only as a recovery run after resetting comparison.",
  carrying_capacity = "Change one visible control, then compare with baseline run 1.",
  demographic_stochasticity = "Keep the habitat setting close to Mission 2 so individual chance is the main change.",
  environmental_stochasticity = "Adjust bad-year variation, then compare uncertainty with earlier runs.",
  genetic_stochasticity = "Change one small-population pressure and watch risk as well as abundance.",
  catastrophe = "Change catastrophe chance or severity, not both, before comparing risk.",
  intervention = "Treat intervention as evidence comparison, not an automatic win.",
  extinction_vortex = "Use this as the compounded-risk contrast for your final comparison."
)
risk_plot_stages <- c("genetic_stochasticity", "catastrophe", "extinction_vortex")

default_stage <- "deterministic_baseline"

run_stage <- function(stage, controls = list()) {
  rPVA::run_teaching_pva(stage, controls = controls, keep_traj = TRUE, seed = 42)
}

summary_metrics <- function(run) {
  summary <- run$summary
  list(
    "Scenario" = summary$scenario,
    "Years" = summary$years,
    "Extinction risk" = sprintf("%.2f", summary$PE),
    "Median final N" = summary$Nmed,
    "Uncertainty" = paste0(summary$Nlo95, "-", summary$Nhi95)
  )
}

summary_metric_ui <- function(run) {
  metrics <- summary_metrics(run)
  div(
    class = "summary-grid",
    lapply(names(metrics), function(name) {
      div(
        class = "summary-metric",
        span(class = "metric-label", name),
        span(class = "metric-value", metrics[[name]])
      )
    })
  )
}

settings_for_display <- function(run) {
  out <- run$settings
  if (!nrow(out)) {
    return(data.frame(Setting = character(), Value = character()))
  }
  data.frame(
    Setting = out$setting,
    Value = out$value,
    stringsAsFactors = FALSE
  )
}

diagnostics_ui <- function(run) {
  diagnostics <- run$diagnostics
  if (!nrow(diagnostics)) {
    return(tags$p(class = "muted", "No major diagnostic warnings for this run. Keep comparing assumptions."))
  }
  tags$ul(
    class = "diagnostic-list",
    lapply(seq_len(nrow(diagnostics)), function(i) {
      tags$li(
        class = if (identical(diagnostics$severity[[i]], "warning")) "risk-note" else NULL,
        diagnostics$message[[i]]
      )
    })
  )
}

stage_control_ui <- function(stage) {
  switch(
    stage,
    deterministic_baseline = tagList(
      sliderInput("years", "Projection years", min = 10, max = 80, value = 25, step = 5)
    ),
    carrying_capacity = tagList(
      sliderInput("K", "Habitat ceiling", min = 20, max = 120, value = 35, step = 5),
      sliderInput("K_sd", "Yearly ceiling variation", min = 0, max = 20, value = 0, step = 1)
    ),
    demographic_stochasticity = tagList(
      sliderInput("K", "Habitat ceiling", min = 20, max = 120, value = 35, step = 5),
      sliderInput("reps", "Simulation futures", min = 20, max = 200, value = 100, step = 20)
    ),
    environmental_stochasticity = tagList(
      sliderInput("env_sd", "Bad-year variation", min = 0.05, max = 0.35, value = 0.25, step = 0.05),
      sliderInput("K", "Habitat ceiling", min = 20, max = 120, value = 35, step = 5)
    ),
    genetic_stochasticity = tagList(
      sliderInput("F_init", "Starting inbreeding", min = 0, max = 0.40, value = 0.10, step = 0.05),
      sliderInput("env_sd", "Bad-year variation", min = 0.05, max = 0.35, value = 0.25, step = 0.05)
    ),
    catastrophe = tagList(
      sliderInput("cat_freq", "Catastrophe chance each year", min = 0, max = 0.20, value = 0.05, step = 0.01),
      sliderInput("cat_surv", "Survival multiplier in catastrophe years", min = 0.20, max = 1, value = 0.60, step = 0.05)
    ),
    intervention = tagList(
      sliderInput("K", "Improved habitat ceiling", min = 35, max = 160, value = 70, step = 5),
      sliderInput("K_sd", "Yearly ceiling variation", min = 0, max = 20, value = 5, step = 1)
    ),
    extinction_vortex = tagList(
      sliderInput("K", "Restricted habitat ceiling", min = 12, max = 60, value = 25, step = 2),
      sliderInput("cat_freq", "Catastrophe chance each year", min = 0, max = 0.15, value = 0.05, step = 0.01)
    )
  )
}

visible_stage_controls <- function(stage) {
  switch(
    stage,
    deterministic_baseline = "years",
    carrying_capacity = c("K", "K_sd"),
    demographic_stochasticity = c("K", "reps"),
    environmental_stochasticity = c("env_sd", "K"),
    genetic_stochasticity = c("F_init", "env_sd"),
    catastrophe = c("cat_freq", "cat_surv"),
    intervention = c("K", "K_sd"),
    extinction_vortex = c("K", "cat_freq"),
    character()
  )
}

stage_control_values <- function(stage, input) {
  allowed <- visible_stage_controls(stage)
  values <- list()
  for (name in allowed) {
    if (!is.null(input[[name]])) {
      values[[name]] <- input[[name]]
    }
  }
  values
}

landing_card_ui <- function(image, alt, eyebrow, title, body, action = NULL, extra_class = NULL) {
  card_class <- paste(c("landing-card", extra_class), collapse = " ")

  div(
    class = card_class,
    div(
      class = "landing-visual",
      tags$img(src = image, alt = alt)
    ),
    div(
      class = "landing-card-copy",
      span(class = "landing-eyebrow", eyebrow),
      h3(title),
      p(body),
      action
    )
  )
}

mission_rail_ui <- function(current_stage, completed_stages = character()) {
  div(
    class = "mission-rail",
    lapply(seq_len(nrow(implemented)), function(i) {
      stage <- implemented$stage[[i]]
      step_class <- paste(c(
        "mission-step",
        if (identical(stage, current_stage)) "is-current",
        if (stage %in% completed_stages) "is-complete"
      ), collapse = " ")

      div(
        class = step_class,
        span(class = "mission-step-index", i),
        span(class = "mission-step-label", stage_missions[[stage]])
      )
    })
  )
}

next_mission_stage <- function(stage) {
  current <- match(stage, implemented$stage)
  if (is.na(current)) {
    return(default_stage)
  }
  implemented$stage[[min(current + 1, nrow(implemented))]]
}

run_changed_settings_label <- function(run) {
  controls <- run$settings[grepl("^control_", run$settings$setting), , drop = FALSE]
  if (!nrow(controls)) {
    return("Reference settings")
  }

  labels <- paste0(sub("^control_", "", controls$setting), " = ", controls$value)
  paste(labels, collapse = "; ")
}

run_cards_ui <- function(runs) {
  comparison <- rPVA::compare_teaching_runs(runs, include_deltas = TRUE)

  div(
    class = "run-card-grid",
    lapply(seq_along(runs), function(i) {
      row <- comparison[i, , drop = FALSE]
      div(
        class = "run-card",
        span(class = "run-card-kicker", paste("Run", i)),
        h4(runs[[i]]$label),
        p(class = "muted", run_changed_settings_label(runs[[i]])),
        div(
          class = "run-card-metrics",
          span(strong("PE"), ": ", sprintf("%.3f", row$PE)),
          span(strong("Nmed"), ": ", row$Nmed),
          span(strong("Delta PE"), ": ", sprintf("%+.3f", row$delta_PE)),
          span(strong("Delta Nmed"), ": ", sprintf("%+d", row$delta_Nmed)),
          span(strong("Uncertainty"), ": ", row$uncertainty_change)
        )
      )
    })
  )
}

pva_deep_dive_path <- file.path("content", "pva-deep-dive.md")
mission_deep_dive_path <- file.path("content", "mission-deep-dive.md")
evidence_deep_dive_path <- file.path("content", "evidence-deep-dive.md")

markdown_unavailable_ui <- function(message) {
  div(
    class = "deep-dive-modal-warning",
    p(strong("Deep-dive note unavailable")),
    p(message)
  )
}

render_markdown_content <- function(path) {
  if (!file.exists(path)) {
    return(markdown_unavailable_ui("The deep-dive note could not be found. Please tell your demonstrator."))
  }

  if (file.access(path, mode = 4) != 0) {
    return(markdown_unavailable_ui("The deep-dive note could not be read. Please tell your demonstrator."))
  }

  if (!requireNamespace("commonmark", quietly = TRUE)) {
    return(markdown_unavailable_ui("The Markdown renderer is unavailable. Please tell your demonstrator."))
  }

  tryCatch(
    {
      markdown_text <- paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
      HTML(commonmark::markdown_html(markdown_text))
    },
    error = function(...) {
      markdown_unavailable_ui("The deep-dive note could not be rendered. Please tell your demonstrator.")
    }
  )
}

deep_dive_modal_ui <- function(title, path) {
  modalDialog(
    title = title,
    div(
      class = "deep-dive-modal",
      render_markdown_content(path)
    ),
    footer = modalButton("Close"),
    easyClose = TRUE,
    size = "m"
  )
}

pva_deep_dive_ui <- function() {
  deep_dive_modal_ui("What is PVA?", pva_deep_dive_path)
}

mission_deep_dive_ui <- function() {
  deep_dive_modal_ui("What you will do", mission_deep_dive_path)
}

evidence_deep_dive_ui <- function() {
  deep_dive_modal_ui("Your evidence pack", evidence_deep_dive_path)
}

ui <- navbarPage(
  title = "Practical 1 PVA",
  id = "section",
  header = tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")),
  tabPanel(
    "Start",
    div(
      class = "page-shell",
      div(
        class = "landing-hero",
        div(
          class = "landing-copy",
          span(class = "landing-eyebrow", "Woodhen Practical 1"),
          h1("Practical 1 PVA mission"),
          p(class = "landing-lede", "PVA is a way to test how a population might change when survival, breeding, habitat, and chance interact."),
          p("You will build a short chain of model runs, compare what changed, and save evidence for discussion."),
          actionButton("run_baseline", label = tagList(icon("play"), "Start baseline"), class = "btn-primary"),
          div(
            class = "mission-cue landing-start-cue",
            span(class = "mission-label", "Mission 1: Baseline compass"),
            p("Start baseline creates or restores baseline as run 1."),
            p(class = "muted", "Keep run 1 as your reference before changing controls.")
          )
        ),
        div(
          class = "landing-hero-visual",
          tags$img(
            src = "img/landing-woodhen-population.png",
            alt = "Lord Howe woodhen-like bird in island forest with a small background population"
          )
        )
      ),
      div(
        class = "landing-card-grid",
        landing_card_ui(
          "img/landing-trajectory-evidence.png",
          "population trajectory lines and evidence marks on a field notebook page",
          "Plain language",
          "What is PVA?",
          "A population viability analysis explores possible futures, not a single forecast.",
          action = actionButton(
            "open_pva_deep_dive",
            label = "Explore PVA",
            icon = icon("circle-info"),
            class = "btn-default landing-card-action",
            `aria-label` = "Explore population viability analysis"
          ),
          extra_class = "is-interactive"
        ),
        landing_card_ui(
          "img/landing-conservation-decision.png",
          "conservation decision scene with island habitat map and field notes",
          "Your mission",
          "What you will do",
          "Run the baseline, change one factor at a time, compare results, and explain the tradeoffs.",
          action = actionButton(
            "open_mission_deep_dive",
            label = "Explore mission",
            icon = icon("route"),
            class = "btn-default landing-card-action",
            `aria-label` = "Explore the Practical 1 mission"
          ),
          extra_class = "is-interactive"
        ),
        div(
          class = "landing-card evidence-card is-interactive",
          div(
            class = "landing-card-copy",
            span(class = "landing-eyebrow", "Evidence to save"),
            h3("Your evidence pack"),
            tags$ul(
              tags$li("a comparison CSV from Compare;"),
              tags$li("evidence notes Markdown;"),
              tags$li("one sentence about what changed and why it matters.")
            ),
            actionButton(
              "open_evidence_deep_dive",
              label = "Explore evidence",
              icon = icon("download"),
              class = "btn-default landing-card-action",
              `aria-label` = "Explore the Practical 1 evidence pack"
            )
          )
        )
      )
    )
  ),
  tabPanel(
    "Concept Lab",
    div(
      class = "page-shell",
      div(
        class = "lab-grid",
        div(
          class = "panel-block",
          h3("Choose one mechanism"),
          p(class = "mission-path", "Work through the mission path by changing one visible control at a time, then compare."),
          actionButton("show_intro", label = tagList(icon("circle-info"), "Introduction"), class = "btn-default btn-sm"),
          uiOutput("mission_rail"),
          selectInput("stage", "Teaching stage", choices = stage_choices, selected = default_stage),
          uiOutput("stage_text"),
          uiOutput("stage_controls"),
          actionButton("run_stage", label = tagList(icon("play"), "Run stage"), class = "btn-primary"),
          actionButton("next_mission", label = tagList(icon("arrow-right"), "Next mission"), class = "btn-default"),
          div(class = "prompt", textOutput("stage_prompt"))
        ),
        div(
          class = "panel-block output-region",
          h3("Current run"),
          uiOutput("summary_table"),
          h4("Diagnostics"),
          uiOutput("diagnostics"),
          h4("Settings record"),
          div(class = "settings-table", tableOutput("settings_table"))
        )
      ),
      div(
        class = "panel-block plot-region",
        h3("Plots"),
        fluidRow(
          column(6, plotOutput("trajectory_plot", height = "320px")),
          column(6, plotOutput("summary_plot", height = "320px"))
        ),
        uiOutput("extinction_plot_panel")
      )
    )
  ),
  tabPanel(
    "Compare",
    div(
      class = "page-shell",
      div(
        class = "compare-grid",
        div(
          class = "panel-block",
          h3("Run comparison"),
          div(
            class = "mission-cue compare-guidance",
            span(class = "mission-label", "Compare mission evidence"),
            p("Choose a clean comparison: baseline run 1, one risk mechanism, and one intervention or vortex run."),
            p(class = "muted", "Repeated clicks are less useful than a targeted one-factor change.")
          ),
          uiOutput("run_cards"),
          div(class = "compare-table", tableOutput("comparison_table")),
          div(
            class = "interpretation-capture",
            textAreaInput("interpretation_note",
              "One-sentence interpretation",
              value = "",
              placeholder = "I changed... The output that moved was... My caveat is...",
              rows = 3
            )
          ),
          h4("Save evidence"),
          p(class = "muted", "Download a compact comparison table and notes for your own report. These files are evidence, not an answer."),
          div(
            class = "export-actions",
            downloadButton("download_comparison", "Comparison CSV"),
            downloadButton("download_evidence_notes", "Evidence notes")
          ),
          actionButton("clear_runs", label = tagList(icon("trash"), "Reset comparison")),
          div(class = "prompt", "What changed between runs, and which output supports your explanation?")
        ),
        div(
          class = "panel-block",
          h3("Comparison habits"),
          tags$ul(
            tags$li("Compare extinction risk and abundance together."),
            tags$li("Treat zero observed extinction as a simulation result, not proof of safety."),
            tags$li("Use uncertainty intervals when judging management actions.")
          )
        )
      )
    )
  ),
  tabPanel(
    "Transfer",
    div(
      class = "page-shell",
      div(
        class = "panel-block",
        h2("Transfer to the Woodhen practical"),
        p("You have explored deterministic growth, carrying capacity, stochasticity, catastrophes, genetics, intervention, and combined small-population risk."),
        tags$ol(
          tags$li("Which output shows extinction risk?"),
          tags$li("Which output shows abundance?"),
          tags$li("Which output shows uncertainty?")
        ),
        p("In Practical 2 you will use the same evidence habits with the Woodhen case study: compare scenarios, explain uncertainty, and make a recommendation from the model results."),
        h3("Future concepts"),
        tags$ul(
          class = "future-list",
          lapply(seq_len(nrow(deferred)), function(i) {
            tags$li(strong(deferred$label[[i]]), ": ", deferred$concept[[i]])
          })
        )
      )
    )
  )
)

server <- function(input, output, session) {
  baseline <- run_stage(default_stage)
  current_run <- reactiveVal(baseline)
  run_history <- reactiveVal(list(baseline))
  evidence_export <- reactive({
    rPVA:::build_teaching_evidence_export(run_history(), interpretation = input$interpretation_note)
  })

  observeEvent(input$run_baseline, {
    baseline_run <- run_stage(default_stage)
    current_run(baseline_run)
    run_history(list(baseline_run))
    updateNavbarPage(session, "section", selected = "Concept Lab")
    updateSelectInput(session, "stage", selected = default_stage)
  })

  observeEvent(input$show_intro, {
    updateNavbarPage(session, "section", selected = "Start")
  })

  observeEvent(input$open_pva_deep_dive, {
    showModal(pva_deep_dive_ui())
  })

  observeEvent(input$open_mission_deep_dive, {
    showModal(mission_deep_dive_ui())
  })

  observeEvent(input$open_evidence_deep_dive, {
    showModal(evidence_deep_dive_ui())
  })

  observeEvent(input$run_stage, {
    stage <- input$stage
    withProgress(message = "Running mission", value = 0.5, {
      run <- run_stage(stage, stage_control_values(stage, input))
      current_run(run)
      run_history(c(run_history(), list(run)))
    })
  })

  observeEvent(input$next_mission, {
    updateSelectInput(session, "stage", selected = next_mission_stage(input$stage))
  })

  observeEvent(input$clear_runs, {
    baseline_run <- run_stage(default_stage)
    current_run(baseline_run)
    run_history(list(baseline_run))
    updateSelectInput(session, "stage", selected = default_stage)
  })

  output$stage_text <- renderUI({
    stage <- input$stage
    info <- implemented[implemented$stage == stage, , drop = FALSE]
    tagList(
      div(class = "stage-badge", info$label[[1]]),
      div(
        class = "mission-cue",
        span(class = "mission-label", stage_missions[[stage]]),
        p(strong(stage_questions[[stage]])),
        p(class = "mission-guidance", stage_mission_guidance[[stage]])
      ),
      p(class = "muted", info$concept[[1]])
    )
  })

  output$stage_controls <- renderUI({
    stage_control_ui(input$stage)
  })

  output$mission_rail <- renderUI({
    stage <- input$stage
    if (is.null(stage) || !nzchar(stage)) {
      stage <- default_stage
    }
    completed <- vapply(run_history(), `[[`, character(1), "stage")
    mission_rail_ui(stage, completed)
  })

  output$stage_prompt <- renderText({
    stage_prompts[[input$stage]]
  })

  output$start_summary <- renderUI({
    summary_metric_ui(current_run())
  })

  output$summary_table <- renderUI({
    summary_metric_ui(current_run())
  })

  output$settings_table <- renderTable({
    settings_for_display(current_run())
  }, striped = TRUE, bordered = TRUE, spacing = "s")

  output$diagnostics <- renderUI({
    diagnostics_ui(current_run())
  })

  output$trajectory_plot <- renderPlot({
    rPVA::plot_pva_traj(current_run()$result, alpha = 0.28, sample = 40, raster = FALSE)
  })

  output$summary_plot <- renderPlot({
    rPVA::plot_pva_summary(current_run()$result)
  })

  output$extinction_plot_panel <- renderUI({
    if (!current_run()$stage %in% risk_plot_stages) {
      return(NULL)
    }
    tagList(
      h4("Risk detail"),
      plotOutput("extinction_plot", height = "300px")
    )
  })

  output$extinction_plot <- renderPlot({
    req(current_run()$stage %in% risk_plot_stages)
    rPVA::plot_ext(current_run()$result)
  })

  output$comparison_table <- renderTable({
    rPVA::compare_teaching_runs(run_history(), include_deltas = TRUE)
  }, striped = TRUE, bordered = TRUE, spacing = "s")

  output$run_cards <- renderUI({
    run_cards_ui(run_history())
  })

  output$download_comparison <- downloadHandler(
    filename = function() {
      paste0("practical1-comparison-", format(Sys.Date(), "%Y%m%d"), ".csv")
    },
    content = function(file) {
      utils::write.csv(evidence_export()$comparison, file, row.names = FALSE)
    }
  )

  output$download_evidence_notes <- downloadHandler(
    filename = function() {
      paste0("practical1-evidence-notes-", format(Sys.Date(), "%Y%m%d"), ".md")
    },
    content = function(file) {
      writeLines(evidence_export()$notes, file, useBytes = TRUE)
    }
  )
}

shinyApp(ui, server)
