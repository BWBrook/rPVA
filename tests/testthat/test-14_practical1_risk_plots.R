context("Practical 1 risk plots")

synthetic_risk_output <- function(total_trajectories, K = 10) {
  total_trajectories <- as.matrix(total_trajectories)
  traj <- array(
    total_trajectories,
    dim = c(nrow(total_trajectories), 1L, ncol(total_trajectories))
  )
  list(
    traj = traj,
    raw = list(traj = traj),
    ext_prob = rowMeans(total_trajectories == 0),
    params = list(
      K = K,
      years = nrow(total_trajectories) - 1L,
      reps = ncol(total_trajectories)
    )
  )
}

test_that("extinction timing records first extinction and population median", {
  totals <- cbind(
    c(10, 8, 0, 0, 0),
    c(10, 5, 3, 0, 0),
    c(10, 6, 4, 2, 1),
    c(10, 7, 5, 4, 3)
  )
  risk <- rPVA:::build_extinction_timing_data(synthetic_risk_output(totals))

  expect_equal(risk$cumulative$Year, 0:4)
  expect_equal(risk$cumulative$Probability, c(0, 0, 0.25, 0.5, 0.5))
  expect_equal(risk$first_extinction_year, c(2L, 3L, NA_integer_, NA_integer_))
  expect_equal(risk$extinct_reps, 2L)
  expect_equal(risk$total_reps, 4L)
  expect_equal(risk$median_extinction_year, 3)
})
test_that("extinction median is absent below fifty percent risk", {
  totals <- cbind(
    c(10, 8, 0, 0),
    c(10, 7, 4, 2),
    c(10, 9, 6, 3),
    c(10, 8, 5, 1)
  )
  risk <- rPVA:::build_extinction_timing_data(synthetic_risk_output(totals))

  expect_equal(risk$extinct_reps, 1L)
  expect_true(is.na(risk$median_extinction_year))
})

test_that("quasi-extinction risk is the probability of ever crossing each threshold", {
  totals <- cbind(
    c(10, 8, 0, 0, 0),
    c(10, 5, 3, 0, 0),
    c(10, 6, 4, 2, 1),
    c(10, 7, 5, 4, 3)
  )
  out <- synthetic_risk_output(totals, K = 10)
  quasi <- rPVA:::build_quasi_extinction_plot_data(out, K = 10)

  expect_equal(quasi$Threshold, 0:5)
  expect_equal(quasi$Probability, c(0.5, 0.75, 0.75, 1, 1, 1))
  expect_equal(quasi$Probability[[1]], tail(out$ext_prob, 1))
  expect_true(all(diff(quasi$Probability) >= 0))
  expect_error(
    rPVA:::build_quasi_extinction_plot_data(out, K = NA_real_),
    "finite positive"
  )
})

test_that("risk plotting helpers return printable plot objects", {
  totals <- cbind(
    c(10, 8, 0, 0, 0),
    c(10, 5, 3, 0, 0),
    c(10, 6, 4, 2, 1),
    c(10, 7, 5, 4, 3)
  )
  out <- synthetic_risk_output(totals, K = 10)

  with_temp_pdf({
    expect_s3_class(rPVA:::plot_extinction_timing(out), "patchwork")
    expect_s3_class(rPVA:::plot_quasi_extinction_risk(out, K = 10), "ggplot")
  })
})
