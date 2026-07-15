# Practical 1 Final Task 9 Release Report

Date: 2026-07-16
Approved design: `docs/superpowers/specs/2026-07-15-practical1-final-polish-design.md`
Reviewed range: `559a2f3bb4d896849c855ee4ddbbdd34211432dd..de888e44e59412a2d063deab6d8377e84840b9f2`

## Release State

The Practical 1 local classroom release is frozen and approved for immutable
image construction. The implementation head reviewed by the final auditor is
`de888e44e59412a2d063deab6d8377e84840b9f2`. The commit containing this report
is the Task 9 release-record commit and is intentionally documentation-only.

No Practical 2 source, deployment configuration, scientific default, or
model-result contract changed during the Task 9 repairs.

## Validated Repairs

- Repeated Start returns to baseline run 1 without deleting history, reusing
  later IDs, or carrying stale evidence state.
- CSV and Markdown completion are independently tied to the ordered selected
  run IDs and trimmed current interpretation.
- Selection or interpretation changes invalidate both prior artifact requests;
  reset clears the complete associated state.
- Browser evidence cleanup accepts only a non-symlink, absolute, direct child
  of the system temporary directory whose name begins `rpva-practical1-`.
- The browser route proves rendered run IDs `1..9`, a three-run final selection,
  post-extension re-export of both artifacts, and Transfer completion only
  after both fresh downloads.
- Mission labels use the intended Shiny action-link grid and remain readable at
  1366x768, 1440x900, and 390x844.
- Final CSV and Markdown are checked against the rendered selected IDs, exact
  stages, labels, complete comparison values, and exact ordered
  settings/provenance rows.

Detailed repair reports:

- `.superpowers/sdd/practical1-final-task-9-state-fix-report.md`
- `.superpowers/sdd/practical1-final-task-9-browser-fix-report.md`
- `.superpowers/sdd/practical1-final-task-9-mission-label-fix-report.md`
- `.superpowers/sdd/practical1-final-task-9-artifact-strictness-report.md`

## Clean Process Gate

Fresh logs: `/tmp/rpva-practical1-task9-final-gates-20260716T001106`

- `source("bootstrap.R")`: passed.
- `renv::status(sources = FALSE)`: completed; the only difference is local
  `pak`, installed and used as bootstrap tooling but not recorded.
- Focused teaching API suite: passed.
- Focused Practical 1 Shiny suite: passed.
- Full `tests/testthat` suite, including Practical 2: passed.
- Practical 1 deployment scaffold validation: passed.
- `git diff --check`: passed.

`pak` occurs only as transitive references in `renv.lock`; it is absent from
`DESCRIPTION`, `NAMESPACE`, `R/`, and `bootstrap.R`. The lockfile was not
changed merely to silence the local status message.

## Browser Gate

Fresh parent-run evidence:
`/tmp/rpva-practical1-task9-parent-final-20260716`

- 135/135 browser checks passed.
- 14/14 recorded artifacts were non-empty.
- Console errors, console warnings, and page errors were empty.
- Rendered session run IDs were positive, unique, strictly increasing, and
  exactly `1..9`.
- Final selected/exported runs were `1`, `8`, and `9` with stages
  `deterministic_baseline`, `catastrophe`, and `extinction_vortex`.
- Notes recorded `Selected evidence: 3 runs from 9 successful session runs`.
- All ten generated PNG files were inspected at original resolution.

The pass used the installed Playwright Chromium runtime because the Browser
plugin was unavailable. No dependency or lockfile change was required.

## Independent Review

The state-freshness repair and each browser-gate repair received independent
bounded review. The final max-level adversarial audit reviewed the complete
range and reported no Critical, Important, or Minor findings.

Final verdict: **Approved**.

## Remaining Boundary

Task 9 proves the source-launched application. Task 10 must build the exact
synchronized source as one immutable `linux/amd64` image, repeat health and
full browser acceptance against that image, push it, and record its OCI source
revision and registry manifest digest. No dev or production deployment should
use an image that has not passed that equivalence gate.
