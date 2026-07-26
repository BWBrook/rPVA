evidence_required_item_fields <- function() {
  c(
    "evidence_schema_version", "evidence_id", "kind", "source_family_id",
    "source_run_ids", "view_id", "title", "observation_id", "created_at",
    "modified_at"
  )
}

evidence_project_items <- function(project) {
  if (is.null(project) || is.null(project$evidence_items) ||
      length(project$evidence_items) == 0L) {
    return(list())
  }
  items <- project$evidence_items
  if (!is.list(items)) {
    stop("`project$evidence_items` must be a list.", call. = FALSE)
  }
  required <- evidence_required_item_fields()
  for (index in seq_along(items)) {
    item <- items[[index]]
    if (!is.list(item) || is.null(names(item)) ||
        length(setdiff(required, names(item))) > 0L) {
      stop(
        "Every portfolio item must contain the Evidence Portfolio fields.",
        call. = FALSE
      )
    }
    if (!is.character(item$evidence_id) || length(item$evidence_id) != 1L ||
        is.na(item$evidence_id) || !nzchar(item$evidence_id) ||
        !is.character(item$kind) || length(item$kind) != 1L ||
        is.na(item$kind) ||
        !item$kind %in% c("plot", "table", "observation")) {
      stop("A portfolio item has an invalid identity or kind.", call. = FALSE)
    }
  }
  item_ids <- vapply(items, `[[`, character(1), "evidence_id")
  if (anyDuplicated(item_ids)) {
    stop("Portfolio evidence IDs must be unique.", call. = FALSE)
  }
  persisted <- if (is.character(project$evidence_ids)) {
    project$evidence_ids
  } else {
    character()
  }
  persisted <- persisted[persisted %in% item_ids]
  order_ids <- c(persisted, setdiff(item_ids, persisted))
  items[match(order_ids, item_ids)]
}

evidence_item_ids <- function(items) {
  if (length(items) == 0L) return(character())
  vapply(items, `[[`, character(1), "evidence_id")
}

evidence_request_already_added <- function(request, project) {
  items <- evidence_project_items(project)
  if (length(items) == 0L) return(FALSE)
  if (!is.null(request$observation_id)) {
    return(any(vapply(items, function(item) {
      identical(item$observation_id, request$observation_id)
    }, logical(1))))
  }
  any(vapply(items, function(item) {
    identical(item$source_run_ids, request$source_run_ids) &&
      identical(item$observation_id, request$observation_id) &&
      identical(item$view_id, request$view_id)
  }, logical(1)))
}

evidence_project_source_candidates <- function(project) {
  if (is.null(project) || !is.list(project$runs) ||
      length(project$runs) == 0L) {
    return(list())
  }
  known_run_ids <- vapply(project$runs, `[[`, character(1), "run_id")
  candidates <- list()
  observations <- if (is.list(project$observations)) {
    project$observations
  } else {
    list()
  }
  for (observation in observations) {
    request <- list(
      source_run_ids = observation$run_ids,
      observation_id = observation$observation_id,
      view_id = "saved_observation",
      title = observation$title
    )
    if (all(observation$run_ids %in% known_run_ids) &&
        !evidence_request_already_added(request, project)) {
      candidates[[length(candidates) + 1L]] <- list(
        candidate_id = paste0("note_", observation$observation_id),
        source_type = "observation",
        observation_id = observation$observation_id,
        title = observation$title,
        description = observation$note,
        requests = list(request)
      )
    }
  }

  reference_runs <- project$runs[vapply(
    project$runs,
    function(run) identical(run$scenario_type, "reference"),
    logical(1)
  )]
  views <- c(
    "calibration_trajectory", "calibration_risk",
    "calibration_timing", "calibration_summary"
  )
  view_titles <- c(
    "population trajectory", "extinction and warning risk",
    "extinction timing", "result summary"
  )
  for (run in reference_runs) {
    requests <- lapply(seq_along(views), function(index) {
      list(
        source_run_ids = run$run_id,
        observation_id = NULL,
        view_id = views[[index]],
        title = paste(run$student_label, "-", view_titles[[index]])
      )
    })
    requests <- requests[!vapply(
      requests,
      evidence_request_already_added,
      logical(1),
      project = project
    )]
    if (length(requests)) {
      candidates[[length(candidates) + 1L]] <- list(
        candidate_id = paste0("reference_", run$run_id),
        source_type = "reference_result_set",
        observation_id = NULL,
        title = paste(run$student_label, "result set"),
        description = paste(
          "Population trajectory, risk, extinction timing and result summary",
          "from this completed historical reconstruction."
        ),
        requests = requests
      )
    }
  }

  required_1980 <- c("01_no_mgmt", "02_pig_control", "03_captive_pig")
  scenario_ids <- vapply(reference_runs, function(run) {
    value <- run$scenario_id
    if (is.null(value) || length(value) != 1L) "" else as.character(value)
  }, character(1))
  indices <- match(required_1980, scenario_ids)
  if (!anyNA(indices)) {
    run_ids <- vapply(
      reference_runs[indices],
      `[[`,
      character(1),
      "run_id"
    )
    request <- list(
      source_run_ids = run_ids,
      observation_id = NULL,
      view_id = "calibration_comparison_table",
      title = "Compatible 1980 management comparison"
    )
    if (!evidence_request_already_added(request, project)) {
      candidates[[length(candidates) + 1L]] <- list(
        candidate_id = "calibration_1980_comparison",
        source_type = "reference_comparison",
        observation_id = NULL,
        title = "Compatible 1980 management comparison",
        description = paste(
          "A single table comparing no intervention, pig control, and captive",
          "breeding plus pig control over the same historical period."
        ),
        requests = list(request)
      )
    }
  }
  candidates
}

evidence_add_from_project_event <- function(requests,
                                            project_fingerprint,
                                            event_id) {
  list(
    action = "add_from_project",
    requests = requests,
    base_project_fingerprint = project_fingerprint,
    event_id = event_id,
    message = "Project evidence added to the Evidence Portfolio."
  )
}

evidence_source_input_id <- function(candidate_id) {
  paste0("add_source_", gsub("[^A-Za-z0-9_]", "_", candidate_id))
}

evidence_filter_items <- function(items,
                                  source_family_id = "all",
                                  kind = "all") {
  if (length(items) == 0L) return(list())
  keep <- rep(TRUE, length(items))
  if (!identical(source_family_id, "all")) {
    keep <- keep & vapply(
      items,
      function(item) identical(item$source_family_id, source_family_id),
      logical(1)
    )
  }
  if (!identical(kind, "all")) {
    keep <- keep & vapply(
      items,
      function(item) identical(item$kind, kind),
      logical(1)
    )
  }
  items[keep]
}

evidence_observation_for_item <- function(item, project) {
  if (!identical(item$kind, "observation") ||
      is.null(item$observation_id) || length(item$observation_id) != 1L ||
      is.na(item$observation_id) || !nzchar(item$observation_id) ||
      is.null(project$observations) || length(project$observations) == 0L) {
    return(NULL)
  }
  ids <- vapply(
    project$observations,
    function(observation) {
      value <- observation$observation_id
      if (is.null(value) || length(value) != 1L) "" else as.character(value)
    },
    character(1)
  )
  index <- match(item$observation_id, ids)
  if (is.na(index)) NULL else project$observations[[index]]
}

evidence_runs_for_item <- function(item, project) {
  if (is.null(project$runs) || length(project$runs) == 0L ||
      length(item$source_run_ids) == 0L) {
    return(list())
  }
  run_ids <- vapply(
    project$runs,
    function(run) {
      value <- run$run_id
      if (is.null(value) || length(value) != 1L) "" else as.character(value)
    },
    character(1)
  )
  indices <- match(item$source_run_ids, run_ids)
  project$runs[indices[!is.na(indices)]]
}

evidence_kind_label <- function(kind) {
  switch(
    kind,
    plot = "Plot",
    table = "Table",
    observation = "Student note",
    "Evidence"
  )
}

evidence_kind_icon <- function(kind) {
  switch(
    kind,
    plot = "chart-line",
    table = "table",
    observation = "note-sticky",
    "file"
  )
}

evidence_count_noun <- function(count, singular, plural) {
  if (identical(as.integer(count), 1L)) singular else plural
}

evidence_view_label <- function(view_id) {
  switch(
    view_id,
    population = "Population through time",
    risk = "Warning risk through time",
    final = "Final population size",
    passage = "First passage below 100 pairs",
    response = "Response to the tested change",
    comparison_table = "Comparison table",
    comparison_note = "Comparison note",
    saved_observation = "Saved observation",
    calibration_trajectory = "Population trajectory",
    calibration_risk = "Extinction and warning risk",
    calibration_timing = "Extinction timing",
    calibration_summary = "Result summary",
    calibration_comparison_table = "Compatible 1980 comparison",
    "Saved evidence"
  )
}

evidence_family_label <- function(item, project) {
  runs <- evidence_runs_for_item(item, project)
  if (length(runs) == 0L) return("Saved comparison")
  types <- vapply(runs, `[[`, character(1), "scenario_type")
  labels <- vapply(runs, function(run) {
    label <- run$student_label
    if (is.null(label) || length(label) != 1L || is.na(label) || !nzchar(label)) {
      "Saved scenario"
    } else {
      label
    }
  }, character(1))
  if (all(types == "reference")) {
    scenario_ids <- vapply(runs, function(run) {
      value <- run$scenario_id
      if (is.null(value) || length(value) != 1L) "" else as.character(value)
    }, character(1))
    if (setequal(
      scenario_ids,
      c("01_no_mgmt", "02_pig_control", "03_captive_pig")
    )) {
      return("1980 management reconstruction")
    }
    return(labels[[1L]])
  }
  if (any(types == "sensitivity")) {
    baseline <- which(types == "locked_baseline")
    if (length(baseline)) {
      return(sub(" - locked baseline$", "", labels[[baseline[[1L]]]]))
    }
  }
  threat <- which(types == "threat")
  if (length(threat)) {
    return(paste(labels[[threat[[1L]]]], "and management"))
  }
  "Saved comparison"
}

evidence_role_label <- function(scenario_type) {
  switch(
    scenario_type,
    locked_baseline = "No-change reference",
    sensitivity = "Alternative setting",
    threat = "Threatened future",
    intervention = "Managed threatened future",
    reference = "Historical reconstruction",
    historical = "Historical reconstruction",
    "Saved scenario"
  )
}

evidence_item_source_label <- function(item, project) {
  runs <- evidence_runs_for_item(item, project)
  if (length(runs) == 0L) {
    return("Saved comparison")
  }
  labels <- vapply(
    runs,
    function(run) {
      if (identical(run$scenario_type, "locked_baseline")) {
        return("Common future")
      }
      label <- run$student_label
      if (is.null(label) || length(label) != 1L || is.na(label) || !nzchar(label)) {
        "Saved scenario"
      } else {
        label
      }
    },
    character(1)
  )
  paste(labels, collapse = " / ")
}

evidence_run_metadata_table <- function(item, project) {
  runs <- evidence_runs_for_item(item, project)
  if (length(runs) == 0L) {
    return(data.frame(
      Source = "Saved comparison",
      Detail = paste(
        length(item$source_run_ids),
        if (length(item$source_run_ids) == 1L) "source run" else "source runs",
        "recorded"
      ),
      stringsAsFactors = FALSE
    ))
  }
  value_or <- function(run, field, default = "Not recorded") {
    value <- run[[field]]
    if (is.null(value) || length(value) != 1L || is.na(value)) default else value
  }
  data.frame(
    Scenario = vapply(
      runs,
      function(run) as.character(value_or(run, "student_label", run$run_id)),
      character(1)
    ),
    Role = vapply(
      runs,
      function(run) evidence_role_label(
        as.character(value_or(run, "scenario_type"))
      ),
      character(1)
    ),
    Horizon = vapply(
      runs,
      function(run) {
        value <- value_or(run, "horizon")
        if (is.numeric(value)) paste(value, "years") else as.character(value)
      },
      character(1)
    ),
    Futures = vapply(
      runs,
      function(run) {
        value <- value_or(run, "reps")
        if (is.numeric(value)) format(value, big.mark = ",") else as.character(value)
      },
      character(1)
    ),
    stringsAsFactors = FALSE
  )
}

evidence_preview_table <- function(item, project) {
  runs <- evidence_runs_for_item(item, project)
  if (identical(item$view_id, "calibration_summary") &&
      length(runs) == 1L) {
    return(calibrate_summary_table(runs[[1L]]))
  }
  if (identical(item$view_id, "calibration_comparison_table") &&
      length(runs) == 3L) {
    return(calibrate_comparison_table(runs))
  }
  if (length(runs) > 0L) {
    comparison <- tryCatch(
      rPVA::compare_woodhen_run_family(
        runs,
        family_id = item$source_family_id
      ),
      error = function(...) NULL
    )
    if (!is.null(comparison) && is.data.frame(comparison$table) &&
        nrow(comparison$table) > 0L) {
      return(compare_probe_table(compare_live_family(comparison)))
    }
  }
  evidence_run_metadata_table(item, project)
}

evidence_calibration_plot_views <- function() {
  c("calibration_trajectory", "calibration_risk", "calibration_timing")
}

evidence_render_calibration_plot <- function(item, project) {
  runs <- evidence_runs_for_item(item, project)
  if (length(runs) != 1L ||
      !item$view_id %in% evidence_calibration_plot_views()) {
    return(invisible(FALSE))
  }
  switch(
    item$view_id,
    calibration_trajectory = calibrate_plot_trajectory(runs[[1L]]),
    calibration_risk = calibrate_plot_risk(runs[[1L]]),
    calibration_timing = calibrate_plot_timing(runs[[1L]])
  )
  invisible(TRUE)
}

evidence_plot_from_comparison <- function(view_id, comparison) {
  evidence <- compare_live_evidence(comparison)
  switch(
    view_id,
    population = compare_population_plot(evidence),
    risk = compare_risk_plot(evidence),
    final = compare_final_plot(evidence),
    passage = compare_passage_plot(evidence),
    response = if (identical(comparison$family_type, "sensitivity")) {
      investigate_sensitivity_probe_plot(evidence$response)
    } else {
      compare_management_response_plot(evidence)
    },
    NULL
  )
}

evidence_preview_plot <- function(item, project) {
  runs <- evidence_runs_for_item(item, project)
  if (length(runs) == 0L) return(NULL)
  attempt <- function(expression) {
    tryCatch(expression, error = function(...) NULL)
  }
  if (length(runs) == 1L) {
    return(switch(
      item$view_id,
      population = attempt(rPVA::plot_woodhen_trajectory_evidence(runs[[1L]])),
      trajectory = attempt(rPVA::plot_woodhen_trajectory_evidence(runs[[1L]])),
      final = attempt(rPVA::plot_woodhen_final_distribution(runs[[1L]])),
      risk = attempt(rPVA::plot_woodhen_risk_evidence(runs[[1L]])),
      NULL
    ))
  }
  comparison <- attempt(rPVA::compare_woodhen_run_family(
    runs,
    family_id = item$source_family_id
  ))
  if (is.null(comparison)) return(NULL)
  attempt(evidence_plot_from_comparison(item$view_id, comparison))
}

evidence_export_max_items <- 100L

evidence_export_slug <- function(value,
                                  fallback = "evidence",
                                  max_chars = 60L) {
  text <- if (is.null(value) || length(value) == 0L || is.na(value[[1L]])) {
    ""
  } else {
    as.character(value[[1L]])
  }
  text <- iconv(text, from = "", to = "ASCII//TRANSLIT", sub = "")
  text <- gsub("[^A-Za-z0-9_.-]+", "_", text)
  text <- gsub("^[_ .-]+|[_ .-]+$", "", text)
  if (!nzchar(text)) text <- fallback
  max_chars <- max(1L, as.integer(max_chars[[1L]]))
  substr(text, 1L, max_chars)
}

evidence_neutralise_csv_cell <- function(value) {
  if (!is.character(value) || length(value) != 1L || is.na(value)) {
    return(value)
  }
  if (substr(value, 1L, 1L) %in% c("=", "+", "-", "@", "\t", "\r")) {
    paste0("'", value)
  } else {
    value
  }
}

evidence_export_items <- function(project, evidence_ids) {
  if (!is.character(evidence_ids) || length(evidence_ids) == 0L) {
    stop("select at least one evidence item before downloading.", call. = FALSE)
  }
  if (length(evidence_ids) > evidence_export_max_items) {
    stop(
      paste0("maximum export size is ", evidence_export_max_items, " items."),
      call. = FALSE
    )
  }
  if (anyNA(evidence_ids) || any(!nzchar(evidence_ids))) {
    stop("Evidence IDs must be non-empty text.", call. = FALSE)
  }
  if (anyDuplicated(evidence_ids)) {
    stop("Evidence IDs in an export must be unique.", call. = FALSE)
  }
  items <- evidence_project_items(project)
  known <- evidence_item_ids(items)
  unknown <- setdiff(evidence_ids, known)
  if (length(unknown)) {
    stop(
      paste0("unknown evidence ID: ", paste(unknown, collapse = ", ")),
      call. = FALSE
    )
  }
  items[match(evidence_ids, known)]
}

evidence_write_plot_png <- function(item, project, path) {
  plot <- NULL
  if (item$view_id %in% evidence_calibration_plot_views()) {
    plot <- tryCatch({
      grDevices::png(path, width = 1800L, height = 1200L, res = 144L)
      ok <- evidence_render_calibration_plot(item, project)
      grDevices::dev.off()
      if (isTRUE(ok)) TRUE else FALSE
    }, error = function(...) {
      try(grDevices::dev.off(), silent = TRUE)
      FALSE
    })
  } else {
    plot <- tryCatch(evidence_preview_plot(item, project), error = function(...) NULL)
    if (!is.null(plot)) {
      plot <- tryCatch({
        grDevices::png(path, width = 1800L, height = 1200L, res = 144L)
        print(plot)
        grDevices::dev.off()
        TRUE
      }, error = function(...) {
        try(grDevices::dev.off(), silent = TRUE)
        FALSE
      })
    } else {
      FALSE
    }
  }
  if (!isTRUE(plot) && file.exists(path)) unlink(path)
  isTRUE(plot) && file.exists(path)
}

evidence_write_table_csv <- function(item, project, path) {
  table <- tryCatch(evidence_preview_table(item, project), error = function(...) NULL)
  if (!is.data.frame(table)) return(FALSE)
  table[] <- lapply(table, function(column) {
    if (is.character(column)) {
      vapply(column, evidence_neutralise_csv_cell, character(1))
    } else {
      column
    }
  })
  utils::write.csv(table, path, row.names = FALSE, na = "", fileEncoding = "UTF-8")
  file.exists(path)
}

evidence_html_escape <- function(value) {
  htmltools::htmlEscape(if (is.null(value)) "" else as.character(value))
}

evidence_html_table <- function(table) {
  if (!is.data.frame(table) || ncol(table) == 0L) return("<p>Table unavailable.</p>")
  headers <- paste0("<th>", vapply(names(table), evidence_html_escape, character(1)), "</th>")
  rows <- if (nrow(table)) vapply(seq_len(nrow(table)), function(index) {
    cells <- vapply(table[index, , drop = TRUE], function(value) {
      paste0("<td>", evidence_html_escape(value), "</td>")
    }, character(1))
    paste0("<tr>", paste(cells, collapse = ""), "</tr>")
  }, character(1)) else character()
  paste0(
    "<table><thead><tr>", paste(headers, collapse = ""),
    "</tr></thead><tbody>", paste(rows, collapse = ""), "</tbody></table>"
  )
}

evidence_dossier_html <- function(items, project, assets = list(), generated_at = Sys.time()) {
  project_title <- if (is.null(project$title) || !nzchar(as.character(project$title))) {
    "Untitled project"
  } else as.character(project$title)
  item_blocks <- vapply(seq_along(items), function(index) {
    item <- items[[index]]
    asset <- if (length(assets) >= index) assets[[index]] else list()
    provenance <- evidence_run_metadata_table(item, project)
    provenance_html <- evidence_html_table(provenance)
    content <- if (identical(item$kind, "observation")) {
      observation <- evidence_observation_for_item(item, project)
      if (is.null(observation)) {
        "<p><strong>Evidence unavailable:</strong> The linked student note is unavailable in the active project.</p>"
      } else {
        paste0("<p class=\"student-note\">", evidence_html_escape(observation$note), "</p>")
      }
    } else if (identical(item$kind, "plot")) {
      if (!is.null(asset$png) && nzchar(asset$png)) {
        paste0("<p><img src=\"", evidence_html_escape(asset$png), "\" alt=\"",
               evidence_html_escape(item$title), "\"></p>")
      } else {
        "<p><strong>Evidence unavailable:</strong> This plot could not be reconstructed from the saved project evidence.</p>"
      }
    } else {
      table <- tryCatch(evidence_preview_table(item, project), error = function(...) NULL)
      csv_link <- if (!is.null(asset$csv) && nzchar(asset$csv)) {
        paste0("<p>Companion CSV: <code>", evidence_html_escape(asset$csv), "</code></p>")
      } else ""
      metadata <- evidence_run_metadata_table(item, project)
      unavailable <- is.null(table) || (
        length(evidence_runs_for_item(item, project)) > 0L &&
          identical(table, metadata)
      )
      notice <- if (unavailable) {
        "<p><strong>Evidence unavailable:</strong> The selected table could not be reconstructed from the saved project evidence; the provenance metadata below is retained.</p>"
      } else ""
      paste0(csv_link, notice, evidence_html_table(table))
    }
    paste0(
      "<section><h2>", index, ". ", evidence_html_escape(item$title), "</h2>",
      "<p><strong>Evidence type:</strong> ", evidence_html_escape(evidence_kind_label(item$kind)),
      "<br><strong>Source:</strong> ", evidence_html_escape(evidence_family_label(item, project)),
      "<br><strong>Saved view:</strong> ", evidence_html_escape(evidence_view_label(item$view_id)),
      "</p><h3>Relevant run provenance</h3>", provenance_html, content, "</section>"
    )
  }, character(1))
  paste0(
    "<!doctype html><html><head><meta charset=\"utf-8\"><title>Evidence dossier</title>",
    "<style>body{font-family: sans-serif; line-height:1.35} section{page-break-before:always} table{border-collapse:collapse} th,td{border:1px solid #999;padding:4px;text-align:left} img{max-width:100%} code{font-family:monospace}</style>",
    "</head><body><h1>Evidence dossier</h1>",
    "<p><strong>Project:</strong> ", evidence_html_escape(project_title),
    "<br><strong>Generated:</strong> ", evidence_html_escape(format(generated_at, tz = "UTC", usetz = TRUE)),
    "<br>This dossier contains selected source material and student notes with their saved scientific provenance. It does not generate assessment interpretations or recommendations.</p>",
    paste(item_blocks, collapse = ""), "</body></html>"
  )
}

write_evidence_dossier_bundle <- function(project,
                                          evidence_ids,
                                          path,
                                          generated_at = Sys.time()) {
  items <- evidence_export_items(project, evidence_ids)
  staging <- tempfile("evidence-export-")
  dir.create(staging, recursive = TRUE, showWarnings = FALSE)
  Sys.chmod(staging, mode = "0700")
  on.exit(unlink(staging, recursive = TRUE, force = TRUE), add = TRUE)
  dir.create(file.path(staging, "figures"), mode = "0700")
  dir.create(file.path(staging, "tables"), mode = "0700")
  Sys.chmod(c(file.path(staging, "figures"), file.path(staging, "tables")), mode = "0700")
  assets <- vector("list", length(items))
  for (index in seq_along(items)) {
    item <- items[[index]]
    base <- paste0(sprintf("%03d", index), "-", evidence_export_slug(item$title))
    if (identical(item$kind, "plot")) {
      relative <- file.path("figures", paste0(base, ".png"))
      absolute <- file.path(staging, relative)
      if (evidence_write_plot_png(item, project, absolute)) assets[[index]] <- list(png = relative)
    } else if (identical(item$kind, "table")) {
      relative <- file.path("tables", paste0(base, ".csv"))
      absolute <- file.path(staging, relative)
      if (evidence_write_table_csv(item, project, absolute)) assets[[index]] <- list(csv = relative)
    }
  }
  html_path <- file.path(staging, "evidence-dossier.html")
  writeLines(evidence_dossier_html(items, project, assets, generated_at), html_path, useBytes = TRUE)
  docx_path <- file.path(staging, "evidence-dossier.docx")
  rmarkdown::pandoc_convert(html_path, to = "docx", output = docx_path, wd = staging)
  files <- c("evidence-dossier.docx", unlist(lapply(assets, function(asset) {
    if (is.null(asset)) character() else unname(unlist(asset))
  }), use.names = FALSE))
  zip::zipr(
    path,
    files = files,
    root = staging,
    include_directories = FALSE,
    mode = "mirror"
  )
  invisible(path)
}

evidence_help_modal <- function() {
  shiny::modalDialog(
    title = "Using your Evidence Portfolio",
    shiny::div(
      class = "help-modal-content",
      render_markdown_content(file.path(
        practical2_app_dir, "content", "help-evidence.md"
      ))
    ),
    footer = shiny::modalButton("Close"),
    easyClose = TRUE,
    size = "l"
  )
}

evidence_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::div(
    class = "page-shell evidence-shell",
    shiny::tags$header(
      class = "evidence-header",
      shiny::div(
        shiny::span(class = "section-eyebrow", "Evidence Portfolio"),
        shiny::h1("Your evidence portfolio"),
        shiny::p(
          "Collect model outputs and notes while you investigate. Inspect their",
          "source, arrange them, and choose what to include in an export."
        )
      ),
      shiny::actionButton(
        ns("open_help"),
        "Portfolio guide",
        icon = shiny::icon("circle-info"),
        class = "btn-default btn-sm"
      )
    ),
    shiny::uiOutput(ns("portfolio_summary")),
    shiny::uiOutput(ns("project_sources")),
    shiny::div(
      class = "evidence-workspace",
      shiny::tags$section(
        class = "evidence-library-panel",
        shiny::div(
          class = "evidence-section-heading",
          shiny::div(
            shiny::span(class = "workspace-label", "Saved evidence"),
            shiny::h2("Portfolio library")
          ),
          shiny::div(
            class = "evidence-section-actions",
            shiny::actionButton(
              ns("open_project_sources"),
              "Add from project",
              icon = shiny::icon("folder-plus"),
              class = "btn-primary btn-sm"
            ),
            shiny::p(
              "These are the plots, tables, and notes you explicitly added.",
              "Portfolio order is preserved with the project."
            )
          )
        ),
        shiny::div(
          class = "evidence-filter-row",
          shiny::selectInput(
            ns("source_filter"),
            "Evidence source",
            choices = c("All evidence sources" = "all"),
            selected = "all"
          ),
          shiny::selectInput(
            ns("type_filter"),
            "Evidence type",
            choices = c(
              "All types" = "all",
              "Plots" = "plot",
              "Tables" = "table",
              "Student notes" = "observation"
            ),
            selected = "all"
          )
        ),
        shiny::uiOutput(ns("portfolio_library"))
      ),
      shiny::tags$section(
        class = "evidence-export-panel",
        shiny::div(
          class = "evidence-section-heading",
          shiny::div(
            shiny::span(class = "workspace-label", "Separate export choice"),
            shiny::h2("Export workspace")
          ),
          shiny::p(
            paste(
              "Use Include in this export beside any saved item.",
              "Items not included in this export remain in your project portfolio."
            )
          )
        ),
        shiny::div(
          class = "evidence-export-actions",
          shiny::actionButton(
            ns("select_all_export"),
            "Select all",
            icon = shiny::icon("check-double"),
            class = "btn-default btn-sm"
          ),
          shiny::actionButton(
            ns("clear_export"),
            "Clear export selection",
            icon = shiny::icon("xmark"),
            class = "btn-default btn-sm"
          )
        ),
        shiny::uiOutput(ns("export_order")),
        shiny::uiOutput(ns("export_preview")),
        shiny::uiOutput(ns("export_control"))
      )
    )
  )
}

evidence_server <- function(id, project = NULL) {
  shiny::moduleServer(id, function(input, output, session) {
    event_counter <- shiny::reactiveVal(0L)
    portfolio_event <- shiny::reactiveVal(NULL)
    export_ids <- shiny::reactiveVal(character())
    preview_id <- shiny::reactiveVal(NULL)
    project_sources_open <- shiny::reactiveVal(FALSE)
    registered_item_ids <- new.env(parent = emptyenv())
    registered_source_ids <- new.env(parent = emptyenv())

    project_value <- shiny::reactive({
      if (is.function(project)) project() else project
    })
    items <- shiny::reactive({
      evidence_project_items(project_value())
    })
    portfolio_ids <- shiny::reactive({
      evidence_item_ids(items())
    })
    source_candidates <- shiny::reactive({
      evidence_project_source_candidates(project_value())
    })

    publish_event <- function(action,
                              evidence_id = NULL,
                              evidence_ids = NULL,
                              requests = NULL) {
      candidate <- project_value()
      if (is.null(candidate) || is.null(candidate$project_fingerprint)) {
        return(invisible(FALSE))
      }
      next_id <- shiny::isolate(event_counter()) + 1L
      event_counter(next_id)
      if (identical(action, "remove")) {
        value <- list(
          action = "remove",
          evidence_id = evidence_id,
          base_project_fingerprint = candidate$project_fingerprint,
          event_id = next_id,
          message = "Evidence item removed from the portfolio."
        )
      } else if (identical(action, "reorder")) {
        value <- list(
          action = "reorder",
          evidence_ids = evidence_ids,
          base_project_fingerprint = candidate$project_fingerprint,
          event_id = next_id,
          message = "Portfolio order updated."
        )
      } else {
        value <- evidence_add_from_project_event(
          requests = requests,
          project_fingerprint = candidate$project_fingerprint,
          event_id = next_id
        )
      }
      portfolio_event(value)
      invisible(TRUE)
    }

    move_id <- function(ids, evidence_id, direction) {
      position <- match(evidence_id, ids)
      target <- position + direction
      if (is.na(position) || target < 1L || target > length(ids)) return(ids)
      ids[c(position, target)] <- ids[c(target, position)]
      ids
    }

    filtered_items <- shiny::reactive({
      evidence_filter_items(
        items(),
        if (is.null(input$source_filter)) "all" else input$source_filter,
        if (is.null(input$type_filter)) "all" else input$type_filter
      )
    })

    shiny::observeEvent(portfolio_ids(), {
      known <- portfolio_ids()
      export_ids(export_ids()[export_ids() %in% known])
      if (!is.null(preview_id()) && !preview_id() %in% known) preview_id(NULL)
      families <- unique(vapply(
        items(),
        `[[`,
        character(1),
        "source_family_id"
      ))
      family_items <- items()[match(
        families,
        vapply(items(), `[[`, character(1), "source_family_id")
      )]
      family_labels <- vapply(
        family_items,
        evidence_family_label,
        character(1),
        project = project_value()
      )
      choices <- c(
        "All evidence sources" = "all",
        stats::setNames(families, family_labels)
      )
      selected <- if (!is.null(input$source_filter) &&
          input$source_filter %in% unname(choices)) {
        input$source_filter
      } else {
        "all"
      }
      shiny::updateSelectInput(
        session, "source_filter", choices = choices, selected = selected
      )
    }, ignoreInit = FALSE)

    shiny::observeEvent(input$open_help, {
      shiny::showModal(evidence_help_modal())
    })
    shiny::observeEvent(input$open_project_sources, {
      project_sources_open(TRUE)
    })
    shiny::observeEvent(input$close_project_sources, {
      project_sources_open(FALSE)
    })
    shiny::observeEvent(source_candidates(), {
      candidates <- source_candidates()
      if (length(candidates) == 0L) return(invisible(NULL))
      candidate_ids <- vapply(candidates, `[[`, character(1), "candidate_id")
      for (candidate_id in candidate_ids) {
        input_id <- evidence_source_input_id(candidate_id)
        if (exists(
          input_id,
          envir = registered_source_ids,
          inherits = FALSE
        )) {
          next
        }
        local({
          source_id <- candidate_id
          source_input <- input_id
          registered_source_ids[[source_input]] <- TRUE
          shiny::observeEvent(input[[source_input]], {
            current <- source_candidates()
            ids <- if (length(current)) {
              vapply(current, `[[`, character(1), "candidate_id")
            } else {
              character()
            }
            index <- match(source_id, ids)
            if (!is.na(index)) {
              publish_event(
                "add_from_project",
                requests = current[[index]]$requests
              )
            }
          }, ignoreInit = TRUE)
        })
      }
    }, ignoreInit = FALSE)
    shiny::observeEvent(input$select_all_export, {
      export_ids(portfolio_ids())
      lapply(portfolio_ids(), function(evidence_id) {
        shiny::updateCheckboxInput(
          session, paste0("include_", evidence_id), value = TRUE
        )
      })
    })
    shiny::observeEvent(input$clear_export, {
      export_ids(character())
      lapply(portfolio_ids(), function(evidence_id) {
        shiny::updateCheckboxInput(
          session, paste0("include_", evidence_id), value = FALSE
        )
      })
    })

    shiny::observeEvent(items(), {
      new_ids <- evidence_item_ids(items())
      new_ids <- new_ids[!vapply(
        new_ids,
        exists,
        logical(1),
        envir = registered_item_ids,
        inherits = FALSE
      )]
      lapply(new_ids, function(item_id) {
        local({
          evidence_id <- item_id
          assign(evidence_id, TRUE, envir = registered_item_ids)
          shiny::observeEvent(input[[paste0("include_", evidence_id)]], {
            ids <- export_ids()
            include <- isTRUE(input[[paste0("include_", evidence_id)]])
            if (include && !evidence_id %in% ids) {
              export_ids(c(ids, evidence_id))
            } else if (!include) {
              export_ids(setdiff(ids, evidence_id))
            }
          }, ignoreInit = TRUE)
          shiny::observeEvent(input[[paste0("inspect_", evidence_id)]], {
            preview_id(evidence_id)
          })
          shiny::observeEvent(input[[paste0("inspect_export_", evidence_id)]], {
            preview_id(evidence_id)
          })
          shiny::observeEvent(input[[paste0("remove_", evidence_id)]], {
            publish_event("remove", evidence_id = evidence_id)
          })
          shiny::observeEvent(input[[paste0("portfolio_up_", evidence_id)]], {
            reordered <- move_id(portfolio_ids(), evidence_id, -1L)
            if (!identical(reordered, portfolio_ids())) {
              publish_event("reorder", evidence_ids = reordered)
            }
          })
          shiny::observeEvent(input[[paste0("portfolio_down_", evidence_id)]], {
            reordered <- move_id(portfolio_ids(), evidence_id, 1L)
            if (!identical(reordered, portfolio_ids())) {
              publish_event("reorder", evidence_ids = reordered)
            }
          })
          shiny::observeEvent(input[[paste0("export_up_", evidence_id)]], {
            export_ids(move_id(export_ids(), evidence_id, -1L))
          })
          shiny::observeEvent(input[[paste0("export_down_", evidence_id)]], {
            export_ids(move_id(export_ids(), evidence_id, 1L))
          })
        })
      })
    }, ignoreInit = FALSE)

    output$project_sources <- shiny::renderUI({
      if (!isTRUE(project_sources_open())) return(NULL)
      candidates <- source_candidates()
      if (length(candidates) == 0L) {
        return(shiny::tags$section(
          class = "evidence-project-sources",
          shiny::div(
            class = "evidence-project-sources-heading",
            shiny::div(
              shiny::span(class = "workspace-label", "Project evidence"),
              shiny::h2("Add from project")
            ),
            shiny::actionButton(
              session$ns("close_project_sources"),
              label = NULL,
              icon = shiny::icon("xmark"),
              class = "btn-default btn-sm",
              `aria-label` = "Close Add from project"
            )
          ),
          shiny::div(
            class = "evidence-library-empty",
            shiny::icon("circle-check"),
            shiny::span(
              paste(
                "There are no unadded project notes or completed Calibrate",
                "result sets."
              )
            )
          )
        ))
      }
      source_type_label <- function(source_type) {
        switch(
          source_type,
          observation = "Saved project note",
          reference_result_set = "Calibrate result set",
          reference_comparison = "Calibrate comparison",
          "Project evidence"
        )
      }
      source_action_label <- function(source_type) {
        switch(
          source_type,
          observation = "Add note",
          reference_result_set = "Add result set",
          reference_comparison = "Add comparison table",
          "Add to portfolio"
        )
      }
      shiny::tags$section(
        class = "evidence-project-sources",
        shiny::div(
          class = "evidence-project-sources-heading",
          shiny::div(
            shiny::span(class = "workspace-label", "Project evidence"),
            shiny::h2("Add from project"),
            shiny::p(
              paste(
                "Project notes are your full working record. Add any useful",
                "notes or completed Calibrate results to this portfolio."
              )
            )
          ),
          shiny::actionButton(
            session$ns("close_project_sources"),
            label = NULL,
            icon = shiny::icon("xmark"),
            class = "btn-default btn-sm",
            `aria-label` = "Close Add from project"
          )
        ),
        shiny::div(
          class = "evidence-project-source-list",
          lapply(candidates, function(candidate) {
            shiny::tags$article(
              class = "evidence-project-source-card",
              shiny::div(
                class = "evidence-project-source-copy",
                shiny::span(
                  class = "evidence-item-type",
                  source_type_label(candidate$source_type)
                ),
                shiny::h3(candidate$title),
                shiny::p(candidate$description)
              ),
              shiny::actionButton(
                session$ns(evidence_source_input_id(candidate$candidate_id)),
                source_action_label(candidate$source_type),
                icon = shiny::icon("plus"),
                class = "btn-default btn-sm"
              )
            )
          })
        )
      )
    })

    output$portfolio_summary <- shiny::renderUI({
      current <- items()
      counts <- table(factor(
        if (length(current)) {
          vapply(current, `[[`, character(1), "kind")
        } else {
          character()
        },
        levels = c("plot", "table", "observation")
      ))
      shiny::div(
        class = "evidence-portfolio-summary",
        shiny::div(
          shiny::icon("folder-open"),
          shiny::div(
            shiny::strong(paste(length(current), "saved portfolio items")),
            shiny::span(
              "Keep this as a working collection; export choices are separate."
            )
          )
        ),
        shiny::div(
          class = "evidence-portfolio-counts",
          shiny::span(
            shiny::strong(counts[["plot"]]),
            paste0(" ", evidence_count_noun(counts[["plot"]], "plot", "plots"))
          ),
          shiny::span(
            shiny::strong(counts[["table"]]),
            paste0(" ", evidence_count_noun(counts[["table"]], "table", "tables"))
          ),
          shiny::span(
            shiny::strong(counts[["observation"]]),
            paste0(
              " ",
              evidence_count_noun(counts[["observation"]], "note", "notes")
            )
          )
        )
      )
    })

    output$portfolio_library <- shiny::renderUI({
      current <- filtered_items()
      if (length(current) == 0L) {
        message <- if (length(items()) == 0L) {
          paste(
            "Your portfolio is empty. Add a plot, table, or note from Compare",
            "when you want to keep it."
          )
        } else {
          "No saved evidence matches these filters."
        }
        return(shiny::div(
          class = "evidence-library-empty",
          shiny::icon("inbox"),
          shiny::span(message)
        ))
      }
      all_ids <- portfolio_ids()
      shiny::div(
        class = "evidence-library",
        lapply(current, function(item) {
          evidence_id <- item$evidence_id
          position <- match(evidence_id, all_ids)
          shiny::tags$article(
            class = "evidence-library-item",
            shiny::div(
              class = "evidence-item-icon",
              shiny::icon(evidence_kind_icon(item$kind))
            ),
            shiny::div(
              class = "evidence-item-copy",
              shiny::span(
                class = "evidence-item-type",
                evidence_kind_label(item$kind)
              ),
              shiny::h3(item$title),
              shiny::p(evidence_item_source_label(item, project_value())),
              shiny::tags$small(evidence_view_label(item$view_id))
            ),
            shiny::div(
              class = "evidence-library-actions",
              shiny::checkboxInput(
                session$ns(paste0("include_", evidence_id)),
                "Include in this export",
                value = evidence_id %in% export_ids()
              ),
              shiny::actionButton(
                session$ns(paste0("inspect_", evidence_id)),
                "Preview",
                icon = shiny::icon("eye"),
                class = "btn-default btn-xs"
              ),
              shiny::actionButton(
                session$ns(paste0("portfolio_up_", evidence_id)),
                label = NULL,
                icon = shiny::icon("arrow-up"),
                class = "btn-default btn-xs",
                disabled = if (position == 1L) "disabled" else NULL,
                `aria-label` = paste("Move", item$title, "up in portfolio")
              ),
              shiny::actionButton(
                session$ns(paste0("portfolio_down_", evidence_id)),
                label = NULL,
                icon = shiny::icon("arrow-down"),
                class = "btn-default btn-xs",
                disabled = if (position == length(all_ids)) "disabled" else NULL,
                `aria-label` = paste("Move", item$title, "down in portfolio")
              ),
              shiny::actionButton(
                session$ns(paste0("remove_", evidence_id)),
                label = NULL,
                icon = shiny::icon("trash"),
                class = "btn-default btn-xs",
                `aria-label` = paste("Remove", item$title, "from portfolio")
              )
            )
          )
        })
      )
    })

    output$export_order <- shiny::renderUI({
      ids <- export_ids()
      if (length(ids) == 0L) {
        return(shiny::div(
          class = "evidence-order-empty",
          shiny::icon("file-circle-plus"),
          shiny::div(
            shiny::strong("No items included in this export"),
            shiny::span(
              "Use Include in this export beside any saved portfolio item."
            )
          )
        ))
      }
      current <- items()
      current_ids <- evidence_item_ids(current)
      selected <- current[match(ids, current_ids)]
      shiny::div(
        class = "evidence-selected-order",
        lapply(seq_along(selected), function(index) {
          item <- selected[[index]]
          shiny::div(
            class = "evidence-order-item",
            shiny::span(class = "evidence-order-number", index),
            shiny::div(
              class = "evidence-order-copy",
              shiny::strong(item$title),
              shiny::span(evidence_kind_label(item$kind))
            ),
            shiny::div(
              class = "evidence-order-actions",
              shiny::actionButton(
                session$ns(paste0("inspect_export_", item$evidence_id)),
                label = NULL,
                icon = shiny::icon("eye"),
                class = "btn-default btn-xs",
                `aria-label` = paste("Preview", item$title)
              ),
              shiny::actionButton(
                session$ns(paste0("export_up_", item$evidence_id)),
                label = NULL,
                icon = shiny::icon("arrow-up"),
                class = "btn-default btn-xs",
                disabled = if (index == 1L) "disabled" else NULL,
                `aria-label` = paste("Move", item$title, "up in export")
              ),
              shiny::actionButton(
                session$ns(paste0("export_down_", item$evidence_id)),
                label = NULL,
                icon = shiny::icon("arrow-down"),
                class = "btn-default btn-xs",
                disabled = if (index == length(selected)) "disabled" else NULL,
                `aria-label` = paste("Move", item$title, "down in export")
              )
            )
          )
        })
      )
    })

    active_item <- shiny::reactive({
      current <- items()
      id <- preview_id()
      if (is.null(id) || !id %in% evidence_item_ids(current)) return(NULL)
      current[[match(id, evidence_item_ids(current))]]
    })

    output$export_preview <- shiny::renderUI({
      item <- active_item()
      if (is.null(item)) {
        return(shiny::div(
          class = "evidence-active-empty",
          shiny::strong("Portfolio item preview"),
          shiny::p(
            "Choose Preview beside a saved item to inspect its content and",
            "scientific provenance."
          )
        ))
      }
      included <- item$evidence_id %in% export_ids()
      observation <- evidence_observation_for_item(item, project_value())
      preview <- if (identical(item$kind, "observation")) {
        if (is.null(observation)) {
          shiny::div(
            class = "evidence-preview-unavailable",
            "The linked student note is unavailable in the active project."
          )
        } else {
          shiny::tags$blockquote(
            class = "evidence-preview-text",
            observation$note
          )
        }
      } else if (identical(item$kind, "table")) {
        shiny::div(
          class = "evidence-preview-table",
          shiny::tableOutput(session$ns("preview_table"))
        )
      } else {
        calibration_plot <- item$view_id %in%
          evidence_calibration_plot_views()
        plot <- if (calibration_plot) {
          TRUE
        } else {
          evidence_preview_plot(item, project_value())
        }
        if (is.null(plot) || identical(plot, FALSE)) {
          shiny::div(
            class = "evidence-preview-unavailable",
            paste(
              "A rendered preview is not available from the compact evidence",
              "currently loaded. Source metadata are retained below."
            )
          )
        } else {
          shiny::plotOutput(session$ns("preview_plot"), height = "500px")
        }
      }
      shiny::tags$article(
        class = "evidence-active-preview",
        shiny::div(
          class = "evidence-active-heading",
          shiny::span(
            class = "evidence-item-type",
            shiny::icon(evidence_kind_icon(item$kind)),
            evidence_kind_label(item$kind)
          ),
          shiny::h3(item$title),
          shiny::p(if (included) {
            "Included in this export."
          } else {
            "Saved in the portfolio; not included in this export."
          })
        ),
        preview,
        shiny::tags$details(
          class = "evidence-source-details",
          shiny::tags$summary("Scientific provenance"),
          shiny::tags$dl(
            shiny::tags$dt("Evidence source"),
            shiny::tags$dd(evidence_family_label(item, project_value())),
            shiny::tags$dt("Source scenarios"),
            shiny::tags$dd(evidence_item_source_label(item, project_value())),
            shiny::tags$dt("Saved view"),
            shiny::tags$dd(evidence_view_label(item$view_id)),
            shiny::tags$dt("Authorship"),
            shiny::tags$dd(if (identical(item$kind, "observation")) {
              "Student-authored note linked to saved project evidence."
            } else {
              "Model-generated evidence from saved project runs."
            })
          )
        )
      )
    })

    output$export_control <- shiny::renderUI({
      ids <- export_ids()
      enabled <- length(ids) > 0L
      shiny::div(
        class = "evidence-export-band",
        shiny::downloadButton(
          session$ns("export_files"),
          "Export selected evidence",
          icon = shiny::icon("file-export"),
          class = "btn-primary",
          disabled = if (enabled) NULL else "disabled"
        ),
        shiny::p(
          if (enabled) {
            paste(
              "The ZIP contains evidence-dossier.docx plus numbered PNG and CSV",
              "companions for the selected items. Use it as source material for",
              "your own report."
            )
          } else {
            "Select at least one saved item to enable the evidence dossier download."
          }
        )
      )
    })

    output$export_files <- shiny::downloadHandler(
      filename = function() {
        project_snapshot <- project_value()
        project_slug <- evidence_export_slug(
          if (is.null(project_snapshot)) NULL else project_snapshot$title,
          fallback = "project",
          max_chars = 40L
        )
        paste0(project_slug, "-evidence-dossier.zip")
      },
      contentType = "application/zip",
      content = function(path) {
        project_snapshot <- project_value()
        ids_snapshot <- export_ids()
        if (is.null(project_snapshot)) {
          stop("An active project is required for an evidence export.", call. = FALSE)
        }
        write_evidence_dossier_bundle(project_snapshot, ids_snapshot, path)
      }
    )

    output$preview_table <- shiny::renderTable({
      item <- active_item()
      shiny::req(!is.null(item), identical(item$kind, "table"))
      evidence_preview_table(item, project_value())
    }, striped = TRUE, bordered = FALSE, spacing = "s", rownames = FALSE)

    output$preview_plot <- shiny::renderPlot({
      item <- active_item()
      shiny::req(!is.null(item), identical(item$kind, "plot"))
      if (item$view_id %in% evidence_calibration_plot_views()) {
        shiny::req(evidence_render_calibration_plot(item, project_value()))
        return(invisible(NULL))
      }
      plot <- evidence_preview_plot(item, project_value())
      shiny::req(!is.null(plot))
      plot
    }, res = 96)

    list(
      portfolio_ids = portfolio_ids,
      export_ids = export_ids,
      portfolio_event = portfolio_event,
      items = items,
      filtered_items = filtered_items,
      active_item = active_item
    )
  })
}
