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
foundations as hard engineering layers while reopening their biological
interpretation through a compact ecological audit. For each substantially new
Shiny surface, approve a representative visual design probe before completing
simulation wiring, persistence, exports, and focused tests. Finish the compulsory
evidence journey before considering the optional advanced sandbox, then complete
integrated classroom, container, and production acceptance.

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
- Treat fewer than 50 territory-holding breeding pairs as a shared **working
  warning threshold for this practical**, not a universal minimum viable
  population or proven biological tipping point. Gate A2 must verify and explain
  exactly how the model stages are converted to breeding-pair abundance.
- Keep the navigation label **Calibrate**, but describe the scientific exercise
  as historical reconstruction, consistency checking, or plausibility checking.
  Do not imply independent validation where observations helped construct or tune
  a scenario.
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
- Treat 1366x768 and 1440x900 as the principal student viewports. A 390x844
  mobile check is non-blocking and asks only whether the app avoids catastrophic
  failure; this analytical application is not phone-first.
- Apply the 80/20 rule: perform one visual and pedagogical self-review before
  presentation. After Barry's review, apply one consolidated material revision
  and return the surface for acceptance. Continue further only where a remaining
  issue materially affects scientific meaning, comprehension, or use.

## Ownership And Review Protocol

### Hard Engineering Gates

Codex owns implementation, tests, regression evidence, project integrity,
browser automation, container identity, and rollback safety. Barry is not asked
to review code architecture, test design, storage schemas, internal identifiers,
or deployment mechanics.

A hard gate pauses for Barry only when it exposes a consequential ecological
choice, changes visible behaviour, loses project evidence, or cannot satisfy a
release-safety condition.

### Scientific Review Gates

Tested implementation does not settle biological meaning. Barry reviews
parameter values and units, empirical or pedagogical provenance, sensitivity
bounds, threat and intervention mechanisms, temporal assumptions, omissions,
and the interpretation of warning thresholds. Codex presents these in a compact
human-readable audit rather than asking Barry to infer them from code.

### Student-Facing Gates

Every substantially new surface has two checkpoints:

1. **Design probe:** the complete visible teaching surface uses cached,
   representative, or stubbed evidence. Controls, copy, help, plots, tables, and
   visual hierarchy are present, but full simulation wiring, persistence, and
   exhaustive tests need not be complete. Barry approves the teaching and
   interaction model before expensive functional completion.
2. **Working implementation:** Codex connects simulation, project state,
   evidence ancestry, exports, and focused tests, then Barry briefly confirms
   that the working surface still matches the approved design.

Before either checkpoint reaches Barry, Codex runs one representative workflow
and inspects the rendered desktop screen rather than accepting successful DOM or
plot-object creation as visual evidence. The review package must state what is
complete and what is deliberately unfinished. Codex explicitly checks:

- adequate plot width and height;
- unclipped uncertainty envelopes;
- probability axes spanning 0-1 with useful ticks;
- whole-bird counts and defensible stochastic precision;
- tables without avoidable page-level horizontal scrolling;
- ecological labels rather than internal object names;
- conceptual explanation before controls;
- visible progress throughout realistic runs;
- help answering what the feature is, why it matters, and how to interpret it;
- the principal desktop viewports; and
- the page as experienced by a student who completed Practical 1 but has never
  seen the implementation plan.

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
| A1 | Hard engineering | Scientific engine and risk evidence | Complete |
| A2 | Scientific review | Ecological assumptions and catalogue audit | Accepted 2026-07-22 |
| B | Hard engineering | Durable projects and compact evidence | Complete |
| C | Student-facing | Start | Implemented; review pending |
| D | Student-facing | Calibrate: 1980 alternatives | Implemented; review pending |
| E | Student-facing | Calibrate: recovery and future | Implemented; review pending |
| F | Two-checkpoint student-facing | Investigate: sensitivity | Design probe next |
| G | Two-checkpoint student-facing | Investigate: threat and intervention | Not started |
| I | Two-checkpoint student-facing | Compare | Not started |
| J1 | Two-checkpoint student-facing | Evidence selection and preview | Not started |
| J2 | Artefact review | Dossier and essential outputs | Not started |
| J3 | Student-facing | Report, research, and assessment guidance | Not started |
| H | Optional student-facing extension | Investigate: advanced sandbox | Deferred behind core |
| K | Hard engineering plus classroom review | Integrated local acceptance and timed dry run | Not started |
| L | Hard engineering plus human smoke | Staff beta and production release | Not started |

---

## Gate A1: Scientific Engine And Risk Evidence

**Type:** Hard engineering. **Status:** Complete and committed.

**Established interfaces:**

- validated annual ecological profiles;
- exact preservation of the scalar simulation path;
- extinction and fewer-than-50-pair first-passage evidence;
- reference, sensitivity, threat, and intervention catalogues; and
- compact plotting and comparison inputs.

**Codex acceptance evidence:** Existing focused and shared-engine tests pass;
catalogue construction and 50-pair calculations satisfy their code contracts.

**Barry review:** None for the implementation mechanics. Biological meaning is
reviewed explicitly in Gate A2.

---

## Gate A2: Ecological Assumptions And Catalogue Audit

**Type:** Scientific review. **Status:** Accepted 22 July 2026; pragmatic model-state convention retained for the 2026 delivery.

**Files:**

- `scripts/audit_practical2_scientific_catalog.R`
- `R/woodhen_investigation_catalog.R`
- `R/woodhen_investigation_spec.R`
- `R/quasi_extinction.R`
- `R/woodhen_investigation_evidence.R`
- Create `docs/teaching/woodhen/practical-2-ecological-assumptions-audit.md`
- Modify `tests/testthat/test-19_woodhen_investigation_spec.R`

- [x] Expand the existing audit to show every baseline parameter, value, unit,
  and model location.
- [x] Show each sensitivity factor with its baseline and two proposed altered
  settings, including units and permitted exploratory range.
- [x] Show each threat and intervention as an ecological process, the exact
  model quantity it changes, the direction and timing of change, and how an
  intervention modifies or offsets its threatened parent.
- [x] Classify every number as empirically sourced, inherited from the existing
  practical, tuned for historical illustration, or a bounded exploratory
  setting; cite the source or state the rationale.
- [x] Distinguish immediate, delayed, gradual, and finite-duration assumptions.
- [x] Record important omitted processes and the inference each omission limits.
- [x] Explain whether the 2019 and 2024 observations helped construct or tune the
  rodent-recovery reconstruction and therefore whether either can be treated as
  independent evidence.
- [x] Explain the 50-pair value as a shared working warning threshold unless a
  defensible empirical or management basis is documented.
- [x] Translate model stages into breeding pairs in biological terms, including
  sex, pair, and individual interpretation; do not rely on the phrase "stages 2
  onward" as sufficient explanation.
- [x] Identify a wider threshold-sensitivity view as an optional extension, not
  a prerequisite for the compulsory workflow.
- [x] **Barry review:** accept, amend, or reject the ecological interpretation,
  values, bounds, temporal assumptions, provenance classes, omissions, and
  threshold treatment before any Investigate design is approved.

**Technical check:**

```bash
Rscript -e 'pkgload::load_all(".", quiet=TRUE); source("scripts/audit_practical2_scientific_catalog.R"); audit_practical2_scientific_catalog(tempdir()); testthat::test_file("tests/testthat/test-19_woodhen_investigation_spec.R", reporter="summary", stop_on_failure=TRUE)'
```

**Gate output:** A Barry-approved ecological assumptions record. Existing engine
code remains accepted unless this review identifies a material biological error.

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
workflow at Gate J2 and an end-to-end behaviour at Gate K.

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
- [ ] Apply one consolidated material revision, return for acceptance, and
  continue only if a remaining issue materially affects meaning or use.

**Technical check:**

```bash
Rscript -e 'pkgload::load_all(".", quiet=TRUE); testthat::test_file("tests/testthat/test-15_practical2_shiny.R", reporter="summary", stop_on_failure=TRUE)'
```

**Gate output:** Accepted Start surface and its own labelled checkpoint commit.
The existing combined pre-review checkpoint remains in history; review-driven
Start changes must not be bundled with Calibrate changes.

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
- [ ] Apply one consolidated material revision, return for acceptance, and
  continue only for a remaining material issue.

**Technical check:** Run the focused Calibrate test command in Gate E after both
Calibrate sections are revised together.

**Gate output:** Accepted historical reconstruction section and its own labelled
checkpoint commit.

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
- [ ] **Barry review:** assess the historical reconstruction and plausibility
  claim, whether the observations are presented with the correct independence,
  the survey overlay, short-horizon warning, future-comparison framing, 50-pair
  explanation, plot scales, and whether the transition to Phase 2 is clear.
- [ ] Apply one consolidated material revision, return for acceptance, and
  continue only for a remaining material issue.

**Technical check:**

```bash
Rscript -e 'pkgload::load_all(".", quiet=TRUE); testthat::test_file("tests/testthat/test-23_practical2_calibrate.R", reporter="summary", stop_on_failure=TRUE)'
```

**Gate output:** Accepted recovery/future section, focused browser evidence, and
its own labelled checkpoint commit.

---

## Gate F: Investigate - One-Factor Sensitivity

**Type:** Two-checkpoint student-facing. **Status:** Design probe follows Gate A2.

**Files:**

- `inst/shiny/practical2/modules/mod_investigate.R`
- `inst/shiny/practical2/content/help-investigate.md`
- Create `inst/shiny/practical2/content/help-sensitivity.md`
- `R/woodhen_investigation_catalog.R`
- `R/woodhen_investigation_evidence.R`
- Create `tests/testthat/helper-practical2-design-fixtures.R`
- `tests/testthat/test-24_practical2_investigate_core.R`

### F1 - Design Probe

- [ ] Build one complete visible sensitivity family from representative compact
  evidence using values already reviewed at Gate A2; full simulation and project
  persistence may remain stubbed.
- [ ] Show a named factor, baseline value and units, two clearly labelled altered
  settings, and an explanation of what remains constant before any controls.
- [ ] Replace *anchor*, *custom value*, and other shorthand with factor-specific
  ecological questions and biologically interpretable controls.
- [ ] Explain one-factor-at-a-time sensitivity analysis, why it is useful and
  limited, and why the working 50-pair warning threshold is being compared.
- [ ] Include the proposed progress treatment, response plot, comparison table,
  optional research-question and expected-direction prompts, observation and
  caveat fields, and contextual help in their intended visual hierarchy.
- [ ] Run and document the shared rendered-output self-review at 1366x768 and
  1440x900, including explicit plot, precision, scrolling, copy, and help checks.
- [ ] Present Barry with the probe and a short list of deliberately unwired
  behaviour.
- [ ] **Barry design review:** decide whether a student who first encountered
  sensitivity analysis in Practical 1 can understand the question, controls,
  held-constant assumptions, response plot, 50-pair result, and prompts.

### F2 - Working Implementation

- [ ] Write failing interface and server tests for the approved design.
- [ ] Wire the approved controls to exactly three 1,000-future runs and compact
  project evidence without changing the visible teaching model.
- [ ] Add engine-driven progress and preserve run ancestry, notes, and selected
  evidence through project round trips.
- [ ] Run one real representative family and repeat the rendered desktop review;
  the response plot and table must not require page-level horizontal scrolling.
- [ ] Run the focused tests and state any deliberate residual limitation.
- [ ] **Barry confirmation:** verify briefly that the working version still
  matches the approved F1 design.
- [ ] Apply one consolidated material revision if needed and create a focused
  Gate F commit.

**Technical check:**

```bash
Rscript -e 'pkgload::load_all(".", quiet=TRUE); testthat::test_file("tests/testthat/test-24_practical2_investigate_core.R", reporter="summary", stop_on_failure=TRUE)'
```

**Gate output:** An approved sensitivity design probe, one working compulsory
sensitivity-family workflow, and a focused commit.

---

## Gate G: Investigate - Threat And Intervention

**Type:** Two-checkpoint student-facing. **Status:** Follows Gate A2 and Gate F.

**Files:**

- `inst/shiny/practical2/modules/mod_investigate.R`
- `inst/shiny/practical2/content/help-investigate.md`
- Create `inst/shiny/practical2/content/help-threat-intervention.md`
- `R/woodhen_investigation_spec.R`
- `R/woodhen_investigation_catalog.R`
- `tests/testthat/helper-practical2-design-fixtures.R`
- `tests/testthat/test-24_practical2_investigate_core.R`

### G1 - Design Probe

- [ ] Build a complete visible baseline-threat-intervention family from one
  representative Gate A2-approved example; project persistence and full
  simulation wiring may remain stubbed.
- [ ] Show the common future assumptions, threat mechanism, changed quantity and
  units, intervention mechanism, and held-constant settings before controls.
- [ ] Use ecological descriptions plus exact values instead of generic
  low/moderate/high labels; expose bounded choice only where it supports inquiry.
- [ ] Include the proposed progress treatment, abundance, extinction, working
  50-pair risk, first-passage timing, intervention difference, result table,
  prompts, and contextual help in the final visual hierarchy.
- [ ] Explain that improvement relative to the threat is not automatically full
  recovery or evidence that the intervention will work in the real system.
- [ ] Run the shared rendered-output self-review at both principal desktop sizes
  and state what remains deliberately unwired.
- [ ] **Barry design review:** assess mechanism credibility, comparison logic,
  degree of freedom, prompt clarity, plot choice, and whether the evidence can
  support conservation reasoning without pre-writing a recommendation.

### G2 - Working Implementation

- [ ] Write failing interface and server tests for the approved design.
- [ ] Wire baseline, threat, and intervention to real 1,000-future runs with
  engine-driven progress, explicit ancestry, compact evidence, and project
  round trips.
- [ ] Run one real representative family and repeat the rendered desktop review,
  including probability scales, interval precision, plot size, and table width.
- [ ] Run the focused tests and state any deliberate residual limitation.
- [ ] **Barry confirmation:** verify briefly that the working version still
  matches the approved G1 design.
- [ ] Apply one consolidated material revision if needed and create a focused
  Gate G commit.

**Technical check:** Use the same focused test file as Gate F, with distinct
threat/intervention contexts and assertions.

**Gate output:** An approved prospective design probe, a working compulsory
threat-intervention workflow, and a focused commit.

---

## Gate I: Compare

**Type:** Two-checkpoint student-facing. **Status:** Core work after Gate G.

**Files:**

- Create `inst/shiny/practical2/modules/mod_compare.R`
- Create `inst/shiny/practical2/content/help-compare.md`
- Modify `inst/shiny/practical2/app.R`
- Modify `R/woodhen_project.R`
- Modify `R/woodhen_investigation_evidence.R`
- `tests/testthat/helper-practical2-design-fixtures.R`
- Create `tests/testthat/test-26_practical2_compare.R`

### I1 - Design Probe

- [ ] Populate the complete visible Compare surface with representative
  historical, sensitivity, and threat-intervention compact evidence.
- [ ] Give the active comparison and selected evidence most of the screen and put
  the run library in a compact searchable drawer or side panel.
- [ ] Show proposed trajectories, final distributions, risk, first-passage,
  sensitivity-response, and intervention-comparison views using the final labels,
  warnings, notes, and evidence-selection interactions.
- [ ] Demonstrate one compatible and one deliberately incompatible comparison so
  warning language can be judged before state logic is completed.
- [ ] Run the shared rendered-output self-review at both principal desktop sizes,
  then state which persistence and comparison actions remain stubbed.
- [ ] **Barry design review:** assess workflow, visual hierarchy, plot choice,
  warning usefulness, evidence-selection logic, and whether the workspace
  promotes synthesis rather than indiscriminate output accumulation.

### I2 - Working Implementation

- [ ] Write failing tests for filtering runs, compatible evidence, warnings,
  accumulated notes, evidence nomination, and project round trips.
- [ ] Wire the approved surface to authoritative project state without changing
  its teaching model.
- [ ] Run representative historical, sensitivity, and prospective comparisons
  and repeat the rendered-output inspection.
- [ ] Run the focused tests and state deliberate residual limitations.
- [ ] **Barry confirmation:** verify briefly that the working version still
  matches the approved I1 design.
- [ ] Apply one consolidated material revision if needed and create a focused
  Gate I commit.

**Technical check:**

```bash
Rscript -e 'pkgload::load_all(".", quiet=TRUE); testthat::test_file("tests/testthat/test-26_practical2_compare.R", reporter="summary", stop_on_failure=TRUE)'
```

**Gate output:** An approved Compare design probe, working comparison and evidence
selection, and a focused commit.

---

## Gate J1: Evidence Selection And Preview

**Type:** Two-checkpoint student-facing. **Status:** Core work after Gate I.

**Files:**

- Create `inst/shiny/practical2/modules/mod_evidence.R`
- Create `inst/shiny/practical2/content/help-evidence.md`
- Modify `inst/shiny/practical2/app.R`
- Modify `R/woodhen_project.R`
- Modify `R/woodhen_investigation_evidence.R`
- `tests/testthat/helper-practical2-design-fixtures.R`
- Create `tests/testthat/test-27_practical2_evidence.R`

### J1a - Design Probe

- [ ] Populate the complete visible Evidence Studio with a deliberately mixed
  representative set of plots, tables, observations, and caveats.
- [ ] Let the student choose a restrained evidence set and preview exactly what
  is being prepared, including scenario identity and provenance.
- [ ] Show sparse, balanced, and excessive selections so the selectivity prompts
  can be judged without automatically choosing evidence for the student.
- [ ] Run the shared rendered-output self-review at both desktop sizes and state
  which export and persistence actions remain stubbed.
- [ ] **Barry design review:** assess hierarchy, selection friction, preview
  usefulness, scaffolding, and whether the surface rewards judgement rather than
  indiscriminate accumulation.

### J1b - Working Implementation

- [ ] Write failing tests for evidence nomination, removal, preview, provenance,
  sparse-project guidance, and project round trips.
- [ ] Wire the approved surface to project state and Compare selections.
- [ ] Run representative sparse and substantial projects through the working
  preview and repeat the rendered desktop review.
- [ ] **Barry confirmation:** verify briefly that the working version still
  matches the approved J1a design.
- [ ] Apply one consolidated material revision if needed and create a focused
  Gate J1 commit.

**Technical check:**

```bash
Rscript -e 'pkgload::load_all(".", quiet=TRUE); testthat::test_file("tests/testthat/test-27_practical2_evidence.R", reporter="summary", stop_on_failure=TRUE)'
```

**Gate output:** Accepted evidence-selection and preview workflow.

---

## Gate J2: Dossier And Essential Outputs

**Type:** Artefact implementation and review. **Status:** Follows Gate J1.

**Files:**

- Create `R/woodhen_dossier.R`
- Create `inst/shiny/practical2/templates/evidence-dossier.Rmd`
- Modify `inst/shiny/practical2/modules/mod_evidence.R`
- Create `tests/testthat/test-28_woodhen_dossier.R`

- [ ] Write failing tests for selected-evidence provenance, whole-bird and
  probability precision, file names, sparse projects, and output structure.
- [ ] Generate the portable project ZIP and editable Word dossier as core
  outputs, plus selected PNG figures and CSV tables as strongly useful companion
  files.
- [ ] Treat Markdown as a secondary convenience: include it when straightforward,
  but do not delay the first release solely for Markdown generation problems.
- [ ] Validate DOCX structure, tables, figures, and provenance; open or convert it
  non-interactively with LibreOffice; and inspect the rendered pages for clipping,
  illegible figures, excessive precision, and false report scaffolding.
- [ ] Test project export/import in a fresh browser context.
- [ ] **Barry artefact review:** inspect one realistic Word dossier and one
  representative PNG/CSV pair for usefulness, visual quality, selection burden,
  and whether they help students write without writing the report for them.
- [ ] Apply one consolidated material revision if needed and create a focused
  Gate J2 commit.

**Technical check:**

```bash
Rscript -e 'pkgload::load_all(".", quiet=TRUE); testthat::test_file("tests/testthat/test-28_woodhen_dossier.R", reporter="summary", stop_on_failure=TRUE)'
```

**Gate output:** Valid and useful core project, Word, PNG, and CSV outputs;
Markdown is included only if it does not threaten the release schedule.

---

## Gate J3: Report, Research, And Assessment Guidance

**Type:** Student-facing content review. **Status:** Follows Gate J2.

**Files:**

- Create `inst/shiny/practical2/content/report-guidance.md`
- Create `inst/shiny/practical2/content/ways-to-deepen.md`
- Create `inst/shiny/practical2/content/woodhen-research.md`
- Create `docs/teaching/woodhen/practical-2-report-guidance.md`
- Modify `docs/teaching/woodhen/practical-2-student-launch-page.md`
- Modify `docs/teaching/woodhen/practical-2-woodhen-management.md`
- Modify `docs/teaching/woodhen/assessment-brief-2026-draft.md`
- Modify `docs/teaching/woodhen/assessment-design-crosswalk-2026.md`
- Modify `docs/teaching/woodhen/classroom-dry-run-checklist.md`
- Modify `docs/teaching/woodhen/expected-outputs.md`
- Modify `docs/teaching/woodhen/README.md`
- Modify `inst/shiny/practical2/README.md`
- Create `tests/testthat/test-29_practical2_content_contract.R`

- [ ] Present the complete visible guidance surface before finalising all linked
  teaching documents: locked C1-C4 wording, approximately 2,000 words, evidence
  selectivity, literature research, uncertainty, display-item restraint, and
  ways to deepen the investigation.
- [ ] State possibilities and quality questions without prescribing one report
  structure, generating prose, or implying that more output is automatically
  better.
- [ ] **Barry content review:** assess language, criteria alignment, research
  encouragement, degree of prescription, and whether the advice is sufficient
  without becoming an assignment-writing template.
- [ ] After approval, align the named app and teaching documents and write the
  locked-content tests.
- [ ] Apply one consolidated material revision if needed and create a focused
  Gate J3 commit.

**Technical check:**

```bash
Rscript -e 'pkgload::load_all(".", quiet=TRUE); testthat::test_file("tests/testthat/test-29_practical2_content_contract.R", reporter="summary", stop_on_failure=TRUE)'
```

**Gate output:** Accepted guidance and aligned teaching documents.

---

## Gate H: Optional Advanced Sandbox

**Type:** Optional two-checkpoint student-facing extension. **Status:** Deferred
until Gates I and J are accepted; it does not block the first core release.

**Files:**

- `inst/shiny/practical2/modules/mod_investigate.R`
- `inst/shiny/practical2/content/help-investigate.md`
- `R/woodhen_investigation_spec.R`
- Create `tests/testthat/test-25_practical2_investigate_advanced.R`

- [ ] Decide from Compare and Evidence Studio experience which advanced
  capabilities produce useful evidence rather than merely more controls.
- [ ] If scheduled, present a design probe for delayed/gradual profiles,
  alternative intensities, multiple interventions, compound threats, and
  robustness checks before wiring them.
- [ ] Keep the compulsory workflows dominant and show complete scenario ancestry
  and changed settings for every multi-factor investigation.
- [ ] Reject duplicate or conflicting components with actionable language.
- [ ] **Barry design review:** assess whether the proposed subset creates genuine
  intellectual headroom without encouraging fantasy Woodhen scenarios or
  overwhelming the core route.
- [ ] Implement and test only the accepted high-value subset, repeat the rendered
  review, obtain brief confirmation, and create a separate Gate H commit.
- [ ] Otherwise record explicit deferral with the data-model hooks preserved.

**Technical check when implemented:**

```bash
Rscript -e 'pkgload::load_all(".", quiet=TRUE); testthat::test_file("tests/testthat/test-25_practical2_investigate_advanced.R", reporter="summary", stop_on_failure=TRUE)'
```

**Gate output:** Either a separately accepted bounded extension or a documented
deferral that does not block the compulsory evidence journey.

---

## Gate K: Integrated Local Acceptance And Classroom Dry Run

**Type:** Hard engineering plus human-paced classroom review. **Status:** Not
started.

**Files:**

- Create `scripts/practical2_browser_acceptance.js`
- Create `scripts/practical2_project_roundtrip_acceptance.R`
- Create `tests/testthat/test-30_practical2_release_contract.R`
- Create `docs/teaching/woodhen/practical-2-classroom-timing-record.md`
- Modify `docs/teaching/woodhen/classroom-dry-run-checklist.md`
- Modify `deploy/shinyproxy/practical2/validate-scaffold.sh`
- Modify `deploy/shinyproxy/practical2/Dockerfile.template`
- Modify `deploy/shinyproxy/practical2/dockerignore.template`
- Modify `deploy/shinyproxy/practical2/README.md`
- Modify `deploy/shinyproxy/practical2/application.spec.example.yml`

- [ ] Run the full R suite once from a clean process.
- [ ] Complete the five-tab route in Playwright with real 1,000-future progress.
- [ ] Export Word, CSV, PNG, and project ZIP files and validate their structure;
  also validate Markdown when it is included.
- [ ] Import the project into a fresh browser context, verify evidence and notes,
  add a run, and export again.
- [ ] Treat 1366x768 and 1440x900 as release viewports and check console errors,
  blank or clipped plots, overlapping controls, avoidable page-level horizontal
  scroll, and missing content.
- [ ] Check 390x844 only for non-blocking catastrophic failure and record mobile
  limitations rather than polishing a phone-first layout.
- [ ] Complete a fresh-project, human-paced compulsory route rather than timing a
  Playwright script. Record required run count and waiting time; approximate time
  in Start, Calibrate, sensitivity, threat-intervention, Compare, and Evidence
  Studio; required reading and interpretive decisions; repetition; undocumented
  assumptions; and material safe to leave for independent assessment work.
- [ ] Confirm that the required classroom route fits three hours for a student who
  reads, thinks, and records observations, not merely for an expert operator.
- [ ] Perform one focused repair pass for material integration failures only.

**Technical checks:**

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter="summary", stop_on_failure=TRUE)'
Rscript scripts/practical2_project_roundtrip_acceptance.R
NODE_PATH=$(npm root -g) PRACTICAL2_URL=http://127.0.0.1:49582 node scripts/practical2_browser_acceptance.js
bash deploy/shinyproxy/practical2/validate-scaffold.sh
```

**Barry review:** Review the human-paced route and timing record, not the test
suite. Confirm whether the compulsory route is realistic for the class and which
extensions should remain independent work.

**Gate output:** Clean integrated release candidate, classroom timing evidence,
and a concise record of material residual risks.

---

## Gate L: Staff Beta And Production Release

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

- [ ] Gate A2 and compulsory Gates C-G, I, and J1-J3 have explicit acceptance.
- [ ] Scientific profiles remain valid and the 50-pair result is presented as an
  explained working warning threshold rather than a universal tipping point.
- [ ] Start, Calibrate, Investigate, Compare, and Evidence Studio form one clear
  learning progression.
- [ ] The compulsory route is achievable in class and independent exploration
  has genuine headroom.
- [ ] Projects move between browsers/hosts without evidence loss.
- [ ] Word, CSV, PNG, and project exports are usable; Markdown is desirable but
  non-blocking.
- [ ] A human-paced dry run demonstrates that the compulsory route fits the
  three-hour class with meaningful reading and interpretation time.
- [ ] Practical 1 remains unchanged.
- [ ] Local, container, registry, ShinyProxy, Staff, KPZ308, and rollback checks
  pass.

## Stopping Rule

At each student-facing gate, complete one visual and pedagogical self-review
before presentation. After Barry's review, make one consolidated material
revision and return the gate for acceptance. Continue further only when a
remaining issue materially affects scientific meaning, comprehension, or use.
Do not delay the next gate for marginal styling preferences. If two attempts do
not materially improve the gate, stop and seek a changed approach or explicit
decision.
