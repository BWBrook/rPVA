resolve_scenario_paths <- function(subdir, package = utils::packageName()) {
  root <- system.file("extdata", package = package)
  paths <- subdir

  if (identical(paths, "")) {
    paths <- root
  } else if (length(paths) == 1 && !dir.exists(paths) && !file.exists(paths)) {
    paths <- file.path(root, paths)
  }

  if (length(paths) == 1 && dir.exists(paths)) {
    paths <- list.files(
      paths,
      pattern = "^[0-9]{2}_.*\\.ya?ml$",
      full.names = TRUE
    )
  }

  if (length(paths) == 0 || any(!file.exists(paths))) {
    stop("Cannot locate scenarios in ", paste(subdir, collapse = ", "), call. = FALSE)
  }

  paths
}

scenario_summary_row <- function(spec, out) {
  pe <- if (!is.null(out$ext_prob)) {
    out$ext_prob[spec$years + 1]
  } else {
    mean(out$Nend == 0)
  }

  data.frame(
    scenario = spec$name,
    years = spec$years,
    reps = spec$reps,
    PE = round(pe, 3),
    Nmed = out$Nend_summary$median,
    Nlo95 = out$Nend_summary$lo95,
    Nhi95 = out$Nend_summary$hi95,
    stringsAsFactors = FALSE
  )
}

run_scenario_path <- function(path, keep_traj, seed = 123) {
  scen <- tools::file_path_sans_ext(basename(path))
  spec <- set_scenario(scen, basename(dirname(path)))
  cat(scen, "\n")

  out <- run_pva_core(spec, keep_traj = keep_traj, seed = seed)

  list(summary = scenario_summary_row(spec, out), result = out)
}

write_scenario_outputs <- function(summary_tbl, results, csv_out, rds_out) {
  if (!is.null(csv_out)) {
    if (!requireNamespace("readr", quietly = TRUE)) {
      stop("Please install the readr package or set csv_out = NULL")
    }
    readr::write_csv(summary_tbl, csv_out)
  }

  if (!is.null(rds_out)) {
    saveRDS(results, rds_out)
  }
}

#' run_scenarios
#'
#' Batch-execute one or more YAML spec files and write a tidy summary table.
#'
#' @param subdir Case-study subdir (for example `"woodhen"`), a project path
#'   like `"inst/extdata/woodhen"`, or a character vector of scenario YAML
#'   files.
#' @param csv_out File name for the summary CSV (set to NULL to suppress).
#' @param rds_out File name for an .rds containing the raw result objects
#'   (set to NULL to suppress).
#' @param keep_traj Logical: store full Monte Carlo trajectories?
#' @param parallel Logical: use `future.apply` for parallel execution?
#' @return Invisibly returns a data.frame with one row per scenario.
#' @export
run_scenarios <- function(subdir     = "",             # e.g. "woodhen"
                          csv_out    = NULL,
                          rds_out    = NULL,
                          keep_traj  = FALSE,
                          parallel   = FALSE) {
  paths <- resolve_scenario_paths(subdir)

  ## ------------ optional parallel backend ---------------------------------
  if (parallel && requireNamespace("future", quietly = TRUE) &&
      requireNamespace("future.apply", quietly = TRUE)) {
    old_plan <- future::plan()
    on.exit(future::plan(old_plan), add = TRUE)
    future::plan(future::multisession,
                 workers = max(1, future::availableCores() - 1))
    lapply_fun <- future.apply::future_lapply
  } else {
    lapply_fun <- lapply
  }

  ## ------------ run each scenario -----------------------------------------
  results <- lapply_fun(paths, run_scenario_path, keep_traj = keep_traj)
  summary_tbl <- dplyr::bind_rows(lapply(results, `[[`, "summary"))

  write_scenario_outputs(
    summary_tbl = summary_tbl,
    results = lapply(results, `[[`, "result"),
    csv_out = csv_out,
    rds_out = rds_out
  )

  invisible(summary_tbl)
}
