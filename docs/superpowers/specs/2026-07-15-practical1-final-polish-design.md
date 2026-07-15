# Practical 1 Final Polish Design

Date: 2026-07-15
Status: approved in design review
Target class: KPZ308, Monday 2026-07-20

## Objective

Finish the KPZ308 Practical 1 Shiny GUI as a dependable first encounter with
population viability analysis. The release should help a novice complete a
minimum useful pathway while giving confident students substantial room to
explore. It must be ready for immutable-image promotion and live classroom use
before Monday 20 July.

Practical 1 is an orientation and evidence-literacy exercise. Deeper Woodhen
management reasoning, assessment preparation, and persistent evidence trails
belong in Practical 2.

## Classroom Context

The practical occupies a three-hour class:

- approximately one hour of PVA teaching and GUI introduction;
- approximately two hours of guided, self-paced app work; and
- an instructor circulating to answer questions rather than advancing the
  whole room through fixed checkpoints.

The primary device is a student laptop. The design should be accepted at
1366x768 and 1440x900. Narrow screens remain usable but are not the primary
layout target.

## Release Boundary

This is a targeted novice-flow release pass. It may change Practical 1 app
navigation, presentation, session state, evidence selection, exports, tests,
and directly associated teaching prose.

It must not change:

- PVA science, scenario defaults, seeds, or expected model outputs;
- the public teaching API contract unless a narrowly compatible export helper
  change is required;
- Practical 2 behaviour, image, workspace, or Staff-only production access;
- authentication, ShinyProxy identity, network, resource limits, or workspace
  mounts; or
- the current static fallback and rollback arrangements.

The existing visual identity, imagery, top navigation, and teaching-help
content remain. This is not a cosmetic rewrite or a new application.

## Student Journey

The four top-level screens remain:

1. **Start** - orient the student and explicitly create baseline run 1.
2. **Concept Lab** - complete the core route, then optionally explore further.
3. **Compare** - curate a three-run evidence set, interpret it, and download
   evidence.
4. **Transfer** - confirm the evidence requests and bridge briefly to
   Practical 2.

All screens and missions remain accessible. Progress cues guide students but
do not lock navigation.

## Core And Extension Routes

The Concept Lab uses one grouped mission rail.

### Core Route

Students are asked to complete these first:

1. Baseline compass - deterministic baseline.
2. Island ceiling - carrying capacity.
3. Individual chance - demographic stochasticity.
4. Shared bad years - environmental stochasticity.
5. Rescue attempt - intervention.
6. Compare, interpret, and request both evidence downloads.

The first five items are model missions. Compare and export are the completion
destination rather than another modelling stage.

### Explore Further

These missions remain visible and available from the outset:

- Small-population pressure - genetic stochasticity.
- Rare bad years - catastrophe.
- Vortex comparison - extinction vortex.
- Advanced controls within the relevant mission.
- Alternative selected comparisons and optional plot downloads.

The extension route is visually secondary but never hidden, locked, or framed
as unimportant.

## Progress Behaviour

Progress is session-only and deliberately soft:

- a mission receives a completion tick only after a successful run;
- the active mission and recommended next core action are prominent;
- completed stages remain clickable;
- extension missions remain clickable at all times; and
- no tab or mission is disabled by incomplete progress.

The app currently preloads a baseline result on server start. That internal
reference must not mark baseline complete. Baseline completion requires the
student to press **Start baseline**.

Progress, run history, selections, and interpretation are not restored after a
refresh, closed tab, expired Shiny session, or released ShinyProxy container.

## Screen Design

### Start

Retain the current PVA Basics landing experience, imagery, baseline action,
mission preview, and three Markdown-backed deep dives. Add a concise session
notice:

> This session is temporary. Download your comparison CSV and evidence notes
> before closing the app.

The notice should be visible but not styled as an error.

### Concept Lab

Use a stable two-column laptop layout:

- the left column answers "What should I do next?" with grouped missions,
  active-stage framing, controls, Run mission, and contextual control help;
- the right column answers "What changed?" with current results, key metrics,
  plots, diagnostics, output help, plot help, and the next-action cue.

After a successful run, show a compact mission-complete cue and recommend the
next incomplete core stage. The cue does not navigate automatically.

The current settings table, diagnostics, plots, advanced controls, and plot
downloads remain available. Dense secondary material may be collapsed or
visually subordinate, but it must not be removed.

### Compare

Separate two concepts that are currently conflated:

- **Session history** contains every successful run in order.
- **Selected evidence** contains exactly three runs used for cards, CSV, and
  Markdown notes.

The left side lists session runs with run number, mission label, changed
settings, category, and evidence-selection control. The right side shows the
selected evidence cards, readiness checklist, interpretation field, download
controls, and an Explore Further return cue.

### Transfer

Keep the Practical 2 bridge short. Add a final session checklist showing
whether both evidence download requests occurred and repeat the temporary
session notice. Do not add Practical 2 case-study depth here.

## Contextual Learning Tools

The polish pass must retain and verify all existing contextual affordances:

- Explore PVA;
- Explore mission;
- Explore evidence;
- Introduction;
- Control help;
- Read outputs;
- Read diagnostics;
- Read plots;
- advanced risk controls;
- diagnostics;
- comparison habits and prompts; and
- plot downloads.

Place contextual actions beside the control or result they explain. Primary
actions should dominate visually, contextual help should remain immediately
available, and advanced material should read as optional.

## Session And Evidence State

Each successful run receives a session-unique run ID. The session state keeps:

- complete ordered run history;
- unique successfully completed stages;
- three selected evidence run IDs;
- interpretation text and whether it matches the current selection; and
- whether CSV and Markdown download requests have occurred.

This state remains in memory only. The existing per-student server workspace
mount is not used for Week 1 restoration.

## Evidence Selection

The selected evidence set contains exactly:

1. baseline, selected and pinned;
2. one risk mechanism; and
3. one intervention or vortex run.

Eligible risk stages are carrying capacity, demographic stochasticity,
environmental stochasticity, genetic stochasticity, and catastrophe.

When eligible runs exist, Compare selects the latest suitable risk and
intervention/vortex runs. Students may substitute any eligible attempt,
including extension work. Duplicate stage attempts remain distinguishable by
run number and changed settings.

CSV and Markdown exports use selected evidence only. The notes record that
three runs were selected from the larger session history and retain selected
settings, provenance, interpretation, and caveat text. The full session history
is visible during the session but is not included in the minimum evidence pack.

## Save Gate

The download controls remain unavailable until:

- baseline is present;
- one eligible risk run is selected;
- one intervention or vortex run is selected; and
- the interpretation field is nonblank.

The readiness checklist must identify each missing requirement directly. It
must not use a generic validation error.

If a student changes selected runs after writing an interpretation, preserve
the text, mark it **Review required**, and pause downloads until the student
edits or explicitly reconfirms it. This prevents an interpretation from being
silently attached to different evidence.

The app can confirm that a download request reached its handler. It cannot
guarantee where the browser saved the file. UI text should therefore say
**Download requested** rather than **Evidence saved**.

The minimum evidence pack is:

- one selected-comparison CSV; and
- one selected evidence-notes Markdown file.

Plot PNGs remain optional extension evidence.

## Failure And Recovery Behaviour

- Disable the active Run mission control while its model call is running to
  prevent accidental duplicate clicks.
- A failed model call creates no history entry or completion tick. Show a
  concise inline failure message and allow immediate retry.
- Missing or invalid evidence selection updates the readiness checklist and
  does not discard runs or interpretation.
- Missing Markdown help should produce a readable unavailable-help message,
  not a broken modal or app failure.
- Resetting after additional runs requires confirmation. State explicitly that
  run history, evidence selection, interpretation, and in-session progress will
  be cleared.
- Context-help actions, advanced controls, diagnostics, and plot downloads do
  not affect mission completion.
- Refresh and close recovery relies on locally downloaded artifacts; automatic
  session restoration is deferred to Practical 2.

## Accessibility And Responsive Behaviour

- All interactive controls must be reachable by keyboard with visible focus.
- Icon buttons require accessible names or tooltips.
- Core and extension status must not depend on colour alone.
- Text, controls, metrics, and tables must not overlap at 1366x768 or
  1440x900.
- The main layout may stack on narrow screens, but mission controls and export
  actions must remain usable.
- Dynamic labels, completion states, and validation messages must not resize
  fixed-format controls unexpectedly.
- Existing colour and typography should be refined for hierarchy and contrast,
  not replaced with a new visual theme.

## Verification

### Focused Automated Tests

Extend Practical 1 tests to cover:

- exact Core and Explore Further membership and order;
- baseline completion only after explicit student action;
- successful-run ticks and failed-run non-completion;
- duplicate attempts and unique run IDs;
- smart evidence defaults;
- exactly three selected evidence runs;
- category validation and pinned baseline;
- interpretation review after selection changes;
- selected-only CSV and Markdown exports;
- download-request state;
- reset confirmation and state clearing;
- missing-help fallback; and
- retention of every existing contextual-help action.

Existing API and scientific-output assertions must continue to pass unchanged.
Run the focused Practical 1 test file and the full test suite before image
publication.

### Browser Acceptance

Exercise two complete routes:

1. **Minimum-success student:** complete all five core model missions, create a
   valid three-run evidence set, write an interpretation, request both
   downloads, and reach Transfer.
2. **Extension student:** run genetics, catastrophe, vortex, advanced controls,
   duplicate attempts, substitute extension evidence, revise interpretation,
   and download an optional plot.

At 1366x768 and 1440x900, verify:

- readable hierarchy and no overlap;
- stable navigation and controls;
- keyboard focus and modal behaviour;
- all contextual-help affordances;
- complete session-history display;
- selected evidence cards and readiness gate;
- CSV with exactly three selected rows and no missing required values;
- Markdown settings and interpretation matching the selected CSV;
- temporary-session notices on Start, Compare, and Transfer; and
- no browser console errors, warnings, or page exceptions.

Run a narrow-screen smoke as a secondary guardrail.

## Release Sequence

1. Implement and iterate locally.
2. Complete automated, browser, export, accessibility, and visual acceptance.
3. Freeze source behaviour and teaching text before image build.
4. Commit and synchronize a clean source revision.
5. Build one immutable `linux/amd64` Practical 1 image and record source
   revision and registry digest.
6. Promote the image to dev on Saturday 18 July and complete the full Staff
   workflow and export checks.
7. Promote the exact accepted digest to production on Sunday 19 July.
8. Repeat Staff acceptance and, if available, one KPZ308 student launch and
   download check.
9. Make no deployment change on Monday 20 July unless responding to a verified
   incident.

The current production image
`git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-20260713-02b09aeed4f0`
and the pre-change production configuration remain the immediate rollback
target. Practical 2 remains deployed and Staff-only throughout.

## Acceptance Criteria

The polish release is complete when:

- a novice can identify and finish the required Core route without instructor
  navigation;
- a confident student can find substantial extension work without bypassing a
  hard lock;
- every existing contextual learning tool remains available and tested;
- progress is helpful, session-only, and accurately derived from successful
  runs;
- selected evidence is exactly baseline + risk + intervention/vortex;
- both required downloads are gated by valid evidence and interpretation;
- session-loss consequences are stated clearly;
- exports are internally consistent and sufficient for later re-examination;
- laptop browser acceptance and the full automated suite pass;
- the same immutable image digest passes dev and production acceptance; and
- rollback can restore the current production image and configuration quickly.

## Deferred Work

The following are intentionally deferred:

- automatic server-side session saving and restoration;
- a student-accessible workspace file browser;
- Week 2 evidence-trail persistence and provenance history;
- deeper Woodhen pedagogy and assessment scaffolding;
- telemetry or classroom analytics; and
- any Practical 2 content refinement.
