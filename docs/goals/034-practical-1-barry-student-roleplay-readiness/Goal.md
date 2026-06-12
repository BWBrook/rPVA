# Goal 034: Practical 1 Barry-As-Student Roleplay Readiness Pack

## Objective

Prepare the exact staging package for Barry to roleplay a Practical 1 student.

This is the final readiness layer before the human "rubber-hits-the-road"
simulation. Barry should be able to take the roleplay pack, open the supplied
student start surface, follow the Shiny app and worksheet, save evidence, and
record observations without needing to infer setup steps from the repo.

This goal does **not** run the Barry roleplay itself.

## Context

Goals 029 to 033 established:

- the app-led Practical 1 mission tutorial and worksheet;
- mission-mode app affordances;
- day-of-class and go/no-go packs;
- a student launch page and Moodle handoff manifest;
- a Moodle-ready bundle with paste-ready section text and regeneration
  commands for generated artefacts.

The next major pedagogical checkpoint is Barry personally testing the student
experience. Before using Barry's time, the repo needs a tight roleplay script,
note-capture template, exact artefact list, and one final local rehearsal that
proves the starting materials and app path are ready for that human pass.

## Success Criteria

The goal is complete when the repo contains a compact roleplay readiness pack
that:

1. Gives Barry a one-page "student roleplay script" with exactly what to open,
   what to do, what to save, and when to take notes.
2. Provides a note-capture template for Barry's observations.
3. Provides a roleplay go/no-go checklist that separates:
   - pedagogical readiness for the human roleplay;
   - local/class route readiness;
   - hosted student URL release readiness.
4. Records a final local rehearsal of the roleplay path using the current
   student launch materials and a local app route.
5. Verifies the Moodle-ready bundle can still regenerate its useful artefacts.
6. Keeps the current raw-IP or browser-warning HTTPS route out of
   student-facing instructions.
7. States clearly whether the result is ready for the next goal: Barry performs
   the roleplay and reports notes.

## In Scope

- Review of the Goal 033 Moodle-ready bundle, Goal 032 student launch page,
  worksheet, day-of-class pack, go/no-go checklist, and current Shiny app.
- Creation of:
  - a Barry-as-student roleplay script;
  - a roleplay note-capture template;
  - a roleplay go/no-go checklist or readiness checklist;
  - a readiness report.
- Final local browser rehearsal of the student path using a local app route.
- Regeneration and verification of the useful Moodle-ready artefacts from Goal
  033, preferably under `/tmp`.
- Narrow discoverability pointers in existing teaching docs if needed.

## Out Of Scope

- Barry performing the roleplay.
- Moodle upload or any external LMS edit.
- Student contact.
- App/package code changes.
- Shiny UI/CSS/server changes.
- Science/YAML/model-default changes.
- Practical 2 mode or Woodhen management practical redesign.
- Assessment redesign or marking-rubric changes.
- KPZ314 materials or implementation.
- Hosting, ShinyProxy, nginx, systemd, firewall, DNS, TLS, Docker-service,
  account, credential, token, class-workspace, or student-release changes.
- Public or student-facing release of the current raw-IP or insecure HTTPS
  route.
- Remote infrastructure changes.
- Commit, push, merge, PR, or Goal 035 work.

## Required Deliverables

Use these paths unless a better existing naming pattern is clearly preferable:

- `docs/teaching/woodhen/practical-1-barry-roleplay-script.md`
- `docs/teaching/woodhen/practical-1-roleplay-notes-template.md`
- `docs/teaching/woodhen/practical-1-roleplay-go-no-go.md`
- `docs/goals/034-practical-1-barry-student-roleplay-readiness/roleplay-readiness-report.md`
- updates to `docs/goals/034-practical-1-barry-student-roleplay-readiness/Log.md`
- narrow pointers, if needed, in:
  - `docs/teaching/woodhen/README.md`
  - `docs/teaching/woodhen/instructor-guide.md`
  - `docs/teaching/woodhen/practical-1-moodle-ready-bundle/README.md`

## Roleplay Script Requirements

The script should be short and direct. It should tell Barry:

- what files or Moodle-style items to open;
- what app route to use, with an approved-route placeholder rather than a raw
  IP or insecure URL;
- where to create the local evidence folder;
- the minimal student path through Start, Concept Lab, Compare/export, and
  Transfer;
- where to pause and write observations;
- what evidence files should exist by the end;
- when to stop and report rather than trying to debug.

The script should assume Barry is acting as a student, not as the instructor or
developer.

## Note-Capture Template Requirements

The template should be practical for a busy human tester. Include fields for:

- start-here clarity;
- first hesitation or confusion;
- app route and login/access friction;
- mission pacing;
- Concept Lab control clarity;
- Compare/export success;
- worksheet usefulness;
- transfer-prompt clarity;
- emotional/engagement notes;
- suggested change;
- severity or priority.

Do not ask Barry for long prose in every field. The template should support
quick notes plus optional detail.

## Rehearsal Requirements

Run a final local rehearsal using the roleplay script and current launch
materials as the student-facing guide. Use a local app route unless a fully
approved class route is explicitly green in repo-local go/no-go state.

Exercise at least:

1. Open the roleplay script and launch page.
2. Create or verify the evidence-folder instruction.
3. Start baseline.
4. Run carrying capacity.
5. Run at least one stochasticity stage.
6. Run at least one risk-pressure stage.
7. Run one intervention or vortex comparison.
8. Use Compare.
9. Save comparison CSV and evidence-notes Markdown.
10. Inspect the worksheet evidence-recording section.
11. Reach Transfer.

Save screenshots and downloads outside the repo, preferably under
`/tmp/rpva-goal034-roleplay-readiness/`, and record their paths in the report.

## Validation

Run and report:

```sh
git diff --check
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
```

Regenerate useful Goal 033 artefacts under `/tmp` and verify type/size/checksum
or equivalent:

- student launch page DOCX;
- mission worksheet DOCX;
- report scaffold DOCX/PDF.

Also complete:

- marker scan over changed/new text;
- secret/private-key-pattern scan over changed/new text, with hits classified;
- stricter assignment/private-key-block scan;
- student-visible route wording check over the launch page, worksheet, Moodle
  section text, roleplay script, and roleplay note template;
- explicit check that no student identifiers, real credentials, private keys,
  or sensitive service payloads are present.

## Stop Rules

Stop and report to the rPVA orchestrator if:

- the starting branch/base/status differs materially from the expected state;
- the roleplay pack would require Barry to act now;
- the pack requires a real Moodle upload, student contact, hostname,
  credential, class account, token, or student workspace decision;
- the app flow fails in a way that needs app/package code changes;
- the roleplay script exposes a raw-IP, insecure HTTPS, browser-warning, or
  unapproved release route as student-facing;
- any real secret, private key, student identifier, or sensitive service
  payload appears in changed files.

## Reporting

Leave the result uncommitted for orchestrator review.

Report:

- branch, HEAD, and final `git status --short --branch`;
- changed/new files;
- roleplay pack summary;
- local rehearsal evidence paths;
- generated artefact verification summary;
- validation commands and results;
- scan hit classification;
- hosted student URL readiness judgement;
- whether the result is ready for a future Barry roleplay execution goal;
- any blockers or recommended next gate.

Wake the rPVA orchestrator thread when complete or blocked.
