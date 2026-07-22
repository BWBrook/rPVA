woodhen_investigation_catalog_version <- function() {
  "woodhen-investigation-v1"
}

woodhen_reference_library_version <- function() {
  "woodhen-reference-v1"
}

woodhen_catalog_component <- function(affected_fields,
                                      affected_stages,
                                      operator,
                                      anchors,
                                      custom_range) {
  list(
    affected_fields = affected_fields,
    affected_stages = affected_stages,
    operator = operator,
    anchors = anchors,
    custom_range = custom_range
  )
}

woodhen_catalog_range <- function(minimum, maximum) {
  c(min = minimum, max = maximum)
}

woodhen_catalog_table <- function(id,
                                  label,
                                  biological_meaning,
                                  mapping,
                                  anchors,
                                  custom_range,
                                  allowed_temporal_shapes,
                                  default_temporal_shape,
                                  source_or_rationale,
                                  interpretation_help,
                                  limitation,
                                  ...) {
  stopifnot(
    length(id) == length(label),
    length(id) == length(biological_meaning),
    length(id) == length(mapping),
    length(id) == length(anchors),
    length(id) == length(custom_range),
    length(id) == length(allowed_temporal_shapes)
  )

  affected_fields <- lapply(mapping, function(entry) {
    unique(unlist(lapply(entry, `[[`, "affected_fields"), use.names = FALSE))
  })
  affected_stages <- lapply(mapping, function(entry) {
    unique(unlist(lapply(entry, `[[`, "affected_stages"), use.names = FALSE))
  })

  data.frame(
    id = id,
    label = label,
    biological_meaning = biological_meaning,
    affected_fields = I(affected_fields),
    affected_stages = I(affected_stages),
    anchors = I(anchors),
    custom_range = I(custom_range),
    allowed_temporal_shapes = I(allowed_temporal_shapes),
    default_temporal_shape = default_temporal_shape,
    mapping = I(mapping),
    source_or_rationale = source_or_rationale,
    interpretation_help = interpretation_help,
    limitation = limitation,
    catalog_version = rep(woodhen_investigation_catalog_version(), length(id)),
    ...,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}

#' Immutable Woodhen reference scenario catalogue
#'
#' @return A data frame describing the five chronological reference scenarios.
#' @export
woodhen_reference_catalog <- function() {
  id <- c(
    "01_no_mgmt", "02_pig_control", "03_captive_pig",
    "04_rodent_eradication", "05_future_baseline"
  )
  mapping <- lapply(id, function(reference_id) {
    list(locked_spec = woodhen_catalog_component(
      affected_fields = "all_executable_fields",
      affected_stages = "all",
      operator = "locked_yaml_specification",
      anchors = c(low = NA_real_, moderate = NA_real_, high = NA_real_),
      custom_range = woodhen_catalog_range(NA_real_, NA_real_)
    ))
  })

  woodhen_catalog_table(
    id = id,
    label = c(
      "No intervention", "Pig control", "Captive breeding plus pig control",
      "Rodent eradication", "Future baseline"
    ),
    biological_meaning = c(
      "The restricted 1980 population without a new management action.",
      "Pig control releases lowland breeding territories.",
      "Captive releases supplement pig-control habitat recovery.",
      "A short historical check after rodent eradication improved recruitment.",
      "The recovered 2024 population projected to 2100 with no further change."
    ),
    mapping = mapping,
    anchors = lapply(id, function(x) c(low = NA_real_, moderate = NA_real_, high = NA_real_)),
    custom_range = lapply(id, function(x) woodhen_catalog_range(NA_real_, NA_real_)),
    allowed_temporal_shapes = lapply(id, function(x) "locked"),
    default_temporal_shape = rep("locked", length(id)),
    source_or_rationale = paste0("Locked repository reference: inst/extdata/woodhen/", id, ".yaml."),
    interpretation_help = c(
      "Use as the historical no-action comparison.",
      "Compare with the common 40-year no-action case.",
      "Compare with the two other common 40-year cases.",
      "Interpret as a five-year recovery check, not a long-run rank.",
      "Use as the unchanged comparison for all Phase 2 investigations."
    ),
    limitation = c(
      rep("A reference scenario is a modelled historical comparison, not a causal estimate.", 4L),
      "The future baseline holds modelled ecological conditions constant for 75 years."
    ),
    source_yaml = paste0(id, ".yaml"),
    horizon_years = c(40L, 40L, 40L, 5L, 75L),
    chronological_order = seq_along(id)
  )
}

#' Woodhen one-factor sensitivity catalogue
#'
#' @return A data frame of bounded sensitivity factors and review metadata.
#' @export
woodhen_sensitivity_catalog <- function() {
  ids <- c("K", "surv", "juvenile_surv", "fecund", "cat_freq", "cat_surv", "env_sd", "K_sd")
  anchors <- list(
    c(low = 500, moderate = 350, high = 250),
    c(low = 1.00, moderate = 0.95, high = 0.90),
    c(low = 1.00, moderate = 0.85, high = 0.70),
    c(low = 1.00, moderate = 0.80, high = 0.60),
    c(low = 0.04, moderate = 0.07, high = 0.10),
    c(low = 0.50, moderate = 0.40, high = 0.30),
    c(low = 0.20, moderate = 0.25, high = 0.30),
    c(low = 50, moderate = 75, high = 100)
  )
  ranges <- list(
    woodhen_catalog_range(150, 750),
    woodhen_catalog_range(0.70, 1.10),
    woodhen_catalog_range(0.50, 1.10),
    woodhen_catalog_range(0.40, 1.20),
    woodhen_catalog_range(0.00, 0.20),
    woodhen_catalog_range(0.20, 1.00),
    woodhen_catalog_range(0.00, 0.30),
    woodhen_catalog_range(0, 150)
  )
  fields <- c("K", "surv", "surv", "fecund", "cat_freq", "cat_surv", "env_sd", "K_sd")
  stages <- list("not_applicable", 1:7, 1:2, 1:7, "not_applicable", "not_applicable", "not_applicable", "not_applicable")
  operators <- c("absolute", "multiply", "multiply", "multiply", "absolute", "absolute", "absolute", "absolute")
  mapping <- lapply(seq_along(ids), function(i) {
    component_id <- paste0(ids[[i]], "_sensitivity")
    stats::setNames(list(woodhen_catalog_component(
      affected_fields = fields[[i]],
      affected_stages = stages[[i]],
      operator = operators[[i]],
      anchors = anchors[[i]],
      custom_range = ranges[[i]]
    )), component_id)
  })

  woodhen_catalog_table(
    id = ids,
    label = c(
      "Breeding-territory capacity", "All-stage survival", "Juvenile survival",
      "Fecundity", "Annual catastrophe probability", "Catastrophe survival",
      "Environmental variability", "Habitat-capacity variability"
    ),
    biological_meaning = c(
      "The ceiling on breeding territories available to territory holders.",
      "A common proportional change in survival at every life stage.",
      "A proportional change in survival for stages 1 and 2 only.",
      "A common proportional change in age-specific breeding output.",
      "The annual chance that a modelled catastrophe occurs.",
      "The survival multiplier applied in a catastrophe year.",
      "The annual variation applied to survival and fecundity draws.",
      "Annual variation around breeding-territory capacity."
    ),
    mapping = mapping,
    anchors = anchors,
    custom_range = ranges,
    allowed_temporal_shapes = lapply(ids, function(x) "fixed_setting"),
    default_temporal_shape = rep("fixed_setting", length(ids)),
    source_or_rationale = c(
      rep("Locked future specification plus reviewed pedagogical design bounds; not an empirical prescription.", 4L),
      "Existing Woodhen catastrophe settings plus reviewed pedagogical design bounds; not empirical estimates.",
      "Existing Woodhen catastrophe settings plus reviewed pedagogical design bounds; not empirical estimates.",
      "Mathematically bounded design settings; beta feasibility is checked after composition.",
      "Locked future specification plus reviewed pedagogical design bounds; not an empirical prescription."
    ),
    interpretation_help = c(
      "Compare how abundance responds as habitat becomes limiting.",
      "Check whether conclusions are robust to broad survival uncertainty.",
      "Focus interpretation on early-life recruitment into holder stages.",
      "Check whether breeding output changes long-run recovery confidence.",
      "Compare long-run risk under more or fewer catastrophe years.",
      "Compare risk when losses within catastrophe years are more or less severe.",
      "Interpret both central outcomes and widening stochastic uncertainty.",
      "Interpret wider habitat variation separately from its mean capacity."
    ),
    limitation = c(
      "Capacity represents territory holders and does not model spatial habitat quality.",
      "A common multiplier does not identify a particular disease or stress mechanism.",
      "Only stages 1 and 2 change; later survival is deliberately held fixed.",
      "The same multiplier is applied to all fecund stages.",
      "The setting changes event frequency, not event severity.",
      "The setting changes catastrophe survival, not frequency or reproduction.",
      "The model does not impose a shared good-year or bad-year effect across all rates.",
      "Capacity draws are Normal; every practical setting must satisfy K >= 3*K_sd."
    ),
    locked_baseline = vapply(anchors, `[[`, numeric(1), "low"),
    horizon_years = rep(75L, length(ids))
  )
}

#' Woodhen prospective threat catalogue
#'
#' @return A data frame of six bounded threat families and model mappings.
#' @export
woodhen_threat_catalog <- function() {
  ids <- c(
    "novel_disease", "habitat_contraction", "sea_level_rise_pathway",
    "increased_cyclone_pressure", "predator_reinvasion",
    "chronic_environmental_variability"
  )
  anchors <- list(
    c(low = 0.95, moderate = 0.90, high = 0.85),
    c(low = 425, moderate = 350, high = 250),
    c(low = 425, moderate = 350, high = 250),
    c(low = 0.07, moderate = 0.10, high = 0.15),
    c(low = 0.85, moderate = 0.70, high = 0.50),
    c(low = 0.225, moderate = 0.25, high = 0.30)
  )
  ranges <- list(
    woodhen_catalog_range(0.70, 1.00),
    woodhen_catalog_range(150, 500),
    woodhen_catalog_range(150, 500),
    woodhen_catalog_range(0.04, 0.20),
    woodhen_catalog_range(0.50, 1.00),
    woodhen_catalog_range(0.20, 0.30)
  )
  fields <- c("surv", "K", "K", "cat_freq", "surv", "env_sd")
  stages <- list(1:7, "not_applicable", "not_applicable", "not_applicable", 1:2, "not_applicable")
  operators <- c("multiply", "absolute", "absolute", "absolute", "multiply", "absolute")
  component_names <- c(
    "disease_survival", "habitat_capacity", "linear_habitat_pathway",
    "cyclone_frequency", "juvenile_survival", "demographic_variability"
  )
  mapping <- lapply(seq_along(ids), function(i) {
    stats::setNames(list(woodhen_catalog_component(
      affected_fields = fields[[i]],
      affected_stages = stages[[i]],
      operator = operators[[i]],
      anchors = anchors[[i]],
      custom_range = ranges[[i]]
    )), component_names[[i]])
  })

  woodhen_catalog_table(
    id = ids,
    label = c(
      "Novel disease", "Habitat contraction or degradation", "Sea-level rise pathway",
      "Increased cyclone pressure", "Invasive-predator reinvasion",
      "Chronic environmental variability"
    ),
    biological_meaning = c(
      "A new disease reduces survival across affected life stages.",
      "Loss or degradation reduces available breeding territories.",
      "Inundation and saline intrusion progressively reduce lowland habitat.",
      "Cyclones occur more often across the projection horizon.",
      "Predator return reduces juvenile and subadult survival.",
      "Demographic conditions vary more strongly among years."
    ),
    mapping = mapping,
    anchors = anchors,
    custom_range = ranges,
    allowed_temporal_shapes = list(c("step", "linear"), c("step", "linear"), "linear", c("step", "linear"), c("step", "linear"), c("step", "linear")),
    default_temporal_shape = c("step", "step", "linear", "step", "step", "step"),
    source_or_rationale = rep(
      "Prospective pedagogical design bounds derived from the locked model scale; not an empirical prescription.",
      length(ids)
    ),
    interpretation_help = c(
      "State which stages or processes the disease assumption represents.",
      "Interpret the response as a habitat-capacity pathway.",
      "Interpret the generated K profile as a habitat-loss abstraction, not an inundation forecast.",
      "Separate cyclone frequency from severity and reproductive effects.",
      "Relate the targeted early-life stages to recruitment into the breeding population.",
      "Discuss how increased variability changes uncertainty as well as median outcomes."
    ),
    limitation = c(
      "Disease effects are not estimated; reproduction may change only as a separately named advanced component.",
      "Habitat quality has no independent model field and K_sd remains locked in the compulsory route.",
      "Sea-level rise is represented only by a linear K habitat pathway, not a sea-level parameter.",
      "Low, moderate, and high change cat_freq only to .07/.10/.15; cat_repro is never silently included.",
      "The mapping is a design analogue and not an estimated causal reversal of eradication benefits.",
      "env_sd affects both survival beta draws and fecundity lognormal draws."
    ),
    horizon_years = rep(75L, length(ids))
  )
}

#' Woodhen prospective intervention catalogue
#'
#' @return A data frame of five bounded intervention families and model mappings.
#' @export
woodhen_intervention_catalog <- function() {
  ids <- c(
    "habitat_protection_restoration", "biosecurity_eradication",
    "targeted_vital_rate_improvement", "captive_breeding_supplementation",
    "emergency_response"
  )
  anchors <- list(
    c(low = 0.25, moderate = 0.50, high = 1.00),
    c(low = 0.25, moderate = 0.50, high = 1.00),
    c(low = 0.25, moderate = 0.50, high = 1.00),
    c(low = 5, moderate = 10, high = 15),
    c(low = 0.25, moderate = 0.50, high = 0.75)
  )
  ranges <- list(
    woodhen_catalog_range(0, 1),
    woodhen_catalog_range(0, 1),
    woodhen_catalog_range(0, 1),
    woodhen_catalog_range(1, 20),
    woodhen_catalog_range(0, 1)
  )
  fields <- list("K", c("surv", "fecund"), c("surv", "fecund"), c("release_years", "release_vec"), "cat_surv")
  stages <- list("not_applicable", "named_parent_stages", "named_parent_stages", 2L, "not_applicable")
  operators <- c(
    "recover_toward_locked_baseline", "recover_toward_locked_baseline",
    "recover_named_vital_rate", "annual_release_schedule", "recover_toward_one"
  )
  component_names <- c(
    "habitat_recovery", "biosecurity_recovery", "targeted_recovery",
    "three_year_stage_2_release", "catastrophe_survival_recovery"
  )
  mapping <- lapply(seq_along(ids), function(i) {
    stats::setNames(list(woodhen_catalog_component(
      affected_fields = fields[[i]],
      affected_stages = stages[[i]],
      operator = operators[[i]],
      anchors = anchors[[i]],
      custom_range = ranges[[i]]
    )), component_names[[i]])
  })

  woodhen_catalog_table(
    id = ids,
    label = c(
      "Habitat protection or restoration", "Strengthened biosecurity or renewed eradication",
      "Targeted survival or breeding improvement", "Captive breeding and supplementation",
      "Emergency response"
    ),
    biological_meaning = c(
      "Management recovers threatened breeding-territory capacity toward the locked baseline.",
      "Management reverses named predator-reinvasion effects.",
      "Management recovers an explicitly named affected survival or fecundity component.",
      "Captive-reared stage-2 female-equivalent breeding pairs are released annually for three years.",
      "Emergency action buffers survival losses in catastrophe years."
    ),
    mapping = mapping,
    anchors = anchors,
    custom_range = ranges,
    allowed_temporal_shapes = list(c("step", "linear"), c("step", "linear"), c("step", "linear"), "scheduled_pulses", c("step", "linear")),
    default_temporal_shape = c("step", "step", "step", "scheduled_pulses", "step"),
    source_or_rationale = c(
      rep("Prospective pedagogical design bounds; not an empirical prescription.", 3L),
      "Release 5/10/15 stage-2 female-equivalent breeding pairs annually for three years; pedagogical design anchors, not empirical prescriptions.",
      "Recover cat_surv from the threatened value toward 1 by .25/.50/.75; pedagogical design anchors, not an empirical prescription."
    ),
    interpretation_help = c(
      "Report the fraction of threatened habitat capacity recovered.",
      "Identify the reinvasion effect being reversed.",
      "Name the targeted vital rate and affected stages.",
      "Report the stage, annual number, first release year, and three-year duration.",
      "Interpret the setting as buffering catastrophe-year survival, not preventing cyclones."
    ),
    limitation = c(
      "Recovery cannot exceed the locked baseline in the compulsory route.",
      "Full recovery means the model baseline, not proof of eradication success.",
      "Above-baseline uplift requires a separately named advanced component.",
      "The engine repeats one release vector; it does not support event-triggered or year-varying amounts.",
      "cat_repro may be an advanced explicit component but is not silently included in cyclone presets."
    ),
    horizon_years = rep(75L, length(ids))
  )
}
