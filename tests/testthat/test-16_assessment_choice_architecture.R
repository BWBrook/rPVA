context("Assessment choice architecture")

read_assessment_text <- function(path) {
  paste(readLines(file.path(repo_root(), path), warn = FALSE), collapse = "\n")
}

test_that("Assessment brief requires an individual analytical choice", {
  brief <- read_assessment_text("docs/teaching/woodhen/assessment-brief-2026-draft.md")

  expect_true(grepl("Individual analytical choice", brief, fixed = TRUE))
  expect_true(grepl("Decision lens", brief, fixed = TRUE))
  expect_true(grepl("selected focal scenario", brief, fixed = TRUE))
  expect_true(grepl("chosen sensitivity ID", brief, fixed = TRUE))
  expect_true(grepl("expected direction", brief, fixed = TRUE))
  expect_true(grepl("condition that would change your advice", brief, fixed = TRUE))
  expect_true(grepl("full core Woodhen scenario comparison", brief, fixed = TRUE))
})

test_that("Report scaffold requires explicit student choices before rendering", {
  scaffold <- read_assessment_text("docs/teaching/woodhen/report-scaffold.qmd")

  expect_true(grepl("assert_student_choices", scaffold, fixed = TRUE))
  expect_true(grepl('decision_lens <- Sys.getenv("RPVA_DECISION_LENS"', scaffold, fixed = TRUE))
  expect_true(grepl('selected_scenario_id <- Sys.getenv("RPVA_SELECTED_SCENARIO_ID"', scaffold, fixed = TRUE))
  expect_true(grepl('chosen_sensitivity_id <- Sys.getenv("RPVA_CHOSEN_SENSITIVITY_ID"', scaffold, fixed = TRUE))
  expect_true(grepl("choose_one_core_scenario", scaffold, fixed = TRUE))
  expect_true(grepl("choose_one_sensitivity", scaffold, fixed = TRUE))
  expect_true(grepl("sensitivity_default", scaffold, fixed = TRUE))
  expect_true(grepl("run_woodhen_management_scenario(selected_scenario_id", scaffold, fixed = TRUE))
  expect_match(scaffold, 'run_woodhen_management_set\\(\\s*c\\("sensitivity_default", chosen_sensitivity_id\\)')
  expect_false(grepl('selected_run <- run_woodhen_management_scenario("02_pig_control"', scaffold, fixed = TRUE))
  expect_false(grepl('c("sensitivity_default", "K_250")', scaffold, fixed = TRUE))
})

test_that("Rubric and feedback identify mechanical scaffold use", {
  rubric <- read_assessment_text("docs/teaching/woodhen/marking-rubric-2026-draft.md")
  feedback <- read_assessment_text("docs/teaching/woodhen/feedback-template-2026-draft.md")
  crosswalk <- read_assessment_text("docs/teaching/woodhen/assessment-design-crosswalk-2026.md")

  expect_true(grepl("mechanical use of the scaffold", rubric, fixed = TRUE))
  expect_true(grepl("total maximum 17/25", rubric, fixed = TRUE))
  expect_true(grepl("individual analytical choice", feedback, fixed = TRUE))
  expect_true(grepl("decision lens", feedback, fixed = TRUE))
  expect_true(grepl("fixed common evidence", crosswalk, fixed = TRUE))
  expect_true(grepl("declared controlled choice", crosswalk, fixed = TRUE))
})

test_that("Practical 2 launch page tells students what to save before export", {
  launch <- read_assessment_text("docs/teaching/woodhen/practical-2-student-launch-page.md")

  expect_true(grepl("Before you export", launch, fixed = TRUE))
  expect_true(grepl("core comparison CSV", launch, fixed = TRUE))
  expect_true(grepl("sensitivity comparison CSV", launch, fixed = TRUE))
  expect_true(grepl("student choice note", launch, fixed = TRUE))
})
