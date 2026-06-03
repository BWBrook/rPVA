# Goal 016 Practical 1 Shiny Interaction QA Report

Date: 2026-06-03

## Scope

Student-style browser QA was run against the Practical 1 Shiny MVP on
`http://127.0.0.1:3862/`, following this target flow:

`app loads -> Start screen baseline is visible -> Concept Lab runs each implemented stage -> Compare table updates and resets -> Transfer prompts are visible -> no visible errors, layout breakage, or confusing blank states`

The in-app browser route was probed first but was unavailable in this
destination thread (`Browser is not available: iab`). The accepted fallback was
Playwright Chromium using the repo-external temporary script
`/tmp/rpva-goal016-clickthrough.cjs`.

## Checklist Result

| Check | Result | Evidence |
| --- | --- | --- |
| Start screen loads with baseline summary | Pass | `evidence/start-after-load.png` |
| Concept Lab runs all 8 implemented stages | Pass | Playwright result recorded matching summaries for all stages |
| Ordinary stochastic stage displays summary and plots | Pass | `evidence/concept-lab-ordinary-stage.png` |
| Risk-focused stage displays extinction/genetics plot | Pass after fix | `evidence/concept-lab-risk-stage-extinction-plot.png` |
| Compare table accumulates multiple runs | Pass | 9 rows before reset; `evidence/compare-after-multiple-runs.png` |
| Compare reset returns to baseline only | Pass after fix | 1 row after reset; `evidence/compare-after-reset.png` |
| Transfer prompts and deferred concepts are visible | Pass | 3 prompt questions and 2 future concepts; `evidence/transfer-screen.png` |
| Mobile-width post-interaction layout is coherent | Pass after fix | `evidence/mobile-concept-lab-post-interaction.png` |
| Visible Shiny errors or confusing blank states | Pass | No `.shiny-output-error` text and no error-text hits in final pass |

## Implemented Fixes

1. Replaced the client-side `conditionalPanel()` dependency on
   `output.showExtinctionPlot` with a server-rendered
   `extinction_plot_panel`. This fixed the browser-visible Shiny error
   `Can't read output 'showExtinctionPlot'` and made the risk plot appear
   reliably for genetics, catastrophe, and extinction-vortex stages.
2. Updated Compare reset so it resets both the run history/current run and the
   selected Concept Lab stage back to the deterministic baseline.
3. Aligned the deterministic baseline slider default with the API default of
   25 years.
4. Restricted collected controls to controls actually visible for the selected
   stage, preventing stale hidden slider values from previous stages from
   changing later runs.
5. Allowed long settings/comparison table values to wrap in narrow layouts.
6. Added focused Shiny MVP regression tests for the server-rendered risk panel,
   reset selector alignment, and visible-control collection.

## Final Browser Evidence

Final Playwright evidence:

- Browser path: Playwright Chromium headless via temporary script.
- Implemented stages run: deterministic baseline, carrying capacity,
  demographic stochasticity, environmental stochasticity, genetic
  stochasticity, catastrophe, intervention, extinction vortex.
- Compare rows before reset: 9.
- Compare rows after reset: 1.
- Transfer questions visible: 3.
- Future concepts visible: 2.
- Final visible error check: no Shiny errors and no error-text hits.

Screenshots:

- `evidence/start-after-load.png`
- `evidence/concept-lab-ordinary-stage.png`
- `evidence/concept-lab-risk-stage-extinction-plot.png`
- `evidence/compare-after-multiple-runs.png`
- `evidence/compare-after-reset.png`
- `evidence/transfer-screen.png`
- `evidence/mobile-concept-lab-post-interaction.png`

## Validation

Validation was run after browser QA and scoped fixes:

- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R")'`
  passed with 27 assertions.
- `Rscript -e 'source("bootstrap.R"); testthat::test_local()'` passed with
  201 assertions.
- `Rscript -e 'source("bootstrap.R"); renv::status()'` reported no issues.
- `git diff --check` passed.
- Marker scan found only the literal validation command strings in Goal 016
  `Goal.md` and `Runbook.md`; no unresolved markers were found in app, tests,
  or teaching docs.
- `lsof -nP -iTCP:3862 -sTCP:LISTEN || true` showed no listener after the app
  server was stopped.

## Residual Risks

- This is still a local MVP smoke-and-interaction QA pass, not a hosted
  deployment test.
- The app remains intentionally single-user/session-local; no authentication,
  persistence, usage tracing, or ShinyProxy behaviour was tested.
- The Practical 2 Woodhen app mode, formal Allee effect, and correlated-event
  features remain deferred as required by the goal boundaries.
