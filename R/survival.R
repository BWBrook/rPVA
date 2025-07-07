survival_phase <- function(N, surv_t, stasis_t, spec, demo_sd) {
  n_stage <- length(N)
  N_next  <- integer(n_stage)

  if (n_stage > 1) {
    for (i in seq_len(n_stage - 1)) {
      prog        <- surv_t[i]
      stay        <- stasis_t[i]
      total_surv  <- prog + stay

      # --- survivors drawn once (binomial or deterministic) ---
      alive <- if (isTRUE(demo_sd)) {
        rbinom(1, N[i], total_surv)
      } else {
        as.integer(round(N[i] * total_surv))
      }

      # --- progression vs stasis split ---
      n_prog <- 0L
      if (isTRUE(alive > 0) && isTRUE(prog > 0) && isTRUE(total_surv > 0)) {
        if (isTRUE(demo_sd)) {
          p_prog <- prog / total_surv
          n_prog <- rbinom(1, alive, p_prog)
        } else {
          n_prog <- as.integer(round(alive * prog / total_surv))
        }
      }
      n_stay <- alive - n_prog

      N_next[i + 1] <- N_next[i + 1] + n_prog
      N_next[i]     <- N_next[i] + n_stay
    }

    # Last stage: only stasis
    surv_ad <- if (isTRUE(demo_sd)) {
      rbinom(1, N[n_stage], stasis_t[n_stage])
    } else {
      as.integer(round(N[n_stage] * stasis_t[n_stage]))
    }
    N_next[n_stage] <- N_next[n_stage] + surv_ad
  }

  N_next
}
