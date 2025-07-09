#' genetic_update
#' Penalise vital rates by inbreeding and update F via drift
#'
#' @param surv  numeric vector of progression survival (after env noise & cat)
#' @param fec   numeric vector of fecundity (same length)
#' @param N_vec current stage vector _before_ reproduction
#' @param F     scalar, mean inbreeding at t
#' @param spec  scenario list with keys: genetics (bool), lethal_equivalents,
#'              Ne_N_ratio, purge_kappa
#' @return list(surv, fec, F) – adjusted survival, fecundity, and updated F
#' @keywords internal
genetic_update <- function(surv, fec, N_vec, F, spec, LE, Ne_override = NULL) {

  # only drift if we have a positive B and a valid Ne/N ratio
  if (is.null(LE) || sum(LE) <= 0 ||
      is.null(spec$Ne_N_ratio) || is.na(spec$Ne_N_ratio) || spec$Ne_N_ratio <= 0
      || !isTRUE(spec$genetics)) {
    return(list(surv = surv, fec = fec, F = F))
  }

  BS <- LE                  # lethal equivalents on survival
  BF <- BS * spec$B_on_fec  # lethal equivalents on fertility
  ws <- exp(-BS * F)        # survival fitness multiplier
  wf <- exp(-BF * F)        # fertility fitness multiplier

  surv <- surv * ws
  fec  <- fec  * wf

  # ---- Drift -------------------------------------------------------------
  if (!is.null(Ne_override)) {
    # floor + bound at 1 so we never divide by zero
    Ne <- as.integer(max(1, floor(Ne_override)))
  } else {
    Ne <- max(1, floor(spec$Ne_N_ratio * sum(N_vec)))
  }
  F_next <- F + (1 - F) / (2 * Ne * 2) # account for ♀ only model

  # ---- Optional purging --------------------------------------------------
  if (!is.null(spec$purge_kappa) && spec$purge_kappa > 0)
    LE <- LE * (1 - spec$purge_kappa * ((1 - F) / (2 * Ne * 2)))

  list(surv = surv, fec = fec, F = F_next, LE = LE)
}
