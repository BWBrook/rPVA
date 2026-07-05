# Goal 047 Landing Card Modals Report

## Summary

Goal 047 extends the Goal 046 Markdown-backed modal pattern from the `What is PVA?` landing card to the other two landing cards. The app now offers three small, visible deep-dive buttons:

- `Explore PVA`
- `Explore mission`
- `Explore evidence`

The student-facing modal bodies live in app-local Markdown files under `inst/shiny/practical1/content/`.

## Preserved User Edit

Barry's pre-existing edit to `inst/shiny/practical1/content/pva-deep-dive.md` was preserved unchanged. The edit clarifies:

- comparisons should explain which input value or assumption changed;
- extinction risk is about simulated future population sizes reaching zero;
- students should be clear about model assumptions.

## New Editable Content

- `inst/shiny/practical1/content/mission-deep-dive.md`
  - Practical 1 as a guided concept lab.
  - Baseline as run 1.
  - Change one factor at a time.
  - Use Compare to interpret what moved.

- `inst/shiny/practical1/content/evidence-deep-dive.md`
  - Comparison CSV.
  - Evidence-notes Markdown.
  - One-sentence interpretation.
  - Evidence supports explanation but is not the answer by itself.

The new text synthesizes the Practical 1 design brief and mission/tutorial materials. It avoids thylacine content and Woodhen case-study detail so the landing modals stay focused on transferable Practical 1 PVA habits.

## Implementation Notes

- `app.R` now defines `deep_dive_modal_ui(title, path)` and small wrappers for each landing-card modal.
- Modal text continues to render through the existing `commonmark`-based helper with a polite in-modal fallback.
- The two new card buttons are ordinary Shiny `actionButton()` controls with accessible labels.
- The existing Start baseline route and export handlers were not changed.

## Validation

Validation passed:

- `git diff --check`
- `Rscript -e 'source("bootstrap.R")'`
- `Rscript -e 'renv::status(sources = FALSE)'`
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'`
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'`

The focused Shiny test was updated first and failed in the expected places before implementation: missing mission/evidence Markdown files, paths, triggers, and modal wrappers. It now passes.

## Browser Smoke

Local smoke used the app at `http://127.0.0.1:3915` and saved evidence under `/tmp/rpva-goal047-landing-card-modals/`.

Screenshots:

- `/tmp/rpva-goal047-landing-card-modals/landing-screen.png`
- `/tmp/rpva-goal047-landing-card-modals/pva-modal-panel.png`
- `/tmp/rpva-goal047-landing-card-modals/mission-modal-panel.png`
- `/tmp/rpva-goal047-landing-card-modals/evidence-modal-panel.png`
- `/tmp/rpva-goal047-landing-card-modals/post-start-baseline.png`
- `/tmp/rpva-goal047-landing-card-modals/compare-after-run.png`

Downloads:

- `/tmp/rpva-goal047-landing-card-modals/practical1-comparison-20260705.csv`
- `/tmp/rpva-goal047-landing-card-modals/practical1-evidence-notes-20260705.md`

Smoke result:

- Landing screen visible.
- PVA, mission, and evidence modals opened, contained expected concepts, and closed.
- `Start baseline` moved to Concept Lab with baseline as run 1.
- `Introduction` returned to Start.
- A carrying-capacity run was added after the baseline.
- Compare and export controls worked.
- Comparison CSV retained baseline as run 1 and carrying capacity as run 2.
- Evidence-notes Markdown retained the accepted title, comparison table, settings/provenance, and interpretation prompt sections.

Selected checksums:

```text
f8c833d36f069284ba0c56e29d43cbfdcc5d99186cc7784f9c900021b662a07d  landing-screen.png
ca1dbd4352cdca53ebe54689214ee2e22050dee5c6867a7c3acdce8466261471  pva-modal-panel.png
829af4092052a2c111fec5fa102f8d5ba15a4ad32bb37b0c41f4fdcea9da789a  mission-modal-panel.png
fbf27137a42da00102951ad0c921f6da3a8a823d4b5f7c3c495c3132a5026d96  evidence-modal-panel.png
7895f193406701cb1353552bf6b8321bc3f35359234ac92b4d0ee44174e22422  practical1-comparison-20260705.csv
43b938461a076161c4bbabe39f342d7cd75a58ce7370ba57ccb4a6e1cc46209d  practical1-evidence-notes-20260705.md
```

## Scans

- Marker scan over changed/untracked text had no hits.
- Strict safety scan over changed/untracked text hit only the scan-name wording in `Runbook.md` and this report; no real values, keys, or student identifiers.
- Student-facing Markdown content scan over `inst/shiny/practical1/content/*.md` had no thylacine, Woodhen case-study, internal workflow, or deployment wording hits.

## Recommendation

This is ready for Barry to edit all three landing-panel modal texts as Markdown and retest locally.
