context("Checkpoint 3 – carrying capacity ceiling")

spec_K <- read_spec(system.file("extdata", "woodhen_test.yaml", 
                    package = "woodhenPVA"))
spec_K$env_sd <- spec_K$demo_sd <- 0
spec_K$years   <- 1
spec_K$reps    <- 1
spec_K$K       <- 50
spec_K$n0[]    <- 60          # start above K

test_that("ceiling scales down exactly to K in first step", {
  out <- run_pva_core(spec_K, keep_traj = TRUE)
  expect_equal(sum(out$traj[2, , 1]), spec_K$K)
})

test_that("population never exceeds K over multiple years", {
  spec_K$years <- 40
  out <- run_pva_core(spec_K)
  expect_true(all(out$Nend <= spec_K$K))
})
