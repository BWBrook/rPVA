# Log

## 2026-06-11 - Orchestrator Packet Creation

- Goal 029 was accepted, committed, and published to `origin/main` before this
  branch was created.
- Starting base for Goal 030:
  - branch: `codex/rpva-goal030-mission-app-affordances`;
  - base commit:
    `9d2504b Add Practical 1 mission tutorial curriculum`;
  - source: `origin/main`.
- Barry authorized proceeding from the Goal 029 closeout recommendation.
- Goal purpose:
  - add small app-visible mission-mode affordances that support the Goal 029
    Practical 1 tutorial;
  - preserve the existing Start -> Concept Lab -> Compare/export -> Transfer
    flow;
  - preserve the existing science, export contract, and hosting boundary;
  - prove the result with focused tests and a local browser smoke.
- Boundary:
  - local Shiny app/text/CSS/docs/test polish only;
  - no science/YAML/model-default changes, Practical 2 mode, assessment
    redesign, hosting/service/DNS/TLS/Docker/account/credential/student
    workspace work, student release, KPZ314 materials, external contact,
    commit, push, merge, or PR work.
- Packet files:
  - `docs/goals/030-practical-1-mission-mode-app-affordance-polish/Goal.md`
  - `docs/goals/030-practical-1-mission-mode-app-affordance-polish/Plan.md`
  - `docs/goals/030-practical-1-mission-mode-app-affordance-polish/Runbook.md`
  - `docs/goals/030-practical-1-mission-mode-app-affordance-polish/Log.md`

Status: packet ready for `woodhen`; execution not yet started.

## 2026-06-11 - woodhen Execution

Start guard:

- `pwd`: `/Users/bwbrook/git/rPVA`
- branch: `codex/rpva-goal030-mission-app-affordances`
- `HEAD`: `9d2504b8b79bb6e74169cdb04764a71d48751574`
- short `HEAD`: `9d2504b`
- starting status:
  - `## codex/rpva-goal030-mission-app-affordances`
  - `?? docs/goals/030-practical-1-mission-mode-app-affordance-polish/`
- The expected Goal 029 closeout base was present:
  `9d2504b Add Practical 1 mission tutorial curriculum`.
- No unexpected dirty state was present before editing beyond the Goal 030
  packet.

Sources read:

- Goal 030 packet: `Goal.md`, `Plan.md`, `Runbook.md`, `Log.md`
- `README.md`
- `docs/teaching/shiny/README.md`
- `docs/teaching/shiny/practical-1-design-brief.md`
- `docs/teaching/shiny/practical-1-mission-tutorial.md`
- `docs/teaching/shiny/implementation-roadmap.md`
- `docs/teaching/woodhen/README.md`
- `docs/teaching/woodhen/practical-1-mission-worksheet.md`
- `docs/teaching/woodhen/practical-1-instructor-beat-sheet.md`
- `docs/goals/029-practical-1-mission-tutorial-curriculum/Goal.md`
- `docs/goals/029-practical-1-mission-tutorial-curriculum/pedagogy-review.md`
- `inst/shiny/practical1/README.md`
- `inst/shiny/practical1/app.R`
- `inst/shiny/practical1/www/styles.css`
- `R/teaching_api.R`
- `tests/testthat/test-12_teaching_api.R`
- `tests/testthat/test-13_practical1_shiny.R`

Implementation:

- Added a focused structural test in
  `tests/testthat/test-13_practical1_shiny.R` for mission-mode classroom
  guidance.
- Confirmed the new test failed before app text was added; the focused Shiny
  test reported six expected missing-text failures for:
  - `Mission 1: Baseline compass`;
  - run-1 baseline wording;
  - one-visible-control guidance;
  - clean baseline/risk/intervention-or-vortex comparison guidance;
  - repeated-click warning;
  - deterministic-baseline recovery framing.
- Added small mission-mode affordances to `inst/shiny/practical1/app.R`:
  - named mission/progress labels for the eight implemented Practical 1 stages;
  - Start-screen wording that `Start baseline` creates or restores baseline
    run 1 for later comparison;
  - Concept Lab guidance to change one visible control at a time, then
    compare;
  - deterministic-baseline guidance that frames rerunning it only as recovery
    after resetting comparison;
  - Compare guidance for a clean baseline run 1, one risk mechanism, and one
    intervention or vortex run;
  - repeated-click warning.
- Added lightweight `.mission-cue` CSS in
  `inst/shiny/practical1/www/styles.css`.
- Added narrow documentation pointers in:
  - `inst/shiny/practical1/README.md`;
  - `docs/teaching/shiny/README.md`.

Browser smoke:

- Browser path: Playwright/Chromium through the local Codex Playwright wrapper.
- Local URL: `http://127.0.0.1:3897/`
- Path exercised:
  - Start baseline;
  - carrying capacity;
  - environmental stochasticity;
  - catastrophe;
  - simple intervention;
  - Compare guidance and table;
  - comparison CSV download;
  - evidence-notes Markdown download;
  - Transfer screen.
- Screenshots:
  - `/tmp/rpva-goal030-browser/start-mission.png`
  - `/tmp/rpva-goal030-browser/concept-mission.png`
  - `/tmp/rpva-goal030-browser/compare-mission.png`
  - `/tmp/rpva-goal030-browser/transfer-mission.png`
- Downloaded browser evidence:
  - `/tmp/rpva-goal030-browser/practical1-comparison-goal030.csv`
  - `/tmp/rpva-goal030-browser/practical1-evidence-notes-goal030.md`
- Export-shape confirmation:
  - comparison CSV still begins with
    `run_id, stage, label, scenario, years, reps, PE, Nmed, Nlo95, Nhi95,
    extinct_reps, surviving_reps, trajectory_available`;
  - evidence notes still contain the Practical 1 evidence-notes title, generated
    timestamp, run count, fixed teaching seed, comparison table, settings and
    provenance, interpretation prompts, and the "evidence, not an answer"
    wording.
- Browser console note:
  - one non-blocking `favicon.ico` 404 was observed; no app JavaScript failure
    was observed.
- The Shiny app was stopped after the smoke, and
  `lsof -nP -iTCP:3897 -sTCP:LISTEN` returned no listener.

Validation completed before this log update:

- `git diff --check`: pass.
- `Rscript -e 'source("bootstrap.R")'`: pass.
- `Rscript -e 'renv::status(sources = FALSE)'`: pass, no issues.
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'`:
  pass.
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'`:
  pass.

Changed files at log time:

- `docs/teaching/shiny/README.md`
- `inst/shiny/practical1/README.md`
- `inst/shiny/practical1/app.R`
- `inst/shiny/practical1/www/styles.css`
- `tests/testthat/test-13_practical1_shiny.R`
- `docs/goals/030-practical-1-mission-mode-app-affordance-polish/`

Boundaries observed:

- No model/science/YAML defaults changed.
- No Practical 2 mode, assessment design, hosting, ShinyProxy, nginx, systemd,
  firewall, DNS, TLS, Docker/service state, account, credential, student
  workspace, public/student release, KPZ314, remote-state, or external-service
  work was performed.
- No dependencies were added.
- No commit, push, PR, merge, or Goal 031 work was performed.

Status: implementation complete locally; final scans and final status still to
be recorded below.

Final validation after log update:

- `git status --short --branch` showed only the accepted Goal 030 changed files
  plus the untracked Goal 030 packet directory.
- `git diff --check`: pass.
- `Rscript -e 'source("bootstrap.R")'`: pass.
- `Rscript -e 'renv::status(sources = FALSE)'`: pass, no issues.
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'`:
  pass.
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'`:
  pass.
- Marker scan over changed and untracked text: no hits.
- Secret/private-key-pattern scan over changed and untracked text: hits were
  limited to policy wording, scan-command text, existing class-account/token
  boundary wording, and credential/private-key safety wording in docs and the
  Goal 030 packet. No secret value, private key, student identifier, or
  sensitive service payload was present.
- Stricter assignment/private-key-block scan: no hits.
- Targeted duplicate-baseline wording search found no remaining instruction
  telling students to run `Deterministic baseline` again after
  `Start baseline`.

Final status: complete locally and left uncommitted for orchestrator review.
