#' Summarize a PVA result
#'
#' Converts one `run_pva_core()` result object into a one-row, report-friendly
#' summary table.
#'
#' @param out A result list returned by `run_pva_core()`.
#' @param scenario Optional scenario label. Defaults to `out$params$name` when
#'   available.
#' @param horizon Optional extinction-probability horizon in years. Defaults to
#'   the final model year.
#' @return A one-row data frame with extinction risk, final abundance interval,
#'   replicate counts, and trajectory availability.
#' @export
summarize_pva_result <- function(out, scenario = NULL, horizon = NULL) {
  validate_pva_result(out)

  final_horizon <- infer_pva_horizon(out)
  selected_horizon <- resolve_pva_horizon(horizon, final_horizon, out)
  scenario <- resolve_pva_scenario(out, scenario)
  reps <- infer_pva_reps(out)
  abundance <- pva_final_abundance_summary(out)
  pe <- pva_extinction_probability(out, selected_horizon, final_horizon)
  extinct_reps <- sum(out$Nend == 0, na.rm = TRUE)

  data.frame(
    scenario = scenario,
    years = selected_horizon,
    reps = reps,
    PE = round(pe, 3),
    Nmed = abundance$median,
    Nlo95 = abundance$lo95,
    Nhi95 = abundance$hi95,
    extinct_reps = extinct_reps,
    surviving_reps = sum(out$Nend > 0, na.rm = TRUE),
    trajectory_available = !is.null(out$traj),
    stringsAsFactors = FALSE
  )
}

#' Compare PVA results
#'
#' Summarizes a list of `run_pva_core()` result objects into a scenario
#' comparison table.
#'
#' @param results Non-empty list of result objects.
#' @param scenarios Optional scenario labels. Defaults to `names(results)` when
#'   available, otherwise `scenario_1`, `scenario_2`, ...
#' @param horizon Optional extinction-probability horizon passed to
#'   `summarize_pva_result()`.
#' @return A data frame with one row per result, preserving input order.
#' @export
compare_pva_results <- function(results, scenarios = names(results), horizon = NULL) {
  if (!is.list(results) || length(results) == 0) {
    stop("`results` must be a non-empty list of PVA result objects.", call. = FALSE)
  }

  scenarios <- resolve_pva_scenarios(results, scenarios)
  rows <- lapply(seq_along(results), function(i) {
    summarize_pva_result(results[[i]], scenario = scenarios[[i]], horizon = horizon)
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

#' Diagnose a PVA result
#'
#' Returns compact, student-facing interpretation prompts for one PVA result.
#'
#' @param out A result list returned by `run_pva_core()`.
#' @param scenario Optional scenario label.
#' @param horizon Optional extinction-probability horizon.
#' @param high_pe Extinction-probability threshold for a high-risk prompt.
#' @param low_nmed Median final abundance threshold for a low-abundance prompt.
#' @param wide_interval_ratio Ratio threshold for a wide-uncertainty prompt.
#' @return A data frame with `scenario`, `code`, `severity`, and `message`.
#' @export
diagnose_pva_result <- function(out,
                                scenario = NULL,
                                horizon = NULL,
                                high_pe = 0.05,
                                low_nmed = 50,
                                wide_interval_ratio = 4) {
  summary <- summarize_pva_result(out, scenario = scenario, horizon = horizon)
  rows <- list()

  add_row <- function(code, severity, message) {
    rows[[length(rows) + 1]] <<- data.frame(
      scenario = summary$scenario,
      code = code,
      severity = severity,
      message = message,
      stringsAsFactors = FALSE
    )
  }

  if (summary$PE >= high_pe) {
    add_row(
      "high_extinction_probability",
      "warning",
      sprintf("Extinction probability is %.3f; discuss this as a material risk.", summary$PE)
    )
  }

  if (summary$Nmed <= low_nmed) {
    add_row(
      "low_median_final_abundance",
      "warning",
      sprintf("Median final abundance is %s; discuss demographic vulnerability and recovery limits.", summary$Nmed)
    )
  }

  interval_ratio <- pva_interval_ratio(summary$Nlo95, summary$Nhi95)
  if (is.infinite(interval_ratio) || interval_ratio >= wide_interval_ratio) {
    add_row(
      "wide_final_abundance_interval",
      "note",
      "The final abundance interval is wide; emphasise uncertainty as well as the median."
    )
  }

  if (!summary$trajectory_available) {
    add_row(
      "no_trajectory_data",
      "note",
      "Trajectory data are not available; rerun with keep_traj = TRUE before plotting or checking timing."
    )
  }

  if (summary$extinct_reps == 0) {
    add_row(
      "zero_observed_extinction",
      "note",
      "No simulated extinctions were observed; report this as a sample result and keep uncertainty visible."
    )
  }

  if (length(rows) == 0) {
    return(data.frame(
      scenario = character(),
      code = character(),
      severity = character(),
      message = character(),
      stringsAsFactors = FALSE
    ))
  }

  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

validate_pva_result <- function(out) {
  if (!is.list(out) || is.null(out$Nend)) {
    stop("`out` must be a result list returned by run_pva_core().", call. = FALSE)
  }
  if (!is.numeric(out$Nend)) {
    stop("`out$Nend` must be numeric.", call. = FALSE)
  }
  invisible(out)
}

infer_pva_horizon <- function(out) {
  if (!is.null(out$params$years)) {
    return(as.integer(out$params$years[[1]]))
  }
  if (!is.null(out$ext_prob)) {
    return(length(out$ext_prob) - 1L)
  }
  NA_integer_
}

resolve_pva_horizon <- function(horizon, final_horizon, out) {
  if (is.null(horizon)) {
    return(final_horizon)
  }
  if (length(horizon) != 1 || is.na(horizon) || horizon < 0 || horizon != as.integer(horizon)) {
    stop("`horizon` must be a single non-negative integer year.", call. = FALSE)
  }
  horizon <- as.integer(horizon)
  if (!is.na(final_horizon) && horizon > final_horizon) {
    stop("`horizon` cannot exceed the result's final model year.", call. = FALSE)
  }
  if (!is.null(out$ext_prob) && horizon > length(out$ext_prob) - 1L) {
    stop("`horizon` cannot exceed the available extinction-probability series.", call. = FALSE)
  }
  horizon
}

resolve_pva_scenario <- function(out, scenario) {
  if (!is.null(scenario)) {
    return(as.character(scenario[[1]]))
  }
  if (!is.null(out$params$name)) {
    return(as.character(out$params$name[[1]]))
  }
  NA_character_
}

infer_pva_reps <- function(out) {
  if (!is.null(out$params$reps)) {
    return(as.integer(out$params$reps[[1]]))
  }
  length(out$Nend)
}

pva_final_abundance_summary <- function(out) {
  if (!is.null(out$Nend_summary)) {
    return(out$Nend_summary)
  }
  list(
    median = as.numeric(round(stats::quantile(out$Nend, probs = 0.50, na.rm = TRUE))),
    lo95 = as.numeric(round(stats::quantile(out$Nend, probs = 0.025, na.rm = TRUE))),
    hi95 = as.numeric(round(stats::quantile(out$Nend, probs = 0.975, na.rm = TRUE)))
  )
}

pva_extinction_probability <- function(out, horizon, final_horizon) {
  if (!is.null(out$ext_prob)) {
    return(out$ext_prob[[horizon + 1L]])
  }
  if (is.na(final_horizon) || identical(horizon, final_horizon)) {
    return(mean(out$Nend == 0, na.rm = TRUE))
  }
  stop(
    "Horizon-specific extinction probability requires keep_traj = TRUE when `out$ext_prob` is unavailable.",
    call. = FALSE
  )
}

resolve_pva_scenarios <- function(results, scenarios) {
  if (is.null(scenarios) || length(scenarios) == 0) {
    scenarios <- paste0("scenario_", seq_along(results))
  }
  if (length(scenarios) != length(results)) {
    stop("`scenarios` must have one label per result.", call. = FALSE)
  }
  scenarios <- as.character(scenarios)
  missing <- is.na(scenarios) | scenarios == ""
  scenarios[missing] <- paste0("scenario_", which(missing))
  scenarios
}

pva_interval_ratio <- function(lo, hi) {
  if (is.na(lo) || is.na(hi)) {
    return(NA_real_)
  }
  if (lo <= 0 && hi > 0) {
    return(Inf)
  }
  if (lo <= 0 && hi <= 0) {
    return(0)
  }
  hi / lo
}
