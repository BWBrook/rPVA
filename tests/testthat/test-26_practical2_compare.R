source_compare_app <- function() {
  app_dir <- system.file("shiny", "practical2", package = "rPVA")
  if (!nzchar(app_dir)) app_dir <- file.path("inst", "shiny", "practical2")
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)
  env
}

compare_test_run <- function(scenario, abundance_shift = 0) {
  years <- scenario$spec$years
  reps <- scenario$spec$reps
  replicate_effect <- (seq_len(reps) %% 31L) - 15L
  total <- outer(0:years, replicate_effect, function(year, effect) {
    pmax(0, round(650 + abundance_shift + 2 * year + effect))
  })
  traj <- array(0, dim = c(years + 1L, length(scenario$spec$n0), reps))
  traj[, 1L, ] <- round(total * 0.20)
  traj[, 2L, ] <- total - traj[, 1L, ]
  normalized <- normalize_pva_spec(scenario$spec, stasis = NULL)
  result <- list(
    Nend = total[years + 1L, ],
    traj = traj,
    sr_traj = matrix(0.5, nrow = years + 1L, ncol = reps),
    F_traj = matrix(0, nrow = years + 1L, ncol = reps),
    LE_traj = matrix(0, nrow = years + 1L, ncol = reps),
    ext_prob = rowMeans(total == 0),
    Nend_summary = list(
      median = as.numeric(stats::median(total[years + 1L, ])),
      lo95 = as.numeric(stats::quantile(total[years + 1L, ], 0.025, names = FALSE)),
      hi95 = as.numeric(stats::quantile(total[years + 1L, ], 0.975, names = FALSE))
    ),
    params = c(
      normalized$spec,
      list(
        years = years, reps = reps, stasis = normalized$stasis,
        seed = scenario$seed
      )
    ),
    raw = list(
      Nend = total[years + 1L, ], traj = traj,
      sr_traj = matrix(0.5, nrow = years + 1L, ncol = reps),
      F_traj = matrix(0, nrow = years + 1L, ncol = reps),
      LE_traj = matrix(0, nrow = years + 1L, ncol = reps)
    )
  )
  compact_woodhen_run(result, scenario, sample_trajectories = 3L)
}

compare_test_project <- function() {
  family <- build_woodhen_sensitivity_family("K", c(500, 150), seed = 123L)
  project <- new_woodhen_project("Compare live evidence")
  for (scenario in family$scenarios) {
    project <- add_woodhen_scenario(project, scenario)
  }
  for (index in seq_along(family$scenarios)) {
    project <- add_woodhen_run(
      project,
      compare_test_run(
        family$scenarios[[index]],
        abundance_shift = c(0, 120, -180)[[index]]
      )
    )
  }
  project
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
    "compare-family_control", "compare-open_library", "compare-open_help",
    "compare-view_controls", "compare-evidence_view",
    "compare-comparison_table", "compare-interpretation",
    "compare-caveat", "compare-save_reasoning",
    "compare-add_plot", "compare-add_table"
  )) {
    expect_match(html, paste0('id="', id, '"'), fixed = TRUE)
  }
  expect_match(html, "Build one defensible comparison", fixed = TRUE)
  expect_match(html, "Browse project runs", fixed = TRUE)
  expect_match(html, "Add evidence to your portfolio", fixed = TRUE)
  expect_match(html, "What pattern does this comparison support?", fixed = TRUE)
  expect_match(html, "What uncertainty or limitation qualifies that pattern?", fixed = TRUE)
  expect_false(grepl("retain only|expect to cite|final report", html, ignore.case = TRUE))
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
  expect_match(text, "Add current plot", fixed = TRUE)
  expect_match(text, "Change summary", fixed = TRUE)
  expect_match(text, "Evidence Studio", fixed = TRUE)
  expect_match(text, "Evidence Portfolio", fixed = TRUE)
  expect_false(grepl("Family response", text, fixed = TRUE))
})

test_that("Compare builds its active catalogue from complete live run families", {
  env <- source_compare_app()
  project <- compare_test_project()
  catalog <- env$compare_live_catalog(project)
  family_id <- unique(vapply(project$runs, `[[`, character(1), "family_id"))

  expect_identical(names(catalog), family_id)
  expect_identical(catalog[[1L]]$comparison$family_type, "sensitivity")
  expect_identical(
    vapply(catalog[[1L]]$comparison$runs, `[[`, character(1), "run_id"),
    vapply(project$runs, `[[`, character(1), "run_id")
  )
  expect_identical(nrow(catalog[[1L]]$family$evidence$summary), 3L)
  expect_identical(
    catalog[[1L]]$family$evidence$summary$final_median_abundance,
    catalog[[1L]]$comparison$table$final_median_abundance
  )
})

test_that("Compare emits direct portfolio actions with real source-run identity", {
  env <- source_compare_app()
  project <- compare_test_project()
  live <- shiny::reactiveVal(project)
  family_id <- unique(vapply(project$runs, `[[`, character(1), "family_id"))
  run_ids <- vapply(project$runs, `[[`, character(1), "run_id")
  expected_fingerprint <- project$project_fingerprint

  shiny::testServer(
    env$compare_server,
    args = list(project = shiny::reactive(live())),
    {
      session$flushReact()
      session$setInputs(family = family_id, view = "risk")
      expect_identical(active_family_id(), family_id)
      expect_true(active_family()$compatible)

      session$setInputs(add_plot = 1)
      plot_event <- portfolio_event()
      expect_identical(names(plot_event), c(
        "ok", "action", "kind", "source_family_id", "source_run_ids",
        "view_id", "title", "note", "base_project_fingerprint",
        "event_id", "message"
      ))
      expect_identical(plot_event$kind, "plot")
      expect_identical(plot_event$source_family_id, family_id)
      expect_identical(plot_event$source_run_ids, run_ids)
      expect_identical(plot_event$view_id, "risk")
      expect_identical(
        plot_event$base_project_fingerprint,
        expected_fingerprint
      )

      session$setInputs(add_table = 1)
      expect_identical(portfolio_event()$kind, "table")
      expect_identical(portfolio_event()$view_id, "comparison_table")

      session$setInputs(
        interpretation = "Lower capacity increased warning risk.",
        caveat = "The threshold is a working warning level.",
        save_reasoning = 1
      )
      note_event <- portfolio_event()
      expect_identical(note_event$kind, "observation")
      expect_identical(note_event$view_id, "comparison_note")
      expect_match(note_event$note, "Interpretation:")
      expect_match(note_event$note, "Caveat:")
    }
  )
})

test_that("Browse completed families offers an actionable Use this comparison route", {
  env <- source_compare_app()
  project <- compare_test_project()
  catalog <- env$compare_live_catalog(project)

  library <- env$compare_run_library(project, catalog)
  expect_true(nrow(library) >= 1L)
  expect_true(all(library$family_id %in% names(catalog)))

  # Browse must expose a family-level action; individual runs remain display-only.
  library_source <- paste(
    readLines(
      testthat::test_path(
        "..", "..", "inst", "shiny", "practical2", "modules",
        "mod_compare.R"
      ),
      warn = FALSE
    ),
    collapse = "\n"
  )
  expect_match(library_source, "Use this comparison", fixed = TRUE)
  expect_match(library_source, "select_family", fixed = TRUE)
  expect_match(library_source, "removeModal", fixed = TRUE)
  expect_match(
    library_source,
    "Add current plot to Evidence Portfolio",
    fixed = TRUE
  )
  expect_match(
    library_source,
    "Add comparison table to Evidence Portfolio",
    fixed = TRUE
  )
  expect_match(library_source, "Add note to Evidence Portfolio", fixed = TRUE)
  expect_false(grepl("Add this run", library_source, fixed = TRUE))
})
