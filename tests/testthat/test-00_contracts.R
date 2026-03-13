context("Public contracts and characterization")

test_that("run_pva_core preserves the current result contract", {
  spec <- read_test_spec()
  spec$years <- 4
  spec$reps <- 3
  spec$env_sd <- 0
  spec$demo_sd <- FALSE

  out <- run_pva_core(spec, keep_traj = TRUE, seed = 11, verbose = FALSE)

  expect_named(
    out,
    c(
      "Nend", "traj", "sr_traj", "F_traj", "LE_traj", "ext_prob",
      "Nend_summary", "traj_mean", "sr_mean", "F_mean", "LE_mean",
      "params", "raw"
    ),
    ignore.order = FALSE
  )
  expect_named(out$raw, c("Nend", "traj", "sr_traj", "F_traj", "LE_traj"))
  expect_equal(out$Nend, c(9, 23, 17))
  expect_equal(out$Nend_summary, list(median = 17, lo95 = 9, hi95 = 23))
  expect_equal(unname(out$ext_prob), c(0, 0, 0, 0, 0))
  expect_equal(dim(out$traj), c(5, 7, 3))
})

test_that("keep_traj = FALSE preserves summaries while omitting heavy arrays", {
  spec <- read_test_spec()
  spec$years <- 4
  spec$reps <- 3
  spec$env_sd <- 0
  spec$demo_sd <- FALSE

  full <- run_pva_core(spec, keep_traj = TRUE, seed = 11, verbose = FALSE)
  lite <- run_pva_core(spec, keep_traj = FALSE, seed = 11, verbose = FALSE)

  expect_equal(lite$Nend, full$Nend)
  expect_equal(lite$Nend_summary, full$Nend_summary)
  expect_null(lite$traj)
  expect_null(lite$traj_mean)
  expect_null(lite$ext_prob)
})

test_that("run_toy_demo remains callable and numerically stable", {
  with_temp_pdf({
    toy <- run_toy_demo(seed = 42)

    expect_named(toy, c("results", "summary"))
    expect_equal(toy$summary$scenario, c("det", "ceiling", "demo_sd", "env_sd", "genetics"))
    expect_equal(unname(toy$summary$PE), c(0, 0, 0, 0, 0.07))
    expect_equal(toy$summary$N_med, c(264, 85, 82, 70, 60))
  })

  expect_no_local_artifacts()
})
