# Classroom Dry-Run Checklist

Use this checklist on the teaching machine before the Woodhen road-test session.
It is written for demonstrators checking the student workflow.

## Before Students Arrive

- Launch the installed app with `rPVA::run_practical2_shiny()`.
- Confirm the six tabs appear in this order: Start, Calibrate, Investigate,
  Compare, Evidence Studio, and Assessment Task.
- Confirm the app opens at a classroom desktop size without horizontal page
  scrolling or clipped controls.
- Create a fresh staff project for the empty and partial-project checks.
- Open a representative validated project containing historical, sensitivity,
  threat-management, note, plot, and table evidence.
- Keep the Practical 2 student guide, expected scientific interpretation, and
  fallback materials available.

## Start And Project Checkpoints

- A new project can be created with a title and owner label.
- Browser recovery and explicit Resume leave a valid project available after a
  refresh.
- A downloaded project ZIP can be imported in another clean session.
- Invalid restore or import input leaves the live project unchanged and gives a
  visible status message.

## Calibrate Checkpoints

- Students can run the supplied historical reconstruction.
- The historical displays distinguish model output from observations.
- Students can explain what agreement supports, why reconstruction is a
  plausibility check, and what independent validation would require.
- Students can establish the common no-change future baseline.
- Notes and relevant model-generated evidence can be saved for later use.

## Investigate Checkpoints

- Students can run a three-setting one-factor sensitivity family containing the
  no-change baseline plus one higher and one lower value for the same named
  ecological factor.
- The interface keeps other settings matched and makes the changed factor clear.
- Students can run at least one matched no-change baseline, threatened future,
  and managed threatened future comparison.
- Students can state the threat mechanism, management response, expected
  direction, observed effect, uncertainty, and important caveat.

## Compare Checkpoints

- Historical, sensitivity, and future comparison families open from saved runs.
- Like-for-like plots and tables identify the compared family and relevant
  horizon.
- Abundance, extinction risk, timing, and uncertainty are readable where
  relevant.
- Plot, table, and student-authored note evidence can be added to the Evidence
  Portfolio with provenance.

## Evidence Studio Checkpoints

- The Evidence Portfolio retains the broad saved working record.
- Students can preview, reorder, and remove portfolio items.
- **Include in this export** creates a separate session-local dossier selection.
- Students can select and order a smaller set of source material without
  removing omitted items from the portfolio.
- **Export selected evidence** downloads one ZIP containing
  `evidence-dossier.docx`, numbered PNG companions for selected plots, and
  numbered CSV companions for selected tables.
- The dossier preserves selected order, provenance, model-generated displays,
  and student-authored notes.
- The dossier remains source material; students supply the report
  interpretation, recommendation, captions, and references.

## Assessment Task Checkpoints

- Confirm Assessment Task is readable with no project loaded.
- Load the representative project and confirm the project-aware neutral summary
  reports available evidence without readiness or completion judgements.
- Confirm the exact ILO wording and exact C1-C4 wording and marks match the
  approved assessment contract.
- Confirm Assessment Task does not score work.
- Confirm Assessment Task does not generate submission prose.
- Confirm Assessment Task does not impose quotas.
- Use its buttons to return to Calibrate, Investigate, Compare, and Evidence
  Studio.
- Confirm navigation and visiting Assessment Task leave project content
  unchanged.
- Confirm the MyLO reminder is visible for official administrative details.

## Responsive And Accessibility Checkpoints

- At the principal classroom desktop resolution, confirm all six tabs, evidence
  controls, criteria, and navigation actions are readable.
- At `390 x 844`, confirm the tab navigation remains usable, long ILO and C1-C4
  wording wraps, and content does not overlap or disappear.
- Use keyboard navigation to reach the main actions, expandable guidance, and
  dossier controls.
- Confirm empty-state and project-aware status messages are readable and
  announced appropriately.

## Demonstrator Triage

- If project recovery fails, use an explicitly downloaded project copy.
- If a run fails, preserve the current project, retry once, and use the fallback
  evidence pack if the failure persists.
- If plots appear blank, confirm the selected comparison has completed source
  runs before changing display settings.
- If a student treats zero simulated extinctions as proof of safety, redirect
  attention to simulation count, uncertainty, horizon, and unmodelled
  ecological processes.
- If a dossier download fails, preserve the portfolio and project copy, retry
  once, and record the browser and visible error message for follow-up.
