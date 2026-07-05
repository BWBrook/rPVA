# Runbook

## Content Path

`inst/shiny/practical1/content/pva-deep-dive.md`

Barry can edit this Markdown file to tune the `What is PVA?` modal body. If
the key teaching concepts change, update the focused Shiny test expectations in
`tests/testthat/test-13_practical1_shiny.R`.

## Validation Commands

```sh
git diff --check
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
```

The teaching API test is optional for this goal because the refactor does not
touch teaching API or export code. Run it if there is any evidence of export
shape drift.

Browser smoke should prove:

1. landing screen is visible;
2. `Explore PVA` opens the Markdown-backed modal;
3. the close action works;
4. `Start baseline` moves to Concept Lab;
5. `Introduction` returns to Start;
6. Compare/export still work after one non-baseline run.

Run marker, strict secret/private-key/token/student-identifier, and
student-facing modal content scans over changed/untracked text.
