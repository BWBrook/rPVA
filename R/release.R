#' apply_releases
#' Add captive-bred individuals in scheduled years.
#' @keywords internal
apply_releases <- function(N_vec, year, spec) {
  if (!is.null(spec$release_years) &&
      !is.null(spec$release_vec)   &&
      length(spec$release_vec) == length(N_vec) &&
      year %in% spec$release_years) {

    N_vec <- N_vec + as.integer(spec$release_vec)
  }
  N_vec
}
