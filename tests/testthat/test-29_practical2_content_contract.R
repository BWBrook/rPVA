source_assessment_module <- function() {
  app_dir <- testthat::test_path(
    "..", "..", "inst", "shiny", "practical2"
  )
  env <- new.env(parent = globalenv())
  env$practical2_app_dir <- normalizePath(
    app_dir, winslash = "/", mustWork = TRUE
  )
  sys.source(
    file.path(app_dir, "ui_helpers.R"),
    envir = env
  )
  sys.source(
    file.path(app_dir, "modules", "mod_assessment.R"),
    envir = env
  )
  env
}

assessment_content_text <- function() {
  content_dir <- testthat::test_path(
    "..", "..", "inst", "shiny", "practical2", "content"
  )
  paths <- file.path(content_dir, c(
    "report-guidance.md",
    "woodhen-research.md",
    "ways-to-deepen.md"
  ))
  paste(vapply(
    paths,
    function(path) paste(readLines(path, warn = FALSE), collapse = "\n"),
    character(1)
  ), collapse = "\n")
}

test_that("Assessment Task preserves locked ILOs and criteria exactly", {
  env <- source_assessment_module()
  expect_identical(env$assessment_ilos(), c(
    "Discuss the requirements for success in effective species conservation by integrating theory and case studies.",
    "Diagnose and solve biodiversity problems by applying fundamental principles from population and community ecology, genetics and ecosystem science.",
    "Evaluate the causes of uncertainty and controversy in the development of strategies for species conservation.",
    "Communicate a conservation problem to scientific peers and relevant stakeholders."
  ))
  criteria <- env$assessment_criteria()
  expect_identical(criteria$criterion, paste0("C", 1:4))
  expect_identical(criteria$marks, c(5L, 6L, 8L, 6L))
  expect_identical(criteria$assessment_criteria, c(
    "Describe the uses and limitations of simulation modelling in conservation decision-making.",
    "Model stochastic processes and causes of threat.",
    "Undertake scenario testing to compare the relative effectiveness of alternative management options.",
    "Translate simulation results and communicate them as conservation recommendations."
  ))
})

test_that("Assessment guidance informs without scoring or writing the report", {
  text <- assessment_content_text()
  expect_match(text, "portfolio", ignore.case = TRUE)
  expect_match(text, "dossier", ignore.case = TRUE)
  expect_match(text, "report", ignore.case = TRUE)
  expect_match(text, "three-setting sensitivity", ignore.case = TRUE)
  expect_match(text, "one named ecological factor", ignore.case = TRUE)
  expect_match(text, "encouraged, but not required", ignore.case = TRUE)
  expect_match(text, "not a quota", ignore.case = TRUE)
  expect_false(grepl(
    "assessment ready|grade estimate|high distinction|pass-level|fixed headings|write this sentence",
    text,
    ignore.case = TRUE
  ))
})

assessment_run <- function(family_id, scenario_type,
                           scenario_id = paste(family_id, scenario_type)) {
  list(
    family_id = family_id,
    scenario_type = scenario_type,
    scenario_id = scenario_id
  )
}

test_that("Assessment summary counts only complete comparison families", {
  env <- source_assessment_module()
  runs <- c(
    list(
      assessment_run("sens_a", "locked_baseline"),
      assessment_run("sens_a", "sensitivity"),
      assessment_run("sens_a", "sensitivity"),
      assessment_run("future_a", "locked_baseline"),
      assessment_run("future_a", "threat"),
      assessment_run("future_a", "intervention"),
      assessment_run("incomplete", "locked_baseline"),
      assessment_run("incomplete", "threat")
    ),
    lapply(
      c("01_no_mgmt", "02_pig_control", "03_captive_pig",
        "04_rodent_eradication"),
      function(id) assessment_run(id, "reference", id)
    )
  )
  expect_identical(
    env$assessment_family_counts(runs),
    c(sensitivity = 1L, future = 1L)
  )
})

test_that("Assessment project summary is neutral and does not mutate input", {
  env <- source_assessment_module()
  empty <- env$assessment_safe_project_summary(NULL)
  expect_identical(empty$status, "empty")

  project <- list(
    title = "Woodhen advice",
    owner_label = "Student 17",
    runs = list(
      assessment_run("01_no_mgmt", "reference", "01_no_mgmt"),
      assessment_run("sens_a", "locked_baseline"),
      assessment_run("sens_a", "sensitivity"),
      assessment_run("sens_a", "sensitivity"),
      assessment_run("future_a", "locked_baseline"),
      assessment_run("future_a", "threat"),
      assessment_run("future_a", "intervention")
    ),
    observations = list(list(note = "A saved observation")),
    evidence_items = list(list(evidence_id = "evidence_1"))
  )
  before <- serialize(project, NULL)
  summary <- env$assessment_safe_project_summary(project)

  expect_identical(summary$status, "available")
  expect_identical(summary$title, "Woodhen advice")
  expect_identical(summary$owner_label, "Student 17")
  expect_identical(summary$historical_count, 1L)
  expect_identical(summary$sensitivity_count, 1L)
  expect_identical(summary$future_count, 1L)
  expect_identical(summary$observation_count, 1L)
  expect_identical(summary$portfolio_count, 1L)
  expect_identical(serialize(project, NULL), before)

  unavailable <- env$assessment_safe_project_summary(list(title = "broken"))
  expect_identical(unavailable$status, "unavailable")
})
