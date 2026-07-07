# Runbook

## Local validation

```sh
git diff --check
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-14_practical2_woodhen_api.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-15_practical2_shiny.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter = "summary")'
quarto render docs/teaching/woodhen/report-scaffold.qmd --to docx --output-dir /tmp/rpva-goal049-report
quarto render docs/teaching/woodhen/report-scaffold.qmd --to pdf --output-dir /tmp/rpva-goal049-report
```

## Browser proof

- Launch Practical 1 locally and exercise landing, modal, baseline, mission run,
  compare, exports, and transfer.
- Launch Practical 2 locally and exercise overview, core scenarios, sensitivity,
  exports, and report bridge.
- Stop all Shiny processes and confirm the local ports are closed.

## Safety scans

- Marker scan over changed text.
- Strict secret/private-key/token/student-identifier scan.
- Student-facing leak scan for deployment/internal wording.
- Scenario-surface scan confirming Practical 2 app uses bounded choices rather
  than open YAML or freeform parameter editing.
