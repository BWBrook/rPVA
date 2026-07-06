# Goal 048 Modal Prose Publish Report

## Summary

Goal 048 publishes Barry-authored prose edits to the three Practical 1 landing modal Markdown files. The edits are preserved as authored, with one narrow focused-test update so the test suite tracks durable teaching concepts rather than the previous exact phrase.

## Barry-authored Files

- `inst/shiny/practical1/content/pva-deep-dive.md`
- `inst/shiny/practical1/content/mission-deep-dive.md`
- `inst/shiny/practical1/content/evidence-deep-dive.md`

## Harness Update

`tests/testthat/test-13_practical1_shiny.R` now checks the revised evidence concepts:

- `support your explanation`
- `trade-offs`

The modal wiring and Markdown-backed content checks remain unchanged.

## Prose Rule For Future Notes

Future teaching notes should prefer direct positive statements and instructions. Avoid contrastive negation patterns such as `not X, but Y`, `not this, it is that`, or journalistic contrast pivots.

## Validation

Validation passed:

- `git diff --check`
- `Rscript -e 'source("bootstrap.R")'`
- `Rscript -e 'renv::status(sources = FALSE)'`
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'`
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'`
- `Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter = "summary")'`

Scans passed:

- Marker scan over changed text had no hits.
- Strict safety scan over changed text had no hits.
- Student-facing Markdown content scan had no thylacine, Woodhen case-study, internal workflow, or deployment wording hits.

The optional browser smoke was skipped because this goal changed only Markdown prose plus one concept-based test expectation. Goal 047 proved the modal wiring, and the focused Shiny test still covers all modal triggers and content files.
