# Goal 044: Practical 1 Local-First Landing Tutorial

## Objective

Create a polished first-run landing/tutorial screen for the Practical 1 Shiny
app so a student sees the purpose of PVA, the practical mission, and the
evidence to save before entering the control workflow.

## Scope

- Work only in `/Users/bwbrook/git/rPVA`.
- Keep the change local-first and uncommitted for orchestrator review.
- Change only Practical 1 Shiny UI/server/CSS/tests/docs needed for this
  onboarding affordance.
- Preserve teaching API semantics, science/model/YAML/defaults, app export
  shape, Practical 2 mode, assessment design, deployment state, ITS/Gitea/VM
  state, Moodle/student release, accounts, credentials, and remote services.

## Deliverables

- Landing/tutorial screen before the existing Concept Lab control workflow.
- Clear `Start baseline` action that creates or restores baseline as run 1.
- A path back to the introduction after entering the lab.
- Local bitmap visual assets with recorded provenance.
- Focused Shiny tests for landing/tutorial structure and asset wiring.
- Local browser smoke evidence and screenshots under `/tmp`.
- Goal 044 report and log.

## Acceptance Checks

- `git diff --check`.
- `Rscript -e 'source("bootstrap.R")'`.
- `Rscript -e 'renv::status(sources = FALSE)'`.
- Focused teaching API test if relevant.
- Focused Practical 1 Shiny test.
- Local browser smoke covering landing, start baseline, run, compare/export,
  and Transfer reachability.
- Marker and secret/private-key/token/student-id scans over changed text.
