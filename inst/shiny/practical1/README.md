# Practical 1 Shiny App

This is the first minimum viable browser scaffold for the Practical 1 PVA
concept lab. It uses the public teaching API in `R/teaching_api.R` and base
Shiny only.

The classroom surface includes mission cues for the Goal 029 Practical 1 path:
`Start baseline` creates or restores run 1, Concept Lab asks students to change
one visible control at a time, and Compare asks for a clean baseline/risk/
intervention or vortex evidence comparison.

Students can save compact session evidence from the Compare screen:

- `practical1-comparison-YYYYMMDD.csv` contains the run comparison table.
- `practical1-evidence-notes-YYYYMMDD.md` contains settings/provenance and
  interpretation prompts. It is evidence for the report, not an answer.

The app intentionally excludes Practical 2 Woodhen scenario running,
authentication, persistent student workspaces, deployment configuration, and
arbitrary YAML editing. Those belong in later, separate goals.
