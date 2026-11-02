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

test_that("student start-here page limits dossier requests to the accepted review boundary", {
  document <- read_assessment_text(
    "docs/teaching/woodhen/practical-2-start-here.md"
  )

  expect_document_contains(document, c(
    "The dossier is not separately marked",
    "clarification, provenance, or academic-integrity review"
  ))
  expect_document_omits(document, "particular purpose")
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
