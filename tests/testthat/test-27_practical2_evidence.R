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

test_that("table preview resolves source runs and falls back to explicit metadata", {
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
    "evidence-export_control"
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
  expect_false(grepl("evidence-dossier.docx", html, fixed = TRUE))
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

test_that("evidence dossier control is disabled until a selection exists", {
  env <- source_evidence_module()
  live <- shiny::reactiveVal(evidence_portfolio_fixture())

  shiny::testServer(
    env$evidence_server,
    args = list(project = shiny::reactive(live())),
    {
      session$flushReact()
      empty_html <- paste(as.character(output$export_control), collapse = "\n")
      expect_match(empty_html, 'id="proxy1-export_files"', fixed = TRUE)
      expect_match(empty_html, 'aria-disabled="true', fixed = TRUE)
      expect_match(empty_html, "Select at least one", fixed = TRUE)

      session$setInputs(include_ev_note = TRUE)
      enabled_html <- paste(as.character(output$export_control), collapse = "\n")
      expect_match(enabled_html, 'id="proxy1-export_files"', fixed = TRUE)
      expect_false(grepl('disabled="disabled"', enabled_html, fixed = TRUE))
      expect_match(enabled_html, "evidence-dossier.docx", fixed = TRUE)
      expect_match(enabled_html, "source material for", fixed = TRUE)
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

test_that("evidence export slugs are safe, bounded, and deterministic", {
  env <- source_evidence_module()
  expect_true(exists("evidence_export_slug", envir = env))
  if (!exists("evidence_export_slug", envir = env)) return()

  expect_identical(
    env$evidence_export_slug("Rat return / <stress> #1", max_chars = 20L),
    "Rat_return_stress_1"
  )
  expect_identical(env$evidence_export_slug("", fallback = "item"), "item")
  expect_false(grepl("[^A-Za-z0-9_.-]", env$evidence_export_slug("x/y")))
  expect_lte(nchar(env$evidence_export_slug(strrep("x", 200L), max_chars = 12L)), 12L)
})

test_that("table export neutralises spreadsheet formula prefixes only in text cells", {
  env <- source_evidence_module()
  expect_true(exists("evidence_neutralise_csv_cell", envir = env))
  if (!exists("evidence_neutralise_csv_cell", envir = env)) return()

  expect_identical(env$evidence_neutralise_csv_cell("=SUM(A1)"), "'=SUM(A1)")
  expect_identical(env$evidence_neutralise_csv_cell("+student note"), "'+student note")
  expect_identical(env$evidence_neutralise_csv_cell("ordinary text"), "ordinary text")
  expect_identical(env$evidence_neutralise_csv_cell(12.5), 12.5)
  expect_identical(env$evidence_neutralise_csv_cell(-2), -2)
})

test_that("evidence export selection validates empty, duplicate, unknown, and over-limit IDs", {
  env <- source_evidence_module()
  expect_true(exists("evidence_export_items", envir = env))
  if (!exists("evidence_export_items", envir = env)) return()
  project <- evidence_portfolio_fixture()

  expect_error(env$evidence_export_items(project, character()), "select")
  expect_error(env$evidence_export_items(project, c("ev_plot", "ev_plot")), "unique|duplicate")
  expect_error(env$evidence_export_items(project, "missing"), "unknown")
  many <- paste0("ev_", seq_len(101L))
  project$evidence_items <- lapply(many, function(id) {
    item <- project$evidence_items[[1L]]
    item$evidence_id <- id
    item
  })
  expect_error(env$evidence_export_items(project, many), "maximum|limit")
})

test_that("evidence export preserves selected order and writes the exact bundle contract", {
  env <- source_evidence_module()
  expect_true(exists("write_evidence_dossier_bundle", envir = env))
  if (!exists("write_evidence_dossier_bundle", envir = env)) return()
  skip_if_not_installed("ggplot2")
  project <- evidence_portfolio_fixture()
  env$evidence_preview_plot <- function(item, project) {
    ggplot2::ggplot(data.frame(x = 1:3, y = 3:1), ggplot2::aes(x, y)) +
      ggplot2::geom_line()
  }
  env$evidence_preview_table <- function(item, project) {
    data.frame(
      Scenario = c("A", "B"),
      Note = c("=unsafe", "+plus"),
      Prefix = c("-minus", "@at"),
      More = c("\ttab", "\rcr"),
      Value = c(1, 2),
      stringsAsFactors = FALSE
    )
  }
  zip_path <- tempfile(fileext = ".zip")
  on.exit(unlink(zip_path), add = TRUE)

  env$write_evidence_dossier_bundle(
    project,
    c("ev_note", "ev_plot", "ev_table"),
    zip_path,
    generated_at = as.POSIXct("2026-07-26 00:00:00", tz = "UTC")
  )
  expect_true(file.exists(zip_path))
  members <- unzip(zip_path, list = TRUE)$Name
  expect_identical(
    members,
    c("evidence-dossier.docx", "figures/002-Risk_through_time.png", "tables/003-Threat_and_intervention_comparison.csv")
  )
  archive_check <- system2("unzip", c("-t", shQuote(zip_path)), stdout = TRUE, stderr = TRUE)
  expect_match(paste(archive_check, collapse = "\n"), "No errors detected", fixed = TRUE)
  extracted_dir <- tempfile("evidence-docx-")
  dir.create(extracted_dir)
  unzip(zip_path, files = "evidence-dossier.docx", exdir = extracted_dir)
  docx_path <- file.path(extracted_dir, "evidence-dossier.docx")
  expect_identical(utils::unzip(docx_path, list = TRUE)$Name[1L], "[Content_Types].xml")
  text_dump <- system2("pandoc", c(shQuote(docx_path), "-t", "plain"), stdout = TRUE)
  text_dump <- paste(text_dump, collapse = "\n")
  expect_match(text_dump, "My comparison note", fixed = TRUE)
  expect_match(text_dump, "managed future retained", fixed = TRUE)
  expect_lt(
    regexpr("My comparison note", text_dump, fixed = TRUE),
    regexpr("Risk through time", text_dump, fixed = TRUE)
  )
  expect_lt(
    regexpr("Risk through time", text_dump, fixed = TRUE),
    regexpr("Threat and intervention comparison", text_dump, fixed = TRUE)
  )
  docx_check <- system2("unzip", c("-t", shQuote(docx_path)), stdout = TRUE, stderr = TRUE)
  expect_match(paste(docx_check, collapse = "\n"), "No errors detected", fixed = TRUE)
  docx_members <- utils::unzip(docx_path, list = TRUE)$Name
  expect_true(any(grepl("^word/media/", docx_members)))
  rel_dir <- tempfile("docx-rels-")
  dir.create(rel_dir)
  unzip(docx_path, files = "word/_rels/document.xml.rels", exdir = rel_dir)
  rel_text <- paste(readLines(
    file.path(rel_dir, "word", "_rels", "document.xml.rels"), warn = FALSE
  ), collapse = "\n")
  expect_match(rel_text, "relationships/image", fixed = TRUE)
  expect_match(rel_text, "Target=\"media/", fixed = TRUE)

  csv_dir <- tempfile("evidence-csv-")
  dir.create(csv_dir)
  unzip(zip_path, files = "tables/003-Threat_and_intervention_comparison.csv", exdir = csv_dir)
  exported <- utils::read.csv(
    file.path(csv_dir, "tables", "003-Threat_and_intervention_comparison.csv"),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  expect_identical(exported$Note, c("'=unsafe", "'+plus"))
  expect_identical(exported$Prefix, c("'-minus", "'@at"))
  expect_identical(exported$More, c("'\ttab", "'\ncr"))
  raw_csv <- rawToChar(readBin(
    file.path(csv_dir, "tables", "003-Threat_and_intervention_comparison.csv"),
    "raw", n = file.info(file.path(
      csv_dir, "tables", "003-Threat_and_intervention_comparison.csv"
    ))$size
  ))
  expect_match(raw_csv, "'\rcr", fixed = TRUE)
  expect_equal(exported$Value, c(1, 2))

  png_dir <- tempfile("evidence-png-")
  dir.create(png_dir)
  unzip(zip_path, files = "figures/002-Risk_through_time.png", exdir = png_dir)
  png_path <- file.path(png_dir, "figures", "002-Risk_through_time.png")
  expect_gt(file.info(png_path)$size, 1000)
  png_bytes <- readBin(png_path, "raw", n = 32L)
  png_width <- sum(as.integer(png_bytes[17:20]) * 256^(3:0))
  expect_identical(png_width, 1800)
})

test_that("failed evidence reconstruction is explicit in dossier HTML", {
  env <- source_evidence_module()
  project <- evidence_portfolio_fixture()
  project$runs <- list()
  items <- project$evidence_items[1:2]
  html <- env$evidence_dossier_html(items, project, assets = list(list(), list()))
  expect_match(html, "Evidence unavailable", fixed = TRUE)
  expect_match(html, "could not be reconstructed", fixed = TRUE)
  expect_false(grepl("example|representative|synthetic", html, ignore.case = TRUE))
})

test_that("table export exposes explicit reconstruction status and omits fallback metadata", {
  env <- source_evidence_module()
  project <- evidence_portfolio_fixture()
  expect_true(exists("evidence_reconstruct_table", envir = env))
  if (!exists("evidence_reconstruct_table", envir = env)) return()

  zero_project <- project
  zero_project$evidence_items[[2L]]$source_run_ids <- character()
  zero <- env$evidence_reconstruct_table(zero_project$evidence_items[[2L]], zero_project)
  expect_false(zero$ok)
  expect_match(zero$reason, "source runs", ignore.case = TRUE)

  partial <- project
  partial$evidence_items[[2L]]$source_run_ids <- c("run_base", "missing")
  partial_result <- env$evidence_reconstruct_table(partial$evidence_items[[2L]], partial)
  expect_false(partial_result$ok)
  expect_match(partial_result$reason, "partial|unknown|source", ignore.case = TRUE)

  error_result <- env$evidence_reconstruct_table(project$evidence_items[[2L]], project)
  expect_false(error_result$ok)
  expect_null(error_result$table)
})

test_that("failed PNG opening preserves a pre-existing graphics device", {
  env <- source_evidence_module()
  project <- evidence_portfolio_fixture()
  env$evidence_preview_plot <- function(item, project) {
    ggplot2::ggplot(data.frame(x = 1:2, y = 2:1), ggplot2::aes(x, y)) +
      ggplot2::geom_line()
  }
  pdf_path <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf_path)
  original <- grDevices::dev.cur()
  on.exit({
    if (grDevices::dev.cur() != 1L) grDevices::dev.off()
    unlink(pdf_path)
  }, add = TRUE)
  bad_path <- tempfile()
  dir.create(bad_path)
  expect_false(env$evidence_write_plot_png(
    project$evidence_items[[1L]], project, file.path(bad_path, "nested", "plot.png")
  ))
  expect_equal(unname(grDevices::dev.cur()), unname(original))
})

test_that("hostile evidence text remains inert and image attributes stay structured", {
  env <- source_evidence_module()
  project <- evidence_portfolio_fixture()
  project$title <- 'Project "<unsafe> & line\nbreak'
  project$evidence_items[[1L]]$title <- 'Plot "quoted" <b>bold</b> & next\nline'
  project$evidence_items[[3L]]$title <- 'Table "quoted" <i>markup</i> & next\nline'
  project$observations[[1L]]$note <- 'Note "quoted" <script>alert(1)</script> & next\nline'
  html <- env$evidence_dossier_html(
    project$evidence_items[c(1L, 3L)], project,
    assets = list(list(png = 'figures/001-safe.png'), list(csv = 'tables/002-safe.csv'))
  )
  expect_match(html, '&lt;script&gt;alert(1)&lt;/script&gt;', fixed = TRUE)
  expect_false(grepl('<script>', html, fixed = TRUE))
  expect_match(html, 'src="figures/001-safe.png"', fixed = TRUE)
  expect_false(grepl('src="[^"]*&quot;', html))
  expect_match(html, 'Plot &quot;quoted&quot; &lt;b&gt;bold&lt;/b&gt;', fixed = TRUE)
})
