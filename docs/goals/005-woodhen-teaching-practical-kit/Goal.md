# Goal: Woodhen Teaching Practical Kit

## Objective

Create the first complete teaching-document kit for a Woodhen-centred `rPVA`
road test: two three-hour undergraduate practicals that take students from no
PVA background to running, interpreting, modifying, and reporting on the
Woodhen case study.

## Why This Matters

The post-merge audit found that the engine and Woodhen scenarios are credible,
but the package is not yet a zero-to-hero teaching product. The next two months
should therefore focus on the student journey, demonstrator support, expected
outputs, interpretation prompts, and assessable-report scaffold before any UI
or Shiny implementation.

This goal is the first road-test teaching build. It should produce materials
that Barry could review, adapt, and trial with a third-year undergraduate class.

## Operating Mode

Teaching-product build, documentation-first, no package-code changes.

## Current Unlocked Envelope

This is a bounded supervision-cycle test.

Allowed:

- create teaching documents under `docs/teaching/woodhen/`
- run cheap local R commands to verify examples and capture expected outputs
- update this goal's `Log.md`
- create a short implementation note if useful under `docs/codex/`

Not allowed:

- edit package code under `R/`
- edit YAML scenarios under `inst/extdata/`
- edit tests, CI, dependencies, `renv.lock`, `DESCRIPTION`, or package metadata
- change scientific assumptions, model defaults, or Woodhen scenario values
- implement Shiny or any other UI
- commit, push, open PRs, merge, or delete branches
- launch remote/HPC jobs or long simulation campaigns

The supervisor will stop after this goal completes and ask Barry whether to
unlock the next phase.

## Review Surface

Primary teaching kit directory:

- `docs/teaching/woodhen/`

Expected files:

- `README.md`
- `practical-1-pva-foundations.md`
- `practical-2-woodhen-management.md`
- `instructor-guide.md`
- `expected-outputs.md`
- `glossary.md`
- `troubleshooting.md`
- `report-scaffold.qmd`
- `marking-rubric.md`

Secondary review surface:

- updated `docs/goals/005-woodhen-teaching-practical-kit/Log.md`
- optional `docs/codex/woodhen-teaching-practical-kit-2026-06-01.md`
- final response summary with git state, validation, artefacts, and residual
  risks

## Scope

In scope:

- design Practical 1 as the beginner ramp from PVA concepts to toy-model runs
- design Practical 2 as the Woodhen management and sensitivity-analysis class
- make both practicals fit separate three-hour teaching blocks
- write student-facing instructions with runnable code blocks
- include checkpoints, interpretation prompts, short reflection questions, and
  expected observations
- define a bounded Woodhen sensitivity exercise that changes one factor at a
  time and keeps ecological interpretation central
- create an instructor guide with timing, setup, likely stumbling points, and
  demonstrator prompts
- create a glossary for core PVA terms used in the practicals
- create a troubleshooting page for setup, package loading, plotting, missing
  trajectories, `PE = 0`, and common interpretation traps
- create expected-output tables from the current engine where cheap to verify
- create a report scaffold suitable for an assessable short report
- create a concise marking rubric/checklist

Out of scope:

- polishing the package README
- adding helper functions or changing exported APIs
- rendering a final polished report
- implementing report-bundle code
- changing plots, labels, or plotting helpers
- reviewing or changing Woodhen science
- building RShiny

## Read First

- `docs/codex/post-merge-readiness-audit-2026-06-01.md`
- `README.md`
- `inst/extdata/toy/toy_demo.R`
- `inst/extdata/woodhen/woodhen.R`
- `inst/extdata/woodhen/*.yaml`
- `R/run_toy_demo.R`
- `R/run_scenarios.R`
- plotting helpers under `R/plot*.R`
- `tests/testthat/test-09_scenarios.R`

## Starting State Checks

Run these first and record results in `Log.md`:

```sh
git status --short --branch
git log --oneline --decorate --max-count=8
```

Expected state is `main...origin/main` with untracked management artefacts from
Goals 004 and 005. If tracked package source files are dirty before you start,
stop and report the mismatch.

## Required Work

1. Confirm the current repo state and read the audit recommendations.
2. Design the teaching kit structure under `docs/teaching/woodhen/`.
3. Draft Practical 1:
   - PVA framing and learning objectives
   - toy-model setup and interpretation
   - deterministic growth, density ceiling, demographic stochasticity,
     environmental stochasticity, and inbreeding
   - short checkpoints that connect output to concept
4. Draft Practical 2:
   - Woodhen case framing
   - baseline and intervention scenario comparison
   - standard comparison table and plot prompts
   - one bounded sensitivity-analysis exercise
   - management interpretation prompts
5. Draft instructor support:
   - room setup and timing
   - demonstrator notes
   - expected outputs
   - common errors and explanations
6. Draft report support:
   - Quarto report scaffold
   - marking rubric/checklist
   - guidance for assumptions, uncertainty, limitations, and management
     conclusions
7. Run cheap validation and record all commands.
8. Recheck final git state and report exactly what changed.

## Validation Gates

The goal is complete when:

- all expected teaching files exist under `docs/teaching/woodhen/`
- code snippets in the worksheets are plausible against current exported
  functions
- cheap R checks have been run and their key outputs recorded
- `git diff --check` passes
- `Log.md` records starting state, commands, artefacts, residual risks, and
  final git state
- no out-of-scope package, scenario, dependency, CI, or Shiny files were changed

Suggested cheap checks:

```sh
git diff --check
Rscript -e 'source("bootstrap.R"); toy <- run_toy_demo(keep_traj = FALSE, plot_matrix = FALSE, verbose = FALSE); print(toy$summary)'
Rscript -e 'source("bootstrap.R"); tbl <- run_scenarios("woodhen", csv_out=NULL, rds_out=NULL, keep_traj=FALSE, parallel=FALSE); print(tbl)'
```

If a suggested check is inappropriate after inspection, explain why in
`Log.md` and run the nearest cheap substitute.

## Deliverables

- `docs/teaching/woodhen/README.md`
- `docs/teaching/woodhen/practical-1-pva-foundations.md`
- `docs/teaching/woodhen/practical-2-woodhen-management.md`
- `docs/teaching/woodhen/instructor-guide.md`
- `docs/teaching/woodhen/expected-outputs.md`
- `docs/teaching/woodhen/glossary.md`
- `docs/teaching/woodhen/troubleshooting.md`
- `docs/teaching/woodhen/report-scaffold.qmd`
- `docs/teaching/woodhen/marking-rubric.md`
- updated `docs/goals/005-woodhen-teaching-practical-kit/Log.md`

## Decision Authority

You may decide:

- the exact section structure and tone of the teaching documents
- how to sequence the two practical classes within the three-hour blocks
- which toy and Woodhen outputs to show as expected results
- how to phrase student prompts, demonstrator hints, and rubric items

You must pause before:

- changing engine behaviour, scenario values, or scientific assumptions
- adding helper functions or package-level docs
- adding dependencies
- making commits, pushes, PRs, or branch changes
- building or prototyping Shiny

## Stop Conditions

Stop when one of these is true:

- the teaching kit and goal log are complete
- tracked package source files are unexpectedly dirty before or during work
- a scientific judgement from Barry is required before the teaching material
  can be honest
- validation fails in a way that affects whether the practicals are usable

## Final Response Requirements

Report succinctly:

- what teaching files you created
- which commands you ran and their outcomes
- whether the goal-mode delegation prefix appeared to put you in goal mode
- any assumptions or residual risks
- final git status
- recommended next supervisor decision
