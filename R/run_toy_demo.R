#' run_toy_demo
#' 
#' Convenience wrapper that runs the toy model under the five textbook
#' configurations and returns a list of result objects plus a summary table.
#' 
#' @export
run_toy_demo <- function(base_yaml = system.file("extdata", "toy_demo.yaml",
                                                 package = "woodhenPVA"),
                         seed = 42) {

  requireNamespace("dplyr")   # fail fast if missing

  base <- read_spec(base_yaml)
  plot_pva_matrix(base)

  scenarios <- list(
    det      = base,
    ceiling  = modifyList(base, list(K = 30)),
    demo_sd  = modifyList(base, list(demo_sd = TRUE, reps = 100, K = 30)),
    env_sd   = modifyList(base, list(demo_sd = TRUE, env_sd = 0.30, 
                                     K = 30, K_sd = 5, reps = 100)),
    genetics = modifyList(base, list(
                  demo_sd = TRUE, 
                  env_sd = 0.30, 
                  K = 30,
                  K_sd = 5, 
                  reps = 100,
                  genetics = TRUE,
                  lethal_equiv = c(2, 1, 0.5))))

  ## run every scenario ------------------------------------------------------
  out <- lapply(scenarios, run_pva_core, seed = seed)

  ## quick tidy summary ------------------------------------------------------
  sumtbl <- dplyr::bind_rows(lapply(names(out), function(nm) {
    o <- out[[nm]]
    yrs <- o$params$years
    dplyr::tibble(
      scenario = nm,
      PE       = round(o$ext_prob[yrs + 1], 3),
      N_med    = o$Nend_summary$median
    )
  }))

  invisible(list(results = out, summary = sumtbl))
}
