# Log

## 2026-06-11 - Orchestrator Packet Creation

- Goal 030 was accepted, committed, and published to `origin/main` before this
  branch was created.
- Starting base for Goal 031:
  - branch: `codex/rpva-goal031-delivery-candidate-rehearsal`;
  - base commit:
    `d4855fc Add Practical 1 mission-mode app affordances`;
  - source: `origin/main`.
- Barry approved the next delivery-candidate rehearsal goal.
- Goal purpose:
  - rehearse the mission-mode Practical 1 app and teaching materials as one
    day-of-class package;
  - produce a concise day-of-class delivery pack;
  - produce a go/no-go checklist separating local teaching readiness from
    hosted URL/TLS/student-release readiness;
  - keep all IT/TLS/account/student-release matters outside this goal.
- Boundary:
  - local delivery rehearsal, documentation, and packaging only;
  - no new app features, science/YAML/model-default changes, Practical 2 mode,
    assessment redesign, hosting/service/DNS/TLS/Docker/account/credential/
    student-workspace work, student release, KPZ314 materials, external
    contact, commit, push, merge, or PR work.
- Packet files:
  - `docs/goals/031-practical-1-delivery-candidate-rehearsal-pack/Goal.md`
  - `docs/goals/031-practical-1-delivery-candidate-rehearsal-pack/Plan.md`
  - `docs/goals/031-practical-1-delivery-candidate-rehearsal-pack/Runbook.md`
  - `docs/goals/031-practical-1-delivery-candidate-rehearsal-pack/Log.md`

Status: packet ready for `woodhen`; execution not yet started.

## 2026-06-11 - woodhen Execution Start

Start guard:

- `pwd`: `/Users/bwbrook/git/rPVA`
- branch: `codex/rpva-goal031-delivery-candidate-rehearsal`
- `HEAD`: `d4855fc2322b082389be8b095ba6d50ad9300af5`
- short `HEAD`: `d4855fc`
- starting status:
  - `## codex/rpva-goal031-delivery-candidate-rehearsal`
  - `?? docs/goals/031-practical-1-delivery-candidate-rehearsal-pack/`
- The expected Goal 030 closeout base was present:
  `d4855fc Add Practical 1 mission-mode app affordances`.
- No unexpected dirty state was present before editing beyond the Goal 031
  packet.

Sources read before rehearsal:

- Goal 031 packet: `Goal.md`, `Plan.md`, `Runbook.md`, `Log.md`
- `README.md`
- `docs/teaching/shiny/README.md`
- `docs/teaching/shiny/practical-1-mission-tutorial.md`
- `docs/teaching/woodhen/README.md`
- `docs/teaching/woodhen/practical-1-mission-worksheet.md`
- `docs/teaching/woodhen/practical-1-instructor-beat-sheet.md`
- `docs/teaching/woodhen/instructor-guide.md`
- `docs/teaching/woodhen/classroom-dry-run-checklist.md`
- `docs/teaching/woodhen/practical-1-fallback-pack.md`
- `docs/teaching/woodhen/expected-outputs.md`
- `docs/teaching/woodhen/troubleshooting.md`
- `docs/teaching/woodhen/report-scaffold.qmd`
- `docs/goals/029-practical-1-mission-tutorial-curriculum/Goal.md`
- `docs/goals/029-practical-1-mission-tutorial-curriculum/pedagogy-review.md`
- `docs/goals/030-practical-1-mission-mode-app-affordance-polish/Goal.md`
- `docs/goals/030-practical-1-mission-mode-app-affordance-polish/Log.md`
- `inst/shiny/practical1/README.md`
- `inst/shiny/practical1/app.R`
- `tests/testthat/test-12_teaching_api.R`
- `tests/testthat/test-13_practical1_shiny.R`

Execution stance:

- Keep Goal 031 to local delivery rehearsal, documentation, and packaging.
- Do not modify app/package code, science/YAML, Practical 2 mode, assessment,
  hosting/service/DNS/TLS/Docker/account/credential/student workspace state,
  public/student release state, KPZ314 materials, dependencies, or remote
  state.
- Do not commit, push, open a PR, merge, or start Goal 032.

Status: rehearsal and delivery-pack drafting in progress.

## 2026-06-11 - woodhen Delivery Rehearsal Complete

Local app rehearsal:

- Launched the Practical 1 Shiny app locally at
  `http://127.0.0.1:3898/` using:
  `Rscript -e 'source("bootstrap.R"); run_practical1_shiny(host = "127.0.0.1", port = 3898, launch.browser = FALSE)'`
- Exercised the student path through `Start baseline`, carrying capacity,
  environmental stochasticity, catastrophe, simple intervention, Compare,
  evidence export, and Transfer.
- Screenshot evidence:
  - `/tmp/rpva-goal031-browser/start-baseline.png`
  - `/tmp/rpva-goal031-browser/concept-lab-after-missions.png`
  - `/tmp/rpva-goal031-browser/compare-and-export.png`
  - `/tmp/rpva-goal031-browser/transfer.png`
- Export evidence:
  - `/tmp/rpva-goal031-browser/practical1-comparison-goal031.csv`
  - `/tmp/rpva-goal031-browser/practical1-evidence-notes-goal031.md`
- The comparison CSV retained the accepted Goal 023/030 export shape:
  `run_id`, `stage`, `label`, `scenario`, `years`, `reps`, `PE`, `Nmed`,
  `Nlo95`, `Nhi95`, `extinct_reps`, `surviving_reps`,
  `trajectory_available`.
- The evidence-notes Markdown retained the evidence-not-answer framing,
  timestamp, run count, fixed teaching seed, comparison table, settings,
  provenance, and interpretation prompts.
- Browser console issue observed: non-blocking `favicon.ico` 404 only.
- The local Shiny process was stopped after rehearsal; a final port check
  showed no listener on `3898`.

Report scaffold rehearsal:

- Rendered the report scaffold into `/tmp/rpva-goal031-report/`.
- DOCX render passed:
  `/tmp/rpva-goal031-report/report-scaffold.docx`.
- PDF render failed once during a parallel DOCX/PDF render attempt with a
  transient `report-scaffold.qmd` read error, then passed when rerun
  sequentially:
  `/tmp/rpva-goal031-report/report-scaffold.pdf`.
- Day-of-class guidance now says to render DOCX and PDF sequentially.

Repo-local deliverables:

- Created
  `docs/goals/031-practical-1-delivery-candidate-rehearsal-pack/delivery-rehearsal-report.md`.
- Created `docs/teaching/woodhen/practical-1-day-of-class-pack.md`.
- Created `docs/teaching/woodhen/practical-1-go-no-go-checklist.md`.
- Updated `docs/teaching/woodhen/README.md` with the new pack/checklist.
- Updated `docs/teaching/woodhen/instructor-guide.md` with the delivery
  pack and hosted-release boundary.
- Updated `docs/teaching/woodhen/practical-1-mission-worksheet.md` with a
  compact evidence-file recording section.
- Updated `docs/teaching/woodhen/classroom-dry-run-checklist.md` with
  day-of-class pack and sequential-render checks.
- Updated `docs/teaching/shiny/README.md` with the Goal 031 delivery-candidate
  pointer.

Validation:

- `git status --short --branch` showed only the expected Goal 031 packet,
  teaching documentation, and delivery-pack files changed or untracked.
- `git diff --check`: passed.
- `Rscript -e 'source("bootstrap.R")'`: passed.
- `Rscript -e 'renv::status(sources = FALSE)'`: passed with no issues.
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'`:
  passed.
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'`:
  passed.
- Marker scan over changed/untracked text: no hits.
- Secret/private-key scan over changed/untracked text: hits were reviewed as
  policy wording, scan-command text, class-account/token boundary wording,
  credential/private-key safety wording, or path/reference text only; no
  secret values, private keys, student identifiers, or sensitive service
  payloads were present.
- Stricter assignment/private-key-block scan: no hits.

Readiness judgement:

- Local/in-room teaching readiness is green for a controlled rehearsal or
  instructor-managed class path where the app route is approved locally and
  demonstrators can switch to fallback quickly.
- Hosted student URL release remains no-go. The raw-IP or browser-warning HTTPS
  route must not be represented as student-ready.
- Hosted release blockers remain: class hostname, browser-trusted TLS, tested
  student app path, access model, class account/token/workspace decisions,
  capacity evidence, and recovery path.

Boundary result:

- No app/package code, tests, science/YAML, Practical 2 mode, assessment,
  hosting/service/DNS/TLS/Docker/account/credential/student-workspace state,
  public/student release state, KPZ314 material, dependency, external-service,
  remote-state, commit, push, merge, PR, or Goal 032 work was performed.

Status: Goal 031 local delivery-candidate rehearsal complete and left
uncommitted for orchestrator review.
