# Goal 045: Practical 1 PVA Deep-Dive Card Prototype

## Objective

Prototype exactly one optional landing-panel deep-dive for the Practical 1
Shiny landing screen: the `What is PVA?` card. The aim is to test whether a
short landing card plus a richer in-app explanation is useful before expanding
the pattern to other cards.

## Accepted Boundaries

- Work locally in `/Users/bwbrook/git/rPVA`.
- Keep the visible landing card short and inviting.
- Make only the `What is PVA?` card openable in this pass.
- Use a rewritten student-facing explanation drawn from repo-local teaching
  material, not raw practitioner notes.
- Preserve the baseline-as-run-1 flow and the Concept Lab `Introduction`
  return.
- Preserve model science, YAML/defaults, export shapes, Practical 2/KPZ314,
  deployment, ITS/Gitea/stochastic, Moodle, student-release, and remote-service
  boundaries.
- Leave the result uncommitted for orchestrator review.

## Deliverables

- Practical 1 Shiny UI/server/CSS change for one accessible deep-dive.
- Focused Shiny test coverage for the deep-dive trigger/content.
- Narrow app README note.
- Local browser smoke evidence and screenshots under `/tmp`.
- This goal packet and closeout report.
