# Goal 029 Pedagogy Review

## What Was Synthesized

Goal 029 synthesized the current Practical 1 Shiny design brief, the Shiny app
surface, the teaching API stage catalog, the Woodhen teaching kit, the classroom
dry-run report, and the export/fallback guidance.

The current app supports a strong app-led mission sequence:

- Start screen baseline initialization;
- Concept Lab stages for deterministic baseline, carrying capacity,
  demographic stochasticity, environmental stochasticity, genetic stochasticity,
  catastrophe, simple intervention, and extinction-vortex comparison;
- Compare screen with comparison CSV and evidence-notes downloads;
- Transfer screen linking the concept lab to the Woodhen practical.

The curriculum therefore does not need to become a heavy handout. It can use
the app as the teaching surface and use the worksheet as a small evidence log.

## Why The Chosen Sequence Works

The mission arc moves from simplest to more complex reasoning:

1. fixed baseline;
2. habitat ceiling;
3. individual chance;
4. shared bad years;
5. small-population pressure;
6. rare bad years;
7. intervention versus compounded risk.

That sequence keeps early comparisons interpretable. Students first learn what
one factor does, then learn that abundance, extinction risk, and uncertainty can
move differently. The final intervention/vortex mission gives them a bridge to
the Woodhen management practical without asking them to run real Woodhen
scenarios in Practical 1.

## How The Worksheet Supports Observation

The worksheet asks for the same four habits in every mission:

- changed assumption;
- output that moved;
- evidence used;
- caveat or uncertainty.

This structure keeps the worksheet active without turning it into lecture
notes. It also guards the assessment boundary: app exports support
interpretation but do not replace it.

## Later App-Support Gaps

No app work was done in this goal. The curriculum exposes several useful
future UI-support ideas:

- add an optional in-app mission checklist or progress label;
- make the Compare screen help students choose a clean three-run comparison;
- add a short "why this mission matters" sentence near each stage prompt;
- make duplicate reruns visually easy to spot in the comparison table;
- offer a worksheet/download link from the app when teaching materials are
  finalized;
- add an in-app reminder that zero observed extinction is not proof of safety;
- consider a short note field that can appear in evidence notes, if that does
  not turn exports into answers;
- keep Allee effects and correlated events clearly labelled as future concepts
  until an implementation goal supports them.

These are app-support candidates for a later goal only. They are not blockers
for using the current app as an app-led Practical 1 concept lab.

## Deliberately Left Out

Goal 029 did not:

- redesign assessment;
- add Practical 2 app mode;
- change the Shiny app or teaching API;
- change scenarios, science settings, model defaults, or YAML;
- create hosted-service, account, workspace, or release instructions;
- read KPZ314 materials;
- make fallback material the main teaching path.

## Recommended Next Gate

Review the mission tutorial, worksheet, and beat sheet for classroom tone and
fit. If accepted, the next useful curriculum gate would be either:

- a human read-through by Barry/demonstrators for wording and timing; or
- a later app-support goal that adds only the smallest UI/text affordances
  needed to make the mission path easier to follow in the browser.
