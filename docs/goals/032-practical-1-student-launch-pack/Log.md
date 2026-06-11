# Log

## 2026-06-11 - Orchestrator Packet Creation

- Goal 031 was accepted, committed, and published to `origin/main`.
- Starting base for Goal 032:
  - branch: `codex/rpva-goal032-student-launch-pack`;
  - base commit:
    `d394b27 Add Practical 1 delivery-candidate rehearsal pack`;
  - source: `origin/main`.
- Barry approved the next student-launch/Moodle-handoff goal.
- Goal purpose:
  - convert the accepted Practical 1 delivery-candidate pack into a
    student-facing launch package;
  - produce a Moodle/upload manifest for Barry or demonstrators;
  - rehearse the launch path as "student zero" using only student-visible
    instructions;
  - keep hosted URL/TLS/account/student-release matters outside this goal.
- Boundary:
  - documentation, packaging, student-zero local rehearsal, and narrow pointers
    only;
  - no app/package code, Shiny UI/CSS/server, science/YAML/model defaults,
    Practical 2 mode, assessment redesign, Moodle upload, student contact,
    KPZ314 materials, hosting/service/DNS/TLS/Docker/account/credential/
    student-workspace work, public/student release, remote state, commit, push,
    merge, PR, or Goal 033 work.
- Packet files:
  - `docs/goals/032-practical-1-student-launch-pack/Goal.md`
  - `docs/goals/032-practical-1-student-launch-pack/Plan.md`
  - `docs/goals/032-practical-1-student-launch-pack/Runbook.md`
  - `docs/goals/032-practical-1-student-launch-pack/Log.md`

Status: packet ready for `woodhen`; execution not yet started.

## 2026-06-11 - woodhen Execution Start

Start guard:

- `pwd`: `/Users/bwbrook/git/rPVA`
- branch: `codex/rpva-goal032-student-launch-pack`
- `HEAD`: `d394b27ff4a686aa1767cc838580da6e9e4661d4`
- short `HEAD`: `d394b27`
- starting status:
  - `## codex/rpva-goal032-student-launch-pack...origin/main`
  - `?? docs/goals/032-practical-1-student-launch-pack/`
- The expected Goal 031 closeout base was present:
  `d394b27 Add Practical 1 delivery-candidate rehearsal pack`.
- No unexpected dirty state was present before editing beyond the Goal 032
  packet.

Sources read before drafting:

- Goal 032 packet: `Goal.md`, `Plan.md`, `Runbook.md`, `Log.md`
- `docs/teaching/shiny/README.md`
- `docs/teaching/shiny/practical-1-mission-tutorial.md`
- `docs/teaching/woodhen/README.md`
- `docs/teaching/woodhen/practical-1-mission-worksheet.md`
- `docs/teaching/woodhen/practical-1-day-of-class-pack.md`
- `docs/teaching/woodhen/practical-1-go-no-go-checklist.md`
- `docs/teaching/woodhen/practical-1-instructor-beat-sheet.md`
- `docs/teaching/woodhen/practical-1-fallback-pack.md`
- `docs/teaching/woodhen/troubleshooting.md`
- `docs/teaching/woodhen/expected-outputs.md`
- `docs/teaching/woodhen/report-scaffold.qmd`
- `docs/teaching/woodhen/instructor-guide.md`
- `docs/goals/031-practical-1-delivery-candidate-rehearsal-pack/delivery-rehearsal-report.md`

Execution stance:

- Keep Goal 032 to documentation, launch packaging, local student-zero
  rehearsal, and narrow discoverability pointers.
- Do not edit app/package code, Shiny UI/CSS/server, science/YAML, model
  defaults, Practical 2 mode, assessment design, Moodle state, student contact,
  hosting/service/DNS/TLS/Docker/account/credential/student workspace state,
  public/student release state, KPZ314 materials, dependencies, external
  services, or remote state.
- Do not commit, push, open a PR, merge, or start Goal 033.

Status: student launch package drafting and rehearsal setup in progress.

## 2026-06-11 - woodhen Student-Zero Rehearsal Complete

Repo-local deliverables:

- Created `docs/teaching/woodhen/practical-1-student-launch-page.md`.
- Created `docs/teaching/woodhen/practical-1-moodle-upload-manifest.md`.
- Created
  `docs/goals/032-practical-1-student-launch-pack/student-zero-rehearsal-report.md`.
- Updated `docs/teaching/woodhen/README.md` with the launch page and manifest.
- Updated `docs/teaching/woodhen/instructor-guide.md` with the Practical 1
  student-facing start page and Moodle/local handoff manifest.
- Updated `docs/teaching/woodhen/practical-1-day-of-class-pack.md` so the
  day-of-class setup opens the student launch page.
- Updated `docs/teaching/shiny/README.md` with the Goal 032 pointer.

Student-zero rehearsal:

- Converted the launch page and worksheet to temporary HTML under
  `/tmp/rpva-goal032-student-zero/` for local browser inspection.
- Served those temporary HTML files at `http://localhost:4899/` during the
  rehearsal only.
- Launched the Practical 1 Shiny app locally at `http://localhost:3899/` using:
  `Rscript -e 'source("bootstrap.R"); run_practical1_shiny(host = "127.0.0.1", port = 3899, launch.browser = FALSE)'`.
- Used the launch page and worksheet as the student-facing instruction surface.
- Exercised:
  - launch page read-through;
  - worksheet evidence-recording section;
  - `Start baseline`;
  - carrying capacity;
  - environmental stochasticity;
  - catastrophe;
  - simple intervention;
  - Compare;
  - comparison CSV export;
  - evidence-notes Markdown export;
  - Transfer.
- Screenshot evidence:
  - `/tmp/rpva-goal032-student-zero/student-launch-page.png`
  - `/tmp/rpva-goal032-student-zero/start-baseline.png`
  - `/tmp/rpva-goal032-student-zero/concept-lab-after-runs.png`
  - `/tmp/rpva-goal032-student-zero/compare-export.png`
  - `/tmp/rpva-goal032-student-zero/worksheet-evidence-section.png`
  - `/tmp/rpva-goal032-student-zero/transfer.png`
- Downloaded evidence:
  - `/tmp/rpva-goal032-student-zero/practical1-comparison-goal032.csv`
  - `/tmp/rpva-goal032-student-zero/practical1-evidence-notes-goal032.md`
- The comparison CSV retained the accepted export shape:
  `run_id`, `stage`, `label`, `scenario`, `years`, `reps`, `PE`, `Nmed`,
  `Nlo95`, `Nhi95`, `extinct_reps`, `surviving_reps`,
  `trajectory_available`.
- The final comparison evidence included five rows: baseline, carrying
  capacity, environmental stochasticity, catastrophe, and simple intervention.
- Observed browser console issue: non-blocking `favicon.ico` 404 only.
- The local Shiny and temporary static HTML servers were stopped after
  rehearsal; final checks showed no listener on ports `3899` or `4899`.

Report scaffold render:

- Rendered the report scaffold sequentially into `/tmp/rpva-goal032-report/`.
- DOCX render passed:
  `/tmp/rpva-goal032-report/report-scaffold.docx`.
- PDF render passed:
  `/tmp/rpva-goal032-report/report-scaffold.pdf`.

Validation:

- `git diff --check`: passed.
- `Rscript -e 'source("bootstrap.R")'`: passed.
- `Rscript -e 'renv::status(sources = FALSE)'`: passed with no issues.
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'`:
  passed.
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'`:
  passed.
- Sequential DOCX/PDF report scaffold render: passed.
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
  boundary judgement.
- Student-facing route wording check over
  `practical-1-student-launch-page.md` and
  `practical-1-mission-worksheet.md`: no raw-IP, insecure-HTTPS,
  browser-warning, or release-ready route instruction hits.

Readiness judgement:

- Student launch package readiness is green for orchestrator review as a
  Moodle/local handoff content package.
- Local/in-room use remains conditional on the day-of-class approved local or
  class-route go/no-go check.
- Hosted student URL release remains no-go. The launch pack requires an
  approved app route and does not publish the current raw-IP or browser-warning
  HTTPS route as a student path.

Boundary result:

- No app/package code, Shiny UI/CSS/server, tests, science/YAML, model
  defaults, Practical 2 mode, assessment design, Moodle state, student contact,
  hosting/service/DNS/TLS/Docker/account/credential/student-workspace state,
  public/student release state, KPZ314 material, dependency, external-service,
  remote-state, commit, push, merge, PR, or Goal 033 work was performed.

Status: Goal 032 student launch package and student-zero rehearsal complete
and left uncommitted for orchestrator review.
