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
      "cat_freq_0.10"
    )
  )
  expect_true(all(catalog$section %in% c("core_management", "sensitivity")))
  expect_true(all(c("source_yaml", "changed_parameter", "change_label", "app_default") %in% names(catalog)))
})

test_that("Woodhen management specs load core scenarios and one-factor sensitivity presets", {
  pig <- build_woodhen_management_spec("02_pig_control")
  sensitivity <- build_woodhen_management_spec("sensitivity_default")
  survival <- build_woodhen_management_spec("survival_minus_10pct")
  k250 <- build_woodhen_management_spec("K_250")
  catastrophe <- build_woodhen_management_spec("cat_freq_0.10")

  expect_s3_class(pig, "pva_spec")
  expect_equal(pig$name, "woodhen_pig_control")
  expect_equal(pig$K, 70)

  expect_equal(survival$surv, sensitivity$surv * 0.90)
  expect_equal(survival$K, sensitivity$K)
  expect_equal(k250$K, 250)
  expect_equal(k250$surv, sensitivity$surv)
  expect_equal(catastrophe$cat_freq, 0.10)
  expect_equal(catastrophe$K, sensitivity$K)

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
  expect_true(all(c("PE", "Nmed", "Nlo95", "Nhi95", "changed_parameter") %in% names(runs$comparison)))
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

test_that("Woodhen evidence export contains comparison, settings, and student notes", {
  runs <- run_woodhen_management_set(
    c("01_no_mgmt", "02_pig_control"),
    keep_traj = FALSE,
    seed = 123
  )
  export <- build_woodhen_management_evidence_export(
    runs,
    generated_at = as.POSIXct("2026-07-07 10:00:00", tz = "UTC"),
    seed = 123,
    interpretation = "Pig control lowers extinction risk but leaves residual risk."
  )

  expect_named(export, c("comparison", "settings", "notes"))
  expect_equal(export$comparison$scenario_id, c("01_no_mgmt", "02_pig_control"))
  expect_true(any(export$settings$scenario_id == "02_pig_control"))
  expect_true(any(grepl("Practical 2 Woodhen Evidence Notes", export$notes, fixed = TRUE)))
  expect_true(any(grepl("Pig control lowers extinction risk", export$notes, fixed = TRUE)))
})
