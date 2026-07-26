compute_env_beta_params <- function(surv, env_sd) {
  if (env_sd <= 0) {
    return(list(alpha = rep(NA_real_, length(surv)), beta = rep(NA_real_, length(surv))))
  }

  var_env <- env_sd^2
  denom <- surv * (1 - surv) / var_env - 1
  env_alpha <- surv * denom
  env_beta <- (1 - surv) * denom
  invalid <- env_alpha <= 0 | env_beta <= 0

  if (any(invalid)) {
    stop("env_sd too large for some survival rates: produces non-positive alpha/beta")
  }

  list(alpha = env_alpha, beta = env_beta)
}

normalize_pva_spec <- function(spec, stasis) {
  stopifnot(is.list(spec))
  spec <- normalize_pva_spec_fields(spec)
  spec <- validate_full_pva_spec(spec)

  n_stage <- length(spec$surv)

  if (is.null(stasis)) {
    if (!is.null(spec$stasis)) {
      stasis <- spec$stasis
    } else {
      stasis <- rep(0, n_stage)
    }
  }
  if (length(stasis) != n_stage) {
    stop("stasis must be length ", n_stage)
  }

  if (is.null(spec$sex_ratio_init)) spec$sex_ratio_init <- 0.5
  if (is.null(spec$monogamy)) spec$monogamy <- FALSE

  if (is.null(spec$K)) spec$K <- NA_real_
  if (is.null(spec$K_sd)) spec$K_sd <- 0

  if (is.null(spec$cat_freq)) spec$cat_freq <- 0
  if (is.null(spec$cat_surv)) spec$cat_surv <- 1
  if (is.null(spec$cat_repro)) spec$cat_repro <- 1

  if (is.null(spec$genetics)) spec$genetics <- FALSE
  if (is.null(spec$F_init)) spec$F_init <- 0
  if (is.null(spec$lethal_equiv)) spec$lethal_equiv <- rep(0, n_stage)
  if (is.null(spec$B_on_fec)) spec$B_on_fec <- 0
  if (is.null(spec$Ne_N_ratio)) spec$Ne_N_ratio <- 1
  if (is.null(spec$Ne_window)) spec$Ne_window <- 1
  if (is.null(spec$purge_kappa)) spec$purge_kappa <- 0

  if (is.null(spec$removal_years)) spec$removal_years <- integer(0)
  if (is.null(spec$removal_vec)) spec$removal_vec <- integer(n_stage)

  if (is.null(spec$release_years)) spec$release_years <- integer(0)
  if (is.null(spec$release_vec)) spec$release_vec <- integer(n_stage)

  env_params <- compute_env_beta_params(spec$surv, spec$env_sd)

  list(
    spec = spec,
    stasis = stasis,
    n_stage = n_stage,
    env_alpha = env_params$alpha,
    env_beta = env_params$beta
  )
}

resolve_pva_year_spec <- function(spec, stasis, year) {
  year <- validate_temporal_year_arg(year, "year", spec$years)
  profiles <- spec$annual_profiles
  year_spec <- spec
  year_spec$annual_profiles <- NULL

  if (!is.null(profiles)) {
    scalar_fields <- intersect(
      names(profiles),
      c("K", "K_sd", "env_sd", "cat_freq", "cat_surv", "cat_repro")
    )
    stage_fields <- intersect(names(profiles), c("surv", "fecund"))

    for (field in scalar_fields) {
      year_spec[[field]] <- profiles[[field]][year]
    }
    for (field in stage_fields) {
      year_spec[[field]] <- as.numeric(profiles[[field]][year, ])
    }
  }

  env_params <- compute_env_beta_params(year_spec$surv, year_spec$env_sd)
  list(
    spec = year_spec,
    stasis = stasis,
    env_alpha = env_params$alpha,
    env_beta = env_params$beta
  )
}

initialize_pva_outputs <- function(years, n_stage, reps, keep_traj) {
  outputs <- list(Nend = numeric(reps), ext_prob = NULL)

  if (keep_traj) {
    outputs$traj <- array(
      NA_integer_,
      dim = c(years + 1, n_stage, reps),
      dimnames = list(
        time = 0:years,
        stage = paste0("stage", seq_len(n_stage)),
        rep = NULL
      )
    )
    outputs$sr_traj <- matrix(
      NA_real_,
      nrow = years + 1,
      ncol = reps,
      dimnames = list(time = 0:years, rep = NULL)
    )
    outputs$F_traj <- matrix(NA_real_, nrow = years + 1, ncol = reps)
    outputs$LE_traj <- matrix(NA_real_, nrow = years + 1, ncol = reps)
  } else {
    outputs$traj <- NULL
    outputs$sr_traj <- NULL
    outputs$F_traj <- NULL
    outputs$LE_traj <- NULL
  }

  outputs
}

draw_vital_rates <- function(spec, stasis, env_alpha, env_beta) {
  n_stage <- length(spec$surv)

  if (spec$env_sd > 0) {
    surv_t <- rbeta(n_stage, env_alpha, env_beta)
    stasis_t <- pmin(1, stasis) * rbeta(n_stage, env_alpha, env_beta)
    stasis_t[n_stage] <- surv_t[n_stage]
    env_fec <- exp(rnorm(n_stage, 0, spec$env_sd))
  } else {
    surv_t <- spec$surv
    stasis_t <- pmin(1, stasis)
    env_fec <- rep(1, n_stage)
  }

  list(
    surv = surv_t,
    stasis = stasis_t,
    fec = pmax(0, spec$fecund * env_fec)
  )
}

resolve_carrying_capacity <- function(spec) {
  if (!is.na(spec$K) && spec$K_sd > 0) {
    return(round(rnorm(1, spec$K, spec$K_sd)))
  }

  spec$K
}

apply_release_rescue <- function(F, N_next, year, spec) {
  if (!is.null(spec$release_years) && year %in% spec$release_years) {
    migrants <- sum(spec$release_vec)
    if (migrants > 0 && sum(N_next) > 0) {
      return((1 - migrants / sum(N_next))^2 * F)
    }
  }

  F
}

run_pva_step <- function(N, sr, F, LE, N_hist, year, spec, stasis, env_alpha, env_beta) {
  rates <- draw_vital_rates(spec, stasis, env_alpha, env_beta)

  cat_res <- maybe_apply_catastrophe(rates$surv, rates$fec, spec)
  surv_t <- cat_res$surv
  fec_t <- cat_res$fec

  N_hist <- c(N_hist[-1], sum(N))
  Ne_t <- spec$Ne_N_ratio / mean(1 / N_hist)
  gen <- genetic_update(surv_t, fec_t, N, F, spec, LE, Ne_override = Ne_t)
  surv_t <- gen$surv
  fec_t <- gen$fec
  F <- gen$F
  LE <- gen$LE

  rec <- recruit_phase(N, fec_t, sr, spec, spec$demographic_stochasticity)
  N_next <- integer(length(N))
  N_next[1] <- rec$recruits
  N_next <- N_next + survival_phase(N, surv_t, rates$stasis, spec, spec$demographic_stochasticity)

  N_next <- apply_removals(N_next, year, spec)
  N_next <- apply_releases(N_next, year, spec)
  F <- apply_release_rescue(F, N_next, year, spec)

  N_next <- apply_ceiling_K(N_next, resolve_carrying_capacity(spec))
  N_next[N_next < 0] <- 0

  list(N = N_next, sr = rec$sr, F = F, LE = LE, N_hist = N_hist)
}

summarize_final_abundance <- function(Nend, final_survivors) {
  if (length(final_survivors) == 0) {
    return(list(median = 0, lo95 = 0, hi95 = 0))
  }

  Np <- Nend[final_survivors]
  list(
    median = as.numeric(round(quantile(Np, probs = 0.50))),
    lo95 = as.numeric(round(quantile(Np, probs = 0.025))),
    hi95 = as.numeric(round(quantile(Np, probs = 0.975)))
  )
}

summarize_pva_outputs <- function(outputs, spec, years, keep_traj) {
  if (!keep_traj) {
    final_survivors <- which(outputs$Nend > 0)
    summary <- summarize_final_abundance(outputs$Nend, final_survivors)
    return(list(
      ext_prob = NULL,
      Nend_summary = summary,
      traj_mean = NULL,
      sr_mean = NULL,
      F_mean = NULL,
      LE_mean = NULL
    ))
  }

  extinct_mat <- apply(outputs$traj, c(1, 3), function(stage_counts) sum(stage_counts) == 0)
  ext_prob <- rowMeans(extinct_mat)

  traj_raw <- apply(outputs$traj, c(1, 2), mean)
  surv_prob <- 1 - ext_prob
  traj_mean <- traj_raw

  for (time_index in seq_len(years + 1)) {
    if (surv_prob[time_index] > 0) {
      traj_mean[time_index, ] <- round(traj_raw[time_index, ] / surv_prob[time_index])
    } else {
      traj_mean[time_index, ] <- 0L
    }
  }

  final_survivors <- which(!extinct_mat[years + 1, ])
  summary <- summarize_final_abundance(outputs$Nend, final_survivors)
  sr_mean <- rowMeans(outputs$sr_traj)
  F_mean <- rowMeans(outputs$F_traj)
  F_mean[1] <- spec$F_init

  list(
    ext_prob = ext_prob,
    Nend_summary = summary,
    traj_mean = traj_mean,
    sr_mean = sr_mean,
    F_mean = F_mean,
    LE_mean = rowMeans(outputs$LE_traj)
  )
}

build_pva_result <- function(outputs, summary, spec, years, reps, stasis, seed) {
  list(
    Nend = outputs$Nend,
    traj = outputs$traj,
    sr_traj = outputs$sr_traj,
    F_traj = outputs$F_traj,
    LE_traj = outputs$LE_traj,
    ext_prob = summary$ext_prob,
    Nend_summary = summary$Nend_summary,
    traj_mean = summary$traj_mean,
    sr_mean = summary$sr_mean,
    F_mean = summary$F_mean,
    LE_mean = summary$LE_mean,
    params = c(
      spec,
      list(years = years, reps = reps, stasis = stasis, seed = seed)
    ),
    raw = list(
      Nend = outputs$Nend,
      traj = outputs$traj,
      sr_traj = outputs$sr_traj,
      F_traj = outputs$F_traj,
      LE_traj = outputs$LE_traj
    )
  )
}
