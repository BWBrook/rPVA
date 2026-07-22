# Practical 2 Woodhen Management Lab Revised Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> `superpowers:subagent-driven-development` or `superpowers:executing-plans` to
> implement this plan gate-by-gate. Steps use checkbox (`- [ ]`) syntax for
> tracking. Do not merge adjacent student-facing review gates without Barry's
> approval.

**Goal:** Deliver a scientifically defensible, student-friendly Woodhen PVA
investigation that supports the three-hour KPZ308 class, independent assessment
work, portable projects, selective evidence export, and safe production access.

**Architecture:** Preserve the completed simulation, evidence, and project
foundations as hard engineering layers. Build and review the Shiny experience
one coherent teaching surface at a time, separating backend acceptance from
Barry's ecology, pedagogy, and interface review. Finish with integrated browser,
export, container, and production acceptance.

**Tech Stack:** R 4.6.x, Shiny, testthat, ggplot2, jsonlite, zip,
rmarkdown/Pandoc, JavaScript IndexedDB, Playwright, Docker, and ShinyProxy 3.2.4.

**Authoritative design:**
`docs/superpowers/specs/2026-07-21-practical2-woodhen-management-lab-design.md`

**Gate rationale:**
`docs/superpowers/plans/2026-07-22-practical2-gate-justification-notes.md`

## Global Constraints

- Preserve the locked C1-C4 assessment criteria word-for-word wherever shown.
- Use **Phase 1** and **Phase 2**, not *Act 1* and *Act 2*.
- Use plain student language. Do not expose seeds, YAML names, internal IDs,
  fingerprints, activation terminology, or unexplained implementation jargon.
- Do not describe the core route as pass-level or predict marks, grades, or
  assessment achievement.
- Use authentic, correctly attributed Woodhen or Lord Howe Island imagery.
- Preserve Practical 1 behaviour and all established seeded scalar results.
- Keep ordinary Phase 2 comparisons at the supplied 2025 starting population,
  75 years, 1,000 futures, common simulation settings, and current Woodhen stage
  structure. Label alternative seeds or replicate counts as robustness checks.
- Treat fewer than 50 territory-holding breeding pairs, represented by stages
  2 onward, as the main future quasi-extinction threshold.
- Report bird abundance as whole birds. Use decimals only where they represent
  meaningful probabilities, rates, or model parameters.
- Every stochastic action expected to exceed about two seconds must provide
  visible, engine-driven progress.
- Store compact evidence rather than full 1,000-replicate trajectory arrays in
  the portable project.
- Do not generate report prose, captions, recommendations, mark estimates, or a
  compulsory report structure.
- Do not depend on SSO identity or server workspaces for project resumption. A
  downloaded project ZIP is the supported cross-host transfer method.
- The first release permits only named, bounded threats, interventions,
  sensitivity factors, and generated temporal profiles. It never executes
  student-supplied R, YAML, HTML, scripts, or arbitrary annual schedules.
- Apply the 80/20 rule: one focused self-review and material repair pass per
  gate, then return the surface or evidence for the designated reviewer.

## Ownership And Review Protocol

### Hard Engineering Gates

Codex owns implementation, tests, regression evidence, project integrity,
browser automation, container identity, and rollback safety. Barry is not asked
to review code architecture, test design, storage schemas, internal identifiers,
or deployment mechanics.

A hard gate pauses for Barry only when it exposes a consequential ecological
choice, changes visible behaviour, loses project evidence, or cannot satisfy a
release-safety condition.

### Student-Facing Gates

Codex first verifies that the surface runs and has no obvious technical failure.
Barry then reviews only the experience he can judge effectively:

- ecological accuracy and defensibility;
- teaching sequence and conceptual load;
- student-facing language and in-context explanation;
- plot choice, scale, precision, and interpretability;
- layout, visual hierarchy, density, and interaction taste; and
- whether the surface supports the intended assessment preparation without
  spoon-feeding.

Internal implementation is outside Barry's review unless it leaks into the
student experience. Each student-facing gate waits for explicit acceptance or
revision before dependent interface work proceeds. Backend work that cannot
pre-empt the interface decision may continue in parallel.

## Gate Map And Current State

| Gate | Type | Surface | State on 2026-07-22 |
| --- | --- | --- | --- |
| A | Hard engineering | Scientific engine and risk evidence | Complete |
| B | Hard engineering | Durable projects and compact evidence | Complete |
| C | Student-facing | Start | Implemented; review pending |
| D | Student-facing | Calibrate: 1980 alternatives | Implemented; review pending |
| E | Student-facing | Calibrate: recovery and future | Implemented; review pending |
| F | Student-facing | Investigate: sensitivity | Draft exists; redesign/review pending |
| G | Student-facing | Investigate: threat and intervention | Draft exists; redesign/review pending |
| H | Student-facing | Investigate: advanced sandbox | Not started |
| I | Student-facing | Compare | Not started |
| J | Student-facing | Evidence Studio and guidance | Not started |
| K | Hard engineering | Integrated local acceptance | Not started |
| L | Hard engineering plus final human smoke | Production release | Not started |

---

## Gate A: Scientific Engine And Risk Evidence

**Type:** Hard engineering. **Status:** Complete and committed.

**Established interfaces:**

- validated annual ecological profiles;
- exact preservation of the scalar simulation path;
- extinction and fewer-than-50-pair first-passage evidence;
- reference, sensitivity, threat, and intervention catalogues; and
- compact plotting and comparison inputs.

**Codex acceptance evidence:** Existing focused and shared-engine tests pass;
catalogue bounds and the 50-pair stage interpretation have been audited.

**Barry review:** None required unless a later surface reveals an ecological
assumption that needs changing.

---

## Gate B: Durable Projects And Compact Evidence

**Type:** Hard engineering. **Status:** Complete and committed.

**Established interfaces:**

- versioned Woodhen projects;
- compact reproducible run evidence;
- browser autosave;
- safe project ZIP export/import; and
- explicit run ancestry and evidence selection state.

**Codex acceptance evidence:** Round-trip and state-validation tests pass. No
student-controlled code is executed during import.

**Barry review:** None required. Project movement is reviewed as a visible
workflow at Gate J and an end-to-end behaviour at Gate K.

---

## Gate C: Start

**Type:** Student-facing. **Status:** Implemented; awaiting review.

**Files:**

- `inst/shiny/practical2/modules/mod_start.R`
- `inst/shiny/practical2/content/start.md`
- `inst/shiny/practical2/content/help-woodhen-background.md`
- `inst/shiny/practical2/content/help-projects.md`
- `inst/shiny/practical2/www/img/lord-howe-island-nasa.webp`
- `inst/shiny/practical2/www/styles.css`
- `tests/testthat/test-15_practical2_shiny.R`

- [x] Replace the inaccurate generated bird image with authentic public-domain
  Lord Howe Island imagery and visible attribution.
- [x] Introduce the present-day adviser role and the two scientific phases.
- [x] Add a readable Woodhen history note based on the original practical.
- [x] Explain create, resume, download, and import without developer vocabulary.
- [x] Verify creation, recovery controls, help modals, desktop layout, and text
  contracts with focused tests and Playwright.
- [ ] **Barry review:** assess first impression, ecological framing, student
  language, cognitive load, image suitability, and whether the project actions
  are self-explanatory.
- [ ] Apply at most one material repair pass and obtain acceptance.

**Technical check:**

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-15_practical2_shiny.R", reporter="summary", stop_on_failure=TRUE)'
```

**Gate output:** Accepted Start surface and a focused commit containing Gates
C-E once the complete Calibrate review is also accepted.

---

## Gate D: Calibrate - 1980 Management Alternatives

**Type:** Student-facing. **Status:** Implemented; awaiting review.

**Files:**

- `inst/shiny/practical2/modules/mod_calibrate.R`
- `inst/shiny/practical2/content/help-calibrate.md`
- `inst/shiny/practical2/content/scenarios/01-no-intervention.md`
- `inst/shiny/practical2/content/scenarios/02-pig-control.md`
- `inst/shiny/practical2/content/scenarios/03-captive-pig.md`
- `R/woodhen_investigation_evidence.R`
- `tests/testthat/test-23_practical2_calibrate.R`

- [x] Present the three 1980 scenarios as one compatible decision comparison.
- [x] Add scenario-specific explanation of biological assumptions and limits.
- [x] Show engine-driven progress during 1,000-future runs.
- [x] Show abundance, cumulative extinction risk, extinction timing, and a
  whole-bird key-results panel in a stable two-by-two layout.
- [x] Add a first-decade intervention view for captive breeding and pig control.
- [x] Round stochastic abundance summaries to whole birds.
- [ ] **Barry review:** assess whether the three scenarios tell a coherent
  management story; whether carrying capacity, uncertainty, extinction risk,
  and intervention timing are taught clearly; and whether the plots and table
  support valid comparison without visual overload.
- [ ] Apply at most one material repair pass and obtain acceptance.

**Technical check:** Run the focused Calibrate test command in Gate E after both
Calibrate sections are revised together.

**Gate output:** Accepted historical calibration section.

---

## Gate E: Calibrate - Rodent Recovery And Common Future Comparison

**Type:** Student-facing. **Status:** Implemented; awaiting review.

**Files:**

- `inst/shiny/practical2/modules/mod_calibrate.R`
- `inst/shiny/practical2/content/help-calibrate.md`
- `inst/shiny/practical2/content/scenarios/04-rodent-eradication.md`
- `inst/shiny/practical2/content/scenarios/05-future-comparison.md`
- `R/woodhen_investigation_catalog.R`
- `R/woodhen_investigation_evidence.R`
- `tests/testthat/test-23_practical2_calibrate.R`

- [x] Keep the five-year recovery check visually and conceptually separate from
  the 40-year management alternatives.
- [x] Overlay the 2019 count and 2024 survey milestone on the recovery plot.
- [x] Establish the 2025-2100 no-change case as the common Phase 2 comparison.
- [x] Explain why 50 breeding pairs is an earlier warning threshold than
  extinction.
- [x] Remove exact-count false precision and internal model-state language.
- [ ] **Barry review:** assess the historical calibration claim, survey overlay,
  short-horizon warning, future-comparison framing, 50-pair explanation, plot
  scales, and whether the transition to Phase 2 is intellectually clear.
- [ ] Apply at most one material repair pass and obtain acceptance.

**Technical check:**

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-23_practical2_calibrate.R", reporter="summary", stop_on_failure=TRUE)'
```

**Gate output:** Accepted Calibrate tab, focused browser evidence, and a coherent
checkpoint commit for Gates C-E.

---

## Gate F: Investigate - One-Factor Sensitivity

**Type:** Student-facing. **Status:** Existing draft requires redesign.

**Files:**

- `inst/shiny/practical2/modules/mod_investigate.R`
- `inst/shiny/practical2/content/help-investigate.md`
- `R/woodhen_investigation_catalog.R`
- `R/woodhen_investigation_evidence.R`
- `tests/testthat/test-24_practical2_investigate_core.R`

- [ ] Write failing interface-contract tests requiring a named factor, its
  baseline value and units, two clearly labelled altered values, and a visible
  explanation of what remains constant.
- [ ] Replace *anchor*, *custom value*, and other shorthand with factor-specific
  questions and biologically interpretable controls.
- [ ] Show the relevant baseline assumptions before the student chooses changes.
- [ ] Explain sensitivity analysis, the 50-pair threshold, and the purpose of
  comparing exactly one changed factor at a time.
- [ ] Add engine-driven progress for the three 1,000-future runs.
- [ ] Present the response plot and comparison table without horizontal page
  scrolling and with appropriate numerical precision.
- [ ] Preserve optional research-question, expected-direction, interpretation,
  and caveat notes without forcing completion.
- [ ] Run focused server and interface tests.
- [ ] **Barry review:** assess whether a student who first encountered
  sensitivity analysis in Practical 1 can understand the question, controls,
  held-constant assumptions, outputs, and ecological interpretation.
- [ ] Apply at most one material repair pass and obtain acceptance.

**Technical check:**

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-24_practical2_investigate_core.R", reporter="summary", stop_on_failure=TRUE)'
```

**Gate output:** One accepted sensitivity-family workflow and a focused commit.

---

## Gate G: Investigate - Threat And Intervention

**Type:** Student-facing. **Status:** Existing draft requires redesign.

**Files:**

- `inst/shiny/practical2/modules/mod_investigate.R`
- `inst/shiny/practical2/content/help-investigate.md`
- `R/woodhen_investigation_spec.R`
- `R/woodhen_investigation_catalog.R`
- `tests/testthat/test-24_practical2_investigate_core.R`

- [ ] Write failing interface tests requiring an explicit chain: common future
  comparison, named threat, and intervention applied to that threatened future.
- [ ] Show baseline assumptions, threat mechanism, changed parameter and units,
  intervention mechanism, and all held-constant settings before running.
- [ ] Replace generic low/moderate/high labels with ecological descriptions plus
  exact values; retain bounded customisation where it adds genuine inquiry.
- [ ] Add engine-driven progress for all family members.
- [ ] Present abundance, extinction, 50-pair risk, first-passage timing, and the
  intervention difference from the threatened future in readable views.
- [ ] Explain that improvement relative to the threat is not automatically full
  recovery or proof of effectiveness in the real system.
- [ ] **Barry review:** assess the ecological credibility of threat/intervention
  mappings, the logic of the comparison, the degree of student freedom, the
  clarity of prompts, and whether the evidence supports conservation advice.
- [ ] Apply at most one material repair pass and obtain acceptance.

**Technical check:** Use the same focused test file as Gate F, with distinct
threat/intervention contexts and assertions.

**Gate output:** Accepted compulsory prospective workflow and a focused commit.

---

## Gate H: Investigate - Advanced Sandbox

**Type:** Student-facing. **Status:** Not started.

**Files:**

- `inst/shiny/practical2/modules/mod_investigate.R`
- `inst/shiny/practical2/content/help-investigate.md`
- `R/woodhen_investigation_spec.R`
- `tests/testthat/test-25_practical2_investigate_advanced.R`

- [ ] Write failing tests for delayed and gradual profiles, alternative
  intensities, multiple interventions, compound threats, and robustness checks.
- [ ] Add a collapsed **Ways to deepen your investigation** layer with structured
  controls for intensity, onset, transition, additional components, and repeat
  simulations.
- [ ] Keep the compulsory workflows visually dominant and usable without opening
  the advanced layer.
- [ ] Label every multi-factor scenario and show its complete ancestry and set of
  changes before running.
- [ ] Reject duplicate or conflicting components with actionable student
  messages.
- [ ] **Barry review:** assess whether the sandbox creates genuine intellectual
  headroom without encouraging fantasy Woodhen scenarios, overwhelming the core
  route, or concealing interacting assumptions.
- [ ] Decide at this gate whether lower-value advanced combinations should be
  deferred from the first release.
- [ ] Apply at most one material repair pass and obtain acceptance.

**Technical check:**

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-25_practical2_investigate_advanced.R", reporter="summary", stop_on_failure=TRUE)'
```

**Gate output:** Accepted bounded sandbox or an explicit recorded deferral of
non-essential combinations.

---

## Gate I: Compare

**Type:** Student-facing. **Status:** Not started.

**Files:**

- Create `inst/shiny/practical2/modules/mod_compare.R`
- Create `inst/shiny/practical2/content/help-compare.md`
- Modify `inst/shiny/practical2/app.R`
- Modify `R/woodhen_project.R`
- Modify `R/woodhen_investigation_evidence.R`
- Create `tests/testthat/test-26_practical2_compare.R`

- [ ] Write failing tests for filtering runs, selecting compatible evidence,
  warnings for incompatible comparisons, accumulated notes, and project
  round trips.
- [ ] Give the active comparison and selected evidence most of the screen.
- [ ] Put the full run library in a compact searchable drawer or side panel.
- [ ] Use a segmented control or tabs for trajectories, final distributions,
  risk, first passage, sensitivity response, and intervention comparisons.
- [ ] Allow multiple observations and caveats to accumulate against named runs.
- [ ] Allow runs, tables, plots, and notes to be nominated for the evidence
  dossier while retaining provenance.
- [ ] **Barry review:** assess comparison workflow, visual hierarchy, plot choice,
  warning usefulness, evidence-selection logic, and whether the workspace
  promotes synthesis rather than indiscriminate output accumulation.
- [ ] Apply at most one material repair pass and obtain acceptance.

**Technical check:**

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-26_practical2_compare.R", reporter="summary", stop_on_failure=TRUE)'
```

**Gate output:** Accepted Compare tab and a focused commit.

---

## Gate J: Evidence Studio And Student Guidance

**Type:** Student-facing. **Status:** Not started.

**Files:**

- Create `R/woodhen_dossier.R`
- Create `inst/shiny/practical2/modules/mod_evidence.R`
- Create `inst/shiny/practical2/templates/evidence-dossier.Rmd`
- Create `inst/shiny/practical2/content/help-evidence.md`
- Create `inst/shiny/practical2/content/report-guidance.md`
- Create `inst/shiny/practical2/content/ways-to-deepen.md`
- Create `inst/shiny/practical2/content/woodhen-research.md`
- Create `docs/teaching/woodhen/practical-2-report-guidance.md`
- Modify `inst/shiny/practical2/app.R`
- Modify `docs/teaching/woodhen/practical-2-student-launch-page.md`
- Modify `docs/teaching/woodhen/practical-2-woodhen-management.md`
- Modify `docs/teaching/woodhen/assessment-brief-2026-draft.md`
- Modify `docs/teaching/woodhen/assessment-design-crosswalk-2026.md`
- Modify `docs/teaching/woodhen/classroom-dry-run-checklist.md`
- Modify `docs/teaching/woodhen/expected-outputs.md`
- Modify `docs/teaching/woodhen/README.md`
- Modify `inst/shiny/practical2/README.md`
- Create `tests/testthat/test-27_woodhen_dossier.R`
- Create `tests/testthat/test-28_practical2_content_contract.R`

- [ ] Write failing tests for evidence selection, provenance, sparse-project
  guidance, locked C1-C4 wording, the 2,000-word scope, and output structure.
- [ ] Build an Evidence Studio that previews selected evidence and encourages
  deliberate inclusion rather than automatic bulk export.
- [ ] Generate an editable Word dossier plus CSV tables, PNG figures, Markdown,
  and the separate project ZIP.
- [ ] Validate Word structure and open/convert it non-interactively with
  LibreOffice.
- [ ] Explain report possibilities, evidence selection, literature research,
  uncertainty, display-item restraint, and ways to deepen the investigation
  without writing the report or recommendation for the student.
- [ ] **Barry review:** assess usefulness of the dossier, selectivity prompts,
  report/research guidance, assessment alignment, degree of scaffolding, and
  whether a student can transfer evidence into an individual 2,000-word report.
- [ ] Test export and import in a fresh browser context during the review.
- [ ] Apply at most one material repair pass and obtain acceptance.

**Technical checks:**

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-27_woodhen_dossier.R", reporter="summary", stop_on_failure=TRUE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-28_practical2_content_contract.R", reporter="summary", stop_on_failure=TRUE)'
```

**Gate output:** Accepted five-tab experience, valid exports, aligned teaching
documents, and a focused commit.

---

## Gate K: Integrated Local Acceptance

**Type:** Hard engineering. **Status:** Not started.

**Files:**

- Create `scripts/practical2_browser_acceptance.js`
- Create `scripts/practical2_project_roundtrip_acceptance.R`
- Create `tests/testthat/test-29_practical2_release_contract.R`
- Modify `deploy/shinyproxy/practical2/validate-scaffold.sh`
- Modify `deploy/shinyproxy/practical2/Dockerfile.template`
- Modify `deploy/shinyproxy/practical2/dockerignore.template`
- Modify `deploy/shinyproxy/practical2/README.md`
- Modify `deploy/shinyproxy/practical2/application.spec.example.yml`

- [ ] Run the full R suite once from a clean process.
- [ ] Complete the five-tab route in Playwright with real 1,000-future progress.
- [ ] Export Word, CSV, PNG, Markdown, and project ZIP files and validate their
  structure.
- [ ] Import the project into a fresh browser context, verify evidence and notes,
  add a run, and export again.
- [ ] Check 1366x768, 1440x900, and 390x844 for console errors, blank plots,
  clipped controls, overlap, horizontal document scroll, and missing content.
- [ ] Perform one focused repair pass for material integration failures only.

**Technical checks:**

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter="summary", stop_on_failure=TRUE)'
Rscript scripts/practical2_project_roundtrip_acceptance.R
NODE_PATH=$(npm root -g) PRACTICAL2_URL=http://127.0.0.1:49582 node scripts/practical2_browser_acceptance.js
bash deploy/shinyproxy/practical2/validate-scaffold.sh
```

**Barry review:** None required unless acceptance exposes a visible regression.
Barry receives a concise pass/fail report and material residual risks.

**Gate output:** Clean, integrated release candidate commit.

---

## Gate L: Production Release

**Type:** Hard engineering plus final human smoke. **Status:** Not started.

**Files:**

- Create `docs/ops/deployments/2026-07-24-kpz308-practical2-production.md`
- Modify `docs/ops/teaching-app-deployment-codex-playbook.md` only if the live
  evidence reveals an incorrect instruction.
- Modify `docs/ops/teaching-app-deployment-human-playbook.md` only if the live
  evidence reveals an incorrect instruction.

- [ ] Confirm a clean `main`, exact source SHA, successful Gate K evidence, and
  the intended Practical 2 image recipe.
- [ ] Build `linux/amd64`, run container acceptance, and record the OCI revision.
- [ ] Push one immutable registry tag and verify local, registry, and pulled
  digests are identical.
- [ ] Preserve production `application.yml` metadata and a timestamped rollback
  copy before changing only the Practical 2 spec.
- [ ] Keep access Staff-only for production beta; verify Practical 1 and KPZ314
  remain unchanged.
- [ ] **Barry smoke:** launch through SSO, complete representative Calibrate,
  Investigate, Compare, Evidence Studio, Word export, and project import actions.
- [ ] After staff acceptance, add `KPZ308`, restart safely, and confirm a student
  account can see and launch Practical 2 while Practical 1 remains available.
- [ ] Record immutable identity, access groups, health, browser/export evidence,
  rollback target, and residual operational risk in the deployment report.

**Gate output:** Student-ready production deployment with an exact rollback path.

## Final Acceptance

- [ ] Gates C-J have explicit student-facing acceptance.
- [ ] Scientific profiles and 50-pair evidence remain valid.
- [ ] Start, Calibrate, Investigate, Compare, and Evidence Studio form one clear
  learning progression.
- [ ] The compulsory route is achievable in class and independent exploration
  has genuine headroom.
- [ ] Projects move between browsers/hosts without evidence loss.
- [ ] Word, CSV, PNG, Markdown, and project exports are usable.
- [ ] Practical 1 remains unchanged.
- [ ] Local, container, registry, ShinyProxy, Staff, KPZ308, and rollback checks
  pass.

## Stopping Rule

At each student-facing gate, fix material problems in ecology, pedagogy,
language, interaction, and visualisation. Do not delay the next gate for marginal
styling preferences that do not affect comprehension or use. If two attempts do
not materially improve the gate, stop and seek a changed approach or explicit
decision.
