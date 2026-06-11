# Goal 031 Delivery Rehearsal Report

## Summary

Goal 031 rehearsed the current Practical 1 mission-mode app and teaching
materials as a local day-of-class delivery candidate. The local app-led path is
usable for an in-room rehearsal or instructor-controlled class route. Hosted
student release remains blocked until the trusted hostname, TLS/browser-trust,
student access, and service-readiness gates are separately resolved.

No app, model, science, YAML, Practical 2, assessment, hosting, service, DNS,
TLS, Docker, account, credential, student workspace, dependency, or remote-state
changes were made.

## Starting State

- Working directory: `/Users/bwbrook/git/rPVA`
- Branch: `codex/rpva-goal031-delivery-candidate-rehearsal`
- Base: `d4855fc Add Practical 1 mission-mode app affordances`
- Initial dirty state: only the untracked Goal 031 packet directory.

## Rehearsal Inputs

The rehearsal used:

- `docs/teaching/shiny/practical-1-mission-tutorial.md`
- `docs/teaching/woodhen/practical-1-mission-worksheet.md`
- `docs/teaching/woodhen/practical-1-instructor-beat-sheet.md`
- `docs/teaching/woodhen/practical-1-fallback-pack.md`
- `docs/teaching/woodhen/classroom-dry-run-checklist.md`
- `docs/teaching/woodhen/instructor-guide.md`
- `inst/shiny/practical1/app.R`
- Goal 030 browser-smoke and log evidence.

## Browser Rehearsal

- Browser automation path: Playwright/Chromium through the local Codex wrapper.
- Local URL: `http://127.0.0.1:3898/`
- App command:

```sh
Rscript -e 'source("bootstrap.R"); run_practical1_shiny(host = "127.0.0.1", port = 3898, launch.browser = FALSE)'
```

Path exercised:

1. Start baseline.
2. Ceiling carrying capacity.
3. Environmental stochasticity.
4. Catastrophe.
5. Simple intervention.
6. Compare guidance and comparison table.
7. Comparison CSV download.
8. Evidence-notes Markdown download.
9. Transfer screen.

Screenshots:

- `/tmp/rpva-goal031-browser/start-baseline.png`
- `/tmp/rpva-goal031-browser/concept-lab-after-missions.png`
- `/tmp/rpva-goal031-browser/compare-and-export.png`
- `/tmp/rpva-goal031-browser/transfer.png`

Downloaded evidence:

- `/tmp/rpva-goal031-browser/practical1-comparison-goal031.csv`
- `/tmp/rpva-goal031-browser/practical1-evidence-notes-goal031.md`

Observed browser console issue:

- A non-blocking `favicon.ico` 404 appeared. No app JavaScript failure was
  observed.

Shutdown:

- The Shiny process was stopped after rehearsal.
- `lsof -nP -iTCP:3898 -sTCP:LISTEN` returned no listener.

## Export Confirmation

The comparison CSV retained the accepted export shape:

```text
run_id, stage, label, scenario, years, reps, PE, Nmed, Nlo95, Nhi95,
extinct_reps, surviving_reps, trajectory_available
```

The evidence-notes Markdown retained:

- Practical 1 evidence-notes title;
- generated timestamp;
- run count;
- fixed teaching seed;
- comparison table;
- settings and provenance;
- interpretation prompts;
- "evidence, not an answer" wording.

## Report Scaffold Render

The report scaffold was rendered to `/tmp/rpva-goal031-report/`.

- DOCX render: passed.
  - `/tmp/rpva-goal031-report/report-scaffold.docx`
- PDF render: first parallel attempt failed with a transient
  `report-scaffold.qmd` read error while DOCX was rendering.
- PDF render rerun by itself: passed.
  - `/tmp/rpva-goal031-report/report-scaffold.pdf`

Day-of-class implication: render DOCX and PDF sequentially on the teaching
machine.

## Delivery Materials Created

- `docs/teaching/woodhen/practical-1-day-of-class-pack.md`
- `docs/teaching/woodhen/practical-1-go-no-go-checklist.md`

Narrow pointers were added so the new pack is discoverable from the Woodhen
teaching kit and instructor guide.

## Worksheet Review

The mission worksheet already supports the lightweight evidence-log design. A
narrow evidence-recording section was added so students have a clear place to
record the filenames of the comparison CSV, evidence-notes Markdown, or fallback
evidence capture.

## Rehearsal Findings

What worked locally:

- The app supports the Goal 029/030 mission path without new feature work.
- Start baseline clearly establishes run 1.
- Concept Lab mission cues are visible.
- Compare guidance gives a clean evidence target.
- Downloads work and preserve the export contract.
- Transfer prompts align with the worksheet.
- Fallback, troubleshooting, and expected-output materials are sufficient for a
  demonstrator-controlled recovery path.

Friction or risks:

- The report scaffold should be rendered sequentially, not in parallel.
- The day-of-class route must avoid implying that the current raw-IP or insecure
  HTTPS route is student-ready.
- The worksheet needs students to record where evidence files were saved; this
  was addressed with a narrow wording addition.

## Readiness Judgement

Local/in-room teaching readiness: green for a controlled rehearsal or class
delivery path where the app route is locally approved and demonstrators can
switch to fallback quickly.

Hosted student URL release readiness: not green. The current unresolved gates
are:

- approved class hostname;
- browser-trusted HTTPS with no warning/crossed-out HTTPS state;
- tested student app path rather than only gateway/login reachability;
- approved access model;
- class account/token/workspace decisions;
- capacity and recovery checks for student-facing use.

Fallback readiness: green if `practical-1-fallback-pack.md`,
`expected-outputs.md`, `troubleshooting.md`, and the report scaffold are open on
the teaching machine.

## Recommended Next Gate

Review the day-of-class pack and go/no-go checklist. If accepted, a separate
closeout goal can commit/publish the Goal 031 docs. Hosted student release
should remain a separate Goal 032-or-later infrastructure gate after trusted
hostname/TLS/access decisions are resolved.
