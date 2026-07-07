#' Practical 2 Woodhen management scenario catalog
#'
#' Returns the bounded scenarios used by the Practical 2 Woodhen Management
#' Lab. Core scenarios come directly from the repo-local Woodhen YAML files;
#' sensitivity scenarios are one-factor presets based on `sensitivity_analysis`.
#'
#' @return A data frame with scenario IDs, display labels, source YAML files,
#'   comparison groups, changed parameters, and app-default status.
#' @export
woodhen_management_catalog <- function() {
  data.frame(
    scenario_id = c(
      "01_no_mgmt",
      "02_pig_control",
      "03_captive_pig",
      "04_rodent_eradication",
      "05_future_baseline",
      "sensitivity_default",
      "survival_minus_10pct",
      "K_250",
      "cat_freq_0.10"
    ),
    section = c(rep("core_management", 5), rep("sensitivity", 4)),
    order = seq_len(9),
    label = c(
      "No intervention",
      "Pig control",
      "Captive breeding plus pig control",
      "Rodent eradication",
      "Future baseline",
      "Sensitivity baseline",
      "Survival minus 10 percent",
      "Habitat ceiling K = 250",
      "Catastrophe frequency = 0.10"
    ),
    source_yaml = c(
      "01_no_mgmt.yaml",
      "02_pig_control.yaml",
      "03_captive_pig.yaml",
      "04_rodent_eradication.yaml",
      "05_future_baseline.yaml",
      rep("sensitivity_analysis.yaml", 4)
    ),
    years = c(40, 40, 40, 5, 75, 75, 75, 75, 75),
    comparison_group = c(rep("management", 5), rep("bounded_sensitivity", 4)),
    changed_parameter = c(
      "none",
      "K",
      "release schedule",
      "survival and fecundity",
      "future baseline",
      "none",
      "surv",
      "K",
      "cat_freq"
    ),
    change_label = c(
      "Historical mountain-top restricted population",
      "Increase habitat ceiling to 70 breeding pairs plus floaters",
      "Add releases after captive breeding and pig control",
      "Short-term check after rodent eradication",
      "Longer future baseline after major recovery",
      "Reference future sensitivity case",
      "Survival rates multiplied by 0.90",
      "Habitat ceiling set to 250",
      "Annual catastrophe probability set to 0.10"
    ),
    app_default = c(rep(TRUE, 5), rep(FALSE, 4)),
    stringsAsFactors = FALSE
  )
}

#' Build a Practical 2 Woodhen management specification
#'
#' @param scenario_id Scenario ID from `woodhen_management_catalog()`.
#' @return A validated `pva_spec`.
#' @export
build_woodhen_management_spec <- function(scenario_id) {
  row <- resolve_woodhen_management_scenario(scenario_id)

  if (identical(row$section[[1]], "core_management")) {
    return(set_scenario(row$scenario_id[[1]], "woodhen"))
  }

  base <- set_scenario("sensitivity_analysis", "woodhen")
  spec <- switch(
    row$scenario_id[[1]],
    sensitivity_default = base,
    survival_minus_10pct = utils::modifyList(base, list(surv = base$surv * 0.90)),
    K_250 = utils::modifyList(base, list(K = 250)),
    cat_freq_0.10 = utils::modifyList(base, list(cat_freq = 0.10)),
    stop("Unknown Woodhen management scenario: ", scenario_id, call. = FALSE)
  )

  spec <- validate_full_pva_spec(spec)
  class(spec) <- c("pva_spec", setdiff(class(spec), "pva_spec"))
  spec
}

#' Run one Practical 2 Woodhen management scenario
#'
#' @param scenario_id Scenario ID from `woodhen_management_catalog()`.
#' @param keep_traj Logical; keep trajectories for plotting.
#' @param seed Integer seed or NULL.
#' @param verbose Logical; passed to `run_pva_core()`.
#' @return A `woodhen_management_run` list.
#' @export
run_woodhen_management_scenario <- function(scenario_id,
                                            keep_traj = FALSE,
                                            seed = 123,
                                            verbose = FALSE) {
  row <- resolve_woodhen_management_scenario(scenario_id)
  spec <- build_woodhen_management_spec(scenario_id)
  result <- run_pva_core(spec, keep_traj = keep_traj, seed = seed, verbose = verbose)
  summary <- summarize_pva_result(result, scenario = row$label[[1]])
  diagnostics <- diagnose_pva_result(result, scenario = row$label[[1]])
  settings <- woodhen_management_settings_record(row, spec)

  structure(
    list(
      scenario_id = row$scenario_id[[1]],
      label = row$label[[1]],
      section = row$section[[1]],
      spec = spec,
      result = result,
      summary = summary,
      diagnostics = diagnostics,
      settings = settings
    ),
    class = c("woodhen_management_run", "list")
  )
}

#' Run a Practical 2 Woodhen management scenario set
#'
#' @param scenario_ids Scenario IDs from `woodhen_management_catalog()`. Defaults
#'   to the core management app path.
#' @param keep_traj Logical; keep trajectories for plotting.
#' @param seed Integer seed or NULL.
#' @param verbose Logical; passed to `run_pva_core()`.
#' @return A `woodhen_management_run_set` list with runs, comparison, and settings.
#' @export
run_woodhen_management_set <- function(scenario_ids = NULL,
                                       keep_traj = FALSE,
                                       seed = 123,
                                       verbose = FALSE) {
  catalog <- woodhen_management_catalog()
  if (is.null(scenario_ids)) {
    scenario_ids <- catalog$scenario_id[catalog$app_default]
  }

  runs <- lapply(
    scenario_ids,
    run_woodhen_management_scenario,
    keep_traj = keep_traj,
    seed = seed,
    verbose = verbose
  )
  comparison <- compare_woodhen_management_runs(runs)
  settings <- woodhen_management_settings_table(runs)

  structure(
    list(
      runs = runs,
      comparison = comparison,
      settings = settings,
      seed = seed
    ),
    class = c("woodhen_management_run_set", "list")
  )
}

#' Build a Practical 2 Woodhen evidence export
#'
#' @param runs A `woodhen_management_run_set` or non-empty list of
#'   `woodhen_management_run` objects.
#' @param generated_at Time stamp for the notes.
#' @param seed Integer seed or NULL.
#' @param interpretation Optional student interpretation note.
#' @return A list with comparison, settings, and Markdown notes.
#' @export
build_woodhen_management_evidence_export <- function(runs,
                                                     generated_at = Sys.time(),
                                                     seed = 123,
                                                     interpretation = NULL) {
  run_set <- normalize_woodhen_management_run_set(runs, seed = seed)

  list(
    comparison = run_set$comparison,
    settings = run_set$settings,
    notes = woodhen_management_evidence_notes(
      run_set$comparison,
      run_set$settings,
      generated_at,
      seed,
      interpretation
    )
  )
}

resolve_woodhen_management_scenario <- function(scenario_id) {
  if (!is.character(scenario_id) || length(scenario_id) != 1 || is.na(scenario_id) || scenario_id == "") {
    stop("`scenario_id` must be a single Woodhen management scenario ID.", call. = FALSE)
  }

  catalog <- woodhen_management_catalog()
  match <- catalog[catalog$scenario_id == scenario_id, , drop = FALSE]
  if (nrow(match) == 0) {
    stop("Unknown Woodhen management scenario: ", scenario_id, call. = FALSE)
  }
  match[1, , drop = FALSE]
}

compare_woodhen_management_runs <- function(runs) {
  validate_woodhen_management_runs(runs)

  scenario_ids <- vapply(runs, `[[`, character(1), "scenario_id")
  labels <- vapply(runs, `[[`, character(1), "label")
  sections <- vapply(runs, `[[`, character(1), "section")
  results <- lapply(runs, `[[`, "result")
  comparison <- compare_pva_results(results, scenarios = labels)

  catalog <- woodhen_management_catalog()
  match_index <- match(scenario_ids, catalog$scenario_id)
  meta <- catalog[match_index, c("changed_parameter", "change_label"), drop = FALSE]

  out <- data.frame(
    scenario_id = scenario_ids,
    section = sections,
    label = labels,
    meta,
    comparison,
    row.names = NULL,
    stringsAsFactors = FALSE
  )
  rownames(out) <- NULL
  out
}

woodhen_management_settings_table <- function(runs) {
  validate_woodhen_management_runs(runs)

  out <- do.call(
    rbind,
    lapply(seq_along(runs), function(i) {
      settings <- runs[[i]]$settings
      data.frame(
        run_id = rep(i, nrow(settings)),
        settings,
        stringsAsFactors = FALSE
      )
    })
  )
  rownames(out) <- NULL
  out
}

woodhen_management_settings_record <- function(row, spec) {
  spec_fields <- c(
    "name",
    "years",
    "reps",
    "K",
    "K_sd",
    "demographic_stochasticity",
    "env_sd",
    "genetics",
    "cat_freq",
    "cat_surv",
    "cat_repro",
    "F_init",
    "surv",
    "n0"
  )
  meta_values <- as.list(row[1, c("source_yaml", "changed_parameter", "change_label")])
  names(meta_values) <- paste0("meta_", names(meta_values))

  spec_values <- spec[intersect(spec_fields, names(spec))]
  names(spec_values) <- paste0("spec_", names(spec_values))

  values <- c(meta_values, spec_values)

  data.frame(
    scenario_id = rep(row$scenario_id[[1]], length(values)),
    section = rep(row$section[[1]], length(values)),
    label = rep(row$label[[1]], length(values)),
    setting = names(values),
    value = vapply(values, collapse_setting_value, character(1)),
    stringsAsFactors = FALSE
  )
}

normalize_woodhen_management_run_set <- function(runs, seed) {
  if (inherits(runs, "woodhen_management_run_set")) {
    return(runs)
  }

  validate_woodhen_management_runs(runs)
  structure(
    list(
      runs = runs,
      comparison = compare_woodhen_management_runs(runs),
      settings = woodhen_management_settings_table(runs),
      seed = seed
    ),
    class = c("woodhen_management_run_set", "list")
  )
}

validate_woodhen_management_runs <- function(runs) {
  if (!is.list(runs) || length(runs) == 0) {
    stop("`runs` must be a non-empty list of Woodhen management run bundles.", call. = FALSE)
  }
  valid <- vapply(runs, inherits, logical(1), what = "woodhen_management_run")
  if (!all(valid)) {
    stop("Every item in `runs` must be returned by run_woodhen_management_scenario().", call. = FALSE)
  }
  invisible(runs)
}

woodhen_management_evidence_notes <- function(comparison, settings, generated_at, seed, interpretation = NULL) {
  seed_label <- if (is.null(seed)) "not fixed" else as.character(seed)

  notes <- c(
    "# Practical 2 Woodhen Evidence Notes",
    "",
    paste0("Generated: ", format_teaching_export_time(generated_at)),
    paste0("Scenarios included: ", nrow(comparison)),
    paste0("Fixed teaching seed: ", seed_label),
    "",
    "Use this export with the comparison CSV from the same browser session.",
    "Use one-factor sensitivity runs to explain how assumptions affect management advice.",
    "",
    "## Comparison table",
    utils::capture.output(utils::write.table(
      comparison,
      sep = "\t",
      row.names = FALSE,
      quote = FALSE
    )),
    "",
    "## Settings and provenance",
    utils::capture.output(utils::write.table(
      settings,
      sep = "\t",
      row.names = FALSE,
      quote = FALSE
    )),
    "",
    "## Interpretation prompts",
    "- Which scenario gives the strongest evidence for lower extinction risk?",
    "- Which scenario gives the strongest evidence for higher final abundance?",
    "- Which uncertainty interval should temper your recommendation?",
    "- Which one-factor sensitivity result changes your confidence?"
  )

  if (!is.null(interpretation) && nzchar(trimws(interpretation))) {
    notes <- c(
      notes,
      "",
      "## Student interpretation note",
      trimws(interpretation)
    )
  }

  notes
}
