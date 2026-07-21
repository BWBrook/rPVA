context("Practical 2 investigation shell")

practical2_app_dir <- function() {
  rPVA:::practical2_shiny_app_dir()
}

source_practical2_app <- function() {
  app_dir <- practical2_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)
  env
}

test_that("installed Practical 2 shell contains its complete Task 6 asset inventory", {
  app_dir <- practical2_app_dir()
  expected <- c(
    "README.md",
    "app.R",
    "content/help-projects.md",
    "content/start.md",
    "modules/mod_start.R",
    "project_helpers.R",
    "ui_helpers.R",
    "www/img/landing-woodhen-population.png",
    "www/project-store.js",
    "www/styles.css"
  )

  expect_true(dir.exists(app_dir))
  expect_true(all(file.exists(file.path(app_dir, expected))))
})

test_that("helpers and the real Start module source from the installed app directory", {
  env <- source_practical2_app()

  expect_true(all(vapply(
    c(
      "start_ui", "start_server", "pending_tab_ui", "project_help_modal",
      "project_store_key", "project_store_record", "make_practical2_server"
    ),
    exists,
    logical(1),
    envir = env,
    inherits = FALSE
  )))
  expect_s3_class(env$ui, "shiny.tag.list")
})

test_that("installed Practical 2 app constructs without repository artefacts", {
  testthat::skip_if_not_installed("shiny")

  app_dir <- practical2_app_dir()
  before <- list.files(".", all.files = TRUE, recursive = FALSE)
  app <- shiny::shinyAppDir(app_dir)
  after <- list.files(".", all.files = TRUE, recursive = FALSE)

  expect_s3_class(app, "shiny.appobj")
  expect_equal(after, before)
  expect_no_local_artifacts()
})

test_that("shell exposes exactly five visible stable tab values", {
  env <- source_practical2_app()
  html <- paste(as.character(env$ui), collapse = "\n")
  tab_values <- regmatches(
    html,
    gregexpr('data-value="(start|calibrate|investigate|compare|evidence)"', html)
  )[[1L]]

  expect_identical(
    unique(gsub('^data-value="|"$', "", tab_values)),
    c("start", "calibrate", "investigate", "compare", "evidence")
  )
  expect_match(html, ">Start<")
  expect_match(html, ">Calibrate<")
  expect_match(html, ">Investigate<")
  expect_match(html, ">Compare<")
  expect_match(html, ">Evidence Studio<")
})

test_that("Start controls and statuses are namespaced and accessible", {
  env <- source_practical2_app()
  html <- paste(as.character(env$start_ui("start")), collapse = "\n")

  for (id in c(
    "start-project_title", "start-owner_label", "start-create_project",
    "start-resume_key", "start-resume_project", "start-import_project",
    "start-download_project", "start-open_project_help",
    "start-project_browser_status", "start-project_portable_status",
    "start-project_dirty_status"
  )) {
    expect_match(html, paste0('id="', id, '"'), fixed = TRUE)
  }
  expect_match(html, 'alt="Lord Howe Island woodhen', fixed = TRUE)
  expect_match(html, 'aria-live="polite"', fixed = TRUE)
  expect_match(html, "Autosave in this browser", fixed = TRUE)
  expect_match(html, "Portable project", fixed = TRUE)
  expect_match(html, "Unsaved changes", fixed = TRUE)
})

test_that("Start narrative states the adviser, two-act, core-route, and extension contract", {
  app_dir <- practical2_app_dir()
  start_text <- paste(readLines(file.path(app_dir, "content", "start.md"), warn = FALSE), collapse = "\n")
  help_text <- paste(readLines(file.path(app_dir, "content", "help-projects.md"), warn = FALSE), collapse = "\n")

  expect_match(start_text, "present-day conservation adviser", ignore.case = TRUE)
  expect_match(start_text, "Act 1")
  expect_match(start_text, "Act 2")
  expect_match(start_text, "three-hour core route", ignore.case = TRUE)
  expect_match(start_text, "pass-level foundation", ignore.case = TRUE)
  expect_match(start_text, "independent work afterward", ignore.case = TRUE)
  expect_match(start_text, "Ways to deepen your investigation", fixed = TRUE)
  expect_false(grepl("grade|grading|score|scoring", start_text, ignore.case = TRUE))

  expect_match(help_text, "autosaved in this browser", ignore.case = TRUE)
  expect_match(help_text, "origin", ignore.case = TRUE)
  expect_match(help_text, "portable", ignore.case = TRUE)
  expect_match(help_text, "download requested", ignore.case = TRUE)
})

test_that("future tabs remain visible quiet bands without false completion", {
  env <- source_practical2_app()
  html <- paste(as.character(env$ui), collapse = "\n")

  expect_equal(length(gregexpr('class="pending-tab-band"', html, fixed = TRUE)[[1L]]), 4L)
  expect_match(html, "This workspace arrives in the next build stage", fixed = TRUE)
  expect_false(grepl("complete|completed|passed|report ready", html, ignore.case = TRUE))
  expect_false(any(file.exists(file.path(
    practical2_app_dir(), "modules",
    c("mod_calibrate.R", "mod_investigate.R", "mod_compare.R", "mod_evidence.R")
  ))))
})

test_that("root server owns replacement and module exposes reactive events", {
  app_dir <- practical2_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")
  module_text <- paste(readLines(file.path(app_dir, "modules", "mod_start.R"), warn = FALSE), collapse = "\n")

  expect_match(app_text, "project <- reactiveVal(NULL)", fixed = TRUE)
  expect_match(app_text, "validate_woodhen_project(candidate)", fixed = TRUE)
  expect_match(app_text, "project(candidate)", fixed = TRUE)
  expect_match(app_text, "events <- start_server", fixed = TRUE)
  expect_match(module_text, "moduleServer(id", fixed = TRUE)
  expect_match(module_text, "create_event <- eventReactive", fixed = TRUE)
  expect_match(module_text, "resume_event <- eventReactive", fixed = TRUE)
  expect_match(module_text, "import_event <- eventReactive", fixed = TRUE)
  expect_match(module_text, "output$download_project <- downloadHandler", fixed = TRUE)
  expect_match(module_text, "write_woodhen_project_package(candidate, file)", fixed = TRUE)
  expect_false(grepl("assign\\(|<<-", paste(app_text, module_text)))
})

test_that("failed project candidates preserve the live project", {
  env <- source_practical2_app()
  original <- new_woodhen_project("Live project", now = as.POSIXct("2026-07-22 09:00:00", tz = "UTC"))
  live <- shiny::reactiveVal(original)
  invalid <- original
  invalid$project_fingerprint <- paste(rep("0", 64), collapse = "")

  expect_error(
    shiny::isolate(env$replace_live_project(live, invalid)),
    "fingerprint"
  )
  expect_identical(shiny::isolate(live()), original)
})

test_that("Start returns validated create and failed import events to the root", {
  env <- source_practical2_app()
  invalid_package <- tempfile(fileext = ".zip")
  valid_package <- tempfile(fileext = ".zip")
  writeLines("not a portable project", invalid_package)
  valid_project <- new_woodhen_project("Imported advice")
  write_woodhen_project_package(valid_project, valid_package)
  on.exit(unlink(c(invalid_package, valid_package)), add = TRUE)

  neutral_status <- env$status_value("No active project yet.")
  shiny::testServer(env$start_server, args = list(
    project = function() NULL,
    inventory = function() list(),
    browser_status = function() neutral_status,
    portable_status = function() neutral_status,
    dirty_status = function() neutral_status
  ), {
    session$setInputs(
      project_title = "Cyclone advice",
      owner_label = "Study group",
      create_project = 1
    )
    create_result <- create_event()
    expect_true(create_result$ok)
    expect_s3_class(create_result$candidate, "woodhen_project")
    expect_identical(create_result$candidate$title, "Cyclone advice")

    session$setInputs(import_project = list(
      name = "invalid.zip",
      size = file.info(invalid_package)$size,
      type = "application/zip",
      datapath = invalid_package
    ))
    import_result <- import_event()
    expect_false(import_result$ok)
    expect_match(import_result$message, "ZIP|archive|portable")

    session$setInputs(import_project = list(
      name = "valid.zip",
      size = file.info(valid_package)$size,
      type = "application/zip",
      datapath = valid_package
    ))
    import_result <- import_event()
    expect_true(import_result$ok)
    expect_s3_class(import_result$candidate, "woodhen_project")
    expect_identical(import_result$candidate$project_id, valid_project$project_id)
  })
})

test_that("Practical 2 static styles carry the approved responsive and focus boundaries", {
  css <- paste(readLines(file.path(practical2_app_dir(), "www", "styles.css"), warn = FALSE), collapse = "\n")

  expect_match(css, "minmax\\(0,")
  expect_match(css, "flex-wrap:\\s*wrap")
  expect_match(css, ":focus-visible")
  expect_match(css, "overflow-x:\\s*hidden")
  expect_match(css, "@media \\(max-width: 780px\\)")
  expect_match(css, "grid-template-columns:\\s*repeat\\(2, minmax\\(0, 1fr\\)\\)")
  expect_match(css, "overflow-wrap:\\s*anywhere")
  expect_false(grepl("font-size:\\s*[^;]*(vw|vh)", css))
  expect_false(grepl("letter-spacing:\\s*-", css))
})

test_that("static shell checks do not claim live browser persistence", {
  app_dir <- practical2_app_dir()
  production_text <- paste(readLines(file.path(app_dir, "README.md"), warn = FALSE), collapse = "\n")
  overclaim <- paste("browser recovery", "passes")

  expect_false(grepl(overclaim, production_text, fixed = TRUE))
})
