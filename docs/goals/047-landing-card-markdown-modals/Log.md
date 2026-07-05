# Log

## 2026-07-05

- Confirmed repo state on `codex/rpva-goal047-landing-card-modals` at base `b9a55c194f8b15cb3c85fb4e27150f81f92ac293`.
- Recorded Barry's pre-existing local edit to `inst/shiny/practical1/content/pva-deep-dive.md` and preserved it unchanged.
- Updated the focused Practical 1 Shiny test first; the expected red run showed missing mission/evidence Markdown files and triggers.
- Added Markdown-backed modals for `What you will do` and `Your evidence pack`.
- Added:
  - `inst/shiny/practical1/content/mission-deep-dive.md`
  - `inst/shiny/practical1/content/evidence-deep-dive.md`
- Generalized the modal helper in `inst/shiny/practical1/app.R` with `deep_dive_modal_ui(title, path)`.
- Updated `inst/shiny/practical1/README.md` so Barry can find all three editable content files.
- Focused Practical 1 Shiny test now passes.
- Validation passed:
  - `git diff --check`
  - `Rscript -e 'source("bootstrap.R")'`
  - `Rscript -e 'renv::status(sources = FALSE)'`
  - focused teaching API test
  - focused Practical 1 Shiny test
- Local browser smoke passed on `http://127.0.0.1:3915` using installed Google Chrome through Playwright.
- Browser evidence saved under `/tmp/rpva-goal047-landing-card-modals/`.
- Export check confirmed comparison CSV and evidence-notes Markdown retained the accepted shape, with baseline as run 1 and a carrying-capacity run as run 2.
- Marker scan over changed/untracked text had no hits.
- Strict safety scan over changed/untracked text hit only the scan-name wording in Goal 047 docs; no real values, keys, or student identifiers.
- Student-facing Markdown content scan had no thylacine, Woodhen case-study, internal workflow, or deployment wording hits.
