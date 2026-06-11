# Goal 032: Practical 1 Student Launch Pack And Moodle Handoff Rehearsal

## Objective

Turn the accepted Practical 1 mission-mode delivery candidate into a
student-facing launch package that Barry could place into Moodle or hand to
students at the start of class.

The output should make the first student action obvious, keep the app-led
learning path engaging, and preserve the existing safety boundary: local or
approved class-route teaching can proceed, but the current raw-IP or
browser-warning HTTPS route is not a student-ready hosted URL.

## Context

Goals 029 to 031 established:

- the Practical 1 mission tutorial and lightweight worksheet;
- app-visible mission affordances;
- a day-of-class instructor pack;
- a go/no-go checklist separating local/in-room readiness from hosted
  student-URL readiness;
- local browser and report-render evidence for the teaching path.

The remaining classroom gap is not another fallback pack or new app feature. It
is the student entry surface: the exact words, files, and order a student sees
when they begin the practical.

This goal should answer:

> If Barry had to assemble the Practical 1 Moodle section today, what should
> students see, download, open, save, and submit or retain as evidence?

## Success Criteria

The goal is complete when the repo contains a coherent, Moodle-ready
student-launch package that:

1. Gives students a short, friendly start page for Practical 1.
2. Lists the exact student materials to open or download.
3. Explains the evidence workflow without exposing implementation details:
   open the approved app route, start baseline, work through missions, compare,
   export CSV and Markdown evidence notes, answer transfer questions, and use
   fallback capture only when directed.
4. Includes a Moodle/upload manifest for Barry or a demonstrator.
5. Includes a student-zero rehearsal report showing the launch pack was walked
   through using only student-visible instructions and a local app route.
6. Updates only narrow teaching-doc pointers needed to make the new launch
   pack discoverable.
7. Keeps hosted student URL release explicitly no-go until the separate
   hostname/TLS/access/capacity gates are green.

## In Scope

- Review of the current Practical 1 mission tutorial, worksheet, day-of-class
  pack, go/no-go checklist, fallback pack, troubleshooting guide, expected
  outputs, report scaffold, and Goal 031 rehearsal report.
- Creation of a concise student-facing launch page.
- Creation of a Moodle/upload manifest for the Practical 1 section.
- Creation of a student-zero rehearsal report using only student-facing
  instructions and a local or placeholder approved-route stand-in.
- Narrow discoverability edits in existing teaching README/instructor docs.
- Local validation of bootstrap, teaching tests, report scaffold rendering,
  and text safety.

## Out Of Scope

- App/package code changes.
- Shiny UI/CSS/server changes.
- Science/YAML/model-default changes.
- Practical 2 mode or Woodhen management practical redesign.
- Assessment redesign or grading-rubric changes.
- Moodle upload or any external LMS edit.
- Student contact.
- KPZ314 materials or implementation.
- Hosting, ShinyProxy, nginx, systemd, firewall, DNS, TLS, Docker-service,
  account, credential, token, class-workspace, or student-release changes.
- Public or student-facing release of the current raw-IP or insecure HTTPS
  route.
- Remote infrastructure changes.
- Commit, push, merge, PR, or Goal 033 work.

## Required Deliverables

Use these paths unless a better existing naming pattern is clearly preferable:

- `docs/teaching/woodhen/practical-1-student-launch-page.md`
- `docs/teaching/woodhen/practical-1-moodle-upload-manifest.md`
- `docs/goals/032-practical-1-student-launch-pack/student-zero-rehearsal-report.md`
- updates to `docs/goals/032-practical-1-student-launch-pack/Log.md`
- narrow pointers, if needed, in:
  - `docs/teaching/woodhen/README.md`
  - `docs/teaching/woodhen/instructor-guide.md`
  - `docs/teaching/woodhen/practical-1-day-of-class-pack.md`
  - `docs/teaching/shiny/README.md`

## Student Launch Page Requirements

The student launch page should:

- be short enough to read at the start of class;
- use direct student-facing language;
- avoid internal implementation or deployment detail;
- name the approved app route as a day-of-class item rather than hard-coding
  the current raw IP or insecure HTTPS route;
- tell students what files they need;
- tell students where to save outputs;
- reinforce that app exports are evidence, not answers;
- tell students what to do if downloads or app access fail;
- avoid implying that fallback is second-rate or a failure.

## Moodle Manifest Requirements

The manifest should help Barry or a demonstrator assemble a Moodle section. It
should list:

- required files;
- optional instructor-only files;
- suggested Moodle labels or section ordering;
- what should be visible to students versus hidden from students;
- the app-route placeholder policy;
- a no-go reminder for raw-IP or insecure HTTPS routes;
- any day-after evidence or notes Barry should retain outside the repo if
  student identifiers are involved.

## Student-Zero Rehearsal Requirements

Run a student-zero rehearsal using the launch page and worksheet as the only
student-facing instructions.

Use a local app route unless a fully approved class route already exists in the
repo-local go/no-go state. Do not use or test the raw-IP/insecure HTTPS route as
a released student path.

Exercise at least:

1. Open the launch page.
2. Identify materials and save-location instructions.
3. Start baseline.
4. Complete at least carrying capacity, one stochasticity stage, one risk
   pressure, and one intervention or vortex comparison.
5. Use Compare.
6. Save the comparison CSV and evidence-notes Markdown.
7. Fill or inspect the worksheet evidence-recording section.
8. Reach the Transfer questions.

Save screenshots and downloads outside the repo, preferably under
`/tmp/rpva-goal032-student-zero/`, and record their paths in the report.

## Validation

Run and report:

```sh
git diff --check
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
```

Render the report scaffold sequentially if student-facing report use remains
part of the launch pack:

```sh
quarto render docs/teaching/woodhen/report-scaffold.qmd --to docx --output-dir /tmp/rpva-goal032-report
quarto render docs/teaching/woodhen/report-scaffold.qmd --to pdf --output-dir /tmp/rpva-goal032-report
```

Also complete:

- marker scan over changed/new text;
- secret/private-key-pattern scan over changed/new text, with hits classified;
- stricter assignment/private-key-block scan;
- explicit check that no student identifiers, real credentials, private keys,
  or sensitive service payloads are present;
- explicit check that no student-facing file tells students to use the current
  raw-IP or browser-warning HTTPS route as release-ready.

## Stop Rules

Stop and report to the rPVA orchestrator if:

- the starting branch/base/status differs materially from the expected state;
- the student launch page would need a real Moodle edit or student contact;
- the launch package would require a real hostname, credential, class account,
  token, or student workspace decision;
- the app flow fails in a way that needs app/package code changes;
- the report scaffold cannot render and there is no sensible docs-only
  mitigation;
- any real secret, private key, student identifier, or sensitive service
  payload appears in changed files.

## Reporting

Leave the result uncommitted for orchestrator review.

Report:

- branch, HEAD, and final `git status --short --branch`;
- changed/new files;
- student launch package summary;
- student-zero rehearsal path and evidence paths;
- validation commands and results;
- scan hit classification;
- whether hosted student URL release remains no-go;
- any blockers or recommended next gate.

Wake the rPVA orchestrator thread when complete or blocked.
