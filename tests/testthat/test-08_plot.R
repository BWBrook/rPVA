context("Checkpoint 8 – plot layer")

spec <- read_test_spec()
spec$years <- 3
spec$reps  <- 5
spec$demographic_stochasticity <- FALSE
out <- run_pva_core(spec, keep_traj = TRUE)

test_that("plotting functions return ggplot", {
  with_temp_pdf({
    expect_s3_class(plot_pva_traj(out), "ggplot")
    expect_s3_class(plot_pva_summary(out), "ggplot")
  })

  expect_no_local_artifacts()
})
