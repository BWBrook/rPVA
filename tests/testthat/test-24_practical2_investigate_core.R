investigate_test_result <- function(scenario,
                                    abundance_shift = NULL,
                                    seed = scenario$seed) {
  years <- as.integer(scenario$spec$years)
  reps <- as.integer(scenario$spec$reps)
  if (is.null(abundance_shift)) {
    abundance_shift <- switch(
      scenario$scenario_type,
      locked_baseline = 0,
      threat = -900,
      intervention = -350,
      sensitivity = -100,
      0
    )
  }
  effects <- (seq_len(reps) %% 17L) - 8L
  totals <- outer(0:years, effects, function(year, effect) {
    pmax(0, round(640 + abundance_shift + year + effect))
  })
  traj <- array(0, dim = c(years + 1L, length(scenario$spec$n0), reps))
  traj[, 1L, ] <- round(totals * 0.20)
  traj[, 2L, ] <- totals - traj[, 1L, ]
  normalized <- normalize_pva_spec(scenario$spec, stasis = NULL)
  list(
    Nend = as.numeric(totals[years + 1L, ]),
    traj = traj,
    sr_traj = matrix(0.5, nrow = years + 1L, ncol = reps),
    F_traj = matrix(0, nrow = years + 1L, ncol = reps),
    LE_traj = matrix(0, nrow = years + 1L, ncol = reps),
    ext_prob = rowMeans(totals == 0),
    Nend_summary = list(
      median = as.numeric(stats::median(totals[years + 1L, ])),
      lo95 = as.numeric(stats::quantile(totals[years + 1L, ], 0.025, names = FALSE)),
      hi95 = as.numeric(stats::quantile(totals[years + 1L, ], 0.975, names = FALSE))
    ),
    params = c(
      normalized$spec,
      list(years = years, reps = reps, stasis = normalized$stasis, seed = seed)
    ),
    raw = list(
      Nend = as.numeric(totals[years + 1L, ]), traj = traj,
      sr_traj = matrix(0.5, nrow = years + 1L, ncol = reps),
      F_traj = matrix(0, nrow = years + 1L, ncol = reps),
      LE_traj = matrix(0, nrow = years + 1L, ncol = reps)
    )
  )
}

investigate_test_runner <- function(scenario,
                                    seed = scenario$seed,
                                    sample_trajectories = 3L,
                                    progress = NULL) {
  if (!is.null(progress)) {
    progress(250L, as.integer(scenario$spec$reps))
    progress(as.integer(scenario$spec$reps), as.integer(scenario$spec$reps))
  }
  compact_woodhen_run(
    investigate_test_result(scenario, seed = seed),
    scenario,
    sample_trajectories = sample_trajectories
  )
}

investigate_ready_project <- function() {
  rPVA:::run_woodhen_reference_project(
    new_woodhen_project("Investigate core"),
    "05_future_baseline",
    runner = investigate_test_runner,
    sample_trajectories = 3L,
    now = as.POSIXct("2026-07-22 00:00:00", tz = "UTC")
  )$project
}

source_investigate_app <- function() {
  app_dir <- system.file("shiny", "practical2", package = "rPVA")
  if (!nzchar(app_dir)) app_dir <- file.path("inst", "shiny", "practical2")
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)
  env
}

test_that("both investigation routes require the exact current locked anchor", {
  ready <- investigate_ready_project()
  family <- build_woodhen_sensitivity_family("K", c(350, 250))
  cases <- list(
    missing = new_woodhen_project(),
    stale = within(ready, reference_library_version <- "woodhen-reference-v0"),
    wrong_seed = ready,
    wrong_horizon = ready,
    wrong_fingerprint = ready
  )
  cases$wrong_seed$runs[[1L]]$seed <- 999L
  cases$wrong_horizon$runs[[1L]]$horizon <- 74L
  cases$wrong_fingerprint$runs[[1L]]$spec_fingerprint <- paste(rep("0", 64), collapse = "")
  cases <- lapply(cases, function(project) {
    project$project_fingerprint <- woodhen_project_fingerprint(project)
    project
  })

  for (case_name in names(cases)) {
    original <- cases[[case_name]]
    expect_error(
      rPVA:::woodhen_run_investigation_family_project(
        original, family, runner = investigate_test_runner
      ),
      "locked future baseline|current compatible project",
      info = case_name
    )
    expect_identical(cases[[case_name]], original)
  }
})

test_that("all eight factors run exact isolated three-setting families", {
  locked <- woodhen_locked_future_spec()
  catalog <- woodhen_sensitivity_catalog()
  project <- investigate_ready_project()

  for (index in seq_len(nrow(catalog))) {
    values <- unname(catalog$anchors[[index]][c("moderate", "high")])
    family <- build_woodhen_sensitivity_family(catalog$id[[index]], values)
    progress <- list()
    action <- rPVA:::woodhen_run_investigation_family_project(
      project,
      family,
      progress = function(scenario, scenarios, completed, total) {
        progress[[length(progress) + 1L]] <<- c(
          scenario = scenario, scenarios = scenarios,
          completed = completed, total = total
        )
      },
      runner = investigate_test_runner,
      sample_trajectories = 3L
    )
    project <- action$project
    expect_false(action$reused)
    expect_length(action$runs, 3L)
    expect_equal(action$comparison$table$setting_value,
      c(catalog$locked_baseline[[index]], values))
    expect_s3_class(plot_woodhen_sensitivity_response(action$comparison), "ggplot")
    expect_equal(vapply(family$scenarios, function(x) x$spec$years, integer(1)), rep(75L, 3L))
    expect_equal(vapply(family$scenarios, function(x) x$spec$reps, integer(1)), rep(1000L, 3L))
    expect_equal(vapply(family$scenarios, `[[`, integer(1), "seed"), rep(123L, 3L))
    expect_true(all(vapply(family$scenarios, function(x) identical(x$spec$n0, locked$n0), logical(1))))
    expect_equal(vapply(progress, `[[`, numeric(1), "total"), rep(1000, 6L))
    expect_equal(vapply(progress, `[[`, numeric(1), "scenarios"), rep(3, 6L))
    for (scenario_index in 1:3) {
      observed <- vapply(progress, `[[`, numeric(1), "completed")[
        vapply(progress, `[[`, numeric(1), "scenario") == scenario_index
      ]
      expect_true(all(diff(observed) >= 0))
      expect_equal(tail(observed, 1L), 1000)
    }
  }
  expect_silent(validate_woodhen_project(project))
})

test_that("UI builders resolve presets, bounded custom settings, and reject invalid routes", {
  env <- source_investigate_app()
  expect_equal(
    env$investigate_sensitivity_values("K", "moderate", "high", 300, 200),
    c(350, 250)
  )
  expect_equal(
    env$investigate_sensitivity_values("K", "custom", "high", 300, 200),
    c(300, 250)
  )
  expect_error(
    env$investigate_sensitivity_values("K", "custom", "custom", 300, 300),
    "distinct|two altered"
  )
  expect_error(
    env$investigate_sensitivity_values("K", "custom", "high", 149, 250),
    "between 150 and 750"
  )
  expect_error(
    env$investigate_sensitivity_values("K", "custom", "high", 500, 250),
    "baseline|two altered"
  )

  threats <- woodhen_threat_catalog()$id
  for (threat_id in threats) {
    compatible <- env$investigate_compatible_interventions(threat_id)
    expect_true(length(compatible) >= 1L)
    expect_true("captive_breeding_supplementation" %in% compatible)
    family <- env$investigate_build_future_family(
      threat_id, "moderate", NA_real_, compatible[[1L]], "moderate", NA_real_
    )
    expect_length(family$scenarios, 3L)
    profile <- family$scenarios[[2L]]$temporal_profile[[1L]]
    if (identical(threat_id, "sea_level_rise_pathway")) {
      expect_identical(profile, list(shape = "linear", onset_year = 1L, end_year = 75L))
      expect_equal(family$scenarios[[2L]]$spec$annual_profiles$K[[1L]], 500)
      expect_equal(tail(family$scenarios[[2L]]$spec$annual_profiles$K, 1L), 350)
    } else {
      expect_identical(profile, list(shape = "step", onset_year = 1L, end_year = 1L))
    }
  }
  expect_error(
    env$investigate_build_future_family(
      "novel_disease", "moderate", NA_real_, "", "moderate", NA_real_
    ),
    "intervention"
  )
  expect_error(
    env$investigate_build_future_family(
      "novel_disease", "moderate", NA_real_, "emergency_response", "moderate", NA_real_
    ),
    "compatible"
  )
})

test_that("future families preserve exact ancestry and threat-relative advice", {
  env <- source_investigate_app()
  project <- investigate_ready_project()
  for (threat_id in woodhen_threat_catalog()$id) {
    intervention_id <- env$investigate_compatible_interventions(threat_id)[[1L]]
    family <- env$investigate_build_future_family(
      threat_id, "moderate", NA_real_, intervention_id, "moderate", NA_real_
    )
    action <- rPVA:::woodhen_run_investigation_family_project(
      project, family, runner = investigate_test_runner, sample_trajectories = 3L
    )
    project <- action$project
    table <- action$comparison$table
    expect_equal(table$scenario_type, c("locked_baseline", "threat", "intervention"))
    expect_equal(table$parent_id[[2L]], table$scenario_id[[1L]])
    expect_equal(table$parent_id[[3L]], table$scenario_id[[2L]])
    expect_equal(
      table$delta_final_median_abundance[[3L]],
      table$final_median_abundance[[3L]] - table$final_median_abundance[[2L]]
    )
    expect_true(all(c(
      "final_q025", "final_q975", "extinction_probability",
      "quasi_extinction_probability", "quasi_extinction_conditional_median_year",
      "quasi_extinction_overall_median_year", "delta_extinction_probability",
      "delta_quasi_extinction_probability", "delta_final_median_abundance"
    ) %in% names(table)))
  }
  expect_silent(validate_woodhen_project(project))
})

test_that("family actions are atomic, immutable, duplicate-free, and prompt-aware", {
  project <- investigate_ready_project()
  family <- build_woodhen_sensitivity_family("K", c(350, 250))
  prompt <- list(
    research_question = "How strongly does habitat capacity affect risk?",
    biological_reason = "Territory holders require breeding habitat.",
    expected_direction = "Lower capacity should increase risk."
  )
  first <- rPVA:::woodhen_run_investigation_family_project(
    project, family, prompt = prompt,
    runner = investigate_test_runner, sample_trajectories = 3L
  )
  expect_length(first$project$observations, 1L)
  expect_true(first$prompt_saved)

  rerun <- rPVA:::woodhen_run_investigation_family_project(
    first$project, family, prompt = prompt,
    runner = function(...) stop("exact rerun must be reused")
  )
  expect_true(rerun$reused)
  expect_false(rerun$prompt_saved)
  expect_identical(rerun$project, first$project)

  changed <- build_woodhen_sensitivity_family("K", c(300, 250))
  second <- rPVA:::woodhen_run_investigation_family_project(
    rerun$project, changed, prompt = list(),
    runner = investigate_test_runner, sample_trajectories = 3L
  )
  family_ids <- unique(vapply(second$project$runs, `[[`, character(1), "family_id"))
  expect_true(all(c(family$family_id, changed$family_id) %in% family_ids))
  expect_length(second$project$observations, 1L)

  calls <- 0L
  failing_runner <- function(...) {
    calls <<- calls + 1L
    if (calls == 2L) stop("synthetic family failure")
    investigate_test_runner(...)
  }
  prospective <- build_woodhen_prospective_family(
    "increased_cyclone_pressure",
    list(response = list(intervention_id = "emergency_response"))
  )
  before <- second$project
  expect_error(
    rPVA:::woodhen_run_investigation_family_project(
      before, prospective, prompt = prompt, runner = failing_runner
    ),
    "synthetic family failure"
  )
  expect_identical(second$project, before)
})

test_that("Investigation module guards busy clicks and restores completed evidence", {
  env <- source_investigate_app()
  busy <- shiny::reactiveVal(FALSE)
  expect_true(shiny::isolate(env$investigate_begin_batch(busy)))
  expect_false(shiny::isolate(env$investigate_begin_batch(busy)))
  shiny::isolate(busy(FALSE))

  project <- investigate_ready_project()
  family <- build_woodhen_sensitivity_family("K", c(350, 250))
  completed <- rPVA:::woodhen_run_investigation_family_project(
    project, family, runner = investigate_test_runner, sample_trajectories = 3L
  )$project
  future_family <- env$investigate_build_future_family(
    "sea_level_rise_pathway", "custom", 325,
    "habitat_protection_restoration", "high", NA_real_
  )
  completed <- rPVA:::woodhen_run_investigation_family_project(
    completed, future_family,
    runner = investigate_test_runner, sample_trajectories = 3L
  )$project
  restored <- env$investigate_restored_controls(completed)
  expect_identical(restored$sensitivity$factor_id, "K")
  expect_equal(restored$sensitivity$values, c(350, 250))
  expect_identical(restored$sensitivity$choices, c("moderate", "high"))
  expect_identical(restored$future$threat_id, "sea_level_rise_pathway")
  expect_equal(restored$future$threat_value, 325)
  expect_identical(restored$future$threat_choice, "custom")
  expect_identical(
    restored$future$intervention_id, "habitat_protection_restoration"
  )
  expect_equal(restored$future$intervention_value, 1)
  expect_identical(restored$future$intervention_choice, "high")
  live <- shiny::reactiveVal(completed)

  shiny::testServer(env$investigate_server, args = list(
    project = shiny::reactive(live()), scenario_runner = investigate_test_runner
  ), {
    expect_identical(completion_state()$sensitivity, "Three sensitivity settings available")
    expect_s3_class(sensitivity_comparison(), "woodhen_run_family_comparison")
    expect_equal(sensitivity_comparison()$family_id, family$family_id)
    expect_identical(completion_state()$future, "Threat-intervention family complete")
    expect_equal(future_comparison()$family_id, future_family$family_id)
  })
})

test_that("Investigate UI and root integration are accessible and honest", {
  env <- source_investigate_app()
  html <- paste(as.character(env$investigate_ui("investigate")), collapse = "\n")
  app_text <- paste(readLines(file.path(env$practical2_app_dir, "app.R")), collapse = "\n")
  help <- paste(readLines(file.path(env$practical2_app_dir, "content", "help-investigate.md")), collapse = "\n")
  css <- paste(readLines(file.path(env$practical2_app_dir, "www", "styles.css")), collapse = "\n")

  for (id in c(
    "investigate-factor_id", "investigate-run_sensitivity",
    "investigate-threat_id", "investigate-intervention_id",
    "investigate-run_future", "investigate-go_calibrate"
  )) expect_match(html, paste0('id="', id, '"'), fixed = TRUE)
  expect_match(html, 'aria-live="polite"', fixed = TRUE)
  expect_match(html, "fewer than 50 breeding pairs", ignore.case = TRUE)
  expect_match(html, "75 years")
  expect_match(html, "1,000")
  expect_match(help, "strictly fewer than 50", ignore.case = TRUE)
  expect_match(help, "stages 2 onward", ignore.case = TRUE)
  expect_match(help, "sea-level", ignore.case = TRUE)
  expect_match(help, "not yet implemented", ignore.case = TRUE)
  expect_match(css, "investigate-workspaces")
  expect_match(css, "@media \\(max-width: 780px\\)")
  expect_match(app_text, 'source(file.path("modules", "mod_investigate.R")', fixed = TRUE)
  expect_match(app_text, 'investigate_ui("investigate")', fixed = TRUE)
  expect_match(app_text, "investigate_events <- investigate_server", fixed = TRUE)
  expect_match(app_text, "observeEvent(investigate_events$project_update()", fixed = TRUE)
  expect_equal(length(gregexpr('class="pending-tab-band"', paste(as.character(env$ui), collapse = "\n"), fixed = TRUE)[[1L]]), 2L)
})
