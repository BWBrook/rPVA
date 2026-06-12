# Goal 034 Roleplay Readiness Report

## Summary

Goal 034 prepared the staging pack for Barry to roleplay a Practical 1 student
in a later session. The pack keeps Barry in the student role, gives the
orchestrator a concise note-capture surface, and separates roleplay readiness
from hosted student URL release.

The local roleplay path passed using a local app route. Hosted student URL
release remains no-go and outside this goal.

## Starting State

- Working directory: `/Users/bwbrook/git/rPVA`
- Branch: `codex/rpva-goal034-barry-student-roleplay-readiness`
- Base:
  `1fe1a38a6fc1a7e2e2afc8471f67de867b28e266`
  (`1fe1a38 Add Practical 1 Moodle-ready bundle`)
- Initial dirty state: untracked Goal 034 packet directory only.

## Sources Reviewed

- `docs/goals/034-practical-1-barry-student-roleplay-readiness/Goal.md`
- `docs/goals/034-practical-1-barry-student-roleplay-readiness/Plan.md`
- `docs/goals/034-practical-1-barry-student-roleplay-readiness/Runbook.md`
- `docs/goals/034-practical-1-barry-student-roleplay-readiness/Log.md`
- `docs/teaching/woodhen/README.md`
- `docs/teaching/woodhen/instructor-guide.md`
- `docs/teaching/woodhen/practical-1-student-launch-page.md`
- `docs/teaching/woodhen/practical-1-mission-worksheet.md`
- `docs/teaching/woodhen/practical-1-moodle-ready-bundle/README.md`
- `docs/teaching/woodhen/practical-1-moodle-ready-bundle/moodle-section-text.md`
- `docs/teaching/woodhen/practical-1-moodle-ready-bundle/manifest.md`
- `docs/teaching/woodhen/practical-1-day-of-class-pack.md`
- `docs/teaching/woodhen/practical-1-go-no-go-checklist.md`
- `docs/goals/033-practical-1-moodle-ready-artefact-bundle/artefact-bundle-report.md`
- `inst/shiny/practical1/app.R`

## Roleplay Pack Created

- `docs/teaching/woodhen/practical-1-barry-roleplay-script.md`
- `docs/teaching/woodhen/practical-1-roleplay-notes-template.md`
- `docs/teaching/woodhen/practical-1-roleplay-go-no-go.md`

Narrow discoverability pointers were added to:

- `docs/teaching/woodhen/README.md`
- `docs/teaching/woodhen/instructor-guide.md`
- `docs/teaching/woodhen/practical-1-moodle-ready-bundle/README.md`

The roleplay script keeps Barry acting as a student and tells him to record
blockers rather than debug as instructor or developer.

## Local Roleplay Rehearsal

Local app command:

```sh
Rscript -e 'source("bootstrap.R"); run_practical1_shiny(host = "127.0.0.1", port = 3900, launch.browser = FALSE)'
```

Local rehearsal route:

```text
http://127.0.0.1:3900/
```

Path exercised:

1. Opened the current student launch and worksheet sources during source
   review.
2. Opened the local app route.
3. Clicked `Start baseline`.
4. Ran `Ceiling carrying capacity`.
5. Ran `Environmental stochasticity`.
6. Ran `Catastrophe`.
7. Ran `Simple intervention`.
8. Opened Compare and confirmed baseline plus four later runs.
9. Downloaded comparison CSV.
10. Downloaded evidence-notes Markdown.
11. Confirmed the worksheet evidence-recording section exists in the launch
    materials.
12. Opened Transfer.

Screenshot evidence:

| Evidence | Path | Size | SHA-256 |
| --- | --- | ---: | --- |
| Start page | `/tmp/rpva-goal034-roleplay-readiness/screenshots/01-start.png` | 89,741 bytes | `18844b6599cc7ac0ce1ff61225f30975dfd0fd3c3e26655a7ab094e50124b65c` |
| Concept Lab after runs | `/tmp/rpva-goal034-roleplay-readiness/screenshots/02-concept-lab-after-runs.png` | 123,707 bytes | `888a1f3044945e3b2ff69c3496b0d5295a75c3545ed5358e2d69ff68babed668` |
| Compare and exports | `/tmp/rpva-goal034-roleplay-readiness/screenshots/03-compare-export.png` | 108,072 bytes | `0d49a0303f7b6e982fe6806f9af6b16c23417649ebeb12d2bba09287bc4ab91f` |
| Transfer | `/tmp/rpva-goal034-roleplay-readiness/screenshots/04-transfer.png` | 70,223 bytes | `2872c3d33517ea316900e914714355cfbabdfa4626ac10f24346ec873cefb533` |

Downloaded evidence:

| Evidence | Path | Size | SHA-256 |
| --- | --- | ---: | --- |
| Comparison CSV | `/tmp/rpva-goal034-roleplay-readiness/downloads/practical1-comparison-20260612.csv` | 631 bytes | `3bed5623ee8ef52da0cd7b2fa602e58df2abf3f401f5d76fc610287c3c6dd3fb` |
| Evidence notes | `/tmp/rpva-goal034-roleplay-readiness/downloads/practical1-evidence-notes-20260612.md` | 4,604 bytes | `cae6c28e6646071275275234dadc597ccface02b85d493e0a4da905ccfeef1ef` |

Export shape observed:

- CSV header:
  `run_id, stage, label, scenario, years, reps, PE, Nmed, Nlo95, Nhi95,
  extinct_reps, surviving_reps, trajectory_available`
- CSV rows: 5, including baseline run 1.
- Evidence-notes Markdown rows: 5 runs.

Browser console:

- one non-blocking `favicon.ico` 404;
- no app JavaScript failure observed.

Shutdown:

- local Shiny listener on port 3900 was stopped after rehearsal;
- `lsof -nP -iTCP:3900 -sTCP:LISTEN` returned no listener.

## Goal 033 Artefact Regeneration

Generated under `/tmp`:

| Artefact | Output path | Size | SHA-256 | Check |
| --- | --- | ---: | --- | --- |
| Mission worksheet DOCX | `/tmp/rpva-goal034-rendered/practical-1-mission-worksheet.docx` | 13,024 bytes | `823cf982b2c68d59d47786a423da47b6bfcbce21100f141fd3a44f6db2c81474` | Word archive OK. |
| Student launch page DOCX | `/tmp/rpva-goal034-rendered/practical-1-student-launch-page.docx` | 12,230 bytes | `e89bf4eb1f2659fd3123be131108f4fb6d02de9d361fe5da575cb6c6d6a5ef96` | Word archive OK. |
| Report scaffold DOCX | `/tmp/rpva-goal034-report/report-scaffold.docx` | 407,891 bytes | `f1108a1bf1b4ddcfb779cdfb9ddffb803b3e867a90673fab6e7ad8542affae46` | Word archive OK. |
| Report scaffold PDF | `/tmp/rpva-goal034-report/report-scaffold.pdf` | 87,399 bytes | `ff2b7cd16b28564f4ad9ed6f6c59f20753257c3ffda1ed3ebe3b2a037e990280` | `pdfinfo` passed. |

PDF metadata:

- title: Woodhen PVA Practical Report;
- producer: LuaTeX-1.24.0;
- pages: 8;
- page size: letter;
- encrypted: no;
- JavaScript: no.

PDF first-page image checked:

- `/tmp/rpva-goal034-pdf-pages/report-scaffold-1.png`

## Validation Results

- `git diff --check`: passed.
- `Rscript -e 'source("bootstrap.R")'`: passed.
- `Rscript -e 'renv::status(sources = FALSE)'`: passed with no issues.
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'`:
  passed.
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'`:
  passed.

## Scan Classification

- Marker scan over changed/untracked text: expected packet wording only; no
  unresolved marker in the roleplay script, notes template, or go/no-go file.
- Secret/private-key-pattern scan over changed/untracked text: hits were
  policy, boundary, scan-command, class-account/access-route, credential or
  private-key safety wording only; no secret values, private keys, student
  identifiers, or sensitive service payloads were present.
- Stricter assignment/private-key-block scan: no hits.
- Student-visible route wording check: no hits in the student launch page,
  worksheet, Moodle section text, roleplay script, or roleplay notes template.

## Readiness Judgement

Barry roleplay execution readiness: green for orchestrator review, conditional
on supplying an approved local or class app route for the later roleplay
session.

Local/in-room teaching readiness: still governed by the day-of-class go/no-go
check.

Hosted student URL release readiness: no-go. Goal 034 does not approve a
hosted student URL, DNS/TLS state, access model, accounts, capacity, Moodle
upload, student contact, or public/student release.

## Recommended Next Gate

If accepted, a closeout goal can commit the Goal 034 docs. The next substantive
pedagogical checkpoint should be Barry performing the roleplay using the script,
notes template, student launch page, worksheet, approved route, and local
evidence folder.
