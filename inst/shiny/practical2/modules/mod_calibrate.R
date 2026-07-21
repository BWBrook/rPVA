calibrate_reference_case_ui <- function(ns, reference_id) {
  catalog <- rPVA::woodhen_reference_catalog()
  row <- catalog[catalog$id == reference_id, , drop = FALSE]
  settings <- sprintf(
    "%d years | 1,000 simulated futures | seed 123 | immutable reference settings",
    row$horizon_years[[1L]]
  )

  tags$article(
    class = "reference-case",
    `data-reference-id` = reference_id,
    div(
      class = "reference-case-heading",
      div(
        span(class = "reference-id", reference_id),
        h3(row$label[[1L]])
      ),
      actionButton(
        ns(paste0("run_", reference_id)),
        "Run reference case",
        icon = icon("play"),
        class = "btn-primary reference-run-action",
        `aria-label` = paste("Run", row$label[[1L]], "reference case")
      )
    ),
    p(class = "reference-meaning", row$biological_meaning[[1L]]),
    p(class = "reference-settings", settings),
    div(
      id = ns(paste0("progress_bar_", reference_id)),
      class = "reference-progress",
      role = "progressbar",
      `aria-valuemin` = "0",
      `aria-valuemax` = "1000",
      `aria-label` = paste(row$label[[1L]], "simulation progress"),
      textOutput(ns(paste0("progress_", reference_id)), inline = TRUE)
    ),
    uiOutput(
      ns(paste0("status_", reference_id)),
      `aria-live` = "polite",
      `aria-atomic` = "true"
    ),
    uiOutput(ns(paste0("result_", reference_id))),
    div(
      class = "reference-evidence-grid",
      div(
        role = "img",
        `aria-label` = paste("Abundance trajectory evidence for", row$label[[1L]]),
        plotOutput(ns(paste0("trajectory_", reference_id)), height = "230px")
      ),
      div(
        role = "img",
        `aria-label` = paste("Risk evidence for", row$label[[1L]]),
        plotOutput(ns(paste0("risk_", reference_id)), height = "230px")
      )
    ),
    div(
      class = "reference-prompts",
      textAreaInput(
        ns(paste0("interpretation_", reference_id)),
        "Optional interpretation",
        rows = 2,
        placeholder = "What pattern matters for the management story?"
      ),
      textAreaInput(
        ns(paste0("caveat_", reference_id)),
        "Optional caveat",
        rows = 2,
        placeholder = "What uncertainty or limitation should qualify this result?"
      ),
      actionButton(
        ns(paste0("save_notes_", reference_id)),
        "Save observations",
        icon = icon("note-sticky"),
        class = "btn-default btn-sm"
      )
    )
  )
}

calibrate_help_modal <- function() {
  modalDialog(
    title = "Interpreting the historical calibration",
    div(
      class = "help-modal-content",
      render_markdown_content(file.path(practical2_app_dir, "content", "help-calibrate.md"))
    ),
    footer = modalButton("Close"),
    easyClose = TRUE,
    size = "m"
  )
}

calibrate_ui <- function(id) {
  ns <- NS(id)
  history <- rPVA:::woodhen_calibration_history()

  div(
    class = "page-shell calibrate-shell",
    tags$header(
      class = "calibrate-header",
      div(
        span(class = "section-eyebrow", "Act 1: Calibrate against history"),
        h1("Audit the Woodhen management record"),
        p(
          "Run each reference case, compare only compatible horizons, and decide",
          "what the historically grounded model can and cannot support."
        )
      ),
      actionButton(
        ns("open_calibrate_help"),
        "Interpretation help",
        icon = icon("circle-info"),
        class = "btn-default btn-sm"
      )
    ),
    tags$section(
      class = "calibration-period",
      `aria-labelledby` = ns("heading_1980"),
      span(class = "period-label", history$crisis_1980$period),
      h2(id = ns("heading_1980"), history$crisis_1980$heading),
      p(history$crisis_1980$observed_history),
      p(
        class = "comparison-rule",
        "These are the only directly ranked cases: they share the 1980 decision context,",
        "starting state, 40-year horizon, seed 123, and 1,000 simulated futures."
      ),
      div(
        class = "reference-case-grid reference-case-grid-three",
        lapply(
          history$crisis_1980$reference_ids,
          function(reference_id) calibrate_reference_case_ui(ns, reference_id)
        )
      ),
      uiOutput(ns("comparison_1980"))
    ),
    tags$section(
      class = "calibration-period",
      `aria-labelledby` = ns("heading_2019"),
      span(class = "period-label", history$recovery_2019_2024$period),
      h2(id = ns("heading_2019"), history$recovery_2019_2024$heading),
      p(history$recovery_2019_2024$observed_history),
      p(history$recovery_2019_2024$model_state$label),
      div(class = "short-horizon-warning", history$recovery_2019_2024$warning),
      div(
        class = "reference-case-grid reference-case-grid-one",
        calibrate_reference_case_ui(ns, "04_rodent_eradication")
      )
    ),
    tags$section(
      class = "calibration-period",
      `aria-labelledby` = ns("heading_2025"),
      span(class = "period-label", history$future_2025_2100$period),
      h2(id = ns("heading_2025"), history$future_2025_2100$heading),
      p(history$future_2025_2100$observed_history),
      div(
        class = "reference-case-grid reference-case-grid-one",
        calibrate_reference_case_ui(ns, "05_future_baseline")
      ),
      uiOutput(ns("anchor_status"), `aria-live` = "polite")
    )
  )
}

calibrate_server <- function(
    id,
    project,
    scenario_runner = rPVA::run_woodhen_investigation_scenario
) {
  moduleServer(id, function(input, output, session) {
    reference_ids <- rPVA::woodhen_reference_catalog()$id
    progress_state <- reactiveVal(setNames(lapply(reference_ids, function(id) {
      c(completed = 0L, total = 1000L)
    }), reference_ids))
    progress_history <- reactiveVal(list())
    status_state <- reactiveVal(setNames(rep("Not run in this project.", 5L), reference_ids))
    project_update_state <- reactiveVal(NULL)
    event_counter <- reactiveVal(0L)

    publish_update <- function(value) {
      next_event <- event_counter() + 1L
      event_counter(next_event)
      value$event_id <- next_event
      project_update_state(value)
      invisible(value)
    }

    completed_run <- function(reference_id, candidate = project()) {
      if (is.null(candidate)) return(NULL)
      tryCatch(
        rPVA:::woodhen_reference_run_in_project(candidate, reference_id),
        error = function(...) NULL
      )
    }

    set_reference_status <- function(reference_id, message) {
      values <- status_state()
      values[[reference_id]] <- message
      status_state(values)
    }

    set_reference_progress <- function(reference_id, completed, total, record = TRUE) {
      values <- progress_state()
      values[[reference_id]] <- c(
        completed = as.integer(completed), total = as.integer(total)
      )
      progress_state(values)
      if (record) {
        history <- progress_history()
        history[[length(history) + 1L]] <- values[[reference_id]]
        progress_history(history)
      }
    }

    observeEvent(input$open_calibrate_help, {
      showModal(calibrate_help_modal())
    })

    for (id_value in reference_ids) {
      local({
        reference_id <- id_value
        run_input <- paste0("run_", reference_id)
        save_input <- paste0("save_notes_", reference_id)

        observeEvent(input[[run_input]], {
          candidate <- project()
          if (is.null(candidate)) {
            message <- "Create or resume a project on Start before running a reference case."
            set_reference_status(reference_id, message)
            publish_update(list(ok = FALSE, reference_id = reference_id, message = message))
            return()
          }
          progress_history(list())
          set_reference_progress(reference_id, 0L, 1000L, record = FALSE)
          set_reference_status(reference_id, "Running simulated futures...")
          action <- tryCatch(
            rPVA:::run_woodhen_reference_project(
              candidate,
              reference_id,
              progress = function(completed, total) {
                set_reference_progress(reference_id, completed, total)
              },
              runner = scenario_runner
            ),
            error = function(error) error
          )
          if (inherits(action, "error")) {
            message <- paste("Reference run failed:", conditionMessage(action))
            set_reference_status(reference_id, message)
            publish_update(list(ok = FALSE, reference_id = reference_id, message = message))
            return()
          }
          set_reference_progress(reference_id, 1000L, 1000L, record = FALSE)
          message <- if (isTRUE(action$reused)) {
            "Exact existing scenario and run reused; no duplicate was created."
          } else {
            "Reference run complete and ready for project activation."
          }
          set_reference_status(reference_id, message)
          publish_update(list(
            ok = TRUE,
            candidate = action$project,
            reference_id = reference_id,
            run_id = action$run$run_id,
            reused = action$reused,
            message = message
          ))
        })

        observeEvent(input[[save_input]], {
          interpretation <- input[[paste0("interpretation_", reference_id)]] %||% ""
          caveat <- input[[paste0("caveat_", reference_id)]] %||% ""
          notes <- c(interpretation = interpretation, caveat = caveat)
          notes <- notes[nzchar(trimws(notes))]
          if (length(notes) == 0L) return()
          candidate <- project()
          run <- completed_run(reference_id, candidate)
          if (is.null(candidate) || is.null(run)) {
            set_reference_status(reference_id, "Run this reference case before saving observations.")
            return()
          }
          updated <- tryCatch({
            for (kind in names(notes)) {
              updated_title <- paste(run$student_label, kind)
              candidate <- rPVA::add_woodhen_observation(candidate, list(
                title = updated_title,
                note = unname(notes[[kind]]),
                run_ids = run$run_id
              ))
            }
            candidate
          }, error = function(error) error)
          if (inherits(updated, "error")) {
            set_reference_status(
              reference_id,
              paste("Observations were not saved:", conditionMessage(updated))
            )
            return()
          }
          set_reference_status(reference_id, "Explicit observations are ready for project activation.")
          publish_update(list(
            ok = TRUE,
            candidate = updated,
            reference_id = reference_id,
            run_id = run$run_id,
            reused = TRUE,
            message = "Explicit observations saved."
          ))
        })

        output[[paste0("progress_", reference_id)]] <- renderText({
          state <- progress_state()[[reference_id]]
          run <- completed_run(reference_id)
          if (!is.null(run) && state[["completed"]] == 0L) {
            state <- c(completed = run$reps, total = run$reps)
          }
          paste(format(state[["completed"]], big.mark = ","), "of",
            format(state[["total"]], big.mark = ","), "futures completed")
        })

        output[[paste0("status_", reference_id)]] <- renderUI({
          message <- status_state()[[reference_id]]
          if (!is.null(completed_run(reference_id)) && identical(message, "Not run in this project.")) {
            message <- "Completed reference evidence restored from this project."
          }
          div(class = "reference-state", message)
        })

        output[[paste0("result_", reference_id)]] <- renderUI({
          run <- completed_run(reference_id)
          if (is.null(run)) return(NULL)
          evidence <- list(
            div(strong("Extinction by horizon"),
              span(sprintf("%.1f%%", 100 * run$extinction_evidence$probability_by_horizon))),
            div(strong("Final median abundance"),
              span(format(run$final_abundance$median, big.mark = ","))),
            div(strong("95% simulation interval"),
              span(sprintf("%s-%s", format(run$final_abundance$q025, big.mark = ","),
                format(run$final_abundance$q975, big.mark = ","))))
          )
          if (identical(reference_id, "05_future_baseline")) {
            evidence[[length(evidence) + 1L]] <- div(
              strong("Below 50 breeding pairs by 2100"),
              span(sprintf("%.1f%%", 100 * run$quasi_extinction_50_pairs$probability_by_horizon))
            )
          }
          div(class = "reference-result-summary", evidence)
        })

        output[[paste0("trajectory_", reference_id)]] <- renderPlot({
          run <- completed_run(reference_id)
          req(run)
          quantiles <- run$annual_quantiles
          plot(
            quantiles$year, quantiles$median,
            type = "l", lwd = 2, col = "#126a73",
            xlab = "Projection year", ylab = "Total birds",
            main = "Abundance and uncertainty"
          )
          polygon(
            c(quantiles$year, rev(quantiles$year)),
            c(quantiles$q025, rev(quantiles$q975)),
            col = grDevices::adjustcolor("#7fb6b3", alpha.f = 0.35), border = NA
          )
          lines(quantiles$year, quantiles$median, lwd = 2, col = "#126a73")
        }, res = 96)

        output[[paste0("risk_", reference_id)]] <- renderPlot({
          run <- completed_run(reference_id)
          req(run)
          extinction <- run$extinction_evidence$cumulative
          plot(
            extinction$year, extinction$probability,
            type = "s", lwd = 2, col = "#a63d40", ylim = c(0, 1),
            xlab = "Projection year", ylab = "Cumulative probability",
            main = if (identical(reference_id, "05_future_baseline")) {
              "Future extinction and 50-pair risk"
            } else {
              "Extinction risk"
            }
          )
          if (identical(reference_id, "05_future_baseline")) {
            quasi <- run$quasi_extinction_50_pairs$cumulative
            lines(quasi$year, quasi$probability, type = "s", lwd = 2, col = "#9a6a14")
            legend("topleft", c("Extinction", "Below 50 pairs"),
              col = c("#a63d40", "#9a6a14"), lwd = 2, bty = "n")
          }
        }, res = 96)
      })
    }

    output$comparison_1980 <- renderUI({
      runs <- lapply(
        c("01_no_mgmt", "02_pig_control", "03_captive_pig"),
        completed_run
      )
      if (any(vapply(runs, is.null, logical(1)))) return(NULL)
      comparison <- rPVA:::compare_woodhen_1980_references(runs)
      rows <- lapply(seq_len(nrow(comparison$table)), function(index) {
        row <- comparison$table[index, ]
        tags$tr(
          tags$th(scope = "row", row$student_label),
          tags$td(sprintf("%.1f%%", 100 * row$extinction_probability)),
          tags$td(format(row$final_median_abundance, big.mark = ",")),
          tags$td(sprintf("%s-%s", format(row$final_q025, big.mark = ","),
            format(row$final_q975, big.mark = ",")))
        )
      })
      div(
        class = "historical-comparison",
        h3("Compatible 1980 comparison"),
        p(comparison$interpretation),
        tags$table(
          class = "table table-condensed",
          tags$thead(tags$tr(
            tags$th("Reference case"), tags$th("Extinction"),
            tags$th("Final median"), tags$th("95% interval")
          )),
          tags$tbody(rows)
        )
      )
    })

    output$anchor_status <- renderUI({
      status <- rPVA:::woodhen_locked_anchor_status(project())
      state_class <- paste0("anchor-status is-", status$status)
      div(
        class = state_class,
        strong(switch(status$status,
          ready = "Locked future baseline ready",
          stale = "Locked future baseline is incompatible",
          "Locked future baseline missing"
        )),
        span(status$action)
      )
    })

    project_update <- reactive(project_update_state())
    list(
      project_update = project_update,
      progress_state = reactive(progress_state()),
      progress_history = reactive(progress_history())
    )
  })
}
