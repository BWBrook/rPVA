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
#' @param stasis    numeric vector; *if NULL (default) the value of spec$stasis 
#'                  is used; otherwise overrides it.*
#' @param seed      integer or NULL; set for reproducibility.
#' @param verbose   logical; progress indicator.
#' @return list with Nend, traj, and params (full inputs used).
#' @export
run_pva_core <- function(
    spec,
    years     = spec$years,
    reps      = spec$reps,
    keep_traj = TRUE,
    stasis    = NULL,
    seed      = NULL,
    verbose   = TRUE
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

  # stasis defaults  ----------------------------------------------------------
  if (is.null(stasis)) {
    if (!is.null(spec$stasis)) {
      stasis <- spec$stasis
    } else {
      stasis <- rep(0, n_stage)
    }
  }
  if (length(stasis) != n_stage)
    stop("stasis must be length ", n_stage)

  # sex‐ratio defaults
  if (is.null(spec$sex_ratio_init)) spec$sex_ratio_init <- 0.5
  if (is.null(spec$monogamy))       spec$monogamy       <- FALSE

  # K default (disable if missing)
  if (is.null(spec$K))               spec$K             <- NA_real_
  if (is.null(spec$K_sd))            spec$K_sd          <- 0

  # catastrophe defaults
  if (is.null(spec$cat_freq))        spec$cat_freq      <- 0
  if (is.null(spec$cat_surv))        spec$cat_surv      <- 1
  if (is.null(spec$cat_repro))       spec$cat_repro     <- 1

  # genetics defaults
  if (is.null(spec$genetics))        spec$genetics      <- FALSE
  if (is.null(spec$F_init))          spec$F_init        <- 0
  if (is.null(spec$lethal_equiv))    spec$lethal_equiv  <- 0
  if (is.null(spec$B_on_fec))        spec$B_on_fec      <- 0
  if (is.null(spec$Ne_N_ratio))      spec$Ne_N_ratio    <- 1
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
                      dimnames = list(time = 0:years, rep = NULL))
    F_traj  <- matrix(NA_real_, nrow = years + 1, ncol = reps)
    LE_traj <- matrix(NA_real_, nrow = years + 1, ncol = reps)
  } else {
    traj    <- NULL
    sr_traj <- NULL
    F_traj  <- NULL
    LE_traj <- NULL
  }

  for (r in seq_len(reps)) {
    N <- as.integer(spec$n0)
    sr <- spec$sex_ratio_init
    F <- if (!is.null(spec$F_init)) spec$F_init else 0
    k <- if (!is.null(spec$Ne_window)) spec$Ne_window else 10  # years of memory
    N_hist <- rep(sum(N), k)                                   # fill with N₀
    LE <- spec$lethal_equiv

    if (keep_traj) {
      traj[1, , r]  <- N
      sr_traj[1, r] <- sr
      F_traj[1, r]  <- F
      LE_traj[1, r] <- sum(LE)
    }
    
    for (t in seq_len(years)) {
      stasis_t <- pmin(1, stasis)

      # --- Environmental stochasticity on survival via Beta ----------
      if (spec$env_sd > 0) {
        surv_t <- rbeta(n_stage, env_alpha, env_beta)
        stasis_t <- pmin(1, stasis) * rbeta(n_stage, env_alpha, env_beta)
        stasis_t[n_stage] <- surv_t[n_stage]
      } else {
        surv_t <- spec$surv
        stasis_t <- pmin(1, stasis)
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
      gen <- genetic_update(surv_t, fec_t, N, F, spec, LE, Ne_override = Ne_t)
      surv_t <- gen$surv; fec_t <- gen$fec; F <- gen$F; LE <- gen$LE

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

      # --- Density ceiling with environmental variability ---
      if (!is.na(spec$K) && spec$K_sd > 0) {
        K_t <- round(rnorm(1, spec$K, spec$K_sd))
      } else {
        K_t <- spec$K
      }   
      N_next <- apply_ceiling_K(N_next, K_t)
      N_next[N_next < 0] <- 0 # numerical guard
      N <- N_next

      # --- Tally trajectories ---
      if (sum(N) == 0) {
        if (keep_traj) {
          traj[(t + 1):(years + 1), , r]  <- 0L
          sr_traj[(t + 1):(years + 1), r] <- sr
          F_traj[(t + 1):(years + 1), r]  <- F
          LE_traj[(t + 1):(years + 1), r] <- sum(LE)
        }
        break # stop this replicate if population has gone extinct
      }

      if (keep_traj) {
        traj[t + 1, , r]  <- N
        sr_traj[t + 1, r] <- sr
        F_traj[t + 1, r]  <- F
        LE_traj[t + 1, r] <- sum(LE)
      }
    }
    Nend[r] <- sum(N)
    if (verbose && r %% max(1, reps %/% 50) == 0) cat(".")
  }
  if (verbose) cat("\n")

  Tsteps <- years + 1
  if (keep_traj) {
    extinct_mat <- matrix(FALSE, nrow = Tsteps, ncol = reps)
    for (r in seq_len(reps)) {
      for (t in seq_len(Tsteps)) {
        extinct_mat[t, r] <- sum(traj[t, , r]) == 0
      }
    }
    ext_prob <- rowMeans(extinct_mat)

    # 1. plain mean over *all* reps
    traj_raw  <- apply(traj, c(1, 2), mean)   # [time × stage]

    # 2. conditional mean given persistence
    surv_prob <- 1 - ext_prob                 # vector length time
    traj_mean <- traj_raw                     # initialise
    for (t in seq_len(years + 1)) {
      if (surv_prob[t] > 0) {
        traj_mean[t, ] <- round(traj_raw[t, ] / surv_prob[t])
      } else {
        traj_mean[t, ] <- 0L                  # no survivors
      }
    }

    # 3. conditional Nend summary
    if (surv_prob[years + 1] > 0) {
      Nsurv <- Nend[!extinct_mat[years + 1, ]]
      Nend_summary <- list(
        median = median(Nsurv),
        lo95   = quantile(Nsurv, 0.025),
        hi95   = quantile(Nsurv, 0.975)
      )
    } else {
      Nend_summary <- list(median = 0, lo95 = 0, hi95 = 0)
    }
      
    # conditional F and SR means
    sr_mean <- rowMeans(sr_traj)
    F_mean  <- rowMeans(F_traj); F_mean[1] <- spec$F_init
    LE_mean <- rowMeans(LE_traj)

  } else {
    traj_mean     <- NULL
    Nend_summary  <- NULL
    sr_mean   <- NULL
    F_mean    <- NULL
    LE_mean   <- NULL
  }
  
  # --- summary of Nend on surviving replicates ----------------------------
  final_survivors <- if (keep_traj) which(!extinct_mat[Tsteps, ]) else which(Nend > 0)
  if (length(final_survivors) > 0) {
    Np <- Nend[final_survivors]
    Nmed  <- as.numeric(round(quantile(Np, probs = 0.50)))
    Nlo95 <- as.numeric(round(quantile(Np, probs = 0.025)))
    Nhi95 <- as.numeric(round(quantile(Np, probs = 0.975)))
  } else {
    Nmed  <- 0
    Nlo95 <- 0
    Nhi95 <- 0
  }

  return(list(
    ext_prob      = ext_prob,                 # fraction extinct at each t
    Nend_summary  = list(median = Nmed,
                         lo95   = Nlo95,
                         hi95   = Nhi95),
    traj_mean     = traj_mean,                # integer mean over survivors
    sr_mean       = sr_mean,
    F_mean        = F_mean,
    LE_mean       = LE_mean,
    params        = c(spec,
                      list(years  = years,
                           reps   = reps,
                           stasis = stasis,
                           seed   = seed)),
    raw           = list(traj = traj)
  ))
}
