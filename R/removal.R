#' apply_removals
#' Remove a fixed stage-vector in specified years
#'
#' @param N_vec numeric vector of stage abundances after demographic update
#' @param year  integer, current simulation year (1…T)
#' @param spec  list, full spec with removal_years & removal_vec
#' @return integer vector, abundance after removals (floored at zero)
#' @keywords internal
apply_removals <- function(N_vec, year, spec) {
  if (!is.null(spec$removal_years) &&
      !is.null(spec$removal_vec) &&
      year %in% spec$removal_years &&
      length(spec$removal_vec) == length(N_vec)) {

    N_vec <- pmax(N_vec - as.integer(spec$removal_vec), 0L)
  }
  N_vec
}
