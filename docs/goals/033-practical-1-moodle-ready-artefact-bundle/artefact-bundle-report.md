# Goal 033 Artefact Bundle Report

## Summary

Goal 033 materialized the accepted Practical 1 launch package into a compact
Moodle-ready bundle and verified the generated handoff artefacts without
rewriting the curriculum or changing the app.

The result is ready for orchestrator review as a Moodle handoff package and is
ready to feed a future Barry-as-student roleplay checkpoint once an approved
local or class app route is supplied for that roleplay.

Hosted student URL release remains no-go and outside this goal.

## Starting State

- Working directory: `/Users/bwbrook/git/rPVA`
- Branch: `codex/rpva-goal033-moodle-ready-artefact-bundle`
- Base:
  `55e2bf6291733594bef1e2c88c35e913badaea83`
  (`55e2bf6 Add Practical 1 student launch pack`)
- Initial dirty state: untracked Goal 033 packet directory only.

## Sources Reviewed

- `docs/goals/033-practical-1-moodle-ready-artefact-bundle/Goal.md`
- `docs/goals/033-practical-1-moodle-ready-artefact-bundle/Plan.md`
- `docs/goals/033-practical-1-moodle-ready-artefact-bundle/Runbook.md`
- `docs/goals/033-practical-1-moodle-ready-artefact-bundle/Log.md`
- `.gitignore`
- `docs/teaching/woodhen/.gitignore`
- `docs/teaching/woodhen/README.md`
- `docs/teaching/woodhen/instructor-guide.md`
- `docs/teaching/woodhen/practical-1-student-launch-page.md`
- `docs/teaching/woodhen/practical-1-mission-worksheet.md`
- `docs/teaching/woodhen/practical-1-moodle-upload-manifest.md`
- `docs/teaching/woodhen/practical-1-day-of-class-pack.md`
- `docs/teaching/woodhen/practical-1-go-no-go-checklist.md`
- `docs/goals/032-practical-1-student-launch-pack/student-zero-rehearsal-report.md`

## Bundle Shape

Repo-local bundle:

- `docs/teaching/woodhen/practical-1-moodle-ready-bundle/README.md`
- `docs/teaching/woodhen/practical-1-moodle-ready-bundle/moodle-section-text.md`
- `docs/teaching/woodhen/practical-1-moodle-ready-bundle/manifest.md`

Narrow discoverability pointers were added to:

- `docs/teaching/woodhen/README.md`
- `docs/teaching/woodhen/instructor-guide.md`

The bundle references accepted source-of-truth Markdown/QMD files in their
existing locations. It does not duplicate the Goal 029-032 curriculum sequence.

## Generated Artefact Policy

Generated DOCX/PDF files were rendered under `/tmp` and left out of the repo.
This keeps the committed bundle small while preserving exact regeneration
commands, sizes, checksums, and file checks in the manifest.

## Generated Artefacts And Checks

| Artefact | Output path | Size | SHA-256 | File/open check |
| --- | --- | ---: | --- | --- |
| Mission worksheet DOCX | `/tmp/rpva-goal033-rendered/practical-1-mission-worksheet.docx` | 13,023 bytes | `a3377360d81cde61502f4081f4e5a03c464f122842f6fc8e05776479dce113d9` | Microsoft Word 2007+; `unzip -t` passed. |
| Student launch page DOCX | `/tmp/rpva-goal033-rendered/practical-1-student-launch-page.docx` | 12,229 bytes | `dc18585e2880bc73bf2e29c565281d70f4ec56e1886969ef1f009c3fa521f435` | Microsoft Word 2007+; `unzip -t` passed. |
| Report scaffold DOCX | `/tmp/rpva-goal033-report/report-scaffold.docx` | 407,891 bytes | `f5d5e377a9ac0d2740c4a8ed526050339a11f7dbdca0b5a7e7f3acdbbc3c68ab` | Microsoft Word 2007+; `unzip -t` passed. |
| Report scaffold PDF | `/tmp/rpva-goal033-report/report-scaffold.pdf` | 87,402 bytes | `1ceb7cd7ae3ec742b605b433654ef915673d4108951a008fdf4711b659c118db` | PDF 1.7; `pdfinfo` passed. |

PDF metadata for `report-scaffold.pdf`:

- title: Woodhen PVA Practical Report;
- producer: LuaTeX-1.24.0;
- pages: 8;
- page size: letter;
- encrypted: no;
- JavaScript: no.

PDF first-page image checked:

- `/tmp/rpva-goal033-pdf-pages/report-scaffold-1.png`

The first page showed the report title, table of contents, and the beginning of
the Instructions section with no blank-page or obvious layout failure.

## Validation Results

Validation was run after bundle creation:

- `git diff --check`: passed.
- `Rscript -e 'source("bootstrap.R")'`: passed.
- `Rscript -e 'renv::status(sources = FALSE)'`: passed with no issues.
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'`:
  passed.
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'`:
  passed.

## Scan Classification

- Marker scan over changed/untracked text: one expected hit was limited to Goal
  033 packet wording about the approved app-link note; no unresolved marker was
  present in the bundle content or Moodle section text.
- Secret/private-key scan over changed/untracked text: hits were policy,
  boundary, scan-command, class-account/access-route, or private-key safety
  wording only; no secret values, private keys, student identifiers, or
  sensitive service payloads were present.
- Stricter assignment/private-key-block scan: no hits.
- Student-visible route wording check: the Moodle section text, launch page,
  and worksheet do not direct students to a raw-IP, insecure HTTPS,
  browser-warning, or unapproved student route. Bundle README and manifest hits
  are instructor-facing route-gate warnings.

## Readiness Judgement

Moodle handoff package readiness: green for orchestrator review.

Local/in-room delivery readiness: still depends on the day-of-class route and
go/no-go checklist.

Hosted student URL release readiness: no-go. This goal does not approve a
hosted student URL, DNS/TLS state, access model, accounts, capacity, or public
student release.

## Recommended Next Gate

Closeout can commit the Goal 033 docs if accepted. The next major pedagogical
checkpoint should be a Barry-as-student roleplay using the Moodle section text,
start-here page, worksheet, approved local or class app route, and a local
`practical-1-evidence` folder.
