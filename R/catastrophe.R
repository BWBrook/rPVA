#' maybe_apply_catastrophe
#' Stochastically apply catastrophe multipliers to survival & fecundity.
#' @param surv  numeric vector (progression probs)
#' @param fec   numeric vector
#' @param spec  full spec list (needs cat_freq, cat_surv, cat_repro)
#' @return list(surv = …, fec = …, happened = TRUE/FALSE)
#' @keywords internal
maybe_apply_catastrophe <- function(surv, fec, spec) {
  if (is.null(spec$cat_freq) || spec$cat_freq <= 0) {
    return(list(surv = surv, fec = fec, happened = FALSE))
  }
  if (runif(1) < spec$cat_freq) {
    surv <- surv * spec$cat_surv
    fec  <- fec  * spec$cat_repro
    return(list(surv = surv, fec = fec, happened = TRUE))
  }
  list(surv = surv, fec = fec, happened = FALSE)
}
