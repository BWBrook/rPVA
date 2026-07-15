# Practical 1 mission-label layout fix

## Scope and root cause

Initial checkout was `535f201`. The browser diagnosis reproduced the reported
defect at 1366x768 and 390x844. Each `.mission-step` link contains one
`.action-label` block wrapper, so the outer CSS grid saw that wrapper as its
only grid child. The inner `.mission-step-index`, `.mission-step-label`, and
`.mission-step-status` spans therefore did not occupy the intended three grid
tracks. With `overflow-wrap: anywhere`, labels rendered at approximately
17.5-20 px wide and ordinary words broke character-by-character; the status
also started at the label's left edge.

The bounded correction is:

```css
.mission-step > .action-label {
  display: contents;
}
```

This exposes the existing index, label, and status spans to the approved
mission grid without changing mission content, state transitions, controls,
buttons, responsive stacking, or model/science defaults.

## Reviewer findings resolved

- Evidence-directory validation now explicitly rejects every relative path,
  performs `lstatSync` before existing-path handling, and rejects existing
  symlinks including dangling symlinks. The runtime probe covers both a
  relative candidate and a dangling symlink while retaining acceptance of a
  not-yet-created absolute direct `rpva-practical1-*` child of `os.tmpdir()`.
- The cleanup test parses the Node probe as JSON with `jsonlite::fromJSON()`
  and asserts structured fields rather than matching output substrings.
- Final export checks now extract rendered selected evidence from the UI,
  including run IDs, visible stage category, label, and settings summary.
  CSV and Markdown comparison rows, stages, labels, and settings/provenance
  are checked against that rendered state. The existing hard-coded route and
  final-selection checks remain as additional invariants.
- Acceptance now checks non-zero panel geometry, rendered label widths,
  ordinary-word line evidence, status geometry, and mission controls at
  1366x768, 1440x900, and 390x844.
- `PRACTICAL1_URL` remains the browser script's URL override; this source-fix
  validation used the local app only.

## Rendered evidence

The fresh Concept Lab screenshots were inspected at their original captured
resolution:

| viewport | screenshot pixels | panel geometry | rendered mission-label widths | line behaviour |
| --- | ---: | --- | --- | --- |
| 1366x768 | 1366x1866 | left 460.5x1300.3; output 767.5x1075.8; plots 1244x436.4 | Core 326.47 px; Explore 341.55 px | every label one line; 19-32 non-space characters on the longest line |
| 1440x900 | 1440x1866 | left 460.5x1300.3; output 767.5x1075.8; plots 1244x436.4 | Core 326.47 px; Explore 341.55 px | every label one line; 19-32 non-space characters on the longest line |
| 390x844 | 390x3976 | panels 336 px wide; heights 1467.2, 1454.1, and 756.4 px | Core 207.97 px; Explore 223.05 px | ordinary words preserved; only the long Small-population label uses two normal lines |

The narrowest rendered label width is 207.97 px, above the 150 px acceptance
threshold. Status widths are non-zero (33.95-46.03 px) and remain to the
right of the label track.

## Verification

- RED browser diagnosis: `/tmp/rpva-practical1-task-9-red/browser-result.json`
  failed at `mission labels have usable rendered width at 1366x768`, with
  measured label widths of about 17.5-20 px.
- `node --check scripts/practical1_browser_acceptance.js`: passed.
- Focused `test-13_practical1_shiny.R`: 454 passed, 0 failed, 0 warnings, 0
  skipped.
- Fresh complete browser pass: all 135 checks true, including the original
  106 acceptance checks plus the new responsive/layout/export/cleanup checks;
  14 non-empty artifacts; 0 console errors; 0 console warnings; 0 page
  errors. Evidence directory:
  `/tmp/rpva-practical1-task-9-browser-20260715-final`.
- `renv/activate.R` was passed through the requested trailing-whitespace
  cleanup command; it produced no workspace diff. `git diff --check` passed.

## Commits

1. `Fix Practical 1 mission label layout`
2. `Document Practical 1 mission label fix`
