# Practical 1 Shiny App

This is the browser scaffold for the Practical 1 PVA concept lab. It uses the
public teaching API in `R/teaching_api.R` and base Shiny only.

The classroom surface opens with a local-first landing/tutorial screen:
students get a plain-language PVA introduction, a short mission preview, and a
clear evidence prompt before touching model controls. The `What is PVA?` card
has an optional `Explore PVA` deep-dive so students can read more without
turning the landing screen into a manual page. Its teaching text lives in
`content/pva-deep-dive.md` so it can be edited without changing Shiny code.
If the key concepts are rewritten, update the focused Shiny test at the same
time. `Start baseline` creates or restores baseline as run 1, Concept Lab asks
students to change one visible control at a time, and Compare asks for a clean
baseline/risk/intervention or vortex evidence comparison.

Students can save compact session evidence from the Compare screen:

- `practical1-comparison-YYYYMMDD.csv` contains the run comparison table.
- `practical1-evidence-notes-YYYYMMDD.md` contains settings/provenance and
  interpretation prompts. It is evidence for the report, not an answer.

The app intentionally excludes Practical 2 Woodhen scenario running,
authentication, persistent student workspaces, deployment configuration, and
arbitrary YAML editing. Those belong in later, separate goals.
