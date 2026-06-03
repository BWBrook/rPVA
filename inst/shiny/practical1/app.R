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

ui <- navbarPage(
  title = "Practical 1 PVA",
  id = "section",
  header = tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")),
  tabPanel(
    "Start",
    div(
      class = "page-shell",
      div(
        class = "intro-grid",
        div(
          class = "panel-block",
          h2("Island rail concept lab"),
          p("Use a simple three-stage island rail to see how PVA turns assumptions into many possible futures."),
          div(
            class = "species-strip",
            div(class = "life-stage", strong("Juveniles"), p(class = "muted", "New recruits enter the population.")),
            div(class = "life-stage", strong("Subadults"), p(class = "muted", "Young birds survive and move toward breeding.")),
            div(class = "life-stage", strong("Adults"), p(class = "muted", "Adults survive, stay, and produce recruits."))
          ),
          actionButton("run_baseline", label = tagList(icon("play"), "Start baseline"), class = "btn-primary"),
          p(class = "muted", "Prepares you for Woodhen.")
        ),
        div(
          class = "panel-block",
          h3("Baseline output"),
          uiOutput("start_summary"),
          div(class = "prompt", "First question: which output would you use to describe abundance at the end of the projection?")
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
          selectInput("stage", "Teaching stage", choices = stage_choices, selected = default_stage),
          uiOutput("stage_text"),
          uiOutput("stage_controls"),
          actionButton("run_stage", label = tagList(icon("play"), "Run stage"), class = "btn-primary"),
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
          div(class = "compare-table", tableOutput("comparison_table")),
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

  observeEvent(input$run_baseline, {
    baseline_run <- run_stage(default_stage)
    current_run(baseline_run)
    run_history(list(baseline_run))
    updateNavbarPage(session, "section", selected = "Concept Lab")
    updateSelectInput(session, "stage", selected = default_stage)
  })

  observeEvent(input$run_stage, {
    stage <- input$stage
    run <- run_stage(stage, stage_control_values(stage, input))
    current_run(run)
    run_history(c(run_history(), list(run)))
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
      p(strong(stage_questions[[stage]])),
      p(class = "muted", info$concept[[1]])
    )
  })

  output$stage_controls <- renderUI({
    stage_control_ui(input$stage)
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
    rPVA::compare_teaching_runs(run_history())
  }, striped = TRUE, bordered = TRUE, spacing = "s")
}

shinyApp(ui, server)
