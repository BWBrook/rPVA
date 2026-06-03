# Goal 015: Practical 1 Shiny MVP Scaffold

## Objective

Build the first usable Practical 1 Shiny MVP scaffold for the zero-to-hero PVA
concept lab, using the published teaching API from Goal 013.

The app should let a student open a browser, run the toy teaching stages,
inspect plots/tables/diagnostics, compare runs, and see the transfer prompts
that prepare them for the Woodhen practical.

This is not a deployment goal. Do not install ShinyProxy, edit `deep-server`,
create accounts, implement persistent workspaces, or build the Practical 2
Woodhen interface.

## Context

Goal 011 defined the Practical 1 Shiny design brief. Goal 013 implemented the
teaching API. Goal 014 published that API with generated documentation and
package-check validation.

Goal 015 should now build the smallest honest browser app that proves the
teaching flow works against the real engine. The app can be visually modest,
but it must feel like a real teaching tool rather than a pile of debug widgets.

The first road-test UI should support only the stages currently implemented by
`teaching_stage_catalog()`. Allee effects and correlated events should remain
visible as deferred/future concepts only if that can be done without implying
the engine supports them today.

## Required Sources

Read:

- `docs/teaching/shiny/practical-1-design-brief.md`
- `docs/teaching/shiny/implementation-roadmap.md`
- `docs/teaching/shiny/engine-affordance-audit.md`
- `docs/teaching/shiny/README.md`
- `R/teaching_api.R`
- `R/plot_pva.R`
- `R/pva_helpers.R`
- `tests/testthat/test-12_teaching_api.R`
- `DESCRIPTION`
- `NAMESPACE`
- `renv.lock`
- `docs/goals/014-publication-hygiene-and-clean-push/Log.md`

You may inspect additional package files as needed.

## Required Implementation

### Package Surface

Add a package-level launcher:

- preferred name: `run_practical1_shiny()`
- it should locate `inst/shiny/practical1`
- it should check for `shiny` and give a clear install message if missing
- it should call `shiny::runApp(...)`
- it should expose practical arguments such as `host`, `port`,
  `launch.browser`, and `...`
- document and export it with roxygen

If a different name is strongly better for local package style, explain why in
`Log.md`.

### App Files

Create a Shiny app under:

```text
inst/shiny/practical1/
```

Expected files:

- `app.R`
- `www/styles.css`
- optional small `README.md` if it helps future maintainers

Use base Shiny. Avoid adding `DT`, `plotly`, `shinydashboard`, or other UI
framework dependencies in this first scaffold unless there is a concrete
blocker that base Shiny cannot solve.

### User Flow

Implement four visible sections or tabs:

1. Start
   - invented species framing for a simple island rail or equivalent toy
     species
   - a direct action to begin or run the baseline
   - concise statement that this prepares students for the Woodhen practical

2. Concept Lab
   - stage selector for implemented teaching stages
   - deferred stages may appear as disabled or clearly labelled future concepts
     only if that is not confusing
   - stage question/concept text from the catalog or local mapping
   - one or two bounded controls appropriate to the stage
   - a run button
   - current summary table
   - diagnostic messages from `diagnose_pva_result()`
   - trajectory plot and summary plot when available
   - extinction/genetics plot when relevant and available

3. Compare
   - table from `compare_teaching_runs()`
   - preserve run order and labels
   - reset/clear comparison action
   - plain-language prompt asking what changed and why

4. Transfer
   - summary of mechanisms explored
   - the three transfer questions from the design brief:
     - which output shows extinction risk?
     - which output shows abundance?
     - which output shows uncertainty?
   - short bridge to the Lord Howe Island woodhen practical

The deterministic baseline should be easy to run immediately. A default
baseline output on first load is acceptable and preferred if it keeps the app
from opening blank.

### UI Quality Requirements

Keep the interface quiet, teaching-focused, and scan-friendly:

- no marketing landing page
- no oversized hero section
- no decorative orbs, stock-like imagery, or generic filler cards
- no nested cards
- no YAML, terminal, internal object, seed, or arbitrary list-editing exposure
- use stable dimensions for plot/output regions to avoid layout jumps
- use readable labels and tooltips/help text for controls
- keep button/control text compact and non-overlapping on laptop and mobile
  widths
- use a restrained palette with more than one hue family; do not make it a
  one-note purple/blue gradient or beige dashboard
- make it usable on a small laptop screen and acceptable on mobile width

Icons are optional in Shiny, but use `shiny::icon()` for clear actions such as
run, compare, reset, or transfer when it improves scanability.

### Dependency Policy

Add `shiny` as a teaching-app dependency in `DESCRIPTION` `Suggests`, and
synchronize `renv.lock`.

Do not make Shiny a core `Imports` dependency unless you find a strong package
reason. The simulator should remain usable without loading Shiny.

If roxygen2 is needed for documentation regeneration and is missing, install it
temporarily with `record = FALSE` as in Goal 014. Do not add roxygen2 as a
package dependency.

### Tests

Add focused tests, preferably:

```text
tests/testthat/test-13_practical1_shiny.R
```

Minimum test coverage:

- app directory and required files exist
- launcher fails clearly if `shiny` is unavailable, or launches/locates the app
  when it is available
- app can be constructed with `shiny::shinyAppDir()` or an equivalent
  non-interactive Shiny check
- default teaching run used by the app returns a valid `teaching_pva_run`
- no ordinary app construction writes files into the repo
- no `TODO`, `TBD`, or `PLACEHOLDER` markers remain in app/code/docs except
  quoted validation commands in the goal packet

Use `skip_if_not_installed("shiny")` only for tests that truly require Shiny.
Because this goal should add and lock Shiny, the local validation run should not
skip the main Shiny tests.

### Browser Evidence

Run the app locally and capture browser evidence.

Minimum evidence:

- Shiny server launch smoke test on `127.0.0.1`
- `curl` or equivalent confirms the app serves HTML
- Chrome headless or Browser/Chrome screenshot at desktop width
- Chrome headless or Browser/Chrome screenshot at mobile width
- save screenshots under:
  `docs/goals/015-practical-1-shiny-mvp-scaffold/evidence/`

Do not commit giant screenshots. If a screenshot is unexpectedly large, resize
or record the issue in `Log.md`.

## Boundaries

Allowed:

- add `run_practical1_shiny()` or equivalent package launcher
- add `inst/shiny/practical1/`
- add Shiny-focused tests
- add `shiny` to `DESCRIPTION` `Suggests`
- update `renv.lock` to synchronize the Shiny dependency
- regenerate `NAMESPACE` and `man/` for the new launcher
- update `docs/teaching/shiny/README.md` or implementation-roadmap text only
  if needed to reflect the MVP scaffold
- add small screenshot evidence under this Goal 015 folder
- commit and push after all validation passes

Do not:

- implement ShinyProxy, Docker, nginx, systemd, or `deep-server` service files
- implement login, authentication, per-student persistent workspaces, quotas, or
  usage tracing
- implement Practical 2 Woodhen app mode
- edit assessment/rubric files
- change scenario YAML files
- change core PVA engine behaviour
- implement formal Allee or correlated-event engine features
- add heavy UI dependencies such as `DT`, `plotly`, or `shinydashboard`
- commit package build/check artifacts, temp server logs, downloaded HTML, or
  local browser profile files
- rebase, reset, force-push, or discard existing work

## Validation

Before committing:

```sh
Rscript -e 'source("bootstrap.R"); renv::install("shiny"); renv::snapshot(prompt = FALSE)'
Rscript -e 'source("bootstrap.R"); roxygen2::roxygenise()'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R")'
Rscript -e 'source("bootstrap.R"); testthat::test_local()'
Rscript -e 'source("bootstrap.R"); renv::status()'
git diff --check
rg -n "TODO|TBD|PLACEHOLDER" R tests inst/shiny docs/teaching/shiny docs/goals/015-practical-1-shiny-mvp-scaffold
```

Run a launch smoke test. Use another port if `3851` is occupied:

```sh
Rscript -e 'source("bootstrap.R"); shiny::runApp(system.file("shiny", "practical1", package = "rPVA"), host = "127.0.0.1", port = 3851, launch.browser = FALSE)' &
server_pid=$!
sleep 8
curl -fsS http://127.0.0.1:3851/ >/tmp/rpva-practical1-start.html
kill "$server_pid"
wait "$server_pid" 2>/dev/null || true
rm -f /tmp/rpva-practical1-start.html
```

Capture screenshots while the app is running. If using Chrome headless:

```sh
mkdir -p docs/goals/015-practical-1-shiny-mvp-scaffold/evidence
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --disable-gpu --screenshot=docs/goals/015-practical-1-shiny-mvp-scaffold/evidence/practical1-desktop.png --window-size=1440,1000 http://127.0.0.1:3851/
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --disable-gpu --screenshot=docs/goals/015-practical-1-shiny-mvp-scaffold/evidence/practical1-mobile.png --window-size=390,900 http://127.0.0.1:3851/
```

If a validation command needs adjustment for the local tooling, use the closest
equivalent and explain it in `Log.md`.

## Commit And Push

If all validation passes:

- update `docs/goals/015-practical-1-shiny-mvp-scaffold/Log.md` with validation
  evidence and screenshot paths before committing
- create one implementation commit, expected subject:
  `Add Practical 1 Shiny MVP scaffold`
- push `main` to `origin`
- do not create an audit-only follow-up commit solely to record its own SHA;
  report the pushed commit SHA in the final response instead

If validation fails or the UI is clearly broken, do not commit or push. Leave a
clear `Log.md` entry and report the blocker.

## Report Back

Report:

- files changed
- public launcher name
- app screens and supported stages
- dependency and lockfile changes
- tests and validation outcomes
- launch smoke result
- screenshot paths
- commit SHA and push result, if committed
- final `git status --short --branch --ignored=matching`
- residual risks
- recommended next goal
