context("Checkpoint 9 – scenario layer")

test_that("wrapper finds and summarises the five core scenarios", {
  tbl <- run_scenarios("woodhen")
  expect_equal(tbl$scenario, c(
    "woodhen_no_intervention",
    "woodhen_pig_control",
    "woodhen_captive_pig",
    "woodhen_rat_eradication",
    "woodhen_future_baseline"
  ))
  expect_equal(tbl$PE, c(0.666, 0.566, 0.082, 0, 0))
  expect_equal(tbl$Nmed, c(16, 57, 119, 832, 1510))
  expect_no_local_artifacts()
})
