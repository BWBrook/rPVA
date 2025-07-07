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
  # --- Input validation & defaults ---
  stopifnot(is.list(spec))
  required <- c("surv","fecund","n0","env_sd","demo_sd")
  if (!all(required %in% names(spec)))
    stop("spec must include: ", paste(required, collapse=", "))
  n_stage <- length(spec$surv)
  stopifnot(length(spec$fecund)==n_stage,
            length(spec$n0)==n_stage,
            is.numeric(spec$years), spec$years>=1, spec$years==as.integer(spec$years),
            is.numeric(spec$reps),  spec$reps >=1, spec$reps == as.integer(spec$reps),
            all(spec$surv>=0 & spec$surv<=1),
            all(spec$fecund>=0),
            all(spec$n0>=0))

  # stasis default
  if (is.null(stasis)) stasis <- rep(0, n_stage)

  # sex‐ratio defaults
  if (is.null(spec$sex_ratio_init)) spec$sex_ratio_init <- 0.5
  if (is.null(spec$monogamy))       spec$monogamy       <- FALSE

  # K default (disable if missing)
  if (is.null(spec$K))               spec$K             <- NA_real_

  # catastrophe defaults
  if (is.null(spec$cat_freq))        spec$cat_freq      <- 0
  if (is.null(spec$cat_surv))        spec$cat_surv      <- 1
  if (is.null(spec$cat_repro))       spec$cat_repro     <- 1

  # genetics defaults
  if (is.null(spec$genetics))        spec$genetics      <- FALSE
  if (is.null(spec$F_init))          spec$F_init        <- 0
  if (is.null(spec$lethal_equiv)) spec$lethal_equiv     <- 0
  if (is.null(spec$B_on_fec))  spec$B_on_fec            <- 0
  if (is.null(spec$Ne_N_ratio))      spec$Ne_N_ratio    <- NA_real_
  if (is.null(spec$Ne_window))       spec$Ne_window     <- 1
  if (is.null(spec$purge_kappa))     spec$purge_kappa   <- 0

  # removals defaults
  if (is.null(spec$removal_years)) spec$removal_years <- integer(0)
  spec$removal_vec <- as.integer(spec$removal_vec %||% integer(n_stage))
  # pad or truncate to exactly n_stage
  if (length(spec$removal_vec) < n_stage) {
    spec$removal_vec <- c(spec$removal_vec,
                          integer(n_stage - length(spec$removal_vec)))
  } else if (length(spec$removal_vec) > n_stage) {
    spec$removal_vec <- spec$removal_vec[seq_len(n_stage)]
  }

  # releases defaults
  if (is.null(spec$release_years)) spec$release_years <- integer(0)
  spec$release_vec <- as.integer(spec$release_vec %||% integer(n_stage))
  # pad or truncate to exactly n_stage
  if (length(spec$release_vec) < n_stage) {
    spec$release_vec <- c(spec$release_vec,
                          integer(n_stage - length(spec$release_vec)))
  } else if (length(spec$release_vec) > n_stage) {
    spec$release_vec <- spec$release_vec[seq_len(n_stage)]
  }
  
  # --- Precompute Beta parameters for survival env variation ----------
  if (spec$env_sd > 0) {
    var_env   <- spec$env_sd^2
    m_surv    <- spec$surv
    denom     <- m_surv * (1 - m_surv) / var_env - 1
    env_alpha <- m_surv * denom
    env_beta  <- (1 - m_surv) * denom
    # guard against invalid variance
    invalid   <- (env_alpha <= 0 | env_beta <= 0)
    if (any(invalid)) {
      stop("env_sd too large for some survival rates: produces non-positive alpha/beta")
    }
  } else {
    env_alpha <- env_beta <- rep(NA_real_, n_stage)
  }

  # seed
  if (!is.null(seed)) set.seed(seed)

  # --- Prepare output containers & trajectories --------------------------
  Nend <- numeric(reps)
  if (keep_traj) {
    traj    <- array(NA_integer_, dim = c(years + 1, n_stage, reps),
                     dimnames = list(time = 0:years,
                                     stage = paste0("stage", seq_len(n_stage)),
                                     rep   = NULL))
    sr_traj <- matrix(NA_real_, nrow = years + 1, ncol = reps,
                      dimnames = list(time = 0:years,
                                      rep   = NULL))
    F_traj  <- numeric(years + 1)
  } else {
    traj    <- NULL
    sr_traj <- NULL
    F_traj  <- NULL
  }

  for (r in seq_len(reps)) {
    N <- as.integer(spec$n0)
    sr <- spec$sex_ratio_init
    F <- if (!is.null(spec$F_init)) spec$F_init else 0
    k <- if (!is.null(spec$Ne_window)) spec$Ne_window else 10  # years of memory
    N_hist <- rep(sum(N), k)                                   # fill with N₀

    if (keep_traj) {
      traj[1, , r]  <- N
      sr_traj[1, r] <- sr
      F_traj[1]     <- F
    }
    
    for (t in seq_len(years)) {
      stasis_t <- pmin(1, stasis)

      # --- Environmental stochasticity on survival via Beta ----------
      if (spec$env_sd > 0) {
        surv_t <- rbeta(n_stage, env_alpha, env_beta)
      } else {
        surv_t <- spec$surv
      }
      
      # --- Environmental stochasticity on fertility via Lognormal ----------
      env_fec  <- if (spec$env_sd > 0) exp(rnorm(n_stage, 0, spec$env_sd)) 
                    else rep(1, n_stage)      
      fec_t    <- pmax(0, spec$fecund * env_fec)

      # --- Catastrophe pulse -------------------------------------------------
      cat_res <- maybe_apply_catastrophe(surv_t, fec_t, spec)
      surv_t  <- cat_res$surv
      fec_t   <- cat_res$fec

      # --- genetics: apply inbreeding depression if selected ---
      N_hist <- c(N_hist[-1], sum(N)) # update rolling buffer of N
      Ne_t <- spec$Ne_N_ratio / mean(1 / N_hist) # harmonic mean of window
      gen <- genetic_update(surv_t, fec_t, N, F, spec, Ne_override = Ne_t)
      surv_t <- gen$surv
      fec_t  <- gen$fec
      F      <- gen$F

      N_next <- integer(n_stage)

      # recruitment
      rec <- recruit_phase(N, fec_t, sr, spec, spec$demo_sd)
      N_next <- integer(n_stage); N_next[1] <- rec$recruits
      sr <- rec$sr

      # survival + progression
      surv_res <- survival_phase(N, surv_t, stasis_t, spec, spec$demo_sd)
      N_next <- N_next + surv_res

      # --- Removals (harvest or captive collection) --------------------------
      N_next <- apply_removals(N_next, t, spec)

      # --- Supplementation ---------------------------------------------------
      N_next <- apply_releases(N_next, t, spec)

      # --- genetic rescue from migrant releases (F_new immigrants = 0)
      if (!is.null(spec$release_years) && t %in% spec$release_years) {
        migrants <- sum(spec$release_vec)
        if (migrants > 0 && sum(N_next) > 0) {
          m <- migrants / sum(N_next)
          F <- (1 - m)^2 * F
        }
      }

      # --- Density ceiling ---
      N_next <- apply_ceiling_K(N_next, spec$K)
      N_next[N_next < 0] <- 0 # numerical guard
      N <- N_next

      if (sum(N) == 0) {
        if (keep_traj) {
          # fill remaining years with zeros (or carry forward sr, F if you prefer)
          traj[(t + 1):(years + 1), , r]   <- 0L
          sr_traj[(t + 1):(years + 1), r]  <- sr
          F_traj[(t + 1):(years + 1)]      <- F
        }
        break # stop this replicate if population has gone extinct
      }

      if (keep_traj) {
        traj[t + 1, , r]  <- N
        sr_traj[t + 1, r] <- sr
        F_traj[t + 1]     <- F
      }
    }
    Nend[r] <- sum(N)
    if (verbose && r %% max(1, reps %/% 20) == 0) cat(".")
  }
  if (verbose) cat("\n")

  list(
    Nend   = Nend,
    traj   = traj,
    sr_traj = if (keep_traj) sr_traj else NULL,
    F_traj  = if (keep_traj) F_traj  else NULL,
    params = c(spec, list(years = years, reps = reps, stasis = stasis, seed = seed))
  )
}
