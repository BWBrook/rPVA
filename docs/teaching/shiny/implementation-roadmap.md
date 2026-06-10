# Implementation Roadmap

## Purpose

This roadmap converts the Practical 1 Shiny design spike into a staged sequence
of future implementation goals. It separates a minimum viable teaching app from
nice-to-have expansions and keeps package-code changes bounded.

## Guiding Principles

- Build the smallest app that can teach the core concepts reliably.
- Preserve the existing PVA engine as the scientific core.
- Add a thin teaching-facing API before building complex UI behaviour.
- Prefer browser-first delivery for the first student contact.
- Keep Practical 1 concept learning separate from Practical 2 Woodhen evidence
  generation until the first app is stable.
- Test with student-style clicking, not only package tests.

## Phase 1: Teaching API Adapter

Goal type: package helper implementation.

Status: completed in Goal 013.

Purpose: create the small app-facing layer that turns safe UI controls into
validated PVA runs.

Minimum outputs:

- helper to build a teaching spec from a stage and bounded controls,
- helper to run a teaching spec and return a labelled result bundle,
- helper to compare teaching runs,
- helper to create compact settings records,
- tests for each teaching stage and invalid control path.

Acceptance evidence:

- deterministic baseline reproduces a stable known result,
- each stage changes only the intended mechanism,
- invalid controls fail with clear messages,
- summaries and diagnostics are available without Shiny.

## Phase 2: Minimum Viable Practical 1 Shiny App

Goal type: Shiny implementation.

Status: completed in Goal 015, with interaction QA and hardening completed in
Goal 016.

Purpose: deliver the guided concept lab for the 2026 road test.

Minimum screens:

- start screen,
- staged concept screen,
- compare screen,
- transfer summary screen.

Minimum concepts:

- deterministic growth,
- carrying capacity,
- demographic stochasticity,
- environmental stochasticity,
- genetic stochasticity,
- catastrophe,
- simple intervention,
- combined extinction-vortex comparison.

Minimum outputs:

- run summary table,
- trajectory plot,
- summary plot,
- extinction/genetics plot when relevant,
- diagnostic messages,
- settings summary.

Deliberate exclusions from the first app:

- arbitrary YAML editing,
- full Woodhen Practical 2 workflow,
- authentication,
- complex student accounts,
- open-ended multi-factor scenario construction.

## Phase 3: Classroom QA And Browser Testing

Goal type: QA and teaching dry run.

Purpose: validate the app as students will actually use it.

Automated checks:

- package tests for the teaching API,
- Shiny launch smoke test,
- Chrome-based interaction test for the complete staged flow,
- output existence checks for plots and tables,
- download/export checks for the comparison CSV and evidence-notes files,
- regression check that the app does not write into the repo during ordinary
  use.

Manual checks:

- instructor runs the full practical from a fresh browser session,
- demonstrator follows only the student handout,
- one lower-spec laptop test,
- one Windows browser test,
- one macOS browser test,
- deliberate rapid-click and backtracking tests.

Student-style poking is especially valuable for:

- discovering confusing control labels,
- finding places where students expect immediate output but need to click run,
- testing whether zero extinction risk is misread as biological certainty,
- checking whether students compare scenarios or just admire plots,
- identifying any point where setup language leaks back into the concept lab.

## Phase 4: Deployment Road Test

Goal type: deployment/readiness.

Status: active planning lane. Goal 017 is the pre-deployment readiness package
that must settle platform, route, identity, workspace, load-test, monitoring,
fallback, rollback, cleanup, and go/no-go gates before any service changes.
Goal 018 adds a non-live ShinyProxy/Docker/nginx scaffold for review before any
remote implementation work.
Goal 019 is the local deployment-preflight pass that tightens the scaffold and
records what can be validated without writing to `deep-server`. Goal 020 proves
the x86_64 image-build path on `deep-server` and records one localhost-only
smoke. Goal 021 is the pre-live staging-gate/runbook package for a future
approved ShinyProxy/nginx/app-path staging pass. Goal 022 adds CI repair, a
local Mac mini Shiny smoke, and read-only remote staging discovery; it stops
before remote app staging because ShinyProxy is not yet installed on
`deep-server`. Goal 023 hardens the road-test product before service work by
adding compact session-local evidence downloads from the Compare flow.

Purpose: prove that the selected hosting path can survive class use.

Minimum outputs:

- deployment instructions,
- version pin or release reference,
- hosting URL,
- capacity/load-test notes,
- fallback materials,
- demonstrator recovery checklist.

Acceptance evidence:

- app loads from the student URL,
- complete Practical 1 flow runs in Chrome,
- expected concurrent-user load is tested or conservatively bounded,
- fallback static material is available,
- no local R installation is required for first-contact students.

## Phase 5: Practical 2 And Assessment Integration

Goal type: teaching integration.

Purpose: decide whether to extend Shiny into Woodhen Practical 2, assessment
exports, or both.

Possible outputs:

- Woodhen scenario runner screen,
- bounded sensitivity builder,
- exportable scenario comparison table,
- exportable selected plots,
- settings record suitable for optional AT1 artefacts,
- wording updates to Practical 2 and report scaffold.

Guardrail:

The interface should not turn AT1 into a button-click assessment. Exports should
support transparency and interpretation, not replace the report.

## Minimum Viable Teaching App

The minimum viable teaching app is successful if a student can:

1. open the app in a browser,
2. run the deterministic baseline,
3. add one mechanism at a time,
4. compare at least three runs,
5. explain extinction probability, median abundance, and uncertainty,
6. recognise why small-population risk can be compounded,
7. leave ready to run the Woodhen Practical 2 workflow.

It does not need to:

- let students build arbitrary species,
- edit YAML,
- save accounts,
- run every Woodhen scenario,
- support open-ended modelling beyond bounded teaching controls.

## Nice-To-Have Expansions

After the road test, consider:

- a sandbox mode for advanced students,
- Practical 2 Woodhen app mode,
- export bundles for report artefacts,
- instructor dashboard for common misunderstandings,
- optional local Shiny launch instructions,
- richer explanation panels,
- accessibility review,
- anonymised usage analytics if approved.

## Risks To Manage

- Overbuilding before the teaching path is tested.
- Letting UI convenience hide scientific assumptions.
- Making hosted Shiny the only path without a fallback.
- Treating app outputs as assessment answers rather than evidence to interpret.
- Allowing long-running simulations to create classroom dead time.
- Expanding to Woodhen before the concept lab is stable.

## Recommended Next Goal

The next bounded implementation goal should follow review of Goal 023 evidence
export hardening. If the local road-test path is accepted, use a separate
service-bootstrap/staging goal to install or configure the missing ShinyProxy
layer before any non-student app URL is exposed. Keep deployment work separate
from app pedagogy, Practical 2 Woodhen content, and future research-grade Lord
Howe Island woodhen recovery analysis.
