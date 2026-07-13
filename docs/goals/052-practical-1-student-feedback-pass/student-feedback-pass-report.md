# Practical 1 Student Feedback Pass Report

## Summary

This pass addresses Barry's first two rounds of student-mode feedback on Practical 1. The Start page is now PVA-first, the main image no longer uses a species/woodhen cue, and the Concept Lab settings record now explains the selected mission in plain English against the baseline. The second revision simplifies advanced controls, adds back-navigation, removes a weak diagnostic phrase, and lets students save plot PNGs as evidence.

## Product Changes

- Start page eyebrow: `Practical 1: Learning PVA`.
- Start page title: `PVA Basics`.
- Main hero image: `inst/shiny/practical1/www/img/landing-pva-learning-futures.png`.
- `What is PVA?` card eyebrow: `Background`.
- Task text uses `.landing-task-text` at 16 px.
- Settings record columns: `Parameter`, `Baseline value`, `Selected mission value`, `What changed`, and `Meaning`.
- Environmental stochasticity default now yields a teaching signal around PE 0.30.
- Advanced controls use preset projection years: 10, 25, 50, 100, and 1000.
- Advanced controls use preset simulation futures: 10, 100, 500, and 1000.
- Advanced controls use preset mortality/fecundity changes: 20%, 10%, or 5% lower; no change; or 5%, 10%, or 20% higher.
- Concept Lab has `Previous mission`, `Run stage`, and `Next mission` controls.
- Concept Lab can save trajectory, summary, and risk-detail plots as PNG files with automatic filenames.
- Advanced projection-year and simulation-future controls use distinct internal IDs from stage-level controls, preventing duplicate Shiny input IDs while preserving `years`/`reps` API values.
- Student-facing diagnostics use British English and direct risk wording.

## Evidence

- Focused teaching API test: passed.
- Focused Practical 1 Shiny test: passed.
- Focused PVA helpers test: passed.
- `renv::status(sources = FALSE)`: passed.
- Browser smoke at `http://127.0.0.1:3920/`: passed.
- Environmental stochasticity default summary with seed 42: years 50, reps 100, PE 0.33, median final N 32, 95% interval 4-62.
- Advanced-control API proof: `years = 1000`, `reps = 1000`, `mortality_pct = 10`, and `fecundity_pct = -20` are accepted and retained in the returned teaching spec.
- Browser smoke caught and resolved two issues before handoff: reversed mortality/fecundity choice values and duplicate Shiny input IDs for `reps`.
- Final browser console had only the harmless missing `favicon.ico` entry.

Browser evidence:

- `/tmp/rpva-goal052-feedback-pass/01-landing.png`
- `/tmp/rpva-goal052-feedback-pass/03-environmental-settings-advanced.png`
- `/tmp/rpva-goal052-feedback-pass/04-environmental-run.png`
- `/tmp/rpva-goal052-feedback-pass/05-compare.png`
- `/tmp/rpva-goal052-feedback-pass/settings-table.txt`
- `/tmp/rpva-goal052-feedback-pass/second-pass/01-landing.png`
- `/tmp/rpva-goal052-feedback-pass/second-pass/02-advanced-presets.png`
- `/tmp/rpva-goal052-feedback-pass/second-pass/03-environmental-run.png`
- `/tmp/rpva-goal052-feedback-pass/second-pass/04-risk-download-ready.png`
- `/tmp/rpva-goal052-feedback-pass/second-pass/practical1-trajectory-environmental-stochasticity-20260708.png`
- `/tmp/rpva-goal052-feedback-pass/second-pass/practical1-summary-environmental-stochasticity-20260708.png`
- `/tmp/rpva-goal052-feedback-pass/second-pass/practical1-risk-catastrophe-20260708.png`

## Residual Judgement

This is ready for Barry's next incremental local test. The most useful next feedback is on Concept Lab wording, table density, whether the advanced presets feel discoverable without inviting over-tweaking, and whether PE near 0.30 feels right after a hands-on run.
