context("Validation and edge cases")

test_that("all repo YAMLs parse under the strict partial schema", {
  yaml_paths <- list.files(
    file.path(repo_root(), "inst"),
    pattern = "\\.ya?ml$",
    recursive = TRUE,
    full.names = TRUE
  )

  expect_no_error(lapply(yaml_paths, read_spec))
})

test_that("read_spec rejects deprecated and unknown live keys", {
  demo_sd_path <- tempfile(fileext = ".yaml")
  writeLines("demo_sd: TRUE", demo_sd_path)
  expect_error(read_spec(demo_sd_path), "demographic_stochasticity")

  max_age_path <- tempfile(fileext = ".yaml")
  writeLines("max_age: 8", max_age_path)
  expect_error(read_spec(max_age_path), "placeholder")

  unknown_path <- tempfile(fileext = ".yaml")
  writeLines("mystery_key: 1", unknown_path)
  expect_error(read_spec(unknown_path), "Unknown spec field")
})

test_that("read_spec rejects quoted stand-in values", {
  quoted_bool_path <- tempfile(fileext = ".yaml")
  writeLines("demographic_stochasticity: \"TRUE\"", quoted_bool_path)
  expect_error(read_spec(quoted_bool_path), "TRUE or FALSE")

  quoted_num_path <- tempfile(fileext = ".yaml")
  writeLines("years: \"10\"", quoted_num_path)
  expect_error(read_spec(quoted_num_path), "integer-valued scalar")
})

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

test_that("run_pva_core rejects legacy programmatic field names", {
  spec <- read_test_spec()
  spec$demo_sd <- spec$demographic_stochasticity
  spec$demographic_stochasticity <- NULL

  expect_error(run_pva_core(spec, verbose = FALSE), "demographic_stochasticity")
})

test_that("run_pva_core rejects exact-length action mismatches", {
  spec <- read_test_spec()
  spec$release_years <- c(1L)
  spec$release_vec <- c(1L, 2L)

  expect_error(run_pva_core(spec, verbose = FALSE), "release_vec")
})

test_that("plot_ext handles trajectories that never cross 50 percent extinction", {
  spec <- read_toy_spec()
  spec$years <- 5
  spec$reps <- 3
  spec$env_sd <- 0
  spec$demographic_stochasticity <- FALSE
  spec$K <- 1e6
  spec$genetics <- FALSE

  out <- run_pva_core(spec, keep_traj = TRUE, seed = 5, verbose = FALSE)

  with_temp_pdf({
    expect_s3_class(plot_ext(out), "ggplot")
  })

  expect_no_local_artifacts()
})
