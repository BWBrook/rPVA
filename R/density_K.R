#' apply_ceiling_K
#' Proportionally scales a stage vector to respect carrying capacity K.
#' @keywords internal
apply_ceiling_K <- function(N_vec, K) {

  if (length(K) != 1 || is.na(K) || !is.finite(K)) {
    return(N_vec)
  }

  N_vec[is.na(N_vec) | N_vec < 0] <- 0L

  tot <- sum(N_vec)
  if (tot > K && tot > 0) {
    N_vec <- round(N_vec * K / tot)
    diff  <- K - sum(N_vec)
    if (diff != 0) {
      idx         <- which.max(N_vec)
      N_vec[idx] <- N_vec[idx] + diff
    }
  }

  N_vec
}
