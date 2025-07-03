survival_phase <- function(N, surv_t, stasis_t, spec, demo_sd) {
  n_stage <- length(N)
  N_next  <- integer(n_stage)

  if (n_stage > 1) {
    for (i in seq_len(n_stage - 1)) {
      prog   <- surv_t[i]
      stay   <- stasis_t[i]
      alive  <- if (demo_sd) rbinom(1, N[i], prog + stay)
                else round(N[i] * (prog + stay))
      n_prog <- if (alive && prog) {
                  if (demo_sd) rbinom(1, alive, prog / (prog + stay))
                  else round(alive * prog / (prog + stay))
                } else 0
      n_stay <- alive - n_prog
      N_next[i + 1] <- N_next[i + 1] + n_prog
      N_next[i]     <- N_next[i]     + n_stay
    }
    # last stage – stasis only
    surv_ad <- if (demo_sd) rbinom(1, N[n_stage], stasis_t[n_stage])
               else round(N[n_stage] * stasis_t[n_stage])
    N_next[n_stage] <- N_next[n_stage] + surv_ad
  }
  N_next
}
