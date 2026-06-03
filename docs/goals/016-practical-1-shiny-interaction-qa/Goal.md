# Goal 016: Practical 1 Shiny Interaction QA And Hardening

## Objective

Run a student-style browser QA and hardening pass on the Practical 1 Shiny MVP
scaffold from Goal 015.

The goal is to prove and improve the app's actual classroom interaction flow:
students should be able to start from the opening screen, run implemented
teaching stages, see outputs update, compare runs, reset comparisons, and reach
the transfer prompts without layout breakage or confusing blank states.

This is not a deployment goal and not a feature-expansion goal.

## Context

Goal 015 built the first Shiny MVP scaffold and published it as commit
`36b36d2 Add Practical 1 Shiny MVP scaffold`. It added:

- `run_practical1_shiny()`
- `inst/shiny/practical1/`
- `shiny` in `DESCRIPTION` `Suggests`
- Shiny-focused tests
- Start-screen desktop/mobile screenshots

Supervisor review accepted Goal 015 as an MVP scaffold, with the explicit
residual risk that screenshots covered the Start screen only and no complete
student-style click-through had yet been performed.

Goal 016 closes that gap.

## Required Sources

Read:

- `docs/goals/015-practical-1-shiny-mvp-scaffold/Log.md`
- `docs/teaching/shiny/practical-1-design-brief.md`
- `docs/teaching/shiny/implementation-roadmap.md`
- `docs/teaching/shiny/README.md`
- `inst/shiny/practical1/app.R`
- `inst/shiny/practical1/www/styles.css`
- `R/shiny_practical1.R`
- `R/teaching_api.R`
- `tests/testthat/test-13_practical1_shiny.R`
- `DESCRIPTION`
- `renv.lock`

You may inspect additional files as needed.

## Required Work

### 1. Browser QA Plan

Define the target flow in `Log.md` before running browser checks:

```text
app loads -> Start screen baseline is visible -> Concept Lab runs each
implemented stage -> Compare table updates and resets -> Transfer prompts are
visible -> no visible errors, layout breakage, or confusing blank states
```

Check Browser availability first if a Browser/IAB tool is exposed in your
session. If unavailable, use the local Playwright CLI wrapper:

```sh
command -v npx
export CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
export PWCLI="$CODEX_HOME/skills/playwright/scripts/playwright_cli.sh"
test -x "$PWCLI"
```

Use the wrapper's `open`, `snapshot`, `click`, `fill`, `press`, and
`screenshot` commands where practical. If the wrapper cannot drive a required
Shiny control cleanly, use a temporary Playwright/Chrome automation script
outside the repo under `/tmp` and record that fallback in `Log.md`. Do not
commit temporary automation scripts or browser profiles.

### 2. Interaction Coverage

Launch the app locally on `127.0.0.1`. Use port `3862` unless occupied.

Exercise at least:

- Start screen:
  - baseline output visible on load
  - Start baseline action navigates or updates as intended
- Concept Lab:
  - run deterministic baseline
  - run carrying capacity
  - run demographic stochasticity
  - run environmental stochasticity
  - run genetic stochasticity
  - run catastrophe
  - run simple intervention
  - run extinction vortex comparison
  - after each run, verify the current run label/summary changes to the
    selected stage and no visible Shiny error appears
- Plots:
  - trajectory and summary plot regions render for ordinary stages
  - extinction/genetics plot appears for relevant risk-focused stages
- Compare:
  - comparison table grows after multiple runs
  - reset comparison returns to a clear baseline state
- Transfer:
  - three transfer questions are visible
  - deferred Allee/correlated-event concepts are labelled as future concepts,
    not implemented features
- Responsive checks:
  - laptop/desktop width
  - mobile width

### 3. Hardening

Fix issues found in the click-through if they are within scope.

Allowed hardening includes:

- clearer labels or helper text
- better empty/loading/error states
- preventing duplicate/confusing run labels
- making compare/reset behaviour clearer
- making plot regions stable after interactions
- improving mobile layout after interactions
- adding `validate()`/`need()` guards for Shiny outputs
- adding focused Shiny tests for behaviours found during QA
- tightening CSS to prevent overlap, clipping, or awkward wrapping

Do not broaden the product:

- no exports/downloads
- no accounts/authentication/workspaces/usage traces
- no ShinyProxy, Docker, nginx, systemd, or `deep-server` service work
- no Practical 2 Woodhen app mode
- no assessment redesign
- no scenario YAML or core engine behaviour changes
- no formal Allee/correlated-event implementation
- no heavy UI dependencies

### 4. Evidence

Create a compact QA report:

```text
docs/goals/016-practical-1-shiny-interaction-qa/qa-report.md
```

It should include:

- environment and browser path used
- target flow
- interaction checklist with pass/fail results
- issues found and fixes made
- screenshots captured
- remaining risks

Capture committed screenshot evidence under:

```text
docs/goals/016-practical-1-shiny-interaction-qa/evidence/
```

Minimum screenshots:

- Start screen after load
- Concept Lab after at least one ordinary stage run
- Concept Lab after one risk-focused stage run with the extinction/genetics
  plot visible
- Compare screen after multiple runs
- Compare screen after reset
- Transfer screen
- one mobile-width post-interaction screen

Keep screenshots reasonably small. If a screenshot is unexpectedly large,
resize or record the issue in `Log.md`.

### 5. Tests

Update or add focused tests if hardening changes app behaviour.

Minimum validation still includes:

- focused Shiny tests
- full package tests
- `renv::status()`
- `git diff --check`
- marker scan

Do not add Playwright, shinytest2, or other browser automation dependencies to
`DESCRIPTION` or `renv.lock` unless there is a strong reason and you explain it
in `Log.md`. Prefer temporary QA tooling outside the package dependency graph.

## Boundaries

Allowed:

- edit `inst/shiny/practical1/app.R`
- edit `inst/shiny/practical1/www/styles.css`
- edit `tests/testthat/test-13_practical1_shiny.R` or add a narrowly scoped
  Shiny test file
- edit `docs/teaching/shiny/README.md` only if the MVP status needs a small
  update
- add Goal 016 `qa-report.md` and screenshot evidence
- update Goal 016 `Log.md`
- commit and push after validation passes

Do not:

- edit deployment/service infrastructure
- edit scenario YAML files
- change PVA engine behaviour
- add heavy UI/runtime dependencies
- implement exports, accounts, workspaces, usage tracing, Practical 2 mode, or
  new science features
- commit temporary Playwright scripts, downloaded HTML, server logs, browser
  profiles, package build artifacts, or check directories
- rebase, reset, force-push, or discard unrelated work

## Validation

Before committing:

```sh
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R")'
Rscript -e 'source("bootstrap.R"); testthat::test_local()'
Rscript -e 'source("bootstrap.R"); renv::status()'
git diff --check
rg -n "TODO|TBD|PLACEHOLDER" R tests inst/shiny docs/teaching/shiny docs/goals/016-practical-1-shiny-interaction-qa
```

Launch and interaction QA:

```sh
Rscript -e 'source("bootstrap.R"); shiny::runApp(system.file("shiny", "practical1", package = "rPVA"), host = "127.0.0.1", port = 3862, launch.browser = FALSE)'
```

Run browser interaction checks against `http://127.0.0.1:3862/` using Browser,
the Playwright CLI wrapper, or a temporary `/tmp` automation fallback.

After browser QA, confirm:

```sh
lsof -nP -iTCP:3862 -sTCP:LISTEN || true
```

No Shiny server should be left running at the end.

## Commit And Push

If validation passes:

- update `Log.md` with browser QA evidence, fixes, validation outcomes, and
  screenshot paths
- create one implementation/QA commit, expected subject:
  `Harden Practical 1 Shiny interactions`
- push `main` to `origin`
- do not create an audit-only follow-up commit solely to record its own SHA

If validation fails or a major UI issue remains, do not commit/push. Record the
blocker in `Log.md` and report back.

## Report Back

Report:

- files changed
- browser tooling path used and any fallback reason
- interaction checklist results
- issues found and fixes made
- validation outcomes
- screenshot evidence paths
- commit SHA and push result, if committed
- final `git status --short --branch --ignored=matching`
- residual risks
- recommended next goal
