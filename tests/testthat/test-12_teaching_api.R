context("Practical 1 teaching API")

test_that("teaching_stage_catalog describes implemented and deferred stages", {
  catalog <- teaching_stage_catalog()

  expect_s3_class(catalog, "data.frame")
  expect_true(all(c(
    "stage",
    "order",
    "label",
    "concept",
    "implemented",
    "engine_status",
    "controls"
  ) %in% names(catalog)))
  expect_equal(catalog$stage[1], "deterministic_baseline")
  expect_true(all(c(
    "deterministic_baseline",
    "carrying_capacity",
    "demographic_stochasticity",
    "environmental_stochasticity",
    "genetic_stochasticity",
    "catastrophe",
    "intervention",
    "extinction_vortex",
    "allee_effect",
    "correlated_events"
  ) %in% catalog$stage))
  expect_false(catalog$implemented[catalog$stage == "allee_effect"])
  expect_false(catalog$implemented[catalog$stage == "correlated_events"])
})

test_that("build_teaching_spec applies safe stage-specific defaults", {
  det <- build_teaching_spec("deterministic_baseline")
  ceiling <- build_teaching_spec("carrying_capacity")
  demographic <- build_teaching_spec("demographic_stochasticity")
  environmental <- build_teaching_spec("environmental_stochasticity")
  genetics <- build_teaching_spec("genetic_stochasticity")
  catastrophe <- build_teaching_spec("catastrophe")
  intervention <- build_teaching_spec("intervention")
  vortex <- build_teaching_spec("extinction_vortex")

  expect_s3_class(det, "pva_spec")
  expect_equal(det$name, "teaching_deterministic_baseline")
  expect_false(det$demographic_stochasticity)
  expect_false(det$genetics)
  expect_true(is.na(det$K))

  expect_equal(ceiling$K, 30)
  expect_false(ceiling$demographic_stochasticity)

  expect_true(demographic$demographic_stochasticity)
  expect_equal(demographic$reps, 100L)

  expect_equal(environmental$K, 15)
  expect_equal(environmental$env_sd, 0.35)
  expect_equal(environmental$years, 50L)
  expect_equal(environmental$K_sd, 5)

  expect_true(genetics$genetics)
  expect_equal(genetics$lethal_equiv, c(1.5, 1, 0.5))

  expect_equal(catastrophe$cat_freq, 0.05)
  expect_equal(catastrophe$cat_surv, 0.60)
  expect_equal(catastrophe$cat_repro, 0.70)

  expect_equal(intervention$K, 60)
  expect_equal(intervention$env_sd, 0.20)

  expect_true(vortex$genetics)
  expect_true(vortex$demographic_stochasticity)
  expect_equal(vortex$n0, c(12, 5, 3))
})

test_that("build_teaching_spec accepts bounded controls and rejects unsafe ones", {
  spec <- build_teaching_spec(
    "catastrophe",
    controls = list(cat_freq = 0.10, cat_surv = 0.50, cat_repro = 0.80, reps = 25)
  )

  expect_equal(spec$cat_freq, 0.10)
  expect_equal(spec$cat_surv, 0.50)
  expect_equal(spec$cat_repro, 0.80)
  expect_equal(spec$reps, 25L)

  expect_error(build_teaching_spec("not_a_stage"), "Unknown teaching stage")
  expect_error(build_teaching_spec("allee_effect"), "not implemented")
  expect_error(build_teaching_spec("catastrophe", list(not_a_control = 0.2)), "Unknown control")
  expect_error(build_teaching_spec("catastrophe", list(cat_freq = 0.8)), "outside")
  expect_error(build_teaching_spec("demographic_stochasticity", list(reps = 2.5)), "integer")
  expect_error(build_teaching_spec("deterministic_baseline", base = "woodhen"), "Only `base = \"toy\"`")
})

test_that("Explore stages accept the accumulated Core teaching controls", {
  shared <- list(
    years = 50,
    reps = 500,
    K = 70,
    K_sd = 7,
    env_sd = 0.40,
    mortality_pct = -10,
    fecundity_pct = 5
  )

  catastrophe <- build_teaching_spec(
    "catastrophe",
    controls = c(shared, list(cat_freq = 0.10, cat_surv = 0.50))
  )
  intervention <- build_teaching_spec("intervention", controls = shared)
  vortex <- build_teaching_spec(
    "extinction_vortex",
    controls = c(
      shared,
      list(F_init = 0.30, cat_freq = 0.18, cat_surv = 0.45, cat_repro = 0.60)
    )
  )

  for (spec in list(catastrophe, intervention, vortex)) {
    expect_equal(spec$years, 50L)
    expect_equal(spec$reps, 500L)
    expect_equal(spec$K, 70)
    expect_equal(spec$K_sd, 7)
    expect_equal(spec$env_sd, 0.40)
    expect_equal(spec$mortality_pct, -10)
    expect_equal(spec$fecundity_pct, 5)
  }
  expect_equal(vortex$F_init, 0.30)
  expect_equal(vortex$cat_freq, 0.18)
  expect_equal(vortex$cat_surv, 0.45)
  expect_equal(vortex$cat_repro, 0.60)
})

test_that("advanced teaching controls apply bounded vital-rate adjustments", {
  base <- build_teaching_spec("environmental_stochasticity")
  adjusted <- build_teaching_spec(
    "environmental_stochasticity",
    controls = list(mortality_pct = 10, fecundity_pct = -20, years = 1000, reps = 1000)
  )

  expected_surv <- 1 - (1 - base$surv) * 1.10
  expect_equal(adjusted$surv, expected_surv)
  expect_equal(adjusted$fecund, base$fecund * 0.80)
  expect_equal(adjusted$mortality_pct, 10)
  expect_equal(adjusted$fecundity_pct, -20)
  expect_equal(adjusted$years, 1000L)
  expect_equal(adjusted$reps, 1000L)

  improved <- build_teaching_spec("environmental_stochasticity", controls = list(mortality_pct = -5, fecundity_pct = 5))
  expect_equal(improved$surv, 1 - (1 - base$surv) * 0.95)
  expect_equal(improved$fecund, base$fecund * 1.05)

  adjusted_run <- run_teaching_pva(
    "environmental_stochasticity",
    controls = list(mortality_pct = 10, fecundity_pct = -20, years = 50, reps = 10),
    keep_traj = FALSE,
    seed = 42
  )
  expect_s3_class(adjusted_run, "teaching_pva_run")
  expect_equal(adjusted_run$spec$mortality_pct, 10)
  expect_equal(adjusted_run$spec$fecundity_pct, -20)

  expect_error(build_teaching_spec("environmental_stochasticity", controls = list(mortality_pct = 15)), "allowed preset")
  expect_error(build_teaching_spec("environmental_stochasticity", controls = list(fecundity_pct = 15)), "allowed preset")
  expect_error(build_teaching_spec("environmental_stochasticity", controls = list(years = 1001)), "outside")
  expect_error(build_teaching_spec("environmental_stochasticity", controls = list(reps = 1001)), "outside")
})

test_that("environmental stochasticity default exposes extinction-time teaching signal", {
  run <- run_teaching_pva("environmental_stochasticity", keep_traj = FALSE, seed = 42)

  expect_gte(run$summary$PE, 0.20)
  expect_lte(run$summary$PE, 0.40)
})

test_that("environmental variability supports the highest valid teaching preset", {
  spec <- build_teaching_spec(
    "environmental_stochasticity",
    controls = list(env_sd = 0.40)
  )

  expect_equal(spec$env_sd, 0.40)
  expect_error(
    build_teaching_spec("environmental_stochasticity", controls = list(env_sd = 0.41)),
    "outside the supported range"
  )
})

test_that("run_teaching_pva returns a labelled Shiny-ready bundle", {
  run <- run_teaching_pva(
    "demographic_stochasticity",
    controls = list(reps = 6),
    keep_traj = FALSE,
    seed = 101
  )

  expect_s3_class(run, "teaching_pva_run")
  expect_equal(names(run), c(
    "stage",
    "label",
    "spec",
    "result",
    "summary",
    "diagnostics",
    "settings"
  ))
  expect_equal(run$stage, "demographic_stochasticity")
  expect_equal(run$label, "Demographic stochasticity")
  expect_s3_class(run$spec, "pva_spec")
  expect_s3_class(run$summary, "data.frame")
  expect_s3_class(run$diagnostics, "data.frame")
  expect_s3_class(run$settings, "data.frame")
  expect_equal(run$summary$scenario, "Demographic stochasticity")
  expect_equal(run$summary$reps, 6L)
  expect_false(run$summary$trajectory_available)
})

test_that("run_teaching_pva avoids console progress by default", {
  expect_silent(run_teaching_pva(
    "deterministic_baseline",
    keep_traj = FALSE,
    seed = 101
  ))
})

test_that("run_teaching_pva passes replicate progress through", {
  events <- list()
  run <- run_teaching_pva(
    "demographic_stochasticity",
    controls = list(reps = 6),
    keep_traj = FALSE,
    seed = 101,
    progress = function(completed, total) {
      events[[length(events) + 1L]] <<- c(completed = completed, total = total)
    }
  )

  event_matrix <- do.call(rbind, events)
  expect_equal(run$summary$reps, 6L)
  expect_true(all(diff(event_matrix[, "completed"]) > 0))
  expect_equal(unname(event_matrix[nrow(event_matrix), ]), c(6, 6))
})

test_that("teaching_settings_record is compact and does not write files", {
  spec <- build_teaching_spec("intervention", controls = list(K = 75, reps = 8))
  settings <- teaching_settings_record("intervention", list(K = 75, reps = 8), spec)

  expect_s3_class(settings, "data.frame")
  expect_true(all(c("stage", "label", "setting", "value") %in% names(settings)))
  expect_true("control_K" %in% settings$setting)
  expect_true("spec_K" %in% settings$setting)
  expect_equal(settings$value[settings$setting == "control_K"], "75")
  expect_no_local_artifacts()
})

test_that("compare_teaching_runs preserves run order and labels", {
  det <- run_teaching_pva("deterministic_baseline", keep_traj = FALSE)
  ceiling <- run_teaching_pva("carrying_capacity", controls = list(K = 40), keep_traj = FALSE)
  comparison <- compare_teaching_runs(list(det, ceiling))

  expect_s3_class(comparison, "data.frame")
  expect_equal(comparison$stage, c("deterministic_baseline", "carrying_capacity"))
  expect_equal(comparison$label, c("Deterministic baseline", "Ceiling carrying capacity"))
  expect_equal(comparison$scenario, comparison$label)
  expect_true(all(c("PE", "Nmed", "Nlo95", "Nhi95") %in% names(comparison)))
  expect_error(compare_teaching_runs(list()), "non-empty list")
  expect_error(compare_teaching_runs(list(list(stage = "broken"))), "run_teaching_pva")
})

test_that("teaching evidence export keeps comparison, settings, and interpretation prompt compact", {
  det <- run_teaching_pva("deterministic_baseline", keep_traj = FALSE, seed = 42)
  ceiling <- run_teaching_pva(
    "carrying_capacity",
    controls = list(K = 40),
    keep_traj = FALSE,
    seed = 42
  )
  before <- list.files(".", all.files = TRUE, recursive = FALSE)

  export <- build_teaching_evidence_export(
    list(det, ceiling),
    generated_at = as.POSIXct("2026-06-10 00:00:00", tz = "UTC")
  )
  after <- list.files(".", all.files = TRUE, recursive = FALSE)

  expect_named(export, c("comparison", "settings", "notes"))
  expect_s3_class(export$comparison, "data.frame")
  expect_s3_class(export$settings, "data.frame")
  expect_type(export$notes, "character")

  expect_true(all(c("run_id", "stage", "label", "PE", "Nmed") %in% names(export$comparison)))
  expect_equal(export$comparison$run_id, 1:2)
  expect_equal(export$comparison$stage, c("deterministic_baseline", "carrying_capacity"))

  expect_true(all(c("run_id", "stage", "label", "setting", "value") %in% names(export$settings)))
  expect_true(any(export$settings$setting == "control_K" & export$settings$value == "40"))
  expect_true(any(grepl("Generated: 2026-06-10 00:00:00 UTC", export$notes, fixed = TRUE)))
  expect_false(any(grepl("UTC UTC", export$notes, fixed = TRUE)))
  expect_true(any(grepl("evidence for your own interpretation", export$notes, fixed = TRUE)))
  expect_true(any(grepl("Fixed teaching seed: 42", export$notes, fixed = TRUE)))
  expect_true(any(grepl("Selected evidence: 2 runs from 2 successful session runs", export$notes, fixed = TRUE)))
  expect_false(any(grepl("raw trajectory", export$notes, fixed = TRUE)))
  expect_equal(after, before)
  expect_no_local_artifacts()
})

test_that("teaching comparison summary adds baseline deltas for interpretation", {
  det <- run_teaching_pva("deterministic_baseline", keep_traj = FALSE, seed = 42)
  ceiling <- run_teaching_pva(
    "carrying_capacity",
    controls = list(K = 40),
    keep_traj = FALSE,
    seed = 42
  )

  comparison <- compare_teaching_runs(list(det, ceiling), include_deltas = TRUE)

  expect_true(all(c("delta_PE", "delta_Nmed", "uncertainty_change") %in% names(comparison)))
  expect_equal(comparison$delta_PE[[1]], 0)
  expect_equal(comparison$delta_Nmed[[1]], 0)
  expect_equal(comparison$uncertainty_change[[1]], "baseline")
  expect_type(comparison$uncertainty_change[[2]], "character")
})

test_that("teaching evidence export can include student interpretation notes", {
  det <- run_teaching_pva("deterministic_baseline", keep_traj = FALSE, seed = 42)
  ceiling <- run_teaching_pva(
    "carrying_capacity",
    controls = list(K = 40),
    keep_traj = FALSE,
    seed = 42
  )

  export <- build_teaching_evidence_export(
    list(det, ceiling),
    generated_at = as.POSIXct("2026-06-10 00:00:00", tz = "UTC"),
    interpretation = "I changed habitat ceiling; median abundance moved; the caveat is horizon."
  )

  expect_true(any(grepl("## Student interpretation note", export$notes, fixed = TRUE)))
  expect_true(any(grepl("I changed habitat ceiling", export$notes, fixed = TRUE)))
})

test_that("teaching evidence notes distinguish selected runs from full session history", {
  det <- run_teaching_pva("deterministic_baseline", keep_traj = FALSE, seed = 42)
  risk <- run_teaching_pva(
    "environmental_stochasticity",
    controls = list(env_sd = 0.25, K = 35),
    keep_traj = FALSE,
    seed = 42
  )
  action <- run_teaching_pva("intervention", keep_traj = FALSE, seed = 42)
  det$session_run_id <- 1L
  risk$session_run_id <- 6L
  action$session_run_id <- 8L

  export <- build_teaching_evidence_export(
    list(det, risk, action),
    generated_at = as.POSIXct("2026-07-15 00:00:00", tz = "UTC"),
    interpretation = "Risk increased under bad years; intervention improved abundance, with uncertainty remaining.",
    session_run_count = 8L
  )

  expect_equal(nrow(export$comparison), 3L)
  expect_equal(export$comparison$run_id, c(1L, 6L, 8L))
  expect_equal(sort(unique(export$settings$run_id)), c(1L, 6L, 8L))
  expect_true(any(grepl(
    "Selected evidence: 3 runs from 8 successful session runs",
    export$notes,
    fixed = TRUE
  )))
  expect_true(any(grepl("## Student interpretation note", export$notes, fixed = TRUE)))
})
