# Goal 047: Markdown-backed landing card modals

## Objective

Extend the Practical 1 landing-screen deep-dive pattern to the remaining two landing cards:

- `What you will do`
- `Your evidence pack`

Each card should have a visible accessible button and a Markdown-backed modal body so Barry can edit all three landing-panel notes without changing Shiny code.

## Accepted Source State

- Base: Goal 046 commit `b9a55c194f8b15cb3c85fb4e27150f81f92ac293`.
- Branch: `codex/rpva-goal047-landing-card-modals`.
- Carry forward Barry's pre-existing local edit to `inst/shiny/practical1/content/pva-deep-dive.md`.

## Scope

Allowed:

- Practical 1 Shiny app code, CSS if needed, app README, content Markdown, focused tests, and this Goal 047 record.
- Two new app-local Markdown files under `inst/shiny/practical1/content/`.
- Small helper generalization for the existing Markdown modal pattern.

Not in scope:

- Science/model/YAML/default/export-shape changes.
- Practical 2, KPZ314, assessment redesign, deployment, ITS/Gitea/stochastic, Docker/image, Moodle, student-release, or remote service work.
- Commits, pushes, pull requests, or publication.

## Success Criteria

- The existing PVA modal remains Markdown-backed and Barry's wording edits are preserved.
- The mission and evidence landing cards each open readable Markdown-backed modals.
- The cards remain concise and uncluttered.
- Start baseline, Introduction return, Compare, CSV export, and evidence-notes export still work.
- Student-facing modal content stays Practical 1 concept-lab focused, with no thylacine or Woodhen case-study detail.
