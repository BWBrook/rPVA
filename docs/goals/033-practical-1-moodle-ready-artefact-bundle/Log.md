# Log

## 2026-06-11 - Orchestrator Packet Creation

- Goal 032 was accepted, committed, and published to `origin/main`.
- Starting base for Goal 033:
  - branch: `codex/rpva-goal033-moodle-ready-artefact-bundle`;
  - base commit:
    `55e2bf6 Add Practical 1 student launch pack`;
  - source: `origin/main`.
- Barry approved continued work toward the major checkpoint where he can
  roleplay a student using the tutorial, Shiny app, and notes.
- Goal purpose:
  - materialize the accepted Practical 1 student launch materials into a
    Moodle-ready handoff bundle;
  - render and verify useful artefacts without rewriting pedagogy or app code;
  - define the bridge to a future Barry-as-student roleplay checkpoint;
  - keep hosted URL/TLS/account/student-release matters outside this goal.
- Boundary:
  - documentation, packaging, local rendering, artefact verification, and
    narrow pointers only;
  - no app/package code, Shiny UI/CSS/server, science/YAML/model defaults,
    Practical 2 mode, assessment redesign, Moodle upload, student contact,
    Barry roleplay itself, KPZ314 materials, hosting/service/DNS/TLS/Docker/
    account/credential/student-workspace work, public/student release, remote
    state, commit, push, merge, PR, or Goal 034 work.
- Packet files:
  - `docs/goals/033-practical-1-moodle-ready-artefact-bundle/Goal.md`
  - `docs/goals/033-practical-1-moodle-ready-artefact-bundle/Plan.md`
  - `docs/goals/033-practical-1-moodle-ready-artefact-bundle/Runbook.md`
  - `docs/goals/033-practical-1-moodle-ready-artefact-bundle/Log.md`

Status: packet ready for `woodhen`; execution not yet started.

## 2026-06-11 - Start Guard And Source Review

- Working directory confirmed: `/Users/bwbrook/git/rPVA`.
- Branch confirmed: `codex/rpva-goal033-moodle-ready-artefact-bundle`.
- HEAD confirmed:
  `55e2bf6291733594bef1e2c88c35e913badaea83`
  (`55e2bf6 Add Practical 1 student launch pack`).
- Initial status confirmed:

```text
## codex/rpva-goal033-moodle-ready-artefact-bundle...origin/main
?? docs/goals/033-practical-1-moodle-ready-artefact-bundle/
```

- Source files reviewed:
  - Goal 033 packet: `Goal.md`, `Plan.md`, `Runbook.md`, `Log.md`;
  - repo ignore rules: `.gitignore`,
    `docs/teaching/woodhen/.gitignore`;
  - teaching handoff docs:
    `docs/teaching/woodhen/README.md`,
    `docs/teaching/woodhen/instructor-guide.md`,
    `docs/teaching/woodhen/practical-1-student-launch-page.md`,
    `docs/teaching/woodhen/practical-1-mission-worksheet.md`,
    `docs/teaching/woodhen/practical-1-moodle-upload-manifest.md`,
    `docs/teaching/woodhen/practical-1-day-of-class-pack.md`,
    `docs/teaching/woodhen/practical-1-go-no-go-checklist.md`;
  - Goal 032 evidence:
    `docs/goals/032-practical-1-student-launch-pack/student-zero-rehearsal-report.md`.
- Bundle policy chosen:
  - keep source-of-truth Markdown/QMD files in their existing locations;
  - add a compact Moodle-ready bundle folder with pointers, paste-ready
    Moodle text, and a manifest;
  - generate DOCX/PDF artefacts under `/tmp` and record commands, sizes, and
    checksums rather than committing regenerated binaries.
- Boundary status: no app/package code, Shiny UI/CSS/server, science/YAML,
  Practical 2, assessment, dependency, Moodle, contact, service, DNS/TLS,
  account, credential, student-workspace, public-release, remote-state, commit,
  push, PR, merge, or Goal 034 work started.

## 2026-06-11 - Bundle Creation And Artefact Rendering

- Created compact Moodle-ready bundle folder:
  - `docs/teaching/woodhen/practical-1-moodle-ready-bundle/README.md`;
  - `docs/teaching/woodhen/practical-1-moodle-ready-bundle/moodle-section-text.md`;
  - `docs/teaching/woodhen/practical-1-moodle-ready-bundle/manifest.md`.
- Added narrow discoverability pointers:
  - `docs/teaching/woodhen/README.md`;
  - `docs/teaching/woodhen/instructor-guide.md`.
- Created Goal 033 report:
  - `docs/goals/033-practical-1-moodle-ready-artefact-bundle/artefact-bundle-report.md`.
- Rendered generated artefacts under `/tmp` and left them out of repo:
  - `/tmp/rpva-goal033-rendered/practical-1-mission-worksheet.docx`;
  - `/tmp/rpva-goal033-rendered/practical-1-student-launch-page.docx`;
  - `/tmp/rpva-goal033-report/report-scaffold.docx`;
  - `/tmp/rpva-goal033-report/report-scaffold.pdf`.
- Generated artefact evidence:
  - worksheet DOCX: 13,023 bytes,
    SHA-256 `a3377360d81cde61502f4081f4e5a03c464f122842f6fc8e05776479dce113d9`,
    Word archive check passed;
  - launch page DOCX: 12,229 bytes,
    SHA-256 `dc18585e2880bc73bf2e29c565281d70f4ec56e1886969ef1f009c3fa521f435`,
    Word archive check passed;
  - report scaffold DOCX: 407,891 bytes,
    SHA-256 `f5d5e377a9ac0d2740c4a8ed526050339a11f7dbdca0b5a7e7f3acdbbc3c68ab`,
    Word archive check passed;
  - report scaffold PDF: 87,402 bytes,
    SHA-256 `1ceb7cd7ae3ec742b605b433654ef915673d4108951a008fdf4711b659c118db`,
    `pdfinfo` passed with 8 pages, letter size, not encrypted, no JavaScript.
- PDF visual evidence rendered and checked:
  - `/tmp/rpva-goal033-pdf-pages/report-scaffold-1.png`.

## 2026-06-11 - Validation

- `git diff --check`: passed.
- `Rscript -e 'source("bootstrap.R")'`: passed.
- `Rscript -e 'renv::status(sources = FALSE)'`: passed with no issues.
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'`:
  passed.
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'`:
  passed.
- Marker scan over changed/untracked text:
  - one expected hit in Goal 033 packet wording about the approved app-link
    note;
  - no unresolved marker in bundle content or Moodle section text.
- Secret/private-key-pattern scan over changed/untracked text:
  - hits were policy, boundary, scan-command, class-account/access-route, or
    private-key safety wording only;
  - no secret values, private keys, student identifiers, or sensitive service
    payloads were present.
- Stricter assignment/private-key-block scan: no hits.
- Student-visible route wording check:
  - no hits in `practical-1-student-launch-page.md`,
    `practical-1-mission-worksheet.md`, or
    `practical-1-moodle-ready-bundle/moodle-section-text.md`;
  - hits in the bundle README and manifest are instructor-facing route-gate
    warnings.
- Hosted student URL release remains no-go and outside Goal 033.
- Boundary status: no app/package code, Shiny UI/CSS/server, science/YAML,
  Practical 2, assessment, dependency, Moodle, contact, service, DNS/TLS,
  account, credential, student-workspace, public-release, remote-state, commit,
  push, PR, merge, or Goal 034 work was performed.

Status: complete for orchestrator review; result left uncommitted.
