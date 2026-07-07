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
  expect_true(grepl('updateSelectInput(session, "stage", selected = default_stage)', app_text, fixed = TRUE))
})

test_that("stage runs collect only visible controls", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")

  expect_match(app_text, "visible_stage_controls <- function\\(stage\\)")
  expect_true(grepl("stage_control_values <- function(stage, input)", app_text, fixed = TRUE))
  expect_true(grepl("allowed <- visible_stage_controls(stage)", app_text, fixed = TRUE))
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
  expect_true(grepl("Practical 1 PVA mission", app_text, fixed = TRUE))
  expect_true(grepl("PVA is a way to test how a population might change", app_text, fixed = TRUE))
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
  expect_true(grepl('uiOutput("mission_rail")', app_text, fixed = TRUE))
  expect_true(grepl('actionButton("next_mission"', app_text, fixed = TRUE))
  expect_true(grepl("output$mission_rail <- renderUI", app_text, fixed = TRUE))
  expect_true(grepl("observeEvent(input$next_mission", app_text, fixed = TRUE))
  expect_match(style_text, "\\.mission-rail")
  expect_match(style_text, "\\.mission-step\\.is-current")
  expect_match(style_text, "\\.mission-step\\.is-complete")
})

test_that("Compare view exposes run cards, baseline deltas, and interpretation capture", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")
  style_text <- paste(readLines(file.path(app_dir, "www", "styles.css"), warn = FALSE), collapse = "\n")

  expect_true(grepl("run_cards_ui <- function(runs)", app_text, fixed = TRUE))
  expect_true(grepl('uiOutput("run_cards")', app_text, fixed = TRUE))
  expect_true(grepl("output$run_cards <- renderUI", app_text, fixed = TRUE))
  expect_true(grepl("compare_teaching_runs(run_history(), include_deltas = TRUE)", app_text, fixed = TRUE))
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
    "landing-woodhen-population.png",
    "landing-trajectory-evidence.png",
    "landing-conservation-decision.png"
  )

  expect_true(dir.exists(asset_dir))
  expect_true(all(file.exists(file.path(asset_dir, expected_assets))))
  expect_true(grepl("img/landing-woodhen-population.png", app_text, fixed = TRUE))
  expect_true(grepl("img/landing-trajectory-evidence.png", app_text, fixed = TRUE))
  expect_true(grepl("img/landing-conservation-decision.png", app_text, fixed = TRUE))
  expect_match(app_text, 'alt = "[^"]+woodhen[^"]+"')
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
  expect_match(style_text, "@media \\(max-width: 780px\\)")
  expect_match(style_text, "\\.landing-hero,\\s*\\.landing-card-grid")
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
