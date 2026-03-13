context("Checkpoint 5 – catastrophe pulse")

spec_cat <- read_test_spec()
spec_cat$env_sd  <- 0
spec_cat$demo_sd <- FALSE
spec_cat$years   <- 50
spec_cat$reps    <- 100
spec_cat$n0[]    <- 50       # start well below K to isolate cat effect
spec_cat$K       <- 1e5       # disable ceiling

test_that("expected # of catastrophes ≈ freq * years", {
  set.seed(1)
  ct <- 0
  # instrument the helper directly
  for (i in seq_len(spec_cat$years)) {
    if (maybe_apply_catastrophe(spec_cat$surv, spec_cat$fecund, spec_cat)$happened)
      ct <- ct + 1
  }
  expect_equal(ct / spec_cat$years, spec_cat$cat_freq,
               tolerance = 0.05)  # 5 % relative error over 1000 draws
})

test_that("catastrophe reduces population vs control", {
  spec_no  <- spec_cat; spec_no$cat_freq <- 0
  out_no   <- run_pva_core(spec_no)
  out_cat  <- run_pva_core(spec_cat)
  expect_lt(median(out_cat$Nend), median(out_no$Nend))
})
