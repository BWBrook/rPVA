source_compare_app <- function() {
  app_dir <- system.file("shiny", "practical2", package = "rPVA")
  if (!nzchar(app_dir)) app_dir <- file.path("inst", "shiny", "practical2")
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)
  env
}

test_that("Compare probe uses current reviewed summary evidence", {
  env <- source_compare_app()
  future <- env$compare_probe_family("future")
  sensitivity <- env$compare_probe_family("sensitivity")
  context <- env$compare_probe_family("context")

  expect_true(future$compatible)
  expect_true(sensitivity$compatible)
  expect_false(context$compatible)
  expect_identical(
    future$evidence$summary$final_median_abundance,
    c(2163, 178, 1786)
  )
  expect_identical(
    future$evidence$summary$warning_probability,
    c(0, 0.923, 0.015)
  )
  expect_identical(
    sensitivity$evidence$summary$final_median_abundance,
    c(984, 2163, 3398)
  )
  expect_identical(
    sensitivity$evidence$summary$warning_probability,
    c(0.998, 0, 0)
  )
  expect_match(context$compatibility, "differ in")
  expect_match(context$compatibility, "matched family")
})

test_that("Compare probe exposes one purposeful view at a time", {
  env <- source_compare_app()
  future <- env$compare_probe_family("future")$evidence
  sensitivity <- env$compare_probe_family("sensitivity")$evidence
  change_summary <- env$compare_management_response_plot(future)

  expect_s3_class(env$compare_population_plot(future), "ggplot")
  expect_s3_class(env$compare_risk_plot(future), "ggplot")
  expect_s3_class(env$compare_final_plot(future), "ggplot")
  expect_s3_class(env$compare_passage_plot(future), "ggplot")
  expect_s3_class(change_summary, "patchwork")
  expect_s3_class(
    env$investigate_sensitivity_probe_plot(sensitivity$response),
    "ggplot"
  )
  if (inherits(change_summary, "patchwork")) {
    expect_identical(
      change_summary$patches$plots[[1L]]$labels$title,
      "Final abundance in 2100"
    )
    expect_identical(
      change_summary$labels$title,
      "Risk of falling below 100 pairs"
    )
    expect_identical(
      change_summary$layers[[1L]]$aes_params$colour,
      "#b23a48"
    )
    y_scale <- change_summary$scales$get_scales("y")
    expect_equal(y_scale$limits, c(0, 1))
  }

  expect_identical(
    unname(env$compare_view_choices("context")),
    "context"
  )
  expect_identical(
    unname(env$compare_view_choices("future")),
    c("population", "risk", "final", "passage", "response")
  )
  expect_identical(
    names(env$compare_view_choices("future"))[[5L]],
    "Change summary"
  )
})

test_that("Compare UI prioritises a family, evidence view, table, and reasoning", {
  env <- source_compare_app()
  html <- paste(as.character(env$compare_ui("compare")), collapse = "\n")

  for (id in c(
    "compare-family", "compare-open_library", "compare-open_help",
    "compare-open_evidence_help",
    "compare-view_controls", "compare-evidence_view",
    "compare-comparison_table", "compare-interpretation",
    "compare-caveat", "compare-save_reasoning", "compare-keep_controls"
  )) {
    expect_match(html, paste0('id="', id, '"'), fixed = TRUE)
  }
  expect_match(html, "Build one defensible comparison", fixed = TRUE)
  expect_match(html, "Browse project runs", fixed = TRUE)
  expect_match(html, "Choose for Evidence Studio", fixed = TRUE)
  expect_match(html, "What pattern does this comparison support?", fixed = TRUE)
  expect_match(html, "What uncertainty or limitation qualifies that pattern?", fixed = TRUE)
  expect_match(html, 'aria-disabled="true"', fixed = TRUE)
  expect_false(grepl(
    "seed|yaml|fingerprint|immutable|family_id",
    html,
    ignore.case = TRUE
  ))
})

test_that("Compare table uses whole birds and conditional timing language", {
  env <- source_compare_app()
  future <- env$compare_probe_table(env$compare_probe_family("future"))
  context <- env$compare_probe_table(env$compare_probe_family("context"))

  expect_identical(nrow(future), 3L)
  expect_match(
    future[["Final modelled median birds (95% interval)"]][[2L]],
    "178 \\(0 - 1,346\\)"
  )
  expect_match(
    future[["Conditional median crossing year"]][[2L]],
    "among futures that crossed"
  )
  expect_identical(
    context[["Below 100 pairs"]][[1L]],
    "Not comparable for this short historical check"
  )
  expect_false(any(grepl("\\.[0-9]{2,}", unlist(future))))
})

test_that("Compare help explains fair comparisons and evidence limits", {
  path <- file.path(
    system.file("shiny", "practical2", package = "rPVA"),
    "content", "help-compare.md"
  )
  if (!file.exists(path)) {
    path <- file.path(
      "inst", "shiny", "practical2", "content", "help-compare.md"
    )
  }
  text <- paste(readLines(path, warn = FALSE), collapse = "\n")

  expect_match(text, "matched scenario family", ignore.case = TRUE)
  expect_match(text, "100 territory-holding pairs", ignore.case = TRUE)
  expect_match(text, "conditional median", ignore.case = TRUE)
  expect_match(text, "not include all uncertainty", ignore.case = TRUE)
  expect_match(text, "not a universal minimum viable population", ignore.case = TRUE)
  expect_match(text, "one plot", ignore.case = TRUE)
  expect_match(text, "Change summary", fixed = TRUE)
  expect_match(text, "Evidence Studio", fixed = TRUE)
  expect_match(text, "Save comparison notes", fixed = TRUE)
  expect_false(grepl("Family response", text, fixed = TRUE))
})

test_that("Compare server switches compatible and context-only preview states", {
  env <- source_compare_app()

  shiny::testServer(
    env$compare_server,
    args = list(project = function() NULL),
    {
      session$setInputs(family = "future", keep_items = c("plot", "table"))
      expect_identical(active_family_id(), "future")
      expect_true(active_family()$compatible)
      expect_identical(input$keep_items, c("plot", "table"))

      session$setInputs(family = "context")
      expect_identical(active_family_id(), "context")
      expect_false(active_family()$compatible)
    }
  )
})
