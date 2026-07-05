# Goal 046: Markdown-Backed Practical 1 Modal Content

## Objective

Refactor the accepted `What is PVA?` Practical 1 landing deep-dive so its
student-facing body text is loaded from an app-local Markdown file instead of
being hard-coded in `app.R`.

## Boundaries

- Preserve the Goal 045 visible behaviour: `Explore PVA` trigger, modal title,
  close action, and one-card-only prototype scope.
- Keep `app.R` responsible for layout, modal mechanics, and safe rendering.
- Keep teaching text in `inst/shiny/practical1/content/pva-deep-dive.md`.
- Do not substantively rewrite the student-facing PVA content.
- Do not add dependencies, images, remote/deployment changes, science/model/YAML
  changes, Practical 2/KPZ314 work, assessment redesign, Docker/image work,
  Moodle/student-release work, commits, pushes, or PRs.

## Deliverables

- Markdown-backed `What is PVA?` modal.
- Focused Shiny test proving the content file and app wiring.
- Practical 1 app README note for Barry editing the Markdown text.
- Browser smoke evidence under `/tmp`.
- This goal packet and report.
