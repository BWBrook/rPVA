# Practical 2 Shiny App

This installed six-tab app is the modular Woodhen investigation workspace.
Start, Calibrate, Investigate, Compare, Evidence Studio, and Assessment Task are
implemented as working modules.

Assessment Task is read-only and project-aware. Its guidance covers the
historical reconstruction, a three-setting one-factor sensitivity family,
matched threat-management comparison, evidence selection, report organisation,
wider research, and final scientific review. Its neutral summary works with an
empty project and reports only what is available in a validated current
project. It does not score work or generate submission prose.

Evidence Studio keeps the Evidence Portfolio as the broad saved working record.
A session-local selection can be ordered and exported as one project-derived
ZIP. The ZIP contains source material only: `evidence-dossier.docx`, numbered
PNG companions for selected plots, and numbered CSV companions for selected
tables. Markdown and PDF are outside the dossier export contract. Students
write all report prose, interpretations, recommendations, captions, and
references.

The R session owns the live validated `woodhen_project`. Browser recovery uses
an origin-specific IndexedDB snapshot and explicit Resume action; portable
project ZIPs are the supported cross-browser and cross-host route. Failed
restore or import validation leaves the live project unchanged.

Focused tests cover app construction, strict project and navigation contracts,
locked assessment wording, empty-state rendering, dossier archive contents,
JavaScript syntax, and responsive CSS boundaries. Desktop and mobile browser
acceptance checks cover the rendered assessment hierarchy, neutral project
summary, navigation, dossier download, and overflow behaviour.
