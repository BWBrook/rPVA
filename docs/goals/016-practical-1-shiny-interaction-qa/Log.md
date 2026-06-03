# Log

## 2026-06-03 - Supervisor Goal Publication

- Supervisor created Goal 016 after Goal 015 delivered the first Practical 1
  Shiny MVP scaffold.
- Objective: perform student-style browser interaction QA and scoped hardening
  of the MVP before any deployment or class-facing URL work.
- Target flow: app loads -> Start baseline visible -> Concept Lab runs each
  implemented stage -> Compare updates and resets -> Transfer prompts visible
  -> no visible errors, layout breakage, or confusing blank states.
- Model recommendation for action-agent execution: `gpt-5.5` with `high`
  reasoning because this goal requires UI judgement, browser automation,
  debugging, focused fixes, tests, evidence capture, commit, and push.
- Commit/push is authorized only after validation passes.
- Deployment, authentication, workspaces, usage tracing, Practical 2 mode,
  assessment redesign, scenario YAML changes, and engine-behaviour changes are
  out of scope.

## 2026-06-03 - Action-Agent Execution Start

- Confirmed work is on `main` with a clean tracked tree; the only visible
  untracked repo work at start was this Goal 016 packet, plus ignored
  `renv/staging/`.
- Reconfirmed target browser QA flow before launch: app loads -> Start screen
  baseline is visible -> Concept Lab runs each implemented stage -> Compare
  table updates and resets -> Transfer prompts are visible -> no visible
  errors, layout breakage, or confusing blank states.
- Formal goal-tool state did not start a fresh Goal 016 record in this
  destination thread; execution is being treated as behavioural goal
  delegation with this log as the audit trail.
- Browser/IAB probe returned `Browser is not available: iab`; using the
  packet-approved Playwright CLI / temporary Playwright fallback path for real
  browser interaction evidence.

## 2026-06-03 - Browser QA, Fixes, and Validation

- Launched the Practical 1 Shiny MVP locally on `127.0.0.1:3862` and used
  Playwright Chromium via `/tmp/rpva-goal016-clickthrough.cjs` after the IAB
  route was unavailable.
- First browser pass exposed a real app issue: the risk-stage plot used a
  client-side `conditionalPanel()` that produced `Can't read output
  'showExtinctionPlot'` and prevented the extinction/genetics plot from
  appearing reliably.
- Fixed the risk plot by replacing the client-side condition with a
  server-rendered `extinction_plot_panel`.
- Visual mobile QA then exposed a clarity issue after Compare reset: current
  run and selected stage could diverge. Reset now also returns the stage
  selector to the deterministic baseline.
- Visual QA also exposed baseline default mismatch / stale hidden-control
  leakage. The deterministic slider now matches the API default of 25 years,
  and stage runs collect only controls currently visible for the selected
  stage.
- Added table wrapping for settings and comparison output in narrow layouts.
- Added focused Shiny MVP regression tests for risk-panel rendering, reset
  selector alignment, and visible-control collection.
- Wrote `qa-report.md` and captured final evidence screenshots under
  `evidence/`.
- Final Playwright pass: Start loaded, all 8 implemented stages ran with
  matching summaries, Compare had 9 rows before reset and 1 after reset,
  Transfer showed 3 questions and 2 future concepts, mobile screenshot was
  coherent, and no visible Shiny errors were detected.
- Validation passed:
  - `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R")'`
    -> 27 passing assertions.
  - `Rscript -e 'source("bootstrap.R"); testthat::test_local()'` -> 201
    passing assertions.
  - `Rscript -e 'source("bootstrap.R"); renv::status()'` -> no issues.
  - `git diff --check` -> passed.
  - Marker scan found only the literal validation command strings in Goal 016
    `Goal.md` and `Runbook.md`; no unresolved markers were found in app,
    tests, or teaching docs.
  - `lsof -nP -iTCP:3862 -sTCP:LISTEN || true` -> no listener after stopping
    the app server.
