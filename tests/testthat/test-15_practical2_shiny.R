context("Practical 2 Shiny app")

test_that("Practical 2 Shiny files are present", {
  app_dir <- system.file("shiny", "practical2", package = "rPVA")

  expect_true(dir.exists(app_dir))
  expect_true(file.exists(file.path(app_dir, "app.R")))
  expect_true(file.exists(file.path(app_dir, "www", "styles.css")))
  expect_true(file.exists(file.path(app_dir, "README.md")))
})

test_that("Practical 2 launcher exposes the expected app directory and arguments", {
  app_dir <- rPVA:::practical2_shiny_app_dir()

  expect_true(dir.exists(app_dir))
  expect_true(file.exists(file.path(app_dir, "app.R")))
  expect_true(all(c("host", "port", "launch.browser", "...") %in% names(formals(run_practical2_shiny))))
})

test_that("Practical 2 app can be constructed non-interactively", {
  testthat::skip_if_not_installed("shiny")

  app_dir <- rPVA:::practical2_shiny_app_dir()
  before <- list.files(".", all.files = TRUE, recursive = FALSE)
  app <- shiny::shinyAppDir(app_dir)
  after <- list.files(".", all.files = TRUE, recursive = FALSE)

  expect_s3_class(app, "shiny.appobj")
  expect_equal(after, before)
  expect_no_local_artifacts()
})

test_that("Practical 2 app exposes the Woodhen Management Lab flow", {
  app_dir <- rPVA:::practical2_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")
  style_text <- paste(readLines(file.path(app_dir, "www", "styles.css"), warn = FALSE), collapse = "\n")

  expect_true(grepl("Woodhen Management Lab", app_text, fixed = TRUE))
  expect_true(grepl("Management scenarios", app_text, fixed = TRUE))
  expect_true(grepl("Bounded sensitivity", app_text, fixed = TRUE))
  expect_true(grepl("Report bridge", app_text, fixed = TRUE))
  expect_true(grepl("woodhen_management_catalog()", app_text, fixed = TRUE))
  expect_true(grepl("run_woodhen_management_set", app_text, fixed = TRUE))
  expect_true(grepl("build_woodhen_management_evidence_export", app_text, fixed = TRUE))
  expect_true(grepl('downloadButton("download_woodhen_comparison"', app_text, fixed = TRUE))
  expect_true(grepl('downloadButton("download_woodhen_evidence"', app_text, fixed = TRUE))
  expect_true(grepl('textAreaInput("woodhen_interpretation"', app_text, fixed = TRUE))
  expect_match(style_text, "\\.scenario-card-grid")
  expect_match(style_text, "\\.scenario-card")
  expect_match(style_text, "\\.report-bridge")
})

test_that("Practical 2 app keeps students on bounded scenario choices", {
  app_dir <- rPVA:::practical2_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")

  expect_false(grepl("modifyList\\(", app_text))
  expect_false(grepl("textInput\\(", app_text))
  expect_false(grepl("source_yaml", app_text, fixed = TRUE))
  expect_true(grepl("01_no_mgmt", app_text, fixed = TRUE))
  expect_true(grepl("02_pig_control", app_text, fixed = TRUE))
  expect_true(grepl("03_captive_pig", app_text, fixed = TRUE))
  expect_true(grepl("sensitivity_default", app_text, fixed = TRUE))
  expect_true(grepl("survival_minus_10pct", app_text, fixed = TRUE))
  expect_true(grepl("K_250", app_text, fixed = TRUE))
  expect_true(grepl("cat_freq_0.10", app_text, fixed = TRUE))
})
