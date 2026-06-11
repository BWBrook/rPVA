# Practical 1 Moodle Upload Manifest

Use this manifest to assemble the Practical 1 Moodle section or a local
teaching handoff folder. It is for Barry or demonstrators, not a student
worksheet.

## Student-Visible Items

Make these visible to students at the start of Practical 1:

| Moodle item | Source file | Suggested label |
| --- | --- | --- |
| Launch instructions | `practical-1-student-launch-page.md` | Start here: Practical 1 PVA mission |
| Mission worksheet | `practical-1-mission-worksheet.md` | Practical 1 mission worksheet |
| Approved app link | day-of-class route supplied after go/no-go check | Practical 1 app |
| Evidence reminder | launch page section "Before You Leave" | What to save before you leave |

If a report scaffold is needed during the same class, provide the rendered DOCX
or the source scaffold only after confirming the local render path:

- `report-scaffold.qmd`;
- `report-scaffold.docx` rendered from the current repo state.

## Instructor-Only Items

Keep these hidden from students unless a demonstrator needs them during class:

| Moodle or handoff item | Source file | Use |
| --- | --- | --- |
| Day-of-class pack | `practical-1-day-of-class-pack.md` | Instructor timing, setup, and fallback switch rule |
| Go/no-go checklist | `practical-1-go-no-go-checklist.md` | Local readiness and hosted-release gate |
| Instructor beat sheet | `practical-1-instructor-beat-sheet.md` | Recaps, roaming prompts, compression options |
| Fallback pack | `practical-1-fallback-pack.md` | Static recovery path if app access or downloads fail |
| Troubleshooting guide | `troubleshooting.md` | Bootstrap, render, and interpretation issue support |
| Expected outputs | `expected-outputs.md` | Reference tables for demonstrators |

## Suggested Moodle Section Order

1. Label: "Practical 1: PVA mission"
2. Page or file: `practical-1-student-launch-page.md`
3. File: `practical-1-mission-worksheet.md`
4. URL: approved Practical 1 app route, added only after the day-of-class
   hosted or local go/no-go check is green
5. Optional file: rendered report scaffold, if Barry wants students to start
   report writing in the same session
6. Hidden demonstrator folder with instructor-only items

## App Link Policy

Do not publish a raw-IP, insecure HTTPS, browser-warning, or "not secure" route
as the student app link.

The student-visible link should be one of:

- a class-approved hosted app route that has passed the hosted URL/TLS/student
  release go/no-go check;
- a local or in-room route supplied by the demonstrator for that session;
- no app link, with the class directed to fallback evidence capture.

The launch page deliberately says "approved Practical 1 app link" rather than
naming infrastructure. Add the live link in Moodle only when the relevant
go/no-go checklist is green.

## Day-After Records

Keep day-after records outside the repo if they contain student identifiers.
Record only non-identifying teaching notes in future repo updates, such as:

- route used: hosted app, local app, instructor demo, or fallback;
- whether students saved both evidence files;
- repeated confusion in the worksheet or launch instructions;
- app access, download, report-render, or hosted-route blockers.

Do not paste student names, usernames, grades, credentials, service logs, or
private service details into repo files or chat.
