#' run_toy_demo
#' 
#' Convenience wrapper that runs the toy model under the five textbook
#' configurations and returns a list of result objects plus a summary table.
#'
#' Prints matrix diagnostics for the base toy model before running the
#' scenarios.
#'
#' @param base_yaml Path to the toy-model YAML file.
#' @param seed Random seed used for all toy scenarios.
#' @param keep_traj If TRUE, retain trajectories in each scenario result.
#' @param plot_matrix If TRUE, print matrix diagnostics for the base toy model.
#' @param verbose If TRUE, print simulation progress dots.
#' @return A list with `results` (named scenario outputs) and `summary`
#'   (a one-row-per-scenario tibble).
#' 
#' @export
run_toy_demo <- function(base_yaml = system.file("extdata", "toy", "toy_demo.yaml", package = "rPVA"),
                         seed = 42,
                         keep_traj = FALSE,
                         plot_matrix = FALSE,
                         verbose = FALSE) {

  if (!requireNamespace("dplyr", quietly = TRUE)) {
    stop("Please install the dplyr package to use run_toy_demo().", call. = FALSE)
  }

  base <- read_spec(base_yaml)
  if (plot_matrix) {
    plot_pva_matrix(base)
  }

  scenarios <- list(
    det      = base,
    ceiling  = modifyList(base, list(K = 30)),
    demographic_stochasticity = modifyList(base, list(demographic_stochasticity = TRUE, reps = 100, K = 30)),
    env_sd   = modifyList(base, list(demographic_stochasticity = TRUE, env_sd = 0.30,
                                     K = 30, K_sd = 5, reps = 100)),
    genetics = modifyList(base, list(
                  demographic_stochasticity = TRUE,
                  env_sd = 0.30,
                  K = 30,
                  K_sd = 5,
                  reps = 100,
                  genetics = TRUE,
                  lethal_equiv = c(1.5, 1, 0.5))))

  ## run every scenario ------------------------------------------------------
  out <- lapply(scenarios, run_pva_core, seed = seed, keep_traj = keep_traj, verbose = verbose)

  ## quick tidy summary ------------------------------------------------------
  sumtbl <- dplyr::bind_rows(lapply(names(out), function(nm) {
    o <- out[[nm]]
    yrs <- o$params$years
    pe <- if (!is.null(o$ext_prob)) o$ext_prob[yrs + 1] else mean(o$Nend == 0)
    dplyr::tibble(
      scenario = nm,
      PE       = round(pe, 3),
      N_med    = o$Nend_summary$median
    )
  }))

  invisible(list(results = out, summary = sumtbl))
}
