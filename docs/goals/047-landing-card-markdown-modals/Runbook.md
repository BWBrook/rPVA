# Runbook

Run from `/Users/bwbrook/git/rPVA`.

## Validation Gates

```sh
git status --short --branch
git diff --check
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'
```

## Browser Smoke

Use a local-only port that does not disturb any existing review app.

Required path:

1. Landing screen visible.
2. PVA modal opens and closes.
3. Mission modal opens and closes.
4. Evidence modal opens and closes.
5. `Start baseline` moves to Concept Lab with baseline as run 1.
6. `Introduction` returns to Start.
7. At least one Concept Lab run can be added.
8. Compare/export controls produce the accepted CSV and evidence-notes Markdown shapes.

Screenshots and downloads should be saved outside the repo, under `/tmp/rpva-goal047-landing-card-modals/`.

## Scans

- Marker scan over changed/untracked text.
- Strict secret/private-key/token/student-id scan over changed/untracked text.
- Student-facing Markdown content scan for thylacine, Woodhen case-study, internal workflow, and deployment wording.
