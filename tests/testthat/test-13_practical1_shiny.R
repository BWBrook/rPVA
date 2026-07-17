context("Practical 1 Shiny app")

test_that("Practical 1 Shiny files are present", {
  app_dir <- system.file("shiny", "practical1", package = "rPVA")

  expect_true(dir.exists(app_dir))
  expect_true(file.exists(file.path(app_dir, "app.R")))
  expect_true(file.exists(file.path(app_dir, "www", "styles.css")))
  expect_true(file.exists(file.path(app_dir, "README.md")))
})

test_that("launcher exposes the expected app directory and arguments", {
  app_dir <- rPVA:::practical1_shiny_app_dir()

  expect_true(dir.exists(app_dir))
  expect_true(file.exists(file.path(app_dir, "app.R")))
  expect_true(all(c("host", "port", "launch.browser", "...") %in% names(formals(run_practical1_shiny))))
})

test_that("Practical 1 app can be constructed non-interactively", {
  testthat::skip_if_not_installed("shiny")

  app_dir <- rPVA:::practical1_shiny_app_dir()
  before <- list.files(".", all.files = TRUE, recursive = FALSE)
  app <- shiny::shinyAppDir(app_dir)
  after <- list.files(".", all.files = TRUE, recursive = FALSE)

  expect_s3_class(app, "shiny.appobj")
  expect_equal(after, before)
  expect_no_local_artifacts()
})

test_that("default app teaching run is valid and Shiny-ready", {
  run <- run_teaching_pva("deterministic_baseline", keep_traj = TRUE, seed = 42)

  expect_s3_class(run, "teaching_pva_run")
  expect_equal(run$stage, "deterministic_baseline")
  expect_true(isTRUE(run$summary$trajectory_available))
  expect_s3_class(run$summary, "data.frame")
  expect_s3_class(run$diagnostics, "data.frame")
})

test_that("server declares display-only baseline and explicit session progress state", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")

  expect_true(file.exists(file.path(app_dir, "session_helpers.R")))
  expect_true(grepl('source("session_helpers.R", local = TRUE)', app_text, fixed = TRUE))
  expect_true(grepl("baseline_run <- reactiveVal(reference_baseline)", app_text, fixed = TRUE))
  expect_true(grepl("current_run <- reactiveVal(reference_baseline)", app_text, fixed = TRUE))
  expect_true(grepl("run_history <- reactiveVal(list())", app_text, fixed = TRUE))
  expect_true(grepl("next_run_id <- reactiveVal(1L)", app_text, fixed = TRUE))
  expect_true(grepl("baseline_started <- reactiveVal(FALSE)", app_text, fixed = TRUE))
  expect_true(grepl("selected_stage <- reactiveVal(default_stage)", app_text, fixed = TRUE))
  expect_false(grepl("reactiveVal(baseline_run())", app_text, fixed = TRUE))
  expect_false(grepl('selectInput("stage"', app_text, fixed = TRUE))
})

test_that("app file avoids unsupported implementation markers", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- readLines(file.path(app_dir, "app.R"), warn = FALSE)
  style_text <- readLines(file.path(app_dir, "www", "styles.css"), warn = FALSE)

  marker_pattern <- paste(c("TO", "DO|T", "BD|PLACE", "HOLDER"), collapse = "")
  expect_false(any(grepl(marker_pattern, c(app_text, style_text))))
})

test_that("risk evidence is server-rendered before population projections", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")

  expect_true(grepl('uiOutput("risk_plot_panel")', app_text, fixed = TRUE))
  expect_true(grepl("output$risk_plot_panel <- renderUI", app_text, fixed = TRUE))
  risk_position <- regexpr('h3("Risk evidence")', app_text, fixed = TRUE)[[1]]
  population_position <- regexpr('h3("Population projections")', app_text, fixed = TRUE)[[1]]
  expect_gt(risk_position, 0L)
  expect_gt(population_position, risk_position)
  expect_false(grepl("output.showExtinctionPlot", app_text, fixed = TRUE))
})

test_that("risk panel distinguishes deterministic, stochastic, and missing-K states", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)

  deterministic <- env$run_stage("deterministic_baseline")
  deterministic_html <- paste(as.character(env$risk_plot_panel_ui(deterministic)), collapse = "\n")
  expect_match(deterministic_html, "One fixed projection cannot estimate probability", fixed = TRUE)

  stochastic <- env$run_stage(
    "demographic_stochasticity",
    controls = list(K = 35, reps = 20)
  )
  stochastic_html <- paste(as.character(env$risk_plot_panel_ui(stochastic)), collapse = "\n")
  expect_match(stochastic_html, 'id="extinction_plot"', fixed = TRUE)
  expect_match(stochastic_html, 'id="quasi_extinction_plot"', fixed = TRUE)

  stochastic$spec$K <- NA_real_
  no_K_html <- paste(as.character(env$risk_plot_panel_ui(stochastic)), collapse = "\n")
  expect_match(no_K_html, "Quasi-extinction risk needs a finite habitat ceiling", fixed = TRUE)
})

test_that("comparison reset realigns the stage selector", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")

  expect_true(grepl("observeEvent(input$clear_runs", app_text, fixed = TRUE))
  expect_true(grepl("selected_stage(default_stage)", app_text, fixed = TRUE))
})

test_that("stage runs collect only visible controls", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")

  expect_match(app_text, "visible_stage_controls <- function\\(stage, advanced = FALSE\\)")
  expect_true(grepl("stage_control_values <- function(stage, input, advanced = FALSE)", app_text, fixed = TRUE))
  expect_true(grepl("allowed <- visible_stage_controls(stage, advanced = advanced)", app_text, fixed = TRUE))
  expect_false(grepl("strsplit\\(implemented\\$controls", app_text))
})

test_that("comparison view exposes compact evidence downloads", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")

  expect_true(grepl('downloadButton("download_comparison"', app_text, fixed = TRUE))
  expect_true(grepl('downloadButton("download_evidence_notes"', app_text, fixed = TRUE))
  expect_true(grepl("output$download_comparison <- downloadHandler", app_text, fixed = TRUE))
  expect_true(grepl("output$download_evidence_notes <- downloadHandler", app_text, fixed = TRUE))
  expect_true(grepl("build_teaching_evidence_export", app_text, fixed = TRUE))
  expect_true(grepl("evidence for your interpretation", app_text, fixed = TRUE))
})

test_that("app exposes mission-mode classroom guidance", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")

  expect_true(grepl("Mission 1: Build your reference", app_text, fixed = TRUE))
  expect_true(grepl("Run 1 uses the starting assumptions. Keep it as the reference for every change that follows.", app_text, fixed = TRUE))
  expect_true(grepl("changing one visible control at a time", app_text, fixed = TRUE))
  expect_true(grepl("Choose a clean comparison: baseline run 1, one risk mechanism, and one intervention or vortex run.", app_text, fixed = TRUE))
  expect_true(grepl("Repeated clicks are less useful than a targeted one-factor change.", app_text, fixed = TRUE))
  expect_true(grepl("Rerun only after changing projection years, mortality, or fecundity; otherwise the same deterministic trajectory repeats.", app_text, fixed = TRUE))
})

test_that("baseline mission action reflects whether run 1 exists", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)

  expect_true(exists("run_stage_action_ui", envir = env, inherits = FALSE))
  before_baseline <- as.character(env$run_stage_action_ui("deterministic_baseline", FALSE))
  after_baseline <- as.character(env$run_stage_action_ui("deterministic_baseline", TRUE))
  another_mission <- as.character(env$run_stage_action_ui("carrying_capacity", TRUE))

  expect_match(before_baseline, "Create baseline on Start", fixed = TRUE)
  expect_match(before_baseline, 'disabled="disabled"', fixed = TRUE)
  expect_match(before_baseline, 'aria-disabled="true"', fixed = TRUE)
  expect_match(after_baseline, "Rerun baseline", fixed = TRUE)
  expect_false(grepl('disabled="disabled"', after_baseline, fixed = TRUE))
  expect_false(grepl('aria-disabled="true"', after_baseline, fixed = TRUE))
  expect_match(another_mission, "Run mission", fixed = TRUE)
  expect_false(grepl('disabled="disabled"', another_mission, fixed = TRUE))
})

test_that("baseline Run mission fallback stays in the Concept Lab", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")
  guard_start <- regexpr("observeEvent(input$run_stage", app_text, fixed = TRUE)[[1]]
  guard_end <- regexpr("observeEvent(input$next_mission", app_text, fixed = TRUE)[[1]]

  expect_gt(guard_start, 0L)
  expect_gt(guard_end, guard_start)
  guard <- substr(app_text, guard_start, guard_end - 1L)

  expect_false(grepl("updateNavbarPage", guard, fixed = TRUE))
  expect_true(grepl("A deterministic run repeats the same population trajectory", guard, fixed = TRUE))
  expect_true(grepl("Create the baseline run on Start before running missions.", guard, fixed = TRUE))
})

test_that("Practical 1 opens with a tutorial landing screen", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")

  expect_true(grepl('class = "landing-hero"', app_text, fixed = TRUE))
  expect_true(grepl("Practical 1: Learning PVA", app_text, fixed = TRUE))
  expect_true(grepl("PVA Basics", app_text, fixed = TRUE))
  expect_false(grepl("Woodhen Practical 1", app_text, fixed = TRUE))
  expect_false(grepl("PVA mission", app_text, fixed = TRUE))
  expect_true(grepl("PVA explores many possible population futures under explicit assumptions", app_text, fixed = TRUE))
  expect_true(grepl("It is not a single forecast.", app_text, fixed = TRUE))
  expect_true(grepl('class = "landing-task-text"', app_text, fixed = TRUE))
  expect_true(grepl("Create a baseline, change one factor at a time, compare the outcomes, and save a short evidence trail.", app_text, fixed = TRUE))
  expect_true(grepl("What you will do", app_text, fixed = TRUE))
  expect_true(grepl("Evidence to save", app_text, fixed = TRUE))
  expect_true(grepl("Mission 1: Build your reference", app_text, fixed = TRUE))
  expect_true(grepl("Create baseline run", app_text, fixed = TRUE))
  expect_true(grepl('actionButton("run_baseline"', app_text, fixed = TRUE))
  expect_false(grepl("later clicks return to run 1", app_text, fixed = TRUE))
  expect_false(grepl("run `Deterministic baseline` again", app_text, fixed = TRUE))
})

test_that("landing cards expose Markdown-backed deep-dives", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")
  style_text <- paste(readLines(file.path(app_dir, "www", "styles.css"), warn = FALSE), collapse = "\n")
  content_paths <- c(
    pva = file.path(app_dir, "content", "pva-deep-dive.md"),
    mission = file.path(app_dir, "content", "mission-deep-dive.md"),
    evidence = file.path(app_dir, "content", "evidence-deep-dive.md")
  )
  content_text <- lapply(content_paths, function(path) {
    if (file.exists(path)) {
      paste(readLines(path, warn = FALSE), collapse = "\n")
    } else {
      ""
    }
  })

  expect_true(all(file.exists(content_paths)))
  expect_true(grepl('pva_deep_dive_path <- file.path("content", "pva-deep-dive.md")', app_text, fixed = TRUE))
  expect_true(grepl('mission_deep_dive_path <- file.path("content", "mission-deep-dive.md")', app_text, fixed = TRUE))
  expect_true(grepl('evidence_deep_dive_path <- file.path("content", "evidence-deep-dive.md")', app_text, fixed = TRUE))
  expect_true(grepl("deep_dive_modal_ui <- function(title, path)", app_text, fixed = TRUE))
  expect_true(grepl("render_markdown_content(path)", app_text, fixed = TRUE))
  expect_true(grepl("pva_deep_dive_ui <- function()", app_text, fixed = TRUE))
  expect_true(grepl("mission_deep_dive_ui <- function()", app_text, fixed = TRUE))
  expect_true(grepl("evidence_deep_dive_ui <- function()", app_text, fixed = TRUE))
  expect_false(grepl("Population viability analysis, or PVA, explores many possible futures under assumptions", app_text, fixed = TRUE))

  expected_triggers <- c(
    "open_pva_deep_dive" = "Explore PVA",
    "open_mission_deep_dive" = "Explore mission",
    "open_evidence_deep_dive" = "Explore evidence"
  )

  for (trigger in names(expected_triggers)) {
    expect_match(app_text, paste0('actionButton\\(\\s*"', trigger, '"'))
    expect_true(grepl(paste0("observeEvent(input$", trigger), app_text, fixed = TRUE))
    expect_true(grepl(expected_triggers[[trigger]], app_text, fixed = TRUE))
  }

  expected_modals <- c(
    "showModal(pva_deep_dive_ui())",
    "showModal(mission_deep_dive_ui())",
    "showModal(evidence_deep_dive_ui())"
  )

  for (modal_call in expected_modals) {
    expect_true(grepl(modal_call, app_text, fixed = TRUE))
  }

  expect_true(grepl('modalButton("Close")', app_text, fixed = TRUE))
  expect_true(grepl("many possible futures under explicit assumptions", content_text$pva, fixed = TRUE))
  expect_true(grepl("Extinction risk", content_text$pva, fixed = TRUE))
  expect_true(grepl("proportion of simulated futures", content_text$pva, fixed = TRUE))
  expect_true(grepl("Abundance", content_text$pva, fixed = TRUE))
  expect_true(grepl("chosen projection horizon", content_text$pva, fixed = TRUE))
  expect_true(grepl("Uncertainty", content_text$pva, fixed = TRUE))
  expect_true(grepl("range of outcomes across simulated futures", content_text$pva, fixed = TRUE))
  expect_true(grepl("Evidence for interpretation", content_text$pva, fixed = TRUE))

  expect_true(grepl("guided concept lab", content_text$mission, fixed = TRUE))
  expect_true(grepl("baseline as run 1", content_text$mission, fixed = TRUE))
  expect_true(grepl("change one factor at a time", content_text$mission, fixed = TRUE))
  expect_true(grepl("Compare", content_text$mission, fixed = TRUE))

  expect_true(grepl("comparison CSV", content_text$evidence, fixed = TRUE))
  expect_true(grepl("evidence-notes file", content_text$evidence, fixed = TRUE))
  expect_true(grepl("Markdown", content_text$evidence, fixed = TRUE))
  expect_true(grepl("one-sentence interpretation", content_text$evidence, fixed = TRUE))
  expect_true(grepl("support your explanation", content_text$evidence, fixed = TRUE))
  expect_true(grepl("trade-offs", content_text$evidence, fixed = TRUE))

  for (text in content_text) {
    expect_false(grepl("thylacine", text, ignore.case = TRUE))
    expect_false(grepl("Lord Howe", text, ignore.case = TRUE))
    expect_false(grepl("Gitea|deployment|ShinyProxy|Docker|Moodle", text, ignore.case = TRUE))
  }

  expect_match(style_text, "\\.landing-card\\.is-interactive")
  expect_match(style_text, "\\.landing-card-action")
  expect_match(style_text, "\\.deep-dive-modal")
})

test_that("Start landing exposes accessible shared UI semantics", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")
  script_text <- paste(readLines(file.path(app_dir, "www", "practical1.js"), warn = FALSE), collapse = "\n")
  style_text <- paste(readLines(file.path(app_dir, "www", "styles.css"), warn = FALSE), collapse = "\n")

  expect_true(grepl('h2(title)', app_text, fixed = TRUE))
  expect_true(grepl('h2("Your evidence pack")', app_text, fixed = TRUE))
  expect_true(grepl("This browser session is temporary. Before you finish, use Compare to download your evidence.", app_text, fixed = TRUE))

  expected_script_hooks <- c(
    "lastModalTrigger",
    "shown.bs.modal",
    "hidden.bs.modal",
    "aria-modal",
    "aria-labelledby",
    "aria-current",
    "shown.bs.tab"
  )
  expect_true(all(vapply(expected_script_hooks, grepl, logical(1), x = script_text, fixed = TRUE)))

  expect_match(style_text, "@media \\(max-width: 780px\\)")
  expect_match(style_text, "\\.navbar-nav\\s*\\{[^}]*display:\\s*grid")
  expect_match(style_text, "grid-template-columns:\\s*repeat\\(2, minmax\\(0, 1fr\\)\\)")
  expect_match(style_text, "\\.navbar-nav::before,\\s*\\.navbar-nav::after\\s*\\{[^}]*display:\\s*none")
})

test_that("Concept Lab exposes Markdown-backed contextual help", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")
  style_text <- paste(readLines(file.path(app_dir, "www", "styles.css"), warn = FALSE), collapse = "\n")
  worksheet_text <- paste(readLines(file.path(repo_root(), "docs", "teaching", "woodhen", "practical-1-mission-worksheet.md"), warn = FALSE), collapse = "\n")
  content_paths <- c(
    parameters = file.path(app_dir, "content", "parameter-help.md"),
    outputs = file.path(app_dir, "content", "output-reading-help.md"),
    diagnostics = file.path(app_dir, "content", "diagnostics-help.md"),
    plots = file.path(app_dir, "content", "plot-reading-help.md")
  )
  content_text <- lapply(content_paths, function(path) {
    if (file.exists(path)) {
      paste(readLines(path, warn = FALSE), collapse = "\n")
    } else {
      ""
    }
  })

  expect_true(all(file.exists(content_paths)))

  expected_paths <- c(
    'parameter_help_path <- file.path("content", "parameter-help.md")',
    'output_help_path <- file.path("content", "output-reading-help.md")',
    'diagnostic_help_path <- file.path("content", "diagnostics-help.md")',
    'plot_help_path <- file.path("content", "plot-reading-help.md")'
  )
  for (path_definition in expected_paths) {
    expect_true(grepl(path_definition, app_text, fixed = TRUE))
  }

  expected_triggers <- c(
    "open_parameter_help" = "Control help",
    "open_output_help" = "Read outputs",
    "open_diagnostic_help" = "Read diagnostics",
    "open_plot_help" = "Read plots"
  )
  expected_aria <- c(
    "Open Practical 1 parameter help",
    "Open Practical 1 output help",
    "Open Practical 1 diagnostic help",
    "Open Practical 1 plot help"
  )

  for (trigger in names(expected_triggers)) {
    expect_match(app_text, paste0('actionButton\\(\\s*"', trigger, '"'))
    expect_true(grepl(paste0("observeEvent(input$", trigger), app_text, fixed = TRUE))
    expect_true(grepl(expected_triggers[[trigger]], app_text, fixed = TRUE))
  }
  for (aria_label in expected_aria) {
    expect_true(grepl(aria_label, app_text, fixed = TRUE))
  }

  expect_true(grepl("breeding and territory-holding stages", content_text$parameters, fixed = TRUE))
  expect_true(grepl("total population can exceed the ceiling", content_text$parameters, fixed = TRUE))
  expect_true(grepl("environmental variation", content_text$parameters, fixed = TRUE))
  expect_true(grepl("bonanza and bust years", content_text$parameters, fixed = TRUE))
  expect_true(grepl("starting inbreeding", content_text$parameters, fixed = TRUE))
  expect_true(grepl("catastrophe chance", content_text$parameters, fixed = TRUE))
  expect_true(grepl("simulation futures", content_text$parameters, fixed = TRUE))

  expect_true(grepl("PE", content_text$outputs, fixed = TRUE))
  expect_true(grepl("Nmed", content_text$outputs, fixed = TRUE))
  expect_true(grepl("uncertainty interval", content_text$outputs, fixed = TRUE))
  expect_true(grepl("PE = 0", content_text$outputs, fixed = TRUE))
  expect_true(grepl("Settings record", content_text$outputs, fixed = TRUE))

  expect_true(grepl("warning", content_text$diagnostics, fixed = TRUE))
  expect_true(grepl("caveat", content_text$diagnostics, fixed = TRUE))
  expect_true(grepl("No major diagnostic warnings", content_text$diagnostics, fixed = TRUE))
  expect_true(grepl("does not prove", content_text$diagnostics, fixed = TRUE))

  expect_true(grepl("trajectory", content_text$plots, fixed = TRUE))
  expect_true(grepl("summary interval", content_text$plots, fixed = TRUE))
  expect_true(grepl("extinction risk through time", tolower(content_text$plots), fixed = TRUE))
  expect_true(grepl("extinction-time histogram", content_text$plots, fixed = TRUE))
  expect_true(grepl("quasi-extinction", tolower(content_text$plots), fixed = TRUE))
  expect_true(grepl("50% of the nominal habitat ceiling", content_text$plots, fixed = TRUE))

  for (text in content_text) {
    expect_false(grepl("Woodhen|thylacine|\\bITS\\b|Gitea|Docker|Moodle|ShinyProxy", text, ignore.case = TRUE))
  }

  expect_true(grepl("5. Rescue attempt", worksheet_text, fixed = TRUE))
  expect_true(grepl("## Explore Further notes", worksheet_text, fixed = TRUE))
  expect_false(grepl("7a. Rescue attempt", worksheet_text, fixed = TRUE))
  expect_false(grepl("7b. Vortex comparison", worksheet_text, fixed = TRUE))
  expect_match(style_text, "\\.contextual-help-button")
  expect_match(style_text, "\\.concept-help-strip")
})

test_that("Concept Lab explains the complete Core and Explore route in place", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")
  content_path <- file.path(app_dir, "content", "core-explore-help.md")
  content_text <- if (file.exists(content_path)) {
    paste(readLines(content_path, warn = FALSE), collapse = "\n")
  } else {
    ""
  }

  expect_true(file.exists(content_path))
  expect_true(grepl('core_explore_help_path <- file.path("content", "core-explore-help.md")', app_text, fixed = TRUE))
  expect_match(app_text, 'actionButton\\(\\s*"open_core_explore_help"')
  expect_true(grepl("observeEvent(input$open_core_explore_help", app_text, fixed = TRUE))
  expect_true(grepl("showModal(core_explore_help_ui())", app_text, fixed = TRUE))
  expect_false(grepl('actionButton("show_intro"', app_text, fixed = TRUE))
  expect_false(grepl("observeEvent(input$show_intro", app_text, fixed = TRUE))

  expected_missions <- c(
    "Baseline compass",
    "Island ceiling",
    "Individual chance",
    "Environmental variability",
    "Rescue attempt",
    "Small-population pressure",
    "Rare bad years",
    "Vortex comparison"
  )
  expect_true(all(vapply(expected_missions, grepl, logical(1), x = content_text, fixed = TRUE)))
  expect_true(grepl("latest successful Core settings", content_text, fixed = TRUE))
  expect_true(grepl("do not rewrite", content_text, fixed = TRUE))
  expect_true(grepl("carry forward into later Explore missions", content_text, fixed = TRUE))
})

test_that("Concept Lab exposes a guided mission rail", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")
  style_text <- paste(readLines(file.path(app_dir, "www", "styles.css"), warn = FALSE), collapse = "\n")

  expect_true(grepl("mission_rail_ui <- function(current_stage, completed_stages = character())", app_text, fixed = TRUE))
  expect_true(grepl('span(class = "mission-group-title", "Core")', app_text, fixed = TRUE))
  expect_true(grepl('span(class = "mission-group-title", "Explore Further")', app_text, fixed = TRUE))
  expect_true(grepl('actionLink(paste0("mission_", stage)', app_text, fixed = TRUE))
  expect_true(grepl('uiOutput("mission_rail")', app_text, fixed = TRUE))
  expect_true(grepl('actionButton("previous_mission"', app_text, fixed = TRUE))
  expect_true(grepl('actionButton("next_mission"', app_text, fixed = TRUE))
  expect_true(grepl("output$mission_rail <- renderUI", app_text, fixed = TRUE))
  expect_true(grepl("observeEvent(input$previous_mission", app_text, fixed = TRUE))
  expect_true(grepl("observeEvent(input$next_mission", app_text, fixed = TRUE))
  expect_true(grepl("previous_mission_stage <- function(stage)", app_text, fixed = TRUE))
  expect_match(style_text, "\\.mission-rail")
  expect_match(style_text, "\\.mission-step > \\.action-label")
  expect_match(style_text, "display:\\s*contents")
  expect_match(style_text, "\\.mission-step\\.is-current")
  expect_match(style_text, "\\.mission-step\\.is-complete")
})

test_that("Practical 1 baseline progress begins only after Start baseline", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)

  shiny::testServer(env$make_practical1_server(), {
    expect_false(baseline_started())
    expect_length(run_history(), 0L)
    session$setInputs(run_baseline = 1)
    expect_true(baseline_started())
    expect_length(run_history(), 1L)
    expect_equal(run_history()[[1]]$stage, "deterministic_baseline")
    expect_equal(session_run_id(run_history()[[1]]), 1L)
  })
})

test_that("Compare outputs are safe before baseline", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)

  shiny::testServer(env$make_practical1_server(), {
    expect_length(run_history(), 0L)
    expect_no_error(comparison_table <- output$comparison_table)
    expect_no_error(run_cards <- output$run_cards)
    expect_match(paste(as.character(run_cards), collapse = "\n"), "No comparison runs yet", fixed = TRUE)
  })
})

test_that("Compare view exposes run cards, baseline deltas, and interpretation capture", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")
  style_text <- paste(readLines(file.path(app_dir, "www", "styles.css"), warn = FALSE), collapse = "\n")

  expect_true(grepl("run_cards_ui <- function(runs)", app_text, fixed = TRUE))
  expect_true(grepl('uiOutput("run_cards")', app_text, fixed = TRUE))
  expect_true(grepl("output$run_cards <- renderUI", app_text, fixed = TRUE))
  expect_true(grepl("compare_teaching_runs(runs, include_deltas = TRUE)", app_text, fixed = TRUE))
  expect_true(grepl('textAreaInput("interpretation_note"', app_text, fixed = TRUE))
  expect_true(grepl("interpretation = input$interpretation_note", app_text, fixed = TRUE))
  expect_true(grepl("Delta PE", app_text, fixed = TRUE))
  expect_true(grepl("Delta Nmed", app_text, fixed = TRUE))
  expect_match(style_text, "\\.run-card-grid")
  expect_match(style_text, "\\.run-card")
  expect_match(style_text, "\\.interpretation-capture")
})

test_that("landing screen uses local accessible bitmap assets", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")
  asset_dir <- file.path(app_dir, "www", "img")
  expected_assets <- c(
    "landing-pva-learning-futures.png",
    "landing-trajectory-evidence.png",
    "landing-conservation-decision.png"
  )

  expect_true(dir.exists(asset_dir))
  expect_true(all(file.exists(file.path(asset_dir, expected_assets))))
  expect_true(grepl("img/landing-pva-learning-futures.png", app_text, fixed = TRUE))
  expect_true(grepl("img/landing-trajectory-evidence.png", app_text, fixed = TRUE))
  expect_true(grepl("img/landing-conservation-decision.png", app_text, fixed = TRUE))
  expect_false(grepl("img/landing-woodhen-population.png", app_text, fixed = TRUE))
  expect_false(grepl("woodhen-like bird", app_text, fixed = TRUE))
  expect_true(grepl("tags$img(src = image, alt = alt)", app_text, fixed = TRUE))
  expect_true(grepl("population trajectory lines", app_text, fixed = TRUE))
  expect_true(grepl("conservation decision scene", app_text, fixed = TRUE))
})

test_that("landing screen has responsive tutorial styling", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  style_text <- paste(readLines(file.path(app_dir, "www", "styles.css"), warn = FALSE), collapse = "\n")

  expect_match(style_text, "\\.landing-hero\\s*\\{[^}]*display:\\s*grid")
  expect_match(style_text, "\\.landing-card-grid\\s*\\{[^}]*grid-template-columns:")
  expect_match(style_text, "\\.landing-visual\\s*\\{[^}]*aspect-ratio:")
  expect_match(style_text, "\\.landing-task-text")
  expect_match(style_text, "@media \\(max-width: 780px\\)")
  expect_match(style_text, "\\.landing-hero,\\s*\\.landing-card-grid")
})

test_that("Concept Lab settings table uses teaching labels and selected-mission changes", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")
  style_text <- paste(readLines(file.path(app_dir, "www", "styles.css"), warn = FALSE), collapse = "\n")

  expect_true(grepl("teaching_parameter_catalog <- function()", app_text, fixed = TRUE))
  expect_true(grepl("settings_for_display <- function(selected_spec, baseline_spec)", app_text, fixed = TRUE))
  expect_true(grepl("Baseline value", app_text, fixed = TRUE))
  expect_true(grepl("Selected mission value", app_text, fixed = TRUE))
  expect_true(grepl("What changed", app_text, fixed = TRUE))
  expect_true(grepl("Habitat ceiling", app_text, fixed = TRUE))
  expect_true(grepl("Environmental variation", app_text, fixed = TRUE))
  expect_true(grepl("Starting population", app_text, fixed = TRUE))
  expect_true(grepl("selected_stage_spec <- reactive", app_text, fixed = TRUE))
  expect_true(grepl("settings_for_display(selected_stage_spec(), baseline_run()$spec)", app_text, fixed = TRUE))
  expect_false(grepl("Setting = out$setting", app_text, fixed = TRUE))
  expect_false(grepl("Value = out$value", app_text, fixed = TRUE))
  expect_match(style_text, "\\.settings-table td:nth-child\\(4\\)")
})

test_that("Core stochastic controls expose the intended classroom ranges", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)

  individual_html <- as.character(env$stage_control_ui("demographic_stochasticity"))
  environmental_html <- as.character(env$stage_control_ui("environmental_stochasticity"))

  expect_match(individual_html, "Simulation futures", fixed = TRUE)
  for (choice in c("10", "100", "500", "1000")) {
    expect_match(individual_html, paste0(">", choice, "<"), fixed = TRUE)
  }
  expect_false(grepl('max="200"', individual_html, fixed = TRUE))

  expect_match(environmental_html, "Environmental variation", fixed = TRUE)
  expect_match(environmental_html, 'data-max="0.4"', fixed = TRUE)
  expect_match(environmental_html, 'data-from="0.35"', fixed = TRUE)
})

test_that("Core controls reopen with the accumulated working assumptions", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)

  working <- list(
    years = 50,
    reps = 500,
    K = 45,
    K_sd = 4,
    env_sd = 0.40,
    mortality_pct = -10,
    fecundity_pct = 5
  )

  baseline_html <- as.character(env$stage_control_ui("deterministic_baseline", working))
  individual_html <- as.character(env$stage_control_ui("demographic_stochasticity", working))
  environmental_html <- as.character(env$stage_control_ui("environmental_stochasticity", working))
  first_intervention_html <- as.character(env$stage_control_ui("intervention", working, stage_completed = FALSE))
  repeated_intervention_html <- as.character(env$stage_control_ui(
    "intervention",
    utils::modifyList(working, list(K = 80, K_sd = 6)),
    stage_completed = TRUE
  ))
  advanced_html <- as.character(env$advanced_stage_controls("catastrophe", working))

  expect_match(baseline_html, 'data-from="50"', fixed = TRUE)
  expect_match(individual_html, 'data-from="45"', fixed = TRUE)
  expect_match(individual_html, '<option value="500" selected>500</option>', fixed = TRUE)
  expect_match(environmental_html, 'data-from="0.4"', fixed = TRUE)
  expect_match(environmental_html, 'data-from="45"', fixed = TRUE)
  expect_match(first_intervention_html, 'data-from="70"', fixed = TRUE)
  expect_match(first_intervention_html, 'data-from="5"', fixed = TRUE)
  expect_match(repeated_intervention_html, 'data-from="80"', fixed = TRUE)
  expect_match(repeated_intervention_html, 'data-from="6"', fixed = TRUE)
  expect_match(advanced_html, '<option value="500" selected>500</option>', fixed = TRUE)
})

test_that("Explore controls retain accumulated mechanism settings", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)

  working <- list(K = 70, K_sd = 7, env_sd = 0.40)
  explore <- list(F_init = 0.30, cat_freq = 0.18, cat_surv = 0.45)
  genetic_html <- as.character(env$stage_control_ui(
    "genetic_stochasticity",
    working,
    explore_assumptions = explore
  ))
  catastrophe_html <- as.character(env$stage_control_ui(
    "catastrophe",
    working,
    explore_assumptions = explore
  ))
  vortex_html <- as.character(env$stage_control_ui(
    "extinction_vortex",
    working,
    explore_assumptions = explore
  ))

  expect_match(genetic_html, "Starting inbreeding", fixed = TRUE)
  expect_match(genetic_html, 'data-from="0.3"', fixed = TRUE)
  expect_false(grepl('id="env_sd"', genetic_html, fixed = TRUE))
  expect_match(catastrophe_html, "Catastrophe chance each year", fixed = TRUE)
  expect_match(catastrophe_html, 'data-from="0.18"', fixed = TRUE)
  expect_match(catastrophe_html, 'data-from="0.45"', fixed = TRUE)
  expect_false(grepl('id="K"', catastrophe_html, fixed = TRUE))
  expect_match(vortex_html, "Catastrophe chance each year", fixed = TRUE)
  expect_match(vortex_html, 'data-from="0.18"', fixed = TRUE)
  expect_match(vortex_html, 'data-max="0.2"', fixed = TRUE)
  expect_false(grepl('id="K"', vortex_html, fixed = TRUE))
})

test_that("Concept Lab exposes optional advanced risk controls", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")

  expect_true(grepl('checkboxInput("show_advanced_controls"', app_text, fixed = TRUE))
  expect_true(grepl("Show advanced risk controls", app_text, fixed = TRUE))
  expect_true(grepl("advanced_stage_controls <- function(stage, working_assumptions = NULL)", app_text, fixed = TRUE))
  expect_true(grepl("advanced_year_choices <- c(10, 25, 50, 100, 1000)", app_text, fixed = TRUE))
  expect_true(grepl("advanced_reps_choices <- c(10, 100, 500, 1000)", app_text, fixed = TRUE))
  expect_true(grepl("advanced_pct_choices <- c(-20, -10, -5, 0, 5, 10, 20)", app_text, fixed = TRUE))
  expect_true(grepl('"advanced_years"', app_text, fixed = TRUE))
  expect_true(grepl('"advanced_reps"', app_text, fixed = TRUE))
  expect_true(grepl("advanced_years = \"years\"", app_text, fixed = TRUE))
  expect_true(grepl("advanced_reps = \"reps\"", app_text, fixed = TRUE))
  expect_true(grepl("Projection years", app_text, fixed = TRUE))
  expect_true(grepl("Simulation futures", app_text, fixed = TRUE))
  expect_true(grepl("Mortality change", app_text, fixed = TRUE))
  expect_true(grepl("Fecundity change", app_text, fixed = TRUE))
  expect_true(grepl("mortality_pct", app_text, fixed = TRUE))
  expect_true(grepl("fecundity_pct", app_text, fixed = TRUE))
  expect_true(grepl("5% lower", app_text, fixed = TRUE))
  expect_true(grepl("20% higher", app_text, fixed = TRUE))
  expect_true(grepl("mission_control_values(", app_text, fixed = TRUE))
  expect_true(grepl("working_assumptions = working_assumptions()", app_text, fixed = TRUE))
})

test_that("deterministic baseline advanced controls omit meaningless replication", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)

  controls <- env$visible_stage_controls("deterministic_baseline", advanced = TRUE)
  advanced_html <- as.character(env$advanced_stage_controls("deterministic_baseline"))

  expect_equal(controls, c("years", "mortality_pct", "fecundity_pct"))
  expect_match(advanced_html, "Mortality change", fixed = TRUE)
  expect_match(advanced_html, "Fecundity change", fixed = TRUE)
  expect_false(grepl("Simulation futures", advanced_html, fixed = TRUE))
})

test_that("Concept Lab can save plot PNGs with automatic filenames", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")
  style_text <- paste(readLines(file.path(app_dir, "www", "styles.css"), warn = FALSE), collapse = "\n")

  expect_true(grepl('downloadButton("download_trajectory_plot"', app_text, fixed = TRUE))
  expect_true(grepl('downloadButton("download_summary_plot"', app_text, fixed = TRUE))
  expect_true(grepl('downloadButton("download_extinction_plot"', app_text, fixed = TRUE))
  expect_true(grepl('downloadButton("download_quasi_extinction_plot"', app_text, fixed = TRUE))
  expect_true(grepl("output$download_trajectory_plot <- downloadHandler", app_text, fixed = TRUE))
  expect_true(grepl("output$download_summary_plot <- downloadHandler", app_text, fixed = TRUE))
  expect_true(grepl("output$download_extinction_plot <- downloadHandler", app_text, fixed = TRUE))
  expect_true(grepl("output$download_quasi_extinction_plot <- downloadHandler", app_text, fixed = TRUE))
  expect_true(grepl("plot_png_filename <- function(kind, run)", app_text, fixed = TRUE))
  expect_true(grepl("write_plot_png <- function(file, plot)", app_text, fixed = TRUE))
  expect_true(grepl("practical1-trajectory-", app_text, fixed = TRUE))
  expect_true(grepl("practical1-summary-", app_text, fixed = TRUE))
  expect_true(grepl("practical1-risk-", app_text, fixed = TRUE))
  expect_match(style_text, "\\.plot-download-grid")
})

test_that("Practical 1 student-facing prose uses British spelling and direct diagnostics", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")
  content_text <- paste(unlist(lapply(
    list.files(file.path(app_dir, "content"), pattern = "\\.md$", full.names = TRUE),
    readLines,
    warn = FALSE
  )), collapse = "\n")

  expect_false(grepl("not a certainty", app_text, fixed = TRUE))
  expect_false(grepl("emphasize", app_text, ignore.case = TRUE))
  expect_false(grepl("favorable|analyze|visualize|customize|modeling", app_text, ignore.case = TRUE))
  expect_false(grepl("favorable|analyze|visualize|customize|modeling", content_text, ignore.case = TRUE))
})

test_that("comparison table is styled for horizontal scanning", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  style_text <- paste(readLines(file.path(app_dir, "www", "styles.css"), warn = FALSE), collapse = "\n")

  expect_match(style_text, "\\.compare-table\\s*\\{[^}]*overflow-x:\\s*auto")
  expect_match(style_text, "\\.compare-table\\s*\\{[^}]*-webkit-overflow-scrolling:\\s*touch")
  expect_match(style_text, "\\.compare-table table\\s*\\{[^}]*min-width:")
  expect_match(style_text, "\\.compare-table th,\\s*\\.compare-table td\\s*\\{[^}]*white-space:\\s*nowrap")
  expect_match(style_text, "\\.compare-table th,\\s*\\.compare-table td\\s*\\{[^}]*overflow-wrap:\\s*normal")
})

load_practical1_session_helpers <- function() {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  env <- new.env(parent = baseenv())
  sys.source(file.path(app_dir, "session_helpers.R"), envir = env)
  env
}

practical1_stub_run <- function(stage, run_id) {
  list(
    stage = stage,
    label = stage,
    settings = data.frame(
      stage = stage,
      label = stage,
      setting = "control_test",
      value = as.character(run_id),
      stringsAsFactors = FALSE
    ),
    session_run_id = as.integer(run_id)
  )
}

test_that("Practical 1 session helpers define the approved Core and extension order", {
  helpers <- load_practical1_session_helpers()

  expect_equal(
    helpers$practical1_stage_groups$core,
    c(
      "deterministic_baseline",
      "carrying_capacity",
      "demographic_stochasticity",
      "environmental_stochasticity",
      "intervention"
    )
  )
  expect_equal(
    helpers$practical1_stage_groups$extension,
    c("genetic_stochasticity", "catastrophe", "extinction_vortex")
  )
  expect_equal(
    helpers$practical1_mission_order,
    c(helpers$practical1_stage_groups$core, helpers$practical1_stage_groups$extension)
  )
})

test_that("Practical 1 run identity and completion ignore the display-only baseline", {
  helpers <- load_practical1_session_helpers()
  baseline <- practical1_stub_run("deterministic_baseline", 1)
  risk <- practical1_stub_run("carrying_capacity", 2)

  expect_equal(helpers$session_run_id(baseline), 1L)
  expect_equal(
    helpers$session_run_id(helpers$attach_session_run_id(risk, 9L)),
    9L
  )
  expect_equal(
    helpers$completed_stage_ids(list(baseline, risk), baseline_started = FALSE),
    "carrying_capacity"
  )
  expect_equal(
    helpers$completed_stage_ids(list(baseline, risk), baseline_started = TRUE),
    c("deterministic_baseline", "carrying_capacity")
  )
  expect_equal(
    helpers$next_incomplete_core_stage(c("deterministic_baseline", "carrying_capacity")),
    "demographic_stochasticity"
  )
})

test_that("Practical 1 evidence defaults use baseline and latest eligible risk and action", {
  helpers <- load_practical1_session_helpers()
  runs <- list(
    practical1_stub_run("deterministic_baseline", 1),
    practical1_stub_run("carrying_capacity", 2),
    practical1_stub_run("environmental_stochasticity", 3),
    practical1_stub_run("intervention", 4),
    practical1_stub_run("extinction_vortex", 5)
  )

  expect_equal(helpers$first_baseline_run_id(runs), 1L)
  expect_equal(
    helpers$default_evidence_run_ids(runs, baseline_started = TRUE),
    c(1L, 3L, 5L)
  )
  expect_equal(
    vapply(helpers$select_session_runs(runs, c(1L, 2L, 4L)), `[[`, character(1), "stage"),
    c("deterministic_baseline", "carrying_capacity", "intervention")
  )
})

test_that("Practical 1 readiness requires exactly baseline risk action and current interpretation", {
  helpers <- load_practical1_session_helpers()
  runs <- list(
    practical1_stub_run("deterministic_baseline", 1),
    practical1_stub_run("environmental_stochasticity", 2),
    practical1_stub_run("intervention", 3),
    practical1_stub_run("catastrophe", 4)
  )
  selected <- c(1L, 2L, 3L)
  signature <- helpers$evidence_selection_signature(selected)

  ready <- helpers$evidence_readiness(
    runs,
    selected,
    interpretation = "Risk rose under shared bad years; intervention improved abundance, with uncertainty remaining.",
    interpretation_signature = signature,
    baseline_started = TRUE
  )
  stale <- helpers$evidence_readiness(
    runs,
    c(1L, 4L, 3L),
    interpretation = "Risk rose under shared bad years; intervention improved abundance, with uncertainty remaining.",
    interpretation_signature = signature,
    baseline_started = TRUE
  )

  expect_true(ready$ready)
  expect_true(all(ready$checks))
  expect_false(stale$ready)
  expect_false(stale$checks[["interpretation_current"]])
  expect_true(stale$checks[["interpretation"]])
})

test_that("Practical 1 selects three runs and invalidates stale interpretation", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)

  shiny::testServer(env$make_practical1_server(), {
    session$setInputs(run_baseline = 1)
    selected_stage("environmental_stochasticity")
    session$setInputs(run_stage = 1)
    selected_stage("intervention")
    session$setInputs(run_stage = 2)
    session$setInputs(
      interpretation_note = paste(
        "Risk increased under shared bad years; intervention improved final abundance,",
        "while uncertainty remained."
      )
    )

    expect_equal(length(selected_evidence_ids()), 3L)
    expect_equal(
      vapply(selected_evidence_runs(), `[[`, character(1), "stage"),
      c("deterministic_baseline", "environmental_stochasticity", "intervention")
    )
    expect_true(evidence_readiness_state()$ready)

    selected_stage("catastrophe")
    session$setInputs(run_stage = 3)
    expect_equal(selected_risk_run_id(), 4L)
    expect_false(evidence_readiness_state()$checks[["interpretation_current"]])
    expect_true(evidence_readiness_state()$checks[["interpretation"]])
    session$setInputs(confirm_interpretation = 1)
    expect_true(evidence_readiness_state()$checks[["interpretation_current"]])
  })
})

test_that("Practical 1 preserves duplicate evidence attempts and stale selection state", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)

  shiny::testServer(env$make_practical1_server(), {
    session$setInputs(run_baseline = 1)

    selected_stage("environmental_stochasticity")
    session$setInputs(env_sd = 0.15, K = 15, run_stage = 1)
    selected_stage("environmental_stochasticity")
    session$setInputs(env_sd = 0.35, K = 20, run_stage = 2)
    selected_stage("intervention")
    session$setInputs(K = 70, K_sd = 5, run_stage = 3)

    history_ids <- vapply(run_history(), session_run_id, integer(1))
    expect_length(run_history(), 4L)
    expect_equal(history_ids, 1:4)
    expect_equal(diff(history_ids), rep(1L, 3L))

    environmental_runs <- Filter(
      function(run) identical(run$stage, "environmental_stochasticity"),
      run_history()
    )
    expect_length(environmental_runs, 2L)
    expect_false(identical(
      env$run_changed_settings_label(environmental_runs[[1]]),
      env$run_changed_settings_label(environmental_runs[[2]])
    ))

    risk_choices <- env$eligible_run_choices(
      run_history(),
      env$practical1_evidence_risk_stages
    )
    expect_equal(unname(risk_choices), c(2L, 3L))
    expect_true(all(vapply(
      c("Run 2", "Run 3"),
      function(label) any(grepl(label, names(risk_choices), fixed = TRUE)),
      logical(1)
    )))

    session$setInputs(selected_risk_run_id = "2")
    expect_equal(selected_risk_run_id(), 2L)
    expect_equal(selected_evidence_ids(), c(1L, 2L, 4L))
    expect_equal(
      vapply(selected_evidence_runs(), `[[`, character(1), "stage"),
      c("deterministic_baseline", "environmental_stochasticity", "intervention")
    )
    expect_length(selected_evidence_runs(), 3L)

    cards <- paste(as.character(output$run_cards), collapse = "\n")
    expect_true(all(vapply(c("Run 1", "Run 2", "Run 4"), grepl, logical(1), cards, fixed = TRUE)))
    expect_false(grepl("Run 3", cards, fixed = TRUE))

    interpretation <- "Risk increased under shared bad years; intervention improved abundance, with uncertainty remaining."
    session$setInputs(interpretation_note = interpretation)
    expect_identical(input$interpretation_note, interpretation)
    expect_true(evidence_readiness_state()$ready)

    selected_export <- evidence_export()
    expect_equal(selected_export$comparison$run_id, c(1L, 2L, 4L))
    expect_equal(sort(unique(selected_export$settings$run_id)), c(1L, 2L, 4L))

    session$setInputs(selected_risk_run_id = "3")
    expect_equal(selected_evidence_ids(), c(1L, 3L, 4L))
    expect_identical(input$interpretation_note, interpretation)
    expect_true(evidence_readiness_state()$checks[["interpretation"]])
    expect_false(evidence_readiness_state()$checks[["interpretation_current"]])

    session$setInputs(confirm_interpretation = 1)
    expect_true(evidence_readiness_state()$checks[["interpretation_current"]])
    expect_true(evidence_readiness_state()$ready)
  })
})

test_that("Practical 1 gates selected evidence downloads and records each request", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")

  expect_true(grepl("session_run_count = length(run_history())", app_text, fixed = TRUE))
  expect_true(grepl("selected_evidence_runs()", app_text, fixed = TRUE))
  expect_true(grepl("download_requested <- reactiveValues(comparison = FALSE, notes = FALSE)", app_text, fixed = TRUE))
  expect_true(grepl('uiOutput("evidence_downloads")', app_text, fixed = TRUE))
  expect_true(grepl('`aria-disabled` = "true"', app_text, fixed = TRUE))
  expect_true(grepl('uiOutput("transfer_checklist")', app_text, fixed = TRUE))
  expect_true(grepl("Comparison CSV: Download requested", app_text, fixed = TRUE))
  expect_true(grepl("Evidence notes: Download requested", app_text, fixed = TRUE))
  expect_true(grepl("Download requested", app_text, fixed = TRUE))
  expect_false(grepl("Evidence saved", app_text, fixed = TRUE))

  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)

  shiny::testServer(env$make_practical1_server(), {
    session$setInputs(run_baseline = 1)
    selected_stage("environmental_stochasticity")
    session$setInputs(env_sd = 0.15, K = 15, run_stage = 1)
    selected_stage("environmental_stochasticity")
    session$setInputs(env_sd = 0.25, K = 20, run_stage = 2)
    selected_stage("intervention")
    session$setInputs(K = 70, K_sd = 5, run_stage = 3)
    session$setInputs(
      interpretation_note = "Risk increased under shared bad years; intervention improved abundance; uncertainty remained."
    )

    expect_gt(length(run_history()), 3L)
    expect_equal(nrow(evidence_export()$comparison), 3L)
    expect_true(any(grepl(
      "Selected evidence: 3 runs from 4 successful session runs",
      evidence_export()$notes,
      fixed = TRUE
    )))
    expect_false(download_requested$comparison)
    expect_false(download_requested$notes)

    output$download_comparison
    output$download_evidence_notes
    comparison_generator <- session$.__enclos_env__$private$file_generators$get(
      session$ns("download_comparison")
    )
    notes_generator <- session$.__enclos_env__$private$file_generators$get(
      session$ns("download_evidence_notes")
    )
    comparison_file <- tempfile(fileext = ".csv")
    notes_file <- tempfile(fileext = ".md")
    comparison_generator$content(comparison_file)
    notes_generator$content(notes_file)
    expect_true(file.exists(comparison_file))
    expect_true(file.exists(notes_file))
    expect_true(download_requested$comparison)
    expect_true(download_requested$notes)
  })
})

test_that("confirmed Practical 1 reset clears all in-memory student state", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)

  shiny::testServer(env$make_practical1_server(), {
    session$setInputs(run_baseline = 1)
    selected_stage("environmental_stochasticity")
    session$setInputs(env_sd = 0.15, K = 15, run_stage = 1)
    selected_stage("intervention")
    session$setInputs(run_stage = 2)
    session$setInputs(interpretation_note = "Risk changed; intervention improved abundance; uncertainty remained.")
    download_requested$comparison <- TRUE
    download_requested$notes <- TRUE
    download_recorded_signatures$comparison <- "1:2:3|stale comparison"
    download_recorded_signatures$notes <- "1:2:3|stale notes"

    session$setInputs(confirm_clear_runs = 1)

    expect_length(run_history(), 0L)
    expect_false(baseline_started())
    expect_equal(next_run_id(), 1L)
    expect_true(is.na(selected_risk_run_id()))
    expect_true(is.na(selected_action_run_id()))
    expect_identical(interpretation_signature(), "")
    expect_false(download_requested$comparison)
    expect_false(download_requested$notes)
    expect_identical(download_recorded_signatures$comparison, "")
    expect_identical(download_recorded_signatures$notes, "")
    expect_true(is.na(last_completed_run_id()))
  })
})

test_that("Practical 1 Compare separates session history from selected evidence", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")

  expect_true(grepl("Session history", app_text, fixed = TRUE))
  expect_true(grepl("Selected evidence", app_text, fixed = TRUE))
  expect_true(grepl("Review required", app_text, fixed = TRUE))
  expect_true(grepl("Baseline pinned", app_text, fixed = TRUE))
  expect_true(grepl("Choose one risk mechanism", app_text, fixed = TRUE))
  expect_true(grepl("Choose one intervention or vortex run", app_text, fixed = TRUE))
  expect_true(grepl("compare-history-panel", app_text, fixed = TRUE))
  expect_true(grepl("compare-evidence-panel", app_text, fixed = TRUE))
  expect_true(grepl("selected_evidence_runs()", app_text, fixed = TRUE))
  expect_true(grepl("interpretation_signature <- reactiveVal(\"\")", app_text, fixed = TRUE))
})

test_that("failed Practical 1 runs do not enter history or progress", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)
  execute <- function(stage, controls = list()) {
    if (identical(stage, "catastrophe")) stop("bounded test failure")
    env$run_stage(stage, controls)
  }

  shiny::testServer(env$make_practical1_server(execute), {
    session$setInputs(run_baseline = 1)
    selected_stage("catastrophe")
    before <- length(run_history())
    session$setInputs(run_stage = 1)
    expect_equal(length(run_history()), before)
    expect_false("catastrophe" %in% completed_stage_ids(run_history(), baseline_started()))
    expect_match(run_error(), "could not complete")
  })
})

test_that("failed Practical 1 baseline runs do not mutate session state", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)
  execute <- function(stage, controls = list()) {
    if (identical(stage, "deterministic_baseline")) stop("bounded baseline failure")
    env$run_stage(stage, controls)
  }

  shiny::testServer(env$make_practical1_server(execute), {
    before_baseline <- baseline_run()
    before_current <- current_run()
    expect_no_error(session$setInputs(run_baseline = 1))
    expect_identical(baseline_run(), before_baseline)
    expect_identical(current_run(), before_current)
    expect_length(run_history(), 0L)
    expect_equal(next_run_id(), 1L)
    expect_false(baseline_started())
    expect_null(last_completed_stage())
    expect_true(is.na(last_completed_run_id()))
    expect_match(run_error(), "could not complete")
  })
})

test_that("repeated Practical 1 baseline clicks preserve the existing session", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)

  shiny::testServer(env$make_practical1_server(), {
    session$setInputs(run_baseline = 1)
    selected_stage("carrying_capacity")
    session$setInputs(run_stage = 1)
    selected_stage("deterministic_baseline")
    session$setInputs(years = 25)
    session$setInputs(run_stage = 1)
    expect_match(run_error(), "A deterministic run repeats the same population trajectory")
    expect_length(run_history(), 2L)
    expect_equal(last_completed_stage(), "carrying_capacity")

    session$setInputs(run_baseline = 2)
    expect_null(run_error())
    expect_equal(last_completed_stage(), "carrying_capacity")
    expect_equal(last_completed_run_id(), 2L)
    expect_length(run_history(), 2L)
    expect_equal(next_run_id(), 3L)
    expect_true(baseline_started())
    expect_equal(selected_stage(), "deterministic_baseline")
    expect_equal(session_run_id(current_run()), 1L)
  })
})

test_that("changed deterministic assumptions create exploratory baseline reruns", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)

  shiny::testServer(env$make_practical1_server(), {
    session$setInputs(run_baseline = 1)
    original_baseline <- baseline_run()
    session$setInputs(years = 25, run_stage = 1)
    expect_length(run_history(), 1L)
    expect_equal(next_run_id(), 2L)
    expect_match(run_error(), "A deterministic run repeats the same population trajectory")

    session$setInputs(years = 50, run_stage = 2)
    expect_length(run_history(), 2L)
    expect_equal(vapply(run_history(), session_run_id, integer(1)), 1:2)
    expect_equal(current_run()$stage, "deterministic_baseline")
    expect_equal(current_run()$spec$years, 50L)
    expect_equal(baseline_run()$spec$years, 25L)
    expect_identical(baseline_run(), original_baseline)
    expect_null(run_error())

    session$setInputs(run_stage = 3)
    expect_length(run_history(), 2L)
    expect_match(run_error(), "A deterministic run repeats the same population trajectory")

    session$setInputs(
      show_advanced_controls = TRUE,
      mortality_pct = "-10",
      fecundity_pct = "0",
      run_stage = 4
    )
    expect_length(run_history(), 3L)
    expect_equal(current_run()$spec$mortality_pct, -10)
    expect_equal(current_run()$spec$fecundity_pct, 0)
    expect_null(run_error())

    session$setInputs(fecundity_pct = "5", run_stage = 5)
    expect_length(run_history(), 4L)
    expect_equal(current_run()$spec$mortality_pct, -10)
    expect_equal(current_run()$spec$fecundity_pct, 5)
    expect_identical(baseline_run(), original_baseline)
    expect_equal(env$first_baseline_run_id(run_history()), 1L)

    selected_stage("carrying_capacity")
    session$setInputs(
      show_advanced_controls = FALSE,
      K = 35,
      K_sd = 5,
      run_stage = 6
    )
    expect_equal(current_run()$stage, "carrying_capacity")
    expect_equal(current_run()$spec$years, 50L)
    expect_equal(current_run()$spec$mortality_pct, -10)
    expect_equal(current_run()$spec$fecundity_pct, 5)
    expect_identical(baseline_run(), original_baseline)

    settings <- env$settings_for_display(current_run()$spec, baseline_run()$spec)
    years_row <- settings[settings$Parameter == "Projection years", , drop = FALSE]
    expect_equal(years_row$`Selected mission value`, "50")
    expect_equal(years_row$`What changed`, "Higher than baseline")

    history_html <- paste(as.character(output$session_history), collapse = "\n")
    pinned_hits <- gregexpr("Pinned in selected evidence", history_html, fixed = TRUE)[[1]]
    expect_equal(sum(pinned_hits > 0L), 1L)

    session$setInputs(confirm_clear_runs = 1)
    session$setInputs(run_baseline = 2)
    selected_stage("carrying_capacity")
    session$setInputs(K = 35, K_sd = 5, run_stage = 7)
    expect_equal(current_run()$spec$years, 25L)
    expect_equal(current_run()$spec$mortality_pct, 0)
    expect_equal(current_run()$spec$fecundity_pct, 0)
  })
})

test_that("Core and Explore settings accumulate separately before Vortex", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)

  captured <- list()
  execute_stage <- function(stage, controls = list(), progress = NULL) {
    captured[[length(captured) + 1L]] <<- list(stage = stage, controls = controls)
    bounded <- controls
    if (!is.null(bounded$reps)) {
      bounded$reps <- min(as.integer(bounded$reps), 10L)
    }
    env$run_stage(stage, bounded, progress = progress)
  }

  shiny::testServer(env$make_practical1_server(execute_stage), {
    session$setInputs(run_baseline = 1)

    selected_stage("deterministic_baseline")
    session$setInputs(
      show_advanced_controls = TRUE,
      years = 50,
      mortality_pct = "-10",
      fecundity_pct = "5",
      run_stage = 1
    )

    selected_stage("carrying_capacity")
    session$setInputs(show_advanced_controls = FALSE, K = 45, K_sd = 4, run_stage = 2)

    selected_stage("demographic_stochasticity")
    session$setInputs(K = 45, reps = "500", run_stage = 3)

    selected_stage("environmental_stochasticity")
    session$setInputs(env_sd = 0.40, K = 45, run_stage = 4)

    selected_stage("intervention")
    session$setInputs(K = 70, K_sd = 7, run_stage = 5)

    expected_working <- list(
      years = 50,
      mortality_pct = -10,
      fecundity_pct = 5,
      K = 70,
      K_sd = 7,
      reps = 500,
      env_sd = 0.40
    )
    expect_equal(working_assumptions(), expected_working)

    before_explore <- working_assumptions()
    selected_stage("genetic_stochasticity")
    session$setInputs(F_init = 0.30, run_stage = 6)
    expect_equal(explore_assumptions(), list(F_init = 0.30))
    genetic_controls_html <- paste(as.character(output$stage_controls), collapse = "\n")
    expect_match(genetic_controls_html, 'data-from="0.3"', fixed = TRUE)

    selected_stage("catastrophe")
    session$setInputs(cat_freq = 0.18, cat_surv = 0.45, run_stage = 7)
    expect_equal(
      explore_assumptions(),
      list(F_init = 0.30, cat_freq = 0.18, cat_surv = 0.45)
    )
    catastrophe_controls_html <- paste(as.character(output$stage_controls), collapse = "\n")
    expect_match(catastrophe_controls_html, 'data-from="0.18"', fixed = TRUE)
    expect_match(catastrophe_controls_html, 'data-from="0.45"', fixed = TRUE)

    selected_stage("extinction_vortex")
    session$setInputs(cat_freq = 0.18, run_stage = 8)

    explore_controls <- captured[[length(captured)]]$controls
    expect_equal(explore_controls[names(expected_working)], expected_working)
    expect_equal(explore_controls$F_init, 0.30)
    expect_equal(explore_controls$cat_freq, 0.18)
    expect_equal(explore_controls$cat_surv, 0.45)
    expect_identical(working_assumptions(), before_explore)

    session$setInputs(confirm_clear_runs = 1)
    expect_identical(explore_assumptions(), list())
  })
})

test_that("Practical 1 repeated Start baseline is non-destructive after evidence downloads", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)

  shiny::testServer(env$make_practical1_server(), {
    session$setInputs(run_baseline = 1)
    selected_stage("environmental_stochasticity")
    session$setInputs(env_sd = 0.15, K = 15, run_stage = 1)
    selected_stage("intervention")
    session$setInputs(K = 70, K_sd = 5, run_stage = 2)
    interpretation <- "Risk increased; intervention improved abundance; uncertainty remained."
    session$setInputs(interpretation_note = interpretation)
    session$setInputs(confirm_interpretation = 1)

    output$download_comparison
    output$download_evidence_notes
    comparison_generator <- session$.__enclos_env__$private$file_generators$get(
      session$ns("download_comparison")
    )
    notes_generator <- session$.__enclos_env__$private$file_generators$get(
      session$ns("download_evidence_notes")
    )
    comparison_generator$content(tempfile(fileext = ".csv"))
    notes_generator$content(tempfile(fileext = ".md"))

    history_before <- run_history()
    history_ids_before <- vapply(history_before, session_run_id, integer(1))
    selected_ids_before <- selected_evidence_ids()
    signature_before <- interpretation_signature()
    current_baseline <- baseline_run()

    session$setInputs(run_baseline = 2)

    expect_identical(vapply(run_history(), session_run_id, integer(1)), history_ids_before)
    expect_identical(run_history(), history_before)
    expect_identical(selected_evidence_ids(), selected_ids_before)
    expect_identical(input$interpretation_note, interpretation)
    expect_identical(interpretation_signature(), signature_before)
    expect_true(download_requested$comparison)
    expect_true(download_requested$notes)
    expect_identical(current_run(), current_baseline)
    expect_equal(session_run_id(current_run()), 1L)
    expect_equal(next_run_id(), 4L)

    selected_stage("catastrophe")
    session$setInputs(run_stage = 3)
    selected_stage("extinction_vortex")
    session$setInputs(K = 25, cat_freq = 0.05, run_stage = 4)

    expect_equal(
      vapply(run_history(), session_run_id, integer(1)),
      1:5
    )
    expect_equal(next_run_id(), 6L)
  })
})

test_that("Practical 1 download requests stay bound to the current export identity", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)

  shiny::testServer(env$make_practical1_server(), {
    session$setInputs(run_baseline = 1)
    selected_stage("environmental_stochasticity")
    session$setInputs(env_sd = 0.15, K = 15, run_stage = 1)
    selected_stage("intervention")
    session$setInputs(K = 70, K_sd = 5, run_stage = 2)
    selected_stage("catastrophe")
    session$setInputs(cat_freq = 0.10, cat_surv = 0.50, run_stage = 3)
    session$setInputs(selected_risk_run_id = "2")

    interpretation <- "Risk increased; intervention improved abundance; uncertainty remained."
    session$setInputs(interpretation_note = interpretation)
    session$setInputs(confirm_interpretation = 1)
    expect_equal(selected_evidence_ids(), c(1L, 2L, 3L))
    expect_true(evidence_readiness_state()$ready)

    output$download_comparison
    output$download_evidence_notes
    comparison_generator <- session$.__enclos_env__$private$file_generators$get(
      session$ns("download_comparison")
    )
    notes_generator <- session$.__enclos_env__$private$file_generators$get(
      session$ns("download_evidence_notes")
    )
    comparison_generator$content(tempfile(fileext = ".csv"))
    notes_generator$content(tempfile(fileext = ".md"))

    expected_signature <- paste("1:2:3", trimws(interpretation), sep = "|")
    expect_true(download_requested$comparison)
    expect_true(download_requested$notes)
    expect_identical(download_recorded_signatures$comparison, expected_signature)
    expect_identical(download_recorded_signatures$notes, expected_signature)

    session$setInputs(selected_risk_run_id = "4")
    expect_equal(selected_evidence_ids(), c(1L, 4L, 3L))
    expect_false(download_requested$comparison)
    expect_false(download_requested$notes)
    expect_identical(download_recorded_signatures$comparison, "")
    expect_identical(download_recorded_signatures$notes, "")
    transfer <- paste(as.character(output$transfer_checklist), collapse = "\n")
    expect_match(transfer, "Not requested yet", all = TRUE)
    expect_false(grepl("Both evidence requests are complete", transfer, fixed = TRUE))

    session$setInputs(confirm_interpretation = 2)
    expect_true(evidence_readiness_state()$checks[["interpretation_current"]])
    expect_false(download_requested$comparison)
    expect_false(download_requested$notes)

    comparison_generator$content(tempfile(fileext = ".csv"))
    expect_true(download_requested$comparison)
    expect_false(download_requested$notes)
    notes_generator$content(tempfile(fileext = ".md"))
    expect_true(download_requested$comparison)
    expect_true(download_requested$notes)

    session$setInputs(interpretation_note = paste0("  ", interpretation, " revised  "))
    expect_false(download_requested$comparison)
    expect_false(download_requested$notes)
    expect_identical(download_recorded_signatures$comparison, "")
    expect_identical(download_recorded_signatures$notes, "")
  })
})

test_that("successful Practical 1 runs render a stable completion cue", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)

  shiny::testServer(env$make_practical1_server(), {
    session$setInputs(run_baseline = 1)
    selected_stage("carrying_capacity")
    session$setInputs(run_stage = 1)
    cue <- paste(as.character(output$run_status), collapse = "\n")
    expect_match(cue, "Mission complete:", fixed = TRUE)
    expect_match(cue, "Core 2: Island ceiling", fixed = TRUE)
    expect_match(cue, "Next Core action: Core 3: Individual chance", fixed = TRUE)
    expect_match(cue, 'data-run-id="2"', fixed = TRUE)
  })
})

test_that("Practical 1 reset waits for confirmation and clears session state", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)

  shiny::testServer(env$make_practical1_server(), {
    session$setInputs(run_baseline = 1)
    selected_stage("carrying_capacity")
    session$setInputs(run_stage = 1)
    expect_length(run_history(), 2L)
    session$setInputs(interpretation_note = "temporary interpretation")

    session$setInputs(clear_runs = 1)
    expect_length(run_history(), 2L)

    session$setInputs(confirm_clear_runs = 1)
    expect_length(run_history(), 0L)
    expect_false(baseline_started())
    expect_equal(selected_stage(), "deterministic_baseline")
    expect_null(run_error())
    expect_null(last_completed_stage())
    expect_true(is.na(last_completed_run_id()))
    expect_equal(current_run()$stage, "deterministic_baseline")
    expect_equal(baseline_run()$stage, "deterministic_baseline")
    expect_equal(next_run_id(), 1L)
  })
})

test_that("Practical 1 declares temporary state and guarded recovery", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")
  js_path <- file.path(app_dir, "www", "practical1.js")
  expect_true(file.exists(js_path))
  js_text <- paste(readLines(js_path, warn = FALSE), collapse = "\n")

  notice <- paste(
    "This browser session is temporary. Before you finish, use Compare to",
    "download your evidence."
  )
  count_fixed <- function(pattern, text) {
    hits <- gregexpr(pattern, text, fixed = TRUE)[[1]]
    if (identical(hits, -1L)) 0L else length(hits)
  }
  expect_equal(count_fixed(notice, app_text), 1L)
  expect_true(grepl("session_notice_ui()", app_text, fixed = TRUE))
  expect_equal(count_fixed("session_notice_ui()", app_text), 3L)
  expect_true(grepl('tags$script(src = "practical1.js")', app_text, fixed = TRUE))
  expect_true(grepl("showModal(modalDialog(", app_text, fixed = TRUE))
  expect_true(grepl("observeEvent(input$confirm_clear_runs", app_text, fixed = TRUE))
  expect_true(grepl('updateTextAreaInput(session, "interpretation_note", value = "")', app_text, fixed = TRUE))
  expect_true(grepl('role = "alert"', app_text, fixed = TRUE))
  expect_true(grepl('$(document).on("shiny:busy"', js_text, fixed = TRUE))
  expect_true(grepl('$(document).on("shiny:idle"', js_text, fixed = TRUE))
  expect_true(grepl('$("#run_stage:not(:disabled)")', js_text, fixed = TRUE))
  expect_true(grepl('$("#run_stage[data-shiny-busy-disabled=\'true\']")', js_text, fixed = TRUE))
})

test_that("Practical 1 final polish retains help and responsive state selectors", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")
  style_text <- paste(readLines(file.path(app_dir, "www", "styles.css"), warn = FALSE), collapse = "\n")
  action_ids <- c(
    "open_pva_deep_dive",
    "open_mission_deep_dive",
    "open_evidence_deep_dive",
    "open_core_explore_help",
    "open_parameter_help",
    "open_output_help",
    "open_diagnostic_help",
    "open_plot_help",
    "show_advanced_controls",
    "download_trajectory_plot",
    "download_summary_plot",
    "download_extinction_plot"
  )
  selectors <- c(
    ".session-notice",
    ".mission-group",
    ".mission-group-title",
    ".mission-step-status",
    ".mission-complete",
    ".session-history",
    ".evidence-selection",
    ".readiness-checklist",
    ".is-ready",
    ".is-missing",
    ".evidence-downloads",
    ".transfer-checklist",
    ":focus-visible"
  )

  expect_true(all(vapply(action_ids, grepl, logical(1), x = app_text, fixed = TRUE)))
  expect_true(all(vapply(selectors, grepl, logical(1), x = style_text, fixed = TRUE)))
  expect_match(style_text, "@media \\(max-width: 780px\\)")
  expect_match(style_text, "grid-template-columns: minmax\\(0,")
})

test_that("Practical 1 select controls retain visible keyboard focus styling", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  style_text <- paste(readLines(file.path(app_dir, "www", "styles.css"), warn = FALSE), collapse = "\n")

  expect_match(style_text, "select:focus-visible")
  expect_match(style_text, "\\.selectize-input\\.focus")
})

test_that("Practical 1 Week 1 documents use the same route and session language", {
  docs <- c(
    file.path(repo_root(), "docs", "teaching", "shiny", "practical-1-mission-tutorial.md"),
    file.path(repo_root(), "docs", "teaching", "woodhen", "practical-1-student-launch-page.md"),
    file.path(repo_root(), "docs", "teaching", "woodhen", "practical-1-mission-worksheet.md"),
    file.path(repo_root(), "docs", "teaching", "woodhen", "practical-1-day-of-class-pack.md"),
    file.path(repo_root(), "docs", "teaching", "woodhen", "practical-1-instructor-beat-sheet.md"),
    file.path(repo_root(), "docs", "teaching", "woodhen", "practical-1-moodle-ready-bundle", "moodle-section-text.md")
  )
  texts <- lapply(docs, function(path) paste(readLines(path, warn = FALSE), collapse = "\n"))
  route_block <- paste(
    "Start with the five **Core** model missions: Baseline compass, Island ceiling,",
    "Individual chance, Environmental variability, and Rescue attempt. Then go to **Compare**",
    "and build a three-run evidence set containing baseline, one risk mechanism, and",
    "one intervention or vortex run.",
    "",
    "When the Core route is complete, **Explore Further** remains available for",
    "genetic pressure, catastrophes, the extinction vortex, advanced controls,",
    "alternative comparisons, and optional plot downloads.",
    "",
    "This browser session is temporary. Before closing the tab, request both your",
    "comparison CSV and your evidence-notes Markdown file. Refreshing, closing the",
    "tab, or allowing the session to expire clears the in-app run history,",
    "selection, progress, and interpretation.",
    sep = "\n"
  )

  expect_true(all(vapply(texts, grepl, logical(1), pattern = "Core", fixed = TRUE)))
  expect_true(all(vapply(texts, grepl, logical(1), pattern = "Explore Further", fixed = TRUE)))
  expect_true(all(vapply(texts, grepl, logical(1), pattern = "temporary", fixed = TRUE)))
  expect_true(all(vapply(texts, grepl, logical(1), pattern = "comparison CSV", fixed = TRUE)))
  expect_true(all(vapply(texts, grepl, logical(1), pattern = "evidence notes", fixed = TRUE)))
  expect_true(all(vapply(texts, grepl, logical(1), pattern = route_block, fixed = TRUE)))

  timing <- paste(
    "The three-hour class uses approximately one hour for PVA teaching and a guided",
    "GUI introduction, followed by approximately two hours of self-paced Practical",
    "1 work while the instructor and demonstrators circulate.",
    sep = "\n"
  )
  expect_true(grepl(timing, texts[[4]], fixed = TRUE))
  expect_true(grepl(timing, texts[[5]], fixed = TRUE))
})

test_that("Practical 1 browser acceptance covers Core extension exports and viewports", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  repo_root <- normalizePath(file.path(app_dir, "..", "..", ".."), mustWork = TRUE)
  script_path <- file.path(repo_root, "scripts", "practical1_browser_acceptance.js")
  expect_true(file.exists(script_path))
  script <- paste(readLines(script_path, warn = FALSE), collapse = "\n")

  required_text <- c(
    "Core 2: Island ceiling",
    "Core 5: Rescue attempt",
    "Explore: Small-population pressure",
    "Explore: Rare bad years",
    "Explore: Vortex comparison",
    "Explore PVA",
    "Explore mission",
    "Explore evidence",
    "Control help",
    "Read outputs",
    "Read diagnostics",
    "Read plots",
    "Comparison CSV",
    "Evidence notes",
    "selected CSV has header plus three rows",
    "consoleErrors",
    "consoleWarnings",
    "pageErrors",
    "prepareEvidenceDirectory",
    "fs.rmSync",
    "path.isAbsolute",
    "Evidence directory must be an absolute path",
    "error.code !== \"ENOENT\"",
    "path.parse",
    "required overlap selectors exist at",
    "parseMarkdownTable",
    "CSV and Markdown selected run counts match",
    "CSV and Markdown ordered run IDs match",
    "CSV and Markdown selected stages match",
    "CSV and Markdown selected labels match",
    "CSV and Markdown shared comparison fields match",
    "Markdown settings rows refer to exactly the selected run-ID set",
    "Markdown settings has at least one row per selected run",
    "selected evidence has exactly one deterministic baseline",
    "selected evidence has exactly one allowed risk stage",
    "selected evidence has exactly one allowed intervention or vortex stage",
    "visited contextual and mission labels match expected set",
    "validateEvidenceDirectory",
    "evidenceDirectoryPrefix",
    "path.dirname(resolved) !== tmpRoot",
    "lstatSync",
    "isSymbolicLink",
    "if (require.main === module)",
    "module.exports",
    "final-comparison.csv",
    "final-evidence-notes.md",
    "final selected evidence is rendered as runs 1, 8, and 9",
    "Selected evidence: 3 runs from 9 successful session runs",
    "deterministic_baseline",
    "catastrophe",
    "extinction_vortex",
    "extension selection invalidates the old CSV request",
    "Transfer completes only after both fresh final downloads",
    "rendered run numbers are positive",
    "rendered run numbers are unique",
    "rendered run numbers are strictly increasing",
    "no page horizontal overflow at",
    "Concept Lab panel geometry is non-zero at",
    "mission labels have usable rendered width at",
    "mission labels preserve ordinary words at",
    "mission statuses have usable rendered geometry at",
    "Concept Lab 1366x768",
    "Concept Lab 1440x900",
    "Concept Lab 390x844",
    "Concept Lab mission controls are visible and enabled at 1440x900",
    "Compare 390x844",
    "Compare controls and downloads are visible at 390x844",
    "#stage_text .mission-label",
    "renderedSelectedEvidence",
    "stageMatchesVisibleCategory",
    "settingsByRun",
    "minimumLabelWidth",
    "CSV run IDs match rendered selected evidence",
    "Markdown labels match rendered selected evidence",
    "CSV stages match rendered visible stage categories",
    "Markdown settings and provenance substantively match rendered cards",
    "assertCompareTableScrollRegion",
    "compare table is horizontally scrollable when needed at",
    "compare table can programmatically reach its far edge at",
    "1366, height: 768",
    "width: 1440, height: 900",
    "width: 390, height: 844"
  )
  expect_true(all(vapply(required_text, grepl, logical(1), x = script, fixed = TRUE)))
})

test_that("Practical 1 browser cleanup validator rejects unsafe paths at runtime", {
  node <- Sys.which("node")
  skip_if(node == "")

  app_dir <- rPVA:::practical1_shiny_app_dir()
  script_path <- file.path(normalizePath(file.path(app_dir, "..", "..", ".."), mustWork = TRUE),
                           "scripts", "practical1_browser_acceptance.js")
  probe_path <- tempfile(fileext = ".js")
  probe <- c(
    "const fs = require('node:fs');",
    "const os = require('node:os');",
    "const path = require('node:path');",
    "const { validateEvidenceDirectory } = require(process.env.PRACTICAL1_SCRIPT);",
    "const tmp = path.resolve(os.tmpdir());",
    "const valid = path.join(tmp, `rpva-practical1-probe-${process.pid}`);",
    "const validMissing = path.join(tmp, `rpva-practical1-probe-missing-child-${process.pid}`);",
    "const target = path.join(tmp, `rpva-practical1-probe-target-${process.pid}`);",
    "const link = path.join(tmp, `rpva-practical1-probe-link-${process.pid}`);",
    "const relative = `rpva-practical1-relative-${process.pid}`;",
    "const danglingTarget = path.join(tmp, `rpva-practical1-probe-missing-${process.pid}`);",
    "const dangling = path.join(tmp, `rpva-practical1-probe-dangling-${process.pid}`);",
    "fs.mkdirSync(valid, { recursive: true });",
    "fs.mkdirSync(target, { recursive: true });",
    "fs.symlinkSync(target, link, 'dir');",
    "fs.symlinkSync(danglingTarget, dangling, 'file');",
    "const invalid = [",
    "  '', path.parse(tmp).root, process.cwd(), os.homedir(),",
    "  path.dirname(process.cwd()), tmp, path.resolve(tmp, '..'),",
    "  path.join(tmp, 'nested', 'rpva-practical1-nested'),",
    "  path.join(tmp, 'not-an-rpva-evidence-directory'), link, dangling",
    "];",
    "const rejected = invalid.map((candidate) => {",
    "  try { validateEvidenceDirectory(candidate); return false; }",
    "  catch (error) { return true; }",
    "});",
    "const validAccepted = validateEvidenceDirectory(valid) === valid;",
    "const validMissingAccepted = validateEvidenceDirectory(validMissing) === validMissing;",
    "let relativeRejected = false;",
    "try { validateEvidenceDirectory(relative); } catch (error) { relativeRejected = true; }",
    "let danglingSymlinkRejected = false;",
    "try { validateEvidenceDirectory(dangling); } catch (error) { danglingSymlinkRejected = true; }",
    "fs.rmSync(valid, { recursive: true, force: true });",
    "fs.rmSync(target, { recursive: true, force: true });",
    "fs.unlinkSync(link);",
    "fs.unlinkSync(dangling);",
    "console.log(JSON.stringify({ validAccepted, validMissingAccepted, rejected, relativeRejected, danglingSymlinkRejected }));"
  )
  writeLines(probe, probe_path)
  old_script <- Sys.getenv("PRACTICAL1_SCRIPT", unset = NA_character_)
  Sys.setenv(PRACTICAL1_SCRIPT = script_path)
  on.exit({
    if (is.na(old_script)) Sys.unsetenv("PRACTICAL1_SCRIPT") else Sys.setenv(PRACTICAL1_SCRIPT = old_script)
    unlink(probe_path, force = TRUE)
  }, add = TRUE)

  output <- system2(node, probe_path, stdout = TRUE, stderr = TRUE)
  status <- attr(output, "status")
  if (is.null(status)) status <- 0L
  expect_equal(status, 0L, info = paste(output, collapse = "\n"))
  probe_result <- jsonlite::fromJSON(paste(output, collapse = "\n"))
  expect_true(isTRUE(probe_result$validAccepted))
  expect_true(isTRUE(probe_result$validMissingAccepted))
  expect_true(all(probe_result$rejected))
  expect_true(isTRUE(probe_result$relativeRejected))
  expect_true(isTRUE(probe_result$danglingSymlinkRejected))
})

test_that("Practical 1 browser artifact helpers enforce strict final evidence", {
  node <- Sys.which("node")
  skip_if(node == "")

  app_dir <- rPVA:::practical1_shiny_app_dir()
  script_path <- file.path(normalizePath(file.path(app_dir, "..", "..", ".."), mustWork = TRUE),
                           "scripts", "practical1_browser_acceptance.js")
  probe_path <- tempfile(fileext = ".js")
  probe <- c(
    "const {",
    "  requiredComparisonFields,",
    "  sharedComparisonFieldsMatch,",
    "  exactRenderedStagesMatch,",
    "  canonicalExpectedSettings,",
    "  canonicalSpecRowsForEvidence,",
    "  settingsRowsExactlyMatch",
    "} = require(process.env.PRACTICAL1_SCRIPT);",
    "const csvHeaders = ['run_id', 'stage', 'label', 'scenario', 'years', 'reps', 'PE', 'Nmed', 'Nlo95', 'Nhi95', 'extinct_reps', 'surviving_reps', 'trajectory_available', 'delta_PE', 'delta_Nmed', 'uncertainty_change'];",
    "const markdownHeaders = [...csvHeaders];",
    "const complete = ['1', 'deterministic_baseline', 'Deterministic baseline', 'Deterministic baseline', '25', '1', '0', '264', '264', '264', '0', '1', 'FALSE', '0', '0', 'baseline'];",
    "const missing = [...complete]; missing[4] = undefined;",
    "const rendered = [{ runId: 1, label: 'Deterministic baseline', visibleStage: 'Baseline', settings: 'Reference settings' }, { runId: 8, label: 'Catastrophe', visibleStage: 'Risk mechanism', settings: 'cat_freq = 0.05' }];",
    "const expectedSpecs = { '1': [{ runId: 1, stage: 'deterministic_baseline', label: 'Deterministic baseline', setting: 'spec_name', value: 'teaching_deterministic_baseline' }], '8': [{ runId: 8, stage: 'catastrophe', label: 'Catastrophe', setting: 'spec_name', value: 'teaching_catastrophe' }] };",
    "const expectedSettings = canonicalExpectedSettings(rendered, expectedSpecs);",
    "const vortexSpecs = canonicalSpecRowsForEvidence([{ runId: 9, label: 'Extinction vortex comparison', settings: 'F_init = 0.3; cat_freq = 0.18' }])['9'];",
    "const actualSettings = [...expectedSettings];",
    "const extraSettings = [...actualSettings, { runId: 8, stage: 'catastrophe', label: 'Catastrophe', setting: 'spec_extra', value: 'unexpected' }];",
    "console.log(JSON.stringify({",
    "  requiredFieldsPresent: requiredComparisonFields.every((field) => csvHeaders.includes(field)),",
    "  completeAccepted: sharedComparisonFieldsMatch(csvHeaders, [complete], markdownHeaders, [complete]),",
    "  missingRejected: !sharedComparisonFieldsMatch(csvHeaders, [missing], markdownHeaders, [missing]),",
    "  exactStagesAccepted: exactRenderedStagesMatch(['deterministic_baseline', 'catastrophe'], rendered),",
    "  wrongStageRejected: !exactRenderedStagesMatch(['deterministic_baseline', 'intervention'], rendered),",
    "  exactSettingsAccepted: settingsRowsExactlyMatch(actualSettings, expectedSettings),",
    "  extraSettingsRejected: !settingsRowsExactlyMatch(extraSettings, expectedSettings),",
    "  vortexInbreedingRecorded: vortexSpecs.some((row) => row.setting === 'spec_F_init' && row.value === '0.3'),",
    "}));"
  )
  writeLines(probe, probe_path)
  old_script <- Sys.getenv("PRACTICAL1_SCRIPT", unset = NA_character_)
  Sys.setenv(PRACTICAL1_SCRIPT = script_path)
  on.exit({
    if (is.na(old_script)) Sys.unsetenv("PRACTICAL1_SCRIPT") else Sys.setenv(PRACTICAL1_SCRIPT = old_script)
    unlink(probe_path, force = TRUE)
  }, add = TRUE)

  output <- system2(node, probe_path, stdout = TRUE, stderr = TRUE)
  status <- attr(output, "status")
  if (is.null(status)) status <- 0L
  expect_equal(status, 0L, info = paste(output, collapse = "\n"))
  probe_result <- jsonlite::fromJSON(paste(output, collapse = "\n"))
  expect_true(isTRUE(probe_result$requiredFieldsPresent))
  expect_true(isTRUE(probe_result$completeAccepted))
  expect_true(isTRUE(probe_result$missingRejected))
  expect_true(isTRUE(probe_result$exactStagesAccepted))
  expect_true(isTRUE(probe_result$wrongStageRejected))
  expect_true(isTRUE(probe_result$exactSettingsAccepted))
  expect_true(isTRUE(probe_result$extraSettingsRejected))
  expect_true(isTRUE(probe_result$vortexInbreedingRecorded))
})
