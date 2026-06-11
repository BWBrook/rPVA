# Plan

## Phase 1: Orient And Guard

1. Read `Goal.md`, `Plan.md`, `Runbook.md`, and the repo-local teaching docs
   named in the goal.
2. Record `pwd`, branch, `HEAD`, and status in `Log.md`.
3. Confirm the branch is `codex/rpva-goal029-practical1-mission-tutorial` and
   the base is `7fb56fb`.
4. Stop if unexpected dirty state exists outside the Goal 029 packet.

## Phase 2: Extract The Current Teaching Surface

1. Summarize the current Practical 1 app path:
   - Start;
   - Concept Lab;
   - Compare/export;
   - Transfer.
2. Summarize the current implemented teaching stages from docs and app/API
   surfaces.
3. Note deferred concepts only as future gaps. Do not design the main class
   around unavailable features.
4. Identify existing student worksheet, fallback, instructor, and dry-run
   guidance that should be reused rather than duplicated.

## Phase 3: Design The Mission Arc

1. Allocate the three-hour class into:
   - Barry priming;
   - app-led student tutorial work;
   - class recap pauses;
   - wrap-up and transfer.
2. Build the two-hour student-led mission sequence.
3. For each mission, specify:
   - learning question;
   - app action;
   - expected observation;
   - compare/evidence task;
   - worksheet prompt;
   - instructor roaming prompt.
4. Keep the arc finishable. Prioritize depth of reasoning over touching every
   possible mechanism.

## Phase 4: Draft Student Materials

1. Create or update the mission tutorial document.
2. Create the lightweight mission worksheet or worksheet specification.
3. Keep language active and student-facing.
4. Preserve scientific seriousness while making the experience exploratory.
5. Make the evidence-export role explicit: evidence supports interpretation;
   it is not the interpretation.

## Phase 5: Draft Instructor Support

1. Create a concise instructor beat sheet.
2. Include priming, recap, roam, and wrap-up moments.
3. Include likely misconceptions and short coaching prompts.
4. Include timing triage: what to skip, compress, or leave as extension if the
   class is slower than expected.

## Phase 6: Gap List And Narrow Pointers

1. Write a short pedagogy review under the Goal 029 directory.
2. Identify later app-support gaps separately from this goal's completed docs.
3. Add narrow README/index pointers only where useful.
4. Avoid broad rewrites of existing teaching docs.

## Phase 7: Validate And Report

1. Run:
   - `git status --short --branch`;
   - `git diff --check`;
   - `Rscript -e 'renv::status(sources = FALSE)'`.
2. Run marker and secret/private-key scans over changed/untracked text.
3. Manually review for secrets, private keys, credentials, student identifiers,
   and sensitive service payloads.
4. Update `Log.md`.
5. Report changed files, the student learning arc, endpoint outcomes, app-gap
   recommendations, validation, and boundaries observed.

## Recommendation Bias

Favor a polished, motivating, self-guided student path over exhaustive coverage.
This goal should make Practical 1 feel like a guided scientific investigation:
students test assumptions, compare evidence, and learn the habits needed for the
Woodhen case.
