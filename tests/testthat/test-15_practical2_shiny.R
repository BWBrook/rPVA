context("Practical 2 investigation shell")

practical2_app_dir <- function() {
  rPVA:::practical2_shiny_app_dir()
}

source_practical2_app <- function() {
  app_dir <- practical2_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)
  env
}

practical2_store_fixture <- function(env, title) {
  project <- rPVA::new_woodhen_project(title)
  snapshot <- rPVA:::woodhen_project_browser_snapshot(project)
  record <- env$project_store_record(
    project,
    snapshot,
    format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
    NULL
  )
  list(
    project = project,
    record = record,
    metadata = record[setdiff(names(record), "snapshot_json")]
  )
}

practical2_restore_envelope <- function(record, request_id) {
  list(
    contract_version = "woodhen-project-store-contract-v1",
    request_id = request_id,
    key = record$key,
    record = record
  )
}

practical2_status_envelope <- function(request_id, status, record) {
  list(
    contract_version = "woodhen-project-store-contract-v1",
    request_id = request_id,
    key = record$key,
    status = status,
    project_id = record$project_id,
    project_fingerprint = record$project_fingerprint,
    message = paste("Test status", status)
  )
}

practical2_action_button_value <- function(value) {
  structure(
    as.integer(value),
    class = c("shinyActionButtonValue", "integer")
  )
}

practical2_calibrate_runner <- function(
    scenario,
    seed = scenario$seed,
    sample_trajectories = 2L,
    progress = NULL
) {
  years <- as.integer(scenario$spec$years)
  reps <- as.integer(scenario$spec$reps)
  totals <- matrix(
    rep(seq.int(2 * sum(scenario$spec$n0), length.out = years + 1L), reps),
    nrow = years + 1L,
    ncol = reps
  )
  traj <- array(0, dim = c(years + 1L, length(scenario$spec$n0), reps))
  traj[, 1L, ] <- round(totals * 0.2)
  traj[, 2L, ] <- totals - traj[, 1L, ]
  normalized <- normalize_pva_spec(scenario$spec, stasis = NULL)
  if (!is.null(progress)) {
    progress(500L, reps)
    progress(reps, reps)
  }
  result <- list(
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
      Nend = as.numeric(totals[years + 1L, ]),
      traj = traj,
      sr_traj = matrix(0.5, nrow = years + 1L, ncol = reps),
      F_traj = matrix(0, nrow = years + 1L, ncol = reps),
      LE_traj = matrix(0, nrow = years + 1L, ncol = reps)
    )
  )
  compact_woodhen_run(result, scenario, sample_trajectories = sample_trajectories)
}

test_that("installed Practical 2 shell contains its implemented module assets", {
  app_dir <- practical2_app_dir()
  expected <- c(
    "README.md",
    "app.R",
    "content/help-calibrate.md",
    "content/help-compare.md",
    "content/help-evidence.md",
    "content/help-investigate.md",
    "content/help-projects.md",
    "content/help-woodhen-background.md",
    "content/report-guidance.md",
    "content/scenarios/01-no-intervention.md",
    "content/scenarios/02-pig-control.md",
    "content/scenarios/03-captive-pig.md",
    "content/scenarios/04-rodent-eradication.md",
    "content/scenarios/05-future-comparison.md",
    "content/start.md",
    "content/ways-to-deepen.md",
    "content/woodhen-research.md",
    "modules/mod_assessment.R",
    "modules/mod_calibrate.R",
    "modules/mod_compare.R",
    "modules/mod_evidence.R",
    "modules/mod_investigate.R",
    "modules/mod_start.R",
    "project_helpers.R",
    "ui_helpers.R",
    "www/img/lord-howe-island-nasa.webp",
    "www/project-store.js",
    "www/styles.css"
  )

  expect_true(dir.exists(app_dir))
  expect_true(all(file.exists(file.path(app_dir, expected))))
})

test_that("helpers and implemented modules source from the installed app directory", {
  env <- source_practical2_app()

  expect_true(all(vapply(
    c(
      "start_ui", "start_server", "calibrate_ui", "calibrate_server",
      "investigate_ui", "investigate_server",
      "compare_ui", "compare_server",
      "evidence_ui", "evidence_server",
      "assessment_ui", "assessment_server",
      "pending_tab_ui", "project_help_modal",
      "project_store_key", "project_store_record", "make_practical2_server"
    ),
    exists,
    logical(1),
    envir = env,
    inherits = FALSE
  )))
  expect_s3_class(env$ui, "shiny.tag.list")
})

test_that("cold namespace-only app supports Create, Import, and restore helpers", {
  testthat::skip_if_not_installed("callr")
  project_root <- normalizePath(".", winslash = "/", mustWork = TRUE)

  result <- callr::r(function(project_root) {
    pkgload::load_all(
      project_root,
      attach = FALSE,
      export_all = FALSE,
      helpers = FALSE,
      attach_testthat = FALSE,
      quiet = TRUE
    )
    stopifnot(!"package:rPVA" %in% search())
    app_dir <- rPVA:::practical2_shiny_app_dir()
    old <- setwd(app_dir)
    on.exit(setwd(old), add = TRUE)
    env <- new.env(parent = globalenv())
    sys.source("app.R", envir = env)

    portable_path <- tempfile(fileext = ".zip")
    on.exit(unlink(portable_path), add = TRUE)
    portable_project <- rPVA::new_woodhen_project("Cold import")
    rPVA::write_woodhen_project_package(portable_project, portable_path)
    neutral <- env$status_value("No active project yet.")
    captured <- new.env(parent = emptyenv())

    shiny::testServer(env$start_server, args = list(
      project = function() NULL,
      inventory = function() list(),
      browser_status = function() neutral,
      portable_status = function() neutral,
      dirty_status = function() neutral
    ), {
      session$setInputs(
        project_title = "Cold create",
        owner_label = "Study group",
        create_project = 1
      )
      captured$created <- create_event()
      session$setInputs(import_project = list(
        name = "cold-import.zip",
        size = file.info(portable_path)$size,
        type = "application/zip",
        datapath = portable_path
      ))
      captured$imported <- import_event()
    })

    stopifnot(isTRUE(captured$created$ok), isTRUE(captured$imported$ok))
    snapshot <- rPVA:::woodhen_project_browser_snapshot(captured$created$candidate)
    record <- env$project_store_record(
      captured$created$candidate,
      snapshot,
      "2026-07-22T11:00:00Z",
      NULL
    )
    envelope <- list(
      contract_version = env$project_store_contract_version(),
      request_id = "restore-cold",
      key = record$key,
      record = record
    )
    restored <- env$validate_project_store_restore(envelope, "restore-cold")

    list(
      package_attached = "package:rPVA" %in% search(),
      created_id = captured$created$candidate$project_id,
      imported_id = captured$imported$candidate$project_id,
      portable_id = portable_project$project_id,
      restored_id = restored$project_id
    )
  }, args = list(project_root))

  expect_false(result$package_attached)
  expect_match(result$created_id, "^woodhen_project_")
  expect_identical(result$imported_id, result$portable_id)
  expect_identical(result$restored_id, result$created_id)
})

test_that("installed Practical 2 app constructs without repository artefacts", {
  testthat::skip_if_not_installed("shiny")

  app_dir <- practical2_app_dir()
  before <- list.files(".", all.files = TRUE, recursive = FALSE)
  app <- shiny::shinyAppDir(app_dir)
  after <- list.files(".", all.files = TRUE, recursive = FALSE)

  expect_s3_class(app, "shiny.appobj")
  expect_equal(after, before)
  expect_no_local_artifacts()
})

test_that("shell exposes exactly six visible stable tab values", {
  env <- source_practical2_app()
  html <- paste(as.character(env$ui), collapse = "\n")
  tab_values <- regmatches(
    html,
    gregexpr(
      'data-value="[^"]+"',
      html
    )
  )[[1L]]
  tab_values <- gsub('^data-value="|"$', "", tab_values)

  expect_identical(
    unique(tab_values),
    c(
      "start", "calibrate", "investigate", "compare", "evidence",
      "assessment"
    )
  )
  expect_identical(
    as.integer(table(factor(tab_values, levels = unique(tab_values)))),
    rep(2L, 6L)
  )
  expect_match(html, ">Assessment Task<", fixed = TRUE)
  expect_match(html, 'id="project_save_bar"', fixed = TRUE)
})

test_that("root handles valid and invalid Assessment navigation events", {
  env <- source_practical2_app()
  navigation_event <- shiny::reactiveVal(NULL)
  selected_tabs <- character()
  notifications <- list()

  env$assessment_server <- function(...) {
    list(
      navigate = shiny::reactive(navigation_event()),
      summary = shiny::reactive(NULL)
    )
  }
  env$updateNavbarPage <- function(session, inputId, selected = NULL, ...) {
    selected_tabs <<- c(selected_tabs, selected)
  }
  env$showNotification <- function(ui, type = "default", ...) {
    notifications[[length(notifications) + 1L]] <<- list(
      message = as.character(ui),
      type = type
    )
  }

  shiny::testServer(env$make_practical2_server(), {
    navigation_event(list(section = "compare", event_id = 1L))
    session$flushReact()
    expect_identical(selected_tabs, "compare")
    expect_length(notifications, 0L)

    navigation_event(list(section = "assessment", event_id = 2L))
    session$flushReact()
    expect_identical(selected_tabs, "compare")
    expect_length(notifications, 1L)
    expect_identical(
      notifications[[1L]],
      list(
        message = "That section could not be opened.",
        type = "warning"
      )
    )
  })
})

test_that("Start controls and statuses are namespaced and accessible", {
  env <- source_practical2_app()
  html <- paste(as.character(env$start_ui("start")), collapse = "\n")

  for (id in c(
    "start-project_title", "start-owner_label", "start-create_project",
    "start-resume_key", "start-resume_project", "start-import_project",
    "start-download_project", "start-open_project_help",
    "start-project_browser_status", "start-project_portable_status",
    "start-project_dirty_status"
  )) {
    expect_match(html, paste0('id="', id, '"'), fixed = TRUE)
  }
  expect_match(html, 'alt="NASA astronaut photograph of Lord Howe Island', fixed = TRUE)
  expect_match(html, 'src="img/lord-howe-woodhen-family.jpg"', fixed = TRUE)
  expect_match(html, 'alt="Lord Howe Island woodhen with two chicks"', fixed = TRUE)
  expect_match(html, "View original island photograph", fixed = TRUE)
  expect_match(html, "NPWS / Liam Murphy", fixed = TRUE)
  expect_false(grepl("public domain", html, ignore.case = TRUE))
  expect_match(html, 'id="start-open_woodhen_background"', fixed = TRUE)
  expect_match(html, 'aria-live="polite"', fixed = TRUE)
  expect_match(html, "Autosave in this browser", fixed = TRUE)
  expect_match(html, "Project copy", fixed = TRUE)
  expect_match(html, "Unsaved changes", fixed = TRUE)
})

test_that("Start narrative states the adviser, two-phase, core-route, and extension contract", {
  app_dir <- practical2_app_dir()
  start_text <- paste(readLines(file.path(app_dir, "content", "start.md"), warn = FALSE), collapse = "\n")
  help_text <- paste(readLines(file.path(app_dir, "content", "help-projects.md"), warn = FALSE), collapse = "\n")

  expect_match(start_text, "present-day conservation adviser", ignore.case = TRUE)
  expect_match(start_text, "found nowhere else", ignore.case = TRUE)
  expect_match(start_text, "more than 1,600", ignore.case = TRUE)
  expect_match(start_text, "conservation recovery", ignore.case = TRUE)
  expect_match(start_text, "Phase 1")
  expect_match(start_text, "Phase 2")
  expect_match(start_text, "three-hour core route", ignore.case = TRUE)
  expect_match(start_text, "essential foundation", ignore.case = TRUE)
  expect_match(start_text, "independent work afterward", ignore.case = TRUE)
  expect_match(start_text, "Ways to deepen your investigation", fixed = TRUE)
  expect_false(grepl("pass-level|grade|grading|score|scoring", start_text, ignore.case = TRUE))
  expect_false(grepl("local-first", paste(start_text, help_text), ignore.case = TRUE))

  expect_match(help_text, "autosaved in this browser", ignore.case = TRUE)
  expect_match(help_text, "completed run or saved note", ignore.case = TRUE)
  expect_match(help_text, "Save in this browser", fixed = TRUE)
  expect_match(help_text, "does not download", ignore.case = TRUE)
  expect_match(help_text, "downloadable project copy", ignore.case = TRUE)
  expect_match(help_text, "another computer", ignore.case = TRUE)
  expect_false(grepl("untrusted data|schema|fingerprint|web origin", help_text, ignore.case = TRUE))
})

test_that("manual browser save queues the current authoritative project", {
  env <- source_practical2_app()

  shiny::testServer(env$make_practical2_server(), {
    session$setInputs(
      `start-create_project` = practical2_action_button_value(0),
      `start-resume_project` = practical2_action_button_value(0)
    )
    session$flushReact()
    session$setInputs(
      `start-project_title` = "Manual save contract",
      `start-create_project` = practical2_action_button_value(1)
    )
    session$flushReact()
    candidate <- project()
    requests_before <- length(pending_requests())

    session$setInputs(save_project = practical2_action_button_value(1))
    session$flushReact()

    expect_identical(length(pending_requests()), requests_before + 1L)
    latest <- pending_requests()[[tail(names(pending_requests()), 1L)]]
    expect_identical(latest$kind, "save")
    expect_identical(latest$source, "manual")
    expect_identical(
      latest$record$project_fingerprint,
      candidate$project_fingerprint
    )
    expect_identical(browser_status()$state, "pending")
    expect_true(env$should_confirm_manual_browser_save(
      latest,
      list(status = "saved")
    ))
    expect_false(env$should_confirm_manual_browser_save(
      within(latest, source <- "automatic"),
      list(status = "saved")
    ))
  })
})

test_that("Compare and the Evidence Portfolio replace all placeholder bands", {
  env <- source_practical2_app()
  html <- paste(as.character(env$ui), collapse = "\n")

  expect_false(grepl('class="pending-tab-band"', html, fixed = TRUE))
  expect_match(html, "Build one defensible comparison", fixed = TRUE)
  expect_match(html, "Your evidence portfolio", fixed = TRUE)
  expect_false(grepl("Design probe only", html, fixed = TRUE))
  expect_true(all(file.exists(file.path(
    practical2_app_dir(), "modules",
    c("mod_investigate.R", "mod_compare.R", "mod_evidence.R")
  ))))
})

test_that("root server owns replacement and module exposes reactive events", {
  app_dir <- practical2_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")
  module_text <- paste(readLines(file.path(app_dir, "modules", "mod_start.R"), warn = FALSE), collapse = "\n")
  calibrate_text <- paste(readLines(file.path(app_dir, "modules", "mod_calibrate.R"), warn = FALSE), collapse = "\n")
  investigate_text <- paste(readLines(file.path(app_dir, "modules", "mod_investigate.R"), warn = FALSE), collapse = "\n")
  compare_text <- paste(readLines(file.path(app_dir, "modules", "mod_compare.R"), warn = FALSE), collapse = "\n")

  expect_match(app_text, "project <- reactiveVal(NULL)", fixed = TRUE)
  expect_match(app_text, "rPVA::validate_woodhen_project(candidate)", fixed = TRUE)
  expect_match(app_text, "project(candidate)", fixed = TRUE)
  expect_match(app_text, "events <- start_server", fixed = TRUE)
  expect_match(app_text, "calibrate_events <- calibrate_server", fixed = TRUE)
  expect_match(app_text, "observeEvent(calibrate_events$project_update()", fixed = TRUE)
  expect_match(app_text, "investigate_events <- investigate_server", fixed = TRUE)
  expect_match(app_text, "observeEvent(investigate_events$project_update()", fixed = TRUE)
  expect_match(app_text, "observeEvent(investigate_events$navigate()", fixed = TRUE)
  expect_match(app_text, "compare_events <- compare_server", fixed = TRUE)
  expect_match(module_text, "moduleServer(id", fixed = TRUE)
  expect_match(module_text, "create_event <- eventReactive", fixed = TRUE)
  expect_match(module_text, "resume_event <- eventReactive", fixed = TRUE)
  expect_match(module_text, "import_event <- eventReactive", fixed = TRUE)
  expect_match(module_text, "output$download_project <- downloadHandler", fixed = TRUE)
  expect_match(module_text, "rPVA::new_woodhen_project(", fixed = TRUE)
  expect_match(module_text, "rPVA::read_woodhen_project_package(upload$datapath)", fixed = TRUE)
  expect_match(module_text, "rPVA::write_woodhen_project_package(candidate, file)", fixed = TRUE)
  expect_match(calibrate_text, "moduleServer(id", fixed = TRUE)
  expect_match(calibrate_text, "project_update", fixed = TRUE)
  expect_match(investigate_text, "moduleServer(id", fixed = TRUE)
  expect_match(investigate_text, "project_update", fixed = TRUE)
  expect_match(compare_text, "moduleServer(id", fixed = TRUE)
  expect_false(grepl(
    "assign\\(",
    paste(app_text, module_text, calibrate_text, investigate_text, compare_text)
  ))
})

test_that("failed project candidates preserve the live project", {
  env <- source_practical2_app()
  original <- new_woodhen_project("Live project", now = as.POSIXct("2026-07-22 09:00:00", tz = "UTC"))
  live <- shiny::reactiveVal(original)
  invalid <- original
  invalid$project_fingerprint <- paste(rep("0", 64), collapse = "")

  expect_error(
    shiny::isolate(env$replace_live_project(live, invalid)),
    "fingerprint"
  )
  expect_identical(shiny::isolate(live()), original)
})

test_that("Start returns validated create and failed import events to the root", {
  env <- source_practical2_app()
  invalid_package <- tempfile(fileext = ".zip")
  valid_package <- tempfile(fileext = ".zip")
  writeLines("not a portable project", invalid_package)
  valid_project <- new_woodhen_project("Imported advice")
  write_woodhen_project_package(valid_project, valid_package)
  on.exit(unlink(c(invalid_package, valid_package)), add = TRUE)

  neutral_status <- env$status_value("No active project yet.")
  shiny::testServer(env$start_server, args = list(
    project = function() NULL,
    inventory = function() list(),
    browser_status = function() neutral_status,
    portable_status = function() neutral_status,
    dirty_status = function() neutral_status
  ), {
    session$setInputs(
      project_title = "Cyclone advice",
      owner_label = "Study group",
      create_project = 1
    )
    create_result <- create_event()
    expect_true(create_result$ok)
    expect_s3_class(create_result$candidate, "woodhen_project")
    expect_identical(create_result$candidate$title, "Cyclone advice")

    session$setInputs(import_project = list(
      name = "invalid.zip",
      size = file.info(invalid_package)$size,
      type = "application/zip",
      datapath = invalid_package
    ))
    import_result <- import_event()
    expect_false(import_result$ok)
    expect_match(import_result$message, "ZIP|archive|portable")

    session$setInputs(import_project = list(
      name = "valid.zip",
      size = file.info(valid_package)$size,
      type = "application/zip",
      datapath = valid_package
    ))
    import_result <- import_event()
    expect_true(import_result$ok)
    expect_s3_class(import_result$candidate, "woodhen_project")
    expect_identical(import_result$candidate$project_id, valid_project$project_id)
  })
})

test_that("Start mirrors the active project identity into its visible fields", {
  env <- source_practical2_app()
  live <- shiny::reactiveVal(NULL)
  sent <- new.env(parent = emptyenv())
  env$updateTextInput <- function(session, inputId, label = NULL,
                                  value = NULL, placeholder = NULL) {
    sent[[inputId]] <- value
    invisible(NULL)
  }
  neutral_status <- env$status_value("No active project yet.")

  shiny::testServer(env$start_server, args = list(
    project = shiny::reactive(live()),
    inventory = function() list(),
    browser_status = function() neutral_status,
    portable_status = function() neutral_status,
    dirty_status = function() neutral_status
  ), {
    live(new_woodhen_project(
      "Imported Woodhen advice",
      owner_label = "Study group"
    ))
    session$flushReact()
    expect_identical(sent$project_title, "Imported Woodhen advice")
    expect_identical(sent$owner_label, "Study group")

    live(new_woodhen_project())
    session$flushReact()
    expect_identical(sent$project_title, "")
    expect_identical(sent$owner_label, "")
  })
})

test_that("the first root Create click activates a live project", {
  env <- source_practical2_app()

  shiny::testServer(env$make_practical2_server(), {
    session$setInputs(
      `start-create_project` = practical2_action_button_value(0),
      `start-resume_project` = practical2_action_button_value(0)
    )
    session$flushReact()
    expect_null(project())

    session$setInputs(
      `start-project_title` = "First click create",
      `start-create_project` = practical2_action_button_value(1)
    )
    session$flushReact()

    expect_s3_class(project(), "woodhen_project")
    expect_identical(project()$title, "First click create")
  })
})

test_that("root activates Calibrate updates and queues authoritative autosave", {
  env <- source_practical2_app()

  shiny::testServer(env$make_practical2_server(
    calibrate_scenario_runner = practical2_calibrate_runner
  ), {
    session$setInputs(
      `start-create_project` = practical2_action_button_value(0),
      `start-resume_project` = practical2_action_button_value(0)
    )
    session$flushReact()
    session$setInputs(
      `start-project_title` = "Root Calibrate integration",
      `start-create_project` = practical2_action_button_value(1)
    )
    session$flushReact()
    before <- project()
    requests_before <- length(pending_requests())

    session$setInputs(
      `calibrate-run_01_no_mgmt` = practical2_action_button_value(1)
    )
    session$flushReact()

    activated <- project()
    expect_silent(validate_woodhen_project(activated))
    expect_identical(activated$project_id, before$project_id)
    expect_identical(
      vapply(activated$runs, `[[`, character(1), "scenario_id"),
      "01_no_mgmt"
    )
    expect_false(identical(activated$project_fingerprint, before$project_fingerprint))
    expect_identical(dirty_status()$state, "warning")
    expect_identical(browser_status()$state, "pending")
    expect_identical(length(pending_requests()), requests_before + 1L)
    latest <- pending_requests()[[tail(names(pending_requests()), 1L)]]
    expect_identical(latest$kind, "save")
    expect_identical(latest$record$project_id, activated$project_id)
    expect_identical(latest$record$project_fingerprint, activated$project_fingerprint)
  })
})

test_that("root rejects a stale Investigate event without activation side effects", {
  env <- source_practical2_app()
  base <- rPVA:::run_woodhen_reference_project(
    new_woodhen_project("Investigate event base"),
    "05_future_baseline",
    runner = practical2_calibrate_runner,
    sample_trajectories = 2L
  )$project
  family <- build_woodhen_sensitivity_family("K", c(350, 250))
  action <- rPVA:::woodhen_run_investigation_family_project(
    base,
    family,
    runner = practical2_calibrate_runner,
    sample_trajectories = 2L
  )
  event <- list(
    ok = TRUE,
    candidate = action$project,
    family_id = family$family_id,
    route = "sensitivity",
    reused = FALSE,
    message = "Complete family ready for project activation.",
    base_project_fingerprint = base$project_fingerprint,
    event_id = 101L
  )

  expect_identical(
    env$validate_investigate_project_update_event(event, base),
    action$project
  )
  expect_error(
    env$validate_investigate_project_update_event(
      c(event, list(unexpected = "field")), base
    ),
    "exactly"
  )
  expect_error(
    env$validate_investigate_project_update_event(
      event[names(event) != "base_project_fingerprint"], base
    ),
    "exactly"
  )

  replacement <- new_woodhen_project("Replacement before activation")
  expect_error(
    env$validate_investigate_project_update_event(event, replacement),
    "active project changed"
  )

  shiny::testServer(env$make_practical2_server(), {
    project(replacement)
    session$flushReact()
    before <- list(
      project = project(),
      dirty = dirty_status(),
      browser = browser_status(),
      requests = pending_requests(),
      request_counter = request_counter(),
      saved = saved_fingerprint(),
      portable = portable_fingerprint()
    )

    expect_false(shiny::isolate(activate_investigate_update(event)))
    expect_identical(project(), before$project)
    expect_identical(dirty_status(), before$dirty)
    expect_identical(browser_status(), before$browser)
    expect_identical(pending_requests(), before$requests)
    expect_identical(request_counter(), before$request_counter)
    expect_identical(saved_fingerprint(), before$saved)
    expect_identical(portable_fingerprint(), before$portable)
  })
})

test_that("root accepts only one linked Investigate observation append", {
  env <- source_practical2_app()
  base <- rPVA:::run_woodhen_reference_project(
    new_woodhen_project("Investigate observation base"),
    "05_future_baseline",
    runner = practical2_calibrate_runner,
    sample_trajectories = 2L
  )$project
  family <- build_woodhen_sensitivity_family("K", c(225, 160))
  current <- rPVA:::woodhen_run_investigation_family_project(
    base,
    family,
    runner = practical2_calibrate_runner,
    sample_trajectories = 2L
  )$project
  run_ids <- vapply(current$runs[vapply(current$runs, function(run) {
    identical(run$family_id, family$family_id)
  }, logical(1))], `[[`, character(1), "run_id")
  candidate <- add_woodhen_observation(
    current,
    list(
      title = "Sensitivity result observation",
      note = "Interpretation: Habitat capacity changed the model response.",
      run_ids = run_ids
    )
  )
  event <- list(
    ok = TRUE,
    candidate = candidate,
    family_id = family$family_id,
    route = "sensitivity",
    message = "Result observation saved.",
    base_project_fingerprint = current$project_fingerprint,
    event_id = 102L
  )

  expect_identical(
    env$validate_investigate_observation_update_event(event, current),
    candidate
  )
  changed <- candidate
  changed$title <- "Unexpected project rewrite"
  changed$project_fingerprint <- woodhen_project_fingerprint(changed)
  changed_event <- event
  changed_event$candidate <- changed
  expect_error(
    env$validate_investigate_observation_update_event(changed_event, current),
    "only append one observation"
  )
  stale_event <- event
  stale_event$base_project_fingerprint <- paste(rep("0", 64), collapse = "")
  expect_error(
    env$validate_investigate_observation_update_event(stale_event, current),
    "active project changed"
  )
})

test_that("the first root Resume click requests browser restoration", {
  env <- source_practical2_app()
  stored <- practical2_store_fixture(env, "First click resume")

  shiny::testServer(env$make_practical2_server(), {
    session$setInputs(
      `start-create_project` = practical2_action_button_value(0),
      `start-resume_project` = practical2_action_button_value(0)
    )
    session$flushReact()
    inventory(list(stored$metadata))
    session$setInputs(`start-resume_key` = stored$record$key)
    session$flushReact()
    expect_null(pending_restore())

    session$setInputs(
      `start-resume_project` = practical2_action_button_value(1)
    )
    session$flushReact()

    pending <- pending_restore()
    expect_match(pending$request_id, "^restore-")
    expect_identical(pending$key, stored$record$key)
    expect_identical(pending$project_id, stored$record$project_id)
    expect_identical(
      pending$project_fingerprint,
      stored$record$project_fingerprint
    )
    expect_match(browser_status()$value, "Restoring selected project", fixed = TRUE)
  })
})

test_that("project download and restore outcomes remain visible in the page status", {
  app_dir <- practical2_app_dir()
  app_text <- paste(
    readLines(file.path(app_dir, "app.R"), warn = FALSE),
    collapse = "\n"
  )

  expect_match(app_text, "Restoring selected project", fixed = TRUE)
  expect_match(app_text, "Browser project was not restored", fixed = TRUE)
  expect_match(app_text, "Project copy downloaded", fixed = TRUE)
  expect_match(app_text, "browser's Downloads folder", fixed = TRUE)
})

test_that("project restore summaries make recovered content explicit", {
  env <- source_practical2_app()

  expect_identical(
    env$project_content_summary(list(
      runs = list(list(), list()),
      observations = list(list()),
      evidence_items = list(list(), list(), list())
    )),
    "2 completed runs, 1 saved observation, and 3 portfolio items"
  )
  expect_identical(
    env$project_content_summary(list(
      runs = list(),
      observations = list(),
      evidence_items = list()
    )),
    "0 completed runs, 0 saved observations, and 0 portfolio items"
  )
})

test_that("only the latest Resume response may replace the live project", {
  env <- source_practical2_app()
  first <- practical2_store_fixture(env, "Resume A")
  second <- practical2_store_fixture(env, "Resume B")

  shiny::testServer(env$make_practical2_server(), {
    session$setInputs(
      `start-resume_project` = practical2_action_button_value(0),
      `start-create_project` = practical2_action_button_value(0)
    )
    session$flushReact()
    inventory(list(first$metadata, second$metadata))

    session$setInputs(
      `start-resume_key` = first$record$key,
      `start-resume_project` = 1
    )
    session$flushReact()
    request_a <- pending_restore()

    session$setInputs(
      `start-resume_key` = second$record$key,
      `start-resume_project` = 2
    )
    session$flushReact()
    request_b <- pending_restore()
    expect_false(identical(request_a$request_id, request_b$request_id))

    session$setInputs(project_store_restore = practical2_restore_envelope(
      first$record,
      request_a$request_id
    ))
    session$flushReact()
    expect_null(project())
    expect_identical(pending_restore(), request_b)

    session$setInputs(project_store_restore = practical2_restore_envelope(
      second$record,
      request_b$request_id
    ))
    session$flushReact()
    expect_identical(project()$project_id, second$project$project_id)
    expect_null(pending_restore())
  })
})

test_that("Create and Import invalidate a pending Resume response", {
  env <- source_practical2_app()
  resumed <- practical2_store_fixture(env, "Late resume")
  import_path <- tempfile(fileext = ".zip")
  imported <- rPVA::new_woodhen_project("Explicit import")
  rPVA::write_woodhen_project_package(imported, import_path)
  on.exit(unlink(import_path), add = TRUE)

  shiny::testServer(env$make_practical2_server(), {
    session$setInputs(
      `start-resume_project` = practical2_action_button_value(0),
      `start-create_project` = practical2_action_button_value(0)
    )
    session$flushReact()
    inventory(list(resumed$metadata))
    session$setInputs(
      `start-resume_key` = resumed$record$key,
      `start-resume_project` = 1
    )
    session$flushReact()
    pending <- pending_restore()

    session$setInputs(
      `start-project_title` = "Explicit create",
      `start-create_project` = 1
    )
    session$flushReact()
    created <- project()
    expect_identical(created$title, "Explicit create")
    expect_null(pending_restore())

    session$setInputs(project_store_restore = practical2_restore_envelope(
      resumed$record,
      pending$request_id
    ))
    session$flushReact()
    expect_identical(project(), created)
  })

  shiny::testServer(env$make_practical2_server(), {
    session$setInputs(
      `start-resume_project` = practical2_action_button_value(0),
      `start-create_project` = practical2_action_button_value(0)
    )
    session$flushReact()
    inventory(list(resumed$metadata))
    session$setInputs(
      `start-resume_key` = resumed$record$key,
      `start-resume_project` = 1
    )
    session$flushReact()
    pending <- pending_restore()

    session$setInputs(`start-import_project` = list(
      name = "explicit-import.zip",
      size = file.info(import_path)$size,
      type = "application/zip",
      datapath = import_path
    ))
    session$flushReact()
    explicit_import <- project()
    expect_identical(explicit_import$project_id, imported$project_id)
    expect_null(pending_restore())

    session$setInputs(project_store_restore = practical2_restore_envelope(
      resumed$record,
      pending$request_id
    ))
    session$flushReact()
    expect_identical(project(), explicit_import)
  })
})

test_that("invalid storage acknowledgements do not consume pending requests", {
  env <- source_practical2_app()
  current <- practical2_store_fixture(env, "Save current")
  other <- practical2_store_fixture(env, "Save other")

  shiny::testServer(env$make_practical2_server(), {
    project(current$project)
    request_id <- "save-91"
    track_request(request_id, list(
      request_id = request_id,
      kind = "save",
      record = current$record
    ))

    session$setInputs(project_store_status = practical2_status_envelope(
      request_id,
      "portable_marked",
      current$record
    ))
    session$flushReact()
    expect_false(is.null(pending_requests()[[request_id]]))
    expect_null(saved_fingerprint())

    session$setInputs(project_store_status = practical2_status_envelope(
      request_id,
      "saved",
      other$record
    ))
    session$flushReact()
    expect_false(is.null(pending_requests()[[request_id]]))
    expect_null(saved_fingerprint())

    session$setInputs(project_store_status = practical2_status_envelope(
      request_id,
      "saved",
      current$record
    ))
    session$flushReact()
    expect_null(pending_requests()[[request_id]])
    expect_identical(saved_fingerprint(), current$project$project_fingerprint)
  })
})

test_that("portable storage failure does not alter browser autosave state", {
  env <- source_practical2_app()
  current <- practical2_store_fixture(env, "Portable current")

  shiny::testServer(env$make_practical2_server(), {
    project(current$project)
    saved_fingerprint(current$project$project_fingerprint)
    browser_status(env$status_value("Autosaved in this browser.", "current", "circle-check"))
    browser_before <- browser_status()
    request_id <- "portable-92"
    track_request(request_id, list(
      request_id = request_id,
      kind = "portable",
      record = list(
        key = current$record$key,
        project_id = current$record$project_id,
        project_fingerprint = current$record$project_fingerprint
      )
    ))

    session$setInputs(project_store_status = practical2_status_envelope(
      request_id,
      "portable_error",
      current$record
    ))
    session$flushReact()
    expect_null(pending_requests()[[request_id]])
    expect_identical(saved_fingerprint(), current$project$project_fingerprint)
    expect_identical(browser_status(), browser_before)
    expect_match(portable_status()$value, "download requested", ignore.case = TRUE)
  })
})

practical2_portfolio_project <- function() {
  family <- build_woodhen_sensitivity_family("K", c(500, 150), seed = 123L)
  project <- new_woodhen_project("Portfolio transaction")
  for (scenario in family$scenarios) {
    project <- add_woodhen_scenario(project, scenario)
    project <- add_woodhen_run(
      project,
      practical2_calibrate_runner(scenario, sample_trajectories = 2L)
    )
  }
  project
}

practical2_add_from_project_fixture <- function() {
  project <- practical2_portfolio_project()
  investigation_run_ids <- vapply(project$runs, `[[`, character(1), "run_id")
  reference <- rPVA:::run_woodhen_reference_project(
    project,
    "04_rodent_eradication",
    runner = practical2_calibrate_runner,
    sample_trajectories = 2L
  )
  project <- reference$project
  reference_run_id <- reference$run$run_id
  project <- add_woodhen_observation(project, list(
    title = "Rodent eradication interpretation",
    note = "The short recovery check is broadly consistent with survey evidence.",
    run_ids = reference_run_id
  ))
  calibrate_observation_id <- tail(project$observations, 1L)[[1L]]$observation_id
  project <- add_woodhen_observation(project, list(
    title = "Sensitivity result observation",
    note = "Lower breeding capacity increased warning risk.",
    run_ids = investigation_run_ids
  ))
  investigate_observation_id <- tail(project$observations, 1L)[[1L]]$observation_id
  list(
    project = project,
    reference_run_id = reference_run_id,
    investigation_run_ids = investigation_run_ids,
    calibrate_observation_id = calibrate_observation_id,
    investigate_observation_id = investigate_observation_id
  )
}

practical2_add_from_project_event <- function(project,
                                              requests,
                                              event_id = 1L) {
  list(
    action = "add_from_project",
    requests = requests,
    base_project_fingerprint = project$project_fingerprint,
    event_id = event_id,
    message = "Project evidence added to the portfolio."
  )
}

test_that("root references an existing project observation without copying it", {
  env <- source_practical2_app()
  fixture <- practical2_add_from_project_fixture()
  project <- fixture$project
  before <- project$observations
  request <- list(
    source_run_ids = fixture$reference_run_id,
    observation_id = fixture$calibrate_observation_id,
    view_id = "saved_observation",
    title = "Rodent eradication interpretation"
  )
  event <- practical2_add_from_project_event(project, list(request))

  expect_named(
    event,
    c(
      "action", "requests", "base_project_fingerprint",
      "event_id", "message"
    )
  )
  expect_named(
    event$requests[[1L]],
    c("source_run_ids", "observation_id", "view_id", "title")
  )
  expect_false(any(c("note", "source_family_id", "kind") %in% names(
    event$requests[[1L]]
  )))

  candidate <- NULL
  expect_no_error(
    candidate <- env$apply_evidence_portfolio_event(
      event,
      project,
      now = as.POSIXct("2026-07-25 06:00:00", tz = "UTC")
    )
  )
  if (is.null(candidate)) return()

  expect_identical(candidate$observations, before)
  expect_length(candidate$evidence_items, 1L)
  expect_identical(candidate$evidence_items[[1L]]$kind, "observation")
  expect_identical(
    candidate$evidence_items[[1L]]$observation_id,
    fixture$calibrate_observation_id
  )
  expect_identical(
    candidate$evidence_items[[1L]]$source_run_ids,
    fixture$reference_run_id
  )
})

test_that("root adds a reference result set atomically and idempotently", {
  env <- source_practical2_app()
  fixture <- practical2_add_from_project_fixture()
  project <- fixture$project
  views <- c(
    "calibration_trajectory", "calibration_risk",
    "calibration_timing", "calibration_summary"
  )
  titles <- c(
    "Rodent eradication - population trajectory",
    "Rodent eradication - extinction and warning risk",
    "Rodent eradication - extinction timing",
    "Rodent eradication - result summary"
  )
  requests <- lapply(seq_along(views), function(index) list(
    source_run_ids = fixture$reference_run_id,
    observation_id = NULL,
    view_id = views[[index]],
    title = titles[[index]]
  ))
  event <- practical2_add_from_project_event(project, requests)
  now <- as.POSIXct("2026-07-25 06:00:00", tz = "UTC")

  first <- NULL
  expect_no_error(
    first <- env$apply_evidence_portfolio_event(event, project, now = now)
  )
  if (is.null(first)) return()

  expect_identical(
    vapply(first$evidence_items, `[[`, character(1), "view_id"),
    views
  )
  expect_identical(
    vapply(first$evidence_items, `[[`, character(1), "kind"),
    c("plot", "plot", "plot", "table")
  )
  expect_true(all(vapply(first$evidence_items, function(item) {
    identical(item$source_run_ids, fixture$reference_run_id)
  }, logical(1))))

  repeated <- practical2_add_from_project_event(first, requests, event_id = 2L)
  second <- env$apply_evidence_portfolio_event(
    repeated,
    first,
    now = now + 60
  )
  expect_identical(second, first)
})

test_that("root rejects stale or mismatched Add from project requests", {
  env <- source_practical2_app()
  fixture <- practical2_add_from_project_fixture()
  project <- fixture$project
  valid <- list(
    source_run_ids = fixture$reference_run_id,
    observation_id = fixture$calibrate_observation_id,
    view_id = "saved_observation",
    title = "Rodent eradication interpretation"
  )

  stale <- practical2_add_from_project_event(project, list(valid))
  stale$base_project_fingerprint <- paste(rep("0", 64), collapse = "")
  expect_error(
    env$apply_evidence_portfolio_event(stale, project),
    "changed"
  )

  mismatched <- valid
  mismatched$source_run_ids <- fixture$investigation_run_ids
  expect_error(
    env$apply_evidence_portfolio_event(
      practical2_add_from_project_event(project, list(mismatched)),
      project
    ),
    "observation|linked|runs",
    ignore.case = TRUE
  )

  mixed_family <- valid
  mixed_family$observation_id <- NULL
  mixed_family$view_id <- "calibration_summary"
  mixed_family$title <- "Mixed result summary"
  mixed_family$source_run_ids <- c(
    fixture$reference_run_id,
    fixture$investigation_run_ids[[1L]]
  )
  expect_error(
    env$apply_evidence_portfolio_event(
      practical2_add_from_project_event(project, list(mixed_family)),
      project
    ),
    "family"
  )

  wrong_note_view <- valid
  wrong_note_view$view_id <- "calibration_summary"
  expect_error(
    env$apply_evidence_portfolio_event(
      practical2_add_from_project_event(project, list(wrong_note_view)),
      project
    ),
    "saved observation|saved note|view",
    ignore.case = TRUE
  )

  investigation_as_calibration <- valid
  investigation_as_calibration$source_run_ids <- fixture$investigation_run_ids
  investigation_as_calibration["observation_id"] <- list(NULL)
  investigation_as_calibration$view_id <- "calibration_summary"
  investigation_as_calibration$title <- "Invalid calibration summary"
  expect_error(
    env$apply_evidence_portfolio_event(
      practical2_add_from_project_event(
        project,
        list(investigation_as_calibration)
      ),
      project
    ),
    "reference|calibrat",
    ignore.case = TRUE
  )

  incomplete_comparison <- valid
  incomplete_comparison["observation_id"] <- list(NULL)
  incomplete_comparison$view_id <- "comparison_table"
  incomplete_comparison$title <- "Incomplete comparison"
  expect_error(
    env$apply_evidence_portfolio_event(
      practical2_add_from_project_event(project, list(incomplete_comparison)),
      project
    ),
    "Add from project|complete|comparison|kind",
    ignore.case = TRUE
  )
})

test_that("root applies validated Compare plot, table, and note portfolio events", {
  env <- source_practical2_app()
  project <- practical2_portfolio_project()
  run_ids <- vapply(project$runs, `[[`, character(1), "run_id")
  family_id <- unique(vapply(project$runs, `[[`, character(1), "family_id"))
  base_event <- list(
    ok = TRUE,
    action = "add",
    kind = "plot",
    source_family_id = family_id,
    source_run_ids = run_ids,
    view_id = "risk",
    title = "Capacity - warning risk",
    note = NULL,
    base_project_fingerprint = project$project_fingerprint,
    event_id = 1L,
    message = "Plot added."
  )
  now <- as.POSIXct("2026-07-25 04:00:00", tz = "UTC")

  with_plot <- env$apply_compare_portfolio_event(base_event, project, now = now)
  expect_length(with_plot$evidence_items, 1L)
  expect_identical(with_plot$evidence_items[[1L]]$kind, "plot")
  expect_identical(with_plot$evidence_items[[1L]]$source_run_ids, run_ids)

  table_event <- base_event
  table_event$kind <- "table"
  table_event$view_id <- "comparison_table"
  table_event$title <- "Capacity - comparison table"
  table_event$base_project_fingerprint <- with_plot$project_fingerprint
  table_event$event_id <- 2L
  with_table <- env$apply_compare_portfolio_event(
    table_event,
    with_plot,
    now = now + 60
  )
  expect_length(with_table$evidence_items, 2L)

  note_event <- base_event
  note_event$kind <- "observation"
  note_event$view_id <- "comparison_note"
  note_event$title <- "Capacity - comparison note"
  note_event$note <- paste(
    "Interpretation: Capacity altered warning risk.",
    "Caveat: The threshold is a working warning level.",
    sep = "\n"
  )
  note_event$base_project_fingerprint <- with_table$project_fingerprint
  note_event$event_id <- 3L
  with_note <- env$apply_compare_portfolio_event(
    note_event,
    with_table,
    now = now + 120
  )
  expect_length(with_note$observations, 1L)
  expect_length(with_note$evidence_items, 3L)
  expect_identical(
    with_note$evidence_items[[3L]]$observation_id,
    with_note$observations[[1L]]$observation_id
  )
  expect_error(
    env$apply_compare_portfolio_event(base_event, with_note, now = now + 180),
    "changed"
  )
  invalid <- base_event
  invalid$source_run_ids <- "woodhen_run_missing"
  expect_error(
    env$apply_compare_portfolio_event(invalid, project, now = now),
    "Unknown run"
  )
})

test_that("root applies Evidence Portfolio reorder and remove events without deleting runs", {
  env <- source_practical2_app()
  project <- practical2_portfolio_project()
  run_ids <- vapply(project$runs, `[[`, character(1), "run_id")
  family_id <- unique(vapply(project$runs, `[[`, character(1), "family_id"))
  now <- as.POSIXct("2026-07-25 04:00:00", tz = "UTC")
  for (spec in list(
    list(
      kind = "plot", source_family_id = family_id,
      source_run_ids = run_ids, view_id = "risk",
      title = "Risk", observation_id = NULL
    ),
    list(
      kind = "table", source_family_id = family_id,
      source_run_ids = run_ids, view_id = "comparison_table",
      title = "Table", observation_id = NULL
    )
  )) {
    project <- add_woodhen_evidence_item(project, spec, now = now)
    now <- now + 60
  }
  ids <- vapply(project$evidence_items, `[[`, character(1), "evidence_id")
  reorder <- list(
    action = "reorder",
    evidence_ids = rev(ids),
    base_project_fingerprint = project$project_fingerprint,
    event_id = 1L,
    message = "Portfolio order updated."
  )
  reordered <- env$apply_evidence_portfolio_event(reorder, project, now = now)
  expect_identical(reordered$evidence_ids, rev(ids))
  expect_length(reordered$runs, length(project$runs))

  remove <- list(
    action = "remove",
    evidence_id = ids[[1L]],
    base_project_fingerprint = reordered$project_fingerprint,
    event_id = 2L,
    message = "Evidence item removed."
  )
  removed <- env$apply_evidence_portfolio_event(remove, reordered, now = now + 60)
  expect_identical(
    vapply(removed$evidence_items, `[[`, character(1), "evidence_id"),
    ids[[2L]]
  )
  expect_length(removed$runs, length(project$runs))
  expect_error(
    env$apply_evidence_portfolio_event(remove, removed, now = now + 120),
    "changed"
  )
})

test_that("root server observes Compare and Evidence Portfolio mutations", {
  app_text <- paste(
    readLines(file.path(practical2_app_dir(), "app.R"), warn = FALSE),
    collapse = "\n"
  )

  expect_match(
    app_text,
    "observeEvent(compare_events$portfolio_event()",
    fixed = TRUE
  )
  expect_match(
    app_text,
    "apply_compare_portfolio_event(event, project())",
    fixed = TRUE
  )
  expect_match(
    app_text,
    "observeEvent(evidence_events$portfolio_event()",
    fixed = TRUE
  )
  expect_match(
    app_text,
    "apply_evidence_portfolio_event(event, project())",
    fixed = TRUE
  )
})

test_that("Practical 2 static styles carry the approved responsive and focus boundaries", {
  css <- paste(readLines(file.path(practical2_app_dir(), "www", "styles.css"), warn = FALSE), collapse = "\n")

  expect_match(css, "minmax\\(0,")
  expect_match(css, "flex-wrap:\\s*wrap")
  expect_match(css, ":focus-visible")
  expect_match(css, "overflow-x:\\s*hidden")
  expect_match(css, "@media \\(max-width: 780px\\)")
  expect_match(css, "grid-template-columns:\\s*repeat\\(2, minmax\\(0, 1fr\\)\\)")
  expect_match(css, "overflow-wrap:\\s*anywhere")
  expect_match(css, "\\.project-action \\.input-group-btn \\.btn-file")
  expect_match(css, "min-width:\\s*9rem")
  expect_false(grepl("font-size:\\s*[^;]*(vw|vh)", css))
  expect_false(grepl("letter-spacing:\\s*-", css))
})

test_that("static shell checks do not claim live browser persistence", {
  app_dir <- practical2_app_dir()
  production_text <- paste(readLines(file.path(app_dir, "README.md"), warn = FALSE), collapse = "\n")
  overclaim <- paste("browser recovery", "passes")

  expect_false(grepl(overclaim, production_text, fixed = TRUE))
})
