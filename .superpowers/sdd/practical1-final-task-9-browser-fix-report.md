# Practical 1 Final Task 9 Browser Fix Report

Date: 2026-07-15
Base revision: `31f0f5e`
Implementation commit: `4e12455` (`Fix Practical 1 release browser gate`)

## RED

Added focused acceptance contracts and an executable Node cleanup probe in
`tests/testthat/test-13_practical1_shiny.R`. Before the repair, the probe
could not safely import the browser script because Playwright was loaded at
module scope and no cleanup validator was exported. The new contracts also
cover final export freshness, rendered run-number integrity, route coverage,
responsive panels, downloads, and page overflow.

## GREEN

Changed only:

- `scripts/practical1_browser_acceptance.js`
- `tests/testthat/test-13_practical1_shiny.R`

The browser runner now:

- deletes evidence only after validating a non-symlink direct child of
  `os.tmpdir()` whose basename starts `rpva-practical1-`; unsafe, nested,
  non-temp, root, home, cwd, parent, and symlink paths are rejected;
- exports the validator and runs the browser only under
  `if (require.main === module)`;
- validates positive, unique, strictly increasing rendered run numbers,
  exactly `1..9` after the extension route;
- captures Concept Lab at 1366x768 and 1440x900, plus Concept Lab and Compare
  at 390x844, while retaining the existing five screenshots;
- checks mission rail/Run mission usability, Compare controls/downloads,
  real-panel overlap, table scrolling, and page horizontal overflow;
- invalidates and checks the old CSV/Markdown requests after extension runs;
- reconfirms extension-specific interpretation text;
- downloads fresh final CSV and Markdown artifacts and verifies final selected
  runs `1,8,9`, stages `deterministic_baseline`, `catastrophe`,
  `extinction_vortex`, settings/provenance rows, and the exact live-history
  note `Selected evidence: 3 runs from 9 successful session runs`;
- verifies Transfer remains incomplete after only one fresh final download and
  completes only after both fresh final downloads.

## Verification

- Focused test: `testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")` — passed with no failures. The existing renv warning reports bootstrap-only `pak` as installed/used but not recorded.
- Node syntax: `node --check scripts/practical1_browser_acceptance.js` — passed.
- Fresh browser: `http://127.0.0.1:3921` — 106/106 checks passed.
- Browser arrays: `consoleErrors=[]`, `consoleWarnings=[]`, `pageErrors=[]`.
- Browser artifacts: 14 recorded, all non-empty.
- Screenshots were inspected at original resolution for overlap, clipping, and responsive control visibility.
- `git diff --check` — passed after cleaning generated `renv/activate.R` whitespace.
- The runner-owned process on port 3921 was stopped. The pre-existing 39314 process was not targeted; it was no longer listening at the final audit.

Evidence directory:

`/tmp/rpva-practical1-task-9-browser-20260715-final`

Key final artifacts:

- `final-comparison.csv` — 522 bytes
- `final-evidence-notes.md` — 4162 bytes
- `browser-result.json` — 106 true checks
- `concept-lab-1366x768.png`
- `concept-lab-1440x900.png`
- `concept-lab-390x844.png`
- `compare-390x844.png`

## Caveats

This was a local headless Chromium/Playwright pass; the Browser plugin was
unavailable. No app source, CSS, raw data, Practical 2 source, or lockfile was
changed. The full repository test suite was not rerun; the focused Practical 1
suite and required browser gate were run.
