source_evidence_module <- function() {
  env <- new.env(parent = globalenv())
  sys.source(
    testthat::test_path(
      "..", "..", "inst", "shiny", "practical2", "modules", "mod_evidence.R"
    ),
    envir = env
  )
  env
}

evidence_portfolio_fixture <- function() {
  list(
    project_fingerprint = paste(rep("a", 64), collapse = ""),
    evidence_ids = c("ev_plot", "ev_note", "ev_table"),
    evidence_items = list(
      list(
        evidence_schema_version = "woodhen-evidence-item-v1",
        evidence_id = "ev_plot",
        kind = "plot",
        source_family_id = "family_future",
        source_run_ids = c("run_base", "run_threat", "run_action"),
        view_id = "risk",
        title = "Risk through time",
        observation_id = NULL,
        created_at = "2026-07-25T01:00:00Z",
        modified_at = "2026-07-25T01:00:00Z"
      ),
      list(
        evidence_schema_version = "woodhen-evidence-item-v1",
        evidence_id = "ev_table",
        kind = "table",
        source_family_id = "family_future",
        source_run_ids = c("run_base", "run_threat", "run_action"),
        view_id = "comparison_table",
        title = "Threat and intervention comparison",
        observation_id = NULL,
        created_at = "2026-07-25T01:01:00Z",
        modified_at = "2026-07-25T01:01:00Z"
      ),
      list(
        evidence_schema_version = "woodhen-evidence-item-v1",
        evidence_id = "ev_note",
        kind = "observation",
        source_family_id = "family_future",
        source_run_ids = c("run_base", "run_threat", "run_action"),
        view_id = "comparison_note",
        title = "My comparison note",
        observation_id = "observation_1",
        created_at = "2026-07-25T01:02:00Z",
        modified_at = "2026-07-25T01:02:00Z"
      )
    ),
    runs = lapply(
      list(
        c("run_base", "No-change future", "locked_baseline"),
        c("run_threat", "Rat-return stress test", "threat"),
        c("run_action", "Renewed rat control", "intervention")
      ),
      function(value) list(
        run_id = value[[1L]],
        student_label = value[[2L]],
        scenario_type = value[[3L]],
        family_id = "family_future",
        horizon = 75L,
        reps = 1000L
      )
    ),
    observations = list(list(
      observation_id = "observation_1",
      title = "My comparison note",
      note = paste(
        "The managed future retained more birds than the threatened future.",
        "The severity of a future rat return remains uncertain."
      ),
      run_ids = c("run_base", "run_threat", "run_action")
    ))
  )
}

evidence_add_from_project_fixture <- function() {
  project <- evidence_portfolio_fixture()
  reference_runs <- lapply(
    list(
      c("run_ref_no_action", "01_no_mgmt", "No intervention"),
      c("run_ref_pig", "02_pig_control", "Pig control"),
      c("run_ref_captive", "03_captive_pig", "Captive breeding plus pig control"),
      c("run_ref_recovery", "04_rodent_eradication", "Rodent eradication")
    ),
    function(value) list(
      run_id = value[[1L]],
      scenario_id = value[[2L]],
      student_label = value[[3L]],
      scenario_type = "reference",
      family_id = if (value[[2L]] %in% c(
        "01_no_mgmt", "02_pig_control", "03_captive_pig"
      )) {
        "reference_1980_management"
      } else {
        "reference_recovery"
      },
      horizon = if (identical(value[[2L]], "04_rodent_eradication")) 5L else 40L,
      reps = 1000L
    )
  )
  project$runs <- c(project$runs, reference_runs)
  project$observations <- c(project$observations, list(
    list(
      observation_id = "observation_calibrate",
      title = "Rodent eradication interpretation",
      note = "The short recovery check is broadly consistent with survey evidence.",
      run_ids = "run_ref_recovery"
    ),
    list(
      observation_id = "observation_investigate",
      title = "Future advice result observation",
      note = "Renewed control retained more birds than the threatened future.",
      run_ids = c("run_base", "run_threat", "run_action")
    )
  ))
  project
}

test_that("Add from project discovers unwrapped observations and reference results", {
  env <- source_evidence_module()
  expect_true(
    exists("evidence_project_source_candidates", envir = env),
    info = "Evidence Studio needs a source-discovery boundary."
  )
  if (!exists("evidence_project_source_candidates", envir = env)) return()

  candidates <- env$evidence_project_source_candidates(
    evidence_add_from_project_fixture()
  )
  types <- vapply(candidates, `[[`, character(1), "source_type")

  observations <- candidates[types == "observation"]
  expect_identical(
    sort(vapply(observations, `[[`, character(1), "observation_id")),
    c("observation_calibrate", "observation_investigate")
  )
  expect_false("observation_1" %in% vapply(
    observations, `[[`, character(1), "observation_id"
  ))
  for (candidate in observations) {
    expect_identical(length(candidate$requests), 1L)
    expect_named(
      candidate$requests[[1L]],
      c("source_run_ids", "observation_id", "view_id", "title")
    )
    expect_identical(candidate$requests[[1L]]$view_id, "saved_observation")
  }

  result_sets <- candidates[types == "reference_result_set"]
  expect_length(result_sets, 4L)
  expect_true(all(vapply(result_sets, function(candidate) {
    identical(
      vapply(candidate$requests, `[[`, character(1), "view_id"),
      c(
        "calibration_trajectory", "calibration_risk",
        "calibration_timing", "calibration_summary"
      )
    )
  }, logical(1))))

  comparisons <- candidates[types == "reference_comparison"]
  expect_length(comparisons, 1L)
  expect_identical(
    comparisons[[1L]]$requests[[1L]]$source_run_ids,
    c("run_ref_no_action", "run_ref_pig", "run_ref_captive")
  )
  expect_identical(
    comparisons[[1L]]$requests[[1L]]$view_id,
    "calibration_comparison_table"
  )
})

test_that("Add from project labels describe saved content without raw IDs", {
  env <- source_evidence_module()
  expect_true(exists("evidence_project_source_candidates", envir = env))
  if (!exists("evidence_project_source_candidates", envir = env)) return()

  candidates <- env$evidence_project_source_candidates(
    evidence_add_from_project_fixture()
  )
  labels <- vapply(candidates, `[[`, character(1), "title")

  expect_true(all(nzchar(labels)))
  expect_false(any(grepl(
    "run_|observation_|reference_|family_|01_|02_|03_|04_",
    labels
  )))
  expect_identical(
    env$evidence_view_label("calibration_trajectory"),
    "Population trajectory"
  )
  expect_identical(
    env$evidence_view_label("calibration_risk"),
    "Extinction and warning risk"
  )
  expect_identical(
    env$evidence_view_label("calibration_timing"),
    "Extinction timing"
  )
  expect_identical(
    env$evidence_view_label("calibration_summary"),
    "Result summary"
  )
  expect_identical(
    env$evidence_view_label("calibration_comparison_table"),
    "Compatible 1980 comparison"
  )
  expect_identical(
    env$evidence_view_label("saved_observation"),
    "Saved observation"
  )
})

test_that("Add from project events carry references rather than copied evidence", {
  env <- source_evidence_module()
  expect_true(exists("evidence_add_from_project_event", envir = env))
  if (!exists("evidence_add_from_project_event", envir = env)) return()

  request <- list(
    source_run_ids = "run_ref_recovery",
    observation_id = "observation_calibrate",
    view_id = "saved_observation",
    title = "Rodent eradication interpretation"
  )
  fingerprint <- paste(rep("c", 64), collapse = "")
  event <- env$evidence_add_from_project_event(
    requests = list(request),
    project_fingerprint = fingerprint,
    event_id = 7L
  )

  expect_named(
    event,
    c(
      "action", "requests", "base_project_fingerprint",
      "event_id", "message"
    )
  )
  expect_identical(event$action, "add_from_project")
  expect_identical(event$requests, list(request))
  expect_false(any(c("note", "source_family_id", "kind") %in% names(
    event$requests[[1L]]
  )))
  expect_identical(event$base_project_fingerprint, fingerprint)
  expect_identical(event$event_id, 7L)
})

test_that("portfolio items follow persisted project order without judgement", {
  env <- source_evidence_module()
  project <- evidence_portfolio_fixture()

  items <- env$evidence_project_items(project)

  expect_identical(
    vapply(items, `[[`, character(1), "evidence_id"),
    c("ev_plot", "ev_note", "ev_table")
  )
  expect_identical(
    vapply(items, `[[`, character(1), "kind"),
    c("plot", "observation", "table")
  )
  expect_length(env$evidence_project_items(NULL), 0L)
  expect_length(
    env$evidence_project_items(list(
      project_fingerprint = project$project_fingerprint,
      evidence_ids = character(),
      evidence_items = list()
    )),
    0L
  )
  expect_false(exists("evidence_selection_assessment", envir = env))
  expect_false(exists("evidence_probe_catalog", envir = env))
})

test_that("portfolio filters retain real project records", {
  env <- source_evidence_module()
  items <- env$evidence_project_items(evidence_portfolio_fixture())

  plots <- env$evidence_filter_items(items, "all", "plot")
  family <- env$evidence_filter_items(items, "family_future", "all")
  absent <- env$evidence_filter_items(items, "other_family", "all")

  expect_identical(vapply(plots, `[[`, character(1), "evidence_id"), "ev_plot")
  expect_length(family, 3L)
  expect_length(absent, 0L)
})

test_that("portfolio labels describe evidence rather than internal identifiers", {
  env <- source_evidence_module()
  project <- evidence_portfolio_fixture()
  item <- project$evidence_items[[1L]]

  expect_identical(
    env$evidence_view_label("risk"),
    "Warning risk through time"
  )
  expect_identical(
    env$evidence_view_label("comparison_table"),
    "Comparison table"
  )
  expect_identical(
    env$evidence_family_label(item, project),
    "Rat-return stress test and management"
  )
  expect_false(grepl(
    "family_future",
    env$evidence_family_label(item, project),
    fixed = TRUE
  ))
  expect_match(
    env$evidence_item_source_label(item, project),
    "^Common future /",
    fixed = FALSE
  )
  expect_identical(env$evidence_count_noun(1L, "plot", "plots"), "plot")
  expect_identical(env$evidence_count_noun(2L, "plot", "plots"), "plots")
})

test_that("every saved comparison plot view has a rendering route", {
  env <- source_evidence_module()
  env$compare_live_evidence <- function(comparison) {
    list(response = data.frame())
  }
  plot_stub <- function(view) {
    function(...) structure(list(view = view), class = "ggplot")
  }
  env$compare_population_plot <- plot_stub("population")
  env$compare_risk_plot <- plot_stub("risk")
  env$compare_final_plot <- plot_stub("final")
  env$compare_passage_plot <- plot_stub("passage")
  env$investigate_sensitivity_probe_plot <- plot_stub("response")
  env$compare_management_response_plot <- plot_stub("response")

  sensitivity <- list(family_type = "sensitivity")
  prospective <- list(family_type = "prospective")
  for (view in c("population", "risk", "final", "passage", "response")) {
    plot <- env$evidence_plot_from_comparison(view, sensitivity)
    expect_s3_class(plot, "ggplot")
    expect_identical(plot$view, view)
  }
  expect_identical(
    env$evidence_plot_from_comparison("response", prospective)$view,
    "response"
  )
  expect_null(env$evidence_plot_from_comparison("unknown", sensitivity))
})

test_that("only linked project observations produce student-authored text", {
  env <- source_evidence_module()
  project <- evidence_portfolio_fixture()
  note <- env$evidence_observation_for_item(
    project$evidence_items[[3L]],
    project
  )
  missing <- project$evidence_items[[3L]]
  missing$observation_id <- "missing_observation"

  expect_match(note$note, "managed future", fixed = TRUE)
  expect_null(env$evidence_observation_for_item(missing, project))

  module_text <- paste(readLines(
    testthat::test_path(
      "..", "..", "inst", "shiny", "practical2", "modules", "mod_evidence.R"
    ),
    warn = FALSE
  ), collapse = "\n")
  expect_false(grepl(
    "Lower breeding-territory capacity produced|renewed control recovered",
    module_text,
    ignore.case = TRUE
  ))
})

test_that("table preview resolves source runs and falls back to honest metadata", {
  env <- source_evidence_module()
  project <- evidence_portfolio_fixture()
  item <- project$evidence_items[[2L]]

  preview <- env$evidence_preview_table(item, project)

  expect_identical(
    names(preview),
    c("Scenario", "Role", "Horizon", "Futures")
  )
  expect_identical(
    preview$Scenario,
    c("No-change future", "Rat-return stress test", "Renewed rat control")
  )
  expect_identical(
    preview$Role,
    c("No-change reference", "Threatened future", "Managed threatened future")
  )
  expect_false(any(grepl("example|representative", unlist(preview), ignore.case = TRUE)))
})

test_that("Evidence Portfolio UI separates library from export selection", {
  env <- source_evidence_module()
  html <- paste(as.character(env$evidence_ui("evidence")), collapse = "\n")

  for (id in c(
    "evidence-open_help",
    "evidence-source_filter",
    "evidence-type_filter",
    "evidence-project_sources",
    "evidence-portfolio_summary",
    "evidence-portfolio_library",
    "evidence-select_all_export",
    "evidence-clear_export",
    "evidence-export_order",
    "evidence-export_preview",
    "evidence-export_files"
  )) {
    expect_match(html, paste0('id="', id, '"'), fixed = TRUE)
  }
  expect_match(html, "Your evidence portfolio", fixed = TRUE)
  expect_match(html, "Add from project", fixed = TRUE)
  expect_match(html, "Include in this export", fixed = TRUE)
  expect_match(
    html,
    "Items not included in this export remain in your project portfolio",
    fixed = TRUE
  )
  expect_match(html, "connected in the next output gate", fixed = TRUE)
  expect_match(html, 'aria-disabled="true"', fixed = TRUE)
  expect_false(grepl(
    "sparse|focused|excessive|report-ready|dossier preview",
    html,
    ignore.case = TRUE
  ))
})

test_that("export selection is session-local and independent of portfolio order", {
  env <- source_evidence_module()
  live <- shiny::reactiveVal(evidence_portfolio_fixture())

  shiny::testServer(
    env$evidence_server,
    args = list(project = shiny::reactive(live())),
    {
      session$flushReact()
      expect_identical(portfolio_ids(), c("ev_plot", "ev_note", "ev_table"))
      expect_identical(export_ids(), character())
      library_html <- paste(as.character(output$portfolio_library), collapse = "\n")
      expect_match(library_html, "Warning risk through time", fixed = TRUE)
      expect_false(grepl("family_future|View: risk", library_html))
      summary_html <- paste(as.character(output$portfolio_summary), collapse = "\n")
      expect_false(grepl("> plots|> tables|> notes", summary_html))

      session$setInputs(include_ev_note = TRUE)
      expect_identical(export_ids(), "ev_note")
      expect_identical(portfolio_ids(), c("ev_plot", "ev_note", "ev_table"))

      session$setInputs(select_all_export = 1)
      expect_identical(export_ids(), c("ev_plot", "ev_note", "ev_table"))
      export_html <- paste(as.character(output$export_order), collapse = "\n")
      expect_match(
        export_html,
        "inspect_export_ev_plot",
        fixed = TRUE
      )
      expect_false(grepl(
        'id="proxy1-inspect_ev_plot"',
        export_html,
        fixed = TRUE
      ))

      session$setInputs(export_up_ev_table = 1)
      expect_identical(export_ids(), c("ev_plot", "ev_table", "ev_note"))
      expect_identical(portfolio_ids(), c("ev_plot", "ev_note", "ev_table"))

      session$setInputs(clear_export = 1)
      expect_identical(export_ids(), character())
      expect_identical(portfolio_ids(), c("ev_plot", "ev_note", "ev_table"))
    }
  )
})

test_that("portfolio remove and reorder actions emit project-neutral events", {
  env <- source_evidence_module()
  project <- evidence_portfolio_fixture()
  fingerprint <- project$project_fingerprint
  live <- shiny::reactiveVal(project)

  shiny::testServer(
    env$evidence_server,
    args = list(project = shiny::reactive(live())),
    {
      session$setInputs(remove_ev_note = 1)
      remove <- portfolio_event()
      expect_identical(
        names(remove),
        c(
          "action", "evidence_id", "base_project_fingerprint",
          "event_id", "message"
        )
      )
      expect_identical(remove$action, "remove")
      expect_identical(remove$evidence_id, "ev_note")
      expect_identical(
        remove$base_project_fingerprint,
        fingerprint
      )
      expect_identical(remove$event_id, 1L)

      session$setInputs(portfolio_down_ev_plot = 1)
      reorder <- portfolio_event()
      expect_identical(
        names(reorder),
        c(
          "action", "evidence_ids", "base_project_fingerprint",
          "event_id", "message"
        )
      )
      expect_identical(reorder$action, "reorder")
      expect_identical(
        reorder$evidence_ids,
        c("ev_note", "ev_plot", "ev_table")
      )
      expect_identical(reorder$event_id, 2L)
    }
  )
})

test_that("project refresh does not duplicate portfolio action observers", {
  env <- source_evidence_module()
  project <- evidence_portfolio_fixture()
  live <- shiny::reactiveVal(project)

  shiny::testServer(
    env$evidence_server,
    args = list(project = shiny::reactive(live())),
    {
      session$flushReact()
      session$setInputs(remove_ev_note = 1)
      expect_identical(portfolio_event()$event_id, 1L)

      refreshed <- live()
      refreshed$project_fingerprint <- paste(rep("b", 64), collapse = "")
      live(refreshed)
      session$flushReact()

      session$setInputs(remove_ev_table = 1)
      expect_identical(portfolio_event()$event_id, 2L)
      expect_identical(
        portfolio_event()$base_project_fingerprint,
        refreshed$project_fingerprint
      )
    }
  )
})

test_that("help describes portfolio operations without report-quality advice", {
  text <- paste(readLines(
    file.path(
      testthat::test_path("..", ".."),
      "inst", "shiny", "practical2", "content", "help-evidence.md"
    ),
    warn = FALSE
  ), collapse = "\n")

  expect_match(text, "working portfolio", ignore.case = TRUE)
  expect_match(text, "Include in this export", fixed = TRUE)
  expect_match(text, "remain in your project", ignore.case = TRUE)
  expect_match(text, "student-authored", ignore.case = TRUE)
  expect_false(grepl(
    "sparse|focused|excessive|too many|too few|report quality",
    text,
    ignore.case = TRUE
  ))
})
