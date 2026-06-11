# Practical 1 Moodle-Ready Bundle Manifest

This manifest lists the files and generated artefacts for a compact Practical 1
Moodle handoff. It is for Barry or demonstrators assembling Moodle, not a
student worksheet.

## Student-Visible Moodle Items

| Moodle item | Source path | Suggested label | Visibility | Notes |
| --- | --- | --- | --- | --- |
| Section text | `docs/teaching/woodhen/practical-1-moodle-ready-bundle/moodle-section-text.md` | Practical 1: PVA mission | Student-visible | Paste into the Moodle section or top label. |
| Launch page | `docs/teaching/woodhen/practical-1-student-launch-page.md` | Start here: Practical 1 PVA mission | Student-visible | Source of truth for start-here instructions. |
| Mission worksheet | `docs/teaching/woodhen/practical-1-mission-worksheet.md` | Practical 1 mission worksheet | Student-visible | Upload Markdown or regenerated DOCX. |
| App link | day-of-class approved route | Practical 1 app | Student-visible only after route gate | Add only after the local or hosted go/no-go check is green. |
| Optional report scaffold | `docs/teaching/woodhen/report-scaffold.qmd` | Practical report scaffold | Student-visible only if planned | Upload regenerated DOCX/PDF only if report-writing starts in class. |

## Instructor-Only Items

| Handoff item | Source path | Suggested label | Visibility | Notes |
| --- | --- | --- | --- | --- |
| Day-of-class pack | `docs/teaching/woodhen/practical-1-day-of-class-pack.md` | Practical 1 day-of-class pack | Hidden | Timing, setup, fallback switch rule. |
| Go/no-go checklist | `docs/teaching/woodhen/practical-1-go-no-go-checklist.md` | Practical 1 go/no-go checklist | Hidden | Separates local readiness from hosted release. |
| Fallback pack | `docs/teaching/woodhen/practical-1-fallback-pack.md` | Practical 1 fallback pack | Hidden | Static recovery path. |
| Troubleshooting | `docs/teaching/woodhen/troubleshooting.md` | Practical 1 troubleshooting | Hidden | Bootstrap, rendering, and interpretation support. |
| Expected outputs | `docs/teaching/woodhen/expected-outputs.md` | Practical 1 expected outputs | Hidden | Demonstrator reference values. |
| Moodle upload manifest | `docs/teaching/woodhen/practical-1-moodle-upload-manifest.md` | Practical 1 Moodle upload manifest | Hidden | Higher-level upload policy from Goal 032. |

## Generated Artefacts

Generated files were rendered under `/tmp` and are intentionally not committed.
They are small and useful as Moodle attachments, but the source Markdown/QMD
files remain the repo source of truth.

| Artefact | Source | Output path | Command | Size | SHA-256 | Check |
| --- | --- | --- | --- | ---: | --- | --- |
| Mission worksheet DOCX | `docs/teaching/woodhen/practical-1-mission-worksheet.md` | `/tmp/rpva-goal033-rendered/practical-1-mission-worksheet.docx` | `pandoc docs/teaching/woodhen/practical-1-mission-worksheet.md -o /tmp/rpva-goal033-rendered/practical-1-mission-worksheet.docx` | 13,023 bytes | `a3377360d81cde61502f4081f4e5a03c464f122842f6fc8e05776479dce113d9` | Word archive OK. |
| Student launch page DOCX | `docs/teaching/woodhen/practical-1-student-launch-page.md` | `/tmp/rpva-goal033-rendered/practical-1-student-launch-page.docx` | `pandoc docs/teaching/woodhen/practical-1-student-launch-page.md -o /tmp/rpva-goal033-rendered/practical-1-student-launch-page.docx` | 12,229 bytes | `dc18585e2880bc73bf2e29c565281d70f4ec56e1886969ef1f009c3fa521f435` | Word archive OK. |
| Report scaffold DOCX | `docs/teaching/woodhen/report-scaffold.qmd` | `/tmp/rpva-goal033-report/report-scaffold.docx` | `quarto render docs/teaching/woodhen/report-scaffold.qmd --to docx --output-dir /tmp/rpva-goal033-report` | 407,891 bytes | `f5d5e377a9ac0d2740c4a8ed526050339a11f7dbdca0b5a7e7f3acdbbc3c68ab` | Word archive OK. |
| Report scaffold PDF | `docs/teaching/woodhen/report-scaffold.qmd` | `/tmp/rpva-goal033-report/report-scaffold.pdf` | `quarto render docs/teaching/woodhen/report-scaffold.qmd --to pdf --output-dir /tmp/rpva-goal033-report` | 87,402 bytes | `1ceb7cd7ae3ec742b605b433654ef915673d4108951a008fdf4711b659c118db` | `pdfinfo`: 8 pages, letter, not encrypted, no JavaScript. |

PDF first-page visual evidence:
`/tmp/rpva-goal033-pdf-pages/report-scaffold-1.png`.

## Regeneration Commands

Run from the repo root:

```sh
mkdir -p /tmp/rpva-goal033-rendered /tmp/rpva-goal033-report
pandoc docs/teaching/woodhen/practical-1-mission-worksheet.md -o /tmp/rpva-goal033-rendered/practical-1-mission-worksheet.docx
pandoc docs/teaching/woodhen/practical-1-student-launch-page.md -o /tmp/rpva-goal033-rendered/practical-1-student-launch-page.docx
quarto render docs/teaching/woodhen/report-scaffold.qmd --to docx --output-dir /tmp/rpva-goal033-report
quarto render docs/teaching/woodhen/report-scaffold.qmd --to pdf --output-dir /tmp/rpva-goal033-report
```

Render the report scaffold DOCX and PDF sequentially.

## Route Gate Notes

- The student app link must be the approved Practical 1 route for the class
  session.
- Do not publish the current raw-IP, insecure HTTPS, browser-warning, or "not
  secure" route as a student-ready Moodle link.
- If no approved route is available, omit the app link and use fallback
  evidence capture or a local instructor-led session.
- Hosted student URL release remains no-go until hostname, browser-trusted TLS,
  access model, capacity, and recovery checks are separately green.

## Bridge To Barry-As-Student Roleplay

The next checkpoint can roleplay a student using:

1. `moodle-section-text.md` or the launch page as the start surface.
2. `../practical-1-mission-worksheet.md` for notes.
3. An approved local or class app route supplied for that session.
4. A local `practical-1-evidence` folder for the comparison CSV and
   evidence-notes Markdown.

Recommended note-capture fields for the roleplay:

| Field | Note |
| --- | --- |
| Start-here clarity |  |
| App route used |  |
| Mission that first caused hesitation |  |
| Evidence export success |  |
| Worksheet wording friction |  |
| Hosted-route or Moodle packaging issue |  |
