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
    "content/help-projects.md",
    "content/start.md",
    "modules/mod_calibrate.R",
    "modules/mod_start.R",
    "project_helpers.R",
    "ui_helpers.R",
    "www/img/landing-woodhen-population.png",
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

test_that("shell exposes exactly five visible stable tab values", {
  env <- source_practical2_app()
  html <- paste(as.character(env$ui), collapse = "\n")
  tab_values <- regmatches(
    html,
    gregexpr('data-value="(start|calibrate|investigate|compare|evidence)"', html)
  )[[1L]]

  expect_identical(
    unique(gsub('^data-value="|"$', "", tab_values)),
    c("start", "calibrate", "investigate", "compare", "evidence")
  )
  expect_match(html, ">Start<")
  expect_match(html, ">Calibrate<")
  expect_match(html, ">Investigate<")
  expect_match(html, ">Compare<")
  expect_match(html, ">Evidence Studio<")
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
  expect_match(html, 'alt="Lord Howe Island woodhen', fixed = TRUE)
  expect_match(html, 'aria-live="polite"', fixed = TRUE)
  expect_match(html, "Autosave in this browser", fixed = TRUE)
  expect_match(html, "Portable project", fixed = TRUE)
  expect_match(html, "Unsaved changes", fixed = TRUE)
})

test_that("Start narrative states the adviser, two-act, core-route, and extension contract", {
  app_dir <- practical2_app_dir()
  start_text <- paste(readLines(file.path(app_dir, "content", "start.md"), warn = FALSE), collapse = "\n")
  help_text <- paste(readLines(file.path(app_dir, "content", "help-projects.md"), warn = FALSE), collapse = "\n")

  expect_match(start_text, "present-day conservation adviser", ignore.case = TRUE)
  expect_match(start_text, "Act 1")
  expect_match(start_text, "Act 2")
  expect_match(start_text, "three-hour core route", ignore.case = TRUE)
  expect_match(start_text, "pass-level foundation", ignore.case = TRUE)
  expect_match(start_text, "independent work afterward", ignore.case = TRUE)
  expect_match(start_text, "Ways to deepen your investigation", fixed = TRUE)
  expect_false(grepl("grade|grading|score|scoring", start_text, ignore.case = TRUE))

  expect_match(help_text, "autosaved in this browser", ignore.case = TRUE)
  expect_match(help_text, "origin", ignore.case = TRUE)
  expect_match(help_text, "portable", ignore.case = TRUE)
  expect_match(help_text, "download requested", ignore.case = TRUE)
})

test_that("only the three future workspaces remain quiet bands without false completion", {
  env <- source_practical2_app()
  html <- paste(as.character(env$ui), collapse = "\n")

  expect_equal(length(gregexpr('class="pending-tab-band"', html, fixed = TRUE)[[1L]]), 3L)
  expect_match(html, "This workspace arrives in the next build stage", fixed = TRUE)
  expect_false(grepl("complete|completed|passed|report ready", html, ignore.case = TRUE))
  expect_false(any(file.exists(file.path(
    practical2_app_dir(), "modules",
    c("mod_investigate.R", "mod_compare.R", "mod_evidence.R")
  ))))
})

test_that("root server owns replacement and module exposes reactive events", {
  app_dir <- practical2_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")
  module_text <- paste(readLines(file.path(app_dir, "modules", "mod_start.R"), warn = FALSE), collapse = "\n")
  calibrate_text <- paste(readLines(file.path(app_dir, "modules", "mod_calibrate.R"), warn = FALSE), collapse = "\n")

  expect_match(app_text, "project <- reactiveVal(NULL)", fixed = TRUE)
  expect_match(app_text, "rPVA::validate_woodhen_project(candidate)", fixed = TRUE)
  expect_match(app_text, "project(candidate)", fixed = TRUE)
  expect_match(app_text, "events <- start_server", fixed = TRUE)
  expect_match(app_text, "calibrate_events <- calibrate_server", fixed = TRUE)
  expect_match(app_text, "observeEvent(calibrate_events$project_update()", fixed = TRUE)
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
  expect_false(grepl("assign\\(|<<-", paste(app_text, module_text, calibrate_text)))
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
  })
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

test_that("Practical 2 static styles carry the approved responsive and focus boundaries", {
  css <- paste(readLines(file.path(practical2_app_dir(), "www", "styles.css"), warn = FALSE), collapse = "\n")

  expect_match(css, "minmax\\(0,")
  expect_match(css, "flex-wrap:\\s*wrap")
  expect_match(css, ":focus-visible")
  expect_match(css, "overflow-x:\\s*hidden")
  expect_match(css, "@media \\(max-width: 780px\\)")
  expect_match(css, "grid-template-columns:\\s*repeat\\(2, minmax\\(0, 1fr\\)\\)")
  expect_match(css, "overflow-wrap:\\s*anywhere")
  expect_false(grepl("font-size:\\s*[^;]*(vw|vh)", css))
  expect_false(grepl("letter-spacing:\\s*-", css))
})

test_that("static shell checks do not claim live browser persistence", {
  app_dir <- practical2_app_dir()
  production_text <- paste(readLines(file.path(app_dir, "README.md"), warn = FALSE), collapse = "\n")
  overclaim <- paste("browser recovery", "passes")

  expect_false(grepl(overclaim, production_text, fixed = TRUE))
})
