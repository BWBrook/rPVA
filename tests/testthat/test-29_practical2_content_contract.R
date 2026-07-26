source_assessment_module <- function() {
  app_dir <- testthat::test_path(
    "..", "..", "inst", "shiny", "practical2"
  )
  env <- new.env(parent = asNamespace("shiny"))
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

assessment_surface_text <- function(env) {
  gsub("\\s+", " ", paste(
    paste(as.character(env$assessment_ui("assessment")), collapse = "\n"),
    assessment_content_text(),
    sep = "\n"
  ))
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
  env <- source_assessment_module()
  text <- assessment_surface_text(env)
  expect_match(text, "portfolio", ignore.case = TRUE)
  expect_match(text, "dossier", ignore.case = TRUE)
  expect_match(text, "report", ignore.case = TRUE)
  expect_match(text, "three-setting sensitivity", ignore.case = TRUE)
  expect_match(text, "one named ecological factor", ignore.case = TRUE)
  expect_match(
    text,
    "Use the portfolio as your broad working record",
    fixed = TRUE
  )
  expect_match(
    text,
    "Adapt the structure to make your reasoning easy to follow",
    fixed = TRUE
  )
  expect_match(
    text,
    "Treat four or five principal display items as a soft planning guide",
    fixed = TRUE
  )
  expect_match(
    text,
    "The report is the routine submission",
    fixed = TRUE
  )
  expect_match(
    text,
    "a plausibility check rather than independent validation",
    fixed = TRUE
  )
  expect_match(
    text,
    "Select enough high-quality sources to support the claims and ecological reasoning in your report",
    fixed = TRUE
  )
  expect_match(
    text,
    "Treat uncertainty and limitations explicitly",
    fixed = TRUE
  )
  expect_false(grepl(
    paste(
      "not a partly written report",
      "possibilities rather than templates",
      "not a quota",
      "no arbitrary source quota",
      "not from complexity for its own sake",
      sep = "|"
    ),
    text,
    ignore.case = TRUE
  ))
  expect_false(grepl("\\bhonest(?:ly)?\\b", text, ignore.case = TRUE))
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
  expect_identical(empty, list(
    status = "empty", title = NULL, owner_label = NULL,
    historical_count = 0L, sensitivity_count = 0L, future_count = 0L,
    observation_count = 0L, portfolio_count = 0L
  ))

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
  expect_identical(unavailable, list(
    status = "unavailable", title = NULL, owner_label = NULL,
    historical_count = 0L, sensitivity_count = 0L, future_count = 0L,
    observation_count = 0L, portfolio_count = 0L
  ))
})

test_that("Assessment summary rejects missing or empty run identities", {
  env <- source_assessment_module()
  invalid_runs <- list(
    list(assessment_run(NA_character_, "sensitivity")),
    list(assessment_run("", "sensitivity")),
    list(assessment_run("family_a", NA_character_)),
    list(assessment_run("family_a", ""))
  )
  for (runs in invalid_runs) {
    expect_error(
      env$assessment_family_counts(runs),
      "Run identity is unavailable."
    )
    project <- list(
      title = "Woodhen advice",
      owner_label = "Student 17",
      runs = runs,
      observations = list(),
      evidence_items = list()
    )
    expect_identical(
      env$assessment_safe_project_summary(project)$status,
      "unavailable"
    )
  }
})

test_that("Assessment UI exposes the approved readable hierarchy", {
  env <- source_assessment_module()
  html <- paste(as.character(env$assessment_ui("assessment")), collapse = "\n")
  for (text in c(
    "Woodhen Conservation Advice",
    "Your investigation at a glance",
    "The investigation",
    "What is assessed",
    "Develop your investigation",
    "Build a coherent argument",
    "Use evidence selectively",
    "Research the Woodhen",
    "Ways to deepen your investigation",
    "Final self-check"
  )) {
    expect_match(html, text, fixed = TRUE)
  }
  expect_match(html, 'id="assessment-investigation_summary"', fixed = TRUE)
  expect_match(html, 'id="assessment-go_calibrate"', fixed = TRUE)
  expect_match(html, 'id="assessment-go_investigate"', fixed = TRUE)
  expect_match(html, 'id="assessment-go_compare"', fixed = TRUE)
  expect_match(html, 'id="assessment-go_evidence"', fixed = TRUE)
  for (index in seq_along(env$assessment_ilos())) {
    expect_match(
      html,
      paste0('<span class="assessment-ilo-label">ILO ', index, "</span>"),
      fixed = TRUE
    )
    expect_match(
      html,
      env$assessment_ilos()[[index]],
      fixed = TRUE
    )
  }
})

test_that("Assessment server remains read-only and emits bounded navigation", {
  env <- source_assessment_module()

  shiny::testServer(
    env$assessment_server,
    args = list(project = NULL),
    {
      expect_identical(summary()$status, "empty")
      session$setInputs(go_calibrate = 1)
      expect_null(navigate())
      session$setInputs(go_calibrate = 2)
      expect_identical(
        navigate(),
        list(section = "calibrate", event_id = 1L)
      )
    }
  )

  project <- list(
    title = "Project-aware assessment",
    owner_label = "Student 17",
    runs = list(
      assessment_run("sens_a", "locked_baseline"),
      assessment_run("sens_a", "sensitivity"),
      assessment_run("sens_a", "sensitivity")
    ),
    observations = list(),
    evidence_items = list()
  )
  before <- serialize(project, NULL)
  live <- shiny::reactiveVal(project)
  shiny::testServer(
    env$assessment_server,
    args = list(project = shiny::reactive(live())),
    {
      expect_identical(summary()$status, "available")
      expect_identical(summary()$sensitivity_count, 1L)
      expect_no_error(output$investigation_summary)
    }
  )
  expect_identical(serialize(project, NULL), before)
})

test_that("Assessment navigation observers explicitly ignore initial values", {
  module_path <- testthat::test_path(
    "..", "..", "inst", "shiny", "practical2", "modules",
    "mod_assessment.R"
  )
  source_text <- paste(readLines(module_path, warn = FALSE), collapse = "\n")
  matches <- gregexpr("ignoreInit = TRUE", source_text, fixed = TRUE)[[1L]]
  expect_identical(
    sum(matches > 0L),
    1L
  )
  expect_identical(source_assessment_module()$assessment_navigation_targets(), c(
    "calibrate", "investigate", "compare", "evidence"
  ))
})

test_that("Assessment navigation accepts only working evidence tabs", {
  env <- source_assessment_module()
  for (section in c("calibrate", "investigate", "compare", "evidence")) {
    expect_identical(
      env$validate_assessment_navigation_event(list(
        section = section,
        event_id = 1L
      )),
      section
    )
  }
  for (section in c("start", "assessment", "unknown")) {
    expect_error(
      env$validate_assessment_navigation_event(list(
        section = section,
        event_id = 1L
      )),
      "invalid"
    )
  }
  malformed <- list(
    NULL,
    "compare",
    list(section = "compare"),
    list(event_id = 1L, section = "compare"),
    list(section = "compare", event_id = 0L),
    list(section = "compare", event_id = 1.5),
    list(section = c("compare", "evidence"), event_id = 1L)
  )
  for (event in malformed) {
    expect_error(
      env$validate_assessment_navigation_event(event),
      "invalid"
    )
  }
})

test_that("Assessment research guidance supports selective scientific context", {
  text <- gsub("\\s+", " ", assessment_content_text())
  for (accepted in c(
    "good scientific citation practice",
    "relevant, credible scientific and management sources",
    "Attach citations to the claims they support",
    "population viability analysis as a quantitative tool for extinction-risk assessment and conservation decision-making",
    "approximately 2,000-word report",
    "concise, well-written, selective synthesis",
    "strengthen your argument"
  )) {
    expect_match(text, accepted, fixed = TRUE)
  }
})
