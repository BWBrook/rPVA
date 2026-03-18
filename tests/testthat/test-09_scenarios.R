context("Checkpoint 9 – scenario layer")

test_that("wrapper finds and summarises the five core scenarios", {
  tbl <- run_scenarios("woodhen",
                       csv_out   = NULL,
                       rds_out   = NULL,
                       parallel  = FALSE)
  expect_equal(nrow(tbl), 5)               # 01..04 + 05 baseline
  expect_true(all(c("scenario", "PE", "Nmed") %in% names(tbl)))
})
