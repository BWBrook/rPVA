context("Plot layer")

spec <- read_spec(system.file("extdata", "woodhen_no_mgmt.yaml",
                              package = "woodhenPVA"))
spec$years <- 3
spec$reps  <- 5
out <- run_pva_core(spec, keep_traj = TRUE)

test_that("plotting functions return ggplot", {
  expect_s3_class(plot_pva_traj(out), "ggplot")
  expect_s3_class(plot_pva_summary(out), "ggplot")
})
