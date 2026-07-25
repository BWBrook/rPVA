#!/usr/bin/env Rscript

# Reproducible, read-only sanity grid for the Practical 2 Investigate catalogue.
# The script sources the same UI builders used by mod_investigate.R, runs each
# unique executable specification once, and writes a compact review table.

options(stringsAsFactors = FALSE)

repo_root <- normalizePath(".", mustWork = TRUE)
output_path <- file.path(
  repo_root,
  "docs/teaching/woodhen/practical2_investigate_default_grid.csv"
)
review_output_path <- file.path(
  repo_root,
  "docs/teaching/woodhen/practical2_investigate_default_grid_review.csv"
)

if (!requireNamespace("pkgload", quietly = TRUE)) {
  stop("The pkgload package is required to load the current rPVA checkout.", call. = FALSE)
}
pkgload::load_all(repo_root, quiet = TRUE)

# These helpers are intentionally sourced from the UI module, rather than
# reimplemented here, so the audit follows the current student-facing choices.
ui_helpers <- new.env(parent = globalenv())
sys.source(file.path(repo_root, "inst/shiny/practical2/modules/mod_investigate.R"), ui_helpers)

seed <- 123L
reps <- 1000L
horizon <- 75L
threshold <- rPVA:::woodhen_warning_threshold_pairs()
sample_trajectories <- 1L

stopf <- function(...) stop(paste0(...), call. = FALSE)
assert_true <- function(condition, ...) {
  if (!isTRUE(condition)) stopf(...)
}

catalog <- ui_helpers$investigate_future_core_catalog()
assert_true(nrow(catalog) == 4L, "Guided future catalogue must contain four threats.")

metric_from_run <- function(run) {
  q <- run$quasi_extinction_50_pairs
  e <- run$extinction_evidence
  assert_true(identical(as.integer(q$threshold_pairs), threshold),
              "Run has the wrong warning threshold.")
  assert_true(identical(as.integer(run$seed), seed), "Run seed mismatch.")
  assert_true(identical(as.integer(run$reps), reps), "Run replicate count mismatch.")
  assert_true(identical(as.integer(run$horizon), horizon), "Run horizon mismatch.")
  list(
    final_median = as.numeric(run$final_abundance$median),
    final_q025 = as.numeric(run$final_abundance$q025),
    final_q975 = as.numeric(run$final_abundance$q975),
    below100_count = as.integer(q$crossed_reps),
    below100_risk = as.numeric(q$probability_by_horizon),
    below100_crossing_projection = as.numeric(q$conditional_median_year),
    extinction_count = as.integer(e$extinct_reps),
    extinction_risk = as.numeric(e$probability_by_horizon)
  )
}

run_cache <- new.env(parent = emptyenv())
run_one <- function(scenario) {
  rPVA::run_woodhen_investigation_scenario(
    scenario = scenario,
    seed = seed,
    sample_trajectories = sample_trajectories
  )
}

scenario_rows <- list()
add_row <- function(row) {
  scenario_rows[[length(scenario_rows) + 1L]] <<- row
}

# Shared baseline is the locked current future. It is run once and reused for
# every conceptual family below.
baseline_family <- rPVA::build_woodhen_sensitivity_family(
  factor_id = "K",
  values = c(500, 150),
  seed = seed
)
baseline_scenario <- baseline_family$scenarios[[1L]]
baseline_run <- run_one(baseline_scenario)
assign(baseline_scenario$spec_fingerprint, baseline_run, envir = run_cache)
baseline_metric <- metric_from_run(baseline_run)

for (factor_id in rPVA::woodhen_sensitivity_catalog()$id) {
  factor_row <- rPVA::woodhen_sensitivity_catalog()
  factor_row <- factor_row[factor_row$id == factor_id, , drop = FALSE]
  anchors <- factor_row$anchors[[1L]]
  family <- rPVA::build_woodhen_sensitivity_family(
    factor_id = factor_id,
    values = unname(anchors[c("higher", "lower")]),
    seed = seed
  )
  for (index in 2:3) {
    scenario <- family$scenarios[[index]]
    add_row(list(
      analysis_type = "sensitivity",
      row_key = paste("sensitivity", factor_id, names(anchors)[index], sep = "__"),
      factor_id = factor_id,
      factor_label = factor_row$label[[1L]],
      factor_setting = names(anchors)[index],
      factor_value = as.numeric(scenario$components[[1L]]$value),
      threat_id = NA_character_, threat_label = NA_character_, threat_intensity = NA_character_,
      threat_setting_label = NA_character_,
      intervention_id = NA_character_, intervention_label = NA_character_, intervention_strength = NA_character_,
      intervention_setting_label = NA_character_,
      scenario_id = scenario$scenario_id,
      scenario_label = scenario$student_label,
      scenario = scenario
    ))
  }
}

for (threat_id in catalog$threat_id) {
  core <- ui_helpers$investigate_future_catalog_row(threat_id)
  threat_choices <- ui_helpers$investigate_future_threat_choices(threat_id)
  response_choices <- ui_helpers$investigate_future_response_choices(core$intervention_id[[1L]])
  for (threat_intensity in unname(threat_choices)) {
    # Build the managed family once for each exact UI pairing. Its second
    # scenario is the unmanaged threat and its third is the managed response.
    for (response_strength in unname(response_choices)) {
      family <- ui_helpers$investigate_build_future_family(
        threat_id = threat_id,
        threat_choice = threat_intensity,
        threat_custom = NULL,
        intervention_id = core$intervention_id[[1L]],
        intervention_choice = response_strength,
        intervention_custom = NULL
      )
      threat_scenario <- family$scenarios[[2L]]
      intervention_scenario <- family$scenarios[[3L]]
      threat_label <- core$threat_label[[1L]]
      threat_setting_label <- names(threat_choices)[match(threat_intensity, unname(threat_choices))]
      intervention_setting_label <- names(response_choices)[match(response_strength, unname(response_choices))]
      intervention_label <- core$intervention_label[[1L]]
      if (identical(response_strength, unname(response_choices[[1L]]))) {
        add_row(list(
          analysis_type = "threat",
          row_key = paste("threat", threat_id, threat_intensity, sep = "__"),
          factor_id = NA_character_, factor_label = NA_character_, factor_setting = NA_character_, factor_value = NA_real_,
          threat_id = threat_id, threat_label = threat_label, threat_intensity = threat_intensity,
          threat_setting_label = threat_setting_label,
          intervention_id = NA_character_, intervention_label = NA_character_, intervention_strength = NA_character_,
          intervention_setting_label = NA_character_,
          scenario_id = threat_scenario$scenario_id,
          scenario_label = threat_scenario$student_label,
          scenario = threat_scenario
        ))
      }
      add_row(list(
        analysis_type = "intervention",
        row_key = paste("intervention", threat_id, threat_intensity, response_strength, sep = "__"),
        factor_id = NA_character_, factor_label = NA_character_, factor_setting = NA_character_, factor_value = NA_real_,
        threat_id = threat_id, threat_label = threat_label, threat_intensity = threat_intensity,
        threat_setting_label = threat_setting_label,
        intervention_id = core$intervention_id[[1L]], intervention_label = intervention_label,
        intervention_strength = response_strength,
        intervention_setting_label = intervention_setting_label,
        scenario_id = intervention_scenario$scenario_id,
        scenario_label = intervention_scenario$student_label,
        scenario = intervention_scenario
      ))
    }
  }
}

assert_true(length(scenario_rows) == 64L,
            "Internal scenario enumeration must contain 64 non-baseline rows; got ", length(scenario_rows), ".")

unique_fingerprints <- unique(vapply(scenario_rows, function(row) row$scenario$spec_fingerprint, character(1)))
unique_scenarios <- lapply(unique_fingerprints, function(fingerprint) {
  scenario_rows[[match(fingerprint, vapply(scenario_rows, function(row) row$scenario$spec_fingerprint, character(1)))]]$scenario
})
cores <- min(4L, length(unique_scenarios), max(1L, parallel::detectCores(logical = TRUE) - 1L))
cat("running_unique_specs=", length(unique_scenarios), " workers=", cores, "\n", sep = "")
unique_runs <- parallel::mclapply(unique_scenarios, run_one, mc.cores = cores, mc.preschedule = TRUE)
for (index in seq_along(unique_runs)) {
  assign(unique_fingerprints[[index]], unique_runs[[index]], envir = run_cache)
}
rows <- lapply(scenario_rows, function(row) {
  run <- get(row$scenario$spec_fingerprint, envir = run_cache, inherits = FALSE)
  row$run <- run
  row$metric <- metric_from_run(run)
  row
})

spec_reuse_count <- length(scenario_rows) + 1L - length(ls(run_cache, all.names = TRUE))
assert_true(length(ls(run_cache, all.names = TRUE)) == 58L,
            "Expected 58 unique executable specs after exact reuse; got ", length(ls(run_cache, all.names = TRUE)), ".")

records <- lapply(rows, function(row) {
  m <- row$metric
  baseline_median <- baseline_metric$final_median
  data.frame(
    analysis_type = row$analysis_type,
    row_key = row$row_key,
    factor_id = row$factor_id,
    factor_label = row$factor_label,
    factor_setting = row$factor_setting,
    factor_value = row$factor_value,
    threat_id = row$threat_id,
    threat_label = row$threat_label,
    threat_intensity = row$threat_intensity,
    threat_setting_label = row$threat_setting_label,
    intervention_id = row$intervention_id,
    intervention_label = row$intervention_label,
    intervention_strength = row$intervention_strength,
    intervention_setting_label = row$intervention_setting_label,
    scenario_id = row$scenario_id,
    scenario_label = row$scenario_label,
    seed = seed,
    reps = reps,
    horizon_years = horizon,
    warning_threshold_pairs = threshold,
    final_median_birds = as.integer(round(m$final_median)),
    final_q025_birds = as.integer(round(m$final_q025)),
    final_q975_birds = as.integer(round(m$final_q975)),
    delta_final_median_birds_vs_baseline = as.integer(round(m$final_median - baseline_median)),
    percent_change_final_median_vs_baseline = 100 * (m$final_median / baseline_median - 1),
    below100_count = m$below100_count,
    below100_risk = m$below100_risk,
    below100_delta_pp_vs_baseline = 100 * (m$below100_risk - baseline_metric$below100_risk),
    conditional_median_crossing_projection_year = m$below100_crossing_projection,
    conditional_median_crossing_calendar_year = ifelse(
      is.na(m$below100_crossing_projection), NA_real_, 2025 + m$below100_crossing_projection
    ),
    extinction_count = m$extinction_count,
    extinction_risk = m$extinction_risk,
    spec_fingerprint = row$scenario$spec_fingerprint,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
})
table <- do.call(rbind, records)

# Add one explicit baseline row at the head of the review table.
baseline_record <- data.frame(
  analysis_type = "baseline", row_key = "baseline__locked", factor_id = NA_character_,
  factor_label = NA_character_, factor_setting = "baseline", factor_value = NA_real_,
  threat_id = NA_character_, threat_label = NA_character_, threat_intensity = NA_character_,
  threat_setting_label = NA_character_,
  intervention_id = NA_character_, intervention_label = NA_character_, intervention_strength = NA_character_,
  intervention_setting_label = NA_character_,
  scenario_id = baseline_scenario$scenario_id, scenario_label = baseline_scenario$student_label,
  seed = seed, reps = reps, horizon_years = horizon, warning_threshold_pairs = threshold,
  final_median_birds = as.integer(round(baseline_metric$final_median)),
  final_q025_birds = as.integer(round(baseline_metric$final_q025)),
  final_q975_birds = as.integer(round(baseline_metric$final_q975)),
  delta_final_median_birds_vs_baseline = 0L,
  percent_change_final_median_vs_baseline = 0,
  below100_count = baseline_metric$below100_count,
  below100_risk = baseline_metric$below100_risk,
  below100_delta_pp_vs_baseline = 0,
  conditional_median_crossing_projection_year = baseline_metric$below100_crossing_projection,
  conditional_median_crossing_calendar_year = ifelse(
    is.na(baseline_metric$below100_crossing_projection), NA_real_,
    2025 + baseline_metric$below100_crossing_projection
  ),
  extinction_count = baseline_metric$extinction_count,
  extinction_risk = baseline_metric$extinction_risk,
  spec_fingerprint = baseline_scenario$spec_fingerprint,
  stringsAsFactors = FALSE, check.names = FALSE
)
table <- rbind(baseline_record, table)

# Matched-threat management differences and bounded anomaly flags.
table$management_delta_birds_vs_unmanaged <- NA_integer_
table$management_delta_risk_pp_vs_unmanaged <- NA_real_
table$anomaly <- ""
table$anomaly_reasons <- ""

add_reason <- function(existing, reason) {
  if (!nzchar(existing)) reason else paste(existing, reason, sep = "; ")
}

for (i in seq_len(nrow(table))) {
  row <- table[i, , drop = FALSE]
  reasons <- character()
  expected_full_recovery <- FALSE
  if (row$analysis_type == "intervention") {
    matched_key <- paste("threat", row$threat_id, row$threat_intensity, sep = "__")
    matched <- table[table$row_key == matched_key, , drop = FALSE]
    assert_true(nrow(matched) == 1L, "Missing matched unmanaged threat for ", row$row_key, ".")
    table$management_delta_birds_vs_unmanaged[i] <-
      as.integer(row$final_median_birds - matched$final_median_birds)
    table$management_delta_risk_pp_vs_unmanaged[i] <-
      100 * (row$below100_risk - matched$below100_risk)
    expected_full_recovery <- row$intervention_strength == "high" &&
      row$intervention_id %in% c("biosecurity_eradication", "habitat_protection_restoration")
    if (!expected_full_recovery && row$final_median_birds < 0.98 * matched$final_median_birds) {
      reasons <- c(reasons, "management worsens final abundance by >2%")
    }
    if (!expected_full_recovery && row$below100_risk - matched$below100_risk > 0.02) {
      reasons <- c(reasons, "management increases warning risk by >2 percentage points")
    }
  }
  if (row$analysis_type %in% c("sensitivity", "threat", "intervention") &&
      row$spec_fingerprint != baseline_record$spec_fingerprint &&
      row$final_median_birds == baseline_record$final_median_birds &&
      row$final_q025_birds == baseline_record$final_q025_birds &&
      row$final_q975_birds == baseline_record$final_q975_birds &&
      row$below100_risk == baseline_record$below100_risk &&
      !expected_full_recovery) {
    reasons <- c(reasons, "nonbaseline outcome is fully identical to baseline")
  }
  if (row$below100_risk >= 0.95) reasons <- c(reasons, "warning risk >=95%")
  if (row$extinction_risk > 0) reasons <- c(reasons, "extinction risk >0")
  table$anomaly_reasons[i] <- paste(reasons, collapse = "; ")
  table$anomaly[i] <- if (length(reasons)) "review" else ""
}

# Monotonicity review flags are applied only within each sensitivity family.
positive_factors <- c("K", "surv", "juvenile_surv", "fecund", "cat_surv")
negative_factors <- c("cat_freq")
for (factor_id in c(positive_factors, negative_factors, "env_sd", "K_sd")) {
  sub <- table[table$factor_id == factor_id, , drop = FALSE]
  if (nrow(sub) != 2L) next
  higher <- sub[sub$factor_setting == "higher", , drop = FALSE]
  lower <- sub[sub$factor_setting == "lower", , drop = FALSE]
  reversal <- if (factor_id %in% positive_factors) {
    higher$final_median_birds < lower$final_median_birds || higher$below100_risk > lower$below100_risk
  } else if (factor_id %in% negative_factors) {
    higher$final_median_birds > lower$final_median_birds || higher$below100_risk < lower$below100_risk
  } else {
    higher$below100_risk < lower$below100_risk
  }
  if (isTRUE(reversal)) {
    for (key in sub$row_key) {
      i <- match(key, table$row_key)
      table$anomaly_reasons[i] <- add_reason(table$anomaly_reasons[i], "directional/monotonic reversal for review")
      table$anomaly[i] <- "review"
    }
  }
}

# Threat severity should not improve the outcome; stronger responses should
# improve it. These are review flags rather than hard failures because finite
# stochastic samples can produce small non-monotone differences.
for (threat_id in unique(table$threat_id[table$analysis_type == "threat"])) {
  unmanaged <- table[table$analysis_type == "threat" & table$threat_id == threat_id, , drop = FALSE]
  unmanaged <- unmanaged[match(c("low", "moderate", "high"), unmanaged$threat_intensity), , drop = FALSE]
  if (nrow(unmanaged) == 3L && all(!is.na(unmanaged$final_median_birds))) {
    reversal <- any(diff(unmanaged$final_median_birds) > 0) || any(diff(unmanaged$below100_risk) < 0)
    if (reversal) {
      keys <- unmanaged$row_key
      for (key in keys) {
        i <- match(key, table$row_key)
        table$anomaly_reasons[i] <- add_reason(table$anomaly_reasons[i], "threat severity is non-monotone for review")
        table$anomaly[i] <- "review"
      }
    }
    if (length(unique(unmanaged$below100_risk)) == 1L) {
      for (key in unmanaged$row_key) {
        i <- match(key, table$row_key)
        table$anomaly_reasons[i] <- add_reason(table$anomaly_reasons[i], "low-information threat group: warning risk unchanged across severity")
        table$anomaly[i] <- "review"
      }
    }
  }
  for (intensity in unique(table$threat_intensity[table$analysis_type == "intervention" & table$threat_id == threat_id])) {
    managed <- table[table$analysis_type == "intervention" & table$threat_id == threat_id & table$threat_intensity == intensity, , drop = FALSE]
    managed <- managed[match(c("low", "moderate", "high"), managed$intervention_strength), , drop = FALSE]
    if (nrow(managed) == 3L && all(!is.na(managed$final_median_birds))) {
      reversal <- any(diff(managed$final_median_birds) < 0) || any(diff(managed$below100_risk) > 0)
      if (reversal) {
        for (key in managed$row_key) {
          i <- match(key, table$row_key)
          table$anomaly_reasons[i] <- add_reason(table$anomaly_reasons[i], "response strength is non-monotone for review")
          table$anomaly[i] <- "review"
        }
      }
      if (length(unique(managed$below100_risk)) == 1L) {
        for (key in managed$row_key) {
          i <- match(key, table$row_key)
          table$anomaly_reasons[i] <- add_reason(table$anomaly_reasons[i], "low-information response group: warning risk unchanged across strengths")
          table$anomaly[i] <- "review"
        }
      }
    }
  }
}

assert_true(nrow(table) == 65L, "Output must contain exactly 65 conceptual rows.")
assert_true(sum(table$analysis_type == "baseline") == 1L, "Expected one baseline row.")
assert_true(sum(table$analysis_type == "sensitivity") == 16L, "Expected 16 sensitivity rows.")
assert_true(sum(table$analysis_type == "threat") == 12L, "Expected 12 unmanaged threat rows.")
assert_true(sum(table$analysis_type == "intervention") == 36L, "Expected 36 managed rows.")
assert_true(!anyDuplicated(table$row_key), "Output row keys must be unique.")
assert_true(all(table$seed == seed & table$reps == reps & table$horizon_years == horizon & table$warning_threshold_pairs == threshold),
            "Runs do not share seed, replicate count, horizon or threshold.")
assert_true(all(is.finite(table$final_median_birds) & table$final_median_birds >= 0), "Invalid final medians.")
assert_true(all(is.finite(table$final_q025_birds) & is.finite(table$final_q975_birds) & table$final_q025_birds <= table$final_q975_birds),
            "Invalid final intervals.")
assert_true(all(is.finite(table$below100_risk) & table$below100_risk >= 0 & table$below100_risk <= 1), "Invalid warning probabilities.")
assert_true(all(is.finite(table$extinction_risk) & table$extinction_risk >= 0 & table$extinction_risk <= 1), "Invalid extinction probabilities.")
assert_true(all(!is.na(table$final_median_birds) & !is.na(table$below100_count)), "Missing key metrics.")

table$spec_fingerprint <- NULL
dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)
write.csv(table, output_path, row.names = FALSE, na = "")

analysis_labels <- c(
  baseline = "Baseline",
  sensitivity = "Sensitivity",
  threat = "Threat only",
  intervention = "Threat + management"
)
review_table <- data.frame(
  analysis = unname(analysis_labels[table$analysis_type]),
  scenario = ifelse(
    table$analysis_type == "baseline",
    "Locked current future",
    ifelse(
      table$analysis_type == "sensitivity",
      table$factor_label,
      table$threat_label
    )
  ),
  tested_setting = ifelse(
    table$analysis_type == "baseline",
    "No additional threat or response",
    ifelse(
      table$analysis_type == "sensitivity",
      table$scenario_label,
      table$threat_setting_label
    )
  ),
  management_response = ifelse(
    table$analysis_type == "intervention",
    table$intervention_setting_label,
    NA_character_
  ),
  final_median_birds = table$final_median_birds,
  change_vs_baseline_birds = table$delta_final_median_birds_vs_baseline,
  change_vs_baseline_percent = round(table$percent_change_final_median_vs_baseline, 1),
  risk_below_100_pairs_percent = round(100 * table$below100_risk, 1),
  risk_change_vs_baseline_percentage_points = round(table$below100_delta_pp_vs_baseline, 1),
  median_calendar_year_first_below_100_pairs =
    table$conditional_median_crossing_calendar_year,
  management_benefit_birds_vs_same_threat =
    table$management_delta_birds_vs_unmanaged,
  management_risk_change_vs_same_threat_percentage_points =
    round(table$management_delta_risk_pp_vs_unmanaged, 1),
  extinction_risk_percent = round(100 * table$extinction_risk, 1),
  review_note = table$anomaly_reasons,
  stringsAsFactors = FALSE,
  check.names = FALSE
)
write.csv(review_table, review_output_path, row.names = FALSE, na = "")

cat("output=", output_path, "\n", sep = "")
cat("review_output=", review_output_path, "\n", sep = "")
cat("rows=", nrow(table), " baseline=", sum(table$analysis_type == "baseline"),
    " sensitivity=", sum(table$analysis_type == "sensitivity"),
    " threat=", sum(table$analysis_type == "threat"),
    " intervention=", sum(table$analysis_type == "intervention"), "\n", sep = "")
cat("unique_executable_specs=", length(ls(run_cache, all.names = TRUE)),
    " reused_rows=", spec_reuse_count, "\n", sep = "")
cat("warning_risk_range=", sprintf("%.3f", min(table$below100_risk)), "..",
    sprintf("%.3f", max(table$below100_risk)), "\n", sep = "")
cat("final_median_range=", min(table$final_median_birds), "..", max(table$final_median_birds), " birds\n", sep = "")
cat("anomaly_rows=", sum(table$anomaly == "review"), "\n", sep = "")
