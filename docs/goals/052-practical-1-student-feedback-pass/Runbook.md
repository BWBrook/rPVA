# Runbook

Local validation commands used for this pass:

```bash
git diff --check
Rscript -e 'source("bootstrap.R"); renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-11_pva_helpers.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); run_practical1_shiny(host = "127.0.0.1", port = 3920, launch.browser = FALSE)'
```

Browser evidence was captured under `/tmp/rpva-goal052-feedback-pass/`.
