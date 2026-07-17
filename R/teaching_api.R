#' @importFrom stats quantile rbeta rbinom rnorm rpois runif sd setNames
#' @importFrom utils modifyList
NULL

#' Practical 1 teaching stage catalog
#'
#' Returns metadata for the guided Practical 1 concept path. Stages marked as
#' not implemented are included so a future Shiny interface can show planned
#' concepts without pretending the engine supports them yet.
#'
#' @return A data frame with stage identifiers, ordering, labels, concepts,
#'   implementation status, and supported controls.
#' @export
teaching_stage_catalog <- function() {
  data.frame(
    stage = c(
      "deterministic_baseline",
      "carrying_capacity",
      "demographic_stochasticity",
      "environmental_stochasticity",
      "genetic_stochasticity",
      "catastrophe",
      "intervention",
      "extinction_vortex",
      "allee_effect",
      "correlated_events"
    ),
    order = seq_len(10),
    label = c(
      "Deterministic baseline",
      "Ceiling carrying capacity",
      "Demographic stochasticity",
      "Environmental stochasticity",
      "Genetic stochasticity",
      "Catastrophe",
      "Simple intervention",
      "Extinction vortex comparison",
      "Allee effect",
      "Correlated events"
    ),
    concept = c(
      "Fixed vital rates project a population from a starting stage vector.",
      "A habitat ceiling bounds growth even when vital rates are favourable.",
      "Discrete births and deaths make small populations diverge by chance.",
      "Shared good and bad years widen the range of possible futures.",
      "Small population size and inbreeding can compound recovery limits.",
      "Rare bad events can dominate risk despite ordinary-year growth.",
      "A bounded habitat improvement changes risk, abundance, and uncertainty.",
      "Multiple small-population threats can reinforce each other.",
      "Low-abundance recovery thresholds need a named future engine/helper path.",
      "Correlated bad years need a future helper or engine extension."
    ),
    implemented = c(rep(TRUE, 8), FALSE, FALSE),
    engine_status = c(
      rep("implemented_with_current_engine", 8),
      "deferred_no_named_engine_feature",
      "deferred_no_named_engine_feature"
    ),
    controls = c(
      "years,reps",
      "K,K_sd,years,reps",
      "K,K_sd,years,reps",
      "K,K_sd,env_sd,years,reps",
      "K,K_sd,env_sd,F_init,years,reps",
      "K,K_sd,env_sd,cat_freq,cat_surv,cat_repro,years,reps",
      "K,K_sd,env_sd,years,reps",
      "K,K_sd,env_sd,F_init,cat_freq,cat_surv,cat_repro,years,reps",
      "",
      ""
    ),
    stringsAsFactors = FALSE
  )
}

#' Build a teaching PVA specification
#'
#' Converts a supported Practical 1 teaching stage and bounded controls into a
#' validated toy-model `pva_spec`.
#'
#' @param stage Teaching stage ID from `teaching_stage_catalog()`.
#' @param controls Named list of stage-appropriate controls.
#' @param base Currently only `"toy"` is supported.
#' @return A validated `pva_spec` ready for `run_pva_core()`.
#' @export
build_teaching_spec <- function(stage, controls = list(), base = "toy") {
  stage_info <- resolve_teaching_stage(stage, require_implemented = TRUE)
  controls <- normalize_teaching_controls(stage, controls)
  teaching_controls <- controls

  if (!identical(base, "toy")) {
    stop("Only `base = \"toy\"` is currently supported for Practical 1 teaching specs.", call. = FALSE)
  }

  spec <- read_spec(system.file("extdata", "toy", "toy_demo.yaml", package = "rPVA"))
  spec <- utils::modifyList(spec, teaching_stage_defaults(stage))
  spec <- apply_teaching_vital_adjustments(spec, controls)
  controls <- controls[setdiff(names(controls), teaching_vital_adjustment_controls())]
  spec <- utils::modifyList(spec, controls)
  spec$name <- paste0("teaching_", stage_info$stage)

  spec <- validate_full_pva_spec(spec)
  for (control in teaching_vital_adjustment_controls()) {
    if (!is.null(teaching_controls[[control]])) {
      spec[[control]] <- teaching_controls[[control]]
    }
  }
  attr(spec, "teaching_controls") <- teaching_controls
  class(spec) <- c("pva_spec", setdiff(class(spec), "pva_spec"))
  spec
}

#' Run a Practical 1 teaching PVA stage
#'
#' Builds a teaching spec, runs the core PVA engine, and returns a labelled
#' bundle for Shiny or report-facing use.
#'
#' @param stage Teaching stage ID.
#' @param controls Named list of bounded controls for the stage.
#' @param keep_traj Logical; keep trajectories for plotting.
#' @param seed Integer seed or NULL.
#' @param verbose Logical; passed to `run_pva_core()`.
#' @param progress Optional replicate-progress callback passed to
#'   `run_pva_core()`.
#' @return A `teaching_pva_run` list with stage, label, spec, result, summary,
#'   diagnostics, and settings.
#' @export
run_teaching_pva <- function(stage,
                             controls = list(),
                             keep_traj = TRUE,
                             seed = 42,
                             verbose = FALSE,
                             progress = NULL) {
  stage_info <- resolve_teaching_stage(stage, require_implemented = TRUE)
  spec <- build_teaching_spec(stage, controls = controls)
  engine_spec <- spec
  engine_spec[teaching_vital_adjustment_controls()] <- NULL
  result <- run_pva_core(
    engine_spec,
    keep_traj = keep_traj,
    seed = seed,
    verbose = verbose,
    progress = progress
  )
  summary <- summarize_pva_result(result, scenario = stage_info$label)
  diagnostics <- diagnose_pva_result(result, scenario = stage_info$label)
  settings <- teaching_settings_record(stage, controls, spec)

  structure(
    list(
      stage = stage_info$stage,
      label = stage_info$label,
      spec = spec,
      result = result,
      summary = summary,
      diagnostics = diagnostics,
      settings = settings
    ),
    class = c("teaching_pva_run", "list")
  )
}

#' Compare Practical 1 teaching PVA runs
#'
#' @param runs Non-empty list of bundles returned by `run_teaching_pva()`.
#' @param include_deltas Logical; add baseline-relative teaching deltas.
#' @return A compact data frame preserving run order and stage labels.
#' @export
compare_teaching_runs <- function(runs, include_deltas = FALSE) {
  if (!is.list(runs) || length(runs) == 0) {
    stop("`runs` must be a non-empty list of teaching run bundles.", call. = FALSE)
  }
  valid <- vapply(runs, inherits, logical(1), what = "teaching_pva_run")
  if (!all(valid)) {
    stop("Every item in `runs` must be returned by run_teaching_pva().", call. = FALSE)
  }

  labels <- vapply(runs, `[[`, character(1), "label")
  stages <- vapply(runs, `[[`, character(1), "stage")
  results <- lapply(runs, `[[`, "result")
  comparison <- compare_pva_results(results, scenarios = labels)

  comparison <- data.frame(
    stage = stages,
    label = labels,
    comparison,
    row.names = NULL,
    stringsAsFactors = FALSE
  )

  if (isTRUE(include_deltas)) {
    comparison <- add_teaching_baseline_deltas(comparison)
  }

  comparison
}

build_teaching_evidence_export <- function(runs,
                                           generated_at = Sys.time(),
                                           seed = 42,
                                           interpretation = NULL,
                                           session_run_count = length(runs)) {
  run_ids <- vapply(seq_along(runs), function(i) {
    id <- runs[[i]]$session_run_id
    if (is.null(id)) as.integer(i) else as.integer(id)
  }, integer(1))
  if (anyNA(run_ids) || anyDuplicated(run_ids)) {
    stop("Evidence run IDs must be non-missing and unique.", call. = FALSE)
  }

  comparison <- compare_teaching_runs(runs, include_deltas = TRUE)
  comparison <- data.frame(
    run_id = run_ids,
    comparison,
    row.names = NULL,
    stringsAsFactors = FALSE
  )

  settings <- do.call(
    rbind,
    lapply(seq_along(runs), function(i) {
      run_settings <- runs[[i]]$settings
      if (!nrow(run_settings)) {
        return(data.frame(
          run_id = integer(),
          stage = character(),
          label = character(),
          setting = character(),
          value = character(),
          stringsAsFactors = FALSE
        ))
      }

      data.frame(
        run_id = rep(run_ids[[i]], nrow(run_settings)),
        stage = run_settings$stage,
        label = run_settings$label,
        setting = run_settings$setting,
        value = run_settings$value,
        stringsAsFactors = FALSE
      )
    })
  )
  rownames(settings) <- NULL

  list(
    comparison = comparison,
    settings = settings,
    notes = teaching_evidence_notes(
      comparison,
      settings,
      generated_at,
      seed,
      interpretation,
      session_run_count
    )
  )
}

add_teaching_baseline_deltas <- function(comparison) {
  if (!nrow(comparison)) {
    comparison$delta_PE <- numeric()
    comparison$delta_Nmed <- numeric()
    comparison$uncertainty_change <- character()
    return(comparison)
  }

  baseline <- comparison[1, , drop = FALSE]
  baseline_width <- baseline$Nhi95 - baseline$Nlo95
  widths <- comparison$Nhi95 - comparison$Nlo95

  comparison$delta_PE <- comparison$PE - baseline$PE
  comparison$delta_Nmed <- comparison$Nmed - baseline$Nmed
  comparison$uncertainty_change <- ifelse(
    seq_len(nrow(comparison)) == 1,
    "baseline",
    ifelse(widths > baseline_width, "wider",
      ifelse(widths < baseline_width, "narrower", "unchanged")
    )
  )

  comparison
}

#' Create a compact teaching settings record
#'
#' @param stage Teaching stage ID.
#' @param controls Named controls supplied by the caller.
#' @param spec Validated teaching `pva_spec`.
#' @return A data frame suitable for later export by a Shiny app.
#' @export
teaching_settings_record <- function(stage, controls, spec) {
  stage_info <- resolve_teaching_stage(stage, require_implemented = TRUE)
  controls <- normalize_control_list(controls)

  control_rows <- settings_rows(stage_info, paste0("control_", names(controls)), controls)
  spec_fields <- c(
    "name",
    "years",
    "reps",
    "mortality_pct",
    "fecundity_pct",
    "K",
    "K_sd",
    "demographic_stochasticity",
    "env_sd",
    "genetics",
    "cat_freq",
    "cat_surv",
    "cat_repro",
    "F_init",
    "n0"
  )
  spec_values <- spec[intersect(spec_fields, names(spec))]
  spec_values <- utils::modifyList(
    list(
      mortality_pct = attr(spec, "teaching_controls")$mortality_pct,
      fecundity_pct = attr(spec, "teaching_controls")$fecundity_pct
    ),
    spec_values
  )
  spec_values <- spec_values[!vapply(spec_values, is.null, logical(1))]
  spec_rows <- settings_rows(stage_info, paste0("spec_", names(spec_values)), spec_values)

  out <- rbind(control_rows, spec_rows)
  rownames(out) <- NULL
  out
}

resolve_teaching_stage <- function(stage, require_implemented = FALSE) {
  if (!is.character(stage) || length(stage) != 1 || is.na(stage) || stage == "") {
    stop("`stage` must be a single teaching stage ID.", call. = FALSE)
  }

  catalog <- teaching_stage_catalog()
  match <- catalog[catalog$stage == stage, , drop = FALSE]
  if (nrow(match) == 0) {
    stop("Unknown teaching stage: ", stage, call. = FALSE)
  }
  if (require_implemented && !isTRUE(match$implemented[[1]])) {
    stop("Teaching stage `", stage, "` is catalogued but not implemented by the current engine.", call. = FALSE)
  }

  match[1, , drop = FALSE]
}

teaching_stage_defaults <- function(stage) {
  switch(
    stage,
    deterministic_baseline = list(
      K = NA_real_,
      K_sd = 0,
      demographic_stochasticity = FALSE,
      env_sd = 0,
      genetics = FALSE,
      reps = 1
    ),
    carrying_capacity = list(
      K = 30,
      K_sd = 0,
      demographic_stochasticity = FALSE,
      env_sd = 0,
      genetics = FALSE,
      reps = 1
    ),
    demographic_stochasticity = list(
      K = 30,
      K_sd = 0,
      demographic_stochasticity = TRUE,
      env_sd = 0,
      genetics = FALSE,
      reps = 100
    ),
    environmental_stochasticity = list(
      K = 15,
      K_sd = 5,
      demographic_stochasticity = TRUE,
      env_sd = 0.35,
      genetics = FALSE,
      reps = 100,
      years = 50
    ),
    genetic_stochasticity = list(
      K = 30,
      K_sd = 5,
      demographic_stochasticity = TRUE,
      env_sd = 0.30,
      genetics = TRUE,
      lethal_equiv = c(1.5, 1, 0.5),
      reps = 100
    ),
    catastrophe = list(
      K = 30,
      K_sd = 5,
      demographic_stochasticity = TRUE,
      env_sd = 0.20,
      genetics = FALSE,
      cat_freq = 0.05,
      cat_surv = 0.60,
      cat_repro = 0.70,
      reps = 100
    ),
    intervention = list(
      K = 60,
      K_sd = 5,
      demographic_stochasticity = TRUE,
      env_sd = 0.20,
      genetics = FALSE,
      reps = 100
    ),
    extinction_vortex = list(
      n0 = c(12, 5, 3),
      K = 20,
      K_sd = 5,
      demographic_stochasticity = TRUE,
      env_sd = 0.30,
      genetics = TRUE,
      lethal_equiv = c(1.5, 1, 0.5),
      cat_freq = 0.05,
      cat_surv = 0.70,
      cat_repro = 0.80,
      reps = 100
    ),
    stop("Unknown teaching stage: ", stage, call. = FALSE)
  )
}

normalize_teaching_controls <- function(stage, controls) {
  controls <- normalize_control_list(controls)
  specs <- teaching_control_specs(stage)

  unknown <- setdiff(names(controls), specs$control)
  if (length(unknown) > 0) {
    stop("Unknown control(s) for stage `", stage, "`: ", paste(sort(unknown), collapse = ", "), call. = FALSE)
  }

  out <- controls
  for (name in names(controls)) {
    rule <- specs[specs$control == name, , drop = FALSE]
    out[[name]] <- validate_teaching_control(name, controls[[name]], rule)
  }
  out
}

normalize_control_list <- function(controls) {
  if (is.null(controls)) {
    return(list())
  }
  if (!is.list(controls)) {
    stop("`controls` must be a named list.", call. = FALSE)
  }
  if (length(controls) > 0 && (is.null(names(controls)) || any(names(controls) == ""))) {
    stop("`controls` must be a named list.", call. = FALSE)
  }
  controls
}

teaching_control_specs <- function(stage) {
  common <- data.frame(
    control = c("years", "reps", "mortality_pct", "fecundity_pct"),
    type = c("integer", "integer", "preset", "preset"),
    min = c(5, 1, NA, NA),
    max = c(1000, 1000, NA, NA),
    stringsAsFactors = FALSE
  )

  extra <- switch(
    stage,
    deterministic_baseline = data.frame(),
    carrying_capacity = data.frame(
      control = c("K", "K_sd"),
      type = c("numeric", "numeric"),
      min = c(10, 0),
      max = c(200, 50),
      stringsAsFactors = FALSE
    ),
    demographic_stochasticity = data.frame(
      control = c("K", "K_sd"),
      type = c("numeric", "numeric"),
      min = c(10, 0),
      max = c(200, 50),
      stringsAsFactors = FALSE
    ),
    environmental_stochasticity = data.frame(
      control = c("K", "K_sd", "env_sd"),
      type = c("numeric", "numeric", "numeric"),
      min = c(10, 0, 0.01),
      max = c(200, 50, 0.40),
      stringsAsFactors = FALSE
    ),
    genetic_stochasticity = data.frame(
      control = c("K", "K_sd", "env_sd", "F_init"),
      type = c("numeric", "numeric", "numeric", "numeric"),
      min = c(10, 0, 0.01, 0),
      max = c(200, 50, 0.40, 0.5),
      stringsAsFactors = FALSE
    ),
    catastrophe = data.frame(
      control = c("K", "K_sd", "env_sd", "cat_freq", "cat_surv", "cat_repro"),
      type = rep("numeric", 6),
      min = c(10, 0, 0.01, 0, 0.20, 0.20),
      max = c(200, 50, 0.40, 0.20, 1, 1.50),
      stringsAsFactors = FALSE
    ),
    intervention = data.frame(
      control = c("K", "K_sd", "env_sd"),
      type = rep("numeric", 3),
      min = c(30, 0, 0.01),
      max = c(200, 50, 0.40),
      stringsAsFactors = FALSE
    ),
    extinction_vortex = data.frame(
      control = c("K", "K_sd", "env_sd", "F_init", "cat_freq", "cat_surv", "cat_repro"),
      type = rep("numeric", 7),
      min = c(10, 0, 0.01, 0, 0, 0.20, 0.20),
      max = c(200, 50, 0.40, 0.50, 0.20, 1, 1.50),
      stringsAsFactors = FALSE
    ),
    stop("Unknown teaching stage: ", stage, call. = FALSE)
  )

  rbind(common, extra)
}

validate_teaching_control <- function(name, value, rule) {
  if (identical(rule$type[[1]], "preset")) {
    value <- as.numeric(value)
    if (length(value) != 1 || is.na(value)) {
      stop("Control `", name, "` must be a single numeric value.", call. = FALSE)
    }
    allowed <- teaching_vital_adjustment_values()
    if (!value %in% allowed) {
      stop(
        "Control `", name, "` must use an allowed preset: ",
        paste(allowed, collapse = ", "),
        ".",
        call. = FALSE
      )
    }
    return(value)
  }
  if (!is.numeric(value) || length(value) != 1 || is.na(value)) {
    stop("Control `", name, "` must be a single numeric value.", call. = FALSE)
  }
  if (identical(rule$type[[1]], "integer")) {
    if (abs(value - round(value)) > sqrt(.Machine$double.eps)) {
      stop("Control `", name, "` must be an integer value.", call. = FALSE)
    }
    value <- as.integer(round(value))
  } else {
    value <- as.numeric(value)
  }
  if (value < rule$min[[1]] || value > rule$max[[1]]) {
    stop(
      "Control `", name, "` is outside the supported range [",
      rule$min[[1]], ", ", rule$max[[1]], "].",
      call. = FALSE
    )
  }
  value
}

teaching_vital_adjustment_controls <- function() {
  c("mortality_pct", "fecundity_pct")
}

teaching_vital_adjustment_values <- function() {
  c(-20, -10, -5, 0, 5, 10, 20)
}

apply_teaching_vital_adjustments <- function(spec, controls) {
  mortality_pct <- controls$mortality_pct
  fecundity_pct <- controls$fecundity_pct

  if (!is.null(mortality_pct) && !identical(as.numeric(mortality_pct), 0)) {
    mortality_multiplier <- 1 + as.numeric(mortality_pct) / 100
    spec$surv <- adjust_survival_probability(spec$surv, mortality_multiplier)
    if (!is.null(spec$stasis)) {
      spec$stasis <- adjust_survival_probability(spec$stasis, mortality_multiplier)
    }
  }

  if (!is.null(fecundity_pct) && !identical(as.numeric(fecundity_pct), 0)) {
    fecundity_multiplier <- 1 + as.numeric(fecundity_pct) / 100
    spec$fecund <- spec$fecund * fecundity_multiplier
  }

  spec
}

adjust_survival_probability <- function(value, mortality_multiplier) {
  pmax(0, pmin(1, 1 - (1 - value) * mortality_multiplier))
}

settings_rows <- function(stage_info, settings, values) {
  if (length(values) == 0) {
    return(data.frame(
      stage = character(),
      label = character(),
      setting = character(),
      value = character(),
      stringsAsFactors = FALSE
    ))
  }

  data.frame(
    stage = rep(stage_info$stage[[1]], length(values)),
    label = rep(stage_info$label[[1]], length(values)),
    setting = settings,
    value = vapply(values, collapse_setting_value, character(1)),
    stringsAsFactors = FALSE
  )
}

collapse_setting_value <- function(value) {
  if (length(value) == 0) {
    return("")
  }
  if (length(value) > 1) {
    return(paste(value, collapse = ","))
  }
  if (is.na(value)) {
    return("NA")
  }
  as.character(value)
}

teaching_evidence_notes <- function(comparison,
                                    settings,
                                    generated_at,
                                    seed,
                                    interpretation = NULL,
                                    session_run_count = nrow(comparison)) {
  seed_label <- if (is.null(seed)) "not fixed" else as.character(seed)
  session_run_count <- as.integer(session_run_count)
  if (length(session_run_count) != 1L || is.na(session_run_count) || session_run_count < nrow(comparison)) {
    stop("session_run_count must be at least the number of selected evidence runs.", call. = FALSE)
  }

  notes <- c(
    "# Practical 1 PVA Evidence Notes",
    "",
    paste0("Generated: ", format_teaching_export_time(generated_at)),
    paste0(
      "Selected evidence: ", nrow(comparison),
      " runs from ", session_run_count,
      " successful session runs"
    ),
    paste0("Fixed teaching seed: ", seed_label),
    "",
    "Use this export with the comparison CSV from the same browser session.",
    "This export is evidence for your own interpretation.",
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
    "- What changed between the runs you compared?",
    "- Which output supports your explanation of extinction risk?",
    "- Which output supports your explanation of final abundance and uncertainty?",
    "- What caveat would you report before turning this evidence into a recommendation?"
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

format_teaching_export_time <- function(generated_at) {
  if (inherits(generated_at, "POSIXt")) {
    return(format(generated_at, "%Y-%m-%d %H:%M:%S %Z"))
  }
  as.character(generated_at)
}
