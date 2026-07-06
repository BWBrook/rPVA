# Runbook

Run from `/Users/bwbrook/git/rPVA`.

```sh
git status --short --branch
git diff --check
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter = "summary")'
```

Then run marker, strict safety, and student-facing Markdown content scans over the changed/staged text.

Publish only after `origin/main` is confirmed at the accepted base or an orchestrator-approved descendant.
