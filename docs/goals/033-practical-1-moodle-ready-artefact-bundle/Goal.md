# Goal 033: Practical 1 Moodle-Ready Artefact Bundle

## Objective

Materialize the accepted Practical 1 student launch materials into a
Moodle-ready handoff bundle that Barry or a demonstrator can assemble quickly
without hunting through the repo.

The bundle should be the last packaging step before the next major pedagogical
checkpoint: Barry roleplays a student, opens the supplied start-here material,
uses the approved app route, works through the Shiny missions, and fills notes
as a real student would.

## Context

Goal 032 produced:

- `docs/teaching/woodhen/practical-1-student-launch-page.md`
- `docs/teaching/woodhen/practical-1-mission-worksheet.md`
- `docs/teaching/woodhen/practical-1-moodle-upload-manifest.md`
- student-zero rehearsal evidence showing the launch path works locally.

Those files are pedagogically accepted. Goal 033 should not rewrite the
curriculum or app. It should turn the accepted sources into a clear handoff
bundle and verify the files Barry would actually use.

## Success Criteria

The goal is complete when the repo contains a compact Practical 1 Moodle-ready
bundle that:

1. Identifies the exact student-visible files and instructor-only files for
   Practical 1.
2. Provides paste-ready Moodle section text or labels.
3. Provides stable generated artefacts where useful, such as rendered worksheet
   and report-scaffold outputs.
4. Provides a bundle manifest with source paths, generated output paths,
   checksums or sizes, and render commands.
5. Preserves source-of-truth documents in their existing locations and avoids
   unnecessary duplicated source text.
6. Keeps the app route as an approved day-of-class item, not a hard-coded raw
   IP or insecure HTTPS URL.
7. Defines the readiness bridge to the next Barry-as-student roleplay
   checkpoint.

## In Scope

- Review the Goal 032 launch page, worksheet, Moodle manifest, day-of-class
  pack, go/no-go checklist, and student-zero rehearsal report.
- Create a Moodle-ready bundle folder or equivalent repo-local handoff surface.
- Render student-facing or optional handoff artefacts, such as:
  - launch page preview, if practical under repo ignore rules;
  - mission worksheet PDF or DOCX;
  - report scaffold DOCX/PDF;
  - paste-ready Moodle section text in Markdown.
- Create a manifest that records exactly what to upload, what to keep hidden,
  what to paste, and what remains gated.
- Verify generated files open or parse.
- Add narrow README/instructor pointers if needed.

## Out Of Scope

- Rewriting the Goal 029-032 pedagogical sequence.
- App/package code changes.
- Shiny UI/CSS/server changes.
- Science/YAML/model-default changes.
- Practical 2 mode or Woodhen management practical redesign.
- Assessment redesign or marking-rubric changes.
- Moodle upload or any external LMS edit.
- Student contact.
- Barry-as-student roleplay itself.
- KPZ314 materials or implementation.
- Hosting, ShinyProxy, nginx, systemd, firewall, DNS, TLS, Docker-service,
  account, credential, token, class-workspace, or student-release changes.
- Public or student-facing release of the current raw-IP or insecure HTTPS
  route.
- Remote infrastructure changes.
- Commit, push, merge, PR, or Goal 034 work.

## Required Deliverables

Use a clear folder under `docs/teaching/woodhen/`, such as:

- `docs/teaching/woodhen/practical-1-moodle-ready-bundle/README.md`
- `docs/teaching/woodhen/practical-1-moodle-ready-bundle/moodle-section-text.md`
- `docs/teaching/woodhen/practical-1-moodle-ready-bundle/manifest.md`
- generated artefacts, if they are useful, stable, small, and consistent with
  repo ignore policy.

Also create:

- `docs/goals/033-practical-1-moodle-ready-artefact-bundle/artefact-bundle-report.md`
- updates to `docs/goals/033-practical-1-moodle-ready-artefact-bundle/Log.md`
- narrow discoverability pointers in existing teaching docs if needed.

If repo ignore rules make a generated artefact unsuitable to commit, do not
force-add it unless there is a strong reason. Instead, generate it under `/tmp`,
record the command and checksum/size in the report, and include the exact
handoff instruction in the bundle manifest.

## Bundle Requirements

The bundle should include or reference:

- start-here launch instructions;
- mission worksheet;
- approved app-link placeholder and go/no-go note;
- optional report scaffold outputs;
- instructor-only support files;
- hidden fallback and troubleshooting materials;
- day-after notes policy;
- a short "ready for Barry roleplay when..." section.

The ready-for-roleplay section should make the next checkpoint explicit:

- Barry has the start-here material;
- Barry has the worksheet or note-taking equivalent;
- Barry has an approved route or local app session to use;
- Barry knows where to save the CSV and Markdown evidence files;
- the orchestrator has a short note-capture template ready for his feedback.

## Validation

Run and report:

```sh
git diff --check
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
```

For generated artefacts:

- render report scaffold DOCX/PDF sequentially if included or referenced;
- render worksheet/launch outputs if included;
- verify file type and non-zero size;
- use `pdfinfo` for PDFs when available;
- record checksums or sizes in the manifest/report.

Also complete:

- marker scan over changed/new text;
- secret/private-key-pattern scan over changed/new text, with hits classified;
- stricter assignment/private-key-block scan;
- student-visible route wording check over the launch page, worksheet, Moodle
  section text, bundle README, and manifest;
- explicit check that no student identifiers, real credentials, private keys,
  or sensitive service payloads are present.

## Stop Rules

Stop and report to the rPVA orchestrator if:

- the starting branch/base/status differs materially from the expected state;
- the bundle requires a real Moodle upload or student contact;
- the bundle requires a real hostname, credential, class account, token, or
  student workspace decision;
- render output would require broad tooling or dependency changes;
- repo ignore rules conflict with a generated-artefact plan and the right
  choice is unclear;
- the student-visible outputs direct students to a raw-IP, insecure HTTPS,
  browser-warning, or unapproved release route;
- any real secret, private key, student identifier, or sensitive service
  payload appears in changed files.

## Reporting

Leave the result uncommitted for orchestrator review.

Report:

- branch, HEAD, and final `git status --short --branch`;
- changed/new files;
- bundle shape and generated artefacts;
- manifest/checksum or file-size summary;
- validation commands and results;
- scan hit classification;
- hosted student URL readiness judgement;
- whether the result is ready for a future Barry-as-student roleplay goal;
- any blockers or recommended next gate.

Wake the rPVA orchestrator thread when complete or blocked.
