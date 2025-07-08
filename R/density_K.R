#' apply_ceiling_K (floaters exempt)
#' Proportionally scales N_vec[-1] to respect carrying capacity K,
#' but leaves N_vec[1] (floaters) untouched.
#' @keywords internal
apply_ceiling_K <- function(N_vec, K) {
  # 1. Only apply if K is a single, finite number
  if (length(K) != 1 || is.na(K) || !is.finite(K)) {
    return(N_vec)
  }

  # 2. Clean up any NAs or negatives
  N_vec[is.na(N_vec) | N_vec < 0] <- 0L

  # 3. Separate floaters (stage 1) from territory holders (stages 2+)
  floaters <- N_vec[1]
  holders  <- N_vec[-1]

  tot_holders <- sum(holders)
  # 4. If total holders exceed K, scale them back proportionally
  if (tot_holders > K && tot_holders > 0) {
    scaled <- round(holders * K / tot_holders)
    diff   <- K - sum(scaled)
    if (diff != 0) {
      # add/remove the remainder to the largest holder stage
      idx <- which.max(scaled)
      scaled[idx] <- scaled[idx] + diff
    }
    N_vec <- c(floaters, scaled)
  }

  N_vec
}
