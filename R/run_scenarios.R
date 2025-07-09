#' run_scenarios
#' 
#' Batch‑execute one or more YAML spec files and write a tidy summary table.
#'
#' @param paths   Character vector of *.yaml files **or** a single directory.
#' @param csv_out File name for the summary CSV (set to NULL to suppress).
#' @param rds_out File name for an .rds containing the raw result objects
#'                (written only if `keep_traj = TRUE`; set to NULL to suppress).
#' @param keep_traj Logical: store full Monte‑Carlo trajectories?
#' @param parallel Logical: use `future.apply` for parallel execution?
#' @return (invisibly) a data.frame with one row per scenario.
#' @export
run_scenarios <- function(paths      = "inst/extdata",
                          csv_out    = "scenario_summary.csv",
                          rds_out    = "scenario_raw.rds",
                          parallel   = FALSE) {

  ## ------------ resolve file list -----------------------------------------
  if (length(paths) == 1 && dir.exists(paths)) {
    paths <- list.files(paths,
                        pattern = "^[0-9]{2}_.*\\.ya?ml$",
                        full.names = TRUE)
  }
  stopifnot(length(paths) > 0)

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
  results <- lapply_fun(paths, function(p) {
    scen <- tools::file_path_sans_ext(basename(p))
    spec <- set_scenario(scen)
    cat(scen, "\n")
    out  <- run_pva_core(spec, seed = 123)
    data.frame(
      scenario = spec$name,
      years    = spec$years,
      reps     = spec$reps,
      PE       = round(out$ext_prob[spec$years + 1], 3),
      Nmed     = out$Nend_summary$median,
      Nlo95    = out$Nend_summary$lo95,
      Nhi95    = out$Nend_summary$hi95,
      stringsAsFactors = FALSE
    )
  })

  summary_tbl <- dplyr::bind_rows(results)

  ## ------------ export -----------------------------------------------------
  if (!is.null(csv_out)) {
    if (!requireNamespace("readr", quietly = TRUE))
      stop("Please install the readr package or set csv_out = NULL")
    readr::write_csv(summary_tbl, csv_out)
  }
  if (!is.null(rds_out)) saveRDS(results, rds_out)

  invisible(summary_tbl)
}
