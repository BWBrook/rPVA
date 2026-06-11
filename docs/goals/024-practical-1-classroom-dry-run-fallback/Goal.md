# Goal 024: Practical 1 Classroom Dry Run And Fallback Pack

## Objective

Run a thorough local dress rehearsal of the Practical 1 Shiny concept lab as a
student and demonstrator would experience it, then harden the teaching notes and
fallback materials enough that the class objective survives even if hosted Shiny
is not ready.

The completed state is that the repo contains an evidence-backed dry-run report,
updated classroom/demonstrator guidance, and a lightweight Practical 1 fallback
pack or fallback-pack index. The work should make the next deployment/staging
goal safer by proving the local teaching workflow first.

## Why This Matters

Goal 023 made the app more useful by adding compact evidence downloads. Before
we spend effort on ShinyProxy, nginx, accounts, or student URLs, we should prove
that the local browser workflow is pedagogically coherent and operationally
recoverable. A class-facing service is only worth exposing if the teaching path
and fallback path are already crisp.

## Operating Mode

Teaching-product dress rehearsal plus documentation hardening.

This is not a deployment goal.

## Review Surface

The rPVA orchestrator will review:

- Goal 024 `Log.md`;
- the dry-run report and/or fallback-pack document created by this goal;
- updates to classroom, instructor, troubleshooting, or Shiny teaching docs;
- any small UI or wording fixes, if the dry run exposes them;
- browser evidence from the local Practical 1 flow;
- render/export evidence;
- final git status and changed-file list.

## Scope

In scope:

- local Practical 1 Shiny dress rehearsal from a fresh browser session;
- Chrome-based testing if the Chrome plugin/browser surface is available;
- Computer Use as a fallback for local GUI-level checks if Chrome is blocked;
- in-app Browser or Playwright/Chromium fallback if plugin browser control is
  unavailable, with the fallback recorded;
- baseline plus staged Concept Lab runs;
- Compare and Transfer view checks;
- comparison CSV and evidence-notes download checks;
- report scaffold render checks;
- small teaching-doc, checklist, troubleshooting, or UI-wording fixes that make
  the classroom path clearer;
- lightweight static fallback pack or fallback-pack index for Practical 1.

Out of scope:

- ShinyProxy installation or configuration;
- nginx, systemd, firewall, DNS, TLS, Docker daemon/service, account, token,
  credential, class workspace, or external-access changes;
- SSH, remote writes, remote validation, or remote service operations on
  `deep-server`;
- public, campus, tailnet, or student-facing exposure;
- Practical 2 Shiny app mode;
- assessment redesign;
- scenario/YAML changes or research-grade Lord Howe woodhen analysis;
- new heavy dependencies;
- commits, pushes, PRs, or merges.

## Read First

- `README.md`
- `docs/codex/thread-handoff-2026-06-04.md`
- `docs/goals/016-practical-1-shiny-interaction-qa/Goal.md`
- `docs/goals/016-practical-1-shiny-interaction-qa/Log.md`
- `docs/goals/016-practical-1-shiny-interaction-qa/qa-report.md`
- `docs/goals/022-local-remote-staging-validation/Goal.md`
- `docs/goals/022-local-remote-staging-validation/Log.md`
- `docs/goals/023-practical-1-evidence-export-road-test-hardening/Goal.md`
- `docs/goals/023-practical-1-evidence-export-road-test-hardening/Log.md`
- `docs/teaching/shiny/README.md`
- `docs/teaching/shiny/practical-1-design-brief.md`
- `docs/teaching/shiny/implementation-roadmap.md`
- `docs/teaching/shiny/road-test-operations-plan.md`
- `docs/teaching/shiny/student-workspace-and-export-design.md`
- `docs/teaching/woodhen/README.md`
- `docs/teaching/woodhen/practical-1-pva-foundations.md`
- `docs/teaching/woodhen/practical-2-woodhen-management.md`
- `docs/teaching/woodhen/classroom-dry-run-checklist.md`
- `docs/teaching/woodhen/expected-outputs.md`
- `docs/teaching/woodhen/instructor-guide.md`
- `docs/teaching/woodhen/troubleshooting.md`
- `docs/teaching/woodhen/report-scaffold.qmd`
- `inst/shiny/practical1/README.md`
- `inst/shiny/practical1/app.R`
- `R/shiny_practical1.R`
- `R/teaching_api.R`
- `tests/testthat/test-12_teaching_api.R`
- `tests/testthat/test-13_practical1_shiny.R`

There is no repo-local `AGENTS.md` in this checkout. Use the repo-local files
above plus Barry's global Mac mini instructions.

## Starting State Checks

Before editing, report in `Log.md` and final response:

```sh
pwd
git branch --show-current
git rev-parse --short HEAD
git status --short --branch
```

Expected branch at handoff:

```text
codex/rpva-goal024-classroom-dry-run
```

Expected starting base:

```text
3b61507 Add Practical 1 evidence export hardening
```

Treat any unexpected dirty state as project state. Do not clean, restore, or
overwrite it unless it is clearly your own failed intermediate output.

## Git And Publication Policy

- Work on `codex/rpva-goal024-classroom-dry-run`.
- Do not commit.
- Do not push.
- Do not open a PR.
- Keep a precise changed-file list in `Log.md` and final response.

The orchestrator will review the uncommitted result before deciding whether a
separate closeout commit/publish goal is needed.

## Data, Browser, And Compute Policy

- Work locally in `/Users/bwbrook/git/rPVA`.
- Use the Mac mini only.
- Use local temporary directories under `/tmp` or `tempdir()` for generated
  evidence that should not be committed.
- Commit only small, useful teaching artefacts if they are intentionally part
  of the fallback pack.
- Do not SSH to `deep-server`.
- Do not build Docker images or launch containers.
- Do not write to `/data/codex`.
- Do not use live student, account, credential, or external web state.

Browser hierarchy for the dress rehearsal:

1. Prefer the Chrome plugin against the local Shiny URL if available.
2. If Chrome plugin control is unavailable, record the exact blocker and use
   in-app Browser or Playwright/Chromium.
3. Use Computer Use only as a fallback for local GUI-level checks when the
   browser automation surface cannot prove the needed visible behaviour.

Do not use Computer Use to change system settings, accept security interstitials,
enter credentials, transmit data, or interact with external services.

## Required Work

1. Run the local teaching dry run.
   - Launch Practical 1 Shiny on `127.0.0.1`.
   - Start from a fresh browser session.
   - Run the baseline.
   - Exercise the staged Concept Lab path, including at least carrying
     capacity, demographic or environmental stochasticity, genetics or
     catastrophe, and one intervention or combined-risk stage if implemented.
   - Open Compare with at least three runs.
   - Confirm the Compare table is readable or horizontally scrollable.
   - Download comparison CSV and evidence-notes Markdown.
   - Open Transfer and check the teaching prompt makes sense after the run.

2. Run a demonstrator-style non-Shiny check.
   - Run the Practical 1 command-line checkpoints from the dry-run checklist.
   - Confirm expected outputs are close to `expected-outputs.md`, or record any
     justified difference.
   - Render the report scaffold to DOCX.
   - Attempt PDF render and record the result. A PDF toolchain issue is a setup
     finding, not automatically a blocker if DOCX succeeds.

3. Test classroom rough edges.
   - Try at least one rapid-click, backtracking, or rerun path in the Shiny app.
   - Check that app use does not write ordinary runtime artefacts into the repo.
   - Check that downloaded evidence is understandable without the live app open.
   - Record confusing labels, missing instructions, or likely student
     misunderstandings.

4. Create or update the fallback pack.
   - Provide a lightweight Practical 1 fallback document or index under
     `docs/teaching/woodhen/` or `docs/teaching/shiny/`.
   - Include enough static material or commands for a demonstrator to continue
     teaching if Shiny is unavailable.
   - Include pointers to expected output tables, representative screenshots or
     `/tmp` screenshot paths, and the export artefact shape.
   - Avoid bulky generated outputs. Keep committed artefacts small and
     intentionally useful.

5. Update teaching docs narrowly.
   - Update `classroom-dry-run-checklist.md`, `troubleshooting.md`,
     `instructor-guide.md`, Shiny docs, or app README only where the rehearsal
     proves a needed improvement.
   - Avoid broad rewrites.

6. Write the Goal 024 dry-run report.
   - Create a concise evidence report under this goal directory, for example
     `dry-run-report.md`.
   - Include commands, browser path, artefact paths, observed friction,
     changes made, unresolved risks, and recommendation for the next goal.

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

Run the full test suite if implementation code, teaching API behaviour, or
shared test surfaces change:

```sh
Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter = "summary")'
```

Also run:

- report scaffold DOCX render;
- PDF render attempt, with outcome recorded;
- local browser dress rehearsal;
- comparison CSV and evidence-notes content checks;
- before/after repo status check around app use;
- marker scan over changed/new tracked text for unresolved implementation
  markers;
- secret-pattern scan over changed/new tracked text and manual review of all
  hits.

No remote validation is required for this goal.

## Deliverables

- updated `docs/goals/024-practical-1-classroom-dry-run-fallback/Log.md`;
- Goal 024 dry-run report, likely `dry-run-report.md`;
- updated classroom/demonstrator docs and/or Shiny docs as warranted;
- lightweight fallback pack or fallback-pack index;
- browser evidence paths and export artefact checks;
- final report to the rPVA orchestrator with validation evidence, changed
  files, residual risks, and recommended next action.

## Decision Authority

You may decide:

- the exact local port used for Shiny testing;
- the browser-control fallback path if Chrome plugin control is unavailable;
- which small documentation updates are needed after the rehearsal;
- whether the fallback pack should be a single document, an index plus sample
  files, or a small directory of static artefacts;
- whether a small UI wording fix is justified by the dry run.

Pause before:

- adding a new dependency;
- changing public package APIs or `NAMESPACE`;
- changing scientific defaults, scenarios, YAML files, stochastic engine
  behaviour, or expected-output truth values;
- adding authentication, persistence, workspaces, remote deployment, service
  configuration, accounts, or credentials;
- changing assessment design;
- committing, pushing, or opening a PR.

## Checkpoint Rules

Checkpoint to the rPVA orchestrator if:

- the dry run exposes a scientific or assessment-design ambiguity rather than a
  wording/workflow issue;
- browser automation cannot exercise the local app with any available local
  method;
- report scaffold rendering fails in both DOCX and PDF;
- a useful fallback pack seems to require large binary artefacts or a new
  dependency;
- repo state diverges unexpectedly;
- validation fails for reasons outside this goal's scope.
