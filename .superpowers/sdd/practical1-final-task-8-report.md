# Practical 1 Task 8 Browser Acceptance Report

Date: 2026-07-15
Base revision: `9da4ff11003e2a505ede722770629037801dfc2d`
Implementation revision: `5653da1258965582977e1c3a890f31936d0e5fc4`

## Completed action and changed files

Hardened Task 8, “Add Repeatable Local Browser Acceptance”, and committed the
implementation as:

```text
5653da1258965582977e1c3a890f31936d0e5fc4
Harden Practical 1 browser acceptance
```

Changed implementation files:

- `scripts/practical1_browser_acceptance.js`
- `tests/testthat/test-13_practical1_shiny.R`

The app, CSS, raw data, Practical 2 files, and renv lockfile were not changed.

## Implementation notes

- Added a CommonJS Playwright Chromium runner using `PRACTICAL1_URL` and
  `PRACTICAL1_EVIDENCE_DIR`, with deterministic route coverage, download
  validation, screenshots, overlap checks, browser error capture, and a
  nonzero exit on any failed assertion.
- The runner waits for the dedicated `#stage_text .mission-label` after each
  mission selection. This avoids matching a stale “Next Core action” sentence
  before the selected stage has changed.
- Added `assertCompareTableScrollRegion()`. At both laptop viewports it checks
  `.compare-table` has computed `overflow-x: auto`, a positive scroll range,
  programmatic movement to the maximum scroll position, and a visible table
  far edge. The check restores the original scroll position.
- The runner now owns evidence cleanup: it rejects empty, root, and checkout
  paths, removes the prior evidence directory recursively, and recreates it
  before any artifact is written.
- `assertNoOverlap()` now records and fails on missing required selectors before
  attempting any overlap calculation.
- The runner parses both tab-separated export tables in the Markdown notes and
  compares selected count, ordered run IDs, stages, labels, and all shared
  comparison fields against the CSV. It also checks the settings/provenance
  run-ID set, at least one settings row per selected run, and exactly one
  deterministic baseline, allowed risk stage, and allowed intervention/vortex
  stage.
- Route coverage now compares the expected label set with labels actually
  visited during the browser flow, including mission, contextual, and download
  actions.
- The Browser plugin was absent, so the approved Playwright fallback was used:
  `@playwright/test` Chromium via `NODE_PATH="$(npm root -g)"`.

## Exact acceptance flow

The live run used only this server:

```text
http://127.0.0.1:3921
```

The server was started from this checkout with `launch.browser = FALSE`, and
its PID was stopped by an exit trap after the run. The unrelated listener on
port 39314 remained unchanged.

The browser flow covered:

1. Practical 1 identity/content, framework-overlay absence, keyboard focus and
   visible focus outline for contextual help, and modal open/close behavior.
2. Compare gating before evidence readiness: no session runs and no CSV or
   notes download controls.
3. Start baseline, all five Core missions, contextual help routes, three-run
   evidence selection, interpretation capture, CSV and Markdown downloads,
   CSV structure/value checks, and notes consistency checks.
4. Transfer download-request status, Explore Further missions including a
   duplicate rare-bad-years attempt, and the Risk PNG download.
5. Laptop screenshots/overlap checks plus the two compare-table scroll-region
   checks; narrow Start screenshot and reset-cancellation preservation.
6. Final empty console-error, console-warning, and page-error assertions.

Viewports were exactly:

- 1366 × 768
- 1440 × 900
- 390 × 844

## Fresh evidence

Fresh evidence directory:

`/tmp/rpva-practical1-task-8-hardened-20260715`

`browser-result.json` reported:

```text
passed: true
checks: 53 total, 53 true
consoleErrors: 0
consoleWarnings: 0
pageErrors: 0
recorded artifacts: 8, all non-empty
```

The runner removed a pre-existing stale sentinel from the evidence directory
before creating artifacts.

The compare-table checks reported:

- 1366 × 768: `overflowX=auto`, `scrollWidth=1693`, `clientWidth=450`,
  `maxScrollLeft=1243`, far edge reached and visible.
- 1440 × 900: `overflowX=auto`, `scrollWidth=1678`, `clientWidth=450`,
  `maxScrollLeft=1228`, far edge reached and visible.

Non-empty artifacts were:

- `practical1-comparison-20260715.csv` — 547 bytes
- `practical1-evidence-notes-20260715.md` — 3330 bytes
- `practical1-risk-extinction-vortex-20260715.png` — 56390 bytes
- `minimum-success-1366x768.png` — 275842 bytes
- `transfer-1366x768.png` — 86525 bytes
- `extension-1366x768.png` — 374467 bytes
- `compare-1440x900.png` — 374854 bytes
- `start-390x844.png` — 444823 bytes
- `browser-result.json` — 11951 bytes

The parent inspected all five screenshots at original resolution: no overlap or
clipped controls were found; the intentionally wide comparison table remains
inside its `overflow-x: auto` container and is now verified as scrollable to
its far edge.

## Verification performed

- TDD source-contract red phase: failed on the missing cleanup, selector,
  export-consistency, category, and visited-route contracts.
- Focused `tests/testthat/test-13_practical1_shiny.R`: passed after the
  hardening changes.
- `node --check scripts/practical1_browser_acceptance.js`: passed.
- Fresh live browser acceptance on 127.0.0.1:3921: passed 53/53 checks with
  empty browser arrays and non-empty artifacts.
- `jq` summary and strict JSON/artifact assertions: passed.
- Stale-evidence sentinel check: passed; the runner-owned cleanup removed it.
- `git diff --check`: passed before both commits.
- The server PID was stopped and port 3921 was no longer listening; port 39314
  remained owned by the pre-existing unrelated process.
- The focused R command emitted the existing renv out-of-sync warning for
  bootstrap-only `pak`; run-generated whitespace in `renv/activate.R` was
  removed and no renv/worktree change remained outside the owned files.

## Limits

- This is a local headless Chromium acceptance run, not a production
  ShinyProxy, reverse-proxy, authentication, multi-user, or device/browser
  matrix test.
- The full repository test suite was not rerun for this Task 8 change; the
  focused Practical 1 suite and requested browser gate were run.
- Visual inspection confirms the captured states only. It does not prove
  every possible user-generated table width, network condition, or future
  content variation.
