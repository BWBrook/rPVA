#' apply_ceiling_K
#' Proportionally scales a stage vector to respect carrying capacity K.
#' @keywords internal
apply_ceiling_K <- function(N_vec, K) {
  tot <- sum(N_vec)
  if (tot > K && tot > 0) {
    N_vec <- round(N_vec * K / tot)
    # small rounding drift: fix total exactly K
    # This ensures all animals are integers, and the stage structure is minimally perturbed.
    diff <- K - sum(N_vec)
    if (diff != 0) {
      idx <- which.max(N_vec)         # add/remove from largest stage for least disturbance
      N_vec[idx] <- N_vec[idx] + diff
    }
  }
  N_vec
}
