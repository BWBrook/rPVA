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

investigate_action_value <- function(value) {
  structure(as.integer(value), class = c("shinyActionButtonValue", "integer"))
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
      "locked future baseline|common future comparison|current compatible project",
      info = case_name
    )
    expect_identical(cases[[case_name]], original)
  }
})

test_that("all eight factors run exact isolated three-setting families", {
  locked <- woodhen_locked_future_spec()
  catalog <- woodhen_sensitivity_catalog()
  project <- investigate_ready_project()
  env <- source_investigate_app()

  for (index in seq_len(nrow(catalog))) {
    values <- unname(catalog$anchors[[index]][c("higher", "lower")])
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
    restored <- env$investigate_restored_controls(project)$sensitivity
    expect_identical(restored$factor_id, catalog$id[[index]])
    expect_equal(restored$values, values)
  }
  expect_silent(validate_woodhen_project(project))
})

test_that("sensitivity inputs keep the higher and lower alternatives on opposite sides", {
  env <- source_investigate_app()
  catalog <- woodhen_sensitivity_catalog()

  for (index in seq_len(nrow(catalog))) {
    factor_id <- catalog$id[[index]]
    anchor <- catalog$anchors[[index]]
    expect_equal(
      env$investigate_sensitivity_values(
        factor_id, "higher", "lower", NA_real_, NA_real_
      ),
      unname(anchor[c("higher", "lower")]),
      info = factor_id
    )
  }

  expect_error(
    env$investigate_sensitivity_values("K", "custom", "lower", 300, NA_real_),
    "Alternative 1 must be higher"
  )
  expect_error(
    env$investigate_sensitivity_values("K", "higher", "custom", NA_real_, 400),
    "Alternative 2 must be lower"
  )
})

test_that("Gate G1 presents every sensitivity factor with factor-specific evidence", {
  env <- source_investigate_app()
  catalog <- woodhen_sensitivity_catalog()
  choices <- env$investigate_sensitivity_factor_choices()

  expect_identical(unname(choices), catalog$id)
  expect_identical(names(choices), catalog$label)
  expect_null(env$investigate_sensitivity_display_data(NULL))

  for (index in seq_len(nrow(catalog))) {
    factor_id <- catalog$id[[index]]
    model <- env$investigate_sensitivity_factor_model(factor_id)
    range <- catalog$custom_range[[index]]
    if (identical(factor_id, "K_sd")) {
      range[["max"]] <- 108
    }
    values <- unname(catalog$anchors[[index]][c("higher", "lower")])
    family <- build_woodhen_sensitivity_family(factor_id, values)
    comparison <- rPVA:::woodhen_run_investigation_family_project(
      investigate_ready_project(),
      family,
      runner = investigate_test_runner,
      sample_trajectories = 3L
    )$comparison
    evidence <- env$investigate_sensitivity_display_data(
      comparison, factor_id
    )
    plots <- env$investigate_sensitivity_probe_plot(evidence)
    table <- env$investigate_sensitivity_probe_table(evidence)

    expect_identical(model$factor_id, factor_id, info = factor_id)
    expect_identical(model$label, catalog$label[[index]], info = factor_id)
    expect_equal(model$baseline, catalog$locked_baseline[[index]], info = factor_id)
    expect_equal(model$defaults, values, info = factor_id)
    expect_equal(model$range, range, info = factor_id)
    expect_true(all(nzchar(unlist(model[c(
      "question", "what_changes", "meaning", "boundary", "input_label",
      "unit_label", "x_label", "plot_title", "research_placeholder",
      "direction_placeholder"
    )]))), info = factor_id)
    expect_identical(unique(evidence$factor_id), factor_id, info = factor_id)
    expect_equal(evidence$setting_value,
      c(catalog$locked_baseline[[index]], values),
      info = factor_id
    )
    expect_identical(table$Setting, evidence$setting_label, info = factor_id)
    expect_s3_class(plots, "patchwork")
    expect_identical(plots[[1L]]$labels$x, model$x_label, info = factor_id)
    expect_identical(plots[[2L]]$labels$x, model$x_label, info = factor_id)
    expect_match(
      plots$patches$annotation$title, model$label,
      fixed = TRUE, info = factor_id
    )
    if (!identical(factor_id, "K")) {
      expect_false(any(grepl(
        "breeding territor", evidence$setting_label,
        ignore.case = TRUE
      )), info = factor_id)
    }
  }
  k_sd_model <- env$investigate_sensitivity_factor_model("K_sd")
  expect_equal(k_sd_model$range[["max"]], 108)
  expect_silent(
    env$investigate_sensitivity_values(
      "K_sd", "custom", "lower", 108, NA_real_
    )
  )
  expect_error(
    env$investigate_sensitivity_values(
      "K_sd", "custom", "lower", 109, NA_real_
    ),
    "between 0 and 108"
  )
})

test_that("UI builders resolve presets, bounded custom settings, and reject invalid routes", {
  env <- source_investigate_app()
  expect_equal(
    env$investigate_sensitivity_values("K", "higher", "lower", 300, 200),
    c(500, 150)
  )
  expect_equal(
    env$investigate_sensitivity_values("K", "custom", "lower", 400, 200),
    c(400, 150)
  )
  expect_error(
    env$investigate_sensitivity_values("K", "custom", "custom", 300, 300),
    "different alternative"
  )
  expect_error(
    env$investigate_sensitivity_values("K", "custom", "lower", 149, 250),
    "between 150 and 750"
  )
  expect_error(
    env$investigate_sensitivity_values("K", "custom", "lower", 325, 250),
    "current no-change assumption"
  )

  core <- env$investigate_future_core_catalog()
  for (index in seq_len(nrow(core))) {
    threat_id <- core$threat_id[[index]]
    intervention_id <- core$intervention_id[[index]]
    expect_true(intervention_id %in%
      env$investigate_compatible_interventions(threat_id))
    family <- env$investigate_build_future_family(
      threat_id, "moderate", NA_real_, intervention_id, "moderate", NA_real_
    )
    expect_length(family$scenarios, 3L)
    profile <- family$scenarios[[2L]]$temporal_profile[[1L]]
    if (identical(threat_id, "sea_level_rise_pathway")) {
      expect_identical(profile, list(shape = "linear", onset_year = 1L, end_year = 75L))
      expect_equal(family$scenarios[[2L]]$spec$annual_profiles$K[[1L]], 325)
      expect_equal(tail(family$scenarios[[2L]]$spec$annual_profiles$K, 1L), 225)
    } else {
      expect_identical(profile, list(shape = "step", onset_year = 1L, end_year = 1L))
    }
  }
  expect_error(
    env$investigate_build_future_family(
      "habitat_contraction", "moderate", NA_real_, "", "moderate", NA_real_
    ),
    "intervention"
  )
  expect_error(
    env$investigate_build_future_family(
      "habitat_contraction", "moderate", NA_real_,
      "emergency_response", "moderate", NA_real_
    ),
    "compatible|guided management response"
  )
})

test_that("future families preserve exact ancestry and threat-relative advice", {
  env <- source_investigate_app()
  project <- investigate_ready_project()
  core <- env$investigate_future_core_catalog()
  for (index in seq_len(nrow(core))) {
    threat_id <- core$threat_id[[index]]
    intervention_id <- core$intervention_id[[index]]
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

  reuse_progress <- list()
  rerun <- rPVA:::woodhen_run_investigation_family_project(
    first$project, family, prompt = prompt,
    progress = function(scenario, scenarios, completed, total) {
      reuse_progress[[length(reuse_progress) + 1L]] <<- c(
        scenario = scenario, scenarios = scenarios,
        completed = completed, total = total
      )
    },
    runner = function(...) stop("exact rerun must be reused")
  )
  expect_true(rerun$reused)
  expect_false(rerun$prompt_saved)
  expect_identical(rerun$project, first$project)
  expect_length(reuse_progress, 3L)
  expect_equal(vapply(reuse_progress, `[[`, numeric(1), "scenario"), 1:3)
  expect_equal(vapply(reuse_progress, `[[`, numeric(1), "scenarios"), rep(3, 3L))
  expect_equal(vapply(reuse_progress, `[[`, numeric(1), "completed"), rep(1000, 3L))
  expect_equal(vapply(reuse_progress, `[[`, numeric(1), "total"), rep(1000, 3L))

  reversed <- build_woodhen_sensitivity_family("K", c(250, 350))
  expect_identical(reversed$family_id, family$family_id)
  reversed_rerun <- rPVA:::woodhen_run_investigation_family_project(
    rerun$project, reversed, prompt = prompt,
    runner = function(...) stop("reversed exact family must be reused")
  )
  expect_true(reversed_rerun$reused)
  expect_false(reversed_rerun$prompt_saved)
  expect_length(reversed_rerun$project$observations, 1L)
  expect_identical(
    reversed_rerun$comparison$table$setting_value,
    c(325, 250, 350)
  )

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
    list(
      threat_id = "increased_cyclone_pressure",
      components = list(
        cyclone_survival = list(
          field = "cat_surv", operator = "absolute", value = 0.40
        ),
        cyclone_reproduction = list(
          field = "cat_repro", operator = "absolute", value = 0.60
        )
      )
    ),
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

test_that("future investigation projects satisfy the strict browser-store boundary", {
  env <- source_investigate_app()
  project <- investigate_ready_project()
  family <- env$investigate_build_future_family(
    "predator_reinvasion", "low", NA_real_,
    "biosecurity_eradication", "moderate", NA_real_
  )
  action <- rPVA:::woodhen_run_investigation_family_project(
    project,
    family,
    prompt = list(
      research_question = "",
      biological_reason = "Test a plausible future pressure.",
      expected_direction = "Management should partly recover outcomes."
    ),
    runner = investigate_test_runner,
    sample_trajectories = 3L,
    now = as.POSIXct("2026-07-22 02:00:00", tz = "UTC")
  )
  snapshot <- rPVA:::woodhen_project_browser_snapshot(action$project)
  restored <- rPVA:::read_woodhen_project_browser_snapshot(snapshot)

  expect_identical(
    restored,
    rPVA:::woodhen_project_restore_schema_order(action$project)
  )
  expect_silent(env$project_store_record(
    action$project,
    snapshot,
    "2026-07-22T02:01:00Z",
    portable_request_fingerprint = NULL
  ))
})

test_that("Investigation module guards busy clicks and restores completed evidence", {
  env <- source_investigate_app()
  busy <- shiny::reactiveVal(FALSE)
  expect_true(shiny::isolate(env$investigate_begin_batch(busy)))
  expect_false(shiny::isolate(env$investigate_begin_batch(busy)))
  shiny::isolate(busy(FALSE))

  project <- investigate_ready_project()
  family <- build_woodhen_sensitivity_family("K_sd", c(108, 0))
  completed <- rPVA:::woodhen_run_investigation_family_project(
    project, family, runner = investigate_test_runner, sample_trajectories = 3L
  )$project
  future_family <- env$investigate_build_future_family(
    "sea_level_rise_pathway", "moderate", NA_real_,
    "habitat_protection_restoration", "high", NA_real_
  )
  completed <- rPVA:::woodhen_run_investigation_family_project(
    completed, future_family,
    runner = investigate_test_runner, sample_trajectories = 3L
  )$project
  restored <- env$investigate_restored_controls(completed)
  expect_identical(restored$sensitivity$factor_id, "K_sd")
  expect_equal(restored$sensitivity$values, c(108, 0))
  expect_identical(restored$sensitivity$choices, c("higher", "lower"))
  expect_identical(restored$future$threat_id, "sea_level_rise_pathway")
  expect_equal(restored$future$threat_value, 225)
  expect_identical(restored$future$threat_choice, "moderate")
  expect_identical(
    restored$future$intervention_id, "habitat_protection_restoration"
  )
  expect_equal(restored$future$intervention_value, 1)
  expect_identical(restored$future$intervention_choice, "high")
  live <- shiny::reactiveVal(completed)
  reuse_calls <- 0L
  reuse_runner <- function(...) {
    reuse_calls <<- reuse_calls + 1L
    stop("a completed module family must be reused")
  }

  shiny::testServer(env$investigate_server, args = list(
    project = shiny::reactive(live()), scenario_runner = reuse_runner
  ), {
    session$setInputs(
      threat_id = restored$future$threat_id,
      threat_choice = restored$future$threat_choice,
      intervention_id = restored$future$intervention_id,
      intervention_choice = restored$future$intervention_choice
    )
    session$flushReact()
    expect_identical(
      completion_state()$sensitivity,
      "Habitat-capacity variability comparison complete"
    )
    expect_s3_class(sensitivity_comparison(), "woodhen_run_family_comparison")
    expect_equal(sensitivity_comparison()$family_id, family$family_id)
    expect_identical(
      completion_state()$future,
      "Threat and management comparison complete"
    )
    expect_equal(future_comparison()$family_id, future_family$family_id)
    session$setInputs(
      factor_id = "K_sd",
      sensitivity_first_choice = "higher",
      sensitivity_second_choice = "lower",
      sensitivity_first_custom = 108,
      sensitivity_second_custom = 0,
      run_sensitivity = investigate_action_value(1L)
    )
    expect_equal(reuse_calls, 0L)
    expect_true(project_update_state()$reused)
    expect_identical(
      progress_state()$sensitivity,
      c(scenario = 3L, scenarios = 3L, completed = 1000L, total = 1000L)
    )
    expect_true(busy())
    session$flushReact()
    expect_false(busy())
  })
})

test_that("Investigation saves linked sensitivity observations through a distinct event", {
  env <- source_investigate_app()
  ready <- investigate_ready_project()
  family <- build_woodhen_sensitivity_family("K", c(500, 150))
  completed <- rPVA:::woodhen_run_investigation_family_project(
    ready,
    family,
    runner = investigate_test_runner,
    sample_trajectories = 3L
  )$project
  live <- shiny::reactiveVal(completed)

  shiny::testServer(env$investigate_server, args = list(
    project = shiny::reactive(live()),
    scenario_runner = investigate_test_runner
  ), {
    session$setInputs(
      factor_id = "K",
      sensitivity_first_choice = "higher",
      sensitivity_second_choice = "lower",
      sensitivity_first_custom = 500,
      sensitivity_second_custom = 150
    )
    session$flushReact()
    session$setInputs(
      sensitivity_interpretation = paste(
        "Final abundance and warning-threshold risk responded differently",
        "across the three territory settings."
      ),
      sensitivity_caveat = "Territory capacity does not represent spatial habitat quality.",
      save_sensitivity_notes = investigate_action_value(1L)
    )
    event <- observation_update_state()
    expect_true(event$ok)
    expect_identical(event$family_id, family$family_id)
    expect_identical(event$route, "sensitivity")
    expect_identical(
      event$base_project_fingerprint,
      completed$project_fingerprint
    )
    expect_length(event$candidate$observations, length(completed$observations) + 1L)
    appended <- tail(event$candidate$observations, 1L)[[1L]]
    expect_identical(
      sort(appended$run_ids),
      sort(sensitivity_comparison()$table$run_id)
    )
    expect_match(appended$note, "Interpretation:")
    expect_match(appended$note, "Caveat:")
  })
})

test_that("Investigation module flushes disabled controls and rejects queued submissions", {
  env <- source_investigate_app()
  project <- investigate_ready_project()
  calls <- 0L
  runner <- function(...) {
    calls <<- calls + 1L
    investigate_test_runner(...)
  }

  enabled <- paste(as.character(env$investigate_run_action(
    shiny::NS("investigate"), "sensitivity", FALSE
  )), collapse = "\n")
  disabled <- paste(as.character(env$investigate_run_action(
    shiny::NS("investigate"), "sensitivity", TRUE
  )), collapse = "\n")
  future_enabled <- paste(as.character(env$investigate_run_action(
    shiny::NS("investigate"), "future", FALSE
  )), collapse = "\n")
  expect_match(enabled, 'id="investigate-run_sensitivity"', fixed = TRUE)
  expect_false(grepl('disabled="disabled"', enabled, fixed = TRUE))
  expect_match(enabled, 'aria-disabled="false"', fixed = TRUE)
  expect_match(disabled, 'disabled="disabled"', fixed = TRUE)
  expect_match(disabled, 'aria-disabled="true"', fixed = TRUE)
  for (html in c(enabled, future_enabled)) {
    expect_match(html, "onclick=", fixed = TRUE)
    expect_match(html, "investigate-run_sensitivity", fixed = TRUE)
    expect_match(html, "investigate-run_future", fixed = TRUE)
    expect_match(html, "button.disabled=true", fixed = TRUE)
  }

  shiny::testServer(env$investigate_server, args = list(
    project = shiny::reactive(project), scenario_runner = runner
  ), {
    session$setInputs(
      factor_id = "K",
      sensitivity_first_choice = "higher",
      sensitivity_second_choice = "lower",
      sensitivity_first_custom = 350,
      sensitivity_second_custom = 250,
      threat_id = "predator_reinvasion",
      threat_choice = "low",
      intervention_id = "biosecurity_eradication",
      intervention_choice = "moderate",
      intervention_custom = 0.5
    )
    session$setInputs(
      run_sensitivity = investigate_action_value(1L),
      run_future = investigate_action_value(1L)
    )

    expect_equal(calls, 3L)
    expect_identical(project_update_state()$route, "sensitivity")
    expect_true(project_update_state()$ok)
    expect_false(project_update_state()$reused)
    expect_identical(
      project_update_state()$base_project_fingerprint,
      project()$project_fingerprint
    )
    expect_identical(
      status_state()[["future"]],
      "A family is already running; the repeated submission was ignored."
    )
    expect_true(busy())
    session$flushReact()
    expect_false(busy())
    expect_length(project_update_state()$candidate$runs, length(project()$runs) + 3L)
    expect_length(
      env$investigate_completed_family_ids(project_update_state()$candidate, "prospective"),
      0L
    )
  })
})

test_that("a fresh session restores completed Investigate evidence before selectors settle", {
  env <- source_investigate_app()
  project <- investigate_ready_project()
  family <- build_woodhen_sensitivity_family("K_sd", c(108, 0))
  completed <- rPVA:::woodhen_run_investigation_family_project(
    project,
    family,
    runner = investigate_test_runner,
    sample_trajectories = 3L
  )$project
  future_family <- env$investigate_build_future_family(
    "sea_level_rise_pathway",
    "moderate",
    NA_real_,
    "habitat_protection_restoration",
    "high",
    NA_real_
  )
  completed <- rPVA:::woodhen_run_investigation_family_project(
    completed,
    future_family,
    runner = investigate_test_runner,
    sample_trajectories = 3L
  )$project
  default_row <- woodhen_sensitivity_catalog()
  default_row <- default_row[default_row$id == "K", , drop = FALSE]
  default_values <- unname(default_row$anchors[[1L]][c("higher", "lower")])
  live <- shiny::reactiveVal(NULL)

  shiny::testServer(env$investigate_server, args = list(
    project = shiny::reactive(live()),
    scenario_runner = investigate_test_runner
  ), {
    session$setInputs(
      factor_id = "K",
      sensitivity_first_custom = default_values[[1L]],
      sensitivity_second_custom = default_values[[2L]],
      threat_id = "predator_reinvasion",
      threat_choice = "high",
      intervention_id = "biosecurity_eradication",
      intervention_choice = "moderate"
    )
    session$flushReact()

    live(completed)
    session$flushReact()

    expect_identical(selected_sensitivity_family_id(), family$family_id)
    expect_identical(sensitivity_model()$factor_id, "K_sd")
    expect_s3_class(
      sensitivity_comparison(),
      "woodhen_run_family_comparison"
    )
    expect_match(
      status_state()[["sensitivity"]],
      "loaded from this project",
      ignore.case = TRUE
    )
    expect_identical(selected_future_family_id(), future_family$family_id)
    expect_s3_class(
      future_comparison(),
      "woodhen_run_family_comparison"
    )
    expect_match(
      status_state()[["future"]],
      "loaded from this project",
      ignore.case = TRUE
    )
  })
})

test_that("late hidden-tab defaults do not replace restored Investigate controls", {
  env <- source_investigate_app()
  project <- investigate_ready_project()
  family <- build_woodhen_sensitivity_family("K_sd", c(108, 0))
  completed <- rPVA:::woodhen_run_investigation_family_project(
    project,
    family,
    runner = investigate_test_runner,
    sample_trajectories = 3L
  )$project
  future_family <- env$investigate_build_future_family(
    "sea_level_rise_pathway",
    "moderate",
    NA_real_,
    "habitat_protection_restoration",
    "high",
    NA_real_
  )
  completed <- rPVA:::woodhen_run_investigation_family_project(
    completed,
    future_family,
    runner = investigate_test_runner,
    sample_trajectories = 3L
  )$project
  default_row <- woodhen_sensitivity_catalog()
  default_row <- default_row[default_row$id == "K", , drop = FALSE]
  default_values <- unname(default_row$anchors[[1L]][c("higher", "lower")])
  live <- shiny::reactiveVal(NULL)

  shiny::testServer(env$investigate_server, args = list(
    project = shiny::reactive(live()),
    scenario_runner = investigate_test_runner
  ), {
    session$flushReact()
    live(completed)
    session$flushReact()

    session$setInputs(
      factor_id = "K",
      sensitivity_first_custom = default_values[[1L]],
      sensitivity_second_custom = default_values[[2L]],
      threat_id = "predator_reinvasion",
      threat_choice = "high",
      intervention_id = "biosecurity_eradication",
      intervention_choice = "moderate"
    )
    session$flushReact()

    expect_identical(selected_sensitivity_family_id(), family$family_id)
    expect_identical(sensitivity_model()$factor_id, "K_sd")
    expect_s3_class(
      sensitivity_comparison(),
      "woodhen_run_family_comparison"
    )
    expect_match(
      status_state()[["sensitivity"]],
      "loaded from this project",
      ignore.case = TRUE
    )
    expect_identical(selected_future_family_id(), future_family$family_id)
    expect_s3_class(
      future_comparison(),
      "woodhen_run_family_comparison"
    )
    expect_match(
      status_state()[["future"]],
      "loaded from this project",
      ignore.case = TRUE
    )
  })
})

test_that("Investigation aborts a deferred family when the live project changes", {
  env <- source_investigate_app()
  accepted <- investigate_ready_project()
  replacement <- investigate_ready_project()
  live <- shiny::reactiveVal(accepted)
  calls <- 0L
  runner <- function(...) {
    calls <<- calls + 1L
    investigate_test_runner(...)
  }
  family <- build_woodhen_sensitivity_family("K", c(350, 250))

  shiny::testServer(env$investigate_server, args = list(
    project = shiny::reactive(live()), scenario_runner = runner
  ), {
    shiny::isolate(run_route("sensitivity", family, list()))
    expect_true(shiny::isolate(busy()))
    live(replacement)
    session$flushReact()

    expect_equal(calls, 0L)
    expect_false(project_update_state()$ok)
    expect_match(project_update_state()$message, "active project changed", fixed = TRUE)
    expect_identical(
      project_update_state()$base_project_fingerprint,
      accepted$project_fingerprint
    )
    session$flushReact()
    expect_false(shiny::isolate(busy()))
  })
})

test_that("Investigation keeps the cross-route guard through the post-work flush", {
  env <- source_investigate_app()
  project <- investigate_ready_project()
  calls <- 0L
  runner <- function(...) {
    calls <<- calls + 1L
    investigate_test_runner(...)
  }
  family <- build_woodhen_sensitivity_family("K", c(350, 250))
  busy_after_work <- NA
  notice_after_work <- NA

  shiny::testServer(env$investigate_server, args = list(
    project = shiny::reactive(project), scenario_runner = runner
  ), {
    session$setInputs(
      threat_id = "predator_reinvasion",
      threat_choice = "low",
      intervention_id = "biosecurity_eradication",
      intervention_choice = "moderate",
      intervention_custom = 0.5
    )
    shiny::isolate(run_route("sensitivity", family, list()))
    session$onFlushed(function() {
      busy_after_work <<- shiny::isolate(busy())
      notice_after_work <<- shiny::isolate(processing_notice_active())
    }, once = TRUE)
    session$setInputs(run_future = investigate_action_value(1L))

    expect_true(busy_after_work)
    expect_true(notice_after_work)
    expect_equal(calls, 3L)
    expect_true(project_update_state()$ok)
    expect_identical(project_update_state()$route, "sensitivity")
    expect_identical(
      status_state()[["future"]],
      "A family is already running; the repeated submission was ignored."
    )
    expect_length(project_update_state()$candidate$runs, length(project()$runs) + 3L)
    expect_length(
      env$investigate_completed_family_ids(project_update_state()$candidate, "prospective"),
      0L
    )
    session$flushReact()
    expect_false(shiny::isolate(busy()))
    expect_false(shiny::isolate(processing_notice_active()))
  })
})

test_that("completed simulations remain visibly busy until results are ready", {
  env <- source_investigate_app()

  expect_identical(
    env$investigate_progress_heading(
      route = "sensitivity",
      scenario = 3L,
      scenarios = 3L,
      overall_completed = 3000L,
      overall_total = 3000L,
      is_busy = TRUE,
      has_comparison = FALSE,
      sensitivity_label = "Breeding-territory capacity"
    ),
    "Summarising and plotting results"
  )
  expect_identical(
    env$investigate_progress_heading(
      route = "future",
      scenario = 3L,
      scenarios = 3L,
      overall_completed = 3000L,
      overall_total = 3000L,
      is_busy = FALSE,
      has_comparison = TRUE
    ),
    "Threat and management comparison complete"
  )
  expect_identical(
    env$investigate_progress_heading(
      route = "future",
      scenario = 3L,
      scenarios = 3L,
      overall_completed = 3000L,
      overall_total = 3000L,
      is_busy = FALSE,
      has_comparison = FALSE
    ),
    "Comparison not completed"
  )
})

test_that("Investigate UI and root integration are accessible and explicit", {
  env <- source_investigate_app()
  html <- paste(as.character(env$investigate_ui("investigate")), collapse = "\n")
  ns <- shiny::NS("investigate")
  initial_model <- env$investigate_sensitivity_factor_model("K")
  dynamic_html <- paste(as.character(tagList(
    env$investigate_sensitivity_purpose_ui(ns, initial_model),
    env$investigate_sensitivity_workspace_intro_ui(ns, initial_model),
    env$investigate_sensitivity_setting_grid(ns, initial_model),
    env$investigate_prompt_inputs(ns, "sensitivity", initial_model),
    env$investigate_sensitivity_plot_region_ui(ns, initial_model),
    env$investigate_result_prompts(
      ns, "sensitivity", model = initial_model
    )
  )), collapse = "\n")
  html <- paste(html, dynamic_html)
  app_text <- paste(readLines(file.path(env$practical2_app_dir, "app.R")), collapse = "\n")
  help <- paste(readLines(file.path(
    env$practical2_app_dir, "content", "help-sensitivity.md"
  )), collapse = "\n")
  css <- paste(readLines(file.path(env$practical2_app_dir, "www", "styles.css")), collapse = "\n")
  module_text <- paste(readLines(file.path(
    env$practical2_app_dir, "modules", "mod_investigate.R"
  )), collapse = "\n")

  for (id in c(
    "investigate-factor_id", "investigate-sensitivity_run_control",
    "investigate-sensitivity_first_custom",
    "investigate-sensitivity_second_custom",
    "investigate-sensitivity_plot", "investigate-sensitivity_table",
    "investigate-go_calibrate"
  )) expect_match(html, paste0('id="', id, '"'), fixed = TRUE)
  expect_match(html, 'aria-live="polite"', fixed = TRUE)
  expect_match(html, "100-pair warning threshold", ignore.case = TRUE)
  expect_match(html, "75 years")
  expect_match(html, "1,000")
  expect_match(html, "what stays the same", ignore.case = TRUE)
  expect_match(html, "breeding territories", ignore.case = TRUE)
  expect_match(html, "What are you testing?", fixed = TRUE)
  expect_match(html, "What did the simulations show, and why?", fixed = TRUE)
  expect_match(html, 'What does "below 100 pairs" mean?', fixed = TRUE)
  expect_match(html, "quasi-extinction threshold", ignore.case = TRUE)
  expect_false(grepl("Moderate anchor|High anchor|custom value", html))
  expect_match(help, "strictly below 100", ignore.case = TRUE)
  expect_match(help, "one-factor", ignore.case = TRUE)
  expect_match(help, "sensitivity analysis", ignore.case = TRUE)
  expect_match(help, "325 territories", ignore.case = TRUE)
  expect_match(help, "not a universal minimum viable", ignore.case = TRUE)
  expect_match(css, "sensitivity-setting-grid")
  expect_match(css, "investigate-progress-track")
  expect_match(css, "@media \\(max-width: 780px\\)")
  expect_match(module_text, "session$onFlushed(", fixed = TRUE)
  expect_match(module_text, "prompt <- force(prompt)", fixed = TRUE)
  expect_match(module_text, "shiny::isolate(event_counter())", fixed = TRUE)
  expect_match(module_text, "shiny::isolate(status_state())", fixed = TRUE)
  expect_match(module_text, "shiny::isolate(progress_state())", fixed = TRUE)
  expect_match(module_text, "shiny::isolate(progress_history_state())", fixed = TRUE)
  expect_match(
    module_text,
    'aria-disabled` = if (busy || design_probe)',
    fixed = TRUE
  )
  expect_match(module_text, "base_project_fingerprint", fixed = TRUE)
  expect_match(module_text, "withProgress(", fixed = TRUE)
  expect_match(module_text, "setProgress(", fixed = TRUE)
  expect_match(module_text, "observation_update = reactive", fixed = TRUE)
  expect_match(
    module_text,
    'investigate_run_action(session$ns, "sensitivity", busy())',
    fixed = TRUE
  )
  expect_match(
    module_text,
    'investigate_run_action(session$ns, "future", busy())',
    fixed = TRUE
  )
  expect_match(app_text, 'source(file.path("modules", "mod_investigate.R")', fixed = TRUE)
  expect_match(app_text, 'investigate_ui("investigate")', fixed = TRUE)
  expect_match(app_text, "investigate_events <- investigate_server", fixed = TRUE)
  expect_match(app_text, "observeEvent(investigate_events$project_update()", fixed = TRUE)
  expect_equal(length(gregexpr('class="pending-tab-band"', paste(as.character(env$ui), collapse = "\n"), fixed = TRUE)[[1L]]), 1L)
})

test_that("Gate G2 rat-return family changes recruitment without changing adult survival", {
  env <- source_investigate_app()
  core <- env$investigate_future_core_catalog()
  expect_identical(core$threat_id, c(
    "predator_reinvasion", "habitat_contraction",
    "sea_level_rise_pathway", "increased_cyclone_pressure"
  ))
  expect_identical(
    env$investigate_future_default_threat_choice("predator_reinvasion"),
    "high"
  )
  expect_identical(
    env$investigate_future_default_threat_choice("habitat_contraction"),
    "moderate"
  )

  family <- env$investigate_build_future_family(
    "predator_reinvasion", "low", NA_real_,
    "biosecurity_eradication", "moderate", NA_real_
  )
  common <- family$scenarios[[1L]]$spec
  threat <- family$scenarios[[2L]]$spec$annual_profiles
  managed <- family$scenarios[[3L]]$spec$annual_profiles

  expect_identical(
    unname(vapply(family$scenarios, `[[`, character(1), "student_label")),
    c("Locked future baseline", "Rat-return future", "Rat return with renewed control")
  )
  expect_equal(threat$surv[, 1L], rep(common$surv[[1L]] * 0.85, 75L))
  expect_equal(threat$surv[, 2:7], matrix(
    rep(common$surv[2:7], each = 75L), nrow = 75L
  ))
  expect_equal(threat$fecund[, 2:7], matrix(
    rep(common$fecund[2:7] * 0.80, each = 75L), nrow = 75L
  ))
  expect_equal(managed$surv[, 1L], rep(common$surv[[1L]] * 0.925, 75L))
  expect_equal(managed$surv[, 2:7], threat$surv[, 2:7])
  expect_equal(managed$fecund[, 2:7], matrix(
    rep(common$fecund[2:7] * 0.90, each = 75L), nrow = 75L
  ))
  expect_named(
    family$scenarios[[2L]]$components,
    c("young_bird_survival", "breeding_output")
  )
  expect_named(
    family$scenarios[[3L]]$components,
    c(
      "threat__young_bird_survival", "threat__breeding_output",
      "biosecurity_eradication__young_bird_survival",
      "biosecurity_eradication__breeding_output"
    )
  )

  restored_project <- investigate_ready_project()
  for (choice in c("low", "moderate", "high")) {
    round_trip_family <- env$investigate_build_future_family(
      "predator_reinvasion", choice, NA_real_,
      "biosecurity_eradication", "moderate", NA_real_
    )
    restored_project <- rPVA:::woodhen_run_investigation_family_project(
      restored_project,
      round_trip_family,
      runner = investigate_test_runner,
      sample_trajectories = 3L
    )$project
    canonical_project <- rPVA:::woodhen_project_restore_schema_order(
      restored_project
    )
    expect_identical(
      env$investigate_restored_controls(canonical_project)$future$threat_choice,
      choice
    )
  }

  for (index in seq_len(nrow(core))) {
    candidate <- env$investigate_build_future_family(
      core$threat_id[[index]], "moderate", NA_real_,
      core$intervention_id[[index]], "moderate", NA_real_
    )
    expect_length(candidate$scenarios, 3L)
    expect_identical(
      unname(vapply(candidate$scenarios, `[[`, character(1), "scenario_type")),
      c("locked_baseline", "threat", "intervention")
    )
  }
})

test_that("Gate G2 cyclone presets combine frequency, survival, and breeding losses", {
  env <- source_investigate_app()
  presets <- env$investigate_cyclone_presets()
  locked <- woodhen_locked_future_spec()

  expect_identical(presets$choice, c("low", "moderate", "high"))
  expect_equal(presets$cat_freq, c(0.07, 0.10, 0.15))
  expect_equal(presets$cat_surv, c(0.45, 0.40, 0.30))
  expect_equal(presets$cat_repro, c(0.60, 0.45, 0.30))
  expect_match(
    paste(names(env$investigate_future_threat_choices(
      "increased_cyclone_pressure"
    )), collapse = " "),
    "7%.*45%.*60%.*10%.*40%.*45%.*15%.*30%.*30%"
  )
  expect_error(
    env$investigate_build_future_family(
      "increased_cyclone_pressure", "custom", 0.08,
      "emergency_response", "moderate", NA_real_
    ),
    "named settings"
  )

  recoveries <- c(low = 0.25, moderate = 0.50, high = 0.75)
  for (index in seq_len(nrow(presets))) {
    threat_choice <- presets$choice[[index]]
    for (response_choice in names(recoveries)) {
      recovery <- recoveries[[response_choice]]
      family <- env$investigate_build_future_family(
        "increased_cyclone_pressure", threat_choice, NA_real_,
        "emergency_response", response_choice, NA_real_
      )
      threat <- family$scenarios[[2L]]
      managed <- family$scenarios[[3L]]

      expect_named(
        threat$components,
        c("cyclone_frequency", "cyclone_survival", "cyclone_reproduction")
      )
      expect_equal(
        tail(threat$spec$annual_profiles$cat_freq, 1L),
        presets$cat_freq[[index]]
      )
      expect_equal(
        tail(threat$spec$annual_profiles$cat_surv, 1L),
        presets$cat_surv[[index]]
      )
      expect_equal(
        tail(threat$spec$annual_profiles$cat_repro, 1L),
        presets$cat_repro[[index]]
      )
      expect_equal(
        tail(managed$spec$annual_profiles$cat_freq, 1L),
        presets$cat_freq[[index]]
      )
      expect_equal(
        tail(managed$spec$annual_profiles$cat_surv, 1L),
        presets$cat_surv[[index]] +
          recovery * (locked$cat_surv - presets$cat_surv[[index]])
      )
      expect_equal(
        tail(managed$spec$annual_profiles$cat_repro, 1L),
        presets$cat_repro[[index]] +
          recovery * (locked$cat_repro - presets$cat_repro[[index]])
      )
    }
  }

  model <- env$investigate_future_mechanism_model(
    "increased_cyclone_pressure", "moderate", "moderate"
  )
  expect_match(model$common_setting, "4%.*50%.*75%")
  expect_match(model$threat_setting, "10%.*40%.*45%")
  expect_match(model$managed_setting, "10%.*45%.*60%")
  expect_match(model$threat_mechanism, "all model stages", ignore.case = TRUE)
  expect_match(model$threat_mechanism, "acute recruitment loss", ignore.case = TRUE)
  expect_match(model$response_mechanism, "annual cyclone probability remains", ignore.case = TRUE)
  expect_match(model$boundary, "cannot uniquely model juvenile mortality", ignore.case = TRUE)
})

test_that("Gate G2 habitat contraction states illustrative ecological routes", {
  env <- source_investigate_app()
  model <- env$investigate_future_mechanism_model(
    "habitat_contraction", "moderate", "moderate"
  )
  copy <- paste(model$threat_mechanism, model$boundary)

  expect_match(copy, "climate-driven moisture", ignore.case = TRUE)
  expect_match(copy, "invertebrate-food", ignore.case = TRUE)
  expect_match(copy, "invasive plants", ignore.case = TRUE)
  expect_match(copy, "illustrative routes", ignore.case = TRUE)
  expect_match(copy, "only lowers.*territory capacity", ignore.case = TRUE)
  expect_match(copy, "not predictions", ignore.case = TRUE)
})

test_that("Gate G2 presents live ecological controls without implementation jargon", {
  env <- source_investigate_app()
  html <- paste(as.character(env$investigate_ui("investigate")), collapse = "\n")
  model <- env$investigate_future_mechanism_model(
    "predator_reinvasion", "low", "moderate"
  )
  mechanism_html <- paste(
    as.character(env$investigate_future_mechanism_ui(model)),
    collapse = "\n"
  )
  future_help <- paste(readLines(file.path(
    env$practical2_app_dir, "content", "help-threat-intervention.md"
  )), collapse = "\n")
  run_html <- paste(as.character(env$investigate_run_action(
    shiny::NS("investigate"), "future", FALSE
  )), collapse = "\n")
  save_html <- paste(as.character(env$investigate_future_observation_prompts(
    shiny::NS("investigate")
  )), collapse = "\n")

  for (id in c(
    "investigate-route_sensitivity", "investigate-route_future",
    "investigate-open_future_help", "investigate-threat_id",
    "investigate-threat_choice", "investigate-intervention_id",
    "investigate-intervention_choice", "investigate-future_expected_outcome",
    "investigate-future_mechanism_prediction",
    "investigate-future_partial_recovery", "investigate-future_run_control",
    "investigate-future_progress", "investigate-future_abundance_plot",
    "investigate-future_risk_plot", "investigate-future_passage_plot",
    "investigate-future_table", "investigate-future_threat_observation",
    "investigate-future_response_observation", "investigate-future_caveat",
    "investigate-save_future_notes"
  )) expect_match(html, paste0('id="', id, '"'), fixed = TRUE)

  expect_match(html, "Rat return or loss of control", fixed = TRUE)
  expect_match(html, "young-bird survival -15%; breeding output -20%", fixed = TRUE)
  expect_match(html, "3,000 futures", fixed = TRUE)
  expect_false(grepl("<fieldset[^>]+disabled", html, perl = TRUE))
  expect_false(grepl('disabled="disabled"', run_html, fixed = TRUE))
  expect_false(grepl('disabled="disabled"', save_html, fixed = TRUE))
  expect_match(mechanism_html, "egg or chick losses", ignore.case = TRUE)
  expect_match(mechanism_html, "territory-holder survival is unchanged", ignore.case = TRUE)
  expect_match(mechanism_html, "bounded teaching assumptions", ignore.case = TRUE)
  expect_match(mechanism_html, "Add the threat", fixed = TRUE)
  expect_match(mechanism_html, "Add management to the same threat", fixed = TRUE)

  student_copy <- paste(html, mechanism_html, future_help)
  expect_false(grepl("\\b(parent|child|yaml|seed|immutable|design probe)\\b",
    student_copy, ignore.case = TRUE, perl = TRUE
  ))
  expect_match(future_help, "egg or chick", ignore.case = TRUE)
  expect_match(future_help, "percentage points", ignore.case = TRUE)
  expect_match(future_help, "working warning threshold", ignore.case = TRUE)
  expect_match(future_help, "empirical estimates", ignore.case = TRUE)
})

test_that("Gate G2 live evidence uses probabilities, whole birds, and readable plots", {
  env <- source_investigate_app()
  project <- investigate_ready_project()
  family <- env$investigate_build_future_family(
    "predator_reinvasion", "low", NA_real_,
    "biosecurity_eradication", "moderate", NA_real_
  )
  action <- rPVA:::woodhen_run_investigation_family_project(
    project, family,
    runner = investigate_test_runner, sample_trajectories = 3L
  )
  evidence <- env$investigate_future_display_data(action$comparison)
  table <- env$investigate_future_probe_table(evidence)
  differences_html <- paste(
    as.character(env$investigate_future_difference_ui(evidence)),
    collapse = "\n"
  )

  expect_identical(evidence$summary$scenario, c(
    "Common future", "Rat-return future", "Rat return with renewed control"
  ))
  expect_true(all(evidence$risk$probability >= 0 & evidence$risk$probability <= 1))
  expect_identical(unique(evidence$risk$metric), "Fewer than 100 pairs")
  expect_false(any(grepl("Extinction", evidence$risk$metric, fixed = TRUE)))
  expect_true(all(evidence$first_passage$probability >= 0 &
    evidence$first_passage$probability <= 1))
  passage_risk <- vapply(evidence$summary$scenario, function(label) {
    sum(evidence$first_passage$probability[
      evidence$first_passage$scenario == label
    ])
  }, numeric(1))
  expect_true(all(unname(passage_risk) <=
    evidence$summary$warning_probability))
  starts_above_threshold <- vapply(
    action$comparison$runs,
    function(run) {
      years <- run$quasi_extinction_50_pairs$first_crossing_year
      !any(years == 0L, na.rm = TRUE)
    },
    logical(1)
  )
  expect_equal(
    unname(passage_risk[starts_above_threshold]),
    evidence$summary$warning_probability[starts_above_threshold]
  )
  expect_s3_class(env$investigate_future_abundance_plot(evidence), "ggplot")
  expect_s3_class(env$investigate_future_risk_plot(evidence), "ggplot")
  expect_s3_class(env$investigate_future_passage_plot(evidence), "ggplot")
  expect_true(all(evidence$summary$final_median_abundance %% 1 == 0))
  expect_identical(table$Scenario, evidence$summary$scenario)
  expect_true("Futures below 100 pairs by 2100" %in% names(table))
  expect_true("Extinction by 2100" %in% names(table))
  expect_false("Crossing futures" %in% names(table))
  expect_true(all(grepl(" - ", table$`Final birds in 2100 (95% interval)`,
    fixed = TRUE
  )))
  expect_match(differences_html, "percentage points", ignore.case = TRUE)
  expect_false(grepl("\\bpp\\b", differences_html, ignore.case = TRUE))
})

test_that("Gate G2 runs and saves a live future family through project events", {
  env <- source_investigate_app()
  live <- shiny::reactiveVal(investigate_ready_project())
  calls <- 0L
  runner <- function(...) {
    calls <<- calls + 1L
    investigate_test_runner(...)
  }

  shiny::testServer(env$investigate_server, args = list(
    project = shiny::reactive(live()), scenario_runner = runner
  ), {
    session$setInputs(
      threat_id = "predator_reinvasion",
      threat_choice = "low",
      intervention_id = "biosecurity_eradication",
      intervention_choice = "moderate",
      future_expected_outcome = "Rat return should lower abundance and raise risk.",
      future_mechanism_prediction = "Egg, chick and young-bird losses reduce recruitment.",
      future_partial_recovery = "The response should recover only part of the loss.",
      run_future = investigate_action_value(1L)
    )
    session$flushReact()

    event <- project_update_state()
    expect_true(event$ok)
    expect_identical(event$route, "future")
    expect_false(event$reused)
    expect_equal(calls, 3L)
    expect_identical(
      progress_state()$future,
      c(scenario = 3L, scenarios = 3L, completed = 1000L, total = 1000L)
    )
    expect_length(event$candidate$runs, length(live()$runs) + 3L)
    expect_length(event$candidate$observations, length(live()$observations) + 1L)

    live(event$candidate)
    session$flushReact()
    expect_s3_class(future_comparison(), "woodhen_run_family_comparison")
    expect_identical(future_comparison()$family_id, event$family_id)

    session$setInputs(
      future_threat_observation = "The rat-return future increased warning risk.",
      future_response_observation = "Renewed control recovered part of the loss.",
      future_caveat = "The joint recruitment effect is a teaching assumption.",
      save_future_notes = investigate_action_value(1L)
    )
    session$flushReact()
    note_event <- observation_update_state()
    expect_true(note_event$ok)
    expect_identical(note_event$route, "future")
    appended <- tail(note_event$candidate$observations, 1L)[[1L]]
    expect_match(appended$note, "Threat:")
    expect_match(appended$note, "Management:")
    expect_match(appended$note, "Caveat:")
    expect_identical(
      sort(appended$run_ids),
      sort(future_comparison()$table$run_id)
    )
  })
})

test_that("Gate G2 never presents or saves evidence for changed future controls", {
  env <- source_investigate_app()
  live <- shiny::reactiveVal(investigate_ready_project())

  shiny::testServer(env$investigate_server, args = list(
    project = shiny::reactive(live()),
    scenario_runner = investigate_test_runner
  ), {
    session$setInputs(
      threat_id = "predator_reinvasion",
      threat_choice = "low",
      intervention_id = "biosecurity_eradication",
      intervention_choice = "moderate",
      run_future = investigate_action_value(1L)
    )
    session$flushReact()
    event <- project_update_state()
    expect_true(event$ok)
    live(event$candidate)
    session$flushReact()
    expect_s3_class(future_comparison(), "woodhen_run_family_comparison")

    session$setInputs(
      threat_id = "increased_cyclone_pressure",
      threat_choice = "moderate",
      intervention_id = "emergency_response",
      intervention_choice = "moderate"
    )
    session$flushReact()
    expect_null(future_comparison())
    expect_identical(
      progress_state()$future,
      c(scenario = 0L, scenarios = 3L, completed = 0L, total = 1000L)
    )
    expect_match(status_state()[["future"]], "Settings changed", fixed = TRUE)

    session$setInputs(
      future_threat_observation = "Cyclones increased risk.",
      future_response_observation = "Response reduced cyclone effects.",
      save_future_notes = investigate_action_value(1L)
    )
    session$flushReact()
    expect_null(observation_update_state())
    expect_match(
      status_state()[["future"]],
      "Run all three comparable scenarios before saving",
      fixed = TRUE
    )
  })
})

test_that("Gate G1 never presents or saves evidence for changed sensitivity controls", {
  env <- source_investigate_app()
  family <- build_woodhen_sensitivity_family("K_sd", c(108, 0))
  completed <- rPVA:::woodhen_run_investigation_family_project(
    investigate_ready_project(),
    family,
    runner = investigate_test_runner,
    sample_trajectories = 3L
  )$project
  live <- shiny::reactiveVal(completed)

  shiny::testServer(env$investigate_server, args = list(
    project = shiny::reactive(live()),
    scenario_runner = investigate_test_runner
  ), {
    session$setInputs(
      factor_id = "K_sd",
      sensitivity_first_choice = "higher",
      sensitivity_second_choice = "lower",
      sensitivity_first_custom = 108,
      sensitivity_second_custom = 0
    )
    session$flushReact()
    expect_identical(selected_sensitivity_family_id(), family$family_id)
    expect_s3_class(sensitivity_comparison(), "woodhen_run_family_comparison")

    session$setInputs(
      factor_id = "env_sd",
      sensitivity_first_choice = "higher",
      sensitivity_second_choice = "lower",
      sensitivity_first_custom = 0.30,
      sensitivity_second_custom = 0
    )
    session$flushReact()
    expect_null(sensitivity_comparison())
    expect_identical(
      progress_state()$sensitivity,
      c(scenario = 0L, scenarios = 3L, completed = 0L, total = 1000L)
    )
    expect_match(status_state()[["sensitivity"]], "Settings changed", fixed = TRUE)

    session$setInputs(
      sensitivity_interpretation = "Variability changed warning risk.",
      sensitivity_caveat = "This is a bounded teaching comparison.",
      save_sensitivity_notes = investigate_action_value(1L)
    )
    session$flushReact()
    expect_null(observation_update_state())
    expect_match(
      status_state()[["sensitivity"]],
      "Run all three comparable scenarios before saving",
      fixed = TRUE
    )
  })
})
