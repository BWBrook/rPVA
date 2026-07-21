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
  expect_equal(woodhen_locked_future_spec()$K, 500)
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
    identical(names(x), c("low", "moderate", "high"))
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

test_that("every sensitivity family has one baseline and two isolated settings", {
  catalog <- woodhen_sensitivity_catalog()
  locked <- woodhen_locked_future_spec()

  for (i in seq_len(nrow(catalog))) {
    family <- build_woodhen_sensitivity_family(
      catalog$id[[i]],
      unname(catalog$anchors[[i]][c("moderate", "high")]),
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

  k_family <- build_woodhen_sensitivity_family("K", c(350, 250))
  expect_equal(vapply(k_family$scenarios, function(x) x$spec$K, numeric(1)), c(500, 350, 250))
  expect_equal(vapply(k_family$scenarios, function(x) x$spec$K_sd, numeric(1)), rep(50, 3))
})

test_that("scenario fingerprints are deterministic and ignore record presentation metadata", {
  first <- build_woodhen_sensitivity_family(
    "K", c(350, 250), created_at = "2026-07-21T01:00:00Z"
  )
  second <- build_woodhen_sensitivity_family(
    "K", c(350, 250), created_at = "2026-07-22T01:00:00Z"
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
    family <- build_woodhen_prospective_family(cases[[intervention_id]], intervention)
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
      "intervention_recovery_components", "full_validation"
    )
  )
  threat_k <- family$scenarios[[2]]$spec$annual_profiles$K
  managed_k <- family$scenarios[[3]]$spec$annual_profiles$K
  expect_equal(threat_k[[1]], 500)
  expect_equal(tail(threat_k, 1), 350)
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
    "increased_cyclone_pressure",
    list(response = list(intervention_id = "emergency_response", intensity = "moderate"))
  )
  expect_equal(tail(emergency$scenarios[[3]]$spec$annual_profiles$cat_surv, 1), 0.75)

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

test_that("builders reject unsafe, unsupported, unnamed, and locked changes before simulation", {
  expect_error(build_woodhen_sensitivity_family("K", c(149, 250)), "between 150 and 750")
  expect_error(build_woodhen_sensitivity_family("K", 250), "at least two altered")
  expect_error(build_woodhen_sensitivity_family("env_sd", c(0.25, 0.31)), "between")
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

  expect_named(paths, c("csv", "markdown"))
  expect_true(all(file.exists(unlist(paths))))
  expect_true(all(dirname(normalizePath(unlist(paths))) == normalizePath(output_dir)))
  csv <- utils::read.csv(paths$csv, stringsAsFactors = FALSE)
  markdown <- readLines(paths$markdown, warn = FALSE)
  expect_true(all(c(
    "anchor", "bound_min", "bound_max", "model_mapping", "temporal_allowance",
    "horizon_years", "seed", "breeding_pair_definition"
  ) %in% names(csv)))
  expect_true(any(grepl("fewer than 50", markdown, fixed = TRUE)))
  expect_true(any(grepl("stages 2 onward", markdown, fixed = TRUE)))
})
