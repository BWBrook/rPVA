# Practical 1 Compare and Transfer Redesign

**Date:** 2026-07-18
**Status:** Approved in design discussion; awaiting written-spec review
**Scope:** Practical 1 Compare and Transfer tabs, their in-session state, help, and evidence exports

## Objective

Turn the Practical 1 closeout into a guided rehearsal of the research workflow students will use independently in Practical 2:

**Change -> Run -> Compare -> Record -> Integrate -> Question again**

Compare should help students reason from selected evidence and accumulate observations. Transfer should help them secure that evidence, reflect on the workflow, and understand how the same habits will support their individual Woodhen investigation and assessed report.

## Current Problems

The current interface is technically functional but weak as a closeout learning experience:

- Full session history dominates Compare, especially after the complete Core and Explore route.
- Evidence-selection radio labels repeat long raw setting strings and are difficult to scan.
- The most useful output, the three-run comparison, is secondary and horizontally scrollable.
- Run cards and the raw comparison table duplicate information without creating a clear reading order.
- Compare has no contextual help despite introducing selection, interpretation, readiness, and export concepts.
- The current one-sentence interpretation is a single mutable value. Earlier interpretations are overwritten rather than accumulated.
- The Evidence notes export contains only the latest interpretation, so it is not a collected notebook.
- Transfer has ample space but mainly repeats instructions and exposes developer-facing future-engine concepts.

## Pedagogical Model

Practical 1 provides a constrained version of the research cycle. The missions define the questions and allowable changes, while students practise:

1. changing assumptions deliberately;
2. comparing against a reference case;
3. examining extinction risk, abundance, and uncertainty together;
4. recording an observation while its evidence is visible;
5. distinguishing results, interpretation, and caveats; and
6. integrating several observations into a synthesis.

Practical 2 will remove many of these rails. Students will frame conservation questions, construct scenarios, run sensitivity analyses, choose useful comparisons, and build an individual evidence-based argument for a report worth 25% of the unit.

Practical 1's notebook is unassessed practice. Its language and interaction pattern should nevertheless become the foundation for the more flexible Practical 2 research workspace.

## Information Architecture

### Compare: Reason From Evidence

Compare becomes one full-width evidence workspace with four ordered sections.

#### 1. Choose Evidence

Display three explicit evidence slots:

- **Baseline:** the first baseline run, locked as the reference.
- **Risk mechanism:** a concise selector containing eligible risk runs.
- **Intervention or vortex:** a concise selector containing eligible action runs.

Each selected slot shows the run number, mission label, category, and the settings that distinguish it. The concise summary includes the stage-specific controls and any shared Core control that differs from the locked baseline; it does not repeat every unchanged control.

Full history moves into a collapsed **Review all session runs** disclosure. Its summary states the number of successful runs. Expanded history uses compact, scannable rows with run number, mission, category, key changes, and selected status. Detailed raw settings remain available there but do not dominate the default screen.

An adjacent help control explains why the comparison contains exactly one baseline, one risk mechanism, and one intervention or vortex run.

#### 2. Compare Outcomes

Replace the wide three-row table and duplicative run cards with a comparison matrix:

- columns are the three selected runs;
- rows are mission, key changed settings, extinction probability, median final abundance, 95% interval, change in extinction probability, change in median abundance, and uncertainty change.

The matrix must fit at normal desktop widths without horizontal scrolling. On mobile it should use a deliberate stacked representation rather than a clipped desktop table.

An adjacent help control explains extinction risk, abundance, uncertainty, baseline deltas, and the danger of interpreting zero observed extinction without considering horizon and simulation count.

#### 3. Build Notebook

Provide a one-sentence observation composer with the visible scaffold:

> When I changed..., extinction risk..., abundance..., and my caveat is...

The primary command is **Add to notebook**. Each saved observation appears below the composer and remains when the selected comparison changes.

Each observation displays:

- sequential observation number;
- associated run numbers and labels;
- a compact metric snapshot for the three-run comparison; and
- the student's observation text.

Students can remove an erroneous observation and recreate it. In-place editing is outside the first implementation tranche.

An unfinished draft is not silently erased when selection changes. The interface shows that the evidence selection changed and asks the student to review the draft before adding it. The observation is associated with the selection active when **Add to notebook** is pressed.

An adjacent help control explains the difference between an observation, a caveat, and the final synthesis.

#### 4. Final Synthesis

Provide a separate two-to-three-sentence field that integrates the notebook rather than repeating the latest observation. It should prompt students to state the overall pattern, cite the most decision-relevant evidence, and retain an appropriate caveat.

Readiness is shown as a compact status summary rather than a long six-item checklist. Detailed missing requirements can appear only when something is incomplete.

### Transfer: Secure and Carry Evidence Forward

Transfer becomes a handoff-first screen with three bands.

#### 1. Your Evidence Pack

Show:

- final selected evidence summary;
- read-only final synthesis;
- number of saved observations;
- current or stale state for both downloads;
- **Comparison CSV** and **Evidence notebook** download controls; and
- a direct **Return to Compare** action when requirements are incomplete.

Download controls live on Transfer, freeing Compare for analysis and note-building. Compare ends with a compact **Review evidence pack** action that opens Transfer.

#### 2. What You Practised

Summarise the habits developed in Practical 1:

- change assumptions deliberately;
- retain a reference case;
- compare risk, abundance, and uncertainty together;
- record evidence promptly; and
- distinguish results, inference, and caveats.

#### 3. From Guided Comparison to Independent Investigation

Explain that Practical 2 will ask students to:

- frame their own Woodhen conservation question;
- construct and refine scenarios;
- test sensitivity to uncertain assumptions;
- choose comparisons that answer their question; and
- build an individual, reproducible argument for the assessed report.

Display the shared research cycle:

**Question -> Scenario -> Simulation -> Comparison -> Evidence note -> Synthesis**

State plainly that the Practical 1 notebook is unassessed practice, while the same evidence habits will support the Practical 2 report worth 25% of the unit.

Remove the current developer-facing **Future concepts** list from the student interface.

## Notebook State Model

Store notebook entries in browser-session reactive state. Each entry contains:

- stable sequential ID;
- creation order;
- selected baseline, risk, and action run IDs;
- selected run labels and stages;
- compact comparison snapshot for key metrics;
- concise settings summary; and
- observation text.

The session also stores a final synthesis separately from notebook observations.

Resetting the session clears run history, selections, notebook entries, draft text, synthesis, and download status together. Nothing is persisted beyond the browser session in this Practical 1 tranche.

## Interaction and State Flow

1. Successful Concept Lab runs populate session history.
2. The first baseline remains locked; the most recent eligible risk and action runs are the initial defaults.
3. Changing either selector refreshes the comparison matrix without deleting saved observations.
4. **Add to notebook** requires a complete three-run selection and non-empty observation.
5. Adding an observation captures the active comparison and clears the composer.
6. Removing an observation updates readiness and invalidates previous downloads.
7. Changing the selected evidence, notebook, or final synthesis invalidates previous downloads.
8. Transfer reports whether the evidence pack is complete and current.

## Export Contract

### Comparison CSV

Retain exactly the final three selected runs. Preserve the existing stable comparison fields and provenance checks so the file remains a compact analysis dataset.

### Evidence Notebook Markdown

Export a human-readable document in this order:

1. title and generation metadata;
2. final synthesis;
3. final selected comparison;
4. chronological observation notebook;
5. a compact three-run metric snapshot beneath each observation;
6. interpretation prompts; and
7. full settings and provenance as an appendix.

The Markdown export can therefore preserve observations about comparisons that differ from the final CSV while keeping the CSV itself to the final three-run evidence set.

## Readiness and Staleness

Transfer reports five states:

1. exactly three eligible evidence runs selected;
2. at least one observation saved;
3. final synthesis completed;
4. current comparison CSV downloaded; and
5. current evidence notebook downloaded.

The export signature must include final selected run IDs, the ordered notebook content, and final synthesis. Any material change after download marks both files stale and requests fresh copies.

## Help

Use the established Practical 1 modal-help pattern rather than visible instruction walls. Compare needs contextual help for:

- choosing evidence;
- reading the comparison matrix; and
- building the notebook and final synthesis.

Transfer needs one concise evidence-pack help control explaining readiness, staleness, downloads, and the temporary browser session.

## Responsive and Accessibility Requirements

- Selected evidence and the comparison matrix appear before full session history on mobile.
- No important comparison metric requires horizontal scrolling.
- Selectors have concise visible labels and generous input targets.
- Help controls have accessible names and keyboard focus states.
- Ready, missing, and stale states use text as well as visual styling.
- Observation removal uses an explicitly labelled **Remove observation** control and a confirmation dialog.
- Heading order describes the workflow logically.
- No control or status relies on colour alone.

Screenshot review cannot establish full screen-reader or keyboard compliance; automated and manual interaction checks remain required.

## Empty and Error States

- Before baseline: direct the student to create the baseline in Concept Lab.
- Baseline only: show empty risk and action slots with direct mission guidance.
- Missing action or risk evidence: keep the outcome matrix incomplete and explain the missing category.
- Empty observation: keep **Add to notebook** disabled and explain nearby that an observation is required.
- Selection changed during a draft: retain the text and request review.
- Missing synthesis: Transfer identifies it and links back to the field.
- Stale downloads: explain which evidence changed and provide fresh controls.
- Export failure: preserve notebook state and allow retry without re-entry.

## Acceptance Criteria

### Compare

- Full history is collapsed by default and no longer dominates first view.
- The three evidence slots are understandable without reading raw control strings.
- The outcome matrix shows all key metrics without horizontal scrolling at supported desktop widths.
- Students can save at least three observations against different comparison selections.
- Saved observations remain correctly associated with their run trios.
- Removing an observation updates readiness without changing run history.
- Final synthesis is distinct from individual observations.
- Contextual help is available for selection, metrics, and notebook use.

### Transfer

- The final evidence summary, synthesis, observation count, and download status are visible together.
- Incomplete or stale evidence provides a direct route back to Compare.
- Both fresh downloads are required for completion.
- The student-facing bridge accurately describes the transition to Practical 2.
- No developer-facing engine language remains.

### Export and Regression

- CSV remains exactly three data rows plus its header.
- Markdown includes every saved observation, each associated run trio, final synthesis, final selected comparison, and settings appendix.
- Selection, notebook, or synthesis changes invalidate prior downloads.
- Reset clears all Compare and Transfer state.
- Existing Concept Lab behavior and run history remain intact.
- Desktop and mobile browser acceptance covers full-history, notebook, final export, and Transfer-complete states.
- No console errors, page errors, incoherent overlaps, or page-level horizontal overflow occur.

## First-Tranche Boundaries

The Monday-ready implementation should include the complete evidence workflow above. It should not add server-side persistence, accounts, cross-session recovery, rich-text editing, notebook reordering, multiple export formats, or Practical 2 scenario-building behavior.

Observation removal and recreation are sufficient for correction in this tranche. In-place observation editing can be reconsidered after classroom feedback.
