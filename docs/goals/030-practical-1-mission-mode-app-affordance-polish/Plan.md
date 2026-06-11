# Plan

## Phase 1: Orient And Guard

1. Read `Goal.md`, `Plan.md`, `Runbook.md`, and the repo-local teaching/app
   docs named in the goal.
2. Record `pwd`, branch, `HEAD`, and status in `Log.md`.
3. Confirm the branch is `codex/rpva-goal030-mission-app-affordances` and the
   base is `9d2504b`.
4. Stop if unexpected dirty state exists outside the Goal 030 packet.

## Phase 2: Inspect The Existing App Surface

1. Inspect `inst/shiny/practical1/app.R` for:
   - Start-screen baseline behaviour;
   - Concept Lab stage text and prompts;
   - Compare guidance and export controls;
   - Transfer text.
2. Inspect `tests/testthat/test-13_practical1_shiny.R` for current structural
   tests and patterns.
3. Inspect `styles.css` only if a small mission cue needs styling.

## Phase 3: Test-First Affordance Checks

1. Add focused tests that assert the app text contains the new mission-mode
   affordances.
2. Keep tests structural and stable enough for a small Shiny app:
   - mission/progress cue exists;
   - baseline/run-1 wording exists;
   - one-factor-change wording exists;
   - Compare guidance includes clean comparison and duplicate-rerun avoidance;
   - existing download wiring remains.
3. Run the focused Shiny test and confirm the new assertions fail before the app
   text changes, unless implementation and tests are made in one patch with the
   failure reason recorded in `Log.md`.

## Phase 4: Implement Minimal App Polish

1. Add small helper data structures or text blocks in `app.R` only if they
   reduce duplication.
2. Add a mission/progress cue near the Concept Lab stage text or another obvious
   location.
3. Update Start wording so the baseline is clearly run 1.
4. Update stage prompts or adjacent text so students are cued to change one
   assumption and compare.
5. Update Compare guidance so students choose a clean baseline/risk/
   intervention comparison and avoid filling the table with duplicate reruns.
6. Add CSS only if needed for readable cues; keep the visual style consistent
   with the existing app.

## Phase 5: Narrow Docs

1. Update `inst/shiny/practical1/README.md` if the new app affordances should be
   mentioned for students or demonstrators.
2. Update teaching docs only if required for consistency.
3. Do not rewrite Goal 029 curriculum documents unless a small pointer or
   wording correction is needed.

## Phase 6: Local Validation

1. Run:
   - `Rscript -e 'source("bootstrap.R")'`;
   - `Rscript -e 'renv::status(sources = FALSE)'`;
   - focused teaching API test;
   - focused Practical 1 Shiny test.
2. Run `git diff --check`.
3. Run marker and secret/private-key scans.
4. Run stricter assignment/private-key-block scan.

## Phase 7: Browser Smoke

1. Launch Practical 1 Shiny locally on a free `127.0.0.1` port.
2. Use an available local browser automation path.
3. Prove visible mission affordances are present.
4. Complete a short path through:
   - Start baseline;
   - at least three non-baseline stages;
   - Compare;
   - both downloads;
   - Transfer.
5. Inspect downloaded files for the expected comparison CSV and evidence-notes
   Markdown shape.
6. Stop Shiny and confirm the port is closed.

## Phase 8: Report

1. Update `Log.md` with:
   - start state;
   - sources read;
   - changes made;
   - validation;
   - browser evidence paths;
   - boundaries observed.
2. Report final branch/status, changed files, validation, export-contract
   status, and next recommendation.

## Recommendation Bias

Choose small, durable affordances over clever interaction. The right end state
is a better first-class browser tutorial, not a larger app.
