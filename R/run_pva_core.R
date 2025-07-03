#' run_pva_core
#' Stage-structured PVA engine with robust stochastic fate assignment.
#'
#' Core PVA simulation, supporting both Leslie and Lefkovitch forms.
#' Assumes: progression probability (`surv`) and stasis probability (`stasis`)
#' are distinct, and for the last stage ("adults"), survival is via `stasis[n]`
#' (typically set `surv[n] = 0, stasis[n] = adult survival`). If both are zero,
#' adults die each step.
#'
#' @param spec      list; must include surv, fecund, n0, env_sd, demo_sd.
#' @param years     integer. Projection length.
#' @param reps      integer. Number of Monte Carlo repetitions.
#' @param keep_traj logical. If TRUE, returns full population trajectory.
#' @param stasis    numeric vector (optional); stage-specific stasis probabilities.
#' @param seed      integer or NULL; set for reproducibility.
#' @param verbose   logical; progress indicator.
#' @return list with Nend, traj, and params (full inputs used).
#' @export
run_pva_core <- function(
    spec,
    years     = spec$years,
    reps      = spec$reps,
    keep_traj = FALSE,
    stasis    = NULL,
    seed      = NULL,
    verbose   = FALSE
) {
  # --- Input validation ---
  stopifnot(is.list(spec))
  required <- c("surv", "fecund", "n0", "env_sd", "demo_sd")
  if (!all(required %in% names(spec)))
    stop("spec must include: surv, fecund, n0, env_sd, demo_sd.")
  n_stage <- length(spec$surv)
  stopifnot(length(spec$fecund) == n_stage, length(spec$n0) == n_stage)
  stopifnot(is.numeric(years), years >= 1, years == as.integer(years))
  stopifnot(is.numeric(reps),  reps  >= 1, reps  == as.integer(reps))
  stopifnot(is.numeric(spec$surv), all(spec$surv >= 0 & spec$surv <= 1, na.rm = TRUE))
  stopifnot(is.numeric(spec$fecund), all(spec$fecund >= 0, na.rm = TRUE))
  stopifnot(is.numeric(spec$n0), all(spec$n0 >= 0, na.rm = TRUE))
  if (is.null(stasis)) stasis <- rep(0, n_stage)
  stopifnot(is.numeric(stasis), length(stasis) == n_stage,
            all(stasis >= 0 & stasis <= 1, na.rm = TRUE))
  if (is.null(spec$sex_ratio_init)) spec$sex_ratio_init <- 0.5
  if (is.null(spec$monogamy))       spec$monogamy       <- FALSE          

  if (!is.null(seed)) set.seed(seed)

  Nend <- numeric(reps)

  if (keep_traj) {
    traj <- array(NA_integer_, c(years + 1, n_stage, reps),
                  dimnames = list(time = 0:years,
                                  stage = paste0("stage", seq_len(n_stage)),
                                  rep = NULL))
    traj_sr <- matrix(NA_real_, nrow = years + 1, ncol = reps,
                      dimnames = list(time = 0:years, rep = NULL))
  } else {
      traj <- NULL
  }

  for (r in seq_len(reps)) {
    N <- as.integer(spec$n0)
    sr <- spec$sex_ratio_init

    if (keep_traj) {
      traj[1, , r]   <- N
      traj_sr[1, r]  <- sr
    }
    
    for (t in seq_len(years)) {
      # --- Environmental stochasticity ---
      env_surv <- if (spec$env_sd > 0) exp(rnorm(n_stage, 0, spec$env_sd)) else rep(1, n_stage)
      env_fec  <- if (spec$env_sd > 0) exp(rnorm(n_stage, 0, spec$env_sd)) else rep(1, n_stage)
      surv_t   <- pmin(1, spec$surv * env_surv)
      fec_t    <- pmax(0, spec$fecund * env_fec)
      stasis_t <- pmin(1, stasis)

      # --- Catastrophe pulse -------------------------------------------------
      cat_res <- maybe_apply_catastrophe(surv_t, fec_t, spec)
      surv_t  <- cat_res$surv
      fec_t   <- cat_res$fec
      # (cat_res$happened could be stored later if we want summaries)

      # --- Demographic stochasticity: fate-assignment for each stage ---
      N_next <- integer(n_stage)

      # --- 1. Recruits (stage 1) -------------------------------------------------
      # constrain reproduction if monogamy and females limiting
      fec_eff <- if (isTRUE(spec$monogamy)) {
                  fec_t * pmin(1, sr / 0.5)          # sr < 0.5 reduces fecundity
                } else {
                  fec_t
                }

      lambda <- sum(fec_eff * N)                      # expected offspring

      recruits <- if (isTRUE(spec$demo_sd)) {
                    rpois(1, lambda)
                  } else {
                    as.integer(round(lambda))
                  }

      # draw sex of recruits, update global sex ratio
      n_f <- if (recruits > 0) rbinom(1, recruits, sr) else 0
      n_m <- recruits - n_f
      N_next[1] <- recruits                        # juvenile stage receives all

      sr <- (sr * sum(N) + n_f) / (sum(N) + recruits + 1e-9)  # weight-update

      # --- 2. Survivors (all other stages) ---------------------------------------
      if (n_stage > 1) {
        for (i in seq_len(n_stage - 1)) {
          prog_prob   <- surv_t[i]
          stasis_prob <- stasis_t[i]
          total_surv  <- prog_prob + stasis_prob
          if (total_surv > 1 + 1e-8)
            stop(sprintf("surv_t + stasis_t > 1 in stage %d; check inputs.", i))

          n_alive <- if (isTRUE(spec$demo_sd)) rbinom(1, N[i], total_surv) else round(N[i] * total_surv)
          n_prog  <- if (n_alive > 0 && total_surv > 0) {
            if (spec$demo_sd == 1) rbinom(1, n_alive, prog_prob / max(total_surv, 1e-12))
            else round(n_alive * prog_prob / max(total_surv, 1e-12))
          } else 0
          n_stay  <- n_alive - n_prog

          N_next[i + 1] <- N_next[i + 1] + n_prog
          N_next[i]     <- N_next[i] + n_stay
        }
        # 3. Last stage (adults): only stasis, no progression
        n_adult <- N[n_stage]
        stasis_p <- stasis_t[n_stage]
        n_adult_surv <- if (spec$demo_sd == 1) rbinom(1, n_adult, stasis_p) else round(n_adult * stasis_p)
        N_next[n_stage] <- N_next[n_stage] + n_adult_surv
      }

      # --- Supplementation ---------------------------------------------------
      N_next <- apply_releases(N_next, t, spec)

      # --- Density ceiling ---
      if (!is.null(spec$K) && is.finite(spec$K)) {
        N_next <- apply_ceiling_K(N_next, spec$K)
      }
      N_next[N_next < 0] <- 0 # numerical guard

      N <- N_next

      if (keep_traj) {
        traj[t + 1, , r] <- N
        traj_sr[t + 1, r] <- sr
      }
    }
    Nend[r] <- sum(N)
    if (verbose && r %% max(1, reps %/% 20) == 0) cat(".")
  }
  if (verbose) cat("\n")

  list(
    Nend   = Nend,
    traj   = traj,
    sr_traj = if (keep_traj) traj_sr else NULL,
    params = c(spec, list(years = years, reps = reps, stasis = stasis, seed = seed))
  )
}
