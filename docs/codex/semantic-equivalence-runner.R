#!/usr/bin/env Rscript

parse_args <- function(args) {
  out <- list()
  i <- 1L
  while (i <= length(args)) {
    key <- args[[i]]
    if (!startsWith(key, "--") || i == length(args)) {
      stop("Expected --key value arguments.", call. = FALSE)
    }
    out[[substring(key, 3L)]] <- args[[i + 1L]]
    i <- i + 2L
  }
  out
}

args <- parse_args(commandArgs(trailingOnly = TRUE))
repo <- normalizePath(args$repo, winslash = "/", mustWork = TRUE)
label <- args$label
out_path <- args$out

setwd(repo)
suppressPackageStartupMessages(pkgload::load_all(repo, quiet = TRUE))

sha <- system2("git", c("-C", repo, "rev-parse", "--short", "HEAD"), stdout = TRUE)
uses_refactor_key <- identical(label, "head")
stochastic_key <- if (uses_refactor_key) "demographic_stochasticity" else "demo_sd"

with_stochastic_key <- function(spec, value) {
  spec[[stochastic_key]] <- value
  spec
}

base_spec <- function(years = 8L,
                      reps = 4L,
                      env_sd = 0,
                      stochastic = FALSE,
                      K = 1e6,
                      removal_years = integer(0),
                      removal_vec = c(0L, 0L, 0L),
                      release_years = integer(0),
                      release_vec = c(0L, 0L, 0L)) {
  spec <- list(
    name = "comparison_spec",
    years = as.integer(years),
    reps = as.integer(reps),
    surv = c(0.45, 0.65, 0.75),
    stasis = c(0.05, 0.20, 0.75),
    fecund = c(0, 1.25, 1.80),
    n0 = c(30, 12, 8),
    env_sd = env_sd,
    sex_ratio_init = 0.48,
    monogamy = TRUE,
    K = K,
    K_sd = 0,
    cat_freq = 0,
    cat_surv = 1,
    cat_repro = 1,
    genetics = FALSE,
    F_init = 0,
    lethal_equiv = c(0, 0, 0),
    B_on_fec = 0,
    Ne_N_ratio = 1,
    Ne_window = 1,
    purge_kappa = 0
  )

  if (length(removal_years) > 0 || any(removal_vec != 0)) {
    spec$removal_years <- as.integer(removal_years)
    spec$removal_vec <- as.integer(removal_vec)
  }

  if (length(release_years) > 0 || any(release_vec != 0)) {
    spec$release_years <- as.integer(release_years)
    spec$release_vec <- as.integer(release_vec)
  }

  with_stochastic_key(spec, stochastic)
}

extract_traj_array <- function(out) {
  if (!is.null(out$raw$traj)) {
    return(out$raw$traj)
  }
  out$traj
}

summarise_core_output <- function(out, years) {
  traj <- extract_traj_array(out)
  total_traj <- if (!is.null(traj)) {
    apply(traj, c(1L, 3L), sum)
  } else {
    NULL
  }
  final_totals <- if (!is.null(total_traj)) {
    total_traj[nrow(total_traj), ]
  } else if (!is.null(out$Nend)) {
    out$Nend
  } else {
    numeric(0)
  }

  list(
    final_totals = as.numeric(final_totals),
    total_traj = total_traj,
    ext_prob = out$ext_prob,
    nend_summary = unlist(out$Nend_summary, use.names = TRUE),
    traj_mean = out$traj_mean,
    sr_mean = out$sr_mean,
    F_mean = out$F_mean
  )
}

run_core_case <- function(name, spec, seed, keep_traj = TRUE) {
  out <- run_pva_core(
    spec,
    years = spec$years,
    reps = spec$reps,
    keep_traj = keep_traj,
    seed = seed,
    verbose = FALSE
  )
  summarise_core_output(out, spec$years)
}

try_core_accepts <- function(spec) {
  result <- try(
    run_pva_core(spec, years = 1L, reps = 1L, keep_traj = TRUE, seed = 1L, verbose = FALSE),
    silent = TRUE
  )
  if (inherits(result, "try-error")) {
    return(list(ok = FALSE, message = conditionMessage(attr(result, "condition"))))
  }
  list(ok = TRUE, message = "")
}

old_key_spec <- base_spec(years = 1L, reps = 1L)
old_key_spec$demographic_stochasticity <- NULL
old_key_spec$demo_sd <- FALSE

new_key_spec <- base_spec(years = 1L, reps = 1L)
new_key_spec$demo_sd <- NULL
new_key_spec$demographic_stochasticity <- FALSE

cases <- list(
  deterministic_minimal = run_core_case(
    "deterministic_minimal",
    base_spec(years = 8L, reps = 4L, env_sd = 0, stochastic = FALSE),
    seed = 101L
  ),
  fixed_seed_demographic = run_core_case(
    "fixed_seed_demographic",
    base_spec(years = 12L, reps = 25L, env_sd = 0, stochastic = TRUE),
    seed = 20260530L
  ),
  fixed_seed_environmental = run_core_case(
    "fixed_seed_environmental",
    base_spec(years = 10L, reps = 20L, env_sd = 0.05, stochastic = TRUE),
    seed = 20260531L
  ),
  deterministic_management = run_core_case(
    "deterministic_management",
    base_spec(
      years = 8L,
      reps = 3L,
      env_sd = 0,
      stochastic = FALSE,
      K = 70,
      removal_years = c(2L, 5L),
      removal_vec = c(0L, 2L, 3L),
      release_years = c(3L),
      release_vec = c(0L, 0L, 8L)
    ),
    seed = 303L
  )
)

woodhen <- NULL
woodhen_output <- capture.output({
  if ("keep_traj" %in% names(formals(run_scenarios))) {
    woodhen <- run_scenarios(
      "woodhen",
      csv_out = NULL,
      rds_out = NULL,
      keep_traj = FALSE,
      parallel = FALSE
    )
  } else {
    woodhen <- run_scenarios(
      "woodhen",
      csv_out = NULL,
      rds_out = NULL,
      parallel = FALSE
    )
  }
})

defaults <- list(
  run_pva_core_keep_traj = deparse(formals(run_pva_core)$keep_traj),
  run_pva_core_verbose = deparse(formals(run_pva_core)$verbose),
  run_scenarios_has_keep_traj = "keep_traj" %in% names(formals(run_scenarios))
)

contracts <- list(
  accepts_demo_sd = try_core_accepts(old_key_spec),
  accepts_demographic_stochasticity = try_core_accepts(new_key_spec)
)

result <- list(
  label = label,
  repo = repo,
  sha = sha,
  stochastic_key = stochastic_key,
  defaults = defaults,
  contracts = contracts,
  cases = cases,
  woodhen = woodhen,
  woodhen_console = woodhen_output
)

saveRDS(result, out_path)
