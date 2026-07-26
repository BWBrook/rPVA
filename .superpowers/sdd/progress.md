# Practical 1 Final Polish Progress

Plan: docs/superpowers/plans/2026-07-15-practical1-final-polish.md
Start commit: df3dc71
Execution mode: subagent-driven in the existing checkout

Task 1: complete (commits df3dc71..c7bd637, review approved)
Task 2: complete (commits c7bd637..c4cb7cd, review approved)
Task 3: complete (commits c4cb7cd..9e1a2c4, repaired and review approved)
Task 4: complete (commits 9e1a2c4..9b95a7f, repaired and review approved)
Task 5: complete (commits 9b95a7f..309e95b, durable duplicate-attempt coverage and review approved)
Task 6: complete (commits 309e95b..e6b7a943, full suite passed and review approved)
Task 7: complete (commits e6b7a943..57a3120, select focus repaired and review approved)
Task 8: complete (commits 57a3120..4d57dfd, 53/53 browser checks and review approved)
Task 9: complete (commits 4d57dfd..de888e4 plus release record, full clean gates and final max-level audit approved)
Task 10: complete (immutable linux/amd64 image built, smoke/browser accepted, pushed at pinned digest, and independent evidence audit approved)
Task 11: pending (scheduled dev deployment, Saturday 2026-07-18)
Task 12: pending (scheduled production deployment, Sunday 2026-07-19)

Minor findings carried to final review:
- Task 1 report called its focused GREEN command exact even though the controller deliberately substituted pkgload::load_all() for source("bootstrap.R") after the bootstrap restore path timed out on the known pak state. No implementation defect; preserve as test-evidence context.
- Task 2 validation branches for duplicate or missing run IDs and undersized session counts are implemented and smoke-checked, but do not yet have explicit regression tests; settings tests also assert the ID set rather than the full ID-to-run mapping.
- Task 3 rail navigation, previous/next behavior, post-baseline run IDs, and reset state were independently smoke-probed but are not yet all represented by focused behavioral regression tests.
- Task 3 RED output and the claimed two GREEN runs are described in the execution report but were not archived; independent review reproduced one clean GREEN run.
- Task 4 reset interpretation clearing is covered by a source/static contract rather than a dynamic testServer assertion; the execution report now states this limitation accurately.
- Task 6 post-readiness renderUI replacement and reset-cleared interpretation/Transfer HTML were independently probed successfully but are not direct focused regression assertions; browser acceptance remains the stronger DOM-level gate.
- Task 7 static contracts establish selector/copy presence but do not prove rendered grid assignments, focus visibility, or status semantics; Task 8 browser acceptance is the required rendered gate.

Task 9 disposition of carried findings:
- The final clean-process gate used `source("bootstrap.R")` for bootstrap, both focused suites, and the full test directory; all passed. This supersedes the earlier Task 1 evidence caveat.
- Final state tests and browser assertions cover monotonic rendered run IDs, repeated Start behavior, reset, evidence identity, selection/interpretation invalidation, and independent CSV/Markdown completion.
- The fresh browser gate covers mission navigation, contextual actions, visible keyboard focus, responsive layout, panel geometry, table scrolling, and complete minimum/extension routes.
- Cleanup validation is exercised through structured runtime probes, including relative, parent, root, symlink, dangling-symlink, nested, and valid uncreated temporary paths.
- Final CSV and Markdown are checked against rendered selected IDs, exact stages, labels, complete comparison values, and exact ordered settings/provenance.
- Final adversarial audit reported no Critical, Important, or Minor findings. The only residual uncertainty is deployment-image equivalence, assigned to Task 10.

---

# Practical 2 Woodhen Management Lab Progress

Plan: docs/superpowers/plans/2026-07-21-practical2-woodhen-management-lab.md
Start commit: 7f9d58c
Execution mode: subagent-driven in isolated worktree on codex/practical2-implementation
Baseline: full pre-change test suite passed on 2026-07-21

Gate 1:
- Task 1: complete (commit f1132b1, focused/core/validation tests and scalar result hash passed; review approved with field-aware bounds clarification)
- Task 2: complete (commit 3d3c872, focused tests and real-engine smoke passed, review approved; minor plot-test hardening carried to Gate 1 closeout)
- Task 3: complete (commits 8ecc328, dc96287, and 30064ab; focused/legacy tests and scientific audit passed; two review-repair rounds resolved all Important and Minor findings)
- Package boundary: complete (commit 2eedf7c; `digest` declared, 12 Gate 1 interfaces exported, isolated source install passed)
- Shared-engine regression: complete on final code (all tests passed in 368 seconds on 2026-07-21)
- Scientific audit: complete (72 CSV rows and 87 Markdown lines; Act 2 uses 75 years, 1,000 futures, seed 123, and strictly fewer than 50 stage-2+ breeding pairs)

Gate 1 scientific decisions:
- Supplementation releases 5/10/15 stage-2 female-equivalent breeding pairs annually for three years.
- Cyclone presets alter catastrophe frequency only; emergency response recovers catastrophe survival toward 1; cat reproduction is advanced explicit only.
- Practical habitat capacity is bounded to K >= 150 and K >= 3*K_sd, with locked K_sd = 50 in ordinary Act 2 comparisons.

Gate 1 review dispositions:
- Generic build_temporal_profile() must support both probability and unbounded K/fecundity endpoints; field-specific [0,1] checks belong in validate_annual_profiles().
- Task 3 family construction preflights every resolved surv/env_sd annual pair before simulation.
- Scientific identities include the intervention definition as well as final executable values; same-result but biologically different interventions remain distinct.
- Plot fixtures do not exhaustively pin every threshold-curve probability/annotation combination; current focused and full-suite coverage is sufficient for Gate 1.
- Shared profile allowlist and additional simulation-level vital-rate tests are optional hardening, not current blockers.

Gate 1 status: closed. Next tranche is Gate 2 compact evidence and portable project state; no browser checkpoint is required for Gate 1.

Gate 2:
- Task 4: complete (commits 262b5d4, 1dcf93d, and 0fb4701; focused tests and all-catalogue compact-record audit passed; two review-repair rounds resolved all Critical and Important findings)

Gate 2 review dispositions:
- Compact evidence validates exact scenario/result provenance, common comparison seed and futures, and bounded path-aware payload schemas.
- Legitimate `75 x 7` annual vital-rate matrices are retained; arbitrary trajectory-shaped matrices and flattened payloads are rejected.
- The ignored Task 4 execution report still describes its repair commits as uncommitted; this is stale operational wording only and does not affect code or evidence.
- Task 5: complete (commits 723d25b, ffadd41, and ecc4ec4; typed project-package round trips and hostile import tests passed; two review-repair rounds resolved all Critical, Important, and Minor findings)
- Package boundary: complete (Task 4's 8 evidence/comparison interfaces and Task 5's 9 project interfaces exported; isolated source install and installed-namespace probe passed)
- Shared regression: complete on final Gate 2 code (all tests through Task 21 passed in 477 seconds on 2026-07-21)
- Portable package audit: complete (5 scenarios, 3 compact runs, 1 observation; 15,794 bytes compressed and 405,544 bytes expanded; exact IDs, typed scientific content, notes, selections, comparison outcomes, and stable fingerprint survived re-export)

Gate 2 status: closed. Next tranche is Gate 3's student-facing three-hour core route; the first browser checkpoint follows Tasks 6-8.

Gate 3:
- Task 6: complete (commits 02d4ba9, 727eb18, and d678e42; 113-expectation Shiny, 56-expectation project-store, and 209-expectation project compatibility suites passed; cold namespace-only Create/Import/restore and first-click Create/Resume passed; two review-repair rounds resolved all Critical and Important findings)
- Task 7: complete (commits d3db69e and 937dca8; 158-expectation Calibrate and 127-expectation Shiny suites passed after repair, evidence/project compatibility suites passed, cold installed-namespace construction passed, and independent review approved)
- Task 8: complete (commits ed7cf5f, 4983322, and 62a5609; focused core/evidence/shell/calibrate/project suites, 612.6-second full tests 00-24, and cold installed-namespace probes passed; two review-repair rounds resolved all Important findings and final review approved)

Gate 3 review dispositions:
- Browser snapshots remain strict typed project documents; IndexedDB inventory carries metadata only and explicit restore is the sole activation path.
- Production launches with the `rPVA` namespace loaded but unattached, so app-side package APIs are explicitly namespace-qualified and cold-process tested.
- Restore and storage acknowledgements are correlated by request identity, operation kind, project identity, and fingerprint before pending state is consumed.
- Real Shiny action-button `0 -> 1` semantics are covered so Create and Resume work on the first click.
- Real IndexedDB durability, browser download behavior, and rendered responsive acceptance remain assigned to the Gate 3 browser checkpoint after Tasks 7-8.
- Historical reference evidence uses three compatible 40-year 1980 cases, a separately labelled 2019-2024 recovery check, and the exact 2025-2100 locked future anchor; ordinary Act 2 preflight remains unchanged.
- The observed historical statement is over 1,600 birds by 2024; 1,654 birds and about 330 breeding pairs are labelled as the supplied 2024 model state.
- Anchor readiness requires the actual current `05_future_baseline` scenario and run with exact library/model metadata, seed, futures, horizon, and fingerprints.
- Calibrate state reconstructs from the root project after Create/Import/Restore, and the real root event path is behaviorally tested through validation, activation, dirty state, and autosave request.
- Investigate supports all eight sensitivity factors and all six threat seeds, with compatible interventions, a labelled linear sea-level pathway, atomic family insertion, strict fewer-than-50 breeding-pair evidence, and duplicate-safe prompt observations.
- Family restore uses exact component metadata (including `K_sd`), exact reruns report truthful completed progress without rerunning, and restored controls/results/completion reconstruct from project evidence.
- Deferred batches and root activation are guarded by the accepted project fingerprint; mutual client disabling and busy state span the work/activation flush so queued cross-route actions cannot overwrite newer work.

Gate 3 implementation status: complete. Next tranche is the local browser checkpoint and Barry's core-route review.
