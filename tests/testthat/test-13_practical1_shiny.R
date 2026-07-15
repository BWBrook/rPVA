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

test_that("risk plot panel is server-rendered for browser reliability", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- readLines(file.path(app_dir, "app.R"), warn = FALSE)

  expect_true(any(grepl('uiOutput\\("extinction_plot_panel"\\)', app_text)))
  expect_true(any(grepl("output\\$extinction_plot_panel <- renderUI", app_text)))
  expect_false(any(grepl("output\\.showExtinctionPlot", app_text)))
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

  expect_true(grepl("Mission 1: Baseline compass", app_text, fixed = TRUE))
  expect_true(grepl("creates or restores baseline as run 1", app_text, fixed = TRUE))
  expect_true(grepl("changing one visible control at a time", app_text, fixed = TRUE))
  expect_true(grepl("Choose a clean comparison: baseline run 1, one risk mechanism, and one intervention or vortex run.", app_text, fixed = TRUE))
  expect_true(grepl("Repeated clicks are less useful than a targeted one-factor change.", app_text, fixed = TRUE))
  expect_true(grepl("Use this stage only as a recovery run after resetting comparison.", app_text, fixed = TRUE))
})

test_that("Practical 1 opens with a tutorial landing screen", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")

  expect_true(grepl('class = "landing-hero"', app_text, fixed = TRUE))
  expect_true(grepl("Practical 1: Learning PVA", app_text, fixed = TRUE))
  expect_true(grepl("PVA Basics", app_text, fixed = TRUE))
  expect_false(grepl("Woodhen Practical 1", app_text, fixed = TRUE))
  expect_false(grepl("PVA mission", app_text, fixed = TRUE))
  expect_true(grepl("PVA is a way to test how a population might change", app_text, fixed = TRUE))
  expect_true(grepl('class = "landing-task-text"', app_text, fixed = TRUE))
  expect_true(grepl("What you will do", app_text, fixed = TRUE))
  expect_true(grepl("Evidence to save", app_text, fixed = TRUE))
  expect_true(grepl("Start baseline creates or restores baseline as run 1", app_text, fixed = TRUE))
  expect_true(grepl('actionButton("run_baseline"', app_text, fixed = TRUE))
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
  expect_true(grepl("many possible futures under assumptions", content_text$pva, fixed = TRUE))
  expect_true(grepl("Extinction risk", content_text$pva, fixed = TRUE))
  expect_true(grepl("Abundance", content_text$pva, fixed = TRUE))
  expect_true(grepl("Uncertainty", content_text$pva, fixed = TRUE))
  expect_true(grepl("Evidence for interpretation", content_text$pva, fixed = TRUE))

  expect_true(grepl("guided concept lab", content_text$mission, fixed = TRUE))
  expect_true(grepl("baseline as run 1", content_text$mission, fixed = TRUE))
  expect_true(grepl("change one factor at a time", content_text$mission, fixed = TRUE))
  expect_true(grepl("Compare", content_text$mission, fixed = TRUE))

  expect_true(grepl("comparison CSV", content_text$evidence, fixed = TRUE))
  expect_true(grepl("evidence-notes Markdown", content_text$evidence, fixed = TRUE))
  expect_true(grepl("one-sentence interpretation", content_text$evidence, fixed = TRUE))
  expect_true(grepl("support your explanation", content_text$evidence, fixed = TRUE))
  expect_true(grepl("trade-offs", content_text$evidence, fixed = TRUE))

  for (text in content_text) {
    expect_false(grepl("thylacine", text, ignore.case = TRUE))
    expect_false(grepl("Lord Howe", text, ignore.case = TRUE))
    expect_false(grepl("Gitea|stochastic|deployment|ShinyProxy|Docker|Moodle", text, ignore.case = TRUE))
  }

  expect_match(style_text, "\\.landing-card\\.is-interactive")
  expect_match(style_text, "\\.landing-card-action")
  expect_match(style_text, "\\.deep-dive-modal")
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

  expect_true(grepl("habitat ceiling", content_text$parameters, fixed = TRUE))
  expect_true(grepl("bad-year variation", content_text$parameters, fixed = TRUE))
  expect_true(grepl("starting inbreeding", content_text$parameters, fixed = TRUE))
  expect_true(grepl("catastrophe chance", content_text$parameters, fixed = TRUE))
  expect_true(grepl("simulation futures", content_text$parameters, fixed = TRUE))

  expect_true(grepl("PE", content_text$outputs, fixed = TRUE))
  expect_true(grepl("Nmed", content_text$outputs, fixed = TRUE))
  expect_true(grepl("uncertainty interval", content_text$outputs, fixed = TRUE))
  expect_true(grepl("PE = 0", content_text$outputs, fixed = TRUE))

  expect_true(grepl("warning", content_text$diagnostics, fixed = TRUE))
  expect_true(grepl("caveat", content_text$diagnostics, fixed = TRUE))
  expect_true(grepl("No major diagnostic warnings", content_text$diagnostics, fixed = TRUE))

  expect_true(grepl("trajectory", content_text$plots, fixed = TRUE))
  expect_true(grepl("summary interval", content_text$plots, fixed = TRUE))
  expect_true(grepl("risk detail", content_text$plots, fixed = TRUE))

  for (text in content_text) {
    expect_false(grepl("Woodhen|thylacine|\\bITS\\b|Gitea|Docker|Moodle|ShinyProxy", text, ignore.case = TRUE))
  }

  expect_true(grepl("7a. Rescue attempt", worksheet_text, fixed = TRUE))
  expect_true(grepl("7b. Vortex comparison", worksheet_text, fixed = TRUE))
  expect_false(grepl("7. Rescue or vortex", worksheet_text, fixed = TRUE))
  expect_match(style_text, "\\.contextual-help-button")
  expect_match(style_text, "\\.concept-help-strip")
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
  expect_true(grepl("Bad-year variation", app_text, fixed = TRUE))
  expect_true(grepl("Starting population", app_text, fixed = TRUE))
  expect_true(grepl("selected_stage_spec <- reactive", app_text, fixed = TRUE))
  expect_true(grepl("settings_for_display(selected_stage_spec(), baseline_run()$spec)", app_text, fixed = TRUE))
  expect_false(grepl("Setting = out$setting", app_text, fixed = TRUE))
  expect_false(grepl("Value = out$value", app_text, fixed = TRUE))
  expect_match(style_text, "\\.settings-table td:nth-child\\(4\\)")
})

test_that("Concept Lab exposes optional advanced risk controls", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")

  expect_true(grepl('checkboxInput("show_advanced_controls"', app_text, fixed = TRUE))
  expect_true(grepl("Show advanced risk controls", app_text, fixed = TRUE))
  expect_true(grepl("advanced_stage_controls <- function(stage)", app_text, fixed = TRUE))
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
  expect_match(app_text, "stage_control_values\\([^)]*advanced = isTRUE\\(input\\$show_advanced_controls\\)")
})

test_that("Concept Lab can save plot PNGs with automatic filenames", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")
  style_text <- paste(readLines(file.path(app_dir, "www", "styles.css"), warn = FALSE), collapse = "\n")

  expect_true(grepl('downloadButton("download_trajectory_plot"', app_text, fixed = TRUE))
  expect_true(grepl('downloadButton("download_summary_plot"', app_text, fixed = TRUE))
  expect_true(grepl('downloadButton("download_extinction_plot"', app_text, fixed = TRUE))
  expect_true(grepl("output$download_trajectory_plot <- downloadHandler", app_text, fixed = TRUE))
  expect_true(grepl("output$download_summary_plot <- downloadHandler", app_text, fixed = TRUE))
  expect_true(grepl("output$download_extinction_plot <- downloadHandler", app_text, fixed = TRUE))
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

    selected_export <- evidence_export()
    expect_equal(selected_export$comparison$run_id, c(1L, 2L, 4L))
    expect_equal(sort(unique(selected_export$settings$run_id)), c(1L, 2L, 4L))
    cards <- paste(as.character(output$run_cards), collapse = "\n")
    expect_true(all(vapply(c("Run 1", "Run 2", "Run 4"), grepl, logical(1), cards, fixed = TRUE)))
    expect_false(grepl("Run 3", cards, fixed = TRUE))

    interpretation <- "Risk increased under shared bad years; intervention improved abundance, with uncertainty remaining."
    session$setInputs(interpretation_note = interpretation)
    expect_identical(input$interpretation_note, interpretation)
    expect_true(evidence_readiness_state()$ready)

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

test_that("successful Practical 1 baseline reruns clear stale recovery state", {
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
    session$setInputs(run_stage = 1)
    expect_match(run_error(), "Use Start baseline")
    expect_equal(last_completed_stage(), "carrying_capacity")

    session$setInputs(run_baseline = 2)
    expect_null(run_error())
    expect_null(last_completed_stage())
    expect_true(is.na(last_completed_run_id()))
    expect_length(run_history(), 1L)
    expect_equal(next_run_id(), 2L)
    expect_true(baseline_started())
    expect_equal(selected_stage(), "deterministic_baseline")
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
    "This session is temporary. Download your comparison CSV and evidence notes",
    "before closing the app."
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
  expect_true(grepl('$("#run_stage").prop("disabled", true)', js_text, fixed = TRUE))
})
