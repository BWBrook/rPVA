calibrate_test_result <- function(scenario, abundance_shift = 0, seed = scenario$seed) {
  years <- as.integer(scenario$spec$years)
  reps <- as.integer(scenario$spec$reps)
  n_stage <- length(scenario$spec$n0)
  start_total <- 2 * sum(scenario$spec$n0)
  replicate_effect <- (seq_len(reps) %% 19L) - 9L
  total <- outer(0:years, replicate_effect, function(year, effect) {
    pmax(0, round(start_total + abundance_shift + 2 * year + effect))
  })
  traj <- array(0, dim = c(years + 1L, n_stage, reps))
  traj[, 1L, ] <- round(total * 0.20)
  traj[, 2L, ] <- total - traj[, 1L, ]
  normalized <- normalize_pva_spec(scenario$spec, stasis = NULL)

  list(
    Nend = as.numeric(total[years + 1L, ]),
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
      list(years = years, reps = reps, stasis = normalized$stasis, seed = seed)
    ),
    raw = list(
      Nend = as.numeric(total[years + 1L, ]), traj = traj,
      sr_traj = matrix(0.5, nrow = years + 1L, ncol = reps),
      F_traj = matrix(0, nrow = years + 1L, ncol = reps),
      LE_traj = matrix(0, nrow = years + 1L, ncol = reps)
    )
  )
}

calibrate_test_runner <- function(
    scenario,
    seed = scenario$seed,
    sample_trajectories = 100L,
    progress = NULL
) {
  if (!is.null(progress)) {
    progress(250L, as.integer(scenario$spec$reps))
    progress(as.integer(scenario$spec$reps), as.integer(scenario$spec$reps))
  }
  compact_woodhen_run(
    calibrate_test_result(scenario, seed = seed),
    scenario,
    sample_trajectories = sample_trajectories
  )
}

calibrate_app_dir <- function() {
  path <- system.file("shiny", "practical2", package = "rPVA")
  if (!nzchar(path)) path <- file.path("inst", "shiny", "practical2")
  normalizePath(path, winslash = "/", mustWork = TRUE)
}

source_calibrate_app <- function() {
  app_dir <- calibrate_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)
  env
}

test_that("reference records preserve the exact chronological scientific identities", {
  catalog <- woodhen_reference_catalog()
  expected_ids <- c(
    "01_no_mgmt", "02_pig_control", "03_captive_pig",
    "04_rodent_eradication", "05_future_baseline"
  )
  expected_labels <- c(
    "No intervention", "Pig control", "Captive breeding plus pig control",
    "Rodent eradication", "Future baseline"
  )
  records <- lapply(expected_ids, rPVA:::woodhen_reference_scenario)

  expect_identical(catalog$id, expected_ids)
  expect_identical(catalog$label, expected_labels)
  expect_identical(catalog$horizon_years, c(40L, 40L, 40L, 5L, 75L))
  expect_identical(vapply(records, `[[`, character(1), "scenario_id"), expected_ids)
  expect_identical(vapply(records, `[[`, character(1), "student_label"), expected_labels)
  expect_true(all(vapply(records, function(record) identical(record$scenario_type, "reference"), logical(1))))
  expect_identical(vapply(records, `[[`, integer(1), "seed"), rep(123L, 5L))
  expect_identical(vapply(records, function(record) as.integer(record$spec$reps), integer(1)), rep(1000L, 5L))
  expect_identical(vapply(records, function(record) as.integer(record$spec$years), integer(1)), c(40L, 40L, 40L, 5L, 75L))
  expect_true(all(vapply(seq_along(records), function(index) {
    identical(records[[index]]$spec_fingerprint,
      woodhen_spec_fingerprint(woodhen_reference_spec(expected_ids[[index]]))) &&
      identical(records[[index]]$scientific_identity_fingerprint,
        woodhen_record_scientific_fingerprint(records[[index]]))
  }, logical(1))))
  expect_identical(
    vapply(lapply(expected_ids, rPVA:::woodhen_reference_scenario), `[[`, character(1), "scientific_identity_fingerprint"),
    vapply(records, `[[`, character(1), "scientific_identity_fingerprint")
  )
})

test_that("reference validation is exact and does not weaken Act 2 preflight", {
  references <- lapply(
    c("01_no_mgmt", "02_pig_control", "03_captive_pig", "04_rodent_eradication"),
    rPVA:::woodhen_reference_scenario
  )
  expect_silent(lapply(references, rPVA:::woodhen_validate_scenario_record))
  expect_error(woodhen_preflight_spec(references[[1L]]$spec), "locked field|K")
  expect_error(woodhen_preflight_spec(references[[4L]]$spec), "locked field")

  tampered_spec <- references[[1L]]
  tampered_spec$spec$K <- tampered_spec$spec$K + 1
  tampered_spec$spec_fingerprint <- woodhen_spec_fingerprint(tampered_spec$spec)
  tampered_spec$scientific_identity_fingerprint <- woodhen_record_scientific_fingerprint(tampered_spec)
  expect_error(rPVA:::woodhen_validate_scenario_record(tampered_spec), "reference|catalog")
  tampered_id <- references[[1L]]
  tampered_id$scenario_id <- "02_pig_control"
  expect_error(rPVA:::woodhen_validate_scenario_record(tampered_id), "reference|catalog")
  tampered_catalog <- references[[1L]]
  tampered_catalog$student_label <- "A different label"
  expect_error(rPVA:::woodhen_validate_scenario_record(tampered_catalog), "reference|catalog")

  act2 <- build_woodhen_sensitivity_family("K", c(350, 250))$scenarios[[1L]]
  expect_silent(rPVA:::woodhen_validate_scenario_record(act2))
  act2$spec$K <- 10
  act2$spec_fingerprint <- woodhen_spec_fingerprint(act2$spec)
  act2$scientific_identity_fingerprint <- woodhen_record_scientific_fingerprint(act2)
  expect_error(rPVA:::woodhen_validate_scenario_record(act2), "K >= 150")
})

test_that("five reference runs insert independently and survive a typed portable round trip", {
  ids <- woodhen_reference_catalog()$id
  project <- new_woodhen_project("Historical calibration")
  runs <- vector("list", length(ids))
  for (index in seq_along(ids)) {
    action <- rPVA:::run_woodhen_reference_project(
      project, ids[[index]], runner = calibrate_test_runner, sample_trajectories = 3L
    )
    project <- action$project
    runs[[index]] <- action$run
    expect_false(action$reused)
  }
  expect_identical(vapply(project$scenarios, `[[`, character(1), "scenario_id"), ids)
  expect_identical(vapply(project$runs, `[[`, character(1), "scenario_id"), ids)
  expect_length(unique(vapply(runs, `[[`, character(1), "run_id")), 5L)
  expect_silent(validate_woodhen_project(project))
  package_path <- tempfile(fileext = ".zip")
  on.exit(unlink(package_path), add = TRUE)
  write_woodhen_project_package(project, package_path)
  restored <- read_woodhen_project_package(package_path)
  expect_identical(restored$scenarios, project$scenarios)
  expect_identical(restored$runs, project$runs)
  expect_silent(validate_woodhen_project(restored))
})

test_that("the historical comparison accepts exactly the three common 40-year cases", {
  ids <- c("01_no_mgmt", "02_pig_control", "03_captive_pig")
  runs <- lapply(rev(ids), function(id) {
    calibrate_test_runner(rPVA:::woodhen_reference_scenario(id), sample_trajectories = 2L)
  })
  comparison <- rPVA:::compare_woodhen_1980_references(runs)
  expect_s3_class(comparison, "woodhen_1980_reference_comparison")
  expect_identical(comparison$table$scenario_id, ids)
  expect_identical(comparison$table$horizon, rep(40L, 3L))
  for (wrong_id in c("04_rodent_eradication", "05_future_baseline")) {
    wrong <- runs
    wrong[[3L]] <- calibrate_test_runner(
      rPVA:::woodhen_reference_scenario(wrong_id), sample_trajectories = 2L
    )
    expect_error(rPVA:::compare_woodhen_1980_references(wrong), "exactly|01_no_mgmt")
  }
  expect_error(rPVA:::compare_woodhen_1980_references(runs[1:2]), "exactly")
})

test_that("calibration history presents observed milestones without false precision", {
  history <- rPVA:::woodhen_calibration_history()
  expect_identical(names(history), c("crisis_1980", "recovery_2019_2024", "future_2025_2100"))
  expect_identical(history$crisis_1980$reference_ids, c("01_no_mgmt", "02_pig_control", "03_captive_pig"))
  expect_identical(history$recovery_2019_2024$reference_ids, "04_rodent_eradication")
  expect_identical(history$future_2025_2100$reference_ids, "05_future_baseline")
  expect_match(history$recovery_2019_2024$observed_history, "over 1,600 birds by 2024", fixed = TRUE)
  expect_identical(history$recovery_2019_2024$observed_points$year, c(2019L, 2024L))
  expect_identical(history$recovery_2019_2024$observed_points$abundance, c(208L, 1600L))
  expect_identical(history$recovery_2019_2024$observed_points$label, c("208", ">1,600"))
  expect_false("model_state" %in% names(history$recovery_2019_2024))
  expect_match(history$recovery_2019_2024$warning, "Short-horizon warning", fixed = TRUE)
})

test_that("Calibrate display helpers avoid false precision and clipped uncertainty", {
  env <- source_calibrate_app()
  expect_identical(env$calibrate_whole_birds(171.025), "171")
  expect_identical(env$calibrate_whole_birds(1386.075), "1,386")
  limits <- env$calibrate_abundance_ylim(data.frame(
    median = c(100, 80), q025 = c(70, 50), q975 = c(125, 110)
  ))
  expect_equal(limits[[1L]], 0)
  expect_gte(limits[[2L]], 160)
  expect_gte(limits[[2L]], 125)
})

test_that("locked-anchor status requires the exact current scenario and run", {
  expected <- rPVA:::woodhen_locked_anchor_expected_identity()
  empty <- new_woodhen_project()
  scenario <- rPVA:::woodhen_reference_scenario("05_future_baseline")
  scenario_only <- add_woodhen_scenario(empty, scenario)
  other_action <- rPVA:::run_woodhen_reference_project(
    empty, "01_no_mgmt", runner = calibrate_test_runner, sample_trajectories = 2L
  )
  ready_action <- rPVA:::run_woodhen_reference_project(
    empty, "05_future_baseline", runner = calibrate_test_runner, sample_trajectories = 2L
  )
  expect_identical(rPVA:::woodhen_locked_anchor_status(NULL)$status, "missing")
  expect_identical(rPVA:::woodhen_locked_anchor_status(empty)$status, "missing")
  expect_identical(rPVA:::woodhen_locked_anchor_status(scenario_only)$status, "missing")
  expect_identical(rPVA:::woodhen_locked_anchor_status(other_action$project)$status, "missing")
  ready <- rPVA:::woodhen_locked_anchor_status(ready_action$project)
  expect_identical(ready$status, "ready")
  expect_identical(ready$expected, expected)
  expect_match(rPVA:::woodhen_locked_anchor_status(empty)$action, "Run the common future comparison", fixed = TRUE)

  wrong_seed <- ready_action$project
  wrong_seed$runs[[1L]]$seed <- 999L
  wrong_seed$runs[[1L]]$run_id <- paste0("woodhen_run_", substr(woodhen_content_fingerprint(list(
    scenario_id = wrong_seed$runs[[1L]]$scenario_id,
    scientific_identity_fingerprint = wrong_seed$runs[[1L]]$scientific_identity_fingerprint,
    seed = 999L, reps = wrong_seed$runs[[1L]]$reps
  )), 1L, 16L))
  wrong_seed$project_fingerprint <- woodhen_project_fingerprint(wrong_seed)
  expect_identical(rPVA:::woodhen_locked_anchor_status(wrong_seed)$status, "stale")
  for (field in c("horizon", "spec_fingerprint", "baseline_spec_fingerprint")) {
    tampered <- ready_action$project
    tampered$runs[[1L]][[field]] <- if (field == "horizon") 40L else paste(rep("0", 64L), collapse = "")
    tampered$project_fingerprint <- woodhen_project_fingerprint(tampered)
    expect_identical(rPVA:::woodhen_locked_anchor_status(tampered)$status, "stale")
  }
  stale_library <- ready_action$project
  stale_library$reference_library_version <- "woodhen-reference-v0"
  stale_library$project_fingerprint <- woodhen_project_fingerprint(stale_library)
  stale <- rPVA:::woodhen_locked_anchor_status(stale_library)
  expect_identical(stale$status, "stale")
  expect_match(stale$action, "Start or import a current compatible project", fixed = TRUE)
  expect_identical(stale$observed$reference_library_version, "woodhen-reference-v0")
})

test_that("reference project actions reuse exact runs without duplicates", {
  progress <- list()
  callback <- function(completed, total) {
    progress[[length(progress) + 1L]] <<- c(completed = completed, total = total)
  }
  first <- rPVA:::run_woodhen_reference_project(
    new_woodhen_project(), "05_future_baseline", progress = callback,
    runner = calibrate_test_runner, sample_trajectories = 2L
  )
  second <- rPVA:::run_woodhen_reference_project(
    first$project, "05_future_baseline",
    progress = function(...) stop("rerun should not execute"),
    runner = function(...) stop("rerun should not execute"),
    sample_trajectories = 2L
  )
  expect_identical(progress, list(c(completed = 250L, total = 1000L), c(completed = 1000L, total = 1000L)))
  expect_false(first$reused)
  expect_true(second$reused)
  expect_identical(second$project, first$project)
  expect_identical(second$run, first$run)
  expect_length(second$project$scenarios, 1L)
  expect_length(second$project$runs, 1L)
})

test_that("Calibrate module handles no project, progress, recovery, failure, and rerun", {
  env <- source_calibrate_app()
  live <- shiny::reactiveVal(NULL)
  shiny::testServer(env$calibrate_server, args = list(
    project = shiny::reactive(live()), scenario_runner = calibrate_test_runner
  ), {
    session$setInputs(run_01_no_mgmt = 1)
    session$flushReact()
    expect_false(project_update()$ok)
    expect_match(project_update()$message, "Create or resume")
    live(new_woodhen_project("Module project"))
    session$setInputs(run_01_no_mgmt = 2)
    session$flushReact()
    event <- project_update()
    expect_true(event$ok)
    expect_identical(event$reference_id, "01_no_mgmt")
    expect_false(event$reused)
    expect_identical(progress_history()[[1L]], c(completed = 250L, total = 1000L))
    expect_identical(progress_history()[[2L]], c(completed = 1000L, total = 1000L))
    live(event$candidate)
    session$setInputs(run_01_no_mgmt = 3)
    session$flushReact()
    rerun <- project_update()
    expect_true(rerun$ok)
    expect_true(rerun$reused)
    expect_identical(rerun$candidate, live())
    expect_length(rerun$candidate$runs, 1L)
  })

  partial <- rPVA:::run_woodhen_reference_project(
    new_woodhen_project(), "02_pig_control",
    runner = calibrate_test_runner, sample_trajectories = 2L
  )$project
  live <- shiny::reactiveVal(partial)
  failing_runner <- function(scenario, ...) {
    if (identical(scenario$scenario_id, "04_rodent_eradication")) stop("deliberate reference failure")
    calibrate_test_runner(scenario, ...)
  }
  shiny::testServer(env$calibrate_server, args = list(
    project = shiny::reactive(live()), scenario_runner = failing_runner
  ), {
    session$setInputs(run_04_rodent_eradication = 1)
    session$flushReact()
    failed <- project_update()
    expect_false(failed$ok)
    expect_match(failed$message, "deliberate reference failure")
    expect_identical(live(), partial)
    session$setInputs(run_03_captive_pig = 1)
    session$flushReact()
    recovered <- project_update()
    expect_true(recovered$ok)
    expect_identical(vapply(recovered$candidate$runs, `[[`, character(1), "scenario_id"),
      c("02_pig_control", "03_captive_pig"))
  })
})

test_that("Calibrate state reconciles exactly when the authoritative project changes", {
  env <- source_calibrate_app()
  project_a <- new_woodhen_project("Failed project A")
  project_b <- new_woodhen_project("Empty project B")
  live <- shiny::reactiveVal(project_a)
  failing_after_progress <- function(scenario, progress = NULL, ...) {
    progress(400L, as.integer(scenario$spec$reps))
    stop("deliberate project A failure")
  }

  shiny::testServer(env$calibrate_server, args = list(
    project = shiny::reactive(live()), scenario_runner = failing_after_progress
  ), {
    session$flushReact()
    session$setInputs(run_04_rodent_eradication = 1)
    session$flushReact()
    expect_identical(
      progress_state()[["04_rodent_eradication"]],
      c(completed = 400L, total = 1000L)
    )
    expect_match(status_state()[["04_rodent_eradication"]], "project A failure")

    live(project_b)
    session$flushReact()
    expect_true(all(vapply(
      progress_state(),
      function(value) identical(value, c(completed = 0L, total = 1000L)),
      logical(1)
    )))
    expect_identical(
      unname(status_state()),
      rep("Not run in this project.", 5L)
    )
    expect_length(progress_history(), 0L)
  })

  completed_a <- rPVA:::run_woodhen_reference_project(
    new_woodhen_project("Completed project A"),
    "05_future_baseline",
    runner = calibrate_test_runner,
    sample_trajectories = 2L
  )$project
  live <- shiny::reactiveVal(completed_a)
  shiny::testServer(env$calibrate_server, args = list(
    project = shiny::reactive(live()), scenario_runner = calibrate_test_runner
  ), {
    session$flushReact()
    expect_identical(
      progress_state()[["05_future_baseline"]],
      c(completed = 1000L, total = 1000L)
    )
    expect_match(status_state()[["05_future_baseline"]], "Saved results loaded")

    live(new_woodhen_project("Replacement project B"))
    session$flushReact()
    expect_true(all(vapply(
      progress_state(),
      function(value) identical(value, c(completed = 0L, total = 1000L)),
      logical(1)
    )))
    expect_false(any(grepl("restored|failed|complete", status_state(), ignore.case = TRUE)))
  })

  partial <- rPVA:::run_woodhen_reference_project(
    new_woodhen_project("Restored partial project"),
    "02_pig_control",
    runner = calibrate_test_runner,
    sample_trajectories = 2L
  )$project
  live <- shiny::reactiveVal(NULL)
  shiny::testServer(env$calibrate_server, args = list(
    project = shiny::reactive(live()), scenario_runner = calibrate_test_runner
  ), {
    session$flushReact()
    live(partial)
    session$flushReact()
    completed <- vapply(progress_state(), `[[`, integer(1), "completed")
    expect_identical(
      completed,
      c(
        `01_no_mgmt` = 0L,
        `02_pig_control` = 1000L,
        `03_captive_pig` = 0L,
        `04_rodent_eradication` = 0L,
        `05_future_baseline` = 0L
      )
    )
    expect_match(status_state()[["02_pig_control"]], "Saved results loaded")
    expect_true(all(status_state()[setdiff(names(status_state()), "02_pig_control")] ==
      "Not run in this project."))
  })
})

test_that("rendered progress semantics track actual completed futures", {
  env <- source_calibrate_app()
  live <- shiny::reactiveVal(new_woodhen_project("Accessible progress"))

  shiny::testServer(env$calibrate_server, args = list(
    project = shiny::reactive(live()), scenario_runner = calibrate_test_runner
  ), {
    session$flushReact()
    initial <- output$progress_01_no_mgmt$html
    expect_match(initial, 'role="progressbar"', fixed = TRUE)
    expect_match(initial, 'aria-valuemin="0"', fixed = TRUE)
    expect_match(initial, 'aria-valuemax="1000"', fixed = TRUE)
    expect_match(initial, 'aria-valuenow="0"', fixed = TRUE)
    expect_match(initial, 'aria-live="polite"', fixed = TRUE)
    expect_match(initial, "0 of 1,000 futures completed", fixed = TRUE)

    session$setInputs(run_01_no_mgmt = 1)
    session$flushReact()
    completed <- output$progress_01_no_mgmt$html
    expect_match(completed, 'aria-valuenow="1000"', fixed = TRUE)
    expect_match(completed, "1,000 of 1,000 futures completed", fixed = TRUE)

    live(new_woodhen_project("Accessible replacement"))
    session$flushReact()
    reset <- output$progress_01_no_mgmt$html
    expect_match(reset, 'aria-valuenow="0"', fixed = TRUE)
    expect_match(reset, "0 of 1,000 futures completed", fixed = TRUE)
  })
})

test_that("each Calibrate run action returns the corresponding project update", {
  env <- source_calibrate_app()
  live <- shiny::reactiveVal(new_woodhen_project("Five reference actions"))
  reference_ids <- woodhen_reference_catalog()$id

  shiny::testServer(env$calibrate_server, args = list(
    project = shiny::reactive(live()), scenario_runner = calibrate_test_runner
  ), {
    for (index in seq_along(reference_ids)) {
      input_name <- paste0("run_", reference_ids[[index]])
      do.call(session$setInputs, setNames(list(index), input_name))
      session$flushReact()
      event <- project_update()
      expect_true(event$ok)
      expect_identical(event$reference_id, reference_ids[[index]])
      live(event$candidate)
      session$flushReact()
    }
    expect_identical(
      vapply(live()$runs, `[[`, character(1), "scenario_id"),
      reference_ids
    )
  })
})

test_that("Calibrate observations persist only explicit non-empty submissions", {
  env <- source_calibrate_app()
  complete <- rPVA:::run_woodhen_reference_project(
    new_woodhen_project(), "01_no_mgmt",
    runner = calibrate_test_runner, sample_trajectories = 2L
  )$project
  live <- shiny::reactiveVal(complete)
  shiny::testServer(env$calibrate_server, args = list(
    project = shiny::reactive(live()), scenario_runner = calibrate_test_runner
  ), {
    session$setInputs(
      interpretation_01_no_mgmt = "   ", caveat_01_no_mgmt = "",
      save_notes_01_no_mgmt = 1
    )
    session$flushReact()
    expect_null(project_update())
    expect_length(live()$observations, 0L)
    session$setInputs(
      interpretation_01_no_mgmt = "The unmanaged population remained highly vulnerable.",
      caveat_01_no_mgmt = "Historical agreement does not establish causation.",
      save_notes_01_no_mgmt = 2
    )
    session$flushReact()
    event <- project_update()
    expect_true(event$ok)
    expect_identical(vapply(event$candidate$observations, `[[`, character(1), "note"), c(
      "The unmanaged population remained highly vulnerable.",
      "Historical agreement does not establish causation."
    ))
    expect_true(all(vapply(event$candidate$observations, function(observation) {
      identical(observation$run_ids, complete$runs[[1L]]$run_id)
    }, logical(1))))
  })
})

test_that("Calibrate UI is chronological, accessible, responsive, and student-facing", {
  env <- source_calibrate_app()
  html <- paste(as.character(env$calibrate_ui("calibrate")), collapse = "\n")
  app_dir <- calibrate_app_dir()
  help <- paste(readLines(file.path(app_dir, "content", "help-calibrate.md"), warn = FALSE), collapse = "\n")
  module_source <- paste(readLines(file.path(app_dir, "modules", "mod_calibrate.R"), warn = FALSE), collapse = "\n")
  css <- paste(readLines(file.path(app_dir, "www", "styles.css"), warn = FALSE), collapse = "\n")
  visible_text <- gsub("<[^>]+>", " ", html)
  headings <- c(
    "1980 crisis and 40-year management alternatives",
    "2019-2024 rodent-eradication recovery check",
    "2025-2100 common future comparison"
  )
  positions <- vapply(headings, function(heading) regexpr(heading, html, fixed = TRUE)[[1L]], integer(1))
  expect_true(all(positions > 0L) && identical(order(positions), 1:3))
  for (id in woodhen_reference_catalog()$id) {
    expect_match(html, paste0('id="calibrate-run_', id, '"'), fixed = TRUE)
    expect_match(html, paste0('id="calibrate-help_', id, '"'), fixed = TRUE)
    expect_match(html, paste0('id="calibrate-interpretation_', id, '"'), fixed = TRUE)
    expect_match(html, paste0('id="calibrate-caveat_', id, '"'), fixed = TRUE)
    expect_match(html, paste0('id="calibrate-save_notes_', id, '"'), fixed = TRUE)
  }
  expect_match(html, 'aria-live="polite"', fixed = TRUE)
  expect_match(html, 'id="calibrate-progress_01_no_mgmt"', fixed = TRUE)
  expect_match(html, "Short-horizon warning", fixed = TRUE)
  expect_match(html, "over 1,600 birds by 2024", fixed = TRUE)
  expect_match(html, 'id="calibrate-evidence_01_no_mgmt"', fixed = TRUE)
  expect_match(module_source, 'paste0("timing_", reference_id)', fixed = TRUE)
  expect_match(module_source, 'paste0("summary_", reference_id)', fixed = TRUE)
  expect_match(module_source, 'paste0("intervention_", reference_id)', fixed = TRUE)
  expect_false(grepl("supplied 2024 model state|1,654 birds|330 breeding pairs", visible_text))
  expect_false(grepl("seed 123|immutable|01_no_mgmt|02_pig_control|03_captive_pig", visible_text))
  expect_false(grepl("canonical", paste(html, help), ignore.case = TRUE))
  expect_match(help, "supports, but does not prove", fixed = TRUE)
  expect_match(help, "exploratory future inference", fixed = TRUE)
  expect_match(help, "must not be ranked", fixed = TRUE)
  expect_match(css, ".calibration-period", fixed = TRUE)
  expect_match(css, ".reference-case-grid", fixed = TRUE)
  expect_match(css, ".reference-progress", fixed = TRUE)
  expect_match(css, ".reference-progress-track", fixed = TRUE)
  expect_match(css, "minmax(300px, 1fr)", fixed = TRUE)
  expect_false(grepl("linear-gradient|radial-gradient", css))
})
