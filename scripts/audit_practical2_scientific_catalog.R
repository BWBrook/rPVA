woodhen_audit_collapse <- function(value) {
  if (length(value) == 0L) {
    return("")
  }
  paste(value, collapse = ", ")
}

woodhen_audit_mapping <- function(mapping) {
  paste(vapply(names(mapping), function(component_id) {
    component <- mapping[[component_id]]
    paste0(
      component_id, ": ", component$operator, " ",
      woodhen_audit_collapse(component$affected_fields), " [stages ",
      woodhen_audit_collapse(component$affected_stages), "]"
    )
  }, character(1)), collapse = "; ")
}

woodhen_audit_catalog_rows <- function(catalog, catalog_name) {
  rows <- lapply(seq_len(nrow(catalog)), function(i) {
    anchors <- catalog$anchors[[i]]
    if (length(anchors) == 0L) {
      anchors <- c(not_applicable = NA_real_)
    }
    data.frame(
      catalog = catalog_name,
      id = catalog$id[[i]],
      label = catalog$label[[i]],
      anchor = names(anchors),
      anchor_value = as.numeric(anchors),
      bound_min = catalog$custom_range[[i]][["min"]],
      bound_max = catalog$custom_range[[i]][["max"]],
      model_mapping = woodhen_audit_mapping(catalog$mapping[[i]]),
      affected_fields = woodhen_audit_collapse(catalog$affected_fields[[i]]),
      affected_stages = woodhen_audit_collapse(catalog$affected_stages[[i]]),
      temporal_allowance = woodhen_audit_collapse(catalog$allowed_temporal_shapes[[i]]),
      horizon_years = catalog$horizon_years[[i]],
      futures = 1000L,
      seed = 123L,
      breeding_pair_definition = "Strictly fewer than 50 territory-holding breeding pairs; stages 2 onward are summed and stage 1 floaters are excluded.",
      source_or_rationale = catalog$source_or_rationale[[i]],
      interpretation_help = catalog$interpretation_help[[i]],
      limitation = catalog$limitation[[i]],
      catalog_version = catalog$catalog_version[[i]],
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

woodhen_audit_markdown_cell <- function(value) {
  value <- ifelse(is.na(value), "", as.character(value))
  gsub("|", "\\|", value, fixed = TRUE)
}

#' Write the Practical 2 scientific catalogue audit tables
#'
#' @param output_dir Caller-supplied directory for the CSV and Markdown files.
#' @return Named list containing the two written file paths.
audit_practical2_scientific_catalog <- function(output_dir) {
  if (!is.character(output_dir) || length(output_dir) != 1L || is.na(output_dir) || !nzchar(output_dir)) {
    stop("`output_dir` must be one non-empty directory path.", call. = FALSE)
  }
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  }
  if (!dir.exists(output_dir)) {
    stop("Could not create audit output directory: ", output_dir, call. = FALSE)
  }

  audit <- do.call(rbind, list(
    woodhen_audit_catalog_rows(woodhen_reference_catalog(), "reference"),
    woodhen_audit_catalog_rows(woodhen_sensitivity_catalog(), "sensitivity"),
    woodhen_audit_catalog_rows(woodhen_threat_catalog(), "threat"),
    woodhen_audit_catalog_rows(woodhen_intervention_catalog(), "intervention")
  ))
  rownames(audit) <- NULL

  csv_path <- file.path(output_dir, "practical2_scientific_catalog.csv")
  markdown_path <- file.path(output_dir, "practical2_scientific_catalog.md")
  utils::write.csv(audit, csv_path, row.names = FALSE, na = "")

  display_columns <- c(
    "catalog", "id", "anchor", "anchor_value", "bound_min", "bound_max",
    "model_mapping", "temporal_allowance", "horizon_years", "seed"
  )
  display <- audit[, display_columns, drop = FALSE]
  header <- paste0("| ", paste(names(display), collapse = " | "), " |")
  divider <- paste0("| ", paste(rep("---", ncol(display)), collapse = " | "), " |")
  body <- apply(display, 1L, function(row) {
    paste0("| ", paste(woodhen_audit_markdown_cell(row), collapse = " | "), " |")
  })
  markdown <- c(
    "# Practical 2 Woodhen Scientific Catalogue Audit",
    "",
    "Locked future horizon: 75 years; 1,000 futures; common comparison seed: 123.",
    "Breeding-pair definition: strictly fewer than 50 territory-holding breeding pairs; stages 2 onward are summed and stage 1 floaters are excluded.",
    "All prospective anchors are pedagogical design bounds unless a real source is cited; they are not empirical prescriptions.",
    "",
    header,
    divider,
    body,
    "",
    "## Scientific Notes",
    "",
    "- Cyclone presets change cat_freq only to 0.07, 0.10, or 0.15. cat_repro is never silently included.",
    "- Supplementation releases 5, 10, or 15 stage-2 female-equivalent breeding pairs annually for three years.",
    "- Sea-level rise is represented only as a linear K habitat pathway.",
    "- Every annual state must satisfy K >= 150, K >= 3*K_sd, and survival/env_sd beta feasibility."
  )
  writeLines(markdown, markdown_path, useBytes = TRUE)

  list(csv = csv_path, markdown = markdown_path)
}
