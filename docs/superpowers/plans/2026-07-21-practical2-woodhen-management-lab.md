# Practical 2 Woodhen Management Lab Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Practical 2 infrastructure canary with a complete, historically grounded Woodhen investigation and evidence app that supports the three-hour KPZ308 class, independent assessment work, portable cross-host projects, and selective evidence export.

**Architecture:** Extend the existing PVA engine with validated annual ecological profiles while preserving the scalar simulation path exactly. Build versioned Woodhen scenario, result, and project APIs around that engine, then expose them through a five-tab modular Shiny app based on Practical 1's approved interaction language. Persist compact project state in IndexedDB and a safe portable ZIP; render a Word evidence dossier with Pandoc; verify locally, in a Linux container, and finally through the production ShinyProxy browser route.

**Tech Stack:** R 4.6.x, Shiny, testthat, ggplot2, patchwork, jsonlite, zip, rmarkdown/Pandoc, JavaScript IndexedDB, Playwright, Docker, ShinyProxy 3.2.4.

**Authoritative design:** `docs/superpowers/specs/2026-07-21-practical2-woodhen-management-lab-design.md`

## Global Constraints

- Preserve the four locked assessment criteria word-for-word wherever they appear.
- Use student-facing terms such as **reference Woodhen scenarios**, **locked future baseline**, and **historically grounded model**. Do not use unexplained developer shorthand such as *canonical* or *base spec*.
- Freeze Practical 1 behaviour. Shared-engine changes are acceptable only when the existing seeded scalar results and the full Practical 1 test suite remain unchanged.
- Keep ordinary Act 2 comparisons fixed at the supplied 2025 starting population, 75 years, 1,000 futures, common seed, and current Woodhen stage structure. Alternative seeds or replicate counts are labelled robustness checks.
- Treat fewer than 50 territory-holding breeding pairs, represented by model stages 2 onward, as the primary future quasi-extinction threshold. Do not substitute total birds.
- Store compact derived evidence, not full 1,000-replicate trajectory arrays, in the portable project.
- Do not generate report prose, captions, recommendations, marks, grade bands, or a compulsory report structure.
- Do not depend on SSO identity or server-side workspaces for project resumption. The downloaded project package is the supported cross-host source of truth.
- Verify portable-project import on both the SSO application and the off-campus host at `https://131-217-178-240.sslip.io/` before release.
- Keep the first release bounded: named threats, interventions, and sensitivity factors with validated ranges and generated temporal profiles. No arbitrary R, YAML, HTML, scripts, or year-by-year student input.
- Apply the 80/20 stopping rule: complete the fit-for-purpose core, perform one focused repair pass per gate, and defer polish that does not materially improve scientific validity, project safety, the student route, or deployment confidence.

## Soft-Gate Operating Model

The gates are review points, not automatic pauses.

- Close each gate with a coherent commit, its verification evidence, material residual risks, and the next local URL or audit artefact Barry can inspect.
- Continue to the next gate unless Barry asks to pause or a stop condition below is met. Feedback received while the next gate is under way is folded into the next safe boundary.
- Gates 1 and 2 are primarily root/automated checks; Barry need only inspect the scientific audit tables if desired.
- Gates 3, 4, and 5 expose useful browser checkpoints. A concise approval such as “Great, move to next gate” is sufficient.
- Gate 6 is a real release gate: no production student access until automated, container, staff-browser, export, and rollback evidence pass.

**Stop and ask before proceeding if:**

- a reference scenario or existing seeded scalar result changes unexpectedly;
- the 50-pair metric cannot be reconciled with the stage/territory interpretation;
- a portable-project round trip loses, changes, or executes student-controlled content;
- the compulsory three-hour route is incomplete or materially confusing;
- the Word dossier cannot be opened and reused as intended;
- the production image identity or rollback state is ambiguous; or
- two consecutive attempts yield no material improvement or new evidence.

## Three-Day Delivery Target

| Day | Primary target | Review surface |
| --- | --- | --- |
| Day 1 | Gates 1-2: scientific engine, catalogues, compact evidence, portable project | Scientific audit tables and automated round-trip results |
| Day 2 | Gate 3 and most of Gate 4: Start, Calibrate, compulsory sensitivity, future comparison, advanced investigation | First complete local browser route |
| Day 3 | Gates 4-6: Compare, Evidence Studio, guidance, browser/container acceptance, staff production beta | Final local app, exports, then staff-only production |

If the schedule compresses, preserve the compulsory route, project portability, primary evidence metrics, Word dossier, and production safety. Defer only lower-value advanced combinations or visual polish, recording the deferral explicitly.

---

## Gate 1: Scientific Foundation

### Task 1: Add annual ecological profiles without changing the scalar path

**Files:**

- Create: `R/temporal_profiles.R`
- Modify: `R/spec_validation.R`
- Modify: `R/run_pva_core.R`
- Modify: `R/run_pva_core_helpers.R`
- Test: `tests/testthat/test-17_temporal_profiles.R`

**Contract:**

```r
build_temporal_profile <- function(
    baseline,
    target,
    years,
    onset_year = 1L,
    end_year = years,
    shape = c("step", "linear")
)

validate_annual_profiles <- function(profiles, years, n_stage)

resolve_pva_year_spec <- function(spec, stasis, year)
```

Supported annual-profile fields in the first release:

- scalar by year: `K`, `K_sd`, `env_sd`, `cat_freq`, `cat_surv`, `cat_repro`;
- stage-specific by year: `surv`, `fecund`.

`annual_profiles` is an optional list on a normalized spec. Scalar profiles are numeric vectors of length `years`; stage profiles are numeric matrices with `years` rows and `n_stage` columns. The student interface never supplies arbitrary vectors; only the validated builders create them.

- [ ] Write failing tests that assert `build_temporal_profile()` produces a persistent step, a correctly bounded linear transition, and informative errors for invalid onset/end years, shape, length, non-finite values, and probability values outside `[0, 1]`.
- [ ] Write failing tests for `validate_annual_profiles()` covering supported fields, dimensions, `K >= 0`, `K_sd >= 0`, `env_sd >= 0`, catastrophe probabilities/multipliers, survival probabilities, and non-negative fecundity.
- [ ] Add `annual_profiles` to `allowed_pva_spec_fields()` and normalize it through a dedicated branch rather than flattening it as a scalar/vector field.
- [ ] Implement `build_temporal_profile()` and `validate_annual_profiles()` in `R/temporal_profiles.R`.
- [ ] Implement `resolve_pva_year_spec()` so it returns the year-local spec, year-local stasis, and survival beta parameters recalculated from the resolved `surv` and `env_sd`. Remove `annual_profiles` before calling `run_pva_step()`.
- [ ] Modify the inner year loop in `run_pva_core()` to call the resolver only when profiles exist. Preserve the current direct `run_pva_step(..., spec, stasis, env_alpha, env_beta)` call as the no-profile branch so the seeded scalar random-number stream is byte-for-byte unchanged.
- [ ] Add tests showing a step decrease in `K`, linear habitat contraction, altered survival, and delayed intervention affect only the intended years and fields.
- [ ] Add a regression test comparing all scalar-path return components from a fixed Woodhen run before and after adding an unused `annual_profiles = NULL` path.
- [ ] Run:

```bash
Rscript -e 'pkgload::load_all("."); testthat::test_file("tests/testthat/test-17_temporal_profiles.R", reporter = "summary")'
Rscript -e 'pkgload::load_all("."); testthat::test_file("tests/testthat/test-01_core.R", reporter = "summary")'
```

Expected: all new profile tests pass; existing core seeded expectations are unchanged.

- [ ] Commit:

```bash
git add R/temporal_profiles.R R/spec_validation.R R/run_pva_core.R R/run_pva_core_helpers.R tests/testthat/test-17_temporal_profiles.R
git commit -m "Extend PVA engine with validated temporal profiles"
```

### Task 2: Implement the 50 breeding-pair risk evidence

**Files:**

- Create: `R/quasi_extinction.R`
- Create: `R/woodhen_investigation_plots.R`
- Test: `tests/testthat/test-18_quasi_extinction.R`

**Contract:**

```r
breeding_pair_trajectories <- function(result, holder_stages = NULL)

summarize_quasi_extinction <- function(
    result,
    threshold_pairs = 50L,
    holder_stages = NULL
)

plot_woodhen_risk_over_time <- function(evidence)
plot_woodhen_first_passage <- function(evidence)
plot_woodhen_threshold_curve <- function(evidence, max_threshold = NULL)
```

The summary returns at least:

```r
list(
  threshold_pairs = 50L,
  holder_stages = 2:7,
  total_reps = 1000L,
  crossed_reps = 0L,
  probability_by_horizon = 0,
  first_crossing_year = integer_or_na_vector,
  cumulative = data.frame(year, probability),
  conditional_median_year = NA_real_,
  overall_median_year = NA_real_
)
```

- [ ] Write hand-built trajectory fixtures that distinguish stage-1 floaters from stages 2+ territory holders.
- [ ] Write failing tests proving the event is `pair_count < 50`, not `<= 50`, and that the first crossing is recorded once per future.
- [ ] Write failing tests for 0%, 49.9%, 50%, and 100% crossing cases. The conditional median uses only crossing futures; the overall median is `NA` below 50% and available at or above 50%.
- [ ] Implement `breeding_pair_trajectories()` and `summarize_quasi_extinction()` with explicit validation that `keep_traj = TRUE` evidence is present.
- [ ] Implement the cumulative-risk, first-passage, and optional wider-threshold plots. When no futures cross, show a truthful zero-risk/“no crossings observed” state rather than an empty or misleading panel.
- [ ] Ensure plot labels explicitly say **breeding pairs**, **fewer than 50**, the horizon, number of futures, and whether a median is conditional.
- [ ] Run:

```bash
Rscript -e 'pkgload::load_all("."); testthat::test_file("tests/testthat/test-18_quasi_extinction.R", reporter = "summary")'
```

Expected: exact boundary/timing tests pass; plot constructors return `ggplot` objects for zero-, partial-, and high-crossing fixtures.

- [ ] Commit:

```bash
git add R/quasi_extinction.R R/woodhen_investigation_plots.R tests/testthat/test-18_quasi_extinction.R
git commit -m "Add Woodhen breeding-pair risk evidence"
```

### Task 3: Define reference, sensitivity, threat, and intervention catalogues

**Files:**

- Create: `R/woodhen_investigation_catalog.R`
- Create: `R/woodhen_investigation_spec.R`
- Modify: `R/woodhen_management_api.R`
- Create: `scripts/audit_practical2_scientific_catalog.R`
- Test: `tests/testthat/test-19_woodhen_investigation_spec.R`

**Contract:**

```r
woodhen_reference_catalog <- function()
woodhen_sensitivity_catalog <- function()
woodhen_threat_catalog <- function()
woodhen_intervention_catalog <- function()

woodhen_locked_future_spec <- function()

build_woodhen_sensitivity_family <- function(
    factor_id,
    values,
    seed = 123L
)

build_woodhen_prospective_family <- function(
    threat,
    interventions = list(),
    seed = 123L
)
```

Every catalogue entry includes: student label, biological meaning, exact affected fields/stages, low/moderate/high anchors, custom range, allowed temporal shapes, source/rationale, interpretation help, and limitation text.

Initial sensitivity anchors for scientific review:

| Factor | Locked baseline | Two initial altered settings | Allowed first-release range |
| --- | ---: | ---: | ---: |
| Breeding-territory capacity `K` | 500 | 350, 250 | 100-750 |
| All-stage survival multiplier | 1.00 | 0.95, 0.90 | 0.70-1.10 |
| Juvenile survival multiplier | 1.00 | 0.85, 0.70 | 0.50-1.10 |
| Fecundity multiplier | 1.00 | 0.80, 0.60 | 0.40-1.20 |
| Annual catastrophe probability | 0.04 | 0.07, 0.10 | 0.00-0.20 |
| Catastrophe survival multiplier | 0.50 | 0.40, 0.30 | 0.20-1.00 |
| Environmental variability `env_sd` | 0.20 | 0.25, 0.30 | valid beta range, maximum 0.30 |
| Habitat-capacity variability `K_sd` | 50 | 75, 100 | 0-150 |

- [ ] Write tests that load the five immutable reference scenarios in chronological/pedagogical order and assert the future anchor exactly matches `05_future_baseline.yaml` plus the common seed and 1,000 futures.
- [ ] Write tests that every sensitivity family contains exactly one locked baseline and at least two altered settings while all non-target settings, years, reps, seed, and `n0` remain identical.
- [ ] Write tests for the six named threats and five named intervention families in the approved design. Assert sea-level rise maps to a gradual habitat pathway rather than an abstract sea-level model parameter.
- [ ] Write tests for composition order: locked baseline -> threat components -> intervention recovery/components -> full validation.
- [ ] Write tests rejecting out-of-bounds values, unsupported temporal shapes, unnamed multi-factor components, and student attempts to change locked fields.
- [ ] Implement the four catalogues with plain-language metadata separated from runnable builders.
- [ ] Implement immutable scenario records with parent IDs, exact changes, timestamps supplied by the caller, library/model version, and deterministic specification fingerprints.
- [ ] Adapt or wrap the current `woodhen_management_api.R` functions so historical reference compatibility is retained while new code uses the investigation APIs. Remove obsolete canary-only assumptions only after equivalent tests exist.
- [ ] Create `scripts/audit_practical2_scientific_catalog.R` to write compact CSV/Markdown audit tables under a caller-supplied temporary directory. Include every anchor, bound, model mapping, temporal allowance, horizon, seed, and the 50-pair definition.
- [ ] Run:

```bash
Rscript -e 'pkgload::load_all("."); testthat::test_file("tests/testthat/test-19_woodhen_investigation_spec.R", reporter = "summary")'
Rscript -e 'pkgload::load_all("."); source("scripts/audit_practical2_scientific_catalog.R"); audit_practical2_scientific_catalog(tempdir())'
```

Expected: all locked-field/composition tests pass; the audit tables give Barry a concise scientific review surface before the UI hardens these choices.

- [ ] Run the full pre-existing suite as the Gate 1 shared-engine regression:

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter = "summary")'
```

Expected: no Practical 1 or historical Woodhen regression.

- [ ] **Gate 1 report:** return the audit table paths, scalar regression result, new scientific interfaces, and any anchor/bound that still requires Barry's judgement. Continue unless scientific drift or unresolved bounds make the UI unsafe to build.
- [ ] Commit:

```bash
git add R/woodhen_investigation_catalog.R R/woodhen_investigation_spec.R R/woodhen_management_api.R scripts/audit_practical2_scientific_catalog.R tests/testthat/test-19_woodhen_investigation_spec.R
git commit -m "Define bounded Woodhen investigation families"
```

---

## Gate 2: Durable Project And Evidence Foundation

### Task 4: Store compact, reproducible investigation evidence

**Files:**

- Create: `R/woodhen_investigation_evidence.R`
- Modify: `R/woodhen_investigation_plots.R`
- Test: `tests/testthat/test-20_woodhen_investigation_evidence.R`

**Contract:**

```r
run_woodhen_investigation_scenario <- function(
    scenario,
    seed = scenario$seed,
    sample_trajectories = 100L,
    progress = NULL
)

compact_woodhen_run <- function(result, scenario, sample_trajectories = 100L)
compare_woodhen_run_family <- function(runs, family_id)
```

- [ ] Write tests for a seeded locked baseline and at least one sensitivity and one threat/intervention family.
- [ ] Assert each compact run contains the full scenario specification/fingerprint, seed, reps, diagnostics, final-abundance distribution, annual quantiles, a deterministic bounded trajectory sample, extinction evidence, 50-pair evidence, and differences from the appropriate parent.
- [ ] Assert no compact run retains `traj`, `sr_traj`, `F_traj`, `LE_traj`, closures, environments, or other full raw simulation objects.
- [ ] Implement deterministic trajectory sampling by stored replicate indices so plots remain stable across reloads.
- [ ] Implement family comparison records that refuse scientifically incompatible baselines/horizons unless the caller explicitly requests an annotated awkward comparison.
- [ ] Complete trajectory, distribution, risk, sensitivity-response, and baseline-threat-intervention plot functions from compact evidence alone.
- [ ] Run:

```bash
Rscript -e 'pkgload::load_all("."); testthat::test_file("tests/testthat/test-20_woodhen_investigation_evidence.R", reporter = "summary")'
```

Expected: reproducible compact records and all required plot families without access to discarded full trajectories.

- [ ] Commit:

```bash
git add R/woodhen_investigation_evidence.R R/woodhen_investigation_plots.R tests/testthat/test-20_woodhen_investigation_evidence.R
git commit -m "Build compact Woodhen investigation evidence"
```

### Task 5: Add versioned local-first projects and safe portable packages

**Files:**

- Create: `R/woodhen_project.R`
- Modify: `DESCRIPTION`
- Modify: `renv.lock`
- Test: `tests/testthat/test-21_woodhen_project.R`

**Dependencies:** move `rmarkdown` to `Imports`; add `jsonlite` and `zip` to `Imports`; snapshot only those resolved dependency changes. Do not add `officer` unless Pandoc Word output proves insufficient at Gate 5.

**Contract:**

```r
new_woodhen_project <- function(title = NULL, owner_label = NULL, now = Sys.time())
validate_woodhen_project <- function(project)
add_woodhen_scenario <- function(project, scenario, now = Sys.time())
add_woodhen_run <- function(project, run, now = Sys.time())
add_woodhen_observation <- function(project, observation, now = Sys.time())
select_woodhen_evidence <- function(project, evidence_ids, now = Sys.time())
woodhen_project_fingerprint <- function(project)
write_woodhen_project_package <- function(project, path, now = Sys.time())
read_woodhen_project_package <- function(
    path,
    max_compressed_bytes = 25 * 1024^2,
    max_expanded_bytes = 50 * 1024^2
)
```

Portable ZIP whitelist:

```text
manifest.json
project.json
```

- [ ] Write tests for the schema: project/run IDs, schema version, model/app/reference-library versions, scenario ancestry/versioning, exact changes, notes, evidence selections, optional identity-light labels, timestamps, and import/export provenance.
- [ ] Write tests proving an edit to a completed scenario creates a new version and never mutates existing run evidence.
- [ ] Write round-trip tests that export, import, and re-export a non-trivial project without changing IDs, scientific content, notes, evidence selections, or fingerprints.
- [ ] Write hostile-package tests for path traversal, unknown files, duplicate members, invalid JSON, excessive compressed/expanded size, executable/script fields, unrecognised scenario fields, invalid bounds, and fingerprint mismatch.
- [ ] Implement pure-list mutation functions that validate before returning and never partially mutate the caller's object.
- [ ] Implement deterministic JSON serialization for fingerprints and portable files; keep timestamps/provenance outside the scientific scenario fingerprint.
- [ ] Implement ZIP inspection before extraction, exact member whitelisting, size accounting, and import into a temporary location. Do not execute or source imported content.
- [ ] Update dependencies with the repo's `renv` workflow and inspect the lockfile diff before accepting it.
- [ ] Run:

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-21_woodhen_project.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter = "summary")'
```

Expected: hostile inputs are rejected before project creation; valid projects survive an exact semantic round trip; full suite stays green.

- [ ] **Gate 2 report:** provide schema version, sample package manifest, compressed/expanded size, round-trip result, and any storage limitation. Continue unless there is data loss, unsafe import behaviour, or an impractical project size.
- [ ] Commit:

```bash
git add DESCRIPTION renv.lock R/woodhen_project.R tests/testthat/test-21_woodhen_project.R
git commit -m "Add portable Woodhen investigation projects"
```

---

## Gate 3: Complete Three-Hour Core Route

### Task 6: Replace the canary with the Practical 1-derived modular shell

**Files:**

- Rewrite: `inst/shiny/practical2/app.R`
- Create: `inst/shiny/practical2/ui_helpers.R`
- Create: `inst/shiny/practical2/project_helpers.R`
- Create: `inst/shiny/practical2/modules/mod_start.R`
- Create: `inst/shiny/practical2/content/start.md`
- Create: `inst/shiny/practical2/content/help-projects.md`
- Create: `inst/shiny/practical2/www/project-store.js`
- Rewrite: `inst/shiny/practical2/www/styles.css`
- Copy: `inst/shiny/practical1/www/img/landing-woodhen-population.png` to `inst/shiny/practical2/www/img/landing-woodhen-population.png`
- Modify: `inst/shiny/practical2/README.md`
- Replace: `tests/testthat/test-15_practical2_shiny.R`
- Create: `tests/testthat/test-22_practical2_project_store.R`

**Module contract:** each module exports `<name>_ui(id)` and `<name>_server(id, project, ...)`; module servers return reactive events rather than mutating global state directly.

- [ ] Write structural tests for the five visible tabs and stable IDs: `start`, `calibrate`, `investigate`, `compare`, `evidence`.
- [ ] Write tests that construct the Shiny app without creating workspace artefacts and that source every module from the installed app directory.
- [ ] Build a quiet, work-focused shell that carries forward Practical 1's navigation, contextual help, compact progress guidance, button/icon conventions, typography, and responsive rules without copying obsolete mission logic.
- [ ] Build Start with the present-day adviser role, two-act structure, three-hour core route, pass-level-foundation statement, “Ways to deepen your investigation” preview, create/resume/import choices, and explicit browser-autosave versus portable-download language.
- [ ] Implement `project-store.js` with IndexedDB keys scoped by project ID and schema version. Send available recovery metadata to Shiny first; restore only after the student chooses Resume. Debounce autosave writes and expose saved/dirty/portable-download status.
- [ ] Keep the R project object authoritative during a live session; browser JavaScript stores validated serialized snapshots received from Shiny and returns them through a single validated restore input.
- [ ] Add responsive layout tests or static assertions for 1366x768, 1440x900, and 390x844 targets. No cards inside cards; no overlapping text or controls.
- [ ] Run:

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-15_practical2_shiny.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-22_practical2_project_store.R", reporter = "summary")'
```

Expected: app constructs; all tab/module/content assets are found from the installed package; project-store message contracts pass.

- [ ] Commit:

```bash
git add inst/shiny/practical2 tests/testthat/test-15_practical2_shiny.R tests/testthat/test-22_practical2_project_store.R
git commit -m "Build Practical 2 investigation shell"
```

### Task 7: Implement Act 1 historical calibration

**Files:**

- Create: `inst/shiny/practical2/modules/mod_calibrate.R`
- Create: `inst/shiny/practical2/content/help-calibrate.md`
- Modify: `R/woodhen_investigation_evidence.R`
- Test: `tests/testthat/test-23_practical2_calibrate.R`

- [ ] Write module-server tests for all five reference scenarios, chronological grouping, run progress, state recovery, rerun behaviour, and evidence insertion into the project.
- [ ] Implement the 1980 crisis comparison as three compatible 40-year cases: no intervention, pig control, and captive breeding plus pig control.
- [ ] Implement the separate 2019-2024 rodent-eradication recovery check with the supplied observed milestone and prominent short-horizon warning. Do not rank it directly against the 40-year cases.
- [ ] Implement the 2025-2100 no-change run as the visible locked future anchor and record the exact anchor fingerprint used by every Act 2 family.
- [ ] Show observed history, scenario settings, model outputs, uncertainty, compatible-horizon labels, trajectory/risk evidence, and short interpretation/caveat prompts. Prompts are encouraged but not blocking.
- [ ] Use the core `progress(completed, total)` callback so the progress bar reflects completed futures rather than artificial phases.
- [ ] Refuse Act 2 scenario construction if the project lacks the current library version's locked future anchor; offer the student one clear action to run it.
- [ ] Run:

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-23_practical2_calibrate.R", reporter = "summary")'
```

Expected: all reference runs persist independently, horizon comparisons are scientifically valid, and the current locked anchor is available to Act 2.

- [ ] Commit:

```bash
git add R/woodhen_investigation_evidence.R inst/shiny/practical2/modules/mod_calibrate.R inst/shiny/practical2/content/help-calibrate.md tests/testthat/test-23_practical2_calibrate.R
git commit -m "Implement Woodhen historical calibration"
```

### Task 8: Implement the compulsory sensitivity and future-advice route

**Files:**

- Create: `inst/shiny/practical2/modules/mod_investigate.R`
- Create: `inst/shiny/practical2/content/help-investigate.md`
- Create: `tests/testthat/test-24_practical2_investigate_core.R`

- [ ] Write server tests that require one named factor with three settings total: locked baseline plus at least two altered values.
- [ ] Write tests proving years, reps, seed, starting population, and all non-target settings remain locked across ordinary sensitivity runs.
- [ ] Implement a compact factor selector, anchored-value controls, optional bounded custom value, visible exact model mapping, run-family action, response plot, result table, and retained settings.
- [ ] Add optional prompts for research question, biological reason, expected direction, interpretation, and caveat. Empty prompts never block a run or export.
- [ ] Write server tests for the required prospective family: locked baseline -> one named threat -> at least one intervention applied to that threatened future.
- [ ] Implement threat and intervention idea-seed selectors with plain-language meaning, low/moderate/high anchors, limitations, and exact changes shown before running.
- [ ] Show the compact baseline-threat-intervention comparison with abundance, extinction, fewer-than-50-pair risk, first-passage timing, uncertainty, and intervention difference from the threatened parent.
- [ ] Prevent silent in-place edits: changing a completed scenario creates a new version and retains the original run.
- [ ] Show unobtrusive completion guidance for the compulsory sensitivity and prospective evidence, but do not lock advanced controls or score the student.
- [ ] Run:

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-24_practical2_investigate_core.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter = "summary")'
```

Expected: the minimum route produces a complete historical anchor, a valid three-setting sensitivity family, and a valid baseline-threat-intervention family without altering locked machinery.

- [ ] Start a local review server:

```bash
Rscript -e 'source("bootstrap.R"); pkgload::load_all("."); run_practical2_shiny(host = "127.0.0.1", port = 49582, launch.browser = FALSE)'
```

- [ ] **Gate 3 browser review:** Barry can complete Start -> Calibrate -> one sensitivity -> one threat/intervention. Report the URL, tests, known advanced features still pending, and any scientific warnings. Perform at most one focused repair pass before continuing.
- [ ] Commit:

```bash
git add inst/shiny/practical2/modules/mod_investigate.R inst/shiny/practical2/content/help-investigate.md tests/testthat/test-24_practical2_investigate_core.R
git commit -m "Complete Practical 2 core investigation route"
```

---

## Gate 4: Independent Investigation Workspace

### Task 9: Add bounded advanced scenario construction

**Files:**

- Modify: `inst/shiny/practical2/modules/mod_investigate.R`
- Modify: `inst/shiny/practical2/content/help-investigate.md`
- Modify: `R/woodhen_investigation_spec.R`
- Test: `tests/testthat/test-25_practical2_investigate_advanced.R`

- [ ] Write tests for immediate, delayed-step, and gradual threat/intervention profiles and for intervention onset before, with, and after the threat.
- [ ] Write tests for alternative intensities, multiple interventions, compound threats, and named multi-factor portfolios. Every component and change must remain visible in the scenario record.
- [ ] Implement an initially collapsed advanced layer using structured controls: intensity, onset year, transition end year, step/gradual shape, add intervention, add threat, and robustness check.
- [ ] Restrict combinations to catalogue-defined fields/ranges and reject duplicate/conflicting components with actionable messages.
- [ ] Label any scenario changing more than one ecological factor as **multi-factor** and explain that interpretation requires greater care.
- [ ] Implement rerun-with-additional-seed/larger-replicate validation as a robustness check linked to the ecological scenario, not a new biological treatment.
- [ ] Keep the default route visually dominant and fast. Advanced controls must not expand until chosen and must not require completion.
- [ ] Run:

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-25_practical2_investigate_advanced.R", reporter = "summary")'
```

Expected: bounded advanced scenarios build valid annual profiles and preserve transparent ancestry/settings.

- [ ] Commit:

```bash
git add R/woodhen_investigation_spec.R inst/shiny/practical2/modules/mod_investigate.R inst/shiny/practical2/content/help-investigate.md tests/testthat/test-25_practical2_investigate_advanced.R
git commit -m "Add advanced Woodhen scenario exploration"
```

### Task 10: Build the persistent Compare workspace

**Files:**

- Create: `inst/shiny/practical2/modules/mod_compare.R`
- Create: `inst/shiny/practical2/content/help-compare.md`
- Modify: `R/woodhen_project.R`
- Modify: `R/woodhen_investigation_evidence.R`
- Test: `tests/testthat/test-26_practical2_compare.R`

- [ ] Write tests for filtering/searching the full run library, selecting compatible evidence, selecting named families, and warning on incompatible horizon/baseline comparisons.
- [ ] Write tests for multiple comparison-linked observations and caveats; notes persist across browser and portable-project round trips.
- [ ] Implement a restrained layout in which the active comparison and selected evidence have most space. Put the complete run library in a compact searchable/filterable drawer or side panel.
- [ ] Provide trajectory, final-distribution, extinction/50-pair risk, first-passage, sensitivity-response, and baseline-threat-intervention views using tabs or a segmented control rather than stacking every plot.
- [ ] Let students nominate runs, plots, tables, and observations for the dossier while preserving source IDs and distinguishing supplied, model-generated, and student-authored content.
- [ ] Add exact, useful warnings for different horizons, different future anchors, different seeds, robustness checks, and multi-factor interpretation. Warnings inform; they do not automatically block comparison.
- [ ] Run:

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-26_practical2_compare.R", reporter = "summary")'
```

Expected: a reloaded project supports coherent family comparisons and multiple accumulated observations without the run history dominating the screen.

- [ ] **Gate 4 browser review:** Barry can build and compare at least one advanced or multi-factor extension, record observations, reload them, and select evidence. Complete one material repair pass, then continue.
- [ ] Commit:

```bash
git add R/woodhen_project.R R/woodhen_investigation_evidence.R inst/shiny/practical2/modules/mod_compare.R inst/shiny/practical2/content/help-compare.md tests/testthat/test-26_practical2_compare.R
git commit -m "Build Practical 2 comparison workspace"
```

---

## Gate 5: Evidence Dossier And Student Guidance

### Task 11: Generate the Word-first evidence dossier and companion files

**Files:**

- Create: `R/woodhen_dossier.R`
- Create: `inst/shiny/practical2/templates/evidence-dossier.Rmd`
- Create: `inst/shiny/practical2/modules/mod_evidence.R`
- Create: `inst/shiny/practical2/content/help-evidence.md`
- Test: `tests/testthat/test-27_woodhen_dossier.R`

**Contract:**

```r
build_woodhen_dossier_data <- function(project)
render_woodhen_evidence_dossier <- function(project, path)
write_woodhen_companion_exports <- function(project, directory)
```

- [ ] Write dossier-data tests for provenance, Act 1 evidence, compulsory sensitivity, baseline-threat-intervention evidence, selected extensions, student observations/caveats, locked criteria, and report guidance.
- [ ] Write tests that missing evidence produces specific advisory messages but never prevents export.
- [ ] Implement an Evidence Studio preview with evidence categories, selective checkboxes, compact output count, editable selection, project-download status, and the soft display-item guidance.
- [ ] Render Word through `rmarkdown::render(..., output_format = "word_document")` and the installed Pandoc. Use editable Word tables and embedded report-resolution figures.
- [ ] Test the `.docx` as a ZIP: require `word/document.xml`, table nodes, expected headings, locked criteria text, and media files. Also open/convert it non-interactively with LibreOffice when available.
- [ ] Generate companion CSV tables, PNG figures, and transparent Markdown. Filenames include stable scenario/evidence IDs and remain safe across Windows/macOS/Linux.
- [ ] Include the portable project package as a separate explicit download, not hidden inside the human-facing dossier.
- [ ] Ensure the dossier contains no generated recommendation, caption, assessment prose, mark estimate, or grade prediction.
- [ ] Run:

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-27_woodhen_dossier.R", reporter = "summary")'
```

Expected: Word opens, tables remain editable, figures are embedded, companion files are usable, and sparse projects still export with helpful gaps noted.

- [ ] Commit:

```bash
git add R/woodhen_dossier.R inst/shiny/practical2/templates/evidence-dossier.Rmd inst/shiny/practical2/modules/mod_evidence.R inst/shiny/practical2/content/help-evidence.md tests/testthat/test-27_woodhen_dossier.R
git commit -m "Add Practical 2 evidence dossier exports"
```

### Task 12: Finish report, research, help, and classroom guidance

**Files:**

- Create: `inst/shiny/practical2/content/report-guidance.md`
- Create: `inst/shiny/practical2/content/ways-to-deepen.md`
- Create: `inst/shiny/practical2/content/woodhen-research.md`
- Create: `docs/teaching/woodhen/practical-2-report-guidance.md`
- Modify: `docs/teaching/woodhen/practical-2-student-launch-page.md`
- Modify: `docs/teaching/woodhen/practical-2-woodhen-management.md`
- Modify: `docs/teaching/woodhen/assessment-brief-2026-draft.md`
- Modify: `docs/teaching/woodhen/assessment-design-crosswalk-2026.md`
- Modify: `docs/teaching/woodhen/classroom-dry-run-checklist.md`
- Modify: `docs/teaching/woodhen/expected-outputs.md`
- Modify: `docs/teaching/woodhen/README.md`
- Modify: `inst/shiny/practical2/README.md`
- Test: `tests/testthat/test-28_practical2_content_contract.R`

- [ ] Add exact contract tests for the locked C1-C4 wording, approximate 2,000-word limit excluding display items/references, typical 3-4 display items, soft ceiling of 4 items/about 6 panels, and “Ways to deepen your investigation”.
- [ ] Preserve and test this exact assessment table:

| Criterion | Marks | Assessment Criteria |
| --- | ---: | --- |
| C1 | 5 | Describe the uses and limitations of simulation modelling in conservation decision-making. |
| C2 | 6 | Model stochastic processes and causes of threat. |
| C3 | 8 | Undertake scenario testing to compare the relative effectiveness of alternative management options. |
| C4 | 6 | Translate simulation results and communicate them as conservation recommendations. |
- [ ] Add negative tests for `canonical`, grade prediction/mark promises, a generated report recommendation, and claims that mechanical completion demonstrates high achievement.
- [ ] Write concise report guidance that describes a defensible pass-level evidence base and ways stronger work can improve through reasoning, selection, literature, systematic analysis, uncertainty, alternative actions, and conditions that change advice.
- [ ] Present several organisational possibilities rather than one scaffold. Encourage broader Woodhen ecology/monitoring/management research and source evaluation without enforcing it.
- [ ] Show the exact locked criteria and explain the kinds of evidence that may address them without scoring compliance.
- [ ] Explain that the three-hour class is the warm-up and the app remains available for independent investigation through the assessment period.
- [ ] Update launch, teaching, assessment, checklist, expected-output, and README documents to match the implemented interface and exports. Remove canary language and any obsolete toy-output instructions.
- [ ] Run:

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-28_practical2_content_contract.R", reporter = "summary")'
```

Expected: locked wording is exact; student language is current, plain, and non-prescriptive; all documented actions exist in the app.

- [ ] Start/update the local server and complete **Gate 5 browser review:** Start and help language, full five-tab route, Word/CSV/PNG/Markdown/project downloads, project import in a fresh browser context, and mobile/desktop layouts. Perform one focused repair pass only.
- [ ] Commit:

```bash
git add inst/shiny/practical2/content docs/teaching/woodhen inst/shiny/practical2/README.md tests/testthat/test-28_practical2_content_contract.R
git commit -m "Align Practical 2 guidance and assessment bridge"
```

---

## Gate 6: Release Readiness And Production Opening

### Task 13: Automate full browser and package acceptance

**Files:**

- Create: `scripts/practical2_browser_acceptance.js`
- Create: `scripts/practical2_project_roundtrip_acceptance.R`
- Modify: `deploy/shinyproxy/practical2/validate-scaffold.sh`
- Modify: `deploy/shinyproxy/practical2/Dockerfile.template`
- Modify: `deploy/shinyproxy/practical2/dockerignore.template`
- Modify: `deploy/shinyproxy/practical2/README.md`
- Modify: `deploy/shinyproxy/practical2/application.spec.example.yml`
- Test: `tests/testthat/test-29_practical2_release_contract.R`

- [ ] Write a Playwright acceptance that starts from a new project and completes all five reference runs, one three-setting sensitivity family, one threat plus intervention, a comparison observation, evidence selection, and every export.
- [ ] In the same test, download the portable project, open a fresh browser context, import it, confirm IDs/results/notes/selections, add a new run, and download a second portable package.
- [ ] Assert the Word dossier, CSV, PNG, Markdown, and project ZIP are non-empty and structurally valid; inspect the Word and project archives using the R acceptance helper.
- [ ] Run desktop and mobile viewport checks at 1366x768, 1440x900, and 390x844. Capture screenshots and fail on page errors, console errors, overlapping primary controls, clipped button text, horizontal document scroll, or missing plots.
- [ ] Make the browser test exercise real stochastic progress at 1,000 futures and assert it advances monotonically from the engine callback.
- [ ] Update container dependencies and scaffold checks for `jsonlite`, `zip`, `rmarkdown`, Pandoc, Word rendering, and new app assets.
- [ ] Update the ShinyProxy example to remove canary naming, retain a separate workspace root, and show Staff-only access for beta. Do not add `KPZ308` in the example until the final opening step.
- [ ] Run local acceptance:

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter = "summary")'
Rscript scripts/practical2_project_roundtrip_acceptance.R

NODE_PATH=/home/bwbrook/.nvm/versions/node/v22.18.0/lib/node_modules \
PRACTICAL2_URL=http://127.0.0.1:49582 \
PRACTICAL2_EVIDENCE_DIR=/tmp/rpva-practical2-acceptance \
node scripts/practical2_browser_acceptance.js

bash deploy/shinyproxy/practical2/validate-scaffold.sh
```

Expected: all R tests pass; browser flow completes without console/page errors; all exports validate; screenshots are readable at all target viewports.

- [ ] Perform one focused review of failing or visibly material issues. Do not begin repeated marginal screenshot-polish loops once the core flow is clear and stable.
- [ ] Commit:

```bash
git add scripts/practical2_browser_acceptance.js scripts/practical2_project_roundtrip_acceptance.R deploy/shinyproxy/practical2 tests/testthat/test-29_practical2_release_contract.R
git commit -m "Add Practical 2 release acceptance"
```

### Task 14: Build and accept the immutable production candidate

**Files:**

- Create after acceptance: `docs/ops/deployments/2026-07-24-kpz308-practical2-production.md`
- Modify only if evidence requires it: `docs/ops/teaching-app-deployment-codex-playbook.md`
- Modify only if evidence requires it: `docs/ops/teaching-app-deployment-human-playbook.md`

- [ ] Confirm a clean worktree, expected `main` SHA, full local tests, and accepted browser evidence before building.
- [ ] Build explicitly for `linux/amd64` using the Practical 2 Dockerfile template. Run the container health check and the full Playwright flow against the container, including Word and portable-project exports.
- [ ] Tag and push one immutable image:

```text
git.its.utas.edu.au/utas/kpz308-rpva-practical2:dev-YYYYMMDD-SHORTSHA
```

- [ ] Record and compare source SHA, local image ID, registry digest, pulled image digest, architecture, and OCI revision label. Digest or revision mismatch is a stop condition.
- [ ] On production, preserve `application.yml` metadata and create a timestamped rollback copy before editing. Record the current canary tag `dev-20260714-8aada69b0ac3` as the immediate rollback target.
- [ ] Replace only the `kpz308-rpva-practical2` image and display/description fields. Keep access restricted to `UNI-Ecology-Teaching-Shiny-Staff` for the first production beta.
- [ ] Restart ShinyProxy, wait for `/actuator/health` to report `UP`, inspect startup logs, and verify Practical 1 and KPZ314 specifications remain unchanged.
- [ ] Barry/staff production acceptance: launch Practical 2 through SSO, complete the compulsory route, download/open Word and portable project, import the package in a fresh browser or the off-campus host, and confirm a new run can be added.
- [ ] Check running container image/digest, separate Practical 2 workspace, recent proxy events, health, and representative resource use. Treat the recurring IPv4-forwarding warning as informational only if browser/container networking demonstrably works.
- [ ] After staff sign-off, add `KPZ308` alongside Staff to the Practical 2 `access-groups`, preserve another rollback copy, restart, and confirm one student-group account can see and launch the app while Practical 1 remains available.
- [ ] Write the deployment evidence report with exact immutable tag/digest, source SHA, backups, access groups, checks, export evidence, rollback command/target, remaining risks, and class-day status.
- [ ] Commit the deployment record and any evidence-driven playbook correction:

```bash
git add -f docs/ops/deployments/2026-07-24-kpz308-practical2-production.md
git add docs/ops/teaching-app-deployment-codex-playbook.md docs/ops/teaching-app-deployment-human-playbook.md 2>/dev/null || true
git commit -m "Record Practical 2 production release"
```

- [ ] **Gate 6 release report:** state the immutable source/image identities, production access groups, actual browser/export tests, rollback state, and any residual operational risk. Practical 2 is student-ready only after this gate passes.

---

## Final Acceptance Checklist

- [ ] Five-tab Start/Calibrate/Investigate/Compare/Evidence Studio journey works on desktop and mobile.
- [ ] All five reference scenarios run with correct horizon framing and no silent scientific drift.
- [ ] The locked 2025-2100 baseline is identical across ordinary Act 2 work.
- [ ] A student can complete a three-setting one-factor sensitivity family.
- [ ] A student can compare locked baseline -> named threat -> at least one intervention.
- [ ] Advanced timing and multi-factor options are bounded, transparent, and optional.
- [ ] Fewer-than-50 breeding-pair risk and timing are calculated from stages 2+ and labelled correctly.
- [ ] Project autosave recovers on the same origin and clearly distinguishes itself from a portable download.
- [ ] A portable project moves between fresh browser contexts/hosts without identity or server storage.
- [ ] Compare retains run families, selected evidence, multiple observations, and caveats without being dominated by history.
- [ ] Word, CSV, PNG, Markdown, and portable-project exports are valid and useful.
- [ ] Student guidance preserves locked C1-C4 wording, 2,000-word scope, selective display advice, and independent-research headroom without generating report prose.
- [ ] Existing Practical 1 tests and seeded scalar outputs remain unchanged.
- [ ] Linux/amd64 container, registry digest, ShinyProxy health, real browser route, Staff beta, student access, and rollback evidence all pass.

## Deferred Unless A Gate Exposes A Material Need

- Server-side project accounts, cloud sync, or cross-origin automatic recovery.
- Arbitrary student YAML/R input or arbitrary annual schedules.
- Automatic prose, captions, recommendations, marking, or submission.
- A full in-app citation manager or literature-search service.
- General refactoring of Practical 1 or the wider PVA engine beyond the annual-profile extension.
- Exhaustive advanced portfolio optimisation, spatial habitat modelling, or a standalone sea-level process.
- Repeated visual polish after the first material repair pass.
