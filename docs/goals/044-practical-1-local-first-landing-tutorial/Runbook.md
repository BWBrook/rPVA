# Runbook

## Local Validation

```sh
git diff --check
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
```

## Browser Smoke

Run the app locally only:

```sh
Rscript -e 'source("bootstrap.R"); run_practical1_shiny(host = "127.0.0.1", port = 3902, launch.browser = FALSE)'
```

Smoke path:

1. Landing screen is visible and images load.
2. Click `Start baseline`.
3. Confirm Concept Lab opens with baseline/current run visible as run 1.
4. Run at least one non-baseline Concept Lab stage.
5. Open Compare, confirm baseline plus new run are present, and download the
   comparison CSV and evidence notes Markdown.
6. Open Transfer.
7. Save screenshots under `/tmp/rpva-goal044-landing-tutorial/`.

## Boundary

Do not build or push images, access ITS/Gitea/VM/dev/prod hosts, change live
service state, alter science/defaults/export shape, or publish this branch.
