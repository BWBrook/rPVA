# rPVA Thread Handoff - 2026-06-04

This note is for the next Codex/action agent picking up `rPVA` after this
thread is closed and archived during the orchestration-location migration.

Do not treat this note as a new goal packet. It is a handoff snapshot only.

## Current Repo State

- Working repo: `/Users/bwbrook/git/rPVA`.
- Current branch: `main`.
- Before this handoff note was created, `main` was even with `origin/main`.
- Latest pushed commit before this handoff note:
  `3df260e Harden Practical 1 Shiny interactions`.
- `git status --short --branch --ignored=matching` before this note showed:
  - `## main...origin/main`
  - `!! renv/staging/`
- `renv/staging/` is ignored and has been a recurring harmless local artefact.
  Do not clean or stage it just because it appears in ignored status output.
- No repo-local `AGENTS.md` was found in this checkout during the recent goal
  runs. Use Barry's global Mac mini instructions, then local repo docs and goal
  packets.

After this note is created, the only expected dirty repo item should be this
new handoff file unless Barry or another agent has made further changes.

## Recent Published Work

Recent pushed commits on `main`:

- `3df260e` - `Harden Practical 1 Shiny interactions`
- `36b36d2` - `Add Practical 1 Shiny MVP scaffold`
- `21ca23a` - `Record Goal 014 publication result`
- `0e47fcd` - `Add Practical 1 teaching API adapter`
- `13b2a52` - `Publish woodhen teaching and Shiny planning`
- `26764ad` - `Publish Goal 009 classroom dry-run audit`
- `f5c569e` - `Publish Goal 008 teaching render readiness`
- `4649ac9` - `Publish Goals 004-007 teaching and diagnostics work`

The important practical meaning is that the Woodhen teaching materials,
assessment planning stack, Practical 1 teaching API, and first Practical 1
Shiny MVP are now all on `main`.

## Key Local Sources Of Truth

Read these before making future changes:

- `README.md`
- `bootstrap.R`
- `DESCRIPTION`
- `renv.lock`
- `docs/teaching/woodhen/`
- `docs/teaching/shiny/README.md`
- `docs/teaching/shiny/practical-1-design-brief.md`
- `docs/teaching/shiny/implementation-roadmap.md`
- `docs/teaching/shiny/deep-server-hosting-feasibility.md`
- `docs/teaching/shiny/platform-options-decision-matrix.md`
- `docs/teaching/shiny/road-test-operations-plan.md`
- `docs/goals/014-publication-hygiene-and-clean-push/Log.md`
- `docs/goals/015-practical-1-shiny-mvp-scaffold/Log.md`
- `docs/goals/016-practical-1-shiny-interaction-qa/Log.md`
- `docs/goals/016-practical-1-shiny-interaction-qa/qa-report.md`

For any future goal packet, read that goal's `Goal.md`, `Plan.md`,
`Runbook.md`, and `Log.md` first and treat the packet as the active contract.

## Practical 1 Shiny State

The package now has a base Shiny MVP for Practical 1:

- Launcher: `run_practical1_shiny()`
- App path: `inst/shiny/practical1/`
- Main app files:
  - `inst/shiny/practical1/app.R`
  - `inst/shiny/practical1/www/styles.css`
  - `inst/shiny/practical1/README.md`
- Focused tests: `tests/testthat/test-13_practical1_shiny.R`

The implemented student flow is:

`Start -> Concept Lab -> Compare -> Transfer`

Implemented stages in the app are:

- `deterministic_baseline`
- `carrying_capacity`
- `demographic_stochasticity`
- `environmental_stochasticity`
- `genetic_stochasticity`
- `catastrophe`
- `intervention`
- `extinction_vortex`

Deferred concepts remain visible only as future concepts:

- `allee_effect`
- `correlated_events`

Do not implement the deferred features casually. They are deferred because the
engine does not yet expose named formal features for them.

## Goal 016 Browser QA Evidence

Goal 016 performed a real browser QA pass and hardening sweep.

Final evidence is in:

- `docs/goals/016-practical-1-shiny-interaction-qa/qa-report.md`
- `docs/goals/016-practical-1-shiny-interaction-qa/evidence/`

The final Goal 016 browser pass confirmed:

- Start screen loaded.
- All 8 implemented stages ran with matching summaries.
- Compare had 9 rows before reset and 1 row after reset.
- Transfer showed 3 prompt questions and 2 deferred/future concepts.
- Mobile-width Concept Lab layout was coherent.
- No visible Shiny errors were detected.

Goal 016 fixes included:

- Server-rendering the risk plot panel instead of using a fragile
  client-side `conditionalPanel()` around `output.showExtinctionPlot`.
- Resetting the selected Concept Lab stage when Compare reset is clicked.
- Aligning the deterministic baseline slider default with the teaching API's
  25-year default.
- Collecting only visible controls for the selected stage, avoiding stale
  hidden-control leakage between stage runs.
- Wrapping long settings/comparison table values in narrow layouts.

## Validation Baseline

Latest validation evidence from Goal 016:

- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R")'`
  passed with 27 assertions.
- `Rscript -e 'source("bootstrap.R"); testthat::test_local()'` passed with
  201 assertions.
- `Rscript -e 'source("bootstrap.R"); renv::status()'` reported no issues.
- `git diff --check` passed.
- Goal 016 marker scan had only intentional hits in the goal packet text where
  the scan command itself is quoted.
- Shiny port `3862` had no listener after shutdown.

Use `source("bootstrap.R")` before R validation. This repo expects one host R
with project-local `renv`.

## Teaching And Platform Direction

The current product direction is teaching-first:

- rPVA is being shaped into a zero-to-hero teaching tool.
- The near-term teaching path is a Practical 1 concept lab followed by the
  Woodhen Practical 2 workflow.
- The app should teach interpretation rather than file mechanics.
- Keep local/instructor launch available even if hosted delivery is pursued.

Current platform direction from the Shiny planning docs:

- Browser-first hosted Practical 1 delivery remains the preferred direction for
  the 2026 road test.
- `deep-server` remains the leading candidate host for a self-managed platform.
- ShinyProxy backed by Docker is the preferred self-managed platform candidate.
- Posit Connect is a fallback only if UTAS provides a supported installation.
- Student-facing exposure, TLS, accounts/tokens, quotas, cleanup, monitoring,
  and fallback procedures still need deliberate planning before service work.

Always verify live route/service state before relying on it. Previous route
and gateway observations are useful context, not a guarantee of current state.

## Thread And Orchestration Context

This action thread handled a long sequence of rPVA goal-packet execution and
publication work, especially Goals 004 through 016. Barry is now doing a
wholesale migration and re-organisation of orchestration locations and
management, so future work may arrive through a different supervisor or project
manager path rather than this archived thread.

Relevant relationship model to preserve:

- Barry remains Lab Leader / CTO.
- Supervisor/project-manager/orchestrator layers may be reorganised outside
  this repo.
- This repo is the action repo, not the supervisor workspace.
- `docs/goals/` packets are the local action contracts.
- `docs/codex/` is the visible place for audit notes and handoffs like this
  one.
- Do not assume old thread IDs, native thread tools, or formal goal-tool state
  still work after migration.

During Goal 016, the formal goal tool still showed the completed Goal 015
record, so Goal 016 was executed as behavioural goal delegation with
`docs/goals/016-practical-1-shiny-interaction-qa/Log.md` as the audit trail.
Treat that as a caveat about tool state, not as a repo problem.

Browser/IAB was unavailable in this thread during Goals 015 and 016. The
accepted fallback was local browser automation:

- Goal 015 used a Chrome/headless fallback.
- Goal 016 used Playwright Chromium via a temporary `/tmp` script.

Temporary scripts and temp Node packages were removed after Goal 016. The
committed screenshots and QA report are the durable evidence.

## Risks And Caveats

- Do not start ShinyProxy, deployment, authentication, persistent student
  workspace, usage tracing, Practical 2 app mode, scenario YAML, or engine
  behaviour work without a fresh explicit goal or Barry directive.
- Do not assume the current app is deployment-ready. It is a local MVP with
  browser QA evidence, not a hosted service.
- Do not edit assessment drafts or Woodhen teaching docs unless the next goal
  explicitly permits that surface.
- Do not change `DESCRIPTION`, `renv.lock`, generated `man/`, or package
  metadata just to make a handoff or orchestration change.
- If roxygen or package check requires temporary tooling, install it narrowly
  in `renv` with `record = FALSE`, clean up afterward, and confirm
  `renv::status()`.
- Marker scans often intentionally hit goal/runbook files because they quote
  the validation command. Review hits before "fixing" them.
- `renv/staging/` is ignored and can remain ignored.
- Use `rg` for searches. On this Mac, plain `rg` needs `--pcre2` for
  lookarounds.

## Recommended Next Actions

Do not start these from this handoff alone. They are candidate next lanes for
Barry/supervisor approval:

1. Create a narrow Goal 017 for Practical 1 deployment-readiness decisioning.
   Keep it design/ops-first: confirm platform path, route/TLS/account model,
   load-test shape, support boundaries, and rollback/fallback plan before any
   service edits.
2. If Goal 017 authorises probes, re-read the Mac mini global AGENTS context
   and the Nectar control-plane docs before touching remote hosts:
   - `/Users/bwbrook/work/nectar/docs/workflows/control-plane-doctrine.md`
   - `/Users/bwbrook/work/nectar/docs/workflows/compute-resource-selection.md`
   - `/Users/bwbrook/work/nectar/docs/workflows/project-integration.md`
   - `/Users/bwbrook/work/nectar/docs/workflows/data-placement.md`
   - `/Users/bwbrook/work/nectar/docs/exchange/current_status.md`
3. Keep any future Shiny deployment task separate from app pedagogy/content
   work. The current app is intentionally small and dependency-light.
4. Consider a later, separate teaching QA goal for instructor-facing rehearsal
   once the hosted route is chosen.

## What Not To Do On First Pickup

- Do not run a broad refactor.
- Do not change package code unless a new goal packet says to.
- Do not start remote services.
- Do not edit scenario YAML.
- Do not make ShinyProxy or Docker service files opportunistically.
- Do not commit or push this handoff note unless Barry or the new orchestration
  process asks for publication.
