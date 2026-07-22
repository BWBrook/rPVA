woodhen_audit_collapse <- function(value) {
  if (is.null(value) || length(value) == 0L) {
    return("none")
  }
  if (is.logical(value)) {
    return(ifelse(value, "TRUE", "FALSE"))
  }
  paste(value, collapse = ", ")
}

woodhen_audit_mapping <- function(mapping) {
  paste(vapply(names(mapping), function(component_id) {
    component <- mapping[[component_id]]
    paste0(
      component_id, ": ", component$operator, " ",
      woodhen_audit_collapse(component$affected_fields), " [stages ",
      woodhen_audit_collapse(component$affected_stages), "]"
    )
  }, character(1)), collapse = "; ")
}

woodhen_audit_value <- function(value) {
  if (is.null(value) || length(value) == 0L) {
    return("none")
  }
  if (is.logical(value)) {
    return(paste(ifelse(value, "TRUE", "FALSE"), collapse = ", "))
  }
  paste(format(value, scientific = FALSE, trim = TRUE), collapse = ", ")
}

woodhen_audit_range <- function(value) {
  if (length(value) != 2L || all(is.na(value))) {
    return("not applicable")
  }
  paste0(woodhen_audit_value(value[["min"]]), " to ", woodhen_audit_value(value[["max"]]))
}

woodhen_audit_markdown_cell <- function(value) {
  value <- ifelse(is.na(value), "", as.character(value))
  gsub("|", "\\|", value, fixed = TRUE)
}

woodhen_audit_markdown_table <- function(data) {
  display <- data
  names(display) <- gsub("_", " ", names(display), fixed = TRUE)
  header <- paste0("| ", paste(names(display), collapse = " | "), " |")
  divider <- paste0("| ", paste(rep("---", ncol(display)), collapse = " | "), " |")
  body <- apply(display, 1L, function(row) {
    paste0("| ", paste(woodhen_audit_markdown_cell(row), collapse = " | "), " |")
  })
  c(header, divider, body)
}

woodhen_audit_baseline_metadata <- function() {
  data.frame(
    parameter = c(
      "name", "years", "reps", "surv", "stasis", "fecund", "sex_ratio_init",
      "monogamy", "n0", "demographic_stochasticity", "env_sd", "K", "K_sd",
      "cat_freq", "cat_surv", "cat_repro", "genetics", "F_init",
      "lethal_equiv", "B_on_fec", "Ne_N_ratio", "Ne_window", "purge_kappa"
    ),
    unit = c(
      "scenario identifier", "years", "simulated futures",
      "annual probability by model stage 1-7 (documented as female stages)",
      "annual probability of remaining in model stage 1-7",
      "mean fledglings per female by stage 1-7",
      "proportion female", "logical pairing assumption",
      "female-equivalent individuals by stage 1-7", "logical switch",
      "standard deviation on annual vital-rate draws", "breeding pairs",
      "standard deviation in breeding-pair capacity", "annual probability",
      "survival multiplier in a catastrophe year",
      "fecundity multiplier in a catastrophe year", "logical switch",
      "inbreeding coefficient", "diploid lethal equivalents by stage 1-7",
      "fecundity scaling per lethal equivalent", "ratio", "years", "rate constant"
    ),
    model_location = c(
      "inst/extdata/woodhen/05_future_baseline.yaml",
      "inst/extdata/woodhen/05_future_baseline.yaml",
      "inst/extdata/woodhen/_woodhen_base.yaml",
      "inst/extdata/woodhen/05_future_baseline.yaml -> run_pva_core()",
      "inst/extdata/woodhen/_woodhen_base.yaml -> run_pva_core()",
      "inst/extdata/woodhen/05_future_baseline.yaml -> run_pva_core()",
      "inst/extdata/woodhen/_woodhen_base.yaml -> run_pva_core()",
      "inst/extdata/woodhen/_woodhen_base.yaml -> recruit_phase()",
      "inst/extdata/woodhen/05_future_baseline.yaml -> run_pva_core()",
      "inst/extdata/woodhen/_woodhen_base.yaml -> run_pva_core()",
      "inst/extdata/woodhen/_woodhen_base.yaml -> draw_vital_rates()",
      "inst/extdata/woodhen/05_future_baseline.yaml -> apply_ceiling_K()",
      "inst/extdata/woodhen/05_future_baseline.yaml -> resolve_carrying_capacity()",
      rep("inst/extdata/woodhen/_woodhen_base.yaml -> maybe_apply_catastrophe()", 3L),
      "inst/extdata/woodhen/_woodhen_base.yaml -> genetic_update()",
      rep("inst/extdata/woodhen/05_future_baseline.yaml -> genetic_update()", 2L),
      rep("inst/extdata/woodhen/_woodhen_base.yaml -> genetic_update()", 3L),
      "inst/extdata/woodhen/05_future_baseline.yaml -> genetic_update()"
    ),
    provenance_class = c(
      "inherited from existing practical", # name
      "inherited from existing practical", # years
      "inherited from existing practical", # reps
      "tuned for historical illustration", # surv
      "inherited from existing practical", # stasis
      "tuned for historical illustration", # fecund
      "inherited from existing practical", # sex_ratio_init
      "inherited from existing practical", # monogamy
      "tuned for historical illustration", # n0
      "inherited from existing practical", # demographic_stochasticity
      "inherited from existing practical", # env_sd
      "tuned for historical illustration", # K
      "tuned for historical illustration", # K_sd
      "inherited from existing practical", # cat_freq
      "inherited from existing practical", # cat_surv
      "inherited from existing practical", # cat_repro
      "inherited from existing practical", # genetics
      "tuned for historical illustration", # F_init
      "tuned for historical illustration", # lethal_equiv
      "inherited from existing practical", # B_on_fec
      "inherited from existing practical", # Ne_N_ratio
      "inherited from existing practical", # Ne_window
      "tuned for historical illustration" # purge_kappa
    ),
    source_or_rationale = c(
      "Stable internal identity for the unchanged 2025-2100 comparison.",
      "The teaching horizon spans 2025-2100.",
      "One thousand futures is the established Practical 2 comparison standard.",
      "Raised early-life survival was chosen to reproduce the post-eradication recovery pattern; it was not estimated from the survey series.",
      "The inherited age-structured survival convention retains adults in the final stage.",
      "Raised breeding output was chosen to reproduce the post-eradication recovery pattern; it was not estimated from the survey series.",
      "The existing practical starts from an even sex ratio.",
      "Woodhens are treated as monogamous; the engine applies a coarse sex-ratio constraint to recruitment.",
      "The vector sums to 827 female-equivalent units, displayed as 1,654 birds under the legacy 1:1 conversion. The total and stage allocation were chosen for the historical teaching reconstruction.",
      "The existing practical includes individual birth and survival chance.",
      "Inherited annual variation setting; it is not a Woodhen field estimate.",
      "Chosen as a post-eradication breeding-territory ceiling for the teaching reconstruction; not a measured island carrying capacity.",
      "Chosen as 10% variation around K for the teaching reconstruction.",
      "Inherited cyclone-frequency assumption from the existing practical; not a current forecast.",
      "Inherited catastrophe-severity assumption from the existing practical.",
      "Inherited catastrophe effect on reproduction from the existing practical.",
      "The existing practical includes inbreeding depression and a simplified purging model.",
      "Chosen to represent legacy inbreeding after the earlier bottleneck; not estimated from the 2019 population.",
      "Reduced from the historical setting to represent prior purging; not newly estimated.",
      "Inherited link between lethal equivalents and breeding output.",
      "Inherited effective-to-census ratio; no Woodhen-specific re-estimation was identified.",
      "Inherited harmonic-memory window for effective population size.",
      "Set to zero in the recovered-population reconstruction so no further purging occurs."
    ),
    temporal_assumption = c(
      "fixed identity", "fixed horizon", "fixed simulation design",
      "constant from 2025 through 2100", "constant from 2025 through 2100",
      "constant from 2025 through 2100", "initial state, then updated by the model",
      "constant", "initial state", "active every year", "active every year",
      "constant mean", "redrawn annually", "constant annual event probability",
      "applied only in catastrophe years", "applied only in catastrophe years",
      "active every year", "initial state", "updated by the genetics model",
      "active every year", "active every year", "rolling window", "active every year"
    ),
    inference_limit = c(
      "No biological inference.", "Does not imply conditions remain constant in reality.",
      "Monte Carlo precision does not remove structural or parameter uncertainty.",
      "Common stage changes cannot identify the true mechanism of recovery.",
      "The final stage is an age-class abstraction, not a measured adult transition matrix.",
      "Common breeding-output changes cannot identify food, rodent, density, or behavioural mechanisms.",
      "Sex structure is simplified and male stages are not tracked explicitly.",
      "Pair formation and territory occupancy are not modelled explicitly.",
      "Observed total abundance does not identify the seven-stage allocation.",
      "Does not represent individual heterogeneity beyond the supplied stochastic processes.",
      "One value drives both beta-distributed survival and lognormal fecundity variation.",
      "K is breeding-territory capacity, not total bird abundance or mapped habitat area.",
      "Normal capacity draws are an abstraction and must remain biologically feasible.",
      "Frequency, survival severity, and reproductive severity are separate assumptions.",
      "A common multiplier does not describe cyclone-specific stage effects.",
      "A common multiplier does not describe cyclone timing within a breeding season.",
      "The genetics module is illustrative rather than a pedigree or genomic model.",
      "The starting coefficient is assumed rather than independently estimated here.",
      "Stage-specific genetic load is simplified.", "The fecundity effect is simplified.",
      "Effective size is not independently estimated for the recovered population.",
      "The chosen memory window is a modelling convention.",
      "No continuing purging is represented."
    ),
    stringsAsFactors = FALSE
  )
}

woodhen_audit_baseline_rows <- function() {
  spec <- woodhen_locked_future_spec()
  metadata <- woodhen_audit_baseline_metadata()
  stopifnot(setequal(metadata$parameter, names(spec)))
  metadata$value <- vapply(metadata$parameter, function(parameter) {
    woodhen_audit_value(spec[[parameter]])
  }, character(1))
  metadata[, c(
    "parameter", "value", "unit", "model_location", "provenance_class",
    "source_or_rationale", "temporal_assumption", "inference_limit"
  )]
}

woodhen_audit_catalogue_frame <- function(catalogue,
                                          catalogue_name,
                                          baseline_values,
                                          units,
                                          directions,
                                          timings,
                                          parent_relationships,
                                          provenance_classes,
                                          omitted_processes) {
  stopifnot(
    nrow(catalogue) == length(baseline_values),
    nrow(catalogue) == length(units),
    nrow(catalogue) == length(directions),
    nrow(catalogue) == length(timings),
    nrow(catalogue) == length(parent_relationships),
    nrow(catalogue) == length(provenance_classes),
    nrow(catalogue) == length(omitted_processes)
  )
  anchor_value <- function(index, name) {
    anchors <- catalogue$anchors[[index]]
    if (!name %in% names(anchors) || is.na(anchors[[name]])) "" else woodhen_audit_value(anchors[[name]])
  }
  data.frame(
    catalogue = catalogue_name,
    id = catalogue$id,
    label = catalogue$label,
    ecological_process = catalogue$biological_meaning,
    baseline_value = baseline_values,
    setting_1 = vapply(seq_len(nrow(catalogue)), anchor_value, character(1), "low"),
    setting_2 = vapply(seq_len(nrow(catalogue)), anchor_value, character(1), "moderate"),
    setting_3 = vapply(seq_len(nrow(catalogue)), anchor_value, character(1), "high"),
    unit = units,
    permitted_range = vapply(catalogue$custom_range, woodhen_audit_range, character(1)),
    model_quantity = vapply(catalogue$mapping, woodhen_audit_mapping, character(1)),
    direction = directions,
    timing = timings,
    parent_relationship = parent_relationships,
    provenance_class = provenance_classes,
    source_or_rationale = catalogue$source_or_rationale,
    omitted_processes = omitted_processes,
    inference_limit = catalogue$limitation,
    stringsAsFactors = FALSE
  )
}

woodhen_audit_catalogue_rows <- function() {
  reference <- woodhen_reference_catalog()
  reference_rows <- woodhen_audit_catalogue_frame(
    reference, "reference", rep("locked scenario specification", nrow(reference)),
    rep("complete scenario", nrow(reference)),
    rep("Chronological historical comparison; see the baseline table for the common future.", nrow(reference)),
    c(
      "1980 start, then 40 years", "1980 start, then 40 years",
      "1980 start with removals and releases in years 1-4, then 40 years",
      "2019 start, then 5 years", "2025 start, then 75 years"
    ),
    rep("Each reference stands alone; later scenarios change management or the historical starting state.", nrow(reference)),
    c(rep("inherited from existing practical", 3L), rep("tuned for historical illustration", 2L)),
    c(
      "Explicit spatial habitat, pig dynamics, observation error, and uncertainty in the historical vital rates.",
      "Pig abundance, eradication effort, habitat maps, and lagged vegetation recovery.",
      "Captive breeding demography, release survival, pedigree, and the actual release schedule.",
      "Rodent abundance, food-web pathways, density feedback, road mortality, and survey observation error.",
      "Climate trends, spatial habitat change, future management adaptation, and parameter uncertainty."
    )
  )
  reference_rows$setting_1 <- reference$source_yaml
  reference_rows$setting_2 <- ""
  reference_rows$setting_3 <- ""
  reference_rows$permitted_range <- "locked"

  sensitivity <- woodhen_sensitivity_catalog()
  sensitivity_rows <- woodhen_audit_catalogue_frame(
    sensitivity, "sensitivity",
    vapply(sensitivity$anchors, function(x) woodhen_audit_value(x[["low"]]), character(1)),
    c(
      "breeding pairs", "multiplier on every stage survival", "multiplier on stages 1-2 survival",
      "multiplier on every fecundity value", "annual probability", "catastrophe-year multiplier",
      "standard deviation", "breeding-pair standard deviation"
    ),
    c(
      "Lower K increases habitat limitation.", "Lower multipliers reduce survival.",
      "Lower multipliers reduce early-life survival.", "Lower multipliers reduce breeding output.",
      "Higher probability increases catastrophe exposure.", "Lower multipliers increase catastrophe mortality.",
      "Higher values widen annual vital-rate variation.", "Higher values widen annual capacity variation."
    ),
    rep("Immediate fixed setting from 2025 through the 75-year projection.", nrow(sensitivity)),
    rep("Compared with the locked future baseline while all other settings are held constant.", nrow(sensitivity)),
    rep("bounded exploratory setting", nrow(sensitivity)),
    c(
      "Spatial habitat quality and density effects below the ceiling.",
      "Cause-specific mortality and different responses among stages.",
      "Nest, chick, juvenile, and subadult processes are compressed into two stages.",
      "Breeding probability, clutch size, nest success, and chick survival are not separated.",
      "Event severity and duration remain fixed.", "Event frequency and reproductive effects remain fixed.",
      "No shared annual environmental driver or long-term trend is represented.",
      "No spatial covariance or directional habitat trend is represented."
    )
  )
  sensitivity_rows$setting_1 <- sensitivity_rows$setting_2
  sensitivity_rows$setting_2 <- sensitivity_rows$setting_3
  sensitivity_rows$setting_3 <- ""

  threat <- woodhen_threat_catalog()
  threat_rows <- woodhen_audit_catalogue_frame(
    threat, "threat", c("1.00", "500", "500", "0.04", "1.00", "0.20"),
    c(
      "survival multiplier", "breeding pairs", "breeding pairs at horizon",
      "annual probability", "stages 1-2 survival multiplier", "standard deviation"
    ),
    c(
      "Reduces survival across all seven stages.", "Reduces breeding-territory capacity.",
      "Gradually reduces breeding-territory capacity.", "Increases cyclone frequency without changing severity.",
      "Reduces survival in stages 1 and 2.", "Increases annual vital-rate variation."
    ),
    c(
      "Step or linear change; step is the current default.",
      "Step or linear change; step is the current default.",
      "Linear change across the projection only.",
      "Step or linear change; step is the current default.",
      "Step or linear change; step is the current default.",
      "Step or linear change; step is the current default."
    ),
    rep("Applied to the locked 2025 future baseline; threat settings do not redefine the starting population.", nrow(threat)),
    rep("bounded exploratory setting", nrow(threat)),
    c(
      "Disease transmission, prevalence, recovery, reproduction, and stage-specific pathology.",
      "Mapped habitat, quality, occupancy, salinity, and compensatory movement.",
      "Sea level itself, inundation maps, salinity dynamics, and adaptation; only K changes.",
      "Storm intensity, duration, reproductive loss, spatial refugia, and serial correlation.",
      "Predator abundance, reinvasion detection, control response, and later-stage predation.",
      "A mechanistic climate driver, autocorrelation, trends, and covariance among rates."
    )
  )

  intervention <- woodhen_intervention_catalog()
  intervention_rows <- woodhen_audit_catalogue_frame(
    intervention, "intervention", rep("0 (no added intervention)", nrow(intervention)),
    c(
      "fraction of threatened K recovered", "fraction of parent vital-rate loss recovered",
      "fraction of named vital-rate loss recovered", "stage-2 female-equivalent pairs per year",
      "fraction of catastrophe-survival loss recovered"
    ),
    c(
      "Restores threatened K toward 500.", "Restores predator-affected survival or fecundity toward baseline.",
      "Restores one named survival or fecundity component toward baseline.",
      "Adds birds without changing the parent threat.", "Raises catastrophe survival toward 1."
    ),
    c(
      "Step or linear recovery after a chosen onset.", "Step or linear recovery after a chosen onset.",
      "Step or linear recovery after a chosen onset.", "Three annual releases beginning at the chosen onset.",
      "Step or linear response after a chosen onset."
    ),
    c(
      "Requires a habitat-contraction or sea-level-rise parent with a named K change.",
      "Requires a predator-reinvasion parent and offsets only its named survival or fecundity changes.",
      "Requires one named survival or fecundity change in the parent threat.",
      "May be added to a threat parent; it supplements stage 2 rather than reversing the threat.",
      "Requires the increased-cyclone-pressure parent; it changes severity, not the parent's frequency increase."
    ),
    rep("bounded exploratory setting", nrow(intervention)),
    c(
      "Restoration feasibility, cost, land tenure, spatial configuration, and ecological lag.",
      "Detection probability, eradication feasibility, reinvasion risk, and operational delay.",
      "The action that produces the vital-rate improvement, feasibility, cost, and side effects.",
      "Captive productivity, sex ratio, pedigree, release survival, territory availability, and cost.",
      "Forecasting, logistics, action efficacy, duration, and effects on reproduction."
    )
  )

  out <- rbind(reference_rows, sensitivity_rows, threat_rows, intervention_rows)
  rownames(out) <- NULL
  out
}

woodhen_audit_recovery_rows <- function() {
  data.frame(
    event_period = c(
      "December 2018", "late 2019 to January 2020", "November 2020", "March 2021",
      "November-December 2021", "March 2022", "December 2022", "April 2024",
      "November-December 2024"
    ),
    reported_count = c(
      "221", "208 selected; primary paper reports 228", "443", "598",
      "551 adults/juveniles plus 14 chicks", "778",
      "1,147 selected; primary paper reports 1,108", "598 banded",
      "1,535 adults/juveniles plus 26 chicks; official minimum 1,638"
    ),
    comparison_count = c(221L, NA_integer_, 443L, 598L, 551L, 778L, 1147L, NA_integer_, 1638L),
    count_type = c(
      "known minimum annual count", "release count, not a population census",
      "survey count", "survey count", "survey count with chicks reported separately",
      "survey count", "survey count", "banding sample, not a population estimate",
      "derived minimum known population"
    ),
    survey_coverage = c(
      "Annual survey; inaccessible birds may be missed.",
      "Captive-managed birds released; free-living birds are not represented consistently.",
      "Comparable post-eradication survey.", "Comparable post-eradication survey.",
      "About 20% of the Mt Gower summit was not surveyed; Big Slope and other areas were also unsurveyed.",
      "Two-week autumn survey; reported as the second autumn post-eradication survey.",
      "Three-week survey including Mt Gower.",
      "Settlement and parts of the Permanent Park Preserve; designed to band unbanded birds before the full survey.",
      "Accessible areas surveyed directly; Mt Gower was excluded and 77 birds from its 2022 count were carried forward."
    ),
    use_as_abundance_point = c(TRUE, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, TRUE),
    source_label = c(
      "O'Dwyer et al. 2024", "Lord Howe Island Board 2025; O'Dwyer et al. 2024",
      "O'Dwyer et al. 2024", "O'Dwyer et al. 2024", "Lord Howe Island Board March 2022 papers",
      "Mitchell et al. 2023", "Lord Howe Island Board February 2023 papers",
      "Lord Howe Island Board April 2024 update", "Lord Howe Island Board March 2025 update"
    ),
    source_url = c(
      rep("https://doi.org/10.1007/s10530-023-03161-w", 1L),
      "https://www.lhib.nsw.gov.au/news/householder-woodhen-survey-results ; https://doi.org/10.1007/s10530-023-03161-w",
      rep("https://doi.org/10.1007/s10530-023-03161-w", 2L),
      "https://www.lhib.nsw.gov.au/sites/default/files/2023-03/ED23_1446%20-%20Board%20Papers%20-%20Open%20-%20March%202022.pdf",
      "https://pmc.ncbi.nlm.nih.gov/articles/PMC10000061/",
      "https://www.lhib.nsw.gov.au/sites/default/files/2023-02/Agenda%20and%20Business%20Papers%20February%202023.pdf",
      "https://www.lhib.nsw.gov.au/news/householder-woodhen-banding-results-april-2024",
      "https://www.lhib.nsw.gov.au/news/householder-woodhen-survey-results"
    ),
    interpretation_note = c(
      "Pre-eradication benchmark.",
      "The official graph uses 208, while the peer-reviewed account reports 233 captured, five deaths, and 228 released in January 2020. Neither is a census estimate for the same sampling frame as later surveys.",
      "First comparable post-release survey point.", "Rapid increase continued.",
      "The count is lower than March 2021, but season and incomplete coverage differ; the report considered the island population likely above 560.",
      "The increase continued; the survey is supported by a peer-reviewed review of the captive-management programme.",
      "Use the Board's final 1,147 count for the teaching series; the earlier peer-reviewed paper reports 1,108, likely reflecting a different data cut.",
      "Do not plot 598 as total abundance: this was a targeted banding sample ahead of the full November survey.",
      "The 1,638 headline is useful but is not one simultaneous whole-island census: it combines 1,561 accessible-area birds with the 77-bird Mt Gower count from 2022."
    ),
    stringsAsFactors = FALSE
  )
}

woodhen_audit_omissions <- function() {
  data.frame(
    omitted_process = c(
      "Explicit males and pair formation", "Spatial habitat and territory occupancy",
      "Observation error and survey effort", "Density dependence below K",
      "Road mortality and other cause-specific mortality", "Rodent-food-web mechanisms",
      "Climate and sea-level mechanisms", "Management cost and feasibility",
      "Parameter uncertainty and model-form uncertainty"
    ),
    consequence = c(
      "Breeding-pair abundance is a female-holder proxy, not an explicit count of paired males and females.",
      "K scenarios compare abstract territory capacity, not mapped areas, quality, movement, or local refugia.",
      "Historical agreement cannot distinguish ecological dynamics from changing count coverage or detectability.",
      "The model imposes a ceiling but does not represent gradual crowding effects before that ceiling.",
      "A changed survival rate cannot identify which mortality source produced the response.",
      "The recovery reconstruction cannot attribute observed growth separately to predation release, food supply, behaviour, or correlated ecosystem change.",
      "Sea-level rise is only a declining-K pathway and environmental variability is not a climate projection.",
      "An intervention that helps in the simulation is not automatically practical, affordable, permitted, or socially acceptable.",
      "One thousand futures describe process stochasticity under chosen settings; they do not span uncertainty in the settings or model structure."
    ),
    stringsAsFactors = FALSE
  )
}

#' Write the Practical 2 ecological assumptions audit
#'
#' @param output_dir Caller-supplied directory for the audit files.
#' @return Named list containing the four written file paths.
audit_practical2_scientific_catalog <- function(output_dir) {
  if (!is.character(output_dir) || length(output_dir) != 1L || is.na(output_dir) || !nzchar(output_dir)) {
    stop("`output_dir` must be one non-empty directory path.", call. = FALSE)
  }
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  }
  if (!dir.exists(output_dir)) {
    stop("Could not create audit output directory: ", output_dir, call. = FALSE)
  }

  baseline <- woodhen_audit_baseline_rows()
  catalogue <- woodhen_audit_catalogue_rows()
  recovery <- woodhen_audit_recovery_rows()
  omissions <- woodhen_audit_omissions()

  baseline_path <- file.path(output_dir, "practical2_future_baseline_parameters.csv")
  catalogue_path <- file.path(output_dir, "practical2_scientific_catalogue.csv")
  recovery_path <- file.path(output_dir, "practical2_recovery_observations.csv")
  markdown_path <- file.path(output_dir, "practical-2-ecological-assumptions-audit.md")
  utils::write.csv(baseline, baseline_path, row.names = FALSE, na = "")
  utils::write.csv(catalogue, catalogue_path, row.names = FALSE, na = "")
  utils::write.csv(recovery, recovery_path, row.names = FALSE, na = "")

  sensitivity <- catalogue[catalogue$catalogue == "sensitivity", c(
    "label", "baseline_value", "setting_1", "setting_2", "unit", "permitted_range",
    "model_quantity", "timing", "inference_limit"
  )]
  threats <- catalogue[catalogue$catalogue == "threat", c(
    "label", "ecological_process", "baseline_value", "setting_1", "setting_2",
    "setting_3", "unit", "model_quantity", "timing", "inference_limit"
  )]
  interventions <- catalogue[catalogue$catalogue == "intervention", c(
    "label", "setting_1", "setting_2", "setting_3", "unit", "direction", "timing",
    "parent_relationship", "inference_limit"
  )]
  recovery_display <- recovery[, c(
    "event_period", "reported_count", "count_type", "survey_coverage", "interpretation_note"
  )]

  markdown <- c(
    "# Practical 2 Ecological Assumptions Audit",
    "",
    "**Gate A2 accepted on 22 July 2026.** This is a scientific decision record for the teacher and development team, not student-facing copy. The pragmatic 2026 choices below are accepted for delivery; deeper model-semantic repair is deferred to the post-teaching interregnum.",
    "",
    "## Accepted decisions for the 2026 practical",
    "",
    "1. **Female cohorts versus whole birds is a material issue, and the engine conventions are internally inconsistent.** The Woodhen YAML and legacy case-study script define female-cohort trajectories and convert final abundance to whole birds by multiplying by two. However, `recruit_phase()` and its tests update sex ratio as though the same state vector contains total birds. The current Practical 2 compact-evidence layer then sums the raw state while some plots label it as whole birds. Until that deeper semantic mismatch is refactored, replicate-specific sex-ratio conversion would imply more precision than the engine supports. For this teaching release, the least disruptive convention is to preserve the tuned engine, describe its states internally as female-equivalent model units, report whole birds as twice those units, and keep sex ratio locked away from student control. This must be implemented and tested before Gate E is accepted.",
    "2. **Breeding pairs are a model proxy.** Under the model's monogamy and territory assumptions, one territory-holding female represents one breeding pair. Stages 2-7 are therefore summed and stage 1 non-territorial birds are excluded. Males, pair formation, failed pairing, and territory occupancy are not tracked explicitly, so the result is not an observed pair count.",
    "3. **Fewer than 50 pairs is a working warning threshold.** It creates a common management-warning comparison for this practical. It is not a universal minimum viable population, a proven biological tipping point, or an estimate of the number at which intervention would certainly occur. A threshold-sensitivity view is a useful optional extension, not a compulsory task.",
    "4. **The 2019-2024 exercise is a historical reconstruction, not independent validation.** The 2019 starting scale and the post-eradication survival and fecundity changes were used to construct the reconstruction, while the future starting vector was chosen to represent the then-known 2024 scale. Agreement with those endpoints is therefore a plausibility or consistency check, not independent validation.",
    "5. **The monitoring series is informative but not uniform.** Survey season, coverage, chicks, banding-only samples, and carried-forward Mt Gower counts differ. The official values remain a strong teaching record if those differences are taught rather than hidden.",
    "6. **The future baseline starts at 1,654 birds, while the latest official minimum is 1,638.** The 16-bird difference is biologically trivial but epistemically useful: 1,654 is a tuned model state, not an exact census. Retaining it avoids needless recalibration; changing it would align the model with the updated official headline. Either choice should be described honestly.",
    "",
    "## How abundance and breeding pairs are represented",
    "",
    "The intended Woodhen specification is a female-only stage model: `n0` is documented as females, fecundity is defined per female, K is documented as breeding pairs, and the legacy example doubles the final state to show females plus males. At the supplied 0.5 starting sex ratio, 827 female-equivalent units represent 1,654 birds. The executable recruitment code, however, updates sex ratio using total-count mass balance and adds all recruits to the stage vector. The implementation therefore mixes female-only and total-bird conventions.",
    "",
    "For the immediate Practical 2 release, the existing tuned trajectories should be treated as female-equivalent model units and multiplied by two for whole-bird display, matching the established case-study convention. The tracked sex ratio should not be used to produce a seemingly exact varying conversion until the state-accounting semantics are refactored. Recruitment applies a simplified monogamy adjustment, but males are not represented in their own stages. Thus the breeding-pair calculation is best described as a female territory-holder proxy under an assumed available mate, not a direct pair census. Sex ratio remains locked in the compulsory route.",
    "",
    "## Locked 2025-2100 future baseline",
    "",
    "This table includes every executable field in the locked future specification. 'Tuned for historical illustration' means a value was chosen to give a plausible reconstruction at the correct scale; it does not mean it was statistically estimated.",
    "",
    woodhen_audit_markdown_table(baseline[, c(
      "parameter", "value", "unit", "model_location", "provenance_class",
      "source_or_rationale", "temporal_assumption", "inference_limit"
    )]),
    "",
    "## Compulsory one-factor sensitivity settings",
    "",
    "Each row changes one quantity while retaining the common 2025 starting population, 75-year horizon, and other future settings. The two altered settings are bounded teaching choices, not empirical forecasts.",
    "",
    woodhen_audit_markdown_table(sensitivity),
    "",
    "## Prospective threat catalogue",
    "",
    "The three settings provide increasing exploratory pressure. They are scenario assumptions that students must interpret, not claims about the most likely future.",
    "",
    woodhen_audit_markdown_table(threats),
    "",
    "## Prospective intervention catalogue",
    "",
    "Interventions modify a named threatened parent. A better simulated outcome means the action offsets part of that assumed threat under the model; it does not establish field effectiveness or feasibility.",
    "",
    woodhen_audit_markdown_table(interventions),
    "",
    "## Observed post-eradication recovery evidence",
    "",
    "The recommended teaching series uses exact published counts rather than interpolating the graph. It deliberately records incompatible sampling frames and source differences. The 2019 release figure and April 2024 banding sample should not be treated as directly comparable abundance surveys.",
    "",
    woodhen_audit_markdown_table(recovery_display),
    "",
    "For the 2026 teaching series, use 208 as the release marker because it matches the existing reconstruction and Board graph, and use the Board's final 1,147 count for December 2022. Keep the alternative published values as brief notes only: the peer-reviewed account reports 228 birds released after five of 233 captive birds died, and its earlier December 2022 data cut reports 1,108. No further reconciliation of 208 and 228, or 1,108 and 1,147, is required for this delivery.",
    "",
    "For the 2024 endpoint, 1,535 adults and juveniles plus 26 chicks were recorded in accessible areas. The official minimum of 1,638 adds 77 Mt Gower birds carried forward from 2022 because Mt Gower was not surveyed in 2024. That is a useful minimum-known-population headline, but not one simultaneous whole-island count.",
    "",
    "## Omitted processes and inference limits",
    "",
    woodhen_audit_markdown_table(omissions),
    "",
    "## Deferred 2027 professionalisation",
    "",
    "After the 2026 delivery, define one consistent state unit across recruitment, sex ratio, density regulation, abundance summaries, and breeding-pair risk; then recalibrate the Woodhen scenarios and regression-test both practicals. Revisit primary parameter provenance and the survey-series discrepancies only if they materially affect that refactor. None of this deferred work blocks the accepted 2026 teaching release.",
    "",
    "## Sources",
    "",
    "- O'Dwyer et al. (2024), *Protection and mortality of non-target terrestrial bird species during the eradication of rodents on Lord Howe Island*: https://doi.org/10.1007/s10530-023-03161-w",
    "- Lord Howe Island Board, November-December 2021 survey report, March 2022 Board papers: https://www.lhib.nsw.gov.au/sites/default/files/2023-03/ED23_1446%20-%20Board%20Papers%20-%20Open%20-%20March%202022.pdf",
    "- Mitchell et al. (2023), *Lessons Learned for Pre-Emptive Capture Management*: https://pmc.ncbi.nlm.nih.gov/articles/PMC10000061/",
    "- Lord Howe Island Board, December 2022 survey, February 2023 Board papers: https://www.lhib.nsw.gov.au/sites/default/files/2023-02/Agenda%20and%20Business%20Papers%20February%202023.pdf",
    "- Lord Howe Island Board, April 2024 banding update: https://www.lhib.nsw.gov.au/news/householder-woodhen-banding-results-april-2024",
    "- Lord Howe Island Board, November-December 2024 survey update: https://www.lhib.nsw.gov.au/news/householder-woodhen-survey-results",
    "- Brook and Lim (1997), *How secure is the Lord Howe Island Woodhen?*: https://doi.org/10.1071/PC970125",
    "",
    "## Gate A2 accepted decisions",
    "",
    "1. Accept the provenance classes and baseline rationales as sufficient for the time-constrained 2026 delivery.",
    "2. Accept the two sensitivity settings and three threat/intervention settings as biologically useful bounded teaching choices.",
    "3. Accept the documented default timing assumptions, including linear sea-level-driven habitat contraction and step defaults elsewhere.",
    "4. Preserve the tuned engine, treat state values as female-equivalent model units, report whole birds as twice those values, keep sex ratio locked, and record the mixed state semantics as technical debt for 2026-2027 repair.",
    "5. Accept the female territory-holder proxy for the shared fewer-than-50-pair working warning threshold with its stated limitations.",
    "6. Use the official 1,638 minimum as the recovery pop-out headline while explaining that it includes the 77-bird Mt Gower count carried forward from 2022.",
    "7. Retain the tuned 1,654-bird future starting state and describe it as a model state rather than an exact census."
  )
  writeLines(markdown, markdown_path, useBytes = TRUE)

  list(
    baseline_csv = baseline_path,
    catalogue_csv = catalogue_path,
    recovery_csv = recovery_path,
    markdown = markdown_path
  )
}
