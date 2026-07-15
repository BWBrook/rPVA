# Practical 1 final Task 9 artifact strictness report

## Scope

Implementation commit: `12b28ca` (`Harden Practical 1 final artifact checks`).

Changed implementation files:

- `scripts/practical1_browser_acceptance.js`
- `tests/testthat/test-13_practical1_shiny.R`

No app, CSS, science/default, Practical 2, or lockfile files were changed.

## RED / GREEN

The focused RED probe failed before implementation because the strict helper
contract was absent: `canonicalExpectedSettings is not a function`. The cleanup
probe was extended to include a valid, absolute, direct `rpva-practical1-*`
child of the system temporary directory that had not been created; it must be
accepted without being created first.

GREEN verification:

- `node --check scripts/practical1_browser_acceptance.js`: passed.
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'`: passed; no failures.
- Fresh browser run at `http://127.0.0.1:3938`: passed all 135 checks.
- Browser result: `consoleErrors=[]`, `consoleWarnings=[]`, `pageErrors=[]`, and no failed checks.
- Evidence directory: `/tmp/rpva-practical1-task9-final`.
- Artifacts: 14 non-empty files, including `final-comparison.csv` and
  `final-evidence-notes.md`.

## Exact assertions

The shared CSV/Markdown comparison assertion now requires the complete shared
comparison schema and rejects undefined, null, and empty values before testing
equality. This covers `PE`, `Nmed`, `Nlo95`, `Nhi95`, extinction/survival
counts, and baseline deltas as well as identity and provenance fields. The same
assertion is used for both initial and final exports.

Rendered labels map exactly to stage IDs through the explicit
`renderedStageByLabel` map. CSV and Markdown stages must equal that mapping in
rendered selection order. The existing Baseline/Risk mechanism/Intervention or
vortex category checks and final route constants remain additional checks.

For settings/provenance, the invariant is exact ordered equality of
`run_id`, `stage`, `label`, `setting`, and `value` rows. Expected rows are
constructed from the selected cards’ rendered settings fragments plus the
known stage-specific `spec_*` representation and control overrides used by
the live session. The session history label/settings must also equal the
selected-card label/settings. `Reference settings` is only valid for the
baseline and must expand to the complete deterministic-baseline spec rows;
missing, extra, duplicate, or incorrect rows fail the assertion.

## Final artifact inspection

The final CSV contains the selected run IDs `1, 8, 9` with stages
`deterministic_baseline`, `catastrophe`, and `extinction_vortex`. Its shared
comparison values match the Markdown table, including interval, count, and
delta fields. The Markdown records `Selected evidence: 3 runs from 9
successful session runs` and contains exact settings/provenance rows for all
three selected runs.

`renv/activate.R` was checked and normalised for trailing whitespace; it is
clean relative to HEAD. `git diff --check` passed.

## Caveat

The Browser plugin was not available in this session. The required rendered
browser pass therefore used the already-installed shared Playwright runtime
via `NODE_PATH`, without installing or modifying dependencies.

This report is committed separately as:

`Document Practical 1 artifact strictness`
