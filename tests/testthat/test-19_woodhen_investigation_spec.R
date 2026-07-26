catalog_required_columns <- c(
  "id", "label", "biological_meaning", "mapping", "affected_fields",
  "affected_stages", "anchors", "custom_range", "allowed_temporal_shapes",
  "source_or_rationale", "interpretation_help", "limitation", "catalog_version"
)

scenario_specs_equal_except <- function(left, right, except) {
  fields <- setdiff(union(names(left), names(right)), except)
  expect_equal(left[fields], right[fields])
}

test_that("reference catalogue is chronological and the future specification is exact", {
  catalog <- woodhen_reference_catalog()

  expect_equal(
    catalog$id,
    c(
      "01_no_mgmt", "02_pig_control", "03_captive_pig",
      "04_rodent_eradication", "05_future_baseline"
    )
  )
  expect_true(all(catalog_required_columns %in% names(catalog)))
  expect_equal(catalog$horizon_years, c(40L, 40L, 40L, 5L, 75L))

  expected <- set_scenario("05_future_baseline", "woodhen")
  future <- woodhen_locked_future_spec()
  expect_equal(future, expected)
  expect_s3_class(future, "pva_spec")
  expect_equal(future$reps, 1000L)
  expect_equal(future$years, 75L)
  expect_equal(future$n0, c(497, 167, 82, 43, 24, 11, 3))

  future$K <- 250
  expect_equal(woodhen_locked_future_spec()$K, 325)
})

test_that("scientific catalogues expose complete structured review metadata", {
  sensitivity <- woodhen_sensitivity_catalog()
  threats <- woodhen_threat_catalog()
  interventions <- woodhen_intervention_catalog()

  expect_true(all(catalog_required_columns %in% names(sensitivity)))
  expect_true(all(catalog_required_columns %in% names(threats)))
  expect_true(all(catalog_required_columns %in% names(interventions)))
  expect_equal(nrow(sensitivity), 8L)
  expect_equal(
    threats$id,
    c(
      "novel_disease", "habitat_contraction", "sea_level_rise_pathway",
      "increased_cyclone_pressure", "predator_reinvasion",
      "chronic_environmental_variability"
    )
  )
  expect_equal(
    interventions$id,
    c(
      "habitat_protection_restoration", "biosecurity_eradication",
      "targeted_vital_rate_improvement", "captive_breeding_supplementation",
      "emergency_response"
    )
  )
  expect_true(all(vapply(sensitivity$anchors, function(x) {
    identical(names(x), c("baseline", "higher", "lower"))
  }, logical(1))))
  expect_true(all(vapply(threats$mapping, function(x) {
    is.list(x) && length(x) >= 1L && !is.null(names(x)) && all(nzchar(names(x)))
  }, logical(1))))

  sea_level <- threats[threats$id == "sea_level_rise_pathway", ]
  expect_equal(sea_level$affected_fields[[1]], "K")
  expect_equal(sea_level$allowed_temporal_shapes[[1]], "linear")
  expect_false(any(grepl("sea_level", sea_level$affected_fields[[1]], fixed = TRUE)))

  cyclone <- threats[threats$id == "increased_cyclone_pressure", ]
  expect_equal(cyclone$affected_fields[[1]], "cat_freq")
  expect_equal(cyclone$anchors[[1]], c(low = 0.07, moderate = 0.10, high = 0.15))
  expect_false("cat_repro" %in% cyclone$affected_fields[[1]])

  supplement <- interventions[interventions$id == "captive_breeding_supplementation", ]
  expect_equal(supplement$anchors[[1]], c(low = 5, moderate = 10, high = 15))
  expect_match(supplement$source_or_rationale, "pedagogical design anchors")
})

test_that("sensitivity defaults bracket the locked future with reviewed settings", {
  catalog <- woodhen_sensitivity_catalog()
  expected_anchors <- list(
    c(baseline = 325, higher = 500, lower = 150),
    c(baseline = 1.00, higher = 1.10, lower = 0.70),
    c(baseline = 1.00, higher = 1.10, lower = 0.50),
    c(baseline = 1.00, higher = 1.20, lower = 0.40),
    c(baseline = 0.04, higher = 0.20, lower = 0.00),
    c(baseline = 0.50, higher = 1.00, lower = 0.20),
    c(baseline = 0.20, higher = 0.30, lower = 0.00),
    c(baseline = 35, higher = 108, lower = 0)
  )
  expected_ranges <- list(
    c(min = 150, max = 750),
    c(min = 0.50, max = 1.10),
    c(min = 0.25, max = 1.20),
    c(min = 0.00, max = 1.50),
    c(min = 0.00, max = 0.30),
    c(min = 0.00, max = 1.00),
    c(min = 0.00, max = 0.33),
    c(min = 0, max = 108)
  )

  expect_identical(catalog$catalog_version, rep("woodhen-investigation-v2", 8L))
  expect_equal(unclass(catalog$anchors), expected_anchors)
  expect_equal(unclass(catalog$custom_range), expected_ranges)
  expect_equal(
    catalog$locked_baseline,
    vapply(expected_anchors, `[[`, numeric(1), "baseline")
  )
  expect_true(all(vapply(catalog$anchors, function(anchor) {
    anchor[["higher"]] > anchor[["baseline"]] &&
      anchor[["lower"]] < anchor[["baseline"]]
  }, logical(1))))
})

test_that("rodent reinvasion targets youngest-bird survival and can add recruitment pressure", {
  locked <- woodhen_locked_future_spec()
  predator <- woodhen_threat_catalog()[woodhen_threat_catalog()$id == "predator_reinvasion", ]

  expect_equal(predator$affected_fields[[1]], "surv")
  expect_equal(predator$affected_stages[[1]], 1L)
  expect_match(predator$label[[1]], "Rodent")
  expect_match(predator$biological_meaning[[1]], "egg and chick")
  expect_match(predator$limitation[[1]], "territory-holder")

  primary <- build_woodhen_prospective_family(
    list(threat_id = "predator_reinvasion", intensity = "moderate")
  )
  primary_spec <- primary$scenarios[[2]]$spec
  primary_surv <- as.numeric(tail(woodhen_spec_field_profile(primary_spec, "surv"), 1L))
  primary_fecund <- as.numeric(tail(woodhen_spec_field_profile(primary_spec, "fecund"), 1L))

  expect_equal(primary_surv[[1]], locked$surv[[1]] * 0.70)
  expect_equal(primary_surv[-1], locked$surv[-1])
  expect_equal(primary_fecund, locked$fecund)

  compound <- build_woodhen_prospective_family(
    list(
      threat_id = "predator_reinvasion",
      intensity = "moderate",
      components = list(egg_chick_recruitment = list(
        field = "fecund", operator = "multiply", value = 0.80, stages = "all"
      ))
    ),
    interventions = list(response = list(
      intervention_id = "biosecurity_eradication", intensity = "moderate"
    ))
  )
  threat_spec <- compound$scenarios[[2]]$spec
  managed_spec <- compound$scenarios[[3]]$spec
  threat_surv <- as.numeric(tail(woodhen_spec_field_profile(threat_spec, "surv"), 1L))
  managed_surv <- as.numeric(tail(woodhen_spec_field_profile(managed_spec, "surv"), 1L))
  threat_fecund <- as.numeric(tail(woodhen_spec_field_profile(threat_spec, "fecund"), 1L))
  managed_fecund <- as.numeric(tail(woodhen_spec_field_profile(managed_spec, "fecund"), 1L))

  expect_equal(threat_surv[[1]], locked$surv[[1]] * 0.70)
  expect_equal(threat_surv[-1], locked$surv[-1])
  expect_equal(threat_fecund, locked$fecund * 0.80)
  expect_equal(managed_surv[[1]], locked$surv[[1]] + 0.5 * (threat_surv[[1]] - locked$surv[[1]]))
  expect_equal(managed_surv[-1], locked$surv[-1])
  expect_equal(managed_fecund, locked$fecund + 0.5 * (threat_fecund - locked$fecund))
  expect_true(all(c(
    "biosecurity_eradication__young_bird_survival",
    "biosecurity_eradication__egg_chick_recruitment"
  ) %in% names(compound$scenarios[[3]]$changes)))
})

test_that("every sensitivity family has one baseline and two isolated settings", {
  catalog <- woodhen_sensitivity_catalog()
  locked <- woodhen_locked_future_spec()

  for (i in seq_len(nrow(catalog))) {
    family <- build_woodhen_sensitivity_family(
      catalog$id[[i]],
      unname(catalog$anchors[[i]][c("higher", "lower")]),
      seed = 321L,
      created_at = "2026-07-21T01:00:00Z"
    )
    expect_s3_class(family, "woodhen_investigation_family")
    expect_length(family$scenarios, 3L)
    expect_equal(
      vapply(family$scenarios, `[[`, character(1), "scenario_type"),
      c("locked_baseline", "sensitivity", "sensitivity")
    )
    expect_equal(vapply(family$scenarios, `[[`, integer(1), "seed"), rep(321L, 3L))
    expect_true(all(vapply(family$scenarios, function(x) identical(x$spec$n0, locked$n0), logical(1))))
    expect_true(all(vapply(family$scenarios, function(x) identical(x$spec$years, locked$years), logical(1))))
    expect_true(all(vapply(family$scenarios, function(x) identical(x$spec$reps, locked$reps), logical(1))))
    expect_true(all(vapply(family$scenarios, function(x) inherits(x$spec, "pva_spec"), logical(1))))

    target_fields <- catalog$affected_fields[[i]]
    for (scenario in family$scenarios[-1]) {
      scenario_specs_equal_except(scenario$spec, locked, target_fields)
      expect_named(scenario$components)
      expect_length(scenario$changes, 1L)
    }
  }

  k_family <- build_woodhen_sensitivity_family("K", c(225, 160))
  expect_equal(vapply(k_family$scenarios, function(x) x$spec$K, numeric(1)), c(325, 225, 160))
  expect_equal(vapply(k_family$scenarios, function(x) x$spec$K_sd, numeric(1)), rep(35, 3))
})

test_that("scenario fingerprints are deterministic and ignore record presentation metadata", {
  first <- build_woodhen_sensitivity_family(
    "K", c(225, 160), created_at = "2026-07-21T01:00:00Z"
  )
  second <- build_woodhen_sensitivity_family(
    "K", c(225, 160), created_at = "2026-07-22T01:00:00Z"
  )

  first_hashes <- vapply(first$scenarios, `[[`, character(1), "spec_fingerprint")
  second_hashes <- vapply(second$scenarios, `[[`, character(1), "spec_fingerprint")
  expect_equal(first_hashes, second_hashes)
  expect_true(all(grepl("^[0-9a-f]{64}$", first_hashes)))
  expect_true(all(vapply(first$scenarios, function(x) {
    identical(x$fingerprint_algorithm, "sha256") &&
      identical(x$record_schema_version, "woodhen-scenario-record-v1")
  }, logical(1))))
  expect_false(identical(first_hashes[[2]], first_hashes[[3]]))
})

test_that("scientific content gives stable unique family and scenario identities", {
  intervention <- list(response = list(
    intervention_id = "emergency_response", intensity = "moderate"
  ))
  cyclone <- function(intensity, label = NULL, notes = NULL) {
    config <- list(
      threat_id = "increased_cyclone_pressure",
      intensity = intensity,
      components = list(
        cyclone_survival = list(field = "cat_surv", operator = "absolute", value = 0.40),
        cyclone_reproduction = list(field = "cat_repro", operator = "absolute", value = 0.60)
      )
    )
    if (!is.null(label)) config$label <- label
    if (!is.null(notes)) config$notes <- notes
    config
  }
  low <- build_woodhen_prospective_family(
    cyclone("low"),
    intervention,
    created_at = "2026-07-21T01:00:00Z"
  )
  low_relabelled <- build_woodhen_prospective_family(
    cyclone("low", "Presentation-only label", "Presentation-only note"),
    intervention,
    created_at = "2026-07-22T01:00:00Z"
  )
  high <- build_woodhen_prospective_family(
    cyclone("high"),
    intervention
  )

  expect_equal(low$family_id, low_relabelled$family_id)
  expect_equal(
    vapply(low$scenarios, `[[`, character(1), "scenario_id"),
    vapply(low_relabelled$scenarios, `[[`, character(1), "scenario_id")
  )
  expect_false(identical(low$family_id, high$family_id))
  expect_false(identical(
    vapply(low$scenarios, `[[`, character(1), "scenario_id"),
    vapply(high$scenarios, `[[`, character(1), "scenario_id")
  ))
  expect_equal(length(unique(vapply(low$scenarios, `[[`, character(1), "scenario_id"))), 3L)
  expect_true(all(vapply(low$scenarios, function(x) identical(x$family_id, low$family_id), logical(1))))
  expect_true(is.na(low$scenarios[[1]]$parent_id))
  expect_equal(low$scenarios[[2]]$parent_id, low$scenarios[[1]]$scenario_id)
  expect_equal(low$scenarios[[3]]$parent_id, low$scenarios[[2]]$scenario_id)
  expect_equal(low$locked_baseline_id, low$scenarios[[1]]$scenario_id)

  sensitivity_a <- build_woodhen_sensitivity_family("K", c(350, 250))
  sensitivity_b <- build_woodhen_sensitivity_family("K", c(300, 250))
  expect_false(identical(sensitivity_a$family_id, sensitivity_b$family_id))

  expect_error(
    build_woodhen_prospective_family(
      "increased_cyclone_pressure",
      c("emergency_response", "emergency_response")
    ),
    "unique"
  )
  expect_error(
    build_woodhen_prospective_family(
      "increased_cyclone_pressure",
      list(baseline = list(intervention_id = "emergency_response"))
    ),
    "reserved"
  )
})

test_that("same-final-spec interventions retain distinct biological identities", {
  biosecurity <- build_woodhen_prospective_family(
    "predator_reinvasion",
    list(management = list(
      intervention_id = "biosecurity_eradication", intensity = "moderate"
    ))
  )
  targeted <- build_woodhen_prospective_family(
    "predator_reinvasion",
    list(management = list(
      intervention_id = "targeted_vital_rate_improvement", intensity = "moderate"
    ))
  )

  expect_equal(biosecurity$scenarios[[3]]$spec, targeted$scenarios[[3]]$spec)
  expect_equal(
    biosecurity$scenarios[[3]]$spec_fingerprint,
    targeted$scenarios[[3]]$spec_fingerprint
  )
  expect_false(identical(biosecurity$family_id, targeted$family_id))
  expect_false(identical(
    biosecurity$scenarios[[3]]$scenario_id,
    targeted$scenarios[[3]]$scenario_id
  ))
  expect_equal(biosecurity$scenarios[[3]]$intervention_id, "biosecurity_eradication")
  expect_equal(targeted$scenarios[[3]]$intervention_id, "targeted_vital_rate_improvement")

  for (scenario in list(biosecurity$scenarios[[3]], targeted$scenarios[[3]])) {
    expect_equal(
      names(scenario$components),
      unname(vapply(scenario$components, `[[`, character(1), "component_id"))
    )
    expect_equal(
      names(scenario$changes),
      unname(vapply(scenario$changes, `[[`, character(1), "component_id"))
    )
  }
})

test_that("all named threat and intervention families materialise explicit mappings", {
  threat_catalog <- woodhen_threat_catalog()
  for (threat_id in threat_catalog$id) {
    family <- build_woodhen_prospective_family(threat_id)
    expect_length(family$scenarios, 2L)
    expect_equal(
      vapply(family$scenarios, `[[`, character(1), "scenario_type"),
      c("locked_baseline", "threat")
    )
    expect_named(family$scenarios[[2]]$components)
    expect_equal(family$scenarios[[2]]$parent_id, family$scenarios[[1]]$scenario_id)
  }

  cases <- list(
    habitat_protection_restoration = "habitat_contraction",
    biosecurity_eradication = "predator_reinvasion",
    targeted_vital_rate_improvement = "novel_disease",
    captive_breeding_supplementation = "novel_disease",
    emergency_response = "increased_cyclone_pressure"
  )
  for (intervention_id in names(cases)) {
    intervention <- list(list(intervention_id = intervention_id, intensity = "moderate"))
    names(intervention) <- intervention_id
    threat <- cases[[intervention_id]]
    if (identical(intervention_id, "emergency_response")) {
      threat <- list(
        threat_id = threat,
        components = list(
          cyclone_survival = list(field = "cat_surv", operator = "absolute", value = 0.40),
          cyclone_reproduction = list(field = "cat_repro", operator = "absolute", value = 0.60)
        )
      )
    }
    family <- build_woodhen_prospective_family(threat, intervention)
    managed <- family$scenarios[[3]]
    expect_equal(managed$scenario_type, "intervention")
    expect_equal(managed$parent_id, family$scenarios[[2]]$scenario_id)
    expect_named(managed$components)
    expect_true(length(managed$changes) >= 1L)
  }
})

test_that("prospective composition is ordered and resolved scientific presets are exact", {
  family <- build_woodhen_prospective_family(
    list(
      threat_id = "sea_level_rise_pathway",
      intensity = "moderate",
      temporal_shape = "linear",
      onset_year = 1L,
      end_year = 75L
    ),
    interventions = list(
      restoration = list(
        intervention_id = "habitat_protection_restoration",
        intensity = "moderate",
        temporal_shape = "linear",
        onset_year = 20L,
        end_year = 40L
      )
    )
  )
  expect_equal(
    family$composition_order,
    c(
      "locked_baseline", "threat_components",
      "intervention_recovery_components", "intervention_direct_components",
      "full_validation"
    )
  )
  threat_k <- family$scenarios[[2]]$spec$annual_profiles$K
  managed_k <- family$scenarios[[3]]$spec$annual_profiles$K
  expect_equal(threat_k[[1]], 325)
  expect_equal(tail(threat_k, 1), 225)
  expect_equal(managed_k[1:20], threat_k[1:20])
  expect_true(tail(managed_k, 1) > tail(threat_k, 1))
  expect_false(any(grepl("sea_level", names(family$scenarios[[2]]$spec), fixed = TRUE)))

  cyclone <- build_woodhen_prospective_family("increased_cyclone_pressure")
  expect_equal(tail(cyclone$scenarios[[2]]$spec$annual_profiles$cat_freq, 1), 0.10)
  expect_false("cat_surv" %in% names(cyclone$scenarios[[2]]$spec$annual_profiles))
  expect_false("cat_repro" %in% names(cyclone$scenarios[[2]]$spec$annual_profiles))

  explicit_reproduction <- build_woodhen_prospective_family(list(
    threat_id = "increased_cyclone_pressure",
    components = list(reproductive_effect = list(
      field = "cat_repro", operator = "absolute", value = 0.60
    ))
  ))
  expect_equal(
    tail(explicit_reproduction$scenarios[[2]]$spec$annual_profiles$cat_repro, 1),
    0.60
  )

  emergency <- build_woodhen_prospective_family(
    list(
      threat_id = "increased_cyclone_pressure",
      components = list(
        cyclone_survival = list(field = "cat_surv", operator = "absolute", value = 0.40),
        cyclone_reproduction = list(field = "cat_repro", operator = "absolute", value = 0.60)
      )
    ),
    list(response = list(intervention_id = "emergency_response", intensity = "moderate"))
  )
  expect_equal(tail(emergency$scenarios[[3]]$spec$annual_profiles$cat_surv, 1), 0.45)
  expect_equal(tail(emergency$scenarios[[3]]$spec$annual_profiles$cat_repro, 1), 0.675)

  supplement <- build_woodhen_prospective_family(
    "novel_disease",
    list(release = list(
      intervention_id = "captive_breeding_supplementation",
      intensity = "moderate",
      onset_year = 5L
    ))
  )
  release_spec <- supplement$scenarios[[3]]$spec
  expect_equal(release_spec$release_years, 5:7)
  expect_equal(release_spec$release_vec, c(0L, 10L, 0L, 0L, 0L, 0L, 0L))
})

test_that("cyclone emergency response recovers named severity and reproduction without changing frequency", {
  locked <- woodhen_locked_future_spec()
  cyclone <- list(
    threat_id = "increased_cyclone_pressure",
    intensity = "high",
    components = list(
      cyclone_survival = list(field = "cat_surv", operator = "absolute", value = 0.30),
      cyclone_reproduction = list(field = "cat_repro", operator = "absolute", value = 0.45)
    )
  )
  family <- build_woodhen_prospective_family(
    cyclone,
    list(response = list(intervention_id = "emergency_response", intensity = "moderate"))
  )
  threat <- family$scenarios[[2]]$spec
  managed <- family$scenarios[[3]]$spec

  expect_equal(tail(threat$annual_profiles$cat_freq, 1L), 0.15)
  expect_equal(tail(managed$annual_profiles$cat_freq, 1L), 0.15)
  expect_equal(tail(managed$annual_profiles$cat_surv, 1L), 0.40)
  expect_equal(tail(managed$annual_profiles$cat_repro, 1L), 0.60)
  expect_equal(managed$surv, threat$surv)
  expect_equal(managed$fecund, threat$fecund)
  expect_true(all(c(
    "emergency_response__cyclone_survival",
    "emergency_response__cyclone_reproduction"
  ) %in% names(family$scenarios[[3]]$changes)))

  expect_error(
    build_woodhen_prospective_family(
      list(
        threat_id = "increased_cyclone_pressure",
        components = list(cyclone_survival = list(
          field = "cat_surv", operator = "absolute", value = 0.30
        ))
      ),
      list(response = list(intervention_id = "emergency_response"))
    ),
    "named parent cat_surv and cat_repro"
  )
  expect_error(
    build_woodhen_prospective_family(
      "novel_disease",
      list(response = list(intervention_id = "emergency_response"))
    ),
    "increased-cyclone-pressure"
  )
})

test_that("fully composed records reject compulsory, advanced, and inherited name collisions", {
  expect_error(
    build_woodhen_prospective_family(list(
      threat_id = "novel_disease",
      components = list(disease_survival = list(
        field = "fecund", operator = "multiply", value = 0.80
      ))
    )),
    "collision"
  )
  expect_error(
    build_woodhen_prospective_family(
      list(
        threat_id = "increased_cyclone_pressure",
        components = list(
          cyclone_survival = list(field = "cat_surv", operator = "absolute", value = 0.40),
          cyclone_reproduction = list(field = "cat_repro", operator = "absolute", value = 0.60)
        )
      ),
      list(response = list(
        intervention_id = "emergency_response",
        components = list(emergency_response__cyclone_survival = list(
          field = "cat_repro", operator = "absolute", value = 0.60
        ))
      ))
    ),
    "collision"
  )
  expect_error(
    build_woodhen_prospective_family(
      list(
        threat_id = "increased_cyclone_pressure",
        components = list(
          cyclone_survival = list(field = "cat_surv", operator = "absolute", value = 0.40),
          cyclone_reproduction = list(field = "cat_repro", operator = "absolute", value = 0.60)
        )
      ),
      list(response = list(
        intervention_id = "emergency_response",
        components = list(threat__cyclone_frequency = list(
          field = "cat_repro", operator = "absolute", value = 0.60
        ))
      ))
    ),
    "collision"
  )
})

test_that("targeted recovery requires an explicit unique target when the parent is multi-factor", {
  multi_vital_threat <- list(
    threat_id = "novel_disease",
    components = list(disease_fecundity = list(
      field = "fecund", operator = "multiply", value = 0.80
    ))
  )
  expect_error(
    build_woodhen_prospective_family(
      multi_vital_threat,
      list(targeted = list(intervention_id = "targeted_vital_rate_improvement"))
    ),
    "target_component"
  )

  explicit <- build_woodhen_prospective_family(
    multi_vital_threat,
    list(targeted = list(
      intervention_id = "targeted_vital_rate_improvement",
      target_component = "disease_fecundity"
    ))
  )
  managed_changes <- names(explicit$scenarios[[3]]$changes)
  expect_true("targeted_vital_rate_improvement__disease_fecundity" %in% managed_changes)
  expect_false("targeted_vital_rate_improvement__disease_survival" %in% managed_changes)

  expect_error(
    build_woodhen_prospective_family(
      multi_vital_threat,
      list(targeted = list(
        intervention_id = "targeted_vital_rate_improvement",
        target_component = "not_a_component"
      ))
    ),
    "uniquely match"
  )
})

test_that("vital-rate component values are scalar or exactly stage-matched", {
  expect_error(
    build_woodhen_prospective_family(list(
      threat_id = "novel_disease",
      components = list(stage_rates = list(
        field = "surv", operator = "absolute", stages = "all",
        value = c(0.60, 0.70, 0.80)
      ))
    )),
    "one scalar or exactly 7"
  )

  exact_rates <- c(0.60, 0.70, 0.80, 0.72, 0.72, 0.62, 0.50)
  accepted <- build_woodhen_prospective_family(list(
    threat_id = "novel_disease",
    components = list(stage_rates = list(
      field = "surv", operator = "absolute", stages = "all",
      value = exact_rates
    ))
  ))
  expect_equal(as.numeric(tail(accepted$scenarios[[2]]$spec$annual_profiles$surv, 1)), exact_rates)
})

test_that("supplied timestamp strings must be strict UTC ISO-8601 values", {
  expect_error(
    build_woodhen_sensitivity_family("K", c(350, 250), created_at = "2026-07-21 01:00:00"),
    "UTC ISO-8601"
  )
  expect_error(
    build_woodhen_prospective_family("novel_disease", created_at = "2026-07-21T11:00:00+10:00"),
    "UTC ISO-8601"
  )
  expect_error(
    build_woodhen_prospective_family("novel_disease", created_at = "2026-02-30T01:00:00Z"),
    "UTC ISO-8601"
  )

  valid <- build_woodhen_sensitivity_family(
    "K", c(350, 250),
    created_at = "2026-07-21T01:00:00Z",
    modified_at = "2026-07-21T02:00:00Z"
  )
  expect_equal(valid$scenarios[[1]]$created_at, "2026-07-21T01:00:00Z")
  expect_equal(valid$scenarios[[1]]$modified_at, "2026-07-21T02:00:00Z")
})

test_that("builders reject unsafe, unsupported, unnamed, and locked changes before simulation", {
  expect_error(build_woodhen_sensitivity_family("K", c(149, 250)), "between 150 and 750")
  expect_error(build_woodhen_sensitivity_family("K", 250), "at least two altered")
  expect_error(build_woodhen_sensitivity_family("env_sd", c(0.25, 0.34)), "between")
  expect_error(
    build_woodhen_prospective_family(list(
      threat_id = "sea_level_rise_pathway",
      temporal_shape = "step"
    )),
    "not allowed"
  )
  expect_error(
    build_woodhen_prospective_family(list(
      threat_id = "novel_disease",
      temporal_shape = "exponential"
    )),
    "not allowed"
  )
  expect_error(
    build_woodhen_prospective_family(list(
      threat_id = "novel_disease",
      components = list(
        list(field = "cat_freq", operator = "absolute", value = 0.1),
        list(field = "cat_surv", operator = "absolute", value = 0.4)
      )
    )),
    "named"
  )
  expect_error(
    build_woodhen_prospective_family(list(
      threat_id = "novel_disease",
      n0 = rep(1, 7)
    )),
    "locked field"
  )
  expect_error(
    build_woodhen_prospective_family(list(
      threat_id = "chronic_environmental_variability",
      intensity = "high",
      components = list(
        survival_boost = list(
          field = "surv", operator = "multiply", value = 1.10, stages = "all"
        )
      )
    )),
    "env_sd too large"
  )
  expect_error(
    build_woodhen_prospective_family(list(
      threat_id = "habitat_contraction",
      intensity = 150,
      components = list(
        habitat_variability = list(
          field = "K_sd", operator = "absolute", value = 51
        )
      )
    )),
    "K >= 3\\*K_sd"
  )
  expect_error(
    build_woodhen_prospective_family(list(
      threat_id = "novel_disease",
      components = list(excess_capacity = list(
        field = "K", operator = "absolute", value = 800
      ))
    )),
    "between 150 and 750"
  )
})

test_that("legacy Woodhen catalogue and specifications remain unchanged", {
  expect_equal(
    woodhen_management_catalog()$scenario_id,
    c(
      "01_no_mgmt", "02_pig_control", "03_captive_pig",
      "04_rodent_eradication", "05_future_baseline", "sensitivity_default",
      "survival_minus_10pct", "K_250", "K_350", "cat_freq_0.10",
      "cat_surv_0.40", "fecund_minus_20pct",
      "juvenile_survival_minus_15pct", "env_sd_0.15"
    )
  )
  expect_equal(
    build_woodhen_management_spec("05_future_baseline"),
    set_scenario("05_future_baseline", "woodhen")
  )
  expect_equal(
    unclass(build_woodhen_management_spec("sensitivity_default")),
    unclass(set_scenario("sensitivity_analysis", "woodhen"))
  )
  expect_error(build_woodhen_management_spec("made_up"), "Unknown Woodhen management scenario")
})

test_that("scientific catalogue audit writes only to its caller-supplied directory", {
  source(file.path(getwd(), "..", "..", "scripts", "audit_practical2_scientific_catalog.R"))
  output_dir <- tempfile("woodhen-catalog-audit-")
  dir.create(output_dir)
  paths <- audit_practical2_scientific_catalog(output_dir)

  expect_named(paths, c("baseline_csv", "catalogue_csv", "recovery_csv", "markdown"))
  expect_true(all(file.exists(unlist(paths))))
  expect_true(all(dirname(normalizePath(unlist(paths))) == normalizePath(output_dir)))
  baseline <- utils::read.csv(paths$baseline_csv, stringsAsFactors = FALSE)
  catalogue <- utils::read.csv(paths$catalogue_csv, stringsAsFactors = FALSE)
  recovery <- utils::read.csv(paths$recovery_csv, stringsAsFactors = FALSE)
  markdown <- readLines(paths$markdown, warn = FALSE)

  expect_setequal(baseline$parameter, names(woodhen_locked_future_spec()))
  expect_true(all(c(
    "parameter", "value", "unit", "model_location", "provenance_class",
    "source_or_rationale", "temporal_assumption", "inference_limit"
  ) %in% names(baseline)))
  expect_false(any(!nzchar(baseline$value)))
  expect_false(any(!nzchar(baseline$unit)))
  expect_false(any(!nzchar(baseline$provenance_class)))

  expect_true(all(c(
    "catalogue", "id", "label", "ecological_process", "baseline_value",
    "setting_1", "setting_2", "setting_3", "unit", "permitted_range",
    "model_quantity", "direction", "timing", "parent_relationship",
    "provenance_class", "source_or_rationale", "omitted_processes",
    "inference_limit"
  ) %in% names(catalogue)))
  sensitivity <- catalogue[catalogue$catalogue == "sensitivity", ]
  expect_setequal(sensitivity$id, woodhen_sensitivity_catalog()$id)
  expect_false(any(!nzchar(sensitivity$baseline_value)))
  expect_false(any(!nzchar(sensitivity$setting_1)))
  expect_false(any(!nzchar(sensitivity$setting_2)))
  expect_true(all(sensitivity$provenance_class == "bounded exploratory setting"))

  baseline <- woodhen_locked_future_spec()
  expect_equal(baseline$K, 325)
  expect_equal(baseline$K_sd, 35)
  threat <- catalogue[catalogue$catalogue == "threat", ]
  expect_equal(
    threat$baseline_value[match(c("habitat_contraction", "sea_level_rise_pathway"), threat$id)],
    c("325", "325")
  )
  expect_match(
    threat$model_quantity[threat$id == "predator_reinvasion"],
    "fecund",
    fixed = TRUE
  )
  expect_match(
    threat$unit[threat$id == "predator_reinvasion"],
    "breeding-output",
    fixed = TRUE
  )
  expect_match(
    threat$model_quantity[threat$id == "increased_cyclone_pressure"],
    "cat_surv",
    fixed = TRUE
  )
  expect_match(
    threat$model_quantity[threat$id == "increased_cyclone_pressure"],
    "cat_repro",
    fixed = TRUE
  )
  intervention <- catalogue[catalogue$catalogue == "intervention", ]
  expect_match(
    intervention$model_quantity[intervention$id == "habitat_protection_restoration"],
    "recover_toward_locked_baseline K",
    fixed = TRUE
  )
  expect_match(
    intervention$direction[intervention$id == "emergency_response"],
    "survival toward 0.5 and reproduction toward 0.75",
    fixed = TRUE
  )
  expect_true(any(grepl("locked K = 325", markdown, fixed = TRUE)))
  expect_true(any(grepl("cat_surv", markdown, fixed = TRUE)))
  expect_true(any(grepl("cat_repro", markdown, fixed = TRUE)))

  expect_true(all(c(
    "event_period", "reported_count", "comparison_count", "count_type",
    "survey_coverage", "use_as_abundance_point", "source_label", "source_url",
    "interpretation_note"
  ) %in% names(recovery)))
  expect_equal(
    recovery$comparison_count[recovery$use_as_abundance_point],
    c(221L, 443L, 598L, 551L, 778L, 1147L, 1638L)
  )
  expect_true(any(recovery$reported_count == "208 selected; primary paper reports 228"))
  expect_true(any(recovery$reported_count == "1,147 selected; primary paper reports 1,108"))
  expect_true(any(recovery$reported_count == "598 banded" & !recovery$use_as_abundance_point))

  expected_markdown <- c(
    "historical reconstruction", "not independent validation",
    "working warning threshold", "not a universal minimum viable population",
    "one territory-holding female represents one breeding pair",
    "female-cohort trajectories", "whole birds", "material issue",
    "internally inconsistent", "female-equivalent model units",
    "208 and 228", "1,108 and 1,147", "threshold-sensitivity",
    "Omitted processes", "Gate A2 accepted", "208 as the release marker",
    "Retain the tuned 1,654-bird future starting state", "technical debt"
  )
  for (phrase in expected_markdown) {
    expect_true(any(grepl(phrase, markdown, fixed = TRUE)), info = phrase)
  }
})
