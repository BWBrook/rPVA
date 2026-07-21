library(shiny)

practical2_app_dir <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)

source("ui_helpers.R", local = TRUE)
source("project_helpers.R", local = TRUE)
source(file.path("modules", "mod_start.R"), local = TRUE)
source(file.path("modules", "mod_calibrate.R"), local = TRUE)
source(file.path("modules", "mod_investigate.R"), local = TRUE)

status_value <- function(value, state = "neutral", icon = "circle-info") {
  list(value = value, state = state, icon = icon)
}

validate_investigate_project_update_event <- function(event, current_project) {
  expected_fields <- c(
    "ok", "candidate", "family_id", "route", "reused", "message",
    "base_project_fingerprint", "event_id"
  )
  if (!is.list(event) || is.null(names(event)) || anyDuplicated(names(event)) ||
      !setequal(names(event), expected_fields)) {
    stop(
      "A successful Investigate event must contain exactly: ",
      paste(expected_fields, collapse = ", "), ".",
      call. = FALSE
    )
  }
  if (!identical(event$ok, TRUE)) {
    stop("A candidate activation requires `event$ok` to be TRUE.", call. = FALSE)
  }
  valid_text <- function(value) {
    is.character(value) && length(value) == 1L && !is.na(value) && nzchar(value)
  }
  if (!valid_text(event$family_id) || !valid_text(event$message) ||
      !valid_text(event$base_project_fingerprint)) {
    stop("Investigate event identity and message fields must be non-empty text.", call. = FALSE)
  }
  if (!valid_text(event$route) || !event$route %in% c("sensitivity", "future") ||
      !is.logical(event$reused) || length(event$reused) != 1L || is.na(event$reused) ||
      !is.numeric(event$event_id) || length(event$event_id) != 1L ||
      !is.finite(event$event_id) || event$event_id < 1L ||
      event$event_id != as.integer(event$event_id)) {
    stop("Investigate event route, reuse state, or event ID is invalid.", call. = FALSE)
  }
  rPVA::validate_woodhen_project(current_project)
  if (!identical(
    event$base_project_fingerprint,
    current_project$project_fingerprint
  )) {
    stop(
      "The active project changed after this Investigate action was accepted.",
      call. = FALSE
    )
  }
  rPVA::validate_woodhen_project(event$candidate)
  if (!identical(event$candidate$project_id, current_project$project_id)) {
    stop("An Investigate candidate cannot replace a different project ID.", call. = FALSE)
  }
  family_runs <- event$candidate$runs[vapply(event$candidate$runs, function(run) {
    identical(run$family_id, event$family_id)
  }, logical(1))]
  expected_types <- if (identical(event$route, "sensitivity")) {
    c("locked_baseline", "sensitivity", "sensitivity")
  } else {
    c("locked_baseline", "threat", "intervention")
  }
  scenario_types <- vapply(family_runs, `[[`, character(1), "scenario_type")
  if (!identical(scenario_types, expected_types)) {
    stop("The Investigate candidate does not contain the event's exact family.", call. = FALSE)
  }
  event$candidate
}

ui <- navbarPage(
  title = "Practical 2 Woodhen Lab",
  id = "section",
  header = tags$head(
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    tags$script(src = "project-store.js")
  ),
  tabPanel("Start", value = "start", start_ui("start")),
  tabPanel(
    "Calibrate",
    value = "calibrate",
    calibrate_ui("calibrate")
  ),
  tabPanel(
    "Investigate",
    value = "investigate",
    investigate_ui("investigate")
  ),
  tabPanel(
    "Compare",
    value = "compare",
    pending_tab_ui(
      "Compare project evidence",
      "The persistent comparison workspace will be added here."
    )
  ),
  tabPanel(
    "Evidence Studio",
    value = "evidence",
    pending_tab_ui(
      "Build an evidence dossier",
      "Evidence selection and deliberate exports will be added here."
    )
  )
)

make_practical2_server <- function(
    calibrate_scenario_runner = rPVA::run_woodhen_investigation_scenario,
    investigate_scenario_runner = rPVA::run_woodhen_investigation_scenario
) {
  function(input, output, session) {
    project <- reactiveVal(NULL)
    inventory <- reactiveVal(list())
    saved_fingerprint <- reactiveVal(NULL)
    portable_fingerprint <- reactiveVal(NULL)
    pending_restore <- reactiveVal(NULL)
    pending_requests <- reactiveVal(list())
    request_counter <- reactiveVal(0L)

    browser_status <- reactiveVal(status_value(
      "No active project yet.", "neutral", "circle-info"
    ))
    portable_status <- reactiveVal(status_value(
      "No portable project download requested.", "neutral", "download"
    ))
    dirty_status <- reactiveVal(status_value(
      "No active project yet.", "neutral", "circle-info"
    ))

    next_request_id <- function(kind) {
      next_value <- request_counter() + 1L
      request_counter(next_value)
      paste0(kind, "-", next_value)
    }

    track_request <- function(request_id, request) {
      request$request_id <- request_id
      requests <- pending_requests()
      requests[[request_id]] <- request
      pending_requests(requests)
      invisible(request_id)
    }

    forget_request <- function(request_id) {
      requests <- pending_requests()
      requests[[request_id]] <- NULL
      pending_requests(requests)
      invisible(NULL)
    }

    refresh_portable_status <- function(candidate = project()) {
      if (is.null(candidate)) {
        portable_status(status_value(
          "No portable project download requested.", "neutral", "download"
        ))
      } else if (is.null(portable_fingerprint())) {
        portable_status(status_value(
          "No portable project download requested.", "neutral", "download"
        ))
      } else if (identical(portable_fingerprint(), candidate$project_fingerprint)) {
        portable_status(status_value(
          "Portable project download requested for current content.",
          "current",
          "circle-check"
        ))
      } else {
        portable_status(status_value(
          "Portable project download is out of date.",
          "warning",
          "triangle-exclamation"
        ))
      }
    }

    refresh_dirty_status <- function(candidate = project()) {
      if (is.null(candidate)) {
        dirty_status(status_value("No active project yet.", "neutral", "circle-info"))
      } else if (identical(saved_fingerprint(), candidate$project_fingerprint)) {
        dirty_status(status_value(
          "No material changes are waiting for browser autosave.",
          "current",
          "circle-check"
        ))
      } else {
        dirty_status(status_value(
          "Material changes are waiting for browser autosave.",
          "warning",
          "triangle-exclamation"
        ))
      }
    }

    queue_project_save <- function(candidate) {
      snapshot_json <- rPVA:::woodhen_project_browser_snapshot(candidate)
      saved_at <- format(
        as.POSIXct(Sys.time(), tz = "UTC"),
        "%Y-%m-%dT%H:%M:%SZ",
        tz = "UTC"
      )
      record <- project_store_record(
        candidate,
        snapshot_json,
        saved_at,
        portable_request_fingerprint = portable_fingerprint()
      )
      request_id <- next_request_id("save")
      track_request(request_id, list(kind = "save", record = record))
      browser_status(status_value(
        "Browser autosave is pending.", "pending", "clock"
      ))
      refresh_dirty_status(candidate)
      session$sendCustomMessage(
        "woodhen-project-store-save",
        list(
          contract_version = project_store_contract_version(),
          request_id = request_id,
          key = record$key,
          record = record
        )
      )
      invisible(request_id)
    }

    activate_project <- function(
        candidate,
        portable_request_fingerprint = portable_fingerprint()
    ) {
      rPVA::validate_woodhen_project(candidate)
      replace_live_project(project, candidate)
      saved_fingerprint(NULL)
      portable_fingerprint(portable_request_fingerprint)
      refresh_portable_status(candidate)
      refresh_dirty_status(candidate)
      queue_project_save(candidate)
      invisible(candidate)
    }

    activate_investigate_update <- function(event) {
      if (!isTRUE(event$ok)) {
        showNotification(event$message, type = "warning")
        return(FALSE)
      }
      candidate <- tryCatch(
        validate_investigate_project_update_event(event, project()),
        error = function(error) error
      )
      if (inherits(candidate, "error")) {
        showNotification(
          paste("Investigate update rejected:", conditionMessage(candidate)),
          type = "warning"
        )
        return(FALSE)
      }
      activate_project(candidate)
      showNotification(event$message, type = "message")
      TRUE
    }

    events <- start_server(
      "start",
      project = reactive(project()),
      inventory = reactive(inventory()),
      browser_status = reactive(browser_status()),
      portable_status = reactive(portable_status()),
      dirty_status = reactive(dirty_status())
    )
    calibrate_events <- calibrate_server(
      "calibrate",
      project = reactive(project()),
      scenario_runner = calibrate_scenario_runner
    )
    investigate_events <- investigate_server(
      "investigate",
      project = reactive(project()),
      scenario_runner = investigate_scenario_runner
    )

    observeEvent(calibrate_events$project_update(), {
      event <- calibrate_events$project_update()
      if (!isTRUE(event$ok)) {
        showNotification(event$message, type = "warning")
        return()
      }
      activate_project(event$candidate)
      showNotification(event$message, type = "message")
    })

    observeEvent(investigate_events$project_update(), {
      activate_investigate_update(investigate_events$project_update())
    })

    observeEvent(investigate_events$navigate(), {
      event <- investigate_events$navigate()
      if (is.null(event) || !identical(event$section, "calibrate")) return()
      updateNavbarPage(session, "section", selected = "calibrate")
    })

    observeEvent(input$project_store_inventory, {
      records <- tryCatch(
        validate_project_store_inventory(input$project_store_inventory),
        error = function(error) {
          showNotification(
            paste("Browser project inventory could not be read:", conditionMessage(error)),
            type = "warning"
          )
          NULL
        }
      )
      if (!is.null(records)) {
        inventory(records)
      }
    }, ignoreInit = TRUE)

    observeEvent(events$create(), {
      event <- events$create()
      if (!isTRUE(event$ok)) {
        showNotification(event$message, type = "error")
        return()
      }
      pending_restore(NULL)
      activate_project(event$candidate, portable_request_fingerprint = NULL)
      showNotification("New Woodhen investigation project created.", type = "message")
    })

    observeEvent(events$resume(), {
      event <- events$resume()
      if (!isTRUE(event$ok)) {
        showNotification(event$message, type = "warning")
        return()
      }
      record <- event$record
      request_id <- next_request_id("restore")
      pending <- list(
        request_id = request_id,
        key = record$key,
        project_id = record$project_id,
        project_fingerprint = record$project_fingerprint
      )
      pending_restore(pending)
      session$sendCustomMessage(
        "woodhen-project-store-restore",
        list(
          contract_version = project_store_contract_version(),
          request_id = request_id,
          key = record$key,
          schema_version = record$schema_version,
          project_id = record$project_id,
          project_fingerprint = record$project_fingerprint
        )
      )
    })

    observeEvent(input$project_store_restore, {
      pending <- pending_restore()
      if (is.null(pending)) {
        showNotification("An unsolicited browser restore response was ignored.", type = "warning")
        return()
      }
      response_request_id <- input$project_store_restore$request_id
      if (!is.character(response_request_id) || length(response_request_id) != 1L ||
          is.na(response_request_id) ||
          !identical(response_request_id, pending$request_id)) {
        showNotification("A stale browser restore response was ignored.", type = "warning")
        return()
      }
      pending_restore(NULL)
      candidate <- tryCatch(
        validate_project_store_restore(input$project_store_restore, pending),
        error = function(error) error
      )
      if (inherits(candidate, "error")) {
        showNotification(
          paste("Browser project was not restored:", conditionMessage(candidate)),
          type = "error"
        )
        return()
      }
      portable_request_fingerprint <- input$project_store_restore$record$portable_request_fingerprint
      activate_project(candidate, portable_request_fingerprint)
      showNotification("Browser project restored after validation.", type = "message")
    }, ignoreInit = TRUE)

    observeEvent(events$import(), {
      event <- events$import()
      if (!isTRUE(event$ok)) {
        showNotification(
          paste("Portable project was not imported:", event$message),
          type = "error"
        )
        return()
      }
      pending_restore(NULL)
      activate_project(event$candidate, portable_request_fingerprint = NULL)
      showNotification("Portable project imported after validation.", type = "message")
    })

    observeEvent(events$download_requested(), {
      event <- events$download_requested()
      candidate <- project()
      if (is.null(event) || is.null(candidate) ||
          !identical(event$project_id, candidate$project_id) ||
          !identical(event$project_fingerprint, candidate$project_fingerprint)) {
        return()
      }
      portable_fingerprint(candidate$project_fingerprint)
      refresh_portable_status(candidate)
      request_id <- next_request_id("portable")
      record_key <- project_store_key(candidate$project_schema_version, candidate$project_id)
      track_request(request_id, list(
        kind = "portable",
        record = list(
          key = record_key,
          project_id = candidate$project_id,
          project_fingerprint = candidate$project_fingerprint
        )
      ))
      session$sendCustomMessage(
        "woodhen-project-store-mark-portable",
        list(
          contract_version = project_store_contract_version(),
          request_id = request_id,
          key = record_key,
          schema_version = candidate$project_schema_version,
          project_id = candidate$project_id,
          project_fingerprint = candidate$project_fingerprint
        )
      )
    }, ignoreInit = TRUE)

    observeEvent(input$project_store_status, {
      request_id <- input$project_store_status$request_id
      request <- pending_requests()[[request_id]]
      if (is.null(request)) {
        return()
      }
      status <- tryCatch(
        validate_project_store_status(input$project_store_status, request),
        error = function(error) error
      )
      if (inherits(status, "error")) {
        showNotification(
          paste("Browser storage acknowledgement was rejected:", conditionMessage(status)),
          type = "warning"
        )
        return()
      }
      forget_request(request_id)

      if (identical(request$kind, "save")) {
        if (identical(status$status, "saved")) {
          saved_fingerprint(status$project_fingerprint)
          browser_status(status_value(
            "Autosaved in this browser.", "current", "circle-check"
          ))
          refresh_dirty_status()
        } else if (identical(status$status, "superseded")) {
          browser_status(status_value(
            "A newer browser autosave is pending.", "pending", "clock"
          ))
        } else {
          browser_status(status_value(
            "Browser autosave is unavailable; download a portable project.",
            "warning",
            "triangle-exclamation"
          ))
          refresh_dirty_status()
        }
      } else if (identical(status$status, "portable_marked")) {
        refresh_portable_status()
      } else {
        portable_status(status_value(
          "Portable project download requested; browser recovery did not record it.",
          "warning",
          "triangle-exclamation"
        ))
      }
    })
  }
}

server <- make_practical2_server()

shinyApp(ui, server)
