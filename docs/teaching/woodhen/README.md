# Woodhen Teaching Kit

This folder contains the first teaching-focused teaching kit for the `rPVA` road
test, built as two three-hour practicals for third-year students with no prior
PVA background.

Target students: ecology, conservation, or applied modelling classes.

## Contents

- `practical-1-pva-foundations.md`
- `practical-1-student-launch-page.md`
- `practical-1-mission-worksheet.md`
- `practical-1-moodle-upload-manifest.md`
- `practical-1-moodle-ready-bundle/`
- `practical-1-barry-roleplay-script.md`
- `practical-1-barry-roleplay-session-brief.md`
- `practical-1-roleplay-notes-template.md`
- `practical-1-roleplay-go-no-go.md`
- `practical-1-dual-route-roleplay-runbook.md`
- `practical-1-roleplay-feedback-return-template.md`
- `practical-1-dual-route-go-no-go.md`
- `practical-1-instructor-beat-sheet.md`
- `practical-1-day-of-class-pack.md`
- `practical-1-go-no-go-checklist.md`
- `practical-2-student-launch-page.md`
- `practical-2-woodhen-management.md`
- `instructor-guide.md`
- `expected-outputs.md`
- `glossary.md`
- `troubleshooting.md`
- `practical-1-fallback-pack.md`
- `report-scaffold.qmd`
- `marking-rubric.md`
- `classroom-dry-run-checklist.md`
- `assessment-brief-2026-draft.md`
- `marking-rubric-2026-draft.md`
- `feedback-template-2026-draft.md`
- `assessment-design-crosswalk-2026.md`

## Quick start for students

Run from the repo root in R:

```r
source("bootstrap.R")
```

To render the assessment scaffold from the repo root, use a temp folder for classroom
output hygiene:

```sh
quarto render docs/teaching/woodhen/report-scaffold.qmd \
  --to docx --output-dir /tmp/rpva-teaching-report
quarto render docs/teaching/woodhen/report-scaffold.qmd \
  --to pdf --output-dir /tmp/rpva-teaching-report
```

You can run either format at a time if your machine is missing a local PDF
dependency; this is common in first-run Mac setups.

Each practical is designed to be run independently, but best delivered in this
order:

1. `practical-1-pva-foundations.md`
2. `practical-2-student-launch-page.md`
3. `practical-2-woodhen-management.md`

For each worksheet:

- Run the listed code blocks exactly as shown.
- Fill response boxes.
- Save all R outputs for your short report.

For demonstrators, use `classroom-dry-run-checklist.md` before class and at the
end of each practical to confirm that the expected tables, plots, and report
render path are still working.

If hosted or local Shiny is unavailable, use `practical-1-fallback-pack.md` to
continue Practical 1 with command-line toy-model outputs, static reference
tables, and report-scaffold rendering.

For the app-led Practical 1 path, use `practical-1-student-launch-page.md` as
the student entry surface and `practical-1-mission-worksheet.md` as the student
observation log. Use `practical-1-moodle-ready-bundle/` for the compact Moodle
handoff surface and generated-artefact manifest, with
`practical-1-moodle-upload-manifest.md` as the higher-level upload policy. Use
`practical-1-instructor-beat-sheet.md` for timing, recaps, roaming prompts, and
wrap-up. The detailed Shiny mission arc lives in
`../shiny/practical-1-mission-tutorial.md`. On the day of class, use
`practical-1-day-of-class-pack.md` and `practical-1-go-no-go-checklist.md` to
separate local teaching readiness from hosted URL/TLS/student-release
readiness. Before asking Barry to roleplay a Practical 1 student, use
`practical-1-barry-roleplay-session-brief.md`,
`practical-1-dual-route-roleplay-runbook.md`,
`practical-1-barry-roleplay-script.md`,
`practical-1-roleplay-notes-template.md`,
`practical-1-roleplay-feedback-return-template.md`,
`practical-1-roleplay-go-no-go.md`, and
`practical-1-dual-route-go-no-go.md`.

Draft 2026 AT1 assessment materials are provided as review documents in this
folder. The student-facing starting point is `assessment-brief-2026-draft.md`;
the instructor-facing rationale is `assessment-design-crosswalk-2026.md`.
The report scaffold is `report-scaffold.qmd` and now uses the Practical 2
Woodhen teaching API directly.

## Teaching outcomes

After these two practicals, students should be able to:

- explain the core PVA mechanics (growth, stochasticity, density limits, extinction),
- run the toy model and interpret its outputs,
- run and compare Woodhen scenarios in the Practical 2 app or R scaffold,
- run a bounded one-factor sensitivity exercise,
- produce a short assessment-style interpretation with uncertainty and management
  implications.

## What is in scope

- Student-facing worksheets and assessment scaffolds.
- Practical 1 and Practical 2 Shiny teaching surfaces.
- Instructor guidance.
- Terminology support and troubleshooting.
- Expected reference outputs.

## What is explicitly out of scope

- scenario/YAML edits,
- dependency/CI adjustments,
- remote deployment, Moodle release, and ITS production operations.
