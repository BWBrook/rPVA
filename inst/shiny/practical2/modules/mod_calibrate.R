calibrate_whole_birds <- function(value) {
  format(round(as.numeric(value)), big.mark = ",", scientific = FALSE, trim = TRUE)
}

calibrate_calendar_years <- function(reference_id, projection_years) {
  start_year <- switch(reference_id,
    `01_no_mgmt` = 1980,
    `02_pig_control` = 1980,
    `03_captive_pig` = 1980,
    `04_rodent_eradication` = 2019,
    `05_future_baseline` = 2025,
    stop("Unknown Woodhen reference scenario.", call. = FALSE)
  )
  as.integer(start_year) + projection_years
}

calibrate_calendar_ticks <- function(reference_id) {
  switch(reference_id,
    `01_no_mgmt` = seq(1980, 2020, by = 10),
    `02_pig_control` = seq(1980, 2020, by = 10),
    `03_captive_pig` = seq(1980, 2020, by = 10),
    `04_rodent_eradication` = 2019:2024,
    `05_future_baseline` = c(2025, 2040, 2060, 2080, 2100),
    stop("Unknown Woodhen reference scenario.", call. = FALSE)
  )
}

calibrate_year_label <- function(value) {
  format(round(as.numeric(value)), scientific = FALSE, trim = TRUE)
}

calibrate_abundance_ylim <- function(quantiles) {
  upper <- max(
    quantiles$q975,
    quantiles$median[[1L]] * 1.6,
    na.rm = TRUE
  )
  c(0, max(1, ceiling(upper * 1.05)))
}

calibrate_plot_trajectory <- function(run,
                                      reference_id = run$scenario_id) {
  quantiles <- run$annual_quantiles
  calendar_years <- calibrate_calendar_years(reference_id, quantiles$year)
  abundance_ylim <- calibrate_abundance_ylim(quantiles)
  if (identical(reference_id, "04_rodent_eradication")) {
    recovery <- rPVA:::woodhen_calibration_history()$recovery_2019_2024
    observed <- recovery$observed_points
    released <- recovery$release_marker
    abundance_ylim[[2L]] <- max(
      abundance_ylim[[2L]],
      1.08 * max(observed$abundance)
    )
  }
  old_par <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(old_par), add = TRUE)
  graphics::par(mar = c(4.2, 4.6, 3.2, 1.2), mgp = c(2.7, 0.8, 0), las = 1)
  graphics::plot(
    calendar_years, quantiles$median,
    type = "l", lwd = 2, col = "#126a73",
    xlab = "Year", ylab = "Number of birds",
    main = if (identical(reference_id, "04_rodent_eradication")) {
      "Reconstructed recovery and survey record"
    } else {
      "Abundance through time"
    },
    ylim = abundance_ylim, xaxt = "n", xaxs = "i", yaxs = "i"
  )
  graphics::polygon(
    c(calendar_years, rev(calendar_years)),
    c(quantiles$q025, rev(quantiles$q975)),
    col = grDevices::adjustcolor("#7fb6b3", alpha.f = 0.35),
    border = NA
  )
  graphics::lines(calendar_years, quantiles$median, lwd = 2, col = "#126a73")
  graphics::axis(1, at = calibrate_calendar_ticks(reference_id))
  if (identical(reference_id, "04_rodent_eradication")) {
    graphics::points(
      calibrate_calendar_years(reference_id, observed$projection_year),
      observed$abundance,
      pch = 21, bg = "#f2c14e", col = "#5f4300", cex = 1.25
    )
    graphics::points(
      calibrate_calendar_years(reference_id, released$projection_year),
      released$abundance,
      pch = 24, bg = "#315c88", col = "#183a58", cex = 1.25
    )
    graphics::legend(
      "topleft",
      c(
        "Model median", "95% simulation interval",
        "Reported survey counts", "208 released"
      ),
      lwd = c(2, NA, NA, NA), pch = c(NA, 15, 21, 24),
      pt.bg = c(
        NA, grDevices::adjustcolor("#7fb6b3", alpha.f = 0.35),
        "#f2c14e", "#315c88"
      ),
      col = c(
        "#126a73", grDevices::adjustcolor("#7fb6b3", alpha.f = 0.35),
        "#5f4300", "#183a58"
      ),
      bty = "n", cex = 0.78
    )
  } else {
    graphics::legend(
      "topleft", c("Median", "95% simulation interval"),
      lwd = c(2, NA), pch = c(NA, 15),
      pt.bg = c(NA, grDevices::adjustcolor("#7fb6b3", alpha.f = 0.35)),
      col = c(
        "#126a73",
        grDevices::adjustcolor("#7fb6b3", alpha.f = 0.35)
      ),
      bty = "n", cex = 0.8
    )
  }
  invisible(NULL)
}

calibrate_plot_risk <- function(run,
                                reference_id = run$scenario_id) {
  extinction <- run$extinction_evidence$cumulative
  calendar_years <- calibrate_calendar_years(reference_id, extinction$year)
  old_par <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(old_par), add = TRUE)
  graphics::par(mar = c(4.2, 4.6, 3.2, 1.2), mgp = c(2.7, 0.8, 0), las = 1)
  graphics::plot(
    calendar_years, extinction$probability,
    type = "l", lwd = 2, col = "#a63d40", ylim = c(0, 1),
    xlab = "Year", ylab = "Cumulative probability",
    main = "Cumulative risk through time",
    xaxt = "n", yaxt = "n", xaxs = "i", yaxs = "i"
  )
  graphics::axis(1, at = calibrate_calendar_ticks(reference_id))
  graphics::axis(
    2,
    at = seq(0, 1, by = 0.2),
    labels = sprintf("%.1f", seq(0, 1, by = 0.2)),
    las = 1
  )
  graphics::abline(h = seq(0, 1, by = 0.2), col = "#d8dfdd", lty = 3)
  graphics::lines(
    calendar_years, extinction$probability,
    lwd = 2, col = "#a63d40"
  )
  if (identical(reference_id, "05_future_baseline")) {
    quasi <- run$quasi_extinction_50_pairs$cumulative
    graphics::lines(
      calibrate_calendar_years(reference_id, quasi$year),
      quasi$probability,
      lwd = 2, col = "#9a6a14"
    )
    graphics::legend(
      "topleft", c("Extinction", "Below 100 pairs"),
      col = c("#a63d40", "#9a6a14"), lwd = 2, bty = "n"
    )
  } else {
    graphics::legend(
      "topleft", "Extinction",
      col = "#a63d40", lwd = 2, bty = "n"
    )
  }
  invisible(NULL)
}

calibrate_plot_timing <- function(run,
                                  reference_id = run$scenario_id) {
  years <- run$extinction_evidence$first_extinction_year
  years <- years[!is.na(years)]
  calendar_range <- calibrate_calendar_years(
    reference_id,
    c(0, as.integer(run$horizon))
  )
  years <- calibrate_calendar_years(reference_id, years)
  old_par <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(old_par), add = TRUE)
  graphics::par(mar = c(4.2, 4.6, 3.2, 1.2), mgp = c(2.7, 0.8, 0), las = 1)
  if (!length(years)) {
    graphics::plot(
      NA, xlim = calendar_range, ylim = c(0, 1),
      xlab = "Year of extinction", ylab = "Number of simulated futures",
      main = "When extinction occurred", xaxt = "n", yaxt = "n", xaxs = "i"
    )
    graphics::axis(1, at = calibrate_calendar_ticks(reference_id))
    graphics::axis(2, at = 0)
    midpoint <- mean(calendar_range)
    graphics::text(
      midpoint, 0.52, "No simulated extinctions",
      cex = 1.05, col = "#4a5b59"
    )
    graphics::text(
      midpoint, 0.39, "All futures persisted to the final year",
      cex = 0.85, col = "#667572"
    )
  } else {
    graphics::hist(
      years,
      breaks = seq(
        calendar_range[[1L]] - 0.5,
        calendar_range[[2L]] + 0.5,
        by = 1
      ),
      col = "#d9795f", border = "white",
      xlim = calendar_range, xaxs = "i", xaxt = "n",
      xlab = "Year of extinction", ylab = "Number of simulated futures",
      main = "When extinction occurred"
    )
    graphics::axis(1, at = calibrate_calendar_ticks(reference_id))
    graphics::abline(
      v = stats::median(years),
      col = "#7d2528", lwd = 2, lty = 2
    )
    graphics::legend(
      "topright", "Median among extinct futures",
      col = "#7d2528", lwd = 2, lty = 2, bty = "n", cex = 0.8
    )
  }
  invisible(NULL)
}

calibrate_summary_table <- function(run,
                                    reference_id = run$scenario_id) {
  metrics <- c(
    "Extinction by the final year",
    "Final median abundance",
    "95% simulation interval"
  )
  results <- c(
    sprintf("%.1f%%", 100 * run$extinction_evidence$probability_by_horizon),
    paste(calibrate_whole_birds(run$final_abundance$median), "birds"),
    sprintf(
      "%s - %s birds",
      calibrate_whole_birds(run$final_abundance$q025),
      calibrate_whole_birds(run$final_abundance$q975)
    )
  )
  if (identical(reference_id, "05_future_baseline")) {
    metrics <- c(
      metrics,
      "Breeding-territory capacity",
      "Below 100 breeding pairs by 2100"
    )
    results <- c(
      results,
      paste(calibrate_whole_birds(run$scenario$spec$K), "pairs"),
      sprintf(
        "%.1f%%",
        100 * run$quasi_extinction_50_pairs$probability_by_horizon
      )
    )
  }
  if (identical(reference_id, "04_rodent_eradication")) {
    metrics <- c(metrics, "2024 known minimum")
    results <- c(results, "1,638 birds")
  }
  data.frame(Metric = metrics, Result = results, stringsAsFactors = FALSE)
}

calibrate_comparison_table <- function(runs) {
  values <- rPVA:::compare_woodhen_1980_references(runs)$table
  data.frame(
    `Reference case` = values$student_label,
    Extinction = sprintf("%.1f%%", 100 * values$extinction_probability),
    `Median extinction year` = ifelse(
      is.na(values$extinction_conditional_median_year),
      "Not reached",
      calibrate_year_label(1980 + values$extinction_conditional_median_year)
    ),
    `Final median birds` = vapply(
      values$final_median_abundance,
      calibrate_whole_birds,
      character(1)
    ),
    `95% interval (birds)` = sprintf(
      "%s - %s",
      vapply(values$final_q025, calibrate_whole_birds, character(1)),
      vapply(values$final_q975, calibrate_whole_birds, character(1))
    ),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
}

calibrate_scenario_help_path <- function(reference_id) {
  names <- c(
    `01_no_mgmt` = "01-no-intervention.md",
    `02_pig_control` = "02-pig-control.md",
    `03_captive_pig` = "03-captive-pig.md",
    `04_rodent_eradication` = "04-rodent-eradication.md",
    `05_future_baseline` = "05-future-comparison.md"
  )
  file.path(practical2_app_dir, "content", "scenarios", unname(names[[reference_id]]))
}

calibrate_scenario_help_modal <- function(reference_id) {
  catalog <- rPVA::woodhen_reference_catalog()
  label <- catalog$label[catalog$id == reference_id][[1L]]
  modalDialog(
    title = label,
    div(
      class = "help-modal-content",
      render_markdown_content(calibrate_scenario_help_path(reference_id))
    ),
    footer = modalButton("Close"),
    easyClose = TRUE,
    size = "m"
  )
}

calibrate_reference_case_ui <- function(ns, reference_id) {
  catalog <- rPVA::woodhen_reference_catalog()
  row <- catalog[catalog$id == reference_id, , drop = FALSE]
  settings <- sprintf(
    "%d-year projection | 1,000 simulated futures | supplied scenario settings",
    row$horizon_years[[1L]]
  )

  tags$article(
    class = "reference-case",
    div(
      class = "reference-case-heading",
      div(
        h3(row$label[[1L]])
      ),
      div(
        class = "reference-case-actions",
        actionButton(
          ns(paste0("help_", reference_id)),
          "Scenario details",
          icon = icon("circle-info"),
          class = "btn-default btn-sm"
        ),
        actionButton(
          ns(paste0("run_", reference_id)),
          "Run scenario",
          icon = icon("play"),
          class = "btn-primary reference-run-action",
          `aria-label` = paste("Run", row$label[[1L]], "scenario")
        )
      )
    ),
    p(class = "reference-meaning", row$biological_meaning[[1L]]),
    p(class = "reference-settings", settings),
    uiOutput(
      ns(paste0("status_", reference_id)),
      `aria-live` = "polite",
      `aria-atomic` = "true"
    ),
    uiOutput(ns(paste0("evidence_", reference_id))),
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
        "Save notes to project",
        icon = icon("note-sticky"),
        class = "btn-default btn-sm"
      )
    )
  )
}

calibrate_help_modal <- function() {
  modalDialog(
    title = "Interpreting the historical reconstruction",
    div(
      class = "help-modal-content",
      render_markdown_content(file.path(practical2_app_dir, "content", "help-calibrate.md"))
    ),
    footer = modalButton("Close"),
    easyClose = TRUE,
    size = "m"
  )
}

calibrate_recovery_record_modal <- function() {
  record <- rPVA:::woodhen_calibration_history()$recovery_2019_2024$survey_record
  rows <- lapply(seq_len(nrow(record)), function(index) {
    tags$tr(
      tags$th(scope = "row", record$event[[index]]),
      tags$td(record$reported_count[[index]]),
      tags$td(record$survey_context[[index]]),
      tags$td(record$teaching_use[[index]])
    )
  })
  modalDialog(
    title = "Woodhen recovery survey record",
    div(
      class = "help-modal-content recovery-record-content",
      p(
        "These records show a strong recovery, but they are not perfectly",
        "standardised. Survey season, coverage, chicks, and the treatment of",
        "Mt Gower differ among years."
      ),
      tags$table(
        class = "table table-condensed recovery-record-table",
        tags$thead(tags$tr(
          tags$th("Record"), tags$th("Reported count"),
          tags$th("Survey context"), tags$th("Use in this practical")
        )),
        tags$tbody(rows)
      ),
      p(
        class = "recovery-record-note",
        "The model comparison uses the plotted survey counts as historical",
        "context. It does not treat their agreement with the model as independent validation."
      )
    ),
    footer = modalButton("Close"),
    easyClose = TRUE,
    size = "l"
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
        span(class = "section-eyebrow", "Phase 1: Calibrate against history"),
        h1("Reconstruct the Woodhen management story"),
        p(
          "Revisit the management decisions behind the Woodhen recovery, compare",
          "only compatible time periods, and decide what the model can and cannot support."
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
        "starting population, 40-year horizon, and 1,000 simulated futures."
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
      div(
        class = "recovery-record-action",
        p("Open the survey record to see which counts are comparable and where caution is needed."),
        actionButton(
          ns("open_recovery_record"),
          "View survey record",
          icon = icon("table-list"),
          class = "btn-default btn-sm"
        )
      ),
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

    project_fingerprint <- reactive({
      candidate <- project()
      if (is.null(candidate)) "no-active-project" else candidate$project_fingerprint
    })

    reconcile_project_state <- function(candidate) {
      progress <- setNames(lapply(reference_ids, function(reference_id) {
        run <- completed_run(reference_id, candidate)
        if (is.null(run)) {
          c(completed = 0L, total = 1000L)
        } else {
          c(completed = as.integer(run$reps), total = as.integer(run$reps))
        }
      }), reference_ids)
      statuses <- setNames(vapply(reference_ids, function(reference_id) {
        if (is.null(completed_run(reference_id, candidate))) {
          "Not run in this project."
        } else {
          "Saved results loaded from this project."
        }
      }, character(1)), reference_ids)
      progress_state(progress)
      status_state(statuses)
      progress_history(list())
      invisible(NULL)
    }

    observeEvent(project_fingerprint(), {
      reconcile_project_state(project())
    }, ignoreInit = FALSE)

    observeEvent(input$open_recovery_record, {
      showModal(calibrate_recovery_record_modal())
    })

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
        help_input <- paste0("help_", reference_id)
        save_input <- paste0("save_notes_", reference_id)

        observeEvent(input[[help_input]], {
          showModal(calibrate_scenario_help_modal(reference_id))
        })

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
          action <- withProgress(
            message = paste("Running", rPVA::woodhen_reference_catalog()$label[
              rPVA::woodhen_reference_catalog()$id == reference_id
            ]),
            value = 0.02,
            {
              setProgress(0.02, detail = "Preparing 1,000 simulated futures")
              tryCatch(
                rPVA:::run_woodhen_reference_project(
                  candidate,
                  reference_id,
                  progress = function(completed, total) {
                    set_reference_progress(reference_id, completed, total)
                    setProgress(
                      0.04 + 0.90 * completed / total,
                      detail = paste(
                        format(completed, big.mark = ","), "of",
                        format(total, big.mark = ","), "futures completed"
                      )
                    )
                  },
                  runner = scenario_runner
                ),
                error = function(error) error
              )
            }
          )
          if (inherits(action, "error")) {
            message <- paste("Reference run failed:", conditionMessage(action))
            set_reference_status(reference_id, message)
            publish_update(list(ok = FALSE, reference_id = reference_id, message = message))
            return()
          }
          set_reference_progress(reference_id, 1000L, 1000L, record = FALSE)
          message <- if (isTRUE(action$reused)) {
            "This scenario was already complete; the saved results are shown."
          } else {
            "Scenario complete. Results saved to your investigation."
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
          set_reference_status(
            reference_id,
            paste(
              "Notes saved to your project. You can add them to the Evidence",
              "Portfolio later from Evidence Studio."
            )
          )
          publish_update(list(
            ok = TRUE,
            candidate = updated,
            reference_id = reference_id,
            run_id = run$run_id,
            reused = TRUE,
            message = "Explicit observations saved."
          ))
        })

        output[[paste0("status_", reference_id)]] <- renderUI({
          message <- status_state()[[reference_id]]
          div(class = "reference-state", message)
        })

        output[[paste0("evidence_", reference_id)]] <- renderUI({
          run <- completed_run(reference_id)
          if (is.null(run)) return(NULL)
          label <- rPVA::woodhen_reference_catalog()$label[
            rPVA::woodhen_reference_catalog()$id == reference_id
          ]
          evidence_grid <- div(
            class = "reference-evidence-grid",
            div(
              class = "reference-evidence-panel",
              role = "img",
              `aria-label` = paste("Abundance trajectory evidence for", label),
              plotOutput(session$ns(paste0("trajectory_", reference_id)), height = "350px")
            ),
            div(
              class = "reference-evidence-panel",
              role = "img",
              `aria-label` = paste("Risk evidence for", label),
              plotOutput(session$ns(paste0("risk_", reference_id)), height = "350px")
            ),
            div(
              class = "reference-evidence-panel",
              role = "img",
              `aria-label` = paste("Extinction timing evidence for", label),
              plotOutput(session$ns(paste0("timing_", reference_id)), height = "350px")
            ),
            uiOutput(session$ns(paste0("summary_", reference_id)))
          )
          if (identical(reference_id, "03_captive_pig")) {
            tagList(
              evidence_grid,
              div(
                class = "reference-intervention-panel reference-intervention-figure",
                h4("Captive-breeding intervention: first decade"),
                p("The close-up shows when birds were taken into captivity and when modelled releases occurred."),
                plotOutput(session$ns(paste0("intervention_", reference_id)), height = "420px")
              )
            )
          } else {
            evidence_grid
          }
        })

        output[[paste0("summary_", reference_id)]] <- renderUI({
          run <- completed_run(reference_id)
          req(run)
          timing <- if (run$extinction_evidence$extinct_reps == 0L) {
            "No simulated futures reached extinction."
          } else {
            median_year <- calibrate_calendar_years(
              reference_id, run$extinction_evidence$conditional_median_year
            )
            paste0(
              "Median extinction year among futures that went extinct: ",
              calibrate_year_label(median_year), "."
            )
          }
          evidence <- list(
            div(strong("Extinction by the final year"),
              span(sprintf("%.1f%%", 100 * run$extinction_evidence$probability_by_horizon))),
            div(strong("Final median abundance"),
              span(calibrate_whole_birds(run$final_abundance$median))),
            div(strong("95% simulation interval"),
              span(sprintf("%s - %s",
                calibrate_whole_birds(run$final_abundance$q025),
                calibrate_whole_birds(run$final_abundance$q975)
              )))
          )
          if (identical(reference_id, "05_future_baseline")) {
            evidence[[length(evidence) + 1L]] <- div(
              strong("Breeding-territory capacity"),
              span(paste(calibrate_whole_birds(run$scenario$spec$K), "pairs"))
            )
            evidence[[length(evidence) + 1L]] <- div(
              strong("Below 100 breeding pairs by 2100"),
              span(sprintf("%.1f%%", 100 * run$quasi_extinction_50_pairs$probability_by_horizon))
            )
          }
          if (identical(reference_id, "04_rodent_eradication")) {
            evidence[[length(evidence) + 1L]] <- div(
              strong("2024 known minimum"),
              span("1,638 birds")
            )
          }
          div(
            class = "reference-evidence-panel reference-result-summary",
            h4("Key results"),
            evidence,
            p(class = "reference-timing-note", timing)
          )
        })

        output[[paste0("trajectory_", reference_id)]] <- renderPlot({
          run <- completed_run(reference_id)
          req(run)
          quantiles <- run$annual_quantiles
          calendar_years <- calibrate_calendar_years(reference_id, quantiles$year)
          abundance_ylim <- calibrate_abundance_ylim(quantiles)
          if (identical(reference_id, "04_rodent_eradication")) {
            recovery <- rPVA:::woodhen_calibration_history()$recovery_2019_2024
            observed <- recovery$observed_points
            released <- recovery$release_marker
            abundance_ylim[[2L]] <- max(abundance_ylim[[2L]], 1.08 * max(observed$abundance))
          }
          old_par <- par(no.readonly = TRUE)
          on.exit(par(old_par), add = TRUE)
          par(mar = c(4.2, 4.6, 3.2, 1.2), mgp = c(2.7, 0.8, 0), las = 1)
          plot(
            calendar_years, quantiles$median,
            type = "l", lwd = 2, col = "#126a73",
            xlab = "Year",
            ylab = "Number of birds",
            main = if (identical(reference_id, "04_rodent_eradication")) {
              "Reconstructed recovery and survey record"
            } else {
              "Abundance through time"
            },
            ylim = abundance_ylim,
            xaxt = "n",
            xaxs = "i", yaxs = "i"
          )
          polygon(
            c(calendar_years, rev(calendar_years)),
            c(quantiles$q025, rev(quantiles$q975)),
            col = grDevices::adjustcolor("#7fb6b3", alpha.f = 0.35), border = NA
          )
          lines(calendar_years, quantiles$median, lwd = 2, col = "#126a73")
          axis(1, at = calibrate_calendar_ticks(reference_id))
          if (identical(reference_id, "04_rodent_eradication")) {
            points(calibrate_calendar_years(reference_id, observed$projection_year), observed$abundance,
              pch = 21, bg = "#f2c14e", col = "#5f4300", cex = 1.25
            )
            points(calibrate_calendar_years(reference_id, released$projection_year), released$abundance,
              pch = 24, bg = "#315c88", col = "#183a58", cex = 1.25
            )
            legend("topleft", c(
              "Model median", "95% simulation interval", "Reported survey counts", "208 released"
            ),
              lwd = c(2, NA, NA, NA), pch = c(NA, 15, 21, 24),
              pt.bg = c(
                NA, grDevices::adjustcolor("#7fb6b3", alpha.f = 0.35),
                "#f2c14e", "#315c88"
              ),
              col = c(
                "#126a73", grDevices::adjustcolor("#7fb6b3", alpha.f = 0.35),
                "#5f4300", "#183a58"
              ),
              bty = "n", cex = 0.78
            )
          } else {
            legend("topleft", c("Median", "95% simulation interval"),
              lwd = c(2, NA), pch = c(NA, 15),
              pt.bg = c(NA, grDevices::adjustcolor("#7fb6b3", alpha.f = 0.35)),
              col = c("#126a73", grDevices::adjustcolor("#7fb6b3", alpha.f = 0.35)),
              bty = "n", cex = 0.8
            )
          }
        }, res = 96)

        output[[paste0("risk_", reference_id)]] <- renderPlot({
          run <- completed_run(reference_id)
          req(run)
          extinction <- run$extinction_evidence$cumulative
          calendar_years <- calibrate_calendar_years(reference_id, extinction$year)
          old_par <- par(no.readonly = TRUE)
          on.exit(par(old_par), add = TRUE)
          par(mar = c(4.2, 4.6, 3.2, 1.2), mgp = c(2.7, 0.8, 0), las = 1)
          plot(
            calendar_years, extinction$probability,
            type = "l", lwd = 2, col = "#a63d40", ylim = c(0, 1),
            xlab = "Year", ylab = "Cumulative probability",
            main = "Cumulative risk through time",
            xaxt = "n", yaxt = "n", xaxs = "i", yaxs = "i"
          )
          axis(1, at = calibrate_calendar_ticks(reference_id))
          axis(2, at = seq(0, 1, by = 0.2), labels = sprintf("%.1f", seq(0, 1, by = 0.2)), las = 1)
          abline(h = seq(0, 1, by = 0.2), col = "#d8dfdd", lty = 3)
          lines(calendar_years, extinction$probability, type = "l", lwd = 2, col = "#a63d40")
          if (identical(reference_id, "05_future_baseline")) {
            quasi <- run$quasi_extinction_50_pairs$cumulative
            lines(
              calibrate_calendar_years(reference_id, quasi$year), quasi$probability,
              type = "l", lwd = 2, col = "#9a6a14"
            )
            legend("topleft", c("Extinction", "Below 100 pairs"),
              col = c("#a63d40", "#9a6a14"), lwd = 2, bty = "n")
          } else {
            legend("topleft", "Extinction", col = "#a63d40", lwd = 2, bty = "n")
          }
        }, res = 96)

        output[[paste0("timing_", reference_id)]] <- renderPlot({
          run <- completed_run(reference_id)
          req(run)
          years <- run$extinction_evidence$first_extinction_year
          years <- years[!is.na(years)]
          horizon <- as.integer(run$horizon)
          calendar_range <- calibrate_calendar_years(reference_id, c(0, horizon))
          years <- calibrate_calendar_years(reference_id, years)
          old_par <- par(no.readonly = TRUE)
          on.exit(par(old_par), add = TRUE)
          par(mar = c(4.2, 4.6, 3.2, 1.2), mgp = c(2.7, 0.8, 0), las = 1)
          if (!length(years)) {
            plot(NA,
              xlim = calendar_range, ylim = c(0, 1),
              xlab = "Year of extinction", ylab = "Number of simulated futures",
              main = "When extinction occurred", xaxt = "n", yaxt = "n", xaxs = "i"
            )
            axis(1, at = calibrate_calendar_ticks(reference_id))
            axis(2, at = 0)
            midpoint <- mean(calendar_range)
            text(midpoint, 0.52, "No simulated extinctions", cex = 1.05, col = "#4a5b59")
            text(midpoint, 0.39, "All futures persisted to the final year", cex = 0.85, col = "#667572")
          } else {
            breaks <- seq(calendar_range[[1L]] - 0.5, calendar_range[[2L]] + 0.5, by = 1)
            hist(years,
              breaks = breaks, col = "#d9795f", border = "white",
              xlim = calendar_range, xaxs = "i", xaxt = "n",
              xlab = "Year of extinction", ylab = "Number of simulated futures",
              main = "When extinction occurred"
            )
            axis(1, at = calibrate_calendar_ticks(reference_id))
            abline(v = stats::median(years), col = "#7d2528", lwd = 2, lty = 2)
            legend("topright", "Median among extinct futures",
              col = "#7d2528", lwd = 2, lty = 2, bty = "n", cex = 0.8
            )
          }
        }, res = 96)

        if (identical(reference_id, "03_captive_pig")) {
          output[[paste0("intervention_", reference_id)]] <- renderPlot({
            run <- completed_run(reference_id)
            req(run)
            quantiles <- run$annual_quantiles
            quantiles <- quantiles[quantiles$year <= 10L, , drop = FALSE]
            calendar_years <- calibrate_calendar_years(reference_id, quantiles$year)
            old_par <- par(no.readonly = TRUE)
            on.exit(par(old_par), add = TRUE)
            par(mar = c(4.2, 4.6, 3.2, 1.2), mgp = c(2.7, 0.8, 0), las = 1)
            plot(
              calendar_years, quantiles$median,
              type = "n", xlim = c(1980, 1990), ylim = calibrate_abundance_ylim(quantiles),
              xaxs = "i", yaxs = "i", xlab = "Year", ylab = "Number of birds",
              main = "Population response during the intervention decade"
            )
            polygon(
              c(calendar_years, rev(calendar_years)),
              c(quantiles$q025, rev(quantiles$q975)),
              col = grDevices::adjustcolor("#7fb6b3", alpha.f = 0.35), border = NA
            )
            lines(calendar_years, quantiles$median, lwd = 2, col = "#126a73")
            abline(v = c(1981, 1982), col = "#7d2528", lwd = 2, lty = 3)
            abline(v = c(1982, 1983, 1984), col = "#315c88", lwd = 2, lty = 2)
            legend("topleft",
              c("Median abundance", "95% interval", "Captures (1981-82)", "Modelled releases (1982-84)"),
              col = c("#126a73", grDevices::adjustcolor("#7fb6b3", alpha.f = 0.35), "#7d2528", "#315c88"),
              lwd = c(2, 8, 2, 2), lty = c(1, 1, 3, 2), bty = "n", cex = 0.78
            )
          }, res = 96)
        }
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
        median_extinction_year <- if (is.na(row$extinction_conditional_median_year)) {
          "Not reached"
        } else {
          calibrate_year_label(1980 + row$extinction_conditional_median_year)
        }
          tags$tr(
            tags$th(scope = "row", row$student_label),
            tags$td(sprintf("%.1f%%", 100 * row$extinction_probability)),
            tags$td(median_extinction_year),
            tags$td(calibrate_whole_birds(row$final_median_abundance)),
            tags$td(sprintf("%s - %s",
              calibrate_whole_birds(row$final_q025),
              calibrate_whole_birds(row$final_q975)
            ))
        )
      })
      div(
        class = "historical-comparison",
        h3("Compatible 1980 comparison"),
        p("These three cases begin from the same 1980 population and run for the same 40 years, so their outcomes can be compared directly."),
        tags$table(
          class = "table table-condensed",
          tags$thead(tags$tr(
            tags$th("Reference case"), tags$th("Extinction"),
            tags$th("Median extinction year"), tags$th("Final median birds"),
            tags$th("95% interval (birds)")
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
          ready = "Common future comparison ready",
          stale = "Common future comparison needs to be rerun",
          "Common future comparison not yet run"
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
