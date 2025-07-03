recruit_phase   <- function(N, fec_t, sr, spec, demo_sd) {
  # 1. throttle by monogamy + SR
  fec_eff <- if (spec$monogamy) fec_t * pmin(1, sr / 0.5) else fec_t
  lambda  <- sum(fec_eff * N)
  recruits <- if (demo_sd) rpois(1, lambda) else as.integer(round(lambda))

  # 2. sex draw + SR update
  n_f <- if (recruits) rbinom(1, recruits, sr) else 0
  sr_out <- (sr * sum(N) + n_f) / (sum(N) + recruits + 1e-9)

  list(recruits = recruits, sr = sr_out)
}
