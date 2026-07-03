# Log

## 2026-07-03

### Start Guard

- `pwd`: `/Users/bwbrook/git/rPVA`.
- Initial branch: `codex/rpva-goal043-its-validation-canonicalization`.
- Initial HEAD: `1a1f44e7942274b630cbb6ad76a906489f88016f`
  (`Record ITS dev prod validation canonicalization`).
- Start status: clean and aligned with `origin/main`.
- Fetched/pruned origin; `origin/main` remained
  `1a1f44e7942274b630cbb6ad76a906489f88016f`.
- Created branch:
  `codex/rpva-goal044-practical1-landing-tutorial`.

### Implementation Notes

- Added a Practical 1 landing/tutorial screen ahead of the Concept Lab control
  workflow.
- Preserved the existing `run_baseline` action path so `Start baseline`
  creates or restores baseline as run 1 and moves students into Concept Lab.
- Added an `Introduction` control in Concept Lab to return to the landing
  screen.
- Added three local generated bitmap assets under
  `inst/shiny/practical1/www/img/`.
- Updated focused Shiny structural tests for the landing screen, assets, and
  responsive styling.

### Validation

- Initial red test run of
  `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'`
  failed on the missing landing screen, missing assets, and missing styles.
- Focused Shiny test after implementation: passed.
- `git diff --check`: passed.
- `Rscript -e 'source("bootstrap.R")'`: passed.
- `Rscript -e 'renv::status(sources = FALSE)'`: passed.
- Focused teaching API test:
  `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'`:
  passed.
- Focused Practical 1 Shiny test:
  `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'`:
  passed.
- Browser smoke:
  - In-app Browser setup succeeded, but its DOM snapshot path failed with
    `TypeError: o.incrementalAriaSnapshot is not a function`; used local Google
    Chrome through Playwright instead.
  - Local app URL: `http://127.0.0.1:3907`.
  - Evidence directory: `/tmp/rpva-goal044-landing-tutorial/`.
  - Flow passed: landing visible, all three images loaded with alt text, Start
    baseline entered Concept Lab with baseline/current run as run 1, carrying
    capacity run completed, Compare table showed two rows, CSV and evidence
    notes downloaded with accepted shape, Transfer opened.
  - Screenshots:
    - `/tmp/rpva-goal044-landing-tutorial/landing-screen.png`;
    - `/tmp/rpva-goal044-landing-tutorial/post-start-baseline.png`;
    - `/tmp/rpva-goal044-landing-tutorial/compare-export-controls.png`;
    - `/tmp/rpva-goal044-landing-tutorial/transfer-screen.png`.
  - Download evidence:
    - `/tmp/rpva-goal044-landing-tutorial/practical1-comparison-smoke.csv`;
    - `/tmp/rpva-goal044-landing-tutorial/practical1-evidence-notes-smoke.md`.
  - Console classification: one 404 from `/favicon.ico`; no app-flow failure.
- Marker scan over changed text: clean.
- Strict secret/private-key/token assignment and key-block scan over changed
  text: clean.
- Broader sensitive-term scan found only policy/boundary wording for
  credentials/token/student-id scanning; no secret values, tokens, private
  keys, student identifiers, or sensitive service payloads.
- Student-facing duplicate-baseline wording search over `inst/shiny/practical1`
  and `docs/teaching`: clean.

### Recommendation

Ready for orchestrator review and Barry's next incremental local test of the
opening experience. Leave uncommitted until accepted.
