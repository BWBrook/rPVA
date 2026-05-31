recruit_phase <- function(N, fec_t, sr, spec, demographic_stochasticity) {
  # 1. throttle by monogamy + SR
  fec_eff <- if (spec$monogamy) fec_t * pmin(1, sr / 0.5) else fec_t
  lambda  <- sum(fec_eff * N)
  recruits <- if (isTRUE(demographic_stochasticity)) {
                rpois(1, lambda)
              } else {
                as.integer(floor(lambda)) # recruits <= λ_eff
              }

  # 2. sex draw + SR update
  n_f <- if (isTRUE(demographic_stochasticity)) {
           rbinom(1, recruits, sr)
         } else {
           # deterministic half‐female split
           as.integer(round(recruits * sr))
         }
  n_m <- recruits - n_f

  sr_out <- (sr * sum(N) + n_f) / (sum(N) + recruits + 1e-9)

  list(recruits = recruits, sr = sr_out)
}
