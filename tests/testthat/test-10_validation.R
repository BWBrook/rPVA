context("Validation and edge cases")

test_that("run_pva_core errors when required fields are missing", {
  spec <- read_test_spec()
  spec$fecund <- NULL

  expect_error(run_pva_core(spec, verbose = FALSE), "spec must include")
})

test_that("run_pva_core errors on stage-length mismatches", {
  spec <- read_test_spec()
  spec$fecund <- spec$fecund[-1]

  expect_error(run_pva_core(spec, verbose = FALSE))
})

test_that("run_pva_core errors on invalid survival probabilities", {
  spec <- read_test_spec()
  spec$surv[1] <- -0.1

  expect_error(run_pva_core(spec, verbose = FALSE), "surv")
})

test_that("plot_ext handles trajectories that never cross 50 percent extinction", {
  spec <- read_toy_spec()
  spec$years <- 5
  spec$reps <- 3
  spec$env_sd <- 0
  spec$demo_sd <- FALSE
  spec$K <- 1e6
  spec$genetics <- FALSE

  out <- run_pva_core(spec, keep_traj = TRUE, seed = 5, verbose = FALSE)

  with_temp_pdf({
    expect_s3_class(plot_ext(out), "ggplot")
  })

  expect_no_local_artifacts()
})
