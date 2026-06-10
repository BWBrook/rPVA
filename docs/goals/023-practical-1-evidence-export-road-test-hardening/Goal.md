# Goal 023: Practical 1 Evidence Export And Road-Test Hardening

## Objective

Make the existing Practical 1 Shiny concept lab road-test useful by adding a
small, student-downloadable evidence export path and the supporting tests and
teaching notes, without adding deployment, persistence, authentication, or
service changes.

The completed state is that a student can run the Practical 1 app locally,
compare teaching runs, download compact evidence from the session, and use that
evidence in the Woodhen practical/report workflow.

## Why This Matters

Goals 017-022 moved the project close to hosted delivery, but the current
student-facing product still has a product gap: it can show concept-lab results
in a browser, but it does not yet give students a clean way to retain evidence
from the Compare/Transfer flow.

Do this before ShinyProxy/service work. A compact export path reduces pressure
on account, identity, and persistent workspace design for the first road test,
and makes a later hosted staging goal more valuable than merely putting the MVP
behind a URL.

## Operating Mode

Implementation sprint plus teaching-product hardening.

## Review Surface

The rPVA orchestrator will review:

- code diff for the Practical 1 app and any small helper functions;
- updated teaching/app documentation;
- Goal 023 `Log.md`;
- focused and full R validation output;
- browser-visible local Shiny smoke evidence, including export/download
  evidence;
- final git status and changed-file list.

## Scope

In scope:

- add a compact evidence export/download path to `inst/shiny/practical1/`;
- include enough run settings and comparison output for a student to cite what
  they did;
- keep the export session-local and small;
- update the app or teaching notes so students/demonstrators know what to save;
- add focused tests for export helpers or app wiring;
- run a local browser-visible smoke that exercises the export path.

Out of scope:

- ShinyProxy installation or configuration;
- nginx, systemd, firewall, DNS, TLS, Docker daemon/service, account, token,
  credential, class workspace, or external-access changes;
- remote writes or remote service operations on `deep-server`;
- public, campus, tailnet, or student-facing exposure;
- Practical 2 Woodhen app mode;
- assessment redesign beyond explaining how to use the export artefact;
- scenario/YAML changes or research-grade Lord Howe woodhen analysis;
- new heavy dependencies;
- commits or pushes.

## Read First

- `README.md` - top-level package and teaching entry point.
- `docs/codex/thread-handoff-2026-06-04.md` - prior app and validation
  handoff.
- `docs/goals/016-practical-1-shiny-interaction-qa/Goal.md`
- `docs/goals/016-practical-1-shiny-interaction-qa/Log.md`
- `docs/goals/016-practical-1-shiny-interaction-qa/qa-report.md`
- `docs/goals/021-staging-gate-runbook/Goal.md`
- `docs/goals/022-local-remote-staging-validation/Goal.md`
- `docs/goals/022-local-remote-staging-validation/Log.md`
- `docs/teaching/shiny/practical-1-design-brief.md`
- `docs/teaching/shiny/implementation-roadmap.md`
- `docs/teaching/shiny/road-test-operations-plan.md`
- `docs/teaching/shiny/student-workspace-and-export-design.md`
- `docs/teaching/woodhen/README.md`
- `docs/teaching/woodhen/classroom-dry-run-checklist.md`
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
codex/rpva-goal023-evidence-export-hardening
```

Treat any unexpected dirty state as project state. Do not clean, restore, or
overwrite it unless it is clearly your own failed intermediate output.

## Git And Publication Policy

- Work on the existing local branch
  `codex/rpva-goal023-evidence-export-hardening`.
- Do not commit.
- Do not push.
- Do not open a PR.
- Keep a precise changed-file list in `Log.md` and final response.

The orchestrator will review the uncommitted result before deciding whether a
separate publication goal is needed.

## Data, Compute, And Staging Policy

- Work locally in `/Users/bwbrook/git/rPVA`.
- Use the Mac mini only.
- Do not SSH to `deep-server` for this goal.
- Do not build Docker images or launch containers.
- Do not write to `/data/codex`.
- The app may use temporary files under `tempdir()` for downloads, but ordinary
  app construction and use must not write into the repository.
- Exported evidence should be compact: tables, settings records, short text,
  and optionally small plots. Do not export raw full trajectory arrays by
  default.

## Required Work

1. Design the smallest useful export contract.
   - It must include the current comparison table or equivalent.
   - It must include settings/provenance sufficient to understand what changed
     between runs.
   - It must include a short explanation or prompt reminding students that the
     artefact is evidence, not an answer.
   - Prefer existing package dependencies. If a single zip bundle is fragile or
     would require a new dependency, use clearly labelled separate downloads.

2. Implement the export path.
   - Place UI where students naturally look after comparing runs.
   - Keep labels plain and teaching-oriented.
   - Preserve the existing Start -> Concept Lab -> Compare -> Transfer flow.
   - Avoid server-side persistence, accounts, or student workspace assumptions.

3. Add tests.
   - Test any helper that builds export content.
   - Test that app construction remains non-writing.
   - Extend `tests/testthat/test-13_practical1_shiny.R` or add a focused test
     file if cleaner.

4. Update docs.
   - Update `inst/shiny/practical1/README.md` if the app behaviour changes.
   - Update the relevant teaching Shiny and/or Woodhen teaching notes so
     demonstrators know what students should save.
   - Avoid broad rewrites.

5. Prove the result in a browser.
   - Launch Practical 1 Shiny locally on `127.0.0.1`.
   - Run the baseline and at least one non-baseline stage.
   - Open Compare.
   - Trigger the export/download path.
   - Inspect the downloaded artefact(s) for expected markers.
   - Stop the app and confirm the port is no longer listening.

Use the in-app Browser if available. If not, use Playwright/Chromium or another
local browser automation fallback and record the fallback.

## Validation Gates

The goal is not complete until these pass, or a blocker is logged with exact
evidence:

```sh
git status --short --branch
git diff --check
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R")'
Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter = "summary")'
```

Also run:

- a marker scan over changed/new tracked text for unresolved implementation
  markers;
- a secret-pattern scan over changed/new tracked text and manual review of all
  hits;
- the browser-visible local Shiny export smoke described above.

No remote validation is required for this goal.

## Deliverables

- updated Practical 1 Shiny app and/or helper code;
- focused tests for export behaviour;
- targeted teaching/app documentation updates;
- updated `docs/goals/023-practical-1-evidence-export-road-test-hardening/Log.md`;
- final report to the rPVA orchestrator with validation evidence, changed files,
  residual risks, and recommended next action.

## Decision Authority

You may decide:

- whether the export is a single bundle or separate downloads, based on
  robustness and dependency cost;
- whether export-building helpers belong in the Shiny app file or a small
  package helper;
- the exact student-facing wording, provided it is concise and does not imply
  the export is an answer;
- the minimal tests needed to prove the behaviour.

Pause before:

- adding a new dependency;
- changing public package APIs or `NAMESPACE`;
- changing scientific defaults, scenarios, YAML files, or stochastic engine
  behaviour;
- implementing accounts, persistent workspaces, remote deployment, or service
  configuration;
- changing assessment design beyond export-use wording;
- committing, pushing, or opening a PR.

## Checkpoint Rules

Checkpoint to the rPVA orchestrator if:

- the export cannot be made robust without a new dependency;
- browser automation cannot exercise downloads;
- validation failures appear unrelated to your changes;
- the app needs design choices that affect assessment or teaching policy.

## Stop Conditions

Stop when one of these is true:

- validation passes and deliverables are produced;
- a scope boundary is reached and direction is needed;
- the same blocker repeats and no meaningful progress is possible without
  orchestrator or Barry input.

## Final Response Requirements

Report:

- starting branch/HEAD/status;
- what changed and why;
- exact export artefact shape;
- files changed;
- validation commands and outcomes;
- browser smoke evidence and cleanup result;
- whether any dependencies, public APIs, scenarios, services, or remote state
  changed;
- final `git status --short --branch`;
- recommended next action.
