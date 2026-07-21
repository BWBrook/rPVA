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
  scenario_id <- c(
    "01_no_mgmt",
    "02_pig_control",
    "03_captive_pig",
    "04_rodent_eradication",
    "05_future_baseline",
    "sensitivity_default",
    "survival_minus_10pct",
    "K_250",
    "K_350",
    "cat_freq_0.10",
    "cat_surv_0.40",
    "fecund_minus_20pct",
    "juvenile_survival_minus_15pct",
    "env_sd_0.15"
  )

  section <- c(rep("core_management", 5), rep("sensitivity", 9))
  label <- c(
    "No intervention",
    "Pig control",
    "Captive breeding plus pig control",
    "Rodent eradication",
    "Future baseline",
    "Sensitivity baseline",
    "Survival minus 10 percent",
    "Habitat ceiling K = 250",
    "Habitat ceiling K = 350",
    "Catastrophe frequency = 0.10",
    "Catastrophe survival = 0.40",
    "Fecundity minus 20 percent",
    "Juvenile survival minus 15 percent",
    "Environmental variation = 0.15"
  )
  years <- c(40, 40, 40, 5, 75, 75, 75, 75, 75, 75, 75, 75, 75, 75)
  changed_parameter <- c(
    "none",
    "K",
    "release schedule",
    "survival and fecundity",
    "future baseline",
    "none",
    "surv",
    "K",
    "K",
    "cat_freq",
    "cat_surv",
    "fecund",
    "juvenile_surv",
    "env_sd"
  )
  change_label <- c(
    "Historical mountain-top restricted population",
    "Increase habitat ceiling to 70 breeding pairs plus floaters",
    "Add releases after captive breeding and pig control",
    "Short-term check after rodent eradication",
    "Longer future baseline after major recovery",
    "Reference future sensitivity case",
    "Survival rates multiplied by 0.90",
    "Habitat ceiling set to 250",
    "Habitat ceiling set to 350",
    "Annual catastrophe probability set to 0.10",
    "Catastrophe-year survival multiplier set to 0.40",
    "Fecundity values multiplied by 0.80",
    "Juvenile and subadult survival values multiplied by 0.85",
    "Environmental variation set to 0.15"
  )
  teaching_note <- c(
    "This is the restricted historical population without a new management action.",
    "This scenario tests whether increased habitat access lowers risk.",
    "This scenario tests whether captive breeding releases add recovery support.",
    "This short-horizon scenario checks the effect of rodent eradication after recovery.",
    "This longer future baseline shows the recovered population under current assumptions.",
    "This is the reference case for one-factor sensitivity checks.",
    "This tests whether lower survival weakens confidence in the advice.",
    "This tests whether a lower habitat ceiling limits abundance.",
    "This tests whether partial habitat recovery limits abundance.",
    "This tests whether more frequent catastrophes change long-term risk.",
    "This tests whether harsher catastrophe years change long-term risk.",
    "This tests whether lower breeding output changes recovery confidence.",
    "This tests whether weaker early-life survival changes recovery confidence.",
    "This tests whether stronger year-to-year variation widens uncertainty."
  )
  choice_prompt <- c(
    "Use this as the no-action comparison point.",
    "Ask whether habitat recovery changes extinction risk and final abundance.",
    "Ask whether release support changes the recovery story.",
    "Ask what a short-horizon recovery check shows about near-term recovery limits.",
    "Ask how a long-horizon recovered baseline should temper management advice.",
    "Use this as the sensitivity reference row.",
    "Choose this if survival under disease or stress concerns you.",
    "Choose this if habitat area or territory availability concerns you.",
    "Choose this if habitat recovery may be incomplete.",
    "Choose this if cyclone frequency concerns you.",
    "Choose this if catastrophe severity concerns you.",
    "Choose this if breeding output or recruitment concerns you.",
    "Choose this if juvenile survival concerns you.",
    "Choose this if variable years and uncertainty concern you."
  )
  evidence_prompt <- c(
    "Use this row to show the risk of taking no extra action.",
    "Use this row to compare risk after habitat access improves.",
    "Use this row to compare release support against habitat-only action.",
    "Use this row to discuss a short recovery check.",
    "Use this row to discuss long-term recovered-population assumptions.",
    "Use this row as the reference for sensitivity comparisons.",
    "Compare PE, Nmed, and interval width with the sensitivity baseline.",
    "Compare the abundance interval with the sensitivity baseline.",
    "Compare this partial-habitat result with the sensitivity baseline.",
    "Compare risk and uncertainty with the sensitivity baseline.",
    "Compare risk and uncertainty with the sensitivity baseline.",
    "Compare abundance and interval width with the sensitivity baseline.",
    "Compare risk and abundance with the sensitivity baseline.",
    "Compare interval width and confidence with the sensitivity baseline."
  )
  horizon_note <- ifelse(
    years == 5,
    "Short 5-year horizon. Compare it carefully with longer runs.",
    ifelse(
      years == 75,
      "Long 75-year horizon. Use it for future robustness, not direct ranking against short checks.",
      "Forty-year management horizon."
    )
  )

  data.frame(
    scenario_id = scenario_id,
    section = section,
    order = seq_along(scenario_id),
    label = label,
    source_yaml = c(
      "01_no_mgmt.yaml",
      "02_pig_control.yaml",
      "03_captive_pig.yaml",
      "04_rodent_eradication.yaml",
      "05_future_baseline.yaml",
      rep("sensitivity_analysis.yaml", 9)
    ),
    years = years,
    comparison_group = c(rep("management", 5), rep("bounded_sensitivity", 9)),
    changed_parameter = changed_parameter,
    change_label = change_label,
    teaching_note = teaching_note,
    choice_prompt = choice_prompt,
    evidence_prompt = evidence_prompt,
    horizon_note = horizon_note,
    pe_zero_prompt = "PE = 0 means no replicate crossed extinction during this run. Report the horizon, seed, and replicate count with this value.",
    app_default = c(rep(TRUE, 5), rep(FALSE, 9)),
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
    return(woodhen_reference_spec(row$scenario_id[[1]]))
  }

  base <- set_scenario("sensitivity_analysis", "woodhen")
  spec <- switch(
    row$scenario_id[[1]],
    sensitivity_default = base,
    survival_minus_10pct = utils::modifyList(base, list(surv = base$surv * 0.90)),
    K_250 = utils::modifyList(base, list(K = 250)),
    K_350 = utils::modifyList(base, list(K = 350)),
    cat_freq_0.10 = utils::modifyList(base, list(cat_freq = 0.10)),
    cat_surv_0.40 = utils::modifyList(base, list(cat_surv = 0.40)),
    fecund_minus_20pct = utils::modifyList(base, list(fecund = base$fecund * 0.80)),
    juvenile_survival_minus_15pct = {
      surv <- base$surv
      surv[1:2] <- surv[1:2] * 0.85
      utils::modifyList(base, list(surv = surv))
    },
    env_sd_0.15 = utils::modifyList(base, list(env_sd = 0.15)),
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
                                                     interpretation = NULL,
                                                     choice_note = NULL) {
  run_set <- normalize_woodhen_management_run_set(runs, seed = seed)

  list(
    comparison = run_set$comparison,
    settings = run_set$settings,
    notes = woodhen_management_evidence_notes(
      run_set$comparison,
      run_set$settings,
      generated_at,
      seed,
      interpretation,
      choice_note
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
  meta <- catalog[match_index, c(
    "changed_parameter",
    "change_label",
    "teaching_note",
    "choice_prompt",
    "evidence_prompt",
    "horizon_note",
    "pe_zero_prompt"
  ), drop = FALSE]

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

  if (is.list(runs) && length(runs) > 0 && all(vapply(runs, inherits, logical(1), what = "woodhen_management_run_set"))) {
    runs <- unlist(lapply(runs, `[[`, "runs"), recursive = FALSE)
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

woodhen_management_evidence_notes <- function(comparison,
                                              settings,
                                              generated_at,
                                              seed,
                                              interpretation = NULL,
                                              choice_note = NULL) {
  seed_label <- if (is.null(seed)) "not fixed" else as.character(seed)
  choice_note <- validate_woodhen_management_choice_note(choice_note, comparison)

  notes <- c(
    "# Practical 2 Woodhen Evidence Notes",
    "",
    paste0("Generated: ", format_teaching_export_time(generated_at)),
    paste0("Scenarios included: ", nrow(comparison)),
    paste0("Fixed teaching seed: ", seed_label),
    "",
    "This export can include core management results and bounded sensitivity results from the same browser session.",
    "Use one-factor sensitivity runs to explain how assumptions affect management advice.",
    "Compare horizons before ranking scenarios.",
    "PE = 0 means zero observed extinctions in this simulation, with this seed and replicate count.",
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
    "- Which one-factor sensitivity result changes your confidence?",
    "- What condition would change your advice?"
  )

  if (!is.null(choice_note)) {
    choice_lines <- c(
      "",
      "## Student analytical choice",
      paste0("- Decision lens: ", choice_note$decision_lens),
      paste0("- Chosen sensitivity: ", choice_note$chosen_sensitivity),
      paste0("- Biological reason: ", choice_note$biological_reason),
      paste0("- Expected direction: ", choice_note$expected_direction),
      paste0("- Observed result: ", choice_note$observed_result),
      paste0("- Confidence change: ", choice_note$confidence_change),
      paste0("- Caveat: ", choice_note$caveat)
    )
    notes <- c(notes, choice_lines)
  }

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

normalize_woodhen_management_choice_note <- function(choice_note) {
  if (is.null(choice_note)) {
    return(NULL)
  }
  required <- c(
    "decision_lens",
    "chosen_sensitivity",
    "biological_reason",
    "expected_direction",
    "observed_result",
    "confidence_change",
    "caveat"
  )
  missing <- setdiff(required, names(choice_note))
  if (length(missing)) {
    stop("Choice note is missing required fields: ", paste(missing, collapse = ", "), call. = FALSE)
  }
  out <- lapply(choice_note[required], function(x) {
    value <- paste(x, collapse = " ")
    trimws(value)
  })
  empty <- names(out)[!nzchar(unlist(out, use.names = FALSE))]
  if (length(empty)) {
    stop("Choice note fields must be filled before export: ", paste(empty, collapse = ", "), call. = FALSE)
  }
  out
}

validate_woodhen_management_choice_note <- function(choice_note, comparison) {
  choice_note <- normalize_woodhen_management_choice_note(choice_note)
  if (is.null(choice_note)) {
    return(NULL)
  }

  if (!is.data.frame(comparison) || !"scenario_id" %in% names(comparison)) {
    stop("Comparison table must include `scenario_id` before choice notes can be exported.", call. = FALSE)
  }

  catalog <- woodhen_management_catalog()
  approved <- catalog$scenario_id[
    catalog$section == "sensitivity" &
      catalog$scenario_id != "sensitivity_default"
  ]
  chosen <- choice_note$chosen_sensitivity
  if (!chosen %in% approved) {
    stop("Chosen sensitivity must be an approved non-baseline sensitivity scenario.", call. = FALSE)
  }
  if (!chosen %in% comparison$scenario_id) {
    stop("Chosen sensitivity must be present in the exported comparison before evidence notes can be built.", call. = FALSE)
  }

  choice_note
}
