# Practical 1 Integrated Risk Layer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Carry the latest deterministic assumptions through Practical 1 missions, report real simulation progress, and foreground extinction and quasi-extinction risk in the Concept Lab.

**Architecture:** Keep run 1 as the immutable evidence reference while storing a separate reactive working-assumptions layer in the Shiny session. Add an optional replicate-progress callback to the existing synchronous engine. Build internal risk-data and plotting helpers from stored trajectories, then integrate them into the existing plot region without changing the public `plot_ext()` behaviour.

**Tech Stack:** R 4.5, Shiny, testthat, ggplot2, patchwork, package-local helpers, Playwright/Node acceptance script.

## Global Constraints

- Target a classroom-ready 80% solution for delivery on 2026-07-20; do not add asynchronous job infrastructure or low-value polish.
- Preserve run 1 as the pinned comparison reference.
- Inherit only projection years, mortality adjustment, and fecundity adjustment from the latest successful deterministic run.
- Keep advanced controls optional.
- Do not change the exported `plot_ext()` behaviour.
- Preserve all pre-existing uncommitted Concept Lab changes and do not commit or push before Barry reviews the rendered result.

---

### Task 1: Session Working Assumptions

**Files:**
- Modify: `inst/shiny/practical1/app.R`
- Modify: `tests/testthat/test-13_practical1_shiny.R`

**Interfaces:**
- Produces: `working_assumptions_from_spec(spec)` returning a named list with `years`, `mortality_pct`, and `fecundity_pct`.
- Produces: `mission_control_values(stage, input, advanced, working_assumptions)` returning inherited common controls merged with visible mission controls.
- Consumes: existing `stage_control_values()`, `same_baseline_assumptions()`, `baseline_run()`, and `run_history()`.

- [ ] **Step 1: Add failing server tests for inherited assumptions**

Extend the deterministic rerun server test so that a successful 50-year rerun with mortality and fecundity adjustments is followed by Core 2. Assert that Core 2 uses those three assumptions, while `baseline_run()` remains run 1 with 25 years and zero adjustments. Add reset assertions restoring the original working assumptions.

- [ ] **Step 2: Run the focused test and verify the inherited-years assertion fails**

Run:

```bash
Rscript -e 'pkgload::load_all(".", quiet = TRUE); testthat::test_file("tests/testthat/test-13_practical1_shiny.R")'
```

Expected: FAIL because Core 2 currently rebuilds from the 25-year package default.

- [ ] **Step 3: Implement the reactive working-assumptions layer**

Initialize it from the display-only reference baseline. Merge it before mission-specific controls for non-baseline stages. Update it only after a successful changed deterministic run. Use it as the selected value when advanced common controls render. Reset it alongside the other session state.

- [ ] **Step 4: Run the focused server tests**

Run:

```bash
Rscript -e 'pkgload::load_all(".", quiet = TRUE); testthat::test_file("tests/testthat/test-13_practical1_shiny.R")'
```

Expected: PASS, with run 1 unchanged and Core 2 using the latest successful deterministic assumptions.

---

### Task 2: Replicate-Based Progress

**Files:**
- Modify: `R/run_pva_core.R`
- Modify: `R/teaching_api.R`
- Modify: `inst/shiny/practical1/app.R`
- Modify: `tests/testthat/test-01_core.R`
- Modify: `tests/testthat/test-12_teaching_api.R`
- Modify: `tests/testthat/test-13_practical1_shiny.R`

**Interfaces:**
- Produces: optional `progress = NULL` argument on `run_pva_core()` and `run_teaching_pva()`.
- Callback contract: `progress(completed, total)` receives integer replicate counts, is monotonic, and is called for the final replicate.
- Shiny adapter maps engine completion onto `setProgress()` with visible future counts.

- [ ] **Step 1: Add failing callback tests**

Run a small three-replicate simulation with a recorder callback. Assert positive, monotonic completed counts, constant total `3L`, and final pair `c(3L, 3L)`. Add a teaching-API pass-through test.

- [ ] **Step 2: Verify the callback tests fail on the missing argument**

Run:

```bash
Rscript -e 'pkgload::load_all(".", quiet = TRUE); testthat::test_file("tests/testthat/test-01_core.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R")'
```

Expected: FAIL because neither function currently accepts `progress`.

- [ ] **Step 3: Implement the throttled callback and Shiny adapter**

Validate that a supplied callback is a function. Invoke it no more than about 100 times and always on the final replicate. Pass it through `run_teaching_pva()`. In Shiny, show preparation, `Simulating future i of n`, and final evidence-preparation phases instead of initializing the bar at 50%.

- [ ] **Step 4: Run engine, teaching, and server progress tests**

Run:

```bash
Rscript -e 'pkgload::load_all(".", quiet = TRUE); testthat::test_file("tests/testthat/test-01_core.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R")'
```

Expected: PASS with no console progress when the callback is absent.

---

### Task 3: Risk Data and Plot Helpers

**Files:**
- Modify: `R/plot_helpers.R`
- Modify: `R/plot_pva.R`
- Create: `tests/testthat/test-14_practical1_risk_plots.R`

**Interfaces:**
- Produces: `build_extinction_timing_data(out)` with cumulative series, first-extinction years, replicate counts, and unconditional median time.
- Produces: `build_quasi_extinction_plot_data(out, K, max_fraction = 0.5)` with integer thresholds and empirical crossing probabilities.
- Produces: internal `plot_extinction_timing(out)` and `plot_quasi_extinction_risk(out, K, max_fraction = 0.5)` functions that print and invisibly return ggplot/patchwork objects.

- [ ] **Step 1: Write synthetic-trajectory tests**

Construct small trajectory arrays whose expected outcomes are exact. Cover no extinctions, extinction probability below 0.5, extinction probability at or above 0.5, first-extinction years, threshold-zero equivalence with final cumulative extinction, and quasi-extinction probabilities through 50% of `K`.

- [ ] **Step 2: Verify the helper tests fail because the functions are absent**

Run:

```bash
Rscript -e 'pkgload::load_all(".", quiet = TRUE); testthat::test_file("tests/testthat/test-14_practical1_risk_plots.R")'
```

Expected: FAIL on missing risk helper functions.

- [ ] **Step 3: Implement internal data helpers and plots**

Derive total population by year and replicate from `out$traj`. Define first extinction as the first year total abundance equals zero. Define quasi-extinction at threshold `q` as `mean(min_t N[t, r] <= q)`. Build a directly labelled cumulative-risk panel, a conditional extinction-time histogram or explicit zero-extinction state, and a simple monotonic quasi-extinction curve with probability limits `[0, 1]`.

- [ ] **Step 4: Run risk-helper and existing plot validation tests**

Run:

```bash
Rscript -e 'pkgload::load_all(".", quiet = TRUE); testthat::test_file("tests/testthat/test-14_practical1_risk_plots.R"); testthat::test_file("tests/testthat/test-10_validation.R")'
```

Expected: PASS and the existing exported `plot_ext()` tests remain unchanged.

---

### Task 4: Concept Lab Risk Surface and Browser Gate

**Files:**
- Modify: `inst/shiny/practical1/app.R`
- Modify: `inst/shiny/practical1/www/styles.css`
- Modify: `scripts/practical1_browser_acceptance.js`
- Modify: `tests/testthat/test-13_practical1_shiny.R`

**Interfaces:**
- Consumes: internal `plot_extinction_timing()` and `plot_quasi_extinction_risk()`.
- Produces: always-present `risk_plot_panel` teaching surface, `quasi_extinction_plot`, and `download_quasi_extinction_plot`.
- Retains: existing `extinction_plot`, `download_extinction_plot`, trajectory and summary outputs.

- [ ] **Step 1: Add failing UI-contract tests**

Assert that Risk evidence precedes Population projections, a one-future run renders an insufficient-futures explanation, stochastic runs render extinction timing, finite-`K` runs render quasi-extinction, and missing-`K` runs render an explicit unavailable state.

- [ ] **Step 2: Verify the UI tests fail on the current stage-gated panel**

Run:

```bash
Rscript -e 'pkgload::load_all(".", quiet = TRUE); testthat::test_file("tests/testthat/test-13_practical1_shiny.R")'
```

Expected: FAIL because risk is currently limited to three named stages and uses the old combined plot.

- [ ] **Step 3: Integrate and style the risk surface**

Replace stage-name gating with scientific availability checks based on replicate count, trajectories, and finite `K`. Place risk before abundance plots, use a responsive two-column layout that collapses to one column, and expose separate risk downloads only when available. Keep advanced controls collapsed by default.

- [ ] **Step 4: Extend the browser acceptance flow**

Exercise this path: load app, run baseline, confirm deterministic risk explanation, rerun baseline at 50 years, run Core 2 with multiple futures and ceiling variation, confirm inherited 50-year Settings record, observe progress detail, verify both risk figures are nonblank, and confirm no console/page errors.

- [ ] **Step 5: Run focused R and browser verification**

Run:

```bash
Rscript -e 'pkgload::load_all(".", quiet = TRUE); testthat::test_file("tests/testthat/test-12_teaching_api.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R"); testthat::test_file("tests/testthat/test-14_practical1_risk_plots.R")'
node scripts/practical1_browser_acceptance.js
git diff --check
```

Expected: all focused tests pass, browser result reports `passed: true` with no failed checks or browser errors, and `git diff --check` is clean.

- [ ] **Step 6: Stop at the beta-review gate**

Leave localhost running at `http://localhost:49581/`. Report the implemented behaviour, verification evidence, known residual limitations, and exact files changed. Do not commit, push, rebuild the container, or begin a second polish pass until Barry reviews the rendered result.
