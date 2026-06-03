# Log

## 2026-06-03 - Supervisor Goal Publication

- Supervisor created Goal 015 after Goal 014 published the accepted teaching
  API and planning stack.
- Objective: build the minimum viable Practical 1 Shiny concept-lab scaffold
  against the real teaching API.
- Model recommendation for action-agent execution: `gpt-5.5` with `high`
  reasoning. The task combines package dependency management, Shiny UI/server
  implementation, tests, browser smoke checks, screenshots, commit, and push.
- Commit/push is authorized only after validation passes.
- Deployment, ShinyProxy, `deep-server` service files, authentication,
  persistent student workspaces, Practical 2 Woodhen app mode, assessment
  redesign, scenario YAML changes, and engine-behaviour changes are out of
  scope.

## 2026-06-03 - Execution Start And Context

- Formal goal mode appeared active for this action-thread run.
- Started from `/Users/bwbrook/git/rPVA` on `main`.
- Initial branch/status checks:
  - `git status --short --branch --ignored=matching` returned
    `## main...origin/main`, with ignored `renv/staging/`.
  - `git branch --show-current` returned `main`.
  - `git rev-list --left-right --count main...origin/main` returned `0 0`.
- No repo-local `AGENTS.md` was found under `/Users/bwbrook/git/rPVA`; global
  Mac mini instructions apply.
- Read the Goal 015 packet:
  - `Goal.md`
  - `Plan.md`
  - `Runbook.md`
  - `Log.md`
- Read required context:
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
- Confirmed the MVP contract:
  - launcher name: `run_practical1_shiny()`
  - app path: `inst/shiny/practical1/`
  - screens: Start, Concept Lab, Compare, Transfer
  - dependency policy: add `shiny` to `Suggests` and synchronize `renv.lock`
  - validation includes focused/full tests, `renv::status()`,
    `git diff --check`, marker scan, launch smoke, and desktop/mobile browser
    screenshots.

## 2026-06-03 - Implementation And Validation

- Added public package launcher `run_practical1_shiny()` in
  `R/shiny_practical1.R`.
- Added base Shiny app files under `inst/shiny/practical1/`:
  - `app.R`
  - `README.md`
  - `www/styles.css`
- Implemented four visible app sections:
  - Start
  - Concept Lab
  - Compare
  - Transfer
- Supported currently implemented teaching stages from
  `teaching_stage_catalog()`:
  - deterministic baseline
  - carrying capacity
  - demographic stochasticity
  - environmental stochasticity
  - genetic stochasticity
  - catastrophe
  - simple intervention
  - extinction vortex comparison
- Deferred Allee-effect and correlated-event concepts remain visible only as
  future concepts in the Transfer section.
- Added focused tests in `tests/testthat/test-13_practical1_shiny.R`.
- Updated `docs/teaching/shiny/README.md` to point to the new MVP scaffold and
  preserve the current non-deployment boundary.
- Added `shiny` to `DESCRIPTION` `Suggests`.
- Ran dependency sync:
  `Rscript -e 'source("bootstrap.R"); renv::install("shiny"); renv::snapshot(prompt = FALSE)'`.
  Result: installed/locked `shiny 1.13.0` plus support packages
  `commonmark`, `httpuv`, `later`, `otel`, `promises`, `sourcetools`, and
  `xtable`.
- Temporarily installed `roxygen2` with `record = FALSE` to regenerate package
  documentation, then removed temporary roxygen packages after regeneration.
- Ran `Rscript -e 'source("bootstrap.R"); roxygen2::roxygenise()'`.
  Result: `NAMESPACE` exports `run_practical1_shiny()` and
  `man/run_practical1_shiny.Rd` was generated.
- Restored incidental roxygen metadata churn in `DESCRIPTION`; the intended
  metadata change is only `shiny` in `Suggests`.
- Stripped incidental `renv/activate.R` whitespace churn after renv operations;
  `renv/activate.R` is not part of the publication diff.
- Ran focused tests:
  `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R")'`.
  Final result: `FAIL 0 | WARN 0 | SKIP 0 | PASS 18`.
- Ran full local tests:
  `Rscript -e 'source("bootstrap.R"); testthat::test_local()'`.
  Final result: `FAIL 0 | WARN 0 | SKIP 0 | PASS 192`.
- Ran `Rscript -e 'source("bootstrap.R"); renv::status()'`.
  Result: `No issues found -- the project is in a consistent state`.
- Ran `git diff --check`. Result: no output, exit 0.
- Ran marker scan:
  `rg -n "TODO|TBD|PLACEHOLDER" R tests inst/shiny docs/teaching/shiny docs/goals/015-practical-1-shiny-mvp-scaffold`.
  Result: intentional hits only in Goal 015 `Goal.md` and `Runbook.md`
  validation text.
- Launch smoke:
  - Started Shiny on `http://127.0.0.1:3851`.
  - `curl -fsS http://127.0.0.1:3851/` wrote
    `/tmp/rpva-practical1-start.html` and confirmed the app HTML includes
    `Practical 1 PVA`, `Island rail`, `Concept Lab`, and `Transfer`.
- Browser evidence:
  - Tried the in-app Browser surface first; it reported `iab` unavailable in
    this session.
  - Used the runbook's Google Chrome headless fallback.
  - Desktop screenshot:
    `docs/goals/015-practical-1-shiny-mvp-scaffold/evidence/practical1-desktop.png`
    (`1440 x 1000`, about 72 KB).
  - Mobile screenshot:
    `docs/goals/015-practical-1-shiny-mvp-scaffold/evidence/practical1-mobile.png`
    (`390 x 900`, about 51 KB).
  - Visually inspected screenshots and tightened summary/table layout so the
    Start screen is not blank, clipped, or overlapping at desktop or mobile
    evidence widths.
- Stopped the Shiny server after screenshot capture.
- No ShinyProxy/deployment service files, authentication, persistent
  workspaces, Practical 2 Woodhen mode, assessment files, scenario YAML, or
  core engine behaviour were changed.
