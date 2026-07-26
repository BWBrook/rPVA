# Practical 2 Woodhen Management Lab Design

Date: 2026-07-21
Status: design approved; written specification awaiting final review
Target: KPZ308 Practical 2 and Assessment Task 1 preparation

## Objective

Build the full KPZ308 Practical 2 Shiny application as a historically grounded
Woodhen investigation and evidence environment. Students should recognise the
interaction patterns established in Practical 1, but encounter a more open
research workspace in which they:

1. test whether the supplied model adequately reconstructs the historical
   management story;
2. establish a locked present-day baseline for future inference;
3. complete a bounded sensitivity analysis;
4. compare a plausible future threat with at least one intervention; and
5. assemble a selective, reproducible evidence dossier for a conservation
   advice report.

The app must support a three-hour classroom route that supplies the minimum
defensible evidence base. It must also remain useful throughout the independent
report-writing period, when stronger students can pursue systematic sensitivity
work, alternative interventions, temporal dynamics, compound threats, and
multi-factor management portfolios.

The app is an evidence studio, not a report generator or submission system.

## Pedagogical Contract

Practical 2 uses a two-act structure.

### Act 1: Calibrate Understanding Against History

Students run and interpret the supplied Woodhen reference scenarios. These
scenarios are anchored to the real case study, tuned to reproduce historically
meaningful patterns, and form the common evidence base for the class.

The student is not expected to alter or rebuild this model. Their task is to
show that they understand:

- the Woodhen decline and management problem;
- the biological and stochastic processes represented;
- the effects of the historical management choices;
- the meaning of the model outputs and uncertainty; and
- why historical agreement supports, but does not prove, fitness for future
  exploratory inference.

### Act 2: Advise From The Present

Students act as present-day conservation advisers. Every future investigation
branches from the same locked 2025-2100 Woodhen specification. Students use
that shared anchor to:

- identify an influential assumption or ecological driver through sensitivity
  analysis;
- construct a plausible future threat;
- test at least one corresponding management intervention; and
- explain how the evidence affects their recommendation and confidence.

The minimum route is intentionally sufficient for a passing submission but no
more. Higher achievement should arise from better reasoning, selection,
systematic analysis, ecological justification, treatment of uncertainty,
background research, and communication rather than from software mechanics.

## Locked Assessment Constraints

The report is approximately 2,000 words. Display items and references are
excluded from that limit. More analysis or prose is not inherently better;
students must select evidence that earns its place in a finite report.

The following assessment criteria wording is locked and must be reproduced
verbatim wherever the criteria are shown:

| Criterion | Marks | Assessment Criteria |
| --- | ---: | --- |
| C1 | 5 | Describe the uses and limitations of simulation modelling in conservation decision-making. |
| C2 | 6 | Model stochastic processes and causes of threat. |
| C3 | 8 | Undertake scenario testing to compare the relative effectiveness of alternative management options. |
| C4 | 6 | Translate simulation results and communicate them as conservation recommendations. |

The app may explain what evidence could address these criteria. It must not
estimate marks, promise bands, score student progress, or mechanically enforce
report compliance.

## Student-Facing Language

Student copy must be precise without using specialist shorthand merely because
it is convenient for developers or instructors.

In particular:

- use **reference Woodhen scenarios**, not **canonical scenarios**;
- use **locked future baseline**, not **base spec**;
- explain **historically grounded** and **fit for exploratory inference** in
  context;
- introduce technical ecological and modelling terms when students need them,
  with concise definitions or contextual help; and
- avoid both unexplained jargon and oversimplified conversational language.

The audience is a technically capable third-year undergraduate cohort, not a
novice general-public audience.

## Primary Student Journey

Practical 2 reuses Practical 1's approved visual language, navigation rhythm,
contextual-help approach, evidence comparison patterns, and restrained layout.
It replaces Practical 1's guided concept missions with five primary tabs.

### 1. Start

The Start tab:

- frames the student as a present-day Woodhen conservation adviser;
- explains the two-act investigation;
- shows the three-hour core route;
- allows creation, resumption, or import of a project;
- distinguishes local browser recovery from a downloaded portable project;
- states that completing the interface mechanically supplies only the minimum
  evidence base; and
- introduces **Ways to deepen your investigation**.

All investigation areas remain visible. Progress guidance is soft and does not
lock tabs or prevent ambitious students from looking ahead.

### 2. Calibrate

The Calibrate tab presents a chronological historical audit rather than one
flat table of scenarios with incompatible horizons.

#### 1980 crisis and management alternatives

Students run and directly compare the common 40-year cases:

- no intervention;
- pig control; and
- captive breeding plus pig control.

These form a valid relative-management comparison because their decision point,
starting context, and horizon are shared.

#### 2019-2024 recovery check

Students run the short rodent-eradication recovery scenario and compare its
simulated response with the supplied observed historical milestone. The app
must label this as a short-horizon historical check, not rank it naively against
the 40-year cases.

#### 2025 future anchor

Students run the 75-year no-change future case. This establishes the locked
future baseline used by every sensitivity and prospective scenario in Act 2.

The tab presents observed history, reference settings, model outputs,
uncertainty, horizon differences, and concise interpretation prompts. Students
run every reference scenario themselves.

### 3. Investigate

The Investigate tab contains two coordinated workspaces.

#### Sensitivity workspace

Every student must:

- choose one named ecological factor;
- run at least three settings in total, including the locked future baseline
  and one numerically higher plus one lower altered value;
- use the same starting population, horizon, replicate count, seed, and all
  other model settings;
- examine the response across the selected settings; and
- retain the settings and results for comparison and export.

The permitted ranges are deliberately wide bounded exploratory assumptions so
students can reveal model response. They are not empirical forecasts, and the
app must not imply that every allowed value is equally realistic.

The app prompts, but does not require, a research question, biological reason,
expected direction, interpretation, and caveat before or after the run.

Deeper work may add settings, examine thresholds, test another factor, validate
with additional seeds, or compare one-factor patterns before building a
multi-factor scenario.

#### Future scenario workspace

Every student must build at least one explicit comparison family:

1. locked future baseline;
2. plausible future threat derived from that baseline; and
3. at least one intervention applied to the threatened future.

The main controls use named Woodhen-relevant threats and interventions. An
advanced layer reveals their model mapping, bounded numeric intensity, onset,
and temporal profile.

Students may extend a family with:

- alternative intervention intensities;
- early versus delayed action;
- step versus gradual changes;
- multiple interventions;
- compound threats; or
- multi-factor management portfolios.

Multi-factor work is permitted and encouraged when justified. It is explicitly
labelled as multi-factor, and all contributing changes remain visible.

### 4. Compare

The Compare tab adapts Practical 1's evidence workspace to longer, persistent
investigations.

It distinguishes:

- the complete project run library;
- named sensitivity and prospective comparison families;
- selected evidence under active comparison; and
- observations and caveats written by the student.

Students can:

- filter and search runs;
- select scenarios with compatible baselines and horizons;
- compare extinction risk, quasi-extinction risk, abundance, uncertainty, and
  timing;
- inspect trajectory, distribution, risk, and response plots;
- record multiple comparison-linked observations;
- nominate evidence for the dossier; and
- see warnings when a proposed comparison is scientifically awkward.

The full run library must not dominate the screen. The active evidence and
comparison should receive the most visual space.

### 5. Evidence Studio

The Evidence Studio supports deliberate evidence selection and independent
report preparation.

Students can:

- review coverage of the required evidence categories;
- select tables, plots, settings, notes, and comparisons;
- preview a structured evidence dossier;
- download the dossier as Word;
- download CSV tables, figures, and a Markdown companion;
- download or import the portable project package;
- read the locked criteria and concise report-development guidance; and
- review ways to deepen the investigation.

Missing evidence produces specific advice but never blocks export. The app does
not generate captions, recommendations, report prose, or a completed report
structure.

## Reference Scenario Model

Reference Woodhen scenarios are immutable within the student interface and
versioned with the app.

They comprise:

- `01_no_mgmt`;
- `02_pig_control`;
- `03_captive_pig`;
- `04_rodent_eradication`; and
- `05_future_baseline`.

The current scenario sources remain the scientific starting point. Any future
scientific correction to a reference scenario requires a deliberate versioned
change, regenerated reference outputs, and explicit regression review. A
student project records which reference-scenario library version it used.

## Locked Future Baseline

Every Act 2 experiment branches from the same no-change 2025-2100 future
specification:

- the supplied 2024 starting stage vector;
- 75 projection years;
- 1,000 simulation futures;
- the common comparison seed;
- the supplied recovered-population survival and fecundity rates;
- the supplied habitat ceiling and variability;
- the supplied catastrophe, environmental, and genetic settings; and
- the same stage structure and model processes.

Students cannot change the starting population, stage structure, horizon,
replicate count, or primary comparison seed in an ordinary sensitivity or
prospective scenario.

An advanced validation action may rerun a completed comparison using another
seed or a larger replicate count. Such a run is labelled as a robustness check,
not treated as a different ecological scenario.

## Scenario Construction Model

Every student-created scenario is a transparent, versioned set of changes from
the locked future baseline or from a named threatened future.

A scenario record includes:

- project and run identifier;
- student-facing scenario name;
- scenario type and parent identifier;
- threat and intervention components;
- exact changed model fields;
- anchored preset or bounded custom value;
- temporal profile and onset;
- seed and replicate count;
- reference-scenario and model versions;
- student notes, if supplied;
- creation and modification timestamps; and
- a deterministic fingerprint of the runnable specification.

Editing a completed scenario creates a new version. It never silently mutates a
run that has already been compared, annotated, or selected as evidence.

## Threat And Intervention Catalogue

The first release provides the following named idea seeds.

### Threats

- **Novel disease:** bounded reductions in relevant stage-specific survival or
  reproduction.
- **Habitat contraction or degradation:** reduced breeding-territory capacity
  or habitat quality.
- **Sea-level rise pathway:** progressive lowland habitat contraction or
  degradation associated with inundation and saline intrusion; this is a
  biologically explicit habitat-loss pathway, not an independent abstract sea-
  level parameter.
- **Increased cyclone pressure:** altered catastrophe frequency, survival
  severity, or reproductive effect.
- **Invasive-predator reinvasion:** reduced juvenile survival or recruitment,
  with advanced compound effects permitted when justified.
- **Chronic environmental variability:** increased temporal variation in
  demographic or habitat conditions.

### Interventions

- **Habitat protection or restoration:** recover or protect breeding-territory
  capacity or habitat quality.
- **Strengthened biosecurity or renewed eradication:** reduce or reverse
  reinvasion effects.
- **Targeted survival or breeding improvement:** improve the affected life-
  history component within defensible bounds.
- **Captive breeding and supplementation:** add a transparent release schedule.
- **Emergency response:** buffer catastrophe losses through a supported,
  explicitly defined management action.

Each catalogue entry must define:

- plain-language biological meaning;
- the exact model parameters affected;
- low, moderate, and severe or intensive anchors;
- a bounded custom range;
- allowed temporal profiles;
- interpretation guidance;
- limitations and processes not represented; and
- source or rationale for the bounds.

The initial numeric anchors are derived from the existing Woodhen sensitivity
cases and biologically valid model ranges. No anchor is presented as an
empirical estimate unless a source supports that claim.

## Temporal Profiles

The compulsory route uses an immediate, persistent change across the future
horizon.

Advanced controls allow:

- a bounded onset year;
- an immediate step change;
- a gradual change from onset to an end year; and
- an intervention beginning before, with, or after the threat.

Students cannot supply arbitrary year-by-year values or executable schedules.
The app generates validated annual parameter profiles from the selected shape.

The simulator extension must accept annual profiles for supported ecological
parameters while preserving the existing scalar path exactly when profiles are
absent. Existing reference outputs and Practical 1 behaviour must therefore
remain unchanged.

## Scientific Outcomes

Every completed run returns and records:

- extinction probability by the end of the horizon;
- extinction timing evidence when extinctions occur;
- probability of crossing the primary quasi-extinction threshold;
- first-passage timing to that threshold;
- final median abundance and uncertainty interval;
- abundance and uncertainty trajectories;
- selected trajectory evidence;
- diagnostic messages;
- complete settings and provenance; and
- difference from the appropriate baseline or threatened parent.

### Primary quasi-extinction threshold

The common future management threshold is **strictly fewer than 100
territory-holding breeding pairs**. This threshold is calculated from the
model's territory-holding stages rather than from total birds. It is
approximately the population scale that preceded rodent eradication, but
historical survey totals and the modelled breeding-pair proxy are different
measures. It is therefore not a direct conversion of a past census.

The value is a working management-warning reference chosen to provide
information before complete extinction. It is not a universal minimum viable
population or a proven biological tipping point.

The app reports:

- probability of falling strictly below 100 pairs by 2100;
- cumulative threshold-crossing probability through time;
- the first-passage-time distribution;
- median first-passage year among futures that cross the threshold, explicitly
  labelled as conditional; and
- an overall median time only when at least half of all simulated futures cross
  the threshold; otherwise it reports **overall median not reached**.

Students may inspect a wider quasi-extinction threshold curve, but the 100-pair
result remains the shared reference metric.

## Plots And Comparison Displays

The app carries forward the strongest Practical 1 visual evidence patterns and
adds investigation-specific displays.

Required plot families are:

- population trajectory samples and yearly summaries;
- cumulative 100-pair warning risk, with extinction retained in result tables;
- first-passage-time distribution;
- final abundance distribution and interval;
- sensitivity response across settings; and
- compact baseline-threat-intervention comparison.

Plots must clearly state population units, horizon, replicate count, scenario
identity, and whether a timing statistic is conditional. Investigate plots
emphasize the more informative 100-pair warning risk; complete extinction
remains available in result tables because it is generally sparse or zero under
the bounded scenarios. Warning-risk displays must remain meaningful when no or
few simulated futures cross the threshold.

## Project State And Portability

The portable student-held project is the cross-host source of truth.

### Browser-local recovery

The app maintains a local browser autosave for crash, refresh, and tab recovery
on the current device and host. IndexedDB or an equivalently capable browser
store should be used rather than relying on the small `localStorage` quota.

Browser recovery is origin-specific. State saved under the SSO host is not
automatically visible under the off-campus host, even on the same laptop.

The interface must distinguish:

- **autosaved in this browser**; and
- **portable project downloaded**.

It displays whether material changes have occurred since the last portable
download and reminds students to export before leaving or changing host.

### Portable project package

Students can download the project to their laptop and import it into either the
SSO application or the off-campus application. The package is the supported
route for changing host or browser.

The package contains validated structured data, including:

- manifest and schema version;
- project metadata;
- scenario definitions and version history;
- derived run results needed for comparison and evidence;
- notes and evidence selections;
- reference-scenario, app, and model versions; and
- export/import provenance.

It excludes executable R, YAML overrides, arbitrary HTML, scripts, full raw
trajectory arrays, and unrelated user files.

Import must enforce a compressed and expanded size limit, reject path traversal
or unrecognised content, validate all scenario fields, and preserve original
project and run identifiers. An imported project remains distinguishable from
new runs created after import.

### Identity-light provenance

The portable project does not require a student identity.

Provenance uses:

- unique project and run identifiers;
- creation and modification times;
- app, model, and scenario-library versions;
- import and export history;
- parent-child scenario relationships; and
- exact changed settings.

A project title or owner label is optional. The normal assessment submission
system, not this app, establishes authorship.

The non-SSO server need not retain project data after the browser session ends.
Server-side SSO workspaces may remain an operational convenience but cannot be
required for resumption or portability.

## Stored Result Boundary

Projects retain enough derived evidence for comparison, reloading, and dossier
generation without accumulating large raw simulation objects.

Stored evidence includes:

- scenario specification and fingerprint;
- primary summary and diagnostic records;
- yearly trajectory summaries;
- a bounded sample of trajectories;
- final abundance values or a compact distribution record;
- extinction and 100-pair first-passage evidence;
- sensitivity response values; and
- selected plot-ready data.

The exact run remains reproducible from its specification and seed. Full raw
simulation objects are session scratch and may be discarded after derived
evidence is created.

## Evidence Dossier

The Word dossier is the primary human-facing export. Markdown remains a useful
transparent companion, while CSV and image files support reuse and checking.

The dossier contains:

1. project and model provenance;
2. Act 1 historical calibration evidence;
3. the compulsory sensitivity settings, response plot, and results;
4. the baseline-threat-intervention comparison;
5. student-selected extension evidence;
6. student-authored predictions, observations, and caveats; and
7. a concise appendix containing the locked criteria and report guidance.

Tables remain editable in Word. Figures are embedded at report-ready
resolution. The dossier clearly distinguishes supplied case-study information,
model-generated evidence, and student-authored notes.

The dossier is not a partially written report. It contains no generated
recommendation, caption, discussion, or mark estimate.

## Report And Research Guidance

The guidance describes quality and choice without prescribing one report.

It should explain that:

- a decent report accurately interprets the reference scenarios, completes the
  sensitivity and intervention evidence, uses quantitative results, and reaches
  a qualified recommendation;
- stronger reports use a clear decision lens, selective evidence, relevant
  literature, systematic investigation, uncertainty, alternative actions, and
  conditions under which advice would change;
- complex or multi-factor analyses add value only when biologically justified
  and clearly interpreted; and
- completing default controls mechanically does not itself demonstrate higher
  achievement.

The app offers several possible organisational patterns rather than a single
report scaffold. Students may integrate methods and results, organise around
threats, or centre the report on a management decision while retaining the
two-act reasoning.

The research surface provides:

- a concise supplied Woodhen case summary;
- provenance for the reference scenarios;
- core references and links;
- prompts to investigate current ecology, monitoring, threats, and management;
  and
- advice on evaluating and citing additional sources.

External research is encouraged but not enforced. Students choose whether to
rely mainly on supplied information or undertake a broader scientific and
conservation-management literature search.

## Display-Item Guidance

The typical report target is three or four display items.

The soft ceiling is:

- four main figures or tables; and
- approximately six plotted panels in total.

A coherent multi-panel figure counts as one display item, but panels are not an
unlimited loophole. Every display item should be cited and interpreted in the
text. Captions should explain the evidence rather than contain hidden essay-
length discussion.

A natural four-item set is:

1. reference historical comparison table;
2. selected calibration or trajectory figure;
3. sensitivity response figure; and
4. future baseline-threat-intervention comparison.

Students may choose a different compact set when it supports their argument
better. Additional outputs can remain in the evidence dossier or supporting
package.

## Ways To Deepen Your Investigation

This student-facing panel remains visible but ungraded. It suggests, without
promising marks:

- denser or better-justified sensitivity settings;
- threshold or nonlinear response analysis;
- validation across additional seeds;
- alternative intervention intensities;
- early versus delayed management;
- multiple plausible interventions;
- compound threats and interactions;
- management portfolios;
- conditions that reverse a preferred recommendation;
- explicit monitoring or data priorities; and
- deeper case-study and management research.

The list is illustrative, not exhaustive.

## Progress And Completion Language

Progress cues report evidence status, not academic achievement.

They may state:

- reference scenarios run;
- three sensitivity settings available;
- threat-intervention family complete;
- observation recorded; or
- portable project download out of date.

They must not state:

- assessment criterion passed;
- report ready for a particular grade;
- analysis is high distinction quality; or
- completion guarantees a particular result.

## Failure And Recovery Behaviour

- Disable a run action while that batch is executing to prevent duplicate
  submissions.
- Process batches sequentially and report the actual scenario count and stage.
- A failed run creates no completed evidence record but preserves its scenario
  definition and student notes for correction or retry.
- A failed import leaves the current project unchanged and reports the specific
  validation problem.
- An incompatible project version offers a read-only explanation or supported
  migration; it never silently discards fields.
- Missing guidance content shows a readable unavailable message rather than
  breaking the app.
- Comparisons with incompatible horizons or baselines remain possible only when
  the app can label the limitation clearly.
- Evidence selections become **review required** when their underlying
  comparison changes.
- Download handling says **download requested**, because the app cannot verify
  where a browser saved a file.

## Performance

- Reuse an existing run when its validated specification fingerprint and seed
  already exist in the project.
- Run only the scenarios requested by the current action.
- Derive compact evidence immediately after a run and release unneeded raw
  objects.
- Show scenario-level progress rather than a synthetic percentage unrelated to
  computation.
- Prevent repeated clicks while a run is active.
- Keep the ordinary three-setting sensitivity and three-scenario prospective
  family responsive within the existing one-user-per-container deployment.

Performance acceptance should use the production-style container and the
existing class-capacity evidence rather than laptop-only timing.

## Accessibility And Responsive Behaviour

- Primary layouts must work at 1366x768 and 1440x900 without overlap.
- Narrow layouts may stack while preserving run, compare, import, and export
  actions.
- All controls are keyboard reachable with visible focus.
- State and risk do not depend on colour alone.
- Icons have accessible names or tooltips.
- Tables provide horizontal handling without hiding their meaning.
- Plot text, legends, thresholds, and units remain readable at export size.
- Dynamic results do not resize controls or obscure nearby content.

## Privacy And Security

- Collect no identity or report prose beyond what students voluntarily place in
  their project notes.
- Treat imported packages as untrusted data.
- Do not evaluate imported code, HTML, YAML, formulas, or paths.
- Apply package size, file-count, schema, and numeric-bound validation before
  replacing project state.
- Do not retain project contents on the off-campus server beyond operational
  session scratch.
- Do not use app interaction logs for marking.

## Internal Architecture

The implementation should avoid reproducing Practical 1's single-file scale.
Use focused modules with clear state boundaries:

- project and persistence;
- reference calibration;
- sensitivity construction;
- future scenario construction;
- simulation and derived evidence;
- comparison and observations;
- plots;
- evidence selection and exports; and
- guidance and help.

Shared Practical 1 visual patterns may be extracted only when doing so is
backwards-compatible and reduces real duplication. Practical 1 remains frozen;
unrelated refactoring is out of scope.

## Verification

### Scientific unit tests

Test:

- unchanged seeded reference outputs;
- locked future-baseline identity;
- one-factor sensitivity isolation;
- named threat and intervention mappings;
- valid and invalid temporal profiles;
- scalar/profile equivalence when no change is introduced;
- parent-child scenario deltas;
- 100-pair territory-holder threshold calculations;
- conditional and overall first-passage medians; and
- warnings for incompatible comparisons.

### Project and export tests

Test:

- project schema validation;
- versioned scenario edits;
- deterministic fingerprints;
- browser-state serialisation;
- package round trips;
- cross-version handling;
- path traversal, unexpected file, size, and malformed-data rejection;
- identity-light provenance preservation;
- selected evidence reconstruction;
- Word dossier structure, tables, figures, and provenance; and
- Markdown, CSV, and figure companions.

### Shiny server tests

Test:

- the complete three-hour core route;
- non-blocking prompts and soft progress;
- reference scenarios remaining immutable;
- sensitivity and future-family construction;
- run reuse and failure recovery;
- comparison-family selection;
- observations and evidence-review state;
- browser recovery state; and
- import/export without unintended filesystem artefacts.

### Browser acceptance

Exercise:

- new project and restored project entry;
- Act 1 chronology and all reference runs;
- minimum three-setting sensitivity;
- baseline-threat-intervention family;
- advanced timing and multi-factor visibility;
- comparison, plots, and observations;
- Word, CSV, figure, Markdown, and project downloads;
- package re-import into a fresh browser context;
- responsive layout and keyboard navigation; and
- absence of console, page, or download errors.

### Regression and deployment gates

- Run the Practical 1 regression suite after any shared change.
- Build and test the Practical 2 container locally.
- Verify package/app/model revision metadata in the image.
- Complete Barry's student-role acceptance before production promotion.
- Promote an immutable image through the documented production workflow.
- Retain the current Staff-only Practical 2 canary as rollback until the full
  release is accepted.

## Delivery Sequence

Implementation should proceed in evidence-producing tranches:

1. scientific scenario, temporal-profile, and 100-pair risk APIs;
2. project schema, browser persistence, and portable package round trip;
3. Start and Calibrate core route;
4. sensitivity and prospective investigation workspaces;
5. comparison and observation workspace;
6. Evidence Studio and Word dossier;
7. report guidance, accessibility, browser acceptance, and container release.

The first integrated acceptance target is the complete three-hour route. After
that passes, perform one focused extension pass for advanced investigation
depth, evidence quality, and independent-work ergonomics. Stop and return for
user assessment when further work becomes marginal rather than material.

## Explicit Non-Goals

This release does not provide:

- YAML or arbitrary R editing;
- a general-purpose species-model builder;
- unrestricted year-by-year schedules;
- automatic literature research;
- automated report prose, captions, or recommendations;
- mark prediction or criterion scoring;
- assessment submission or plagiarism detection;
- server-dependent project persistence;
- an unlimited raw trajectory archive; or
- unrelated Practical 1 redesign.

## Acceptance Criteria

The design is implemented when:

- the five-tab journey is complete and visually consistent with Practical 1;
- all students can run the historically grouped reference scenarios;
- all Act 2 work branches from the locked future baseline;
- a minimum three-setting sensitivity produces interpretable response evidence;
- a baseline-threat-intervention family supports named, bounded, and temporal
  scenario construction;
- advanced multi-factor work remains possible and transparent;
- 100-pair warning probability and timing are scientifically correct;
- browser recovery and portable cross-host project import/export work;
- comparison and evidence selection remain usable with a substantial run
  library;
- the Word dossier and companion files are valid and nonempty;
- student guidance reproduces the locked criteria and supports, but does not
  write, the report;
- reference scientific outputs and Practical 1 regressions remain unchanged;
  and
- the container passes automated, browser, package-portability, access, and
  production-style acceptance gates.
