read_test_spec <- function() {
  read_spec(system.file("testdata", "test_01.yaml", package = "rPVA"))
}

read_toy_spec <- function() {
  read_spec(system.file("extdata", "toy", "toy_demo.yaml", package = "rPVA"))
}

repo_root <- function() {
  normalizePath(file.path("..", ".."), winslash = "/", mustWork = TRUE)
}

with_temp_pdf <- function(code) {
  pdf_file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf_file)
  on.exit({
    grDevices::dev.off()
    unlink(pdf_file)
  }, add = TRUE)
  force(code)
}

expect_no_local_artifacts <- function() {
  testthat::expect_false(file.exists("Rplots.pdf"))
  testthat::expect_false(file.exists("scenario_raw.rds"))
  testthat::expect_false(file.exists("scenario_summary.csv"))
}
