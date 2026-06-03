# Goal 011: Practical 1 Shiny Design Spike

## Objective

Produce a bounded design package for a GUI-first Practical 1 Shiny experience
that teaches PVA concepts from first principles before students move into the
Lord Howe Island woodhen case study in Practical 2.

This is a design and requirements goal only. Do not implement a Shiny app, add
dependencies, change package code, or commit/push anything.

## Context

Barry's 2026 teaching goal is a two-practical zero-to-hero pathway:

- Practical 1: students with little or no PVA background use a Shiny GUI to
  build conceptual understanding of population growth, simple carrying
  capacity, stochasticity, extinction vortex dynamics, catastrophes, and
  interventions.
- Practical 2: students transfer those skills to the Woodhen case study with
  guardrails, then prepare an assessable Woodhen report.

The key delivery risk is mixed student hardware. The interface and setup path
must be credible for Windows 11, macOS, older laptops, and fallback browser-only
or Chromebook-like situations without requiring students to work in Terminal,
PowerShell, bash, package rebuilds, or YAML editing.

Goal 010 produced a draft Woodhen AT1 assessment package. Treat it as useful
context, but do not edit it in this goal.

## Required Sources

Read and use:

- `docs/teaching/woodhen/practical-1-pva-foundations.md`
- `docs/teaching/woodhen/practical-2-woodhen-management.md`
- `docs/teaching/woodhen/report-scaffold.qmd`
- `docs/teaching/woodhen/assessment-brief-2026-draft.md`
- `docs/teaching/woodhen/assessment-design-crosswalk-2026.md`
- `docs/teaching/intake-2026-06-02-legacy-assessment-materials/1_rPVA_overview.md`
- `docs/teaching/intake-2026-06-02-legacy-assessment-materials/2_woodhen_notes.converted.md`
- existing engine and teaching helpers in `R/`
- toy and Woodhen scenarios under `inst/extdata/`

You may read additional repo files as needed.

## Deliverables

Create a new directory:

- `docs/teaching/shiny/`

Inside it, create:

1. `README.md`
   - concise index of the Shiny design package
   - explain that this is a design spike, not an implemented app

2. `practical-1-design-brief.md`
   - define the Practical 1 learning experience as a staged concept lab
   - map each stage to PVA concepts, student actions, visible outputs, and
     what students should understand before moving on
   - include deterministic growth, ceiling carrying capacity, demographic
     stochasticity, genetic stochasticity, Allee effects, extinction vortex
     synergy, environmental stochasticity, correlated events, catastrophes,
     and interventions
   - recommend a simple invented species framing if useful
   - include guardrails for what the GUI should reveal versus hide

3. `engine-affordance-audit.md`
   - map the current rPVA functions, scenarios, and helpers that could support
     the Shiny concept lab
   - distinguish ready-to-use engine pieces, pieces needing thin wrapper/helper
     functions, and genuine gaps
   - avoid proposing large refactors unless they are clearly needed
   - identify the minimum engine-facing API a Shiny app should call

4. `deployment-and-setup-options.md`
   - compare local Shiny, hosted Shiny, containerized/server, and browser-first
     fallback options for the student cohort
   - assess Windows 11, macOS, older laptops, and Chromebook/fallback cases
   - recommend a primary path and fallback path for the 2026 road test
   - list unresolved decisions Barry may need to make

5. `implementation-roadmap.md`
   - propose a staged sequence of future implementation goals
   - separate minimum viable teaching app from nice-to-have expansions
   - include testing/QA expectations, including Chrome-based Shiny testing
   - include where human student-style poking would add value

## Boundaries

Do not:

- implement or scaffold a Shiny app
- add `shiny` or other dependencies
- edit R package code
- edit scenarios
- edit Goal 010 assessment files
- edit tests or CI
- commit or push

You may create or update only:

- `docs/goals/011-practical-1-shiny-design-spike/Log.md`
- files under `docs/teaching/shiny/`

## Validation

Before reporting back:

- run `git diff --check`
- run `rg -n "TODO|TBD|PLACEHOLDER" docs/teaching/shiny docs/goals/011-practical-1-shiny-design-spike`
  and either remove placeholders or explain any intentional hits in the log
- run `git status --short --branch --untracked-files=all`
- confirm no files outside the allowed paths were changed by this goal

## Report Back

Report:

- files created or changed
- the recommended Shiny/deployment path in one short paragraph
- validation results
- current git status
- any decisions that should be escalated to Barry
- confirmation that no commit or push was performed
