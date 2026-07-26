context("Assessment choice architecture")

read_assessment_text <- function(path) {
  paste(readLines(file.path(repo_root(), path), warn = FALSE), collapse = "\n")
}

normalize_document_text <- function(text) {
  gsub("[[:space:]]+", " ", text)
}

expect_document_contains <- function(text, required) {
  text <- normalize_document_text(text)
  for (phrase in required) {
    expect_match(text, normalize_document_text(phrase), fixed = TRUE)
  }
}

expect_document_omits <- function(text, obsolete) {
  text <- tolower(normalize_document_text(text))
  for (phrase in obsolete) {
    expect_false(grepl(
      tolower(normalize_document_text(phrase)), text, fixed = TRUE
    ))
  }
}

locked_assessment_criteria <- c(
  "Describe the uses and limitations of simulation modelling in conservation decision-making.",
  "Model stochastic processes and causes of threat.",
  "Undertake scenario testing to compare the relative effectiveness of alternative management options.",
  "Translate simulation results and communicate them as conservation recommendations."
)

test_that("assessment brief defines the complete evidence-led report journey", {
  brief <- read_assessment_text(
    "docs/teaching/woodhen/assessment-brief-2026-draft.md"
  )

  expect_document_contains(brief, c(
    "approximately 2,000 words",
    "Display items and references are excluded",
    "historical reconstruction",
    "three-setting one-factor sensitivity",
    "no-change baseline",
    "threatened future",
    "managed threatened future",
    "Evidence Portfolio",
    "evidence dossier",
    "student-authored report",
    "MyLO",
    "Wider Woodhen research",
    "conventional scientific sequence",
    "decision-led sequence",
    "evidence-led sequence",
    "soft planning guide"
  ))
  expect_document_contains(brief, locked_assessment_criteria)
  expect_document_contains(brief, c(
    "| C1 | 5 |",
    "| C2 | 6 |",
    "| C3 | 8 |",
    "| C4 | 6 |"
  ))
  expect_document_omits(brief, c(
    "Individual analytical choice",
    "selected focal scenario",
    "chosen sensitivity ID",
    "full core Woodhen scenario comparison",
    "one bounded student-chosen sensitivity, threat, or intervention test",
    "report scaffold",
    "R commands",
    "YAML editing",
    "shell commands",
    "Suggested length",
    "Maximum: 2000 words"
  ))
})

test_that("marking rubric preserves locked criteria and assesses all evidence families", {
  rubric <- read_assessment_text(
    "docs/teaching/woodhen/marking-rubric-2026-draft.md"
  )

  expect_document_contains(rubric, locked_assessment_criteria)
  expect_document_contains(rubric, c(
    "| C1 | 5 |",
    "| C2 | 6 |",
    "| C3 | 8 |",
    "| C4 | 6 |",
    "approximately 2,000 words",
    "Display items and references are excluded",
    "historical reconstruction",
    "three-setting one-factor sensitivity",
    "no-change baseline",
    "threatened future",
    "managed threatened future",
    "The report is the assessed synthesis",
    "Evidence Portfolio",
    "evidence dossier"
  ))
  expect_document_omits(rubric, c(
    "all core Woodhen scenarios",
    "sensitivity, threat, or intervention test",
    "mechanical use of the scaffold",
    "total maximum 17/25",
    "approved sensitivity ID",
    "optional artefacts"
  ))
})

test_that("assessment crosswalk records the six-tab evidence journey", {
  crosswalk <- read_assessment_text(
    "docs/teaching/woodhen/assessment-design-crosswalk-2026.md"
  )

  expect_document_contains(crosswalk, locked_assessment_criteria)
  expect_document_contains(crosswalk, c(
    "| C1 | 5 |",
    "| C2 | 6 |",
    "| C3 | 8 |",
    "| C4 | 6 |",
    "Start",
    "Calibrate",
    "Investigate",
    "Compare",
    "Evidence Studio",
    "Assessment Task",
    "historical reconstruction",
    "three-setting one-factor sensitivity",
    "no-change baseline",
    "threatened future",
    "managed threatened future",
    "Evidence Portfolio",
    "evidence dossier",
    "student-authored report",
    "evidence-dossier.docx",
    "numbered PNG",
    "numbered CSV"
  ))
  expect_document_omits(crosswalk, c(
    "edit YAML",
    "shell-command requirement",
    "all five core scenarios",
    "sensitivity, threat, or intervention test",
    "comparison CSV and evidence-notes exports",
    "If Shiny is introduced later"
  ))
})

test_that("classroom checklist exercises the implemented student route", {
  checklist <- read_assessment_text(
    "docs/teaching/woodhen/classroom-dry-run-checklist.md"
  )

  expect_document_contains(checklist, c(
    "six tabs",
    "Assessment Task",
    "no project",
    "project-aware neutral summary",
    "exact ILO",
    "C1-C4",
    "does not score",
    "does not generate submission prose",
    "does not impose quotas",
    "Calibrate",
    "Investigate",
    "Compare",
    "Evidence Studio",
    "MyLO",
    "evidence-dossier.docx",
    "numbered PNG",
    "numbered CSV"
  ))
  expect_document_omits(checklist, c(
    "run_scenarios(",
    "five-row reference table",
    "command log",
    "report scaffold",
    "RPVA_DECISION_LENS",
    "quarto render",
    "one management-scenario plot",
    "one bounded sensitivity table"
  ))
})

test_that("Practical 2 README describes the working app and dossier bundle", {
  readme <- read_assessment_text("inst/shiny/practical2/README.md")

  expect_document_contains(readme, c(
    "Start",
    "Calibrate",
    "Investigate",
    "Compare",
    "Evidence Studio",
    "Assessment Task",
    "six-tab",
    "read-only",
    "project-aware",
    "evidence-dossier.docx",
    "numbered PNG",
    "numbered CSV",
    "selected plots",
    "selected tables",
    "empty-state",
    "browser",
    "The ZIP contains source material only",
    "Markdown and PDF are outside the dossier export contract",
    paste(
      "Students write all report prose, interpretations, recommendations,",
      "captions, and references"
    )
  ))
})
