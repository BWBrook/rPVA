#' run_pva_core
#' Stage-structured PVA engine with robust stochastic fate assignment.
#'
#' Core PVA simulation, supporting both Leslie and Lefkovitch forms.
#' Assumes: progression probability (`surv`) and stasis probability (`stasis`)
#' are distinct, and for the last stage ("adults"), survival is via `stasis[n]`
#' (typically set `surv[n] = 0, stasis[n] = adult survival`). If both are zero,
#' adults die each step.
#'
#' @param spec      list; must include surv, fecund, n0, env_sd,
#'   demographic_stochasticity.
#' @param years     integer. Projection length.
#' @param reps      integer. Number of Monte Carlo repetitions.
#' @param keep_traj logical. If TRUE, returns full population trajectory.
#' @param stasis    numeric vector; *if NULL (default) the value of spec$stasis
#'                  is used; otherwise overrides it.*
#' @param seed      integer or NULL; set for reproducibility.
#' @param verbose   logical; progress indicator.
#' @param progress  optional function called with completed and total replicate
#'   counts at throttled intervals.
#' @return list with Nend, traj, and params (full inputs used).
#' @export
run_pva_core <- function(
    spec,
    years     = spec$years,
    reps      = spec$reps,
    keep_traj = FALSE,
    stasis    = NULL,
    seed      = NULL,
    verbose   = FALSE,
    progress  = NULL
) {
  if (!is.null(progress) && !is.function(progress)) {
    stop("`progress` must be a function or NULL.", call. = FALSE)
  }
  spec$years <- years
  spec$reps <- reps
  normalized <- normalize_pva_spec(spec, stasis)
  spec <- normalized$spec
  stasis <- normalized$stasis
  n_stage <- normalized$n_stage
  env_alpha <- normalized$env_alpha
  env_beta <- normalized$env_beta
  has_annual_profiles <- !is.null(spec$annual_profiles) && length(spec$annual_profiles) > 0

  # seed
  if (!is.null(seed)) set.seed(seed)

  outputs <- initialize_pva_outputs(years, n_stage, reps, keep_traj)
  progress_every <- max(1L, as.integer(floor(reps / 100)))

  for (r in seq_len(reps)) {
    N <- as.integer(spec$n0)
    sr <- spec$sex_ratio_init
    F <- if (!is.null(spec$F_init)) spec$F_init else 0
    k <- if (!is.null(spec$Ne_window)) spec$Ne_window else 10  # years of memory
    N_hist <- rep(sum(N), k)                                   # fill with N₀
    LE <- spec$lethal_equiv

    if (keep_traj) {
      outputs$traj[1, , r] <- N
      outputs$sr_traj[1, r] <- sr
      outputs$F_traj[1, r] <- F
      outputs$LE_traj[1, r] <- sum(LE)
    }

    for (t in seq_len(years)) {
      if (has_annual_profiles) {
        year_spec <- resolve_pva_year_spec(spec, stasis, t)
        step_out <- run_pva_step(
          N,
          sr,
          F,
          LE,
          N_hist,
          t,
          year_spec$spec,
          year_spec$stasis,
          year_spec$env_alpha,
          year_spec$env_beta
        )
      } else {
        step_out <- run_pva_step(N, sr, F, LE, N_hist, t, spec, stasis, env_alpha, env_beta)
      }
      N <- step_out$N
      sr <- step_out$sr
      F <- step_out$F
      LE <- step_out$LE
      N_hist <- step_out$N_hist

      # --- Tally trajectories ---
      if (sum(N) == 0) {
        if (keep_traj) {
          outputs$traj[(t + 1):(years + 1), , r] <- 0L
          outputs$sr_traj[(t + 1):(years + 1), r] <- sr
          outputs$F_traj[(t + 1):(years + 1), r] <- F
          outputs$LE_traj[(t + 1):(years + 1), r] <- sum(LE)
        }
        break # stop this replicate if population has gone extinct
      }

      if (keep_traj) {
        outputs$traj[t + 1, , r] <- N
        outputs$sr_traj[t + 1, r] <- sr
        outputs$F_traj[t + 1, r] <- F
        outputs$LE_traj[t + 1, r] <- sum(LE)
      }
    }
    outputs$Nend[r] <- sum(N)
    if (verbose && r %% max(1, reps %/% 50) == 0) cat(".")
    if (!is.null(progress) && (r %% progress_every == 0L || r == reps)) {
      progress(as.integer(r), as.integer(reps))
    }
  }
  if (verbose) cat("\n")

  summary <- summarize_pva_outputs(outputs, spec, years, keep_traj)

  build_pva_result(outputs, summary, spec, years, reps, stasis, seed)
}
