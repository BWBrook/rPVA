synthetic_breeding_pair_result <- function(holder_trajectories,
                                           floater_trajectories = NULL,
                                           additional_holders = NULL) {
  holder_trajectories <- as.matrix(holder_trajectories)
  n_years <- nrow(holder_trajectories)
  n_reps <- ncol(holder_trajectories)

  if (is.null(floater_trajectories)) {
    floater_trajectories <- matrix(0, nrow = n_years, ncol = n_reps)
  }
  if (is.null(additional_holders)) {
    additional_holders <- matrix(0, nrow = n_years, ncol = n_reps)
  }

  traj <- array(
    0,
    dim = c(n_years, 3L, n_reps),
    dimnames = list(
      time = seq_len(n_years) - 1L,
      stage = paste0("stage", 1:3),
      rep = NULL
    )
  )
  traj[, 1L, ] <- as.matrix(floater_trajectories)
  traj[, 2L, ] <- holder_trajectories
  traj[, 3L, ] <- as.matrix(additional_holders)

  list(
    traj = traj,
    raw = list(traj = traj),
    params = list(years = n_years - 1L, reps = n_reps)
  )
}

crossing_fraction_result <- function(crossed_reps, total_reps = 1000L) {
  holders <- matrix(60, nrow = 3L, ncol = total_reps)
  if (crossed_reps > 0L) {
    holders[2L, seq_len(crossed_reps)] <- 49
  }
  synthetic_breeding_pair_result(holders)
}

test_that("breeding-pair trajectories exclude floaters and sum holder stages", {
  stage_2 <- matrix(c(30, 29, 28, 40, 39, 38), nrow = 3L)
  stage_3 <- matrix(c(20, 20, 20, 10, 10, 10), nrow = 3L)
  floaters <- matrix(c(0, 1000, 0, 500, 500, 500), nrow = 3L)
  result <- synthetic_breeding_pair_result(stage_2, floaters, stage_3)

  pairs <- breeding_pair_trajectories(result)

  expect_equal(pairs, stage_2 + stage_3)
  expect_equal(breeding_pair_trajectories(result, holder_stages = 3L), stage_3)
})

test_that("quasi-extinction means strictly fewer than 50 breeding pairs", {
  holders <- cbind(
    c(50, 49, 48, 60),
    c(60, 49, 60, 40),
    c(50, 50, 50, 50)
  )
  floaters <- matrix(1000, nrow = nrow(holders), ncol = ncol(holders))

  evidence <- summarize_quasi_extinction(
    synthetic_breeding_pair_result(holders, floaters),
    threshold_pairs = 50L
  )

  expect_equal(evidence$threshold_pairs, 50L)
  expect_equal(evidence$holder_stages, 2:3)
  expect_equal(evidence$total_reps, 3L)
  expect_equal(evidence$crossed_reps, 2L)
  expect_equal(evidence$probability_by_horizon, 2 / 3)
  expect_equal(evidence$first_crossing_year, c(1L, 1L, NA_integer_))
  expect_equal(evidence$cumulative$year, 0:3)
  expect_equal(evidence$cumulative$probability, c(0, 2 / 3, 2 / 3, 2 / 3))
})

test_that("crossing probability and medians handle exact censoring boundaries", {
  cases <- data.frame(
    crossed_reps = c(0L, 499L, 500L, 1000L),
    probability = c(0, 0.499, 0.5, 1),
    conditional_median = c(NA, 1, 1, 1),
    overall_median = c(NA, NA, 1, 1)
  )

  for (i in seq_len(nrow(cases))) {
    evidence <- summarize_quasi_extinction(
      crossing_fraction_result(cases$crossed_reps[[i]])
    )

    expect_equal(evidence$total_reps, 1000L)
    expect_equal(evidence$crossed_reps, cases$crossed_reps[[i]])
    expect_equal(evidence$probability_by_horizon, cases$probability[[i]])
    expect_equal(evidence$conditional_median_year, cases$conditional_median[[i]])
    expect_equal(evidence$overall_median_year, cases$overall_median[[i]])
  }
})

test_that("conditional and overall medians answer different timing questions", {
  holders <- cbind(
    c(60, 49, 60, 60),
    c(60, 60, 60, 49),
    c(60, 60, 60, 60),
    c(60, 60, 60, 60)
  )

  evidence <- summarize_quasi_extinction(synthetic_breeding_pair_result(holders))

  expect_equal(evidence$conditional_median_year, 2)
  expect_equal(evidence$overall_median_year, 3)
})

test_that("quasi-extinction evidence requires valid retained trajectories", {
  expect_error(
    breeding_pair_trajectories(list(traj = NULL, raw = list(traj = NULL))),
    "keep_traj = TRUE"
  )
  expect_error(
    breeding_pair_trajectories(list(traj = matrix(1, nrow = 2L, ncol = 2L))),
    "three-dimensional"
  )

  result <- synthetic_breeding_pair_result(matrix(60, nrow = 2L, ncol = 2L))
  expect_error(breeding_pair_trajectories(result, holder_stages = 1L), "stage 1")
  expect_error(summarize_quasi_extinction(result, threshold_pairs = 0), "positive")
})

test_that("all Woodhen risk plots are truthful ggplots across crossing regimes", {
  evidence_sets <- list(
    zero = summarize_quasi_extinction(crossing_fraction_result(0L)),
    partial = summarize_quasi_extinction(crossing_fraction_result(499L)),
    high = summarize_quasi_extinction(crossing_fraction_result(1000L))
  )

  for (evidence in evidence_sets) {
    plots <- list(
      plot_woodhen_risk_over_time(evidence),
      plot_woodhen_first_passage(evidence),
      plot_woodhen_threshold_curve(evidence, max_threshold = 75L)
    )

    for (plot in plots) {
      expect_s3_class(plot, "ggplot")
      expect_gt(nrow(plot$data), 0L)
      labels <- paste(unlist(plot$labels), collapse = " ")
      expect_match(labels, "breeding pairs", ignore.case = TRUE)
      expect_match(labels, "fewer than 50", ignore.case = TRUE)
      expect_match(labels, "horizon", ignore.case = TRUE)
      expect_match(labels, "1000 futures", ignore.case = TRUE)
      expect_match(labels, "conditional", ignore.case = TRUE)
    }
  }

  zero_first_passage <- plot_woodhen_first_passage(evidence_sets$zero)
  annotations <- vapply(
    zero_first_passage$layers,
    function(layer) paste(layer$aes_params$label, collapse = ""),
    character(1)
  )
  expect_true(any(grepl("No crossings observed", annotations, fixed = TRUE)))
})
