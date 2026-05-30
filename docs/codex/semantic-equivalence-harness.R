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

run_checked <- function(command, args, env = character(), cwd = NULL) {
  old <- NULL
  if (!is.null(cwd)) {
    old <- getwd()
    setwd(cwd)
    on.exit(setwd(old), add = TRUE)
  }
  status <- system2(command, args, stdout = TRUE, stderr = TRUE, env = env)
  code <- attr(status, "status")
  if (is.null(code)) {
    code <- 0L
  }
  if (!identical(code, 0L)) {
    cat(paste(status, collapse = "\n"), "\n")
    stop("Command failed: ", command, " ", paste(args, collapse = " "), call. = FALSE)
  }
  status
}

as_numeric_vector <- function(x) {
  if (is.null(x)) {
    return(NULL)
  }
  as.numeric(x)
}

max_abs_diff <- function(a, b) {
  a <- as_numeric_vector(a)
  b <- as_numeric_vector(b)
  if (is.null(a) && is.null(b)) {
    return(0)
  }
  if (is.null(a) || is.null(b) || length(a) != length(b)) {
    return(Inf)
  }
  if (length(a) == 0L) {
    return(0)
  }
  max(abs(a - b), na.rm = TRUE)
}

same_numeric <- function(a, b, tolerance = 1e-12) {
  d <- max_abs_diff(a, b)
  is.finite(d) && d <= tolerance
}

row <- function(section, item, status, max_diff = NA_real_, note = "") {
  data.frame(
    section = section,
    item = item,
    status = status,
    max_abs_diff = max_diff,
    note = note,
    stringsAsFactors = FALSE
  )
}

`%||%` <- function(x, y) if (is.null(x)) y else x

parse_dependency_names <- function(value) {
  if (length(value) == 0L || is.na(value)) {
    return(character())
  }

  entries <- trimws(unlist(strsplit(value, ",", fixed = TRUE)))
  entries <- sub("\\s*\\(.*\\)$", "", entries)
  entries[nzchar(entries)]
}

origin_main_dependency_names <- function(repo) {
  desc_lines <- run_checked("git", c("-C", repo, "show", "origin/main:DESCRIPTION"))
  con <- textConnection(desc_lines)
  on.exit(close(con), add = TRUE)
  desc <- read.dcf(con)
  fields <- intersect(c("Depends", "Imports"), colnames(desc))
  packages <- unique(unlist(lapply(fields, function(field) parse_dependency_names(desc[1, field]))))
  setdiff(packages, "R")
}

package_available <- function(package, libraries) {
  any(file.exists(file.path(libraries, package, "DESCRIPTION")))
}

ensure_compat_packages <- function(packages, compat_lib, renv_lib) {
  libraries <- c(compat_lib, renv_lib)
  missing <- packages[!vapply(packages, package_available, logical(1), libraries = libraries)]
  if (length(missing) == 0L) {
    return(invisible(character()))
  }

  message(
    "Installing comparison-only package(s) into ",
    compat_lib,
    ": ",
    paste(missing, collapse = ", ")
  )
  renv::install(missing, library = compat_lib, prompt = FALSE, lock = FALSE)
  invisible(missing)
}

compare_case <- function(name, main_case, head_case) {
  checks <- list(
    final_totals = same_numeric(main_case$final_totals, head_case$final_totals),
    total_traj = same_numeric(main_case$total_traj, head_case$total_traj),
    ext_prob = same_numeric(main_case$ext_prob, head_case$ext_prob),
    nend_summary = same_numeric(main_case$nend_summary, head_case$nend_summary),
    traj_mean = same_numeric(main_case$traj_mean, head_case$traj_mean),
    sr_mean = same_numeric(main_case$sr_mean, head_case$sr_mean),
    F_mean = same_numeric(main_case$F_mean, head_case$F_mean)
  )
  diffs <- c(
    final_totals = max_abs_diff(main_case$final_totals, head_case$final_totals),
    total_traj = max_abs_diff(main_case$total_traj, head_case$total_traj),
    ext_prob = max_abs_diff(main_case$ext_prob, head_case$ext_prob),
    nend_summary = max_abs_diff(main_case$nend_summary, head_case$nend_summary),
    traj_mean = max_abs_diff(main_case$traj_mean, head_case$traj_mean),
    sr_mean = max_abs_diff(main_case$sr_mean, head_case$sr_mean),
    F_mean = max_abs_diff(main_case$F_mean, head_case$F_mean)
  )

  if (all(unlist(checks))) {
    return(row("core_cases", name, "equivalent", max(diffs), "All compared numeric outputs matched."))
  }

  failed <- names(checks)[!unlist(checks)]
  row(
    "core_cases",
    name,
    "different",
    suppressWarnings(max(diffs, na.rm = TRUE)),
    paste("Differing fields:", paste(failed, collapse = ", "))
  )
}

compare_woodhen <- function(main_tbl, head_tbl) {
  main_tbl <- as.data.frame(main_tbl)
  head_tbl <- as.data.frame(head_tbl)
  common_cols <- intersect(names(main_tbl), names(head_tbl))
  main_tbl <- main_tbl[common_cols]
  head_tbl <- head_tbl[common_cols]

  same_names <- identical(main_tbl$scenario, head_tbl$scenario)
  numeric_cols <- common_cols[vapply(main_tbl[common_cols], is.numeric, logical(1))]
  diffs <- vapply(numeric_cols, function(col) max_abs_diff(main_tbl[[col]], head_tbl[[col]]), numeric(1))
  numeric_same <- all(vapply(numeric_cols, function(col) same_numeric(main_tbl[[col]], head_tbl[[col]]), logical(1)))

  if (same_names && numeric_same) {
    return(row("scenario_smoke", "woodhen_summary", "equivalent", max(diffs), "Scenario names and numeric summaries matched."))
  }

  note <- c()
  if (!same_names) {
    note <- c(note, "scenario names differ")
  }
  if (!numeric_same) {
    note <- c(note, paste("numeric columns differ:", paste(names(diffs)[diffs > 1e-12], collapse = ", ")))
  }
  row("scenario_smoke", "woodhen_summary", "different", suppressWarnings(max(diffs, na.rm = TRUE)), paste(note, collapse = "; "))
}

args <- parse_args(commandArgs(trailingOnly = TRUE))
repo <- normalizePath(args$repo %||% getwd(), winslash = "/", mustWork = TRUE)
output_csv <- args$output %||% file.path(repo, "docs", "codex", "semantic-equivalence-results-2026-05-30.csv")
runner <- file.path(repo, "docs", "codex", "semantic-equivalence-runner.R")

if (!file.exists(runner)) {
  stop("Runner script not found: ", runner, call. = FALSE)
}

tmp_root <- tempfile("semantic-equivalence-")
dir.create(tmp_root, recursive = TRUE)
renv_lib <- renv::paths$library()
compat_lib <- file.path(tmp_root, "compat-library")
dir.create(compat_lib, recursive = TRUE)
main_wt <- file.path(tmp_root, "origin-main")
head_wt <- file.path(tmp_root, "head")
main_rds <- file.path(tmp_root, "origin-main.rds")
head_rds <- file.path(tmp_root, "head.rds")

cleanup <- function() {
  if (dir.exists(main_wt)) {
    system2("git", c("-C", repo, "worktree", "remove", "--force", main_wt), stdout = FALSE, stderr = FALSE)
  }
  if (dir.exists(head_wt)) {
    system2("git", c("-C", repo, "worktree", "remove", "--force", head_wt), stdout = FALSE, stderr = FALSE)
  }
  unlink(tmp_root, recursive = TRUE, force = TRUE)
}
on.exit(cleanup(), add = TRUE)

ensure_compat_packages(origin_main_dependency_names(repo), compat_lib, renv_lib)

run_checked("git", c("-C", repo, "worktree", "add", "--detach", main_wt, "origin/main"))
run_checked("git", c("-C", repo, "worktree", "add", "--detach", head_wt, "HEAD"))

runner_libs <- paste(c(compat_lib, renv_lib), collapse = .Platform$path.sep)
runner_env <- c(
  paste0("R_LIBS=", runner_libs),
  paste0("R_LIBS_USER=", runner_libs),
  "RENV_CONFIG_AUTOLOADER_ENABLED=FALSE"
)

run_checked(
  "Rscript",
  c("--vanilla", runner, "--repo", main_wt, "--label", "origin_main", "--out", main_rds),
  env = runner_env
)
run_checked(
  "Rscript",
  c("--vanilla", runner, "--repo", head_wt, "--label", "head", "--out", head_rds),
  env = runner_env
)

main <- readRDS(main_rds)
head <- readRDS(head_rds)

rows <- list(
  row("metadata", "origin_main_sha", "recorded", NA_real_, main$sha),
  row("metadata", "head_sha", "recorded", NA_real_, head$sha),
  row("intentional_api", "stochasticity_key", "intentional_difference", NA_real_,
      paste0("origin/main uses ", main$stochastic_key, "; HEAD uses ", head$stochastic_key)),
  row("intentional_api", "run_pva_core_keep_traj_default", "intentional_difference", NA_real_,
      paste0("origin/main=", main$defaults$run_pva_core_keep_traj,
             "; HEAD=", head$defaults$run_pva_core_keep_traj)),
  row("intentional_api", "run_pva_core_verbose_default", "intentional_difference", NA_real_,
      paste0("origin/main=", main$defaults$run_pva_core_verbose,
             "; HEAD=", head$defaults$run_pva_core_verbose)),
  row("intentional_api", "run_scenarios_keep_traj_argument", "intentional_difference", NA_real_,
      paste0("origin/main=", main$defaults$run_scenarios_has_keep_traj,
             "; HEAD=", head$defaults$run_scenarios_has_keep_traj)),
  row("intentional_api", "demo_sd_acceptance", "intentional_difference", NA_real_,
      paste0("origin/main=", main$contracts$accepts_demo_sd$ok,
             "; HEAD=", head$contracts$accepts_demo_sd$ok)),
  row("intentional_api", "demographic_stochasticity_acceptance", "intentional_difference", NA_real_,
      paste0("origin/main=", main$contracts$accepts_demographic_stochasticity$ok,
             "; HEAD=", head$contracts$accepts_demographic_stochasticity$ok))
)

for (case_name in names(main$cases)) {
  rows[[length(rows) + 1L]] <- compare_case(case_name, main$cases[[case_name]], head$cases[[case_name]])
}
rows[[length(rows) + 1L]] <- compare_woodhen(main$woodhen, head$woodhen)

results <- do.call(rbind, rows)
dir.create(dirname(output_csv), recursive = TRUE, showWarnings = FALSE)
write.csv(results, output_csv, row.names = FALSE)

print(results)

if (any(results$status == "different")) {
  quit(status = 1L)
}
