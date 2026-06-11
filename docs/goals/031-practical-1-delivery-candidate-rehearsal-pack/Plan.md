# Plan

## Phase 1: Orient And Guard

1. Read `Goal.md`, `Plan.md`, `Runbook.md`, and the repo-local teaching/app
   docs named in the goal.
2. Record `pwd`, branch, `HEAD`, and status in `Log.md`.
3. Confirm the branch is `codex/rpva-goal031-delivery-candidate-rehearsal` and
   the base is `d4855fc`.
4. Stop if unexpected dirty state exists outside the Goal 031 packet.

## Phase 2: Dry-Run The Current Classroom Path

1. Launch Practical 1 Shiny locally on a free `127.0.0.1` port.
2. Use the mission tutorial, worksheet, and instructor beat sheet as the
   rehearsal script.
3. Exercise the final teaching path:
   - Start baseline;
   - carrying capacity;
   - one stochasticity mission;
   - one risk-pressure mission;
   - one intervention or vortex mission;
   - Compare and exports;
   - Transfer.
4. Save screenshots and downloaded evidence under `/tmp`.
5. Stop Shiny and confirm the port is closed.

## Phase 3: Review Student And Instructor Materials

1. Check the mission worksheet for print/Moodle suitability:
   - clear student instructions;
   - compact mission log;
   - clear export checklist;
   - no hidden dependency on repo paths if students receive it as a file.
2. Check the instructor beat sheet and instructor guide for day-of-class
   usability.
3. Identify any small wording or pointer fixes.

## Phase 4: Build The Day-Of-Class Pack

1. Create `docs/teaching/woodhen/practical-1-day-of-class-pack.md`.
2. Include:
   - pre-class setup;
   - links/files students open;
   - neutral app URL wording that does not imply release;
   - Barry priming, recap, and wrap-up beats;
   - exact evidence students must save;
   - download failure and fallback triggers;
   - post-class notes to capture.

## Phase 5: Build The Go/No-Go Checklist

1. Create `docs/teaching/woodhen/practical-1-go-no-go-checklist.md`.
2. Separate:
   - local/in-room readiness;
   - hosted URL/TLS/student-release readiness;
   - fallback readiness.
3. Make current hosted blockers explicit without attempting to resolve them.

## Phase 6: Write Rehearsal Report And Narrow Pointers

1. Create `delivery-rehearsal-report.md` under the Goal 031 directory.
2. Record:
   - commands;
   - browser path and evidence;
   - export confirmation;
   - render results;
   - doc changes;
   - local readiness and remaining blockers.
3. Update README/instructor-guide/checklist pointers only where needed.

## Phase 7: Validate And Report

1. Run:
   - `git diff --check`;
   - `Rscript -e 'source("bootstrap.R")'`;
   - `Rscript -e 'renv::status(sources = FALSE)'`;
   - focused teaching API test;
   - focused Practical 1 Shiny test.
2. Render/check report scaffold if used by the delivery pack.
3. Run marker and secret/private-key scans.
4. Run stricter assignment/private-key-block scan.
5. Update `Log.md`.
6. Report changed files, rehearsal evidence, readiness assessment, and
   remaining blockers.

## Recommendation Bias

Make this useful on the morning of class. Prefer one clear delivery pack and one
sharp checklist over scattered improvements. Do not let the rehearsal become a
new implementation project.
