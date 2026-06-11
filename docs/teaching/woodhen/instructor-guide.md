# Instructor Guide — Woodhen Teaching Practical Kit

## Session design intent

This kit is intended to be a minimal-code, reproducible road-test workflow for
undergraduate teaching. The emphasis is interpretation and decision-making, not
engine internals.

## Pre-class setup

- Confirm `git status` is clean except for expected goal artefacts.
- Start from the repo root.
- Work through `classroom-dry-run-checklist.md` on the teaching machine before
  the first student session.
- Use `practical-1-day-of-class-pack.md` and
  `practical-1-go-no-go-checklist.md` for the final Practical 1 day-of-class
  decision.
- Keep `practical-1-fallback-pack.md` open as the static recovery path if
  hosted Shiny, local Shiny, or app downloads are unavailable.
- For the app-led Practical 1 path, keep `practical-1-instructor-beat-sheet.md`
  and `practical-1-mission-worksheet.md` open alongside the Shiny app.
- Open an R session and run:

```r
source("bootstrap.R")
```

- Ask students to open:
  - `docs/teaching/woodhen/practical-1-pva-foundations.md`
  - `docs/teaching/woodhen/practical-2-woodhen-management.md`
- For assessment design review, read:
  - `docs/teaching/woodhen/assessment-brief-2026-draft.md`
  - `docs/teaching/woodhen/marking-rubric-2026-draft.md`
  - `docs/teaching/woodhen/feedback-template-2026-draft.md`
  - `docs/teaching/woodhen/assessment-design-crosswalk-2026.md`

## Three-hour class timing

- **Practical 1**
  - 0:00–0:15 orientation + bootstrap
  - 0:15–1:20 mechanism-by-mechanism toy runs
  - 1:20–2:00 interpretation and checkpoints
  - 2:00–3:00 short write-up

- **Practical 2**
  - 0:00–0:10 orient to woodhen narratives
  - 0:10–1:15 run scenario table and visual checks
  - 1:15–2:00 bounded sensitivity exercise
  - 2:00–3:00 synthesis and report scaffold fill

## Demonstrator prompts that usually help

- “What changed when `K` became explicit?”
- “Which number is the management effect versus the uncertainty effect?”
- “Why can two scenarios have similar Nmed but different extinction risk?”
- “What did fixed seed outputs help you control?”

## Common issues and coaching scripts

- **`PE = 0` interpreted as ‘safe’**
  Script: *“`PE = 0` means no runs extincted in this horizon; still ask if this is
  ecologically meaningful and whether the uncertainty spread is wide.”*

- **Missing trajectory plots**
  Script: *“`plot_pva_traj()` and `plot_ext()` require `keep_traj = TRUE` when simulating.”*

- **Students skip code checkpoints**
  Script: *“Require each student to print object names and table outputs before moving forward.”*

- **Comparisons done without seeds**
  Script: *“For comparable class results, pin `seed = 123` in your reporting run.”*

## Expected outputs (minimum evidence per group)

- Practical 1 toy summary with non-zero extinction risk only in `genetics`,
- one `run_scenarios()` table (Practical 2),
- one plotted management scenario,
- one bounded sensitivity table,
- checkpoint answers from both practicals,
- report scaffold with written management caveat.

## Notes for Barry’s road test

- Keep this kit as the teaching entry point; avoid parallel UI work during the
  first road test.
- For first delivery, prioritize clarity of interpretation prompts over adding new
  helper wrappers.
- For app-led Practical 1 delivery, protect the two-hour mission arc from being
  swallowed by setup or lecture; use the beat sheet's compression options if
  the class is slow.
- Keep local/in-room teaching readiness separate from hosted student URL
  release readiness. A local rehearsal can be usable while a raw-IP or insecure
  HTTPS route remains not student-ready.
- Before releasing AT1, confirm whether students will use R-only outputs, Shiny
  exports, or both, then tune the optional artefact wording accordingly.
- For the first road test, do not let app trouble consume the interpretation
  window. Switch to the fallback pack once retrying the app would cost more
  than a few minutes of class time.
