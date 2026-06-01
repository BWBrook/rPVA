# Plan

## 1. Confirm State

- Check branch, remote sync, and dirty state.
- Confirm only expected management/teaching artefacts are untracked.
- Record starting state in `Log.md`.

## 2. Read Teaching Inputs

- Read the post-merge readiness audit.
- Read the current README teaching snippets.
- Inspect the toy and Woodhen scripts, Woodhen YAML comments, relevant exported
  helpers, and scenario tests.

## 3. Build The Teaching Kit Skeleton

- Create `docs/teaching/woodhen/`.
- Create the landing page, two practical worksheets, instructor guide,
  expected outputs, glossary, troubleshooting guide, report scaffold, and
  rubric.

## 4. Draft Practical 1

- Center the class on PVA foundations using the toy model.
- Keep tasks runnable by novices.
- Add interpretation checkpoints and expected observations for each mechanism.

## 5. Draft Practical 2

- Center the class on Woodhen baseline, interventions, and management
  interpretation.
- Include a bounded sensitivity exercise that changes one factor at a time.
- Add prompts for uncertainty, assumptions, and conservation advice.

## 6. Draft Instructor And Assessment Support

- Write timing and demonstrator notes.
- Write expected-output tables and common troubleshooting explanations.
- Write the report scaffold and marking rubric.

## 7. Validate

- Run cheap R commands to confirm the main worksheet examples still match the
  package.
- Run `git diff --check`.
- Check that only expected files changed.

## 8. Finalize

- Update `Log.md` with commands, artefacts, residual risks, and final git
  state.
- Respond with a concise summary and the recommended next supervisor decision.
