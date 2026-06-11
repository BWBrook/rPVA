# Goal 031: Practical 1 Delivery-Candidate Rehearsal Pack

## Objective

Run the current Practical 1 teaching product as a coherent delivery candidate
and package it for class use, while keeping hosted-route, TLS, account, and
student-release decisions outside this goal.

The completed state is a repo-local delivery pack that tells Barry and
demonstrators exactly how to run Practical 1 with the mission-mode app, what
students should open, what Barry should say at each pause, what evidence
students must leave with, what to do if app/download trouble occurs, and which
checks belong to local/in-room teaching readiness versus hosted student URL
release.

This is a classroom delivery-rehearsal and teaching-packaging goal. It is not a
new app-feature goal and not a deployment goal.

## Why This Matters

Goals 029 and 030 made the Practical 1 teaching path coherent: an app-led
mission tutorial, a lightweight worksheet, an instructor beat sheet, and
browser-visible mission affordances. The next useful step is to rehearse those
pieces together as a class package and close the last delivery gaps we control
before waiting on campus IT/TLS decisions.

This goal should answer: if the class were tomorrow and the app were reachable
locally or through the current staged route, what exactly should Barry and the
students do?

## Operating Mode

Docs and delivery-pack hardening plus local browser rehearsal.

No live service changes.

## Review Surface

The rPVA orchestrator will review:

- Goal 031 `Log.md`;
- a delivery-candidate report or rehearsal report;
- a day-of-class delivery pack/runbook;
- any print/Moodle-ready worksheet refinements;
- a go/no-go checklist separating local classroom readiness from hosted student
  URL release;
- narrow README/instructor-guide pointers;
- browser evidence through the final mission arc;
- validation output and final changed-file list.

## Scope

In scope:

- local end-to-end rehearsal of the Goal 029/030 Practical 1 path;
- browser-visible smoke through mission-mode app Start -> Concept Lab ->
  Compare/export -> Transfer;
- review of the mission worksheet for print/Moodle usability and light wording
  refinements if needed;
- creation of a concise day-of-class delivery pack for Barry/demonstrators;
- creation of a Practical 1 go/no-go checklist that explicitly separates:
  - local/in-room teaching readiness;
  - hosted route/TLS/student URL readiness;
  - optional fallback/recovery triggers;
- narrow documentation/index updates so the delivery pack is easy to find;
- report-scaffold render checks if relevant to day-of-class evidence handling;
- temporary evidence under `/tmp`.

Out of scope:

- new Shiny features or broad UI redesign;
- app/package code changes unless a tiny wording/doc-link fix is clearly
  necessary and separately justified;
- changes to model/science/YAML defaults, stochastic engine behaviour,
  scenarios, teaching API semantics, or export shape;
- Practical 2 implementation;
- assessment redesign, grading-rubric changes, or AT1 policy changes;
- hosting, ShinyProxy, nginx, systemd, firewall, DNS, TLS, Docker,
  certificates, credentials, class accounts, student workspaces, public/student
  release, or remote state;
- campus-route or student-network proof;
- contacting Barry, Chief, campus IT, students, or external services;
- KPZ314 materials or implementation;
- new dependencies, generated binary artefacts in the repo, commits, pushes,
  PRs, or merges.

## Read First

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

There is no repo-local `AGENTS.md` in this checkout. Use the repo-local files
above plus Barry's global Mac mini instructions and this Goal 031 packet.

Do not read sibling project folders, Chief of Staff, Goal Composer, KPZ314
materials, or archive material.

## Starting State Checks

Before editing beyond this packet, report in `Log.md` and final response:

```sh
pwd
git branch --show-current
git rev-parse --short HEAD
git status --short --branch
```

Expected branch at handoff:

```text
codex/rpva-goal031-delivery-candidate-rehearsal
```

Expected starting base:

```text
d4855fc Add Practical 1 mission-mode app affordances
```

Treat any unexpected dirty state as project state. Do not clean, restore, or
overwrite it unless it is clearly your own failed intermediate output.

## Git And Publication Policy

- Work on `codex/rpva-goal031-delivery-candidate-rehearsal`.
- Do not commit.
- Do not push.
- Do not open a PR.
- Keep a precise changed-file list in `Log.md` and final response.

The orchestrator will review the uncommitted result before deciding whether a
separate closeout commit/publish goal is needed.

## Required Work

1. Prove current starting state.
   - Verify branch/status and expected base.
   - Confirm the Goal 030 closeout commit is present.
   - Confirm no unexpected dirty state exists before editing Goal 031 outputs.

2. Rehearse the delivery path.
   - Launch Practical 1 Shiny locally on `127.0.0.1`.
   - Exercise the mission-mode app as a student would:
     - Start baseline;
     - carrying capacity;
     - demographic or environmental stochasticity;
     - genetics or catastrophe;
     - intervention or extinction vortex;
     - Compare guidance and exports;
     - Transfer.
   - Use the mission worksheet and instructor beat sheet as the rehearsal
     script, not just the app itself.
   - Record timing, friction, and any student-facing confusion.

3. Inspect the student evidence path.
   - Download comparison CSV and evidence-notes Markdown.
   - Confirm export shape is unchanged.
   - Confirm the worksheet has a clear place for students to record the
     exported evidence or fallback equivalent.
   - If useful, render or inspect the worksheet as plain Markdown/PDF/DOCX only
     if the repo already supports the route. Do not add dependencies.

4. Create the day-of-class delivery pack.
   - Create a concise document under `docs/teaching/woodhen/` or the Goal 031
     directory that Barry/demonstrators can use immediately before class.
   - Include:
     - pre-class setup;
     - what students should open;
     - Barry's priming and recap moments;
     - the exact student evidence target;
     - when to switch to fallback;
     - what to collect or ask students to keep;
     - post-class notes to capture.

5. Create a go/no-go checklist.
   - Separate:
     - local/in-room teaching readiness;
     - hosted URL/TLS/student-release readiness;
     - fallback readiness.
   - Make clear that local classroom readiness can be green while hosted
     student release remains blocked by IT/TLS/account gates.
   - Do not imply the current insecure HTTPS route is student-ready.

6. Refine worksheet/delivery docs narrowly if needed.
   - Make the mission worksheet more print/Moodle-ready if the rehearsal shows
     obvious formatting or instruction gaps.
   - Keep it lightweight. Do not turn it into a heavy handout.
   - Update README/instructor-guide pointers only where discoverability needs
     it.

7. Validate.
   - Run the validation gates listed below.
   - Confirm no secrets, credentials, private keys, student identifiers, or
     sensitive service details appear in changed text.

## Suggested Output Files

Use these paths unless a better existing naming pattern is clearly preferable:

- `docs/teaching/woodhen/practical-1-day-of-class-pack.md`
- `docs/teaching/woodhen/practical-1-go-no-go-checklist.md`
- `docs/goals/031-practical-1-delivery-candidate-rehearsal-pack/delivery-rehearsal-report.md`

Small, focused updates to the mission worksheet, instructor guide, Woodhen
README, Shiny README, or classroom dry-run checklist are allowed if justified by
the rehearsal.

## Validation Gates

The goal is not complete until these pass, or a blocker is logged with exact
evidence:

```sh
git status --short --branch
git diff --check
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
```

Also complete:

- browser-visible local Shiny rehearsal described above;
- report scaffold DOCX render if the day-of-class pack relies on it;
- PDF render attempt if practical and already supported, recording any toolchain
  issue as non-blocking when DOCX succeeds;
- marker scan over changed/new tracked text;
- secret/private-key-pattern scan over changed/new tracked text;
- stricter assignment/private-key-block scan.

Do not run remote, service, deployment, campus-route, DNS, TLS, account, or
student-release checks for this goal.

## Stop Rules

Stop and report to the orchestrator if:

- the starting branch/base/status is not as expected;
- the rehearsal reveals that the mission-mode app cannot support the day-of-class
  path without new feature work;
- the day-of-class pack would require service credentials, student identities,
  class accounts, remote state, or IT decisions;
- the work would require model/science changes, assessment redesign, hosting,
  TLS, account, public-release, new dependencies, or external contact;
- the work would require reading sibling project folders, Chief of Staff, Goal
  Composer, KPZ314 materials, or archive material;
- any validation gate fails;
- a real secret, private key, credential, student identifier, or sensitive
  service payload appears in repo files or terminal output.

## Expected Final Report

Report:

- final branch, HEAD, and status;
- changed files;
- where the day-of-class pack, go/no-go checklist, and rehearsal report live;
- browser rehearsal path and evidence locations;
- student evidence/export confirmation;
- render/checklist validation results;
- any local teaching readiness risks;
- any hosted student-release blockers that remain outside this goal;
- validation commands and results;
- explicit confirmation that no app feature, science/YAML, Practical 2,
  assessment, hosting/service, account/credential/student-workspace,
  student-release, KPZ314, commit, push, PR, merge, or Goal 032 work was done.
