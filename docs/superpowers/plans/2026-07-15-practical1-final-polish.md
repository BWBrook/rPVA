# Practical 1 Final Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver a novice-friendly, evidence-gated KPZ308 Practical 1 Shiny experience, verify it locally, and promote one immutable `linux/amd64` image through dev and production before the class on Monday 20 July 2026.

**Architecture:** Keep the existing four-screen base-Shiny app and all model behaviour, but move pure session/evidence rules into an app-local helper file so they can be unit tested independently. The Shiny server remains in `app.R`, using in-memory reactive state for run history, mission progress, selected evidence, interpretation validity, and download-request status. Release work follows the existing immutable-image playbooks, with the same registry digest promoted from local to dev to production and Practical 2 checked as an unchanged Staff-only neighbour.

**Tech Stack:** R 4.6.0 image runtime, base Shiny, rPVA teaching API, testthat, CSS, small jQuery/Shiny event hooks, Playwright with Chromium, Docker/BuildKit, Gitea Container Registry, ShinyProxy 3.2.4.

## Global Constraints

- Target KPZ308 Practical 1 only; do not change Practical 2 code, image, workspace, or Staff-only production access.
- Preserve PVA science, stage defaults, fixed seed `42`, expected outputs, and exported public teaching API behaviour.
- Retain the four screens `Start`, `Concept Lab`, `Compare`, and `Transfer`.
- Retain every contextual action: `Explore PVA`, `Explore mission`, `Explore evidence`, `Introduction`, `Control help`, `Read outputs`, `Read diagnostics`, `Read plots`, advanced controls, diagnostics, comparison guidance, and plot downloads.
- Treat `1366x768` and `1440x900` as primary acceptance viewports; run `390x844` only as a secondary narrow-screen smoke.
- Keep all missions and top-level tabs clickable; progress is advisory and session-only.
- Count baseline complete only after the student activates `Start baseline`; the precomputed display reference does not count.
- Preserve full successful-run history in memory, while exporting exactly baseline plus one risk run plus one intervention/vortex run.
- Make interpretation nonblank and current for the selected evidence before enabling CSV or Markdown downloads.
- Use `Download requested` language; do not claim the browser saved a file.
- State on Start, Compare, and Transfer: `This session is temporary. Download your comparison CSV and evidence notes before closing the app.`
- Do not add server-side restoration, workspace browsing, telemetry, new R or JavaScript package dependencies, or Practical 2 pedagogy.
- Keep the current production rollback image `git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-20260713-02b09aeed4f0` available.
- Promote the exact dev-accepted image digest to production; do not rebuild between environments.
- Do not make a Monday 20 July deployment change unless responding to a verified incident.

---

## File Map

### Create

- `inst/shiny/practical1/session_helpers.R` - pure stage grouping, run identity, progress, evidence-selection, and readiness rules; no Shiny reactives.
- `inst/shiny/practical1/www/practical1.js` - disables the active model-run button while Shiny is busy and restores it when idle.
- `scripts/practical1_browser_acceptance.js` - repeatable local Playwright acceptance for minimum-success, extension, export, accessibility, console, and viewport checks.
- `docs/ops/deployments/2026-07-19-kpz308-practical1-final-polish.md` - final source/image/dev/prod/rollback record assembled from observed evidence.
- `docs/ops/deployments/evidence/2026-07-18-kpz308-practical1-dev/` - dev command, browser, export, screenshot, and checksum evidence.
- `docs/ops/deployments/evidence/2026-07-19-kpz308-practical1-prod/` - production command, browser, export, screenshot, tester, and checksum evidence.

### Modify

- `inst/shiny/practical1/app.R` - grouped mission rail, explicit baseline progress, robust run/reset handling, selected evidence, save gate, transfer checklist, and temporary-session notices.
- `inst/shiny/practical1/www/styles.css` - laptop hierarchy, grouped mission state, history/selection/readiness layouts, visible focus, and narrow-screen stacking.
- `R/teaching_api.R` - backward-compatible selected-from-session metadata in evidence notes.
- `tests/testthat/test-12_teaching_api.R` - export metadata compatibility and selected-from-session tests.
- `tests/testthat/test-13_practical1_shiny.R` - pure helper tests, Shiny state tests, retained-affordance checks, and static UI/CSS/JavaScript contract checks.
- `inst/shiny/practical1/README.md` - current Core/Explore Further, session, and evidence-pack behaviour.
- `docs/teaching/shiny/practical-1-mission-tutorial.md` - guided Core and optional extension route.
- `docs/teaching/woodhen/practical-1-student-launch-page.md` - two-hour student workflow and temporary-session warning.
- `docs/teaching/woodhen/practical-1-mission-worksheet.md` - five Core model missions and three-run evidence selection.
- `docs/teaching/woodhen/practical-1-day-of-class-pack.md` - one-hour lecture/GUI introduction plus two-hour app sequence.
- `docs/teaching/woodhen/practical-1-instructor-beat-sheet.md` - instructor prompts, recovery, and evidence gate.
- `docs/teaching/woodhen/practical-1-moodle-ready-bundle/moodle-section-text.md` - student-facing Core/Explore and download language.

### Explicitly Unchanged

- `inst/shiny/practical2/`
- `deploy/shinyproxy/practical2/`
- Practical 1 model functions, scenario catalog values, seed, ShinyProxy app ID, access groups, resource limits, port, and workspace mount.

---

### Task 1: Add Pure Session And Evidence Rules

**Files:**
- Create: `inst/shiny/practical1/session_helpers.R`
- Modify: `tests/testthat/test-13_practical1_shiny.R`

**Interfaces:**
- Consumes: teaching run objects with `stage`, `label`, `settings`, and later `session_run_id` fields.
- Produces: `practical1_stage_groups`, `practical1_mission_order`, `practical1_evidence_risk_stages`, `practical1_evidence_action_stages`, `attach_session_run_id()`, `session_run_id()`, `completed_stage_ids()`, `next_incomplete_core_stage()`, `first_baseline_run_id()`, `default_evidence_run_ids()`, `select_session_runs()`, `evidence_selection_signature()`, and `evidence_readiness()`.

- [ ] **Step 1: Add focused failing tests for grouping, identity, progress, defaults, and readiness**

Append a helper loader and tests to `tests/testthat/test-13_practical1_shiny.R`:

```r
load_practical1_session_helpers <- function() {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  env <- new.env(parent = baseenv())
  sys.source(file.path(app_dir, "session_helpers.R"), envir = env)
  env
}

practical1_stub_run <- function(stage, run_id) {
  list(
    stage = stage,
    label = stage,
    settings = data.frame(
      stage = stage,
      label = stage,
      setting = "control_test",
      value = as.character(run_id),
      stringsAsFactors = FALSE
    ),
    session_run_id = as.integer(run_id)
  )
}

test_that("Practical 1 session helpers define the approved Core and extension order", {
  helpers <- load_practical1_session_helpers()

  expect_equal(
    helpers$practical1_stage_groups$core,
    c(
      "deterministic_baseline",
      "carrying_capacity",
      "demographic_stochasticity",
      "environmental_stochasticity",
      "intervention"
    )
  )
  expect_equal(
    helpers$practical1_stage_groups$extension,
    c("genetic_stochasticity", "catastrophe", "extinction_vortex")
  )
  expect_equal(
    helpers$practical1_mission_order,
    c(helpers$practical1_stage_groups$core, helpers$practical1_stage_groups$extension)
  )
})

test_that("Practical 1 run identity and completion ignore the display-only baseline", {
  helpers <- load_practical1_session_helpers()
  baseline <- practical1_stub_run("deterministic_baseline", 1)
  risk <- practical1_stub_run("carrying_capacity", 2)

  expect_equal(helpers$session_run_id(baseline), 1L)
  expect_equal(
    helpers$session_run_id(helpers$attach_session_run_id(risk, 9L)),
    9L
  )
  expect_equal(
    helpers$completed_stage_ids(list(baseline, risk), baseline_started = FALSE),
    "carrying_capacity"
  )
  expect_equal(
    helpers$completed_stage_ids(list(baseline, risk), baseline_started = TRUE),
    c("deterministic_baseline", "carrying_capacity")
  )
  expect_equal(
    helpers$next_incomplete_core_stage(c("deterministic_baseline", "carrying_capacity")),
    "demographic_stochasticity"
  )
})

test_that("Practical 1 evidence defaults use baseline and latest eligible risk and action", {
  helpers <- load_practical1_session_helpers()
  runs <- list(
    practical1_stub_run("deterministic_baseline", 1),
    practical1_stub_run("carrying_capacity", 2),
    practical1_stub_run("environmental_stochasticity", 3),
    practical1_stub_run("intervention", 4),
    practical1_stub_run("extinction_vortex", 5)
  )

  expect_equal(helpers$first_baseline_run_id(runs), 1L)
  expect_equal(
    helpers$default_evidence_run_ids(runs, baseline_started = TRUE),
    c(1L, 3L, 5L)
  )
  expect_equal(
    vapply(helpers$select_session_runs(runs, c(1L, 2L, 4L)), `[[`, character(1), "stage"),
    c("deterministic_baseline", "carrying_capacity", "intervention")
  )
})

test_that("Practical 1 readiness requires exactly baseline risk action and current interpretation", {
  helpers <- load_practical1_session_helpers()
  runs <- list(
    practical1_stub_run("deterministic_baseline", 1),
    practical1_stub_run("environmental_stochasticity", 2),
    practical1_stub_run("intervention", 3),
    practical1_stub_run("catastrophe", 4)
  )
  selected <- c(1L, 2L, 3L)
  signature <- helpers$evidence_selection_signature(selected)

  ready <- helpers$evidence_readiness(
    runs,
    selected,
    interpretation = "Risk rose under shared bad years; intervention improved abundance, with uncertainty remaining.",
    interpretation_signature = signature,
    baseline_started = TRUE
  )
  stale <- helpers$evidence_readiness(
    runs,
    c(1L, 4L, 3L),
    interpretation = "Risk rose under shared bad years; intervention improved abundance, with uncertainty remaining.",
    interpretation_signature = signature,
    baseline_started = TRUE
  )

  expect_true(ready$ready)
  expect_true(all(ready$checks))
  expect_false(stale$ready)
  expect_false(stale$checks[["interpretation_current"]])
  expect_true(stale$checks[["interpretation"]])
})
```

- [ ] **Step 2: Run the focused file and verify the new tests fail because the helper file is absent**

Run:

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
```

Expected: the new helper tests fail at `sys.source()` because `session_helpers.R` does not exist; pre-existing Practical 1 assertions still run.

- [ ] **Step 3: Create the complete pure helper module**

Create `inst/shiny/practical1/session_helpers.R` with:

```r
practical1_stage_groups <- list(
  core = c(
    "deterministic_baseline",
    "carrying_capacity",
    "demographic_stochasticity",
    "environmental_stochasticity",
    "intervention"
  ),
  extension = c(
    "genetic_stochasticity",
    "catastrophe",
    "extinction_vortex"
  )
)

practical1_mission_order <- unname(unlist(practical1_stage_groups, use.names = FALSE))

practical1_evidence_risk_stages <- c(
  "carrying_capacity",
  "demographic_stochasticity",
  "environmental_stochasticity",
  "genetic_stochasticity",
  "catastrophe"
)

practical1_evidence_action_stages <- c("intervention", "extinction_vortex")

attach_session_run_id <- function(run, run_id) {
  stopifnot(is.list(run), length(run_id) == 1L, !is.na(run_id), run_id >= 1)
  run$session_run_id <- as.integer(run_id)
  run
}

session_run_id <- function(run) {
  id <- run$session_run_id
  if (length(id) != 1L || is.na(id)) {
    stop("A session run must have one non-missing session_run_id.", call. = FALSE)
  }
  as.integer(id)
}

completed_stage_ids <- function(runs, baseline_started) {
  if (!length(runs)) {
    return(character())
  }
  stages <- unique(vapply(runs, `[[`, character(1), "stage"))
  if (!isTRUE(baseline_started)) {
    stages <- setdiff(stages, "deterministic_baseline")
  }
  practical1_mission_order[practical1_mission_order %in% stages]
}

next_incomplete_core_stage <- function(completed_stages) {
  remaining <- setdiff(practical1_stage_groups$core, completed_stages)
  if (length(remaining)) remaining[[1]] else NA_character_
}

first_baseline_run_id <- function(runs) {
  if (!length(runs)) {
    return(NA_integer_)
  }
  stages <- vapply(runs, `[[`, character(1), "stage")
  index <- which(stages == "deterministic_baseline")
  if (!length(index)) NA_integer_ else session_run_id(runs[[index[[1]]]])
}

latest_stage_group_run_id <- function(runs, eligible_stages) {
  if (!length(runs)) {
    return(NA_integer_)
  }
  stages <- vapply(runs, `[[`, character(1), "stage")
  index <- which(stages %in% eligible_stages)
  if (!length(index)) NA_integer_ else session_run_id(runs[[tail(index, 1)]])
}

default_evidence_run_ids <- function(runs, baseline_started) {
  ids <- c(
    if (isTRUE(baseline_started)) first_baseline_run_id(runs) else NA_integer_,
    latest_stage_group_run_id(runs, practical1_evidence_risk_stages),
    latest_stage_group_run_id(runs, practical1_evidence_action_stages)
  )
  as.integer(ids[!is.na(ids)])
}

select_session_runs <- function(runs, selected_ids) {
  selected_ids <- as.integer(selected_ids)
  if (!length(selected_ids)) {
    return(list())
  }
  run_ids <- vapply(runs, session_run_id, integer(1))
  index <- match(selected_ids, run_ids)
  if (anyNA(index)) {
    stop("Every selected evidence ID must identify a successful session run.", call. = FALSE)
  }
  runs[index]
}

evidence_selection_signature <- function(selected_ids) {
  paste(as.integer(selected_ids), collapse = ":")
}

evidence_readiness <- function(runs,
                               selected_ids,
                               interpretation,
                               interpretation_signature,
                               baseline_started) {
  selected_ids <- as.integer(selected_ids)
  selected <- tryCatch(
    select_session_runs(runs, selected_ids),
    error = function(error) list()
  )
  stages <- if (length(selected)) {
    vapply(selected, `[[`, character(1), "stage")
  } else {
    character()
  }
  interpretation_present <- length(interpretation) == 1L && nzchar(trimws(interpretation))
  current_signature <- evidence_selection_signature(selected_ids)

  checks <- c(
    baseline = isTRUE(baseline_started) && sum(stages == "deterministic_baseline") == 1L,
    risk = sum(stages %in% practical1_evidence_risk_stages) == 1L,
    action = sum(stages %in% practical1_evidence_action_stages) == 1L,
    exactly_three = length(selected_ids) == 3L && length(unique(selected_ids)) == 3L && length(selected) == 3L,
    interpretation = interpretation_present,
    interpretation_current = interpretation_present && identical(interpretation_signature, current_signature)
  )

  list(
    ready = all(checks),
    checks = checks,
    messages = c(
      baseline = "Baseline run 1 is included.",
      risk = "One risk-mechanism run is selected.",
      action = "One intervention or vortex run is selected.",
      exactly_three = "The evidence set contains exactly three different runs.",
      interpretation = "A one-sentence interpretation is present.",
      interpretation_current = "The interpretation matches the current selection."
    )
  )
}
```

- [ ] **Step 4: Run the focused tests and verify the helper contract passes**

Run the Step 2 command again.

Expected: all new helper tests pass; failures from old source-text expectations are permitted only where later tasks deliberately replace those contracts.

- [ ] **Step 5: Commit the pure rules**

```bash
git add inst/shiny/practical1/session_helpers.R tests/testthat/test-13_practical1_shiny.R
git commit -m "Add Practical 1 session evidence rules"
```

Expected: one signed commit containing only the helper module and its tests.

---

### Task 2: Record Selected Evidence As Part Of A Larger Session

**Files:**
- Modify: `R/teaching_api.R:188-232`
- Modify: `R/teaching_api.R:602-645`
- Modify: `tests/testthat/test-12_teaching_api.R:199-276`

**Interfaces:**
- Consumes: `build_teaching_evidence_export(runs, generated_at, seed, interpretation)` callers.
- Produces: backward-compatible optional argument `session_run_count = length(runs)` on `build_teaching_evidence_export()` and `session_run_count = nrow(comparison)` on `teaching_evidence_notes()`.

- [ ] **Step 1: Add failing compatibility and selected-from-session assertions**

Extend the first evidence-export test with:

```r
expect_true(any(grepl("Selected evidence: 2 runs from 2 successful session runs", export$notes, fixed = TRUE)))
```

Add this test after the interpretation test:

```r
test_that("teaching evidence notes distinguish selected runs from full session history", {
  det <- run_teaching_pva("deterministic_baseline", keep_traj = FALSE, seed = 42)
  risk <- run_teaching_pva(
    "environmental_stochasticity",
    controls = list(env_sd = 0.25, K = 35),
    keep_traj = FALSE,
    seed = 42
  )
  action <- run_teaching_pva("intervention", keep_traj = FALSE, seed = 42)
  det$session_run_id <- 1L
  risk$session_run_id <- 6L
  action$session_run_id <- 8L

  export <- build_teaching_evidence_export(
    list(det, risk, action),
    generated_at = as.POSIXct("2026-07-15 00:00:00", tz = "UTC"),
    interpretation = "Risk increased under bad years; intervention improved abundance, with uncertainty remaining.",
    session_run_count = 8L
  )

  expect_equal(nrow(export$comparison), 3L)
  expect_equal(export$comparison$run_id, c(1L, 6L, 8L))
  expect_equal(sort(unique(export$settings$run_id)), c(1L, 6L, 8L))
  expect_true(any(grepl(
    "Selected evidence: 3 runs from 8 successful session runs",
    export$notes,
    fixed = TRUE
  )))
  expect_true(any(grepl("## Student interpretation note", export$notes, fixed = TRUE)))
})
```

- [ ] **Step 2: Run the API tests and verify they fail on the new argument/text**

Run:

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'
```

Expected: failure reports `unused argument (session_run_count = 8L)` and the old `Runs included` line does not match.

- [ ] **Step 3: Add the compatible count argument and exact evidence note**

Change the signatures and note call to:

```r
build_teaching_evidence_export <- function(runs,
                                           generated_at = Sys.time(),
                                           seed = 42,
                                           interpretation = NULL,
                                           session_run_count = length(runs)) {
```

Before constructing `comparison`, derive IDs that preserve app-local session provenance while keeping all existing non-Shiny callers numbered `1:n`:

```r
run_ids <- vapply(seq_along(runs), function(i) {
  id <- runs[[i]]$session_run_id
  if (is.null(id)) as.integer(i) else as.integer(id)
}, integer(1))
if (anyNA(run_ids) || anyDuplicated(run_ids)) {
  stop("Evidence run IDs must be non-missing and unique.", call. = FALSE)
}
```

Use `run_ids` in both tables:

```r
comparison <- data.frame(
  run_id = run_ids,
  comparison,
  row.names = NULL,
  stringsAsFactors = FALSE
)
```

```r
run_id = rep(run_ids[[i]], nrow(run_settings)),
```

```r
notes = teaching_evidence_notes(
  comparison,
  settings,
  generated_at,
  seed,
  interpretation,
  session_run_count
)
```

Change the notes signature to:

```r
teaching_evidence_notes <- function(comparison,
                                    settings,
                                    generated_at,
                                    seed,
                                    interpretation = NULL,
                                    session_run_count = nrow(comparison)) {
```

Validate the count immediately after `seed_label`:

```r
session_run_count <- as.integer(session_run_count)
if (length(session_run_count) != 1L || is.na(session_run_count) || session_run_count < nrow(comparison)) {
  stop("session_run_count must be at least the number of selected evidence runs.", call. = FALSE)
}
```

Replace `paste0("Runs included: ", nrow(comparison))` with:

```r
paste0(
  "Selected evidence: ", nrow(comparison),
  " runs from ", session_run_count,
  " successful session runs"
)
```

- [ ] **Step 4: Run focused API tests and the teaching API regression file**

Run the Step 2 command.

Expected: all `test-12_teaching_api.R` tests pass, including existing two-run callers that omit the new argument.

- [ ] **Step 5: Commit the compatible export change**

```bash
git add R/teaching_api.R tests/testthat/test-12_teaching_api.R
git commit -m "Record selected evidence session size"
```

---

### Task 3: Build The Grouped Mission Rail And Accurate Soft Progress

**Files:**
- Modify: `inst/shiny/practical1/app.R:1-54,28-47,449-483,639-760,893-1030`
- Modify: `tests/testthat/test-13_practical1_shiny.R`

**Interfaces:**
- Consumes: all symbols from `session_helpers.R` and existing stage catalog/control functions.
- Produces: `selected_stage` reactive state, grouped clickable mission inputs named `mission_<stage>`, `baseline_started`, monotonic current-history run IDs, and `make_practical1_server(execute_stage = run_stage)`.

- [ ] **Step 1: Replace stale static assertions with failing behavioural/static contracts**

Add assertions that:

```r
expect_true(file.exists(file.path(app_dir, "session_helpers.R")))
expect_true(grepl('source("session_helpers.R", local = TRUE)', app_text, fixed = TRUE))
expect_true(grepl('span(class = "mission-group-title", "Core")', app_text, fixed = TRUE))
expect_true(grepl('span(class = "mission-group-title", "Explore Further")', app_text, fixed = TRUE))
expect_true(grepl('actionLink(paste0("mission_", stage)', app_text, fixed = TRUE))
expect_true(grepl("selected_stage <- reactiveVal(default_stage)", app_text, fixed = TRUE))
expect_true(grepl("baseline_started <- reactiveVal(FALSE)", app_text, fixed = TRUE))
expect_true(grepl("run_history <- reactiveVal(list())", app_text, fixed = TRUE))
expect_false(grepl('selectInput("stage"', app_text, fixed = TRUE))
```

Add a server-factory smoke using `shiny::testServer()`:

```r
test_that("Practical 1 baseline progress begins only after Start baseline", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)

  shiny::testServer(env$make_practical1_server(), {
    expect_false(baseline_started())
    expect_length(run_history(), 0L)
    session$setInputs(run_baseline = 1)
    expect_true(baseline_started())
    expect_length(run_history(), 1L)
    expect_equal(run_history()[[1]]$stage, "deterministic_baseline")
    expect_equal(session_run_id(run_history()[[1]]), 1L)
  })
})
```

- [ ] **Step 2: Run the focused tests and verify the new contracts fail**

Run:

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
```

Expected: failures identify the absent helper source, grouped action links, server factory, and explicit baseline state.

- [ ] **Step 3: Source helpers and update mission labels/order**

Immediately after `library(shiny)` add:

```r
source("session_helpers.R", local = TRUE)
```

Replace `stage_missions` with:

```r
stage_missions <- c(
  deterministic_baseline = "Core 1: Baseline compass",
  carrying_capacity = "Core 2: Island ceiling",
  demographic_stochasticity = "Core 3: Individual chance",
  environmental_stochasticity = "Core 4: Shared bad years",
  intervention = "Core 5: Rescue attempt",
  genetic_stochasticity = "Explore: Small-population pressure",
  catastrophe = "Explore: Rare bad years",
  extinction_vortex = "Explore: Vortex comparison"
)
```

Replace mission navigation helpers so they use `practical1_mission_order`, not catalog row order:

```r
adjacent_mission_stage <- function(stage, offset) {
  current <- match(stage, practical1_mission_order)
  if (is.na(current)) {
    return(default_stage)
  }
  practical1_mission_order[[max(1L, min(length(practical1_mission_order), current + offset))]]
}

next_mission_stage <- function(stage) adjacent_mission_stage(stage, 1L)
previous_mission_stage <- function(stage) adjacent_mission_stage(stage, -1L)
```

- [ ] **Step 4: Replace the static rail with grouped, clickable, status-labelled actions**

Replace `mission_rail_ui()` with:

```r
mission_rail_ui <- function(current_stage, completed_stages = character()) {
  group_ui <- function(title, stages, group_class) {
    div(
      class = paste("mission-group", group_class),
      span(class = "mission-group-title", title),
      lapply(seq_along(stages), function(index) {
        stage <- stages[[index]]
        complete <- stage %in% completed_stages
        step_class <- paste(c(
          "mission-step",
          if (identical(stage, current_stage)) "is-current",
          if (complete) "is-complete"
        ), collapse = " ")
        status <- if (complete) "Complete" else if (identical(stage, current_stage)) "Current" else "Available"

        actionLink(
          paste0("mission_", stage),
          label = tagList(
            span(class = "mission-step-index", if (group_class == "is-core") index else "+"),
            span(class = "mission-step-label", stage_missions[[stage]]),
            span(class = "mission-step-status", status)
          ),
          class = step_class,
          `aria-current` = if (identical(stage, current_stage)) "step" else NULL
        )
      })
    )
  }

  div(
    class = "mission-rail",
    group_ui("Core", practical1_stage_groups$core, "is-core"),
    group_ui("Explore Further", practical1_stage_groups$extension, "is-extension")
  )
}
```

Remove the stage `selectInput()` from Concept Lab. Keep `uiOutput("mission_rail")` in its place.

Rename the primary model action while retaining its input ID:

```r
actionButton(
  "run_stage",
  label = tagList(icon("play"), "Run mission"),
  class = "btn-primary"
)
```

- [ ] **Step 5: Introduce the server factory and explicit in-memory progress state**

Change the server declaration and initial state to:

```r
make_practical1_server <- function(execute_stage = run_stage) {
  function(input, output, session) {
    reference_baseline <- run_stage(default_stage)
    baseline_run <- reactiveVal(reference_baseline)
    current_run <- reactiveVal(reference_baseline)
    run_history <- reactiveVal(list())
    next_run_id <- reactiveVal(1L)
    baseline_started <- reactiveVal(FALSE)
    selected_stage <- reactiveVal(default_stage)
```

Close both functions before app construction and instantiate them with:

```r
  }
}

server <- make_practical1_server()
shinyApp(ui, server)
```

Inside the server factory, replace every stage read from `input$stage` with `selected_stage()`. Replace every `updateSelectInput(..., "stage", selected = value)` with `selected_stage(value)`.

Register every clickable rail input:

```r
lapply(practical1_mission_order, function(stage) {
  local({
    stage_id <- stage
    observeEvent(input[[paste0("mission_", stage_id)]], {
      selected_stage(stage_id)
    }, ignoreInit = TRUE)
  })
})
```

Replace Start baseline handling with:

```r
observeEvent(input$run_baseline, {
  baseline <- attach_session_run_id(execute_stage(default_stage), 1L)
  baseline_run(baseline)
  current_run(baseline)
  run_history(list(baseline))
  next_run_id(2L)
  baseline_started(TRUE)
  selected_stage(default_stage)
  updateNavbarPage(session, "section", selected = "Concept Lab")
})
```

Replace mission completion derivation with:

```r
completed <- completed_stage_ids(run_history(), baseline_started())
```

Render the recommended next Core action from:

```r
next_core <- next_incomplete_core_stage(completed_stage_ids(run_history(), baseline_started()))
```

If `next_core` is missing, render `Core route complete. Continue to Compare, or explore another mission.` Otherwise render the matching `stage_missions[[next_core]]`.

- [ ] **Step 6: Run focused tests and repair only intentional old-contract assertions**

Run the Step 2 command.

Expected: the baseline behaviour test passes, grouped Core/Explore assertions pass, and all retained controls/help/plot tests still pass. Remove or update assertions that required the deleted selector or the old catalog mission order; do not weaken assertions for retained features.

- [ ] **Step 7: Commit grouped navigation and progress**

```bash
git add inst/shiny/practical1/app.R tests/testthat/test-13_practical1_shiny.R
git commit -m "Guide Practical 1 through Core missions"
```

---

### Task 4: Make Runs, Reset, And Session Loss Recoverable

**Files:**
- Create: `inst/shiny/practical1/www/practical1.js`
- Modify: `inst/shiny/practical1/app.R:639-890,893-1030`
- Modify: `tests/testthat/test-13_practical1_shiny.R`

**Interfaces:**
- Consumes: `make_practical1_server(execute_stage)`, `run_history`, `next_run_id`, `baseline_started`, and `selected_stage` from Task 3.
- Produces: `run_error`, `last_completed_stage`, `last_completed_run_id`, confirmed reset inputs `clear_runs`/`confirm_clear_runs`, and shared `session_notice_ui()`.

- [ ] **Step 1: Add failing tests for failed-run non-completion, reset confirmation, JavaScript busy state, and notices**

Add a `testServer()` case using an executor that fails only for catastrophe:

```r
test_that("failed Practical 1 runs do not enter history or progress", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)
  execute <- function(stage, controls = list()) {
    if (identical(stage, "catastrophe")) stop("bounded test failure")
    env$run_stage(stage, controls)
  }

  shiny::testServer(env$make_practical1_server(execute), {
    session$setInputs(run_baseline = 1)
    selected_stage("catastrophe")
    before <- length(run_history())
    session$setInputs(run_stage = 1)
    expect_equal(length(run_history()), before)
    expect_false("catastrophe" %in% completed_stage_ids(run_history(), baseline_started()))
    expect_match(run_error(), "could not complete")
  })
})
```

Add static assertions for all three notice placements, `showModal()`, `confirm_clear_runs`, the JavaScript include, `shiny:busy`, and `shiny:idle`.

Use this exact test:

```r
test_that("Practical 1 declares temporary state and guarded recovery", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")
  js_path <- file.path(app_dir, "www", "practical1.js")
  expect_true(file.exists(js_path))
  js_text <- paste(readLines(js_path, warn = FALSE), collapse = "\n")

  notice <- paste(
    "This session is temporary. Download your comparison CSV and evidence notes",
    "before closing the app."
  )
  count_fixed <- function(pattern, text) {
    hits <- gregexpr(pattern, text, fixed = TRUE)[[1]]
    if (identical(hits, -1L)) 0L else length(hits)
  }
  expect_equal(count_fixed(notice, app_text), 1L)
  expect_true(grepl("session_notice_ui()", app_text, fixed = TRUE))
  expect_equal(count_fixed("session_notice_ui()", app_text), 3L)
  expect_true(grepl('tags$script(src = "practical1.js")', app_text, fixed = TRUE))
  expect_true(grepl("showModal(modalDialog(", app_text, fixed = TRUE))
  expect_true(grepl("observeEvent(input$confirm_clear_runs", app_text, fixed = TRUE))
  expect_true(grepl('role = "alert"', app_text, fixed = TRUE))
  expect_true(grepl('$(document).on("shiny:busy"', js_text, fixed = TRUE))
  expect_true(grepl('$(document).on("shiny:idle"', js_text, fixed = TRUE))
  expect_true(grepl('$("#run_stage").prop("disabled", true)', js_text, fixed = TRUE))
})
```

- [ ] **Step 2: Run the focused file and verify the recovery contracts fail**

Run the Task 3 focused-test command.

Expected: the failure test reports missing `run_error`, and static checks report absent confirmation, notices, and script.

- [ ] **Step 3: Add the exact session notice and include the JavaScript**

Define once above `ui`:

```r
session_notice_ui <- function() {
  div(
    class = "session-notice",
    icon("clock"),
    span("This session is temporary. Download your comparison CSV and evidence notes before closing the app.")
  )
}
```

Add `session_notice_ui()` once in each Start, Compare, and Transfer `page-shell`. Change the navbar header to:

```r
header = tags$head(
  tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
  tags$script(src = "practical1.js")
),
```

Create `inst/shiny/practical1/www/practical1.js`:

```javascript
$(document).on("shiny:busy", function () {
  $("#run_stage").prop("disabled", true).attr("aria-busy", "true");
});

$(document).on("shiny:idle", function () {
  $("#run_stage").prop("disabled", false).removeAttr("aria-busy");
});
```

- [ ] **Step 4: Catch run failures without mutating successful state**

Add server state:

```r
run_error <- reactiveVal(NULL)
last_completed_stage <- reactiveVal(NULL)
last_completed_run_id <- reactiveVal(NA_integer_)
```

Replace the mission-run observer with:

```r
observeEvent(input$run_stage, {
  stage <- selected_stage()
  if (identical(stage, default_stage)) {
    updateNavbarPage(session, "section", selected = "Start")
    run_error("Use Start baseline to create baseline run 1.")
    return()
  }

  run_error(NULL)
  result <- tryCatch(
    withProgress(message = "Running mission", value = 0.5, {
      execute_stage(
        stage,
        stage_control_values(stage, input, advanced = isTRUE(input$show_advanced_controls))
      )
    }),
    error = function(error) error
  )

  if (inherits(result, "error")) {
    run_error("This mission could not complete. Check the controls and try again.")
    return()
  }

  run <- attach_session_run_id(result, next_run_id())
  next_run_id(next_run_id() + 1L)
  current_run(run)
  run_history(c(run_history(), list(run)))
  last_completed_stage(stage)
  last_completed_run_id(session_run_id(run))
})
```

Render `run_error` directly below the mission actions with `role="alert"`. Render a compact successful cue from `last_completed_stage()` and the next incomplete Core stage; do not navigate automatically. Give the cue a stable completion marker for browser synchronization:

```r
div(
  class = "mission-complete",
  `data-run-id` = last_completed_run_id(),
  strong("Mission complete: "),
  stage_missions[[last_completed_stage()]],
  p(class = "muted", next_core_message)
)
```

- [ ] **Step 5: Require confirmation before a complete reset**

Replace immediate reset with:

```r
observeEvent(input$clear_runs, {
  showModal(modalDialog(
    title = "Reset this session?",
    p("Run history, evidence selection, interpretation, and in-session progress will be cleared."),
    footer = tagList(
      modalButton("Keep my work"),
      actionButton("confirm_clear_runs", "Reset session", class = "btn-danger")
    ),
    easyClose = TRUE
  ))
})
```

Add the confirmation observer with the state available at this task:

```r
observeEvent(input$confirm_clear_runs, {
  removeModal()
  reference <- run_stage(default_stage)
  baseline_run(reference)
  current_run(reference)
  run_history(list())
  next_run_id(1L)
  baseline_started(FALSE)
  selected_stage(default_stage)
  run_error(NULL)
  last_completed_stage(NULL)
  last_completed_run_id(NA_integer_)
  updateTextAreaInput(session, "interpretation_note", value = "")
  updateNavbarPage(session, "section", selected = "Start")
})
```

Task 6 extends this observer with evidence/download state introduced later.

- [ ] **Step 6: Run focused tests and commit recovery behaviour**

Run the focused Practical 1 test file twice to catch state leakage.

Expected: both runs pass; the missing-Markdown fallback assertions remain green.

```bash
git add inst/shiny/practical1/app.R inst/shiny/practical1/www/practical1.js tests/testthat/test-13_practical1_shiny.R
git commit -m "Make Practical 1 session recovery explicit"
```

---

### Task 5: Separate Session History From Three-Run Evidence

**Files:**
- Modify: `inst/shiny/practical1/app.R:523-556,820-890,893-1130`
- Modify: `tests/testthat/test-13_practical1_shiny.R`

**Interfaces:**
- Consumes: Task 1 selection/readiness helpers and successful run IDs.
- Produces: `selected_risk_run_id`, `selected_action_run_id`, `selected_evidence_ids()`, `selected_evidence_runs()`, `interpretation_signature`, `evidence_readiness_state()`, `session_history_ui()`, and selected-only `run_cards_ui()`/comparison table.

- [ ] **Step 1: Add failing selection and stale-interpretation server tests**

Add a `testServer()` workflow that starts baseline, runs environmental stochasticity and intervention, verifies smart defaults, then changes the risk choice and verifies the signature is stale until `confirm_interpretation` fires. Use real `env$run_stage()` and `selected_stage()` so science defaults remain exercised.

The key assertions are:

```r
expect_equal(length(selected_evidence_ids()), 3L)
expect_equal(
  vapply(selected_evidence_runs(), `[[`, character(1), "stage"),
  c("deterministic_baseline", "environmental_stochasticity", "intervention")
)
expect_true(evidence_readiness_state()$ready)
expect_false(evidence_readiness_state()$checks[["interpretation_current"]])
session$setInputs(confirm_interpretation = 1)
expect_true(evidence_readiness_state()$checks[["interpretation_current"]])
```

The complete server test setup is:

```r
test_that("Practical 1 selects three runs and invalidates stale interpretation", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)

  shiny::testServer(env$make_practical1_server(), {
    session$setInputs(run_baseline = 1)
    selected_stage("environmental_stochasticity")
    session$setInputs(run_stage = 1)
    selected_stage("intervention")
    session$setInputs(run_stage = 2)
    session$setInputs(
      interpretation_note = paste(
        "Risk increased under shared bad years; intervention improved final abundance,",
        "while uncertainty remained."
      )
    )

    expect_equal(length(selected_evidence_ids()), 3L)
    expect_equal(
      vapply(selected_evidence_runs(), `[[`, character(1), "stage"),
      c("deterministic_baseline", "environmental_stochasticity", "intervention")
    )
    expect_true(evidence_readiness_state()$ready)

    selected_stage("catastrophe")
    session$setInputs(run_stage = 3)
    expect_equal(selected_risk_run_id(), 4L)
    expect_false(evidence_readiness_state()$checks[["interpretation_current"]])
    expect_true(evidence_readiness_state()$checks[["interpretation"]])
    session$setInputs(confirm_interpretation = 1)
    expect_true(evidence_readiness_state()$checks[["interpretation_current"]])
  })
})
```

Also assert static presence of `Session history`, `Selected evidence`, `Review required`, pinned baseline copy, and category-specific risk/action selection controls.

- [ ] **Step 2: Run focused tests and verify evidence-state failures**

Run the focused Practical 1 command.

Expected: new tests fail because session history and selection still use the same all-runs rendering.

- [ ] **Step 3: Add category-specific selected-ID state and smart defaults**

Inside the server factory add:

```r
selected_risk_run_id <- reactiveVal(NA_integer_)
selected_action_run_id <- reactiveVal(NA_integer_)
interpretation_signature <- reactiveVal("")
```

Add helpers in `app.R` for user-facing choices:

```r
evidence_choice_label <- function(run) {
  paste0(
    "Run ", session_run_id(run), " - ", run$label,
    " (", run_changed_settings_label(run), ")"
  )
}

eligible_run_choices <- function(runs, eligible_stages) {
  eligible <- Filter(function(run) run$stage %in% eligible_stages, runs)
  stats::setNames(
    vapply(eligible, session_run_id, integer(1)),
    vapply(eligible, evidence_choice_label, character(1))
  )
}
```

Add the ordered history/selection renderer:

```r
evidence_stage_category <- function(stage) {
  if (identical(stage, "deterministic_baseline")) return("Baseline")
  if (stage %in% practical1_evidence_risk_stages) return("Risk mechanism")
  if (stage %in% practical1_evidence_action_stages) return("Intervention or vortex")
  "Other"
}

session_history_ui <- function(runs, selected_risk_id, selected_action_id) {
  history_rows <- if (length(runs)) {
    lapply(runs, function(run) {
      div(
        class = "session-run-row",
        span(class = "run-number", paste("Run", session_run_id(run))),
        strong(run$label),
        span(class = "run-category", evidence_stage_category(run$stage)),
        span(class = "run-settings", run_changed_settings_label(run))
      )
    })
  } else {
    p(class = "muted", "No successful session runs yet. Start baseline to create run 1.")
  }

  risk_choices <- eligible_run_choices(runs, practical1_evidence_risk_stages)
  action_choices <- eligible_run_choices(runs, practical1_evidence_action_stages)
  baseline_id <- first_baseline_run_id(runs)

  div(
    class = "session-history",
    div(class = "session-run-list", history_rows),
    div(
      class = "evidence-selection",
      h4("Selected evidence"),
      p(
        class = "pinned-baseline",
        if (is.na(baseline_id)) "Baseline missing - use Start baseline." else paste("Run", baseline_id, "- Baseline pinned")
      ),
      if (length(risk_choices)) {
        radioButtons(
          "selected_risk_run_id",
          "Choose one risk mechanism",
          choices = risk_choices,
          selected = as.character(selected_risk_id)
        )
      } else {
        p(class = "muted", "Run one risk-mechanism mission to make a selection.")
      },
      if (length(action_choices)) {
        radioButtons(
          "selected_action_run_id",
          "Choose one intervention or vortex run",
          choices = action_choices,
          selected = as.character(selected_action_id)
        )
      } else {
        p(class = "muted", "Run Rescue attempt or Vortex comparison to make a selection.")
      }
    )
  )
}
```

Whenever history changes, set each category to the latest suitable ID. This establishes the approved smart default; once the modelling history is stable, a student can substitute any eligible run in Compare:

```r
observeEvent(run_history(), {
  risk_ids <- unname(eligible_run_choices(run_history(), practical1_evidence_risk_stages))
  action_ids <- unname(eligible_run_choices(run_history(), practical1_evidence_action_stages))
  selected_risk_run_id(if (length(risk_ids)) tail(risk_ids, 1) else NA_integer_)
  selected_action_run_id(if (length(action_ids)) tail(action_ids, 1) else NA_integer_)
}, ignoreInit = FALSE)
```

Synchronise the rendered category controls back to reactive state with `observeEvent(input$selected_risk_run_id, ...)` and `observeEvent(input$selected_action_run_id, ...)`, converting values with `as.integer()`.

Define:

```r
selected_evidence_ids <- reactive({
  ids <- c(
    first_baseline_run_id(run_history()),
    selected_risk_run_id(),
    selected_action_run_id()
  )
  as.integer(ids[!is.na(ids)])
})

selected_evidence_runs <- reactive({
  select_session_runs(run_history(), selected_evidence_ids())
})
```

- [ ] **Step 4: Replace Compare with history, pinned baseline, risk/action choices, selected cards, and readiness**

Keep one full-history table/list in the left Compare column with class `compare-history-panel`. Each row must show run ID, mission label, category, and `run_changed_settings_label(run)`. Render baseline as `Pinned in selected evidence`; render risk and action controls as separate `radioButtons()` using `eligible_run_choices()`. Give the right selected-evidence column class `compare-evidence-panel` so the two sibling regions can be checked for overlap.

Wire that renderer with:

```r
output$session_history <- renderUI({
  session_history_ui(
    run_history(),
    selected_risk_run_id(),
    selected_action_run_id()
  )
})
```

Place `uiOutput("session_history")` under the `Session history` heading.

In the right column render:

- `Selected evidence` cards from `selected_evidence_runs()` only;
- comparison table from `rPVA::compare_teaching_runs(selected_evidence_runs(), include_deltas = TRUE)` only;
- a named readiness checklist from `evidence_readiness_state()$checks` and `$messages`;
- the existing interpretation text area;
- an `actionButton("confirm_interpretation", "Use this interpretation")`; and
- `Review required` whenever interpretation is nonblank but its signature differs from `evidence_selection_signature(selected_evidence_ids())`.

Update the run-card kicker so duplicate attempts retain their session identity:

```r
span(class = "run-card-kicker", paste("Run", session_run_id(runs[[i]])))
```

Define readiness exactly once:

```r
evidence_readiness_state <- reactive({
  evidence_readiness(
    run_history(),
    selected_evidence_ids(),
    input$interpretation_note,
    interpretation_signature(),
    baseline_started()
  )
})
```

Set the interpretation signature on student editing and explicit reconfirmation:

```r
observeEvent(input$interpretation_note, {
  if (nzchar(trimws(input$interpretation_note))) {
    interpretation_signature(evidence_selection_signature(selected_evidence_ids()))
  }
}, ignoreInit = TRUE)

observeEvent(input$confirm_interpretation, {
  req(nzchar(trimws(input$interpretation_note)))
  interpretation_signature(evidence_selection_signature(selected_evidence_ids()))
})
```

Selection changes preserve the text and therefore make the old signature stale. Do not clear the text in either selection observer.

- [ ] **Step 5: Run focused tests and inspect duplicate-attempt labels**

Run the focused file. Then launch locally and create two environmental runs with different controls.

Expected: both runs appear with different run IDs/settings, either can be selected, selected cards/table contain exactly three runs, and changing selection shows `Review required` without deleting text.

- [ ] **Step 6: Commit the history/evidence split**

```bash
git add inst/shiny/practical1/app.R tests/testthat/test-13_practical1_shiny.R
git commit -m "Separate Practical 1 history and evidence"
```

---

### Task 6: Gate Downloads And Complete The Transfer Checklist

**Files:**
- Modify: `inst/shiny/practical1/app.R:820-890,893-1130`
- Modify: `tests/testthat/test-13_practical1_shiny.R`

**Interfaces:**
- Consumes: `evidence_readiness_state()`, `selected_evidence_runs()`, and `selected_evidence_ids()`.
- Produces: selected-only `evidence_export()`, conditional `evidence_downloads`, `download_requested$comparison`, `download_requested$notes`, and `transfer_checklist`.

- [ ] **Step 1: Add failing selected-export and request-state tests**

Add server/static tests asserting:

```r
expect_true(grepl("session_run_count = length(run_history())", app_text, fixed = TRUE))
expect_true(grepl("selected_evidence_runs()", app_text, fixed = TRUE))
expect_true(grepl("download_requested <- reactiveValues(comparison = FALSE, notes = FALSE)", app_text, fixed = TRUE))
expect_true(grepl('uiOutput("evidence_downloads")', app_text, fixed = TRUE))
expect_true(grepl("Download requested", app_text, fixed = TRUE))
expect_false(grepl("Evidence saved", app_text, fixed = TRUE))
```

In the valid three-run `testServer()` flow, assert `nrow(evidence_export()$comparison) == 3L`, `length(run_history()) > 3L` after a duplicate attempt, and the notes include `Selected evidence: 3 runs from 4 successful session runs`.

Add this complete reset-state test after the valid-flow test:

```r
test_that("confirmed Practical 1 reset clears all in-memory student state", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  old <- setwd(app_dir)
  on.exit(setwd(old), add = TRUE)
  env <- new.env(parent = globalenv())
  sys.source("app.R", envir = env)

  shiny::testServer(env$make_practical1_server(), {
    session$setInputs(run_baseline = 1)
    selected_stage("environmental_stochasticity")
    session$setInputs(run_stage = 1)
    selected_stage("intervention")
    session$setInputs(run_stage = 2)
    session$setInputs(interpretation_note = "Risk changed; intervention improved abundance; uncertainty remained.")
    download_requested$comparison <- TRUE
    download_requested$notes <- TRUE

    session$setInputs(confirm_clear_runs = 1)

    expect_length(run_history(), 0L)
    expect_false(baseline_started())
    expect_equal(next_run_id(), 1L)
    expect_true(is.na(selected_risk_run_id()))
    expect_true(is.na(selected_action_run_id()))
    expect_identical(interpretation_signature(), "")
    expect_false(download_requested$comparison)
    expect_false(download_requested$notes)
    expect_true(is.na(last_completed_run_id()))
  })
})
```

- [ ] **Step 2: Run focused tests and verify the all-history export fails**

Run the focused Practical 1 command.

Expected: selected-row and request-state assertions fail against the current unconditional handlers.

- [ ] **Step 3: Build only the selected export and render gated controls**

Replace `evidence_export` with:

```r
evidence_export <- reactive({
  req(evidence_readiness_state()$ready)
  rPVA:::build_teaching_evidence_export(
    selected_evidence_runs(),
    interpretation = input$interpretation_note,
    session_run_count = length(run_history())
  )
})
```

Add:

```r
download_requested <- reactiveValues(comparison = FALSE, notes = FALSE)
```

Replace unconditional buttons with `uiOutput("evidence_downloads")`. Render either two disabled native buttons with `aria-disabled="true"`, or the real `downloadButton()` controls when `evidence_readiness_state()$ready` is true. The disabled state must sit beside the readiness checklist, not replace it.

- [ ] **Step 4: Mark requests only after each handler writes its artifact**

Use the existing filenames. At the end of the CSV handler add:

```r
download_requested$comparison <- TRUE
```

At the end of the Markdown handler add:

```r
download_requested$notes <- TRUE
```

Render state as `Comparison CSV: Download requested` and `Evidence notes: Download requested`; otherwise render `Not requested yet`.

- [ ] **Step 5: Add Transfer completion state and finish reset clearing**

Add `uiOutput("transfer_checklist")` above the Practical 2 bridge. Render two independently labelled items from the reactive values and a concise next action when either is false.

Extend `confirm_clear_runs` with:

```r
selected_risk_run_id(NA_integer_)
selected_action_run_id(NA_integer_)
interpretation_signature("")
download_requested$comparison <- FALSE
download_requested$notes <- FALSE
```

- [ ] **Step 6: Run API, Practical 1, and full test suites**

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter = "summary")'
```

Expected: all tests pass; scientific-output assertions remain unchanged.

- [ ] **Step 7: Commit the evidence gate**

```bash
git add inst/shiny/practical1/app.R tests/testthat/test-13_practical1_shiny.R
git commit -m "Gate Practical 1 evidence downloads"
```

---

### Task 7: Polish Laptop Layout, Accessibility, And Teaching Copy

**Files:**
- Modify: `inst/shiny/practical1/www/styles.css`
- Modify: `inst/shiny/practical1/app.R`
- Modify: `tests/testthat/test-13_practical1_shiny.R`
- Modify: `inst/shiny/practical1/README.md`
- Modify: `docs/teaching/shiny/practical-1-mission-tutorial.md`
- Modify: `docs/teaching/woodhen/practical-1-student-launch-page.md`
- Modify: `docs/teaching/woodhen/practical-1-mission-worksheet.md`
- Modify: `docs/teaching/woodhen/practical-1-day-of-class-pack.md`
- Modify: `docs/teaching/woodhen/practical-1-instructor-beat-sheet.md`
- Modify: `docs/teaching/woodhen/practical-1-moodle-ready-bundle/moodle-section-text.md`

**Interfaces:**
- Consumes: all final UI classes and copy from Tasks 3-6.
- Produces: stable two-column laptop layout, grouped mission hierarchy, visible keyboard focus, readable readiness states, updated student/instructor guidance, and preserved contextual tools.

- [ ] **Step 1: Add failing CSS and copy-contract assertions**

Assert exact selectors for `.session-notice`, `.mission-group`, `.mission-group-title`, `.mission-step-status`, `.mission-complete`, `.session-history`, `.evidence-selection`, `.readiness-checklist`, `.is-ready`, `.is-missing`, `.evidence-downloads`, `.transfer-checklist`, and `:focus-visible`. Assert the 780px media rule still stacks layouts.

Assert all existing contextual action IDs remain in `app.R`, and assert the six teaching documents contain `Core`, `Explore Further`, `temporary`, `comparison CSV`, and `evidence notes` where student-facing.

Use one test with these exact vectors:

```r
test_that("Practical 1 final polish retains help and responsive state selectors", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  app_text <- paste(readLines(file.path(app_dir, "app.R"), warn = FALSE), collapse = "\n")
  style_text <- paste(readLines(file.path(app_dir, "www", "styles.css"), warn = FALSE), collapse = "\n")
  action_ids <- c(
    "open_pva_deep_dive",
    "open_mission_deep_dive",
    "open_evidence_deep_dive",
    "show_intro",
    "open_parameter_help",
    "open_output_help",
    "open_diagnostic_help",
    "open_plot_help",
    "show_advanced_controls",
    "download_trajectory_plot",
    "download_summary_plot",
    "download_extinction_plot"
  )
  selectors <- c(
    ".session-notice",
    ".mission-group",
    ".mission-group-title",
    ".mission-step-status",
    ".mission-complete",
    ".session-history",
    ".evidence-selection",
    ".readiness-checklist",
    ".is-ready",
    ".is-missing",
    ".evidence-downloads",
    ".transfer-checklist",
    ":focus-visible"
  )

  expect_true(all(vapply(action_ids, grepl, logical(1), x = app_text, fixed = TRUE)))
  expect_true(all(vapply(selectors, grepl, logical(1), x = style_text, fixed = TRUE)))
  expect_match(style_text, "@media \\(max-width: 780px\\)")
  expect_match(style_text, "grid-template-columns: minmax\\(0,")
})
```

- [ ] **Step 2: Run focused tests and verify new selectors/copy are absent**

Run the focused Practical 1 test file.

Expected: CSS/copy checks fail while retained-affordance checks remain green.

- [ ] **Step 3: Add restrained, stable CSS for the approved hierarchy**

Add rules with these exact layout constraints:

```css
.session-notice {
  display: flex;
  align-items: flex-start;
  gap: 0.6rem;
  margin: 0 0 1rem;
  padding: 0.75rem 0.9rem;
  border-left: 4px solid #2f6f73;
  background: #edf6f5;
  color: #18383a;
}

.mission-group + .mission-group {
  margin-top: 0.85rem;
  padding-top: 0.85rem;
  border-top: 1px solid #c9d5d2;
}

.mission-group-title {
  display: block;
  margin-bottom: 0.45rem;
  font-size: 0.82rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0;
}

.mission-step {
  display: grid;
  grid-template-columns: 2rem minmax(0, 1fr) auto;
  align-items: center;
  min-height: 2.75rem;
  width: 100%;
  gap: 0.55rem;
}

.mission-step-status {
  font-size: 0.78rem;
  font-weight: 700;
}

.session-history,
.evidence-selection,
.readiness-checklist,
.transfer-checklist {
  display: grid;
  gap: 0.65rem;
}

.readiness-checklist .is-ready::before {
  content: "\2713";
  margin-right: 0.45rem;
  font-weight: 700;
}

.readiness-checklist .is-missing::before {
  content: "\25CB";
  margin-right: 0.45rem;
  font-weight: 700;
}

.evidence-downloads {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 0.65rem;
}

a:focus-visible,
button:focus-visible,
input:focus-visible,
textarea:focus-visible,
.btn:focus-visible {
  outline: 3px solid #0b6e75;
  outline-offset: 2px;
}
```

Refine the existing `.lab-grid` and `.compare-grid` tracks with `minmax(0, ...)`, ensure dynamic content cannot force horizontal page overflow, and stack `.lab-grid`, `.compare-grid`, and `.evidence-downloads` at the existing narrow breakpoint. Use text plus status symbols, never colour alone.

- [ ] **Step 4: Align all Week 1 teaching prose with the final flow**

In each listed document, state the same operational sequence:

1. one-hour PVA teaching and GUI introduction;
2. two-hour guided self-paced app work;
3. five Core model missions in the approved order;
4. Compare as the Core completion destination;
5. optional Explore Further genetics, catastrophe, vortex, advanced controls, alternative comparisons, and plot downloads;
6. exactly baseline plus one risk plus one intervention/vortex in the evidence pack;
7. both CSV and Markdown requested before closing; and
8. refresh/tab close/session expiry loses in-app state.

Do not add Practical 2 case-study depth or assessment claims to Week 1 material.

Use this exact student-facing route block in the launch page, mission worksheet, mission tutorial, and Moodle section text, adjusting only the Markdown heading level to fit the file:

```markdown
## Your route through Practical 1

Start with the five **Core** model missions: Baseline compass, Island ceiling,
Individual chance, Shared bad years, and Rescue attempt. Then go to **Compare**
and build a three-run evidence set containing baseline, one risk mechanism, and
one intervention or vortex run.

When the Core route is complete, **Explore Further** remains available for
genetic pressure, catastrophes, the extinction vortex, advanced controls,
alternative comparisons, and optional plot downloads.

This browser session is temporary. Before closing the tab, request both your
comparison CSV and your evidence-notes Markdown file. Refreshing, closing the
tab, or allowing the session to expire clears the in-app run history,
selection, progress, and interpretation.
```

Use this exact timing statement in the day-of-class pack and instructor beat sheet:

```markdown
The three-hour class uses approximately one hour for PVA teaching and a guided
GUI introduction, followed by approximately two hours of self-paced Practical
1 work while the instructor and demonstrators circulate.
```

- [ ] **Step 5: Run focused tests and scan copy consistency**

```bash
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
rg -n "Core|Explore Further|temporary|comparison CSV|evidence notes" \
  inst/shiny/practical1/README.md \
  docs/teaching/shiny/practical-1-mission-tutorial.md \
  docs/teaching/woodhen/practical-1-student-launch-page.md \
  docs/teaching/woodhen/practical-1-mission-worksheet.md \
  docs/teaching/woodhen/practical-1-day-of-class-pack.md \
  docs/teaching/woodhen/practical-1-instructor-beat-sheet.md \
  docs/teaching/woodhen/practical-1-moodle-ready-bundle/moodle-section-text.md
```

Expected: tests pass and every document reports the relevant final-flow language without contradictory old mission numbering.

- [ ] **Step 6: Commit UI polish and aligned teaching guidance**

```bash
git add inst/shiny/practical1/app.R inst/shiny/practical1/www/styles.css \
  tests/testthat/test-13_practical1_shiny.R inst/shiny/practical1/README.md \
  docs/teaching/shiny/practical-1-mission-tutorial.md \
  docs/teaching/woodhen/practical-1-student-launch-page.md \
  docs/teaching/woodhen/practical-1-mission-worksheet.md \
  docs/teaching/woodhen/practical-1-day-of-class-pack.md \
  docs/teaching/woodhen/practical-1-instructor-beat-sheet.md \
  docs/teaching/woodhen/practical-1-moodle-ready-bundle/moodle-section-text.md
git commit -m "Polish Practical 1 classroom guidance"
```

---

### Task 8: Add Repeatable Local Browser Acceptance

**Files:**
- Create: `scripts/practical1_browser_acceptance.js`
- Modify: `tests/testthat/test-13_practical1_shiny.R`

**Interfaces:**
- Consumes: a running Practical 1 URL from `PRACTICAL1_URL` and output directory from `PRACTICAL1_EVIDENCE_DIR`.
- Produces: screenshots, downloaded CSV/Markdown/PNG files, `browser-result.json`, and a nonzero process exit on any workflow, console, page, overlap, or export failure.

- [ ] **Step 1: Add a failing source-contract test for the browser acceptance script**

Assert the script exists and contains the three viewports, both routes, all contextual action labels, CSV/Markdown download waits, console/page error capture, and a three-row CSV assertion.

Add:

```r
test_that("Practical 1 browser acceptance covers Core extension exports and viewports", {
  app_dir <- rPVA:::practical1_shiny_app_dir()
  repo_root <- normalizePath(file.path(app_dir, "..", "..", ".."), mustWork = TRUE)
  script_path <- file.path(repo_root, "scripts", "practical1_browser_acceptance.js")
  expect_true(file.exists(script_path))
  script <- paste(readLines(script_path, warn = FALSE), collapse = "\n")

  required_text <- c(
    "Core 2: Island ceiling",
    "Core 5: Rescue attempt",
    "Explore: Small-population pressure",
    "Explore: Rare bad years",
    "Explore: Vortex comparison",
    "Explore PVA",
    "Explore mission",
    "Explore evidence",
    "Control help",
    "Read outputs",
    "Read diagnostics",
    "Read plots",
    "Comparison CSV",
    "Evidence notes",
    "selected CSV has header plus three rows",
    "consoleErrors",
    "consoleWarnings",
    "pageErrors",
    "1366, height: 768",
    "width: 1440, height: 900",
    "width: 390, height: 844"
  )
  expect_true(all(vapply(required_text, grepl, logical(1), x = script, fixed = TRUE)))
})
```

- [ ] **Step 2: Run the focused file and verify it fails because the script is absent**

Run the focused Practical 1 test command.

Expected: only the new script contract fails.

- [ ] **Step 3: Create the browser runner with deterministic artifacts**

Create a CommonJS script that imports `chromium` from `@playwright/test`, creates the evidence directory, and performs these exact workflows:

```javascript
const fs = require("node:fs");
const path = require("node:path");
const { chromium } = require("@playwright/test");

const baseURL = process.env.PRACTICAL1_URL || "http://127.0.0.1:3921";
const evidenceDir = process.env.PRACTICAL1_EVIDENCE_DIR || "/tmp/rpva-practical1-final-polish";
fs.mkdirSync(evidenceDir, { recursive: true });

const result = {
  baseURL,
  startedAt: new Date().toISOString(),
  consoleErrors: [],
  consoleWarnings: [],
  pageErrors: [],
  checks: []
};

function record(name, passed, detail = "") {
  result.checks.push({ name, passed, detail });
  if (!passed) throw new Error(`${name}: ${detail}`);
}

function parseCsvLine(line) {
  const values = [];
  let value = "";
  let quoted = false;
  for (let index = 0; index < line.length; index += 1) {
    const character = line[index];
    if (character === '"' && quoted && line[index + 1] === '"') {
      value += '"';
      index += 1;
    } else if (character === '"') {
      quoted = !quoted;
    } else if (character === "," && !quoted) {
      values.push(value);
      value = "";
    } else {
      value += character;
    }
  }
  values.push(value);
  return values;
}

async function assertNoOverlap(page, selectors) {
  const overlaps = await page.evaluate((items) => {
    const boxes = items.map((selector) => {
      const element = document.querySelector(selector);
      if (!element) return { selector, missing: true };
      const rect = element.getBoundingClientRect();
      return { selector, left: rect.left, right: rect.right, top: rect.top, bottom: rect.bottom };
    });
    return boxes.filter((box, index) => boxes.slice(index + 1).some((other) =>
      !box.missing && !other.missing && box.left < other.right && box.right > other.left &&
      box.top < other.bottom && box.bottom > other.top
    ));
  }, selectors);
  record(`no overlap: ${selectors.join(", ")}`, overlaps.length === 0, JSON.stringify(overlaps));
}

async function runMission(page, mission) {
  const cue = page.locator(".mission-complete");
  const before = await cue.count() ? await cue.getAttribute("data-run-id") : null;
  await page.locator(".mission-rail").getByText(mission, { exact: false }).click();
  await page.getByRole("button", { name: /Run stage|Run mission/ }).click();
  await page.waitForFunction((previous) => {
    const value = document.querySelector(".mission-complete")?.getAttribute("data-run-id");
    return value && value !== previous;
  }, before);
  await cue.filter({ hasText: mission }).waitFor();
}

let browser;

async function main() {
  browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ acceptDownloads: true, viewport: { width: 1366, height: 768 } });
  const page = await context.newPage();
  page.on("console", (message) => {
    if (message.type() === "error") result.consoleErrors.push(message.text());
    if (message.type() === "warning") result.consoleWarnings.push(message.text());
  });
  page.on("pageerror", (error) => result.pageErrors.push(error.message));

  await page.goto(baseURL, { waitUntil: "networkidle" });
  await page.getByText("This session is temporary.", { exact: false }).first().waitFor();
  const explorePva = page.getByRole("button", { name: "Explore PVA" });
  await explorePva.focus();
  record("context help receives keyboard focus", await explorePva.evaluate((element) => document.activeElement === element));
  record(
    "focused context help has a visible outline",
    await explorePva.evaluate((element) => getComputedStyle(element).outlineStyle !== "none")
  );
  await page.keyboard.press("Enter");
  await page.locator(".modal").waitFor();
  await page.keyboard.press("Escape");
  await page.locator(".modal").waitFor({ state: "hidden" });
  for (const label of ["Explore mission", "Explore evidence"]) {
    await page.getByRole("button", { name: label }).click();
    await page.getByRole("button", { name: "Close" }).click();
  }

  await page.getByRole("tab", { name: "Compare" }).click();
  await page.getByText("This session is temporary.", { exact: false }).waitFor();
  record("context help does not create runs", await page.locator(".session-run-row").count() === 0);
  record("CSV is gated before evidence is ready", await page.getByRole("link", { name: "Comparison CSV" }).count() === 0);
  record("notes are gated before evidence is ready", await page.getByRole("link", { name: "Evidence notes" }).count() === 0);
  await page.getByRole("tab", { name: "Start" }).click();
  await page.getByRole("button", { name: "Start baseline" }).click();
  await page.getByText("Core 1: Baseline compass", { exact: false }).waitFor();

  for (const mission of [
    "Core 2: Island ceiling",
    "Core 3: Individual chance",
    "Core 4: Shared bad years",
    "Core 5: Rescue attempt"
  ]) {
    await runMission(page, mission);
  }

  for (const label of ["Introduction", "Control help", "Read outputs", "Read diagnostics", "Read plots"]) {
    await page.getByRole("button", { name: label }).click();
    if (label === "Introduction") {
      await page.getByRole("tab", { name: "Concept Lab" }).click();
    } else {
      await page.getByRole("button", { name: "Close" }).click();
    }
  }

  await page.getByRole("tab", { name: "Compare" }).click();
  record("Core route keeps five successful session runs", await page.locator(".session-run-row").count() === 5);
  record("selected evidence shows exactly three cards", await page.locator(".run-card").count() === 3);
  await page.getByLabel("One-sentence interpretation").fill(
    "Risk increased under shared bad years; intervention improved final abundance, while uncertainty remained."
  );
  await page.getByRole("button", { name: "Use this interpretation" }).click();

  const csvPromise = page.waitForEvent("download");
  await page.getByRole("link", { name: "Comparison CSV" }).click();
  const csv = await csvPromise;
  const csvPath = path.join(evidenceDir, await csv.suggestedFilename());
  await csv.saveAs(csvPath);

  const notesPromise = page.waitForEvent("download");
  await page.getByRole("link", { name: "Evidence notes" }).click();
  const notes = await notesPromise;
  const notesPath = path.join(evidenceDir, await notes.suggestedFilename());
  await notes.saveAs(notesPath);

  const csvLines = fs.readFileSync(csvPath, "utf8").trim().split(/\r?\n/);
  record("selected CSV has header plus three rows", csvLines.length === 4, `rows=${csvLines.length - 1}`);
  const headers = parseCsvLine(csvLines[0]);
  const rows = csvLines.slice(1).map(parseCsvLine);
  const requiredColumns = ["run_id", "stage", "label", "PE", "Nmed"];
  const requiredIndexes = requiredColumns.map((name) => headers.indexOf(name));
  record("selected CSV has required columns", requiredIndexes.every((index) => index >= 0), headers.join(","));
  record(
    "selected CSV required values are complete",
    rows.every((row) => requiredIndexes.every((index) => row[index] !== undefined && row[index] !== ""))
  );
  const notesText = fs.readFileSync(notesPath, "utf8");
  record("notes describe three selected runs", notesText.includes("Selected evidence: 3 runs from"));
  record("notes retain interpretation", notesText.includes("Risk increased under shared bad years"));
  const selectedStages = rows.map((row) => row[headers.indexOf("stage")]);
  record("notes and CSV name the same stages", selectedStages.every((stage) => notesText.includes(stage)));
  await page.getByText("Comparison CSV: Download requested", { exact: false }).waitFor();
  await page.getByText("Evidence notes: Download requested", { exact: false }).waitFor();
  await page.screenshot({ path: path.join(evidenceDir, "minimum-success-1366x768.png"), fullPage: true });
  await assertNoOverlap(page, [".compare-history-panel", ".compare-evidence-panel"]);

  await page.getByRole("tab", { name: "Transfer" }).click();
  await page.getByText("This session is temporary.", { exact: false }).waitFor();
  await page.getByText("Comparison CSV: Download requested", { exact: false }).waitFor();
  await page.getByText("Evidence notes: Download requested", { exact: false }).waitFor();
  await page.screenshot({ path: path.join(evidenceDir, "transfer-1366x768.png"), fullPage: true });

  await page.getByRole("tab", { name: "Concept Lab" }).click();
  await page.locator(".mission-rail").getByText("Explore: Small-population pressure", { exact: false }).click();
  await page.getByLabel("Show advanced risk controls").check();
  await runMission(page, "Explore: Small-population pressure");
  await runMission(page, "Explore: Rare bad years");
  await runMission(page, "Explore: Rare bad years");
  await runMission(page, "Explore: Vortex comparison");

  const plotPromise = page.waitForEvent("download");
  await page.getByRole("link", { name: "Risk PNG" }).click();
  const plot = await plotPromise;
  await plot.saveAs(path.join(evidenceDir, await plot.suggestedFilename()));

  await page.getByRole("tab", { name: "Compare" }).click();
  record("extension route keeps duplicate attempts", await page.locator(".session-run-row").count() === 9);
  const riskChoices = page.locator('input[name="selected_risk_run_id"]');
  await riskChoices.last().check();
  await page.getByText("Review required", { exact: false }).waitFor();
  await page.getByRole("button", { name: "Use this interpretation" }).click();
  await page.screenshot({ path: path.join(evidenceDir, "extension-1366x768.png"), fullPage: true });

  await page.setViewportSize({ width: 1440, height: 900 });
  await page.screenshot({ path: path.join(evidenceDir, "compare-1440x900.png"), fullPage: true });
  await page.setViewportSize({ width: 390, height: 844 });
  await page.getByRole("tab", { name: "Start" }).click();
  await page.screenshot({ path: path.join(evidenceDir, "start-390x844.png"), fullPage: true });

  await page.getByRole("tab", { name: "Compare" }).click();
  await page.getByRole("button", { name: "Reset comparison" }).click();
  await page.getByText("Run history, evidence selection, interpretation", { exact: false }).waitFor();
  await page.keyboard.press("Escape");
  await page.locator(".modal").waitFor({ state: "hidden" });

  record("no console errors", result.consoleErrors.length === 0, JSON.stringify(result.consoleErrors));
  record("no console warnings", result.consoleWarnings.length === 0, JSON.stringify(result.consoleWarnings));
  record("no page errors", result.pageErrors.length === 0, JSON.stringify(result.pageErrors));
  result.finishedAt = new Date().toISOString();
  fs.writeFileSync(path.join(evidenceDir, "browser-result.json"), JSON.stringify(result, null, 2));
  await browser.close();
}

main().catch(async (error) => {
  result.finishedAt = new Date().toISOString();
  result.failure = error.stack || error.message;
  fs.writeFileSync(path.join(evidenceDir, "browser-result.json"), JSON.stringify(result, null, 2));
  if (browser) await browser.close();
  process.exitCode = 1;
});
```

During implementation, use the exact final accessible role/name emitted by the app if Shiny renders a control as a link rather than a button. Keep each assertion semantically named; do not replace role locators with brittle coordinates.

- [ ] **Step 4: Launch the app and execute the browser runner**

Terminal 1:

```bash
Rscript -e 'source("bootstrap.R"); rPVA::run_practical1_shiny(host = "127.0.0.1", port = 3921, launch.browser = FALSE)' \
  > /tmp/rpva-practical1-final-polish-app.log 2>&1
```

Terminal 2:

```bash
rm -rf /tmp/rpva-practical1-final-polish
PRACTICAL1_URL='http://127.0.0.1:3921' \
PRACTICAL1_EVIDENCE_DIR='/tmp/rpva-practical1-final-polish' \
NODE_PATH="$(npm root -g)" \
node scripts/practical1_browser_acceptance.js
jq '.checks, .consoleErrors, .consoleWarnings, .pageErrors' \
  /tmp/rpva-practical1-final-polish/browser-result.json
```

Expected: exit `0`; every check is true; the three browser arrays are empty; CSV, Markdown, optional PNG, five screenshots, and JSON are non-empty.

- [ ] **Step 5: Inspect all screenshots at original resolution**

Use `view_image` on each PNG. Verify no overlap, clipped text, hidden controls, unexpected scroll traps, or status conveyed by colour alone at both laptop sizes. At narrow size, verify stacked controls remain usable.

- [ ] **Step 6: Commit the repeatable browser gate**

```bash
git add scripts/practical1_browser_acceptance.js tests/testthat/test-13_practical1_shiny.R
git commit -m "Automate Practical 1 browser acceptance"
```

---

### Task 9: Freeze And Independently Review The Local Release

**Files:**
- Review: all files changed in Tasks 1-8
- Modify: only files required by validated findings

**Interfaces:**
- Consumes: complete local implementation and browser evidence.
- Produces: clean, synchronized, reviewed source commit suitable for one immutable image build.

- [ ] **Step 1: Run the full local acceptance gate from a clean process**

```bash
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter = "summary")'
bash deploy/shinyproxy/practical1/validate-scaffold.sh
git diff --check
git status --short --branch
```

Expected: all tests and scaffold checks pass, no whitespace errors, no unexplained `renv` drift, and only intentional reviewed files are present.

Planning-time bootstrap reported `pak` as installed/used but not recorded in the lockfile. If that remains the only `renv::status()` difference, confirm with `rg -n "pak" DESCRIPTION NAMESPACE R bootstrap.R renv.lock` that it is bootstrap tooling rather than a package runtime dependency, record the classification, and do not change `renv.lock` merely to silence the local status message.

- [ ] **Step 2: Request independent review against the approved design**

Use `superpowers:requesting-code-review` with the design spec and Tasks 1-8 diff. The reviewer must prioritise:

- scientific/default/API regression;
- baseline preload accidentally counting as completion;
- invalid evidence categories or more/fewer than three export rows;
- stale interpretation bypass;
- download controls reachable before readiness;
- reset leaving hidden reactive state;
- contextual action loss;
- laptop overlap/accessibility failures; and
- any Practical 2 or deployment-scope change.

- [ ] **Step 3: Resolve validated findings with focused tests first**

For each accepted finding, add a failing test or browser assertion, reproduce it, make the smallest correction, and rerun the focused and full gates. Do not fold unrelated refactors into release fixes.

- [ ] **Step 4: Re-run browser acceptance after the final correction**

Use the Task 8 commands from a newly launched app process.

Expected: complete minimum and extension routes pass at all three viewports with empty console/page arrays and internally consistent exports.

- [ ] **Step 5: Commit review fixes and synchronize source**

```bash
git diff --name-only -z -- \
  R/teaching_api.R \
  inst/shiny/practical1 \
  scripts/practical1_browser_acceptance.js \
  tests/testthat/test-12_teaching_api.R \
  tests/testthat/test-13_practical1_shiny.R \
  docs/teaching/shiny/practical-1-mission-tutorial.md \
  docs/teaching/woodhen/practical-1-student-launch-page.md \
  docs/teaching/woodhen/practical-1-mission-worksheet.md \
  docs/teaching/woodhen/practical-1-day-of-class-pack.md \
  docs/teaching/woodhen/practical-1-instructor-beat-sheet.md \
  docs/teaching/woodhen/practical-1-moodle-ready-bundle/moodle-section-text.md \
  | xargs -0 -r git add
git commit -m "Finalize Practical 1 classroom release"
git status --short --branch
git push origin main
git fetch --prune origin
test "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)"
```

Expected: signed commit, clean tree, and local `main` exactly equals `origin/main`. Stop before image build if synchronization fails.

---

### Task 10: Build, Smoke, Push, And Pin One Immutable Image

**Files:**
- Read: `deploy/shinyproxy/practical1/Dockerfile.template`
- Read: `deploy/shinyproxy/teaching-app-human-playbook.md`
- Create locally during execution: `push-${TAG}.log`, `manifest-${TAG}.txt`

**Interfaces:**
- Consumes: clean synchronized source from Task 9 and Docker Desktop WSL integration.
- Produces: `SOURCE_SHA`, immutable `IMAGE`, registry `DIGEST`, local smoke result, and registry manifest evidence used unchanged by Tasks 11-12.

- [ ] **Step 1: Derive and print immutable release identity**

```bash
APP_ID='kpz308-rpva-practical'
SOURCE_SHA="$(git rev-parse HEAD)"
SHORT_SHA="$(git rev-parse --short=12 HEAD)"
BUILD_DATE="$(date +%Y%m%d)"
IMAGE_REPOSITORY='git.its.utas.edu.au/utas/kpz308-rpva-practical'
TAG="dev-${BUILD_DATE}-${SHORT_SHA}"
IMAGE="${IMAGE_REPOSITORY}:${TAG}"
test "${SOURCE_SHA}" = "$(git rev-parse origin/main)"
printf 'app=%s\nsource=%s\nimage=%s\n' "${APP_ID}" "${SOURCE_SHA}" "${IMAGE}"
```

Expected: the source equals synchronized `origin/main`; tag date is the build day and suffix is the first 12 characters of the exact source commit.

- [ ] **Step 2: Build for ITS hosts and run bounded container smoke**

```bash
docker info >/dev/null
docker build \
  --platform linux/amd64 \
  -f deploy/shinyproxy/practical1/Dockerfile.template \
  --build-arg RPVA_REF="${SOURCE_SHA}" \
  -t "${IMAGE}" \
  .
```

Run the bounded health/HTTP cleanup block from Phase 3 of `deploy/shinyproxy/teaching-app-human-playbook.md`, using `SMOKE_NAME="rpva-practical-smoke-${SHORT_SHA}"`.

Expected: image health is `healthy`, HTTP contains the Practical 1 marker, and the smoke container is removed.

- [ ] **Step 3: Run the full browser acceptance against the image**

Use loopback port `3922`, stopping if it is occupied:

```bash
if ss -ltn '( sport = :3922 )' | rg -q LISTEN; then
  printf 'Port 3922 is already in use.\n' >&2
  exit 1
fi
IMAGE_ACCEPTANCE_NAME="rpva-practical1-browser-${SHORT_SHA}"
cleanup_image_acceptance() {
  docker rm -f "${IMAGE_ACCEPTANCE_NAME}" >/dev/null 2>&1 || true
}
trap cleanup_image_acceptance EXIT
docker run -d --name "${IMAGE_ACCEPTANCE_NAME}" -p 127.0.0.1:3922:3838 "${IMAGE}"
for attempt in $(seq 1 60); do
  STATUS="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "${IMAGE_ACCEPTANCE_NAME}")"
  test "${STATUS}" = healthy && break
  test "${STATUS}" = unhealthy && docker logs "${IMAGE_ACCEPTANCE_NAME}" && exit 1
  sleep 2
done
test "${STATUS}" = healthy
rm -rf "/tmp/rpva-practical1-image-${SHORT_SHA}"
PRACTICAL1_URL='http://127.0.0.1:3922' \
PRACTICAL1_EVIDENCE_DIR="/tmp/rpva-practical1-image-${SHORT_SHA}" \
NODE_PATH="$(npm root -g)" \
node scripts/practical1_browser_acceptance.js
cleanup_image_acceptance
trap - EXIT
```

Expected: same route/export/viewport checks pass inside the deployment image, not only the source launcher.

- [ ] **Step 4: Authenticate, push, and capture the registry digest**

Use the safe `docker login ... --password-stdin` block from Phase 4 of the human playbook, then:

```bash
set -o pipefail
docker push "${IMAGE}" | tee "push-${TAG}.log"
docker buildx imagetools inspect "${IMAGE}" | tee "manifest-${TAG}.txt"
DIGEST="$(awk '/^Digest:/ {print $2; exit}' "manifest-${TAG}.txt")"
test -n "${DIGEST}"
docker image inspect "${IMAGE}" \
  --format 'id={{.Id}} revision={{index .Config.Labels "org.opencontainers.image.revision"}} repoDigests={{json .RepoDigests}}'
printf 'image=%s\ndigest=%s\nsource=%s\n' "${IMAGE}" "${DIGEST}" "${SOURCE_SHA}"
```

Expected: push completes, manifest digest is `sha256:` plus 64 hexadecimal characters, and OCI revision equals `SOURCE_SHA`.

- [ ] **Step 5: Record the release identity outside shell history dependence**

Write image, digest, source, local image ID, build time, test results, and image-browser evidence paths into the top of the deployment record created in Task 12. Do not record registry credentials.

---

### Task 11: Deploy And Accept The Exact Image On Dev On Saturday 18 July

**Files:**
- Create: `docs/ops/deployments/evidence/2026-07-18-kpz308-practical1-dev/README.md`
- Add: sanitized dev command output, config diff, browser artifacts, exports, JSON, and checksums under that directory.

**Interfaces:**
- Consumes: exact `IMAGE`, `DIGEST`, and `SOURCE_SHA` from Task 10.
- Produces: dev backup path and proof that Practical 1 passes while Practical 2 remains present, distinct, and Staff-only.

- [ ] **Step 1: Connect to the dev container host and verify authority**

Through RDS/DUO/PuTTY, connect to `ecology-r-dev1.its.utas.edu.au`, then:

```bash
sudo -iu sa-container
cd /srv/sa-container/ecology-teaching-shiny
printf 'user=%s\nhost=%s\npath=%s\n' "$(id -un)" "$(hostname -f)" "$PWD"
docker compose ps
curl -fsS http://127.0.0.1:9090/actuator/health
```

Expected: `sa-container`, dev hostname, exact deployment path, ShinyProxy up, health `UP`.

- [ ] **Step 2: Pull by immutable tag and reconcile digest/revision**

Set `IMAGE` to the Task 10 value on the remote host, pull it, and inspect repository digest and OCI revision. Stop if either differs from Task 10.

- [ ] **Step 3: Back up and change only Practical 1's image line**

Create a permission-preserving timestamped backup of `application.yml`. Replace only the `container-image` under app ID `kpz308-rpva-practical`. Print an exact diff and app inventory.

Expected invariants:

- `kpz308-rpva-practical` points to `IMAGE`;
- `kpz308-rpva-practical2` still points to its existing canary image;
- Practical 1 dev access remains Admin-only as currently configured;
- Practical 2 dev access remains unchanged;
- app IDs, network, memory, CPU, port, environment, and workspace paths are unchanged.

- [ ] **Step 4: Restart, wait for health, and inspect startup logs**

```bash
docker compose down
docker compose up -d
for attempt in $(seq 1 30); do
  if curl -fsS http://127.0.0.1:9090/actuator/health; then
    printf '\nhealth_attempt=%s\n' "${attempt}"
    break
  fi
  sleep 5
done
docker compose ps
docker logs --tail 160 shinyproxy 2>&1 | rg -i 'Started ShinyProxy|error|warn|denied|kpz308'
```

Expected: actuator `UP`, ShinyProxy starts, both app specs parse, and no unexplained startup error. Record the known IPv4-forwarding warning if present; actual browser/runtime success remains the decision gate.

- [ ] **Step 5: Complete full Staff browser acceptance on dev**

Open `https://ecology-r-dev1.its.utas.edu.au`, authenticate, and run the minimum-success plus extension workflows from Task 8. Confirm every contextual action, three-row selected CSV, matching Markdown interpretation/settings, both `Download requested` states, Transfer checklist, temporary notices, laptop layouts, and no browser errors. Keep Practical 1 and Practical 2 open concurrently and verify distinct healthy app containers and separate workspace roots.

- [ ] **Step 6: Sanitize and checksum dev evidence**

Store no passwords, cookies, SAML assertions, access tokens, or unnecessary student identifiers. Add `README.md`, command output, exact config diff, exports, screenshots, and browser result. Then:

```bash
find docs/ops/deployments/evidence/2026-07-18-kpz308-practical1-dev \
  -type f ! -name checksums.sha256 -print0 | sort -z | xargs -0 sha256sum \
  > docs/ops/deployments/evidence/2026-07-18-kpz308-practical1-dev/checksums.sha256
sha256sum -c docs/ops/deployments/evidence/2026-07-18-kpz308-practical1-dev/checksums.sha256
```

Expected: every checksum passes. Stop production promotion if any dev server, browser, export, digest, or neighbour-app check fails.

---

### Task 12: Promote The Same Digest To Production And Close Out On Sunday 19 July

**Files:**
- Create: `docs/ops/deployments/evidence/2026-07-19-kpz308-practical1-prod/README.md`
- Create: `docs/ops/deployments/2026-07-19-kpz308-practical1-final-polish.md`
- Add: sanitized production command output, config diff, browser artifacts, exports, tester note, and checksums.

**Interfaces:**
- Consumes: dev-accepted `IMAGE@DIGEST`, dev evidence, and rollback image/config.
- Produces: production acceptance, optional KPZ308 student confirmation, complete release report, and explicit Monday freeze/rollback instructions.

- [ ] **Step 1: Connect to production and establish the untouched baseline**

Through RDS/DUO/PuTTY, connect to `ecology-r1.its.utas.edu.au`, then run the identity/path/compose/health/app-inventory checks from Task 11.

Expected before mutation:

- Practical 1 access groups are `UNI-Ecology-Teaching-Shiny-Staff` and `KPZ308`;
- Practical 2 access is `UNI-Ecology-Teaching-Shiny-Staff` only;
- both apps have distinct workspace roots; and
- current Practical 1 rollback tag is recorded.

- [ ] **Step 2: Pull and prove the production candidate is the dev-accepted digest**

Pull the exact Task 10 `IMAGE`, inspect `RepoDigests` and OCI revision, and compare with the dev evidence. Stop if tag, source revision, or registry digest differs.

- [ ] **Step 3: Back up and change only the Practical 1 image line**

Create a permission-preserving backup. Replace only Practical 1's image, print the exact diff, validate file owner/mode and both app specs, then restart and wait for actuator `UP` using Task 11's bounded loop.

Expected: access groups, app IDs, Practical 2 image/access, resources, ports, environments, and both workspace paths are unchanged.

- [ ] **Step 4: Complete production Staff acceptance and neighbour regression**

At `https://ecology-r1.its.utas.edu.au`, repeat the complete minimum-success route, both required downloads, Transfer checklist, extension selection substitution, optional plot, and viewport checks. Open Practical 2 concurrently and verify it remains Staff-only and healthy. On the server, capture both app-container images, health, resource snapshot, proxy activation events, and separate workspace roots.

- [ ] **Step 5: Obtain one KPZ308 student-path check if an authorized tester is available**

Ask one enrolled KPZ308 user to confirm Practical 1 appears, launches, runs baseline plus one changed mission, and requests a small CSV. Ask them to confirm Practical 2 does not appear. Record tester name/role, timestamp, and concise observed result only with consent. Staff acceptance remains mandatory; absence of an available student tester is recorded honestly rather than inferred.

- [ ] **Step 6: Validate production exports and evidence checksums**

Check CSV has one header plus exactly three data rows, no missing required comparison values, and the same selected stages/settings described by the Markdown. Check notes contain the current interpretation and selected-from-session count. Generate and verify checksums using the Task 11 pattern with the production directory.

- [ ] **Step 7: Write the final deployment report with observed facts**

Create `docs/ops/deployments/2026-07-19-kpz308-practical1-final-polish.md` with these sections, populated from recorded evidence:

1. Scope and approved design.
2. Source commit and test summary.
3. Immutable image tag, OCI revision, and registry digest.
4. Local image/browser acceptance.
5. Dev backup, configuration diff, health, browser, exports, and Practical 2 regression.
6. Production backup, configuration diff, health, browser, exports, and Practical 2 regression.
7. KPZ308 student-path result or explicit unavailability.
8. Remaining caveats: in-memory session only and known non-blocking IPv4-forwarding warning if observed.
9. Monday freeze statement.
10. Rollback commands and both pre-change backup names.

Rollback must restore the production backup or set Practical 1 back to `git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-20260713-02b09aeed4f0`, restart ShinyProxy, wait for health `UP`, and repeat Staff browser acceptance. It must not alter Practical 2.

- [ ] **Step 8: Commit and push only sanitized durable evidence**

```bash
git add docs/ops/deployments/2026-07-19-kpz308-practical1-final-polish.md \
  docs/ops/deployments/evidence/2026-07-18-kpz308-practical1-dev \
  docs/ops/deployments/evidence/2026-07-19-kpz308-practical1-prod
git commit -m "Record Practical 1 classroom deployment"
git push origin main
git status --short --branch
```

Expected: signed evidence commit, successful push, clean synchronized `main`, and no secret/identity leakage beyond consented tester attribution.

- [ ] **Step 9: Freeze normal deployment changes for Monday 20 July**

Keep the production backup and rollback tag immediately available. Make no change before or during class unless a reproducible student-facing incident is verified, the correction is tested against the acceptance workflow, and rollback remains faster than repair.

---

## Final Acceptance Matrix

| Requirement | Primary proof |
|---|---|
| Five Core model missions in approved order | helper tests, grouped rail tests, browser minimum route |
| Explore Further always available | helper/static tests, extension browser route |
| Baseline requires explicit Start action | `testServer()` state test |
| Successful-only progress and unique run IDs | helper and failed-run tests |
| Every contextual learning action retained | static ID checks plus browser modal workflow |
| Full session history retained | duplicate-attempt server/browser checks |
| Exactly baseline + risk + action/vortex exported | helper tests, selected-only server test, three-row CSV inspection |
| Interpretation remains but becomes stale after selection change | readiness helper and browser substitution checks |
| Downloads unavailable until ready | server/static test and browser minimum route |
| Download requests tracked accurately | handler state and Transfer browser checks |
| Session loss communicated | copy tests and Start/Compare/Transfer browser checks |
| No science/default/API regression | API tests and full suite |
| Laptop layout and accessibility | screenshots, overlap checks, keyboard/focus inspection |
| One immutable image on dev and prod | registry digest, OCI revision, remote image inspections |
| Practical 2 unchanged and Staff-only | dev/prod inventories and concurrent browser regression |
| Rollback ready | recorded old image, backup names, and exact recovery procedure |
