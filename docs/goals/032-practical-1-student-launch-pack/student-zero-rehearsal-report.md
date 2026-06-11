# Goal 032 Student-Zero Rehearsal Report

## Summary

Goal 032 produced a student-facing Practical 1 launch page and a Moodle/upload
handoff manifest, then rehearsed the student path using only student-facing
instructions and a local app route.

The local student-zero path is usable for a controlled class or local/in-room
handoff. Hosted student URL release remains no-go until class hostname,
browser-trusted TLS, student access, and capacity/recovery gates are separately
green.

No app, Shiny UI/CSS/server, model, science, YAML, Practical 2, assessment,
Moodle, hosting, service, DNS, TLS, Docker, account, credential, student
workspace, dependency, KPZ314, external-service, or remote-state changes were
made.

## Starting State

- Working directory: `/Users/bwbrook/git/rPVA`
- Branch: `codex/rpva-goal032-student-launch-pack`
- Base: `d394b27 Add Practical 1 delivery-candidate rehearsal pack`
- Initial dirty state: only the untracked Goal 032 packet directory.

## Launch Materials Created

- `docs/teaching/woodhen/practical-1-student-launch-page.md`
- `docs/teaching/woodhen/practical-1-moodle-upload-manifest.md`

Narrow pointers were added to the Woodhen teaching kit, instructor guide,
day-of-class pack, and Shiny teaching README so the new launch page and manifest
are discoverable without changing the app or assessment design.

## Student-Zero Rehearsal

Student-facing instructions used:

- `docs/teaching/woodhen/practical-1-student-launch-page.md`
- `docs/teaching/woodhen/practical-1-mission-worksheet.md`

Browser automation path: Playwright/Chromium through the local Codex wrapper.

Local app command:

```sh
Rscript -e 'source("bootstrap.R"); run_practical1_shiny(host = "127.0.0.1", port = 3899, launch.browser = FALSE)'
```

Local app route: `http://127.0.0.1:3899/`

Path exercised:

1. Read the launch page and identify the approved-link, worksheet, and
   save-location instructions.
2. Open the local app route as the approved local rehearsal route.
3. Click `Start baseline` and keep the baseline as run 1.
4. Run carrying capacity.
5. Run environmental stochasticity.
6. Run catastrophe as the risk-pressure stage.
7. Run simple intervention.
8. Open Compare and inspect the comparison table.
9. Save the comparison CSV.
10. Save the evidence-notes Markdown file.
11. Inspect the worksheet evidence-recording section.
12. Reach the Transfer questions.

Screenshot evidence:

- `/tmp/rpva-goal032-student-zero/student-launch-page.png`
- `/tmp/rpva-goal032-student-zero/start-baseline.png`
- `/tmp/rpva-goal032-student-zero/concept-lab-after-runs.png`
- `/tmp/rpva-goal032-student-zero/compare-export.png`
- `/tmp/rpva-goal032-student-zero/worksheet-evidence-section.png`
- `/tmp/rpva-goal032-student-zero/transfer.png`

Downloaded evidence:

- `/tmp/rpva-goal032-student-zero/practical1-comparison-goal032.csv`
- `/tmp/rpva-goal032-student-zero/practical1-evidence-notes-goal032.md`

Observed browser console issue:

- A non-blocking `favicon.ico` 404 appeared. No app JavaScript failure was
  observed.

Shutdown:

- The Shiny process was stopped after rehearsal.
- `lsof -nP -iTCP:3899 -sTCP:LISTEN` returned no listener.

## Export Confirmation

The comparison CSV retained the accepted export shape:

```text
run_id, stage, label, scenario, years, reps, PE, Nmed, Nlo95, Nhi95,
extinct_reps, surviving_reps, trajectory_available
```

The evidence-notes Markdown retained:

- Practical 1 evidence-notes title;
- generated timestamp;
- run count;
- fixed teaching seed;
- comparison table;
- settings and provenance;
- interpretation prompts;
- evidence-not-answer framing.

## Report Scaffold Render

The launch package keeps the report scaffold available as an optional Moodle
item, so the scaffold was rendered sequentially into `/tmp/rpva-goal032-report/`.

- DOCX render: passed.
  - `/tmp/rpva-goal032-report/report-scaffold.docx`
- PDF render: passed.
  - `/tmp/rpva-goal032-report/report-scaffold.pdf`

## Validation

- `git diff --check`: passed.
- `Rscript -e 'source("bootstrap.R")'`: passed.
- `Rscript -e 'renv::status(sources = FALSE)'`: passed with no issues.
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'`:
  passed.
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'`:
  passed.
- Sequential report scaffold render to DOCX and PDF: passed.
- Marker scan over changed/untracked text: hits were restricted to Goal 032
  packet wording about the app-route stand-in/policy; no unresolved launch
  content marker was present in the student launch page, Moodle manifest, or
  rehearsal report.
- Secret/private-key scan over changed/untracked text: hits were reviewed as
  policy wording, scan-command text, class-account/token boundary wording,
  credential/private-key safety wording, or route-governance wording only; no
  secret values, private keys, student identifiers, or sensitive service
  payloads were present.
- Stricter assignment/private-key-block scan: no hits.
- Raw-IP/insecure-route wording scan: hits were restricted to the Goal 032
  packet, instructor/manifest no-go wording, and the rehearsal report's
  boundary judgement. The student launch page and worksheet do not direct
  students to use a raw-IP or browser-warning HTTPS route as release-ready.

## Readiness Judgement

Student launch package readiness: green for orchestrator review as a Moodle or
local-handoff content package.

Local/in-room route readiness: green only when the day-of-class local or class
route go/no-go check is green.

Hosted student URL release readiness: no-go. The launch pack intentionally
requires an approved app route and does not publish the current raw-IP or
browser-warning HTTPS route as a student path.

## Recommended Next Gate

Review the student launch page, Moodle manifest, and student-zero rehearsal
evidence. If accepted, a separate closeout goal can commit/publish the Goal 032
docs. Hosted student URL release should remain a separate infrastructure gate.
