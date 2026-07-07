test_that("Woodhen management catalog is ordered and bounded", {
  catalog <- woodhen_management_catalog()

  expect_s3_class(catalog, "data.frame")
  expect_equal(
    catalog$scenario_id,
    c(
      "01_no_mgmt",
      "02_pig_control",
      "03_captive_pig",
      "04_rodent_eradication",
      "05_future_baseline",
      "sensitivity_default",
      "survival_minus_10pct",
      "K_250",
      "K_350",
      "cat_freq_0.10",
      "cat_surv_0.40",
      "fecund_minus_20pct",
      "juvenile_survival_minus_15pct",
      "env_sd_0.15"
    )
  )
  expect_true(all(catalog$section %in% c("core_management", "sensitivity")))
  expect_true(all(c(
    "source_yaml",
    "changed_parameter",
    "change_label",
    "app_default",
    "teaching_note",
    "choice_prompt",
    "evidence_prompt",
    "horizon_note"
  ) %in% names(catalog)))
  expect_true(all(nzchar(catalog$teaching_note)))
  expect_true(all(nzchar(catalog$choice_prompt)))
  expect_true(any(catalog$scenario_id == "K_350"))
  expect_true(any(catalog$scenario_id == "fecund_minus_20pct"))
})

test_that("Woodhen management specs load core scenarios and one-factor sensitivity presets", {
  pig <- build_woodhen_management_spec("02_pig_control")
  sensitivity <- build_woodhen_management_spec("sensitivity_default")
  survival <- build_woodhen_management_spec("survival_minus_10pct")
  k250 <- build_woodhen_management_spec("K_250")
  k350 <- build_woodhen_management_spec("K_350")
  catastrophe <- build_woodhen_management_spec("cat_freq_0.10")
  catastrophe_survival <- build_woodhen_management_spec("cat_surv_0.40")
  fecund <- build_woodhen_management_spec("fecund_minus_20pct")
  juvenile_survival <- build_woodhen_management_spec("juvenile_survival_minus_15pct")
  env <- build_woodhen_management_spec("env_sd_0.15")

  expect_s3_class(pig, "pva_spec")
  expect_equal(pig$name, "woodhen_pig_control")
  expect_equal(pig$K, 70)

  expect_equal(survival$surv, sensitivity$surv * 0.90)
  expect_equal(survival$K, sensitivity$K)
  expect_equal(k250$K, 250)
  expect_equal(k250$surv, sensitivity$surv)
  expect_equal(k350$K, 350)
  expect_equal(k350$surv, sensitivity$surv)
  expect_equal(catastrophe$cat_freq, 0.10)
  expect_equal(catastrophe$K, sensitivity$K)
  expect_equal(catastrophe_survival$cat_surv, 0.40)
  expect_equal(catastrophe_survival$K, sensitivity$K)
  expect_equal(fecund$fecund, sensitivity$fecund * 0.80)
  expect_equal(fecund$surv, sensitivity$surv)
  expect_equal(juvenile_survival$surv[1:2], sensitivity$surv[1:2] * 0.85)
  expect_equal(juvenile_survival$surv[-c(1:2)], sensitivity$surv[-c(1:2)])
  expect_equal(env$env_sd, 0.15)
  expect_equal(env$K, sensitivity$K)

  expect_error(build_woodhen_management_spec("made_up"), "Unknown Woodhen management scenario")
})

test_that("Woodhen management runs return labelled evidence bundles", {
  run <- run_woodhen_management_scenario("02_pig_control", keep_traj = FALSE, seed = 123)

  expect_s3_class(run, "woodhen_management_run")
  expect_equal(run$scenario_id, "02_pig_control")
  expect_equal(run$label, "Pig control")
  expect_s3_class(run$summary, "data.frame")
  expect_equal(run$summary$scenario, "Pig control")
  expect_true(nrow(run$settings) > 0)
  expect_true(any(run$settings$setting == "spec_K" & run$settings$value == "70"))
})

test_that("Woodhen management sets preserve order and include report-ready comparisons", {
  runs <- run_woodhen_management_set(
    c("01_no_mgmt", "02_pig_control", "03_captive_pig"),
    keep_traj = FALSE,
    seed = 123
  )

  expect_s3_class(runs, "woodhen_management_run_set")
  expect_equal(vapply(runs$runs, `[[`, character(1), "scenario_id"), c("01_no_mgmt", "02_pig_control", "03_captive_pig"))
  expect_equal(runs$comparison$scenario_id, c("01_no_mgmt", "02_pig_control", "03_captive_pig"))
  expect_equal(runs$comparison$label, c("No intervention", "Pig control", "Captive breeding plus pig control"))
  expect_true(all(c(
    "PE",
    "Nmed",
    "Nlo95",
    "Nhi95",
    "years",
    "changed_parameter",
    "teaching_note",
    "evidence_prompt"
  ) %in% names(runs$comparison)))
})

test_that("Woodhen sensitivity presets reproduce reference seeded values", {
  runs <- run_woodhen_management_set(
    c("sensitivity_default", "survival_minus_10pct", "K_250", "cat_freq_0.10"),
    keep_traj = FALSE,
    seed = 123
  )

  expect_equal(runs$comparison$PE, c(0, 0, 0, 0))
  expect_equal(runs$comparison$Nmed, c(1510, 1484, 745, 1483))
  expect_equal(runs$comparison$Nlo95, c(1109, 1091, 466, 1052))
  expect_equal(runs$comparison$Nhi95, c(1957, 1968, 1070, 1975))
})

test_that("Woodhen evidence export contains comparison, settings, and student choice notes", {
  core_runs <- run_woodhen_management_set(
    c("01_no_mgmt", "02_pig_control"),
    keep_traj = FALSE,
    seed = 123
  )
  sensitivity_runs <- run_woodhen_management_set(
    c("sensitivity_default", "K_350"),
    keep_traj = FALSE,
    seed = 123
  )
  export <- build_woodhen_management_evidence_export(
    list(core_runs, sensitivity_runs),
    generated_at = as.POSIXct("2026-07-07 10:00:00", tz = "UTC"),
    seed = 123,
    interpretation = "Pig control lowers extinction risk but leaves residual risk.",
    choice_note = list(
      decision_lens = "future threat robustness",
      chosen_sensitivity = "K_350",
      biological_reason = "Habitat recovery may be incomplete.",
      expected_direction = "Lower K should reduce final abundance.",
      observed_result = "The median abundance fell compared with the sensitivity baseline.",
      confidence_change = "This makes the recommendation more conditional.",
      caveat = "The model omits spatial habitat quality."
    )
  )

  expect_named(export, c("comparison", "settings", "notes"))
  expect_equal(export$comparison$scenario_id, c("01_no_mgmt", "02_pig_control", "sensitivity_default", "K_350"))
  expect_true(any(export$settings$scenario_id == "02_pig_control"))
  expect_true(any(export$settings$scenario_id == "K_350"))
  expect_true(any(grepl("Practical 2 Woodhen Evidence Notes", export$notes, fixed = TRUE)))
  expect_true(any(grepl("Pig control lowers extinction risk", export$notes, fixed = TRUE)))
  expect_true(any(grepl("Student analytical choice", export$notes, fixed = TRUE)))
  expect_true(any(grepl("future threat robustness", export$notes, fixed = TRUE)))
  expect_true(any(grepl("Habitat recovery may be incomplete", export$notes, fixed = TRUE)))
})

test_that("Woodhen evidence export requires chosen sensitivity evidence row", {
  core_runs <- run_woodhen_management_set(
    c("01_no_mgmt", "02_pig_control"),
    keep_traj = FALSE,
    seed = 123
  )
  sensitivity_runs <- run_woodhen_management_set(
    c("sensitivity_default", "K_250"),
    keep_traj = FALSE,
    seed = 123
  )
  choice_note <- list(
    decision_lens = "future threat robustness",
    chosen_sensitivity = "K_350",
    biological_reason = "Habitat recovery may be incomplete.",
    expected_direction = "Lower K should reduce final abundance.",
    observed_result = "The median abundance fell compared with the sensitivity baseline.",
    confidence_change = "This makes the recommendation more conditional.",
    caveat = "The model omits spatial habitat quality."
  )

  expect_error(
    build_woodhen_management_evidence_export(list(core_runs, sensitivity_runs), choice_note = choice_note),
    "Chosen sensitivity must be present in the exported comparison"
  )

  choice_note$chosen_sensitivity <- "sensitivity_default"
  expect_error(
    build_woodhen_management_evidence_export(list(core_runs, sensitivity_runs), choice_note = choice_note),
    "approved non-baseline sensitivity"
  )
})
