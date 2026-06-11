# Plan

## Phase 1: Guard And Orient

1. Confirm repo root, branch, HEAD, and `git status --short --branch`.
2. Confirm the branch is `codex/rpva-goal033-moodle-ready-artefact-bundle` and
   the base is the accepted Goal 032 commit.
3. Read the Goal 033 packet and the current Practical 1 launch materials.
4. Record the start guard and source list in `Log.md`.

## Phase 2: Choose Bundle Shape

1. Inspect repo ignore rules and existing teaching-file conventions.
2. Decide which generated artefacts are useful and appropriate to commit.
3. Prefer a compact bundle folder that references source-of-truth files rather
   than duplicating large source documents.
4. Keep raw-IP/insecure-route and student-release gates explicit.

## Phase 3: Build Moodle Handoff Surface

1. Create the Moodle-ready bundle folder.
2. Write bundle `README.md`.
3. Write paste-ready Moodle section text.
4. Write a manifest with source paths, generated outputs, labels, visibility,
   render commands, checksums or sizes, and route-gate notes.
5. Add narrow discoverability pointers if needed.

## Phase 4: Generate And Verify Artefacts

1. Render included artefacts sequentially.
2. Verify file type, size, and PDF metadata where applicable.
3. Record generated paths and checksums or sizes.
4. Leave ignored or unsuitable generated files out of the repo and document how
   to regenerate them.

## Phase 5: Validate

1. Run patch hygiene, bootstrap, environment, and focused teaching tests.
2. Run marker, secret/private-key, stricter assignment/private-key-block, and
   student-visible route wording scans.
3. Verify no Moodle state, app code, hosting, account, or student-release state
   changed.

## Phase 6: Report

1. Write `artefact-bundle-report.md`.
2. Update `Log.md` with commands, outputs, checks, and boundary result.
3. Leave changes uncommitted.
4. Wake the rPVA orchestrator with a concise completion or blocker report.
