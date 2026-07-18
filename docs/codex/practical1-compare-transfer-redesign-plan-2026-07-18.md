# Practical 1 Compare and Transfer Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the busy Practical 1 closeout with a guided evidence workspace that accumulates comparison-linked observations and hands a current evidence pack into the Practical 2 research workflow.

**Architecture:** Extend the teaching evidence API with immutable observation snapshots, then keep all notebook and readiness state in the existing browser-session Shiny server. Rebuild Compare around concise selectors, a transposed outcome matrix, notebook entries, and final synthesis; move downloads and completion status to Transfer. Preserve current run history, selected-run IDs, download handlers, and Concept Lab behavior wherever possible.

**Tech Stack:** R 4.6, Shiny, testthat, base R serialization for in-session signatures, Markdown/CSV exports, CSS Grid, existing Font Awesome/Shiny controls, Node.js 22, Playwright.

## Global Constraints

- Practical 1 remains browser-session only; add no server-side persistence or accounts.
- The comparison CSV contains exactly the final three selected runs.
- The Markdown notebook contains every saved observation, final synthesis, final selected comparison, and provenance appendix.
- The first baseline stays locked; the latest eligible risk and action runs remain initial defaults.
- Downloads become stale after any final selection, notebook, or synthesis change.
- Compare owns analysis and note-building; Transfer owns downloads and completion.
- Existing Concept Lab, simulation, plotting, and run-history behavior must remain unchanged.
- Use the established modal-help and visual design patterns.
- No important comparison metric may require horizontal scrolling at supported viewports.
- The first tranche excludes persistence, rich-text editing, observation reordering, and in-place observation editing.

---

### Task 1: Observation Snapshots and Notebook Export

**Files:**
- Modify: `R/teaching_api.R`
- Modify: `tests/testthat/test-12_teaching_api.R`

**Interfaces:**
- Consumes: existing teaching run objects with `session_run_id`, `stage`, `label`, `summary`, and `settings`.
- Produces: `build_teaching_observation(runs, observation_id, note)` returning one immutable observation list.
- Produces: `build_teaching_evidence_export(..., observations = list(), synthesis = NULL)` returning `comparison`, `settings`, and `notes` while retaining the existing `interpretation` compatibility argument.

- [ ] **Step 1: Add failing observation-constructor tests**

Create three teaching runs with stable session IDs, call:

```r
observation <- rPVA:::build_teaching_observation(
  list(baseline, risk, action),
  observation_id = 1L,
  note = "Environmental variability increased risk; rescue improved abundance, with wider uncertainty."
)
```

Assert:

```r
expect_identical(observation$id, 1L)
expect_equal(observation$run_ids, c(1L, 4L, 5L))
expect_equal(nrow(observation$comparison), 3L)
expect_true(all(c("run_id", "PE", "Nmed", "delta_PE", "delta_Nmed") %in% names(observation$comparison)))
expect_true(all(c("run_id", "setting", "value") %in% names(observation$settings)))
expect_match(observation$note, "Environmental variability increased risk", fixed = TRUE)
```

- [ ] **Step 2: Run the focused API test and verify RED**

Run:

```bash
Rscript -e 'pkgload::load_all(quiet=TRUE); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter="summary", stop_on_failure=TRUE)'
```

Expected: FAIL because `build_teaching_observation()` does not exist.

- [ ] **Step 3: Add failing accumulated-notebook export tests**

Construct two observations against different risk/action selections and call:

```r
export <- rPVA:::build_teaching_evidence_export(
  list(baseline, final_risk, final_action),
  observations = list(observation_1, observation_2),
  synthesis = "Risk mechanisms differed, but all useful recommendations retained uncertainty.",
  session_run_count = 7L
)
```

Assert the CSV comparison remains three rows and the Markdown contains, in order:

```r
expect_equal(nrow(export$comparison), 3L)
expect_match(export$notes, "## Final synthesis", fixed = TRUE)
expect_match(export$notes, "## Observation notebook", fixed = TRUE)
expect_match(export$notes, "### Observation 1", fixed = TRUE)
expect_match(export$notes, "### Observation 2", fixed = TRUE)
expect_match(export$notes, "## Settings and provenance appendix", fixed = TRUE)
expect_lt(
  grep("## Final synthesis", export$notes, fixed = TRUE),
  grep("## Final selected comparison", export$notes, fixed = TRUE)
)
```

- [ ] **Step 4: Implement the evidence-table helper and observation constructor**

Extract the current comparison/settings assembly into:

```r
teaching_evidence_tables <- function(runs) {
  # Return list(comparison = ..., settings = ...) using stable session run IDs.
}

build_teaching_observation <- function(runs, observation_id, note) {
  note <- trimws(as.character(note))
  if (length(runs) != 3L || !nzchar(note)) {
    stop("An evidence observation requires three runs and a non-empty note.", call. = FALSE)
  }
  tables <- teaching_evidence_tables(runs)
  list(
    id = as.integer(observation_id),
    run_ids = tables$comparison$run_id,
    run_labels = tables$comparison$label,
    stages = tables$comparison$stage,
    comparison = tables$comparison,
    settings = tables$settings,
    note = note
  )
}
```

Validate one positive integer ID, exactly three unique run IDs, and non-empty note text.

- [ ] **Step 5: Extend the Markdown export**

Update `build_teaching_evidence_export()` and `teaching_evidence_notes()` so:

- `synthesis` supersedes `interpretation` when provided;
- old calls using only `interpretation` continue to export one student interpretation note;
- notebook observations render chronologically with their compact comparison tables;
- observation settings and final-selection settings are deduplicated by `run_id`, `setting`, and `value` for the appendix; and
- the CSV comparison remains exactly the final selected runs.

- [ ] **Step 6: Run API tests and verify GREEN**

Run the Task 1 focused command. Expected: all `test-12_teaching_api.R` tests pass.

- [ ] **Step 7: Commit Task 1**

```bash
git add R/teaching_api.R tests/testthat/test-12_teaching_api.R
git commit -m "Add Practical 1 evidence notebook model"
```

---

### Task 2: Session Readiness, Signatures, and Notebook State Helpers

**Files:**
- Modify: `inst/shiny/practical1/session_helpers.R`
- Modify: `tests/testthat/test-13_practical1_shiny.R`

**Interfaces:**
- Consumes: selected run IDs, ordered observation lists from Task 1, final synthesis, and existing run history.
- Produces: `evidence_pack_signature(selected_ids, observations, synthesis)`.
- Produces: revised `evidence_readiness(runs, selected_ids, observations, synthesis, baseline_started)`.
- Produces: `remove_evidence_observation(observations, observation_id)`.

- [ ] **Step 1: Write failing pure-helper tests**

Add tests proving:

```r
signature_a <- evidence_pack_signature(c(1L, 4L, 5L), list(obs1), "Synthesis")
signature_b <- evidence_pack_signature(c(1L, 4L, 5L), list(obs1, obs2), "Synthesis")
signature_c <- evidence_pack_signature(c(1L, 4L, 5L), list(obs1), "Changed synthesis")
expect_false(identical(signature_a, signature_b))
expect_false(identical(signature_a, signature_c))
expect_equal(vapply(remove_evidence_observation(list(obs1, obs2), 1L), `[[`, integer(1), "id"), 2L)
```

Assert readiness is false without observations, false without synthesis, and true with three eligible runs, one observation, and a non-empty synthesis.

- [ ] **Step 2: Run focused Shiny tests and verify RED**

Run:

```bash
Rscript -e 'pkgload::load_all(quiet=TRUE); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter="summary", stop_on_failure=TRUE)'
```

Expected: FAIL because the new helpers and readiness contract do not exist.

- [ ] **Step 3: Implement canonical pack signatures**

Use base serialization so arbitrary note punctuation cannot collide with separators:

```r
evidence_pack_signature <- function(selected_ids, observations, synthesis) {
  state <- list(
    selected_ids = as.integer(selected_ids),
    observations = observations,
    synthesis = trimws(as.character(synthesis %||% ""))
  )
  paste(as.integer(serialize(state, NULL, version = 2)), collapse = "-")
}
```

Implement the same null-safe string handling without introducing a new dependency or `%||%` if it is not already defined.

- [ ] **Step 4: Replace interpretation readiness with notebook readiness**

Return checks named:

```r
c("baseline", "risk", "action", "exactly_three", "observation", "synthesis")
```

Require at least one structurally valid observation and one non-empty synthesis. Keep category validation and exactly-three validation unchanged.

- [ ] **Step 5: Implement observation removal**

Reject invalid IDs and return the remaining observations without renumbering them. Stable IDs preserve the evidence trail.

- [ ] **Step 6: Run focused tests and verify GREEN**

Run the Task 2 focused command. Expected: all tests pass.

- [ ] **Step 7: Commit Task 2**

```bash
git add inst/shiny/practical1/session_helpers.R tests/testthat/test-13_practical1_shiny.R
git commit -m "Track Practical 1 evidence pack readiness"
```

---

### Task 3: Evidence Selection and Outcome Matrix

**Files:**
- Modify: `inst/shiny/practical1/app.R`
- Modify: `inst/shiny/practical1/www/styles.css`
- Modify: `tests/testthat/test-13_practical1_shiny.R`

**Interfaces:**
- Consumes: existing `run_history()`, `selected_risk_run_id()`, `selected_action_run_id()`, and `selected_evidence_runs()`.
- Produces: `evidence_selection_ui()`, `session_history_disclosure_ui()`, and `comparison_matrix_ui()`.
- Keeps input IDs `selected_risk_run_id` and `selected_action_run_id` so server selection logic remains stable.

- [ ] **Step 1: Write failing UI contract tests**

Source `app.R` and assert generated UI contains:

```r
expect_match(selection_html, "Baseline reference", fixed = TRUE)
expect_match(selection_html, "Risk mechanism", fixed = TRUE)
expect_match(selection_html, "Intervention or vortex", fixed = TRUE)
expect_match(history_html, "<details", fixed = TRUE)
expect_match(history_html, "Review all 9 session runs", fixed = TRUE)
expect_match(matrix_html, "Extinction probability", fixed = TRUE)
expect_match(matrix_html, "Median final abundance", fixed = TRUE)
expect_match(matrix_html, "95% interval", fixed = TRUE)
expect_false(grepl("min-width: 960px", new_compare_css, fixed = TRUE))
```

- [ ] **Step 2: Run focused tests and verify RED**

Run the Task 2 focused command. Expected: FAIL on missing new UI helpers.

- [ ] **Step 3: Implement concise evidence choices and slots**

Use `selectInput()` for risk and action categories with labels formatted as:

```text
Run 8 - Catastrophe | chance 0.05; survival 0.60
```

Render the locked baseline as a non-interactive slot. Beneath each current selection, show mission, category, and only stage-specific controls plus shared Core controls that differ from baseline.

- [ ] **Step 4: Implement collapsed history disclosure**

Render semantic `tags$details()` with:

```r
tags$summary(paste("Review all", length(runs), "session runs"))
```

Use compact rows with run number, mission, category, key settings, and selected state. Remove radio inputs from full history.

- [ ] **Step 5: Implement the comparison matrix**

Create one accessible desktop table and one mobile stacked representation from the same matrix data. Show:

- mission;
- key settings;
- extinction probability;
- median final abundance;
- 95% interval;
- delta extinction probability;
- delta median abundance; and
- uncertainty change.

Hide the mobile representation above 780px and the desktop table at or below 780px to avoid duplicate visible content.

- [ ] **Step 6: Replace the Compare page structure**

Use a single-column `.compare-workspace` with section headers and contextual-help controls. Remove the old two-column `.compare-grid`, duplicate run cards, raw `comparison_table`, and long readiness checklist from the default surface.

- [ ] **Step 7: Run focused tests and verify GREEN**

Run the Task 2 focused command. Expected: all tests pass.

- [ ] **Step 8: Commit Task 3**

```bash
git add inst/shiny/practical1/app.R inst/shiny/practical1/www/styles.css tests/testthat/test-13_practical1_shiny.R
git commit -m "Rebuild Practical 1 evidence comparison"
```

---

### Task 4: Accumulated Notebook and Final Synthesis

**Files:**
- Modify: `inst/shiny/practical1/app.R`
- Modify: `inst/shiny/practical1/www/styles.css`
- Modify: `tests/testthat/test-13_practical1_shiny.R`

**Interfaces:**
- Consumes: Task 1 observation constructor and Task 2 readiness/signature helpers.
- Produces reactive state: `evidence_notebook`, `next_observation_id`, `draft_selection_signature`, and `pending_remove_observation_id`.
- Produces inputs: `observation_draft`, `add_observation`, `final_synthesis`, `remove_observation_id`, and `confirm_remove_observation`.

- [ ] **Step 1: Write failing server-state tests**

Use `shiny::testServer()` to create baseline, risk, and action runs, then assert:

```r
session$setInputs(observation_draft = "Risk increased and uncertainty widened.")
session$setInputs(add_observation = 1)
expect_length(evidence_notebook(), 1L)
expect_equal(evidence_notebook()[[1]]$run_ids, selected_evidence_ids())
expect_identical(input$observation_draft, "")
```

Change the risk selection, add a second note, and prove both observations retain different run trios. Remove observation 1 through the confirmation flow and prove observation 2 remains.

- [ ] **Step 2: Write failing draft and reset tests**

Assert a non-empty draft records the current selection signature, changing selection exposes the changed-draft state without erasing text, and complete reset clears notebook, draft signature, synthesis, next ID, and download status.

- [ ] **Step 3: Run focused tests and verify RED**

Run the Task 2 focused command. Expected: FAIL on missing reactive state and handlers.

- [ ] **Step 4: Implement notebook state and add flow**

Initialize:

```r
evidence_notebook <- reactiveVal(list())
next_observation_id <- reactiveVal(1L)
draft_selection_signature <- reactiveVal("")
pending_remove_observation_id <- reactiveVal(NA_integer_)
```

`add_observation` requires a valid three-run selection and non-empty draft, calls `rPVA:::build_teaching_observation()`, appends the result, increments the ID, clears the composer, and clears its draft signature.

- [ ] **Step 5: Implement draft-change warning**

On the first non-empty draft, capture the current selection signature. If later selection differs, render:

```text
Your evidence selection changed. Review this draft before adding it to the notebook.
```

Do not erase or silently reassign the draft.

- [ ] **Step 6: Implement notebook UI and confirmed removal**

Render observation entries in chronological order with run labels, compact metrics, note text, and an explicitly labelled **Remove observation** control. Clicking remove opens a confirmation modal; only `confirm_remove_observation` mutates state.

- [ ] **Step 7: Implement final synthesis and compact readiness**

Add a two-to-three-sentence `textAreaInput("final_synthesis", ...)`. Replace the detailed checklist with one compact readiness summary and show detailed missing items only while incomplete.

- [ ] **Step 8: Wire export and staleness**

Pass `evidence_notebook()` and `input$final_synthesis` into `build_teaching_evidence_export()`. Replace `current_export_signature()` with `evidence_pack_signature()`. Any selection, notebook, or synthesis change clears both recorded download signatures.

- [ ] **Step 9: Run focused tests and verify GREEN**

Run the Task 2 focused command. Expected: all tests pass.

- [ ] **Step 10: Commit Task 4**

```bash
git add inst/shiny/practical1/app.R inst/shiny/practical1/www/styles.css tests/testthat/test-13_practical1_shiny.R
git commit -m "Add Practical 1 observation notebook"
```

---

### Task 5: Contextual Help and Transfer Handoff

**Files:**
- Create: `inst/shiny/practical1/content/compare-selection-help.md`
- Create: `inst/shiny/practical1/content/compare-outcomes-help.md`
- Create: `inst/shiny/practical1/content/compare-notebook-help.md`
- Create: `inst/shiny/practical1/content/transfer-evidence-help.md`
- Modify: `inst/shiny/practical1/app.R`
- Modify: `inst/shiny/practical1/www/styles.css`
- Modify: `tests/testthat/test-13_practical1_shiny.R`

**Interfaces:**
- Consumes: current readiness, selected evidence, notebook count, final synthesis, and download signatures.
- Produces: Compare help modals and `transfer_evidence_pack_ui()`.

- [ ] **Step 1: Write failing help and Transfer tests**

Assert every help file exists, renders through `deep_dive_modal_ui()`, and is opened by an accessible labelled button. Assert Transfer contains:

```text
Your evidence pack
What you practised
From guided comparison to independent investigation
Question
Scenario
Simulation
Comparison
Evidence note
Synthesis
```

Assert the old **Future concepts** and engine/helper wording are absent.

- [ ] **Step 2: Run focused tests and verify RED**

Run the Task 2 focused command. Expected: FAIL because help files and Transfer structure do not exist.

- [ ] **Step 3: Write concise contextual help**

Cover:

- why the evidence set uses baseline, risk, and action/vortex roles;
- how to interpret risk, abundance, intervals, and baseline deltas;
- how an observation differs from final synthesis; and
- why downloads become stale in a temporary browser session.

- [ ] **Step 4: Implement Transfer evidence-pack UI**

Show the final selected trio, final synthesis, observation count, current/stale status, and the existing two download controls. If incomplete, list missing requirements and provide `actionButton("return_to_compare", "Return to Compare")`. Compare ends with `actionButton("review_evidence_pack", "Review evidence pack")`.

- [ ] **Step 5: Add the Practical 2 bridge**

Use the approved copy:

```text
This notebook is unassessed practice. In Practical 2, the same evidence habits will support your individual Woodhen investigation and the report worth 25% of the unit.
```

Describe independent questions, scenario construction, sensitivity analysis, evidence selection, and reproducible argument. Render the six-stage research cycle as a responsive ordered strip.

- [ ] **Step 6: Update session notice and navigation handlers**

Change the global notice to direct students to Transfer for the evidence pack. `review_evidence_pack` opens Transfer; `return_to_compare` opens Compare and focuses the first missing field where practical.

- [ ] **Step 7: Run focused tests and verify GREEN**

Run the Task 2 focused command. Expected: all tests pass.

- [ ] **Step 8: Commit Task 5**

```bash
git add inst/shiny/practical1/app.R inst/shiny/practical1/www/styles.css inst/shiny/practical1/content tests/testthat/test-13_practical1_shiny.R
git commit -m "Reframe Practical 1 evidence transfer"
```

---

### Task 6: Browser Acceptance and Responsive Repair

**Files:**
- Modify: `scripts/practical1_browser_acceptance.js`
- Modify: `inst/shiny/practical1/www/styles.css`
- Modify: `tests/testthat/test-13_practical1_shiny.R`

**Interfaces:**
- Consumes: the finished Compare/Transfer DOM and existing Playwright artifact helpers.
- Produces: current desktop/mobile screenshots and strict notebook/export assertions.

- [ ] **Step 1: Update browser-script contract tests and verify RED**

Require the script to exercise:

- nine-run history collapsed by default;
- concise risk and action selectors;
- three visible comparison roles;
- three observations against at least two different run trios;
- final synthesis;
- stale downloads after notebook or selection change;
- exactly three final CSV rows;
- all observations and synthesis in Markdown;
- Transfer completion only after two fresh downloads; and
- Compare and Transfer at 1440x900 and 390x844.

Run `test-13_practical1_shiny.R` and verify it fails before updating the script.

- [ ] **Step 2: Update the Playwright student route**

Replace old radio-card/readiness selectors with the new evidence workspace controls. Save:

```text
compare-notebook-1440x900.png
compare-notebook-390x844.png
transfer-incomplete-1440x900.png
transfer-complete-1440x900.png
transfer-complete-390x844.png
```

- [ ] **Step 3: Repair responsive styling from captured evidence**

At 390x844 ensure selectors, matrix cards, observation composer, saved entries, synthesis, downloads, and Transfer bridge are readable without page-level horizontal overflow. At desktop widths keep the workspace dense enough that selected evidence and the beginning of the notebook are visible without full-history expansion.

- [ ] **Step 4: Run browser acceptance**

Run:

```bash
NODE_PATH=/home/bwbrook/.nvm/versions/node/v22.18.0/lib/node_modules \
PRACTICAL1_URL=http://127.0.0.1:49581 \
PRACTICAL1_EVIDENCE_DIR=/tmp/rpva-practical1-compare-transfer \
node scripts/practical1_browser_acceptance.js
```

Expected: exit 0, no failed checks, no console errors, no page errors, and accepted screenshots at both viewports.

- [ ] **Step 5: Run focused R tests and verify GREEN**

Run the Task 2 focused command. Expected: all tests pass.

- [ ] **Step 6: Commit Task 6**

```bash
git add scripts/practical1_browser_acceptance.js inst/shiny/practical1/www/styles.css tests/testthat/test-13_practical1_shiny.R
git commit -m "Verify Practical 1 evidence closeout"
```

---

### Task 7: Teaching Documentation and Final Gate

**Files:**
- Modify: `inst/shiny/practical1/README.md`
- Modify: `docs/teaching/shiny/practical-1-mission-tutorial.md`
- Modify: `docs/teaching/woodhen/practical-1-student-launch-page.md`
- Modify: `docs/teaching/woodhen/practical-1-instructor-beat-sheet.md`
- Modify: `tests/testthat/test-13_practical1_shiny.R`

**Interfaces:**
- Consumes: final user-visible workflow and export names.
- Produces: aligned student/instructor guidance and a complete verified checkpoint.

- [ ] **Step 1: Write failing documentation-alignment tests**

Require teaching guidance to mention:

```text
Add to notebook
final synthesis
Transfer
comparison CSV
evidence notebook
temporary browser session
```

Require the launch and instructor guidance to distinguish unassessed Practical 1 rehearsal from the Practical 2 assessed investigation.

- [ ] **Step 2: Run focused tests and verify RED**

Run the Task 2 focused command. Expected: FAIL on missing new workflow language.

- [ ] **Step 3: Update teaching and operator documentation**

Keep instructions concise and action-oriented. Do not turn student documents into feature manuals. Explain the minimum sequence: select evidence, add observations, write synthesis, review Transfer, download both current files.

- [ ] **Step 4: Run focused tests and verify GREEN**

Run the Task 2 focused command. Expected: all tests pass.

- [ ] **Step 5: Run the complete repository test suite**

Run:

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter="summary", stop_on_failure=TRUE)'
```

Expected: zero failures. Record any existing non-failing `renv` diagnostic separately and do not commit generated `renv/activate.R` churn.

- [ ] **Step 6: Run final browser acceptance and inspect results**

Run the Task 6 browser command, then inspect:

```bash
jq '{passed, checks: (.checks|length), failed: [.checks[] | select(.passed != true)], consoleErrors, consoleWarnings, pageErrors}' \
  /tmp/rpva-practical1-compare-transfer/browser-result.json
```

Expected: `passed: true`, no failed checks, and empty browser error arrays.

- [ ] **Step 7: Run repository integrity checks**

```bash
git diff --check
git status --short --branch
```

Confirm no generated runtime files, test evidence, credentials, or unrelated changes are included.

- [ ] **Step 8: Commit Task 7**

```bash
git add inst/shiny/practical1/README.md docs/teaching tests/testthat/test-13_practical1_shiny.R
git commit -m "Document Practical 1 evidence workflow"
```

## Completion Gate

Before presenting the implementation for Barry's beta review:

- every task-specific RED failure was observed before production implementation;
- the complete R suite is green;
- the final browser route is green at desktop and mobile widths;
- screenshots show no incoherent overlap or hidden comparison metrics;
- CSV and Markdown exports satisfy the new contract;
- the worktree contains only planned files; and
- localhost is running at `http://localhost:49581/` for manual review.
