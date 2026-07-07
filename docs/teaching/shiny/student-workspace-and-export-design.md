# Student Workspace And Export Design

## Purpose

This note defines a per-student workspace and export model for an rPVA Shiny
teaching service hosted on `deep-server` or an equivalent Linux teaching
platform.

The design target is a class under 50 students, with workspaces retained through
Practical 1, the break, Practical 2, and the two-week report-writing period,
then cleaned after semester.

## Design Principles

- Students should work entirely through the browser.
- Workspaces should support recovery of exports within compact course
  directories.
- Exports should help students cite and interpret their own model runs.
- The app should preserve assessment boundaries: a saved output is evidence for
  interpretation.
- Retention should be time-limited and clearly communicated.
- Quotas should be simple enough to enforce operationally.

## Workspace Model

Use one workspace per student identity:

```text
/data/codex/teaching/rpva-2026/workspaces/<student_id>/
```

This path is a recommendation only for future deployment.

Suggested subdirectories:

```text
exports/
settings/
plots/
logs/
tmp/
```

Meanings:

- `exports/`: student-downloadable tables and bundles.
- `settings/`: small machine-readable records of selected scenarios and
  controls.
- `plots/`: exported PNG/PDF figures.
- `logs/`: minimal app-side event records if approved.
- `tmp/`: disposable per-session scratch, cleaned aggressively.

Do not store large raw trajectory objects by default. The default evidence
bundle should be compact.

## Identity Options

### Unlisted Class URL

Students receive one unlisted URL and use the app without login.

Strengths:

- lowest friction,
- fastest first road test,
- minimal account management.

Weaknesses:

- weak mapping between exports and individual students,
- weak workspace recovery,
- no meaningful quota enforcement per student,
- risk of accidental overwrites or shared-state confusion.

Fit:

- acceptable only for a no-persistence demo or static fallback,
- a poor fit for per-student recoverable workspaces.

### Generated Class Accounts

Create simple course-specific accounts or tokens before class.

Strengths:

- good balance of practicality and isolation,
- enables per-student workspace routing,
- avoids full institutional SSO dependency,
- easy to wipe after semester,
- works well for a first road test under 50 students.

Weaknesses:

- requires secure distribution of credentials,
- account list must be managed,
- password reset/recovery process must be simple.

Fit:

- recommended first road-test option unless UTAS SSO is easily available.

### UTAS SSO Or LDAP

Use institutional identity.

Strengths:

- strongest identity model,
- aligns with student records and institutional access expectations,
- better for long-term platform reuse.

Weaknesses:

- likely needs campus IT support,
- may slow the first road test,
- integration details can dominate the platform work.

Fit:

- best long-term option if support is available,
- optional for the first R&D road test unless policy demands it.

### Reverse-Proxy Authentication

A reverse proxy handles authentication before traffic reaches the Shiny app.

Strengths:

- keeps app simpler,
- can work with generated accounts, SSO, or campus auth,
- centralises TLS and access control.

Weaknesses:

- must pass a stable student identity to the app,
- needs careful configuration and testing,
- still requires workspace mapping logic.

Fit:

- strong option if campus/reverse-proxy support is part of the deployment.

### Other Reasonable Option: One-Time Class Codes

The app issues or accepts one-time student codes that map to a workspace.

Strengths:

- lighter than full accounts,
- enough for workspace recovery in a small class,
- compatible with browser-first teaching.

Weaknesses:

- less secure than proper accounts,
- needs careful handling to avoid code sharing or loss.

Fit:

- viable for a prototype if generated class accounts add too much setup.

## Recommended Identity Path

Use generated class accounts or generated per-student tokens for the first
road test. Keep UTAS SSO/LDAP as the long-term preferred option if the platform
is reused for multiple teaching apps.

Avoid an unauthenticated unlisted URL for any workflow that promises
recoverable per-student exports.

## Quota Strategy

Target quota:

- about `1 GB` per student,
- class under 50 students gives an expected cap around `50 GB`,
- keep a separate operational reserve for logs, container images, and backups.

Quota enforcement options:

- filesystem project quotas on `/data`,
- per-user directory quotas if supported by the filesystem,
- ShinyProxy/container resource limits plus app-level export caps,
- scheduled reporting and manual cleanup for the first road test if filesystem
  quota setup remains unfinished.

For a first road test, the app should also enforce soft limits:

- maximum number of saved export bundles,
- maximum file size per export,
- exclude raw trajectory object exports by default,
- automatic cleanup of `tmp/`,
- warnings before overwriting or deleting older exports.

## Export Types

Current local Practical 1 Shiny export baseline:

- comparison table as CSV;
- evidence-notes Markdown file with run settings/provenance and prompts;
- session-local downloads only, with no server-side workspace assumption.

Recommended export bundle:

- scenario comparison table as CSV,
- selected run summary as CSV,
- selected plot as PNG or PDF,
- plain-text or JSON settings record,
- short README explaining what the export contains.

Optional later exports:

- DOCX-ready table,
- report-scaffold insertion snippet,
- reproducibility bundle with seed and scenario controls,
- instructor-only anonymised class summary.

Avoid by default:

- raw full trajectory arrays,
- large RDS files,
- unlabelled screenshots,
- exports that hide the settings used to generate them.

## Retention And Cleanup

Suggested service lifecycle:

- open workspaces before Practical 1,
- retain through Practical 1,
- retain through the break,
- retain through Practical 2,
- retain through the two-week report-writing period,
- freeze or make read-only after report due date,
- archive or wipe after a clearly announced cleanup date.

Suggested retention policy:

- student exports retained until two weeks after report due date,
- operational logs retained only as long as needed for teaching QA and support,
- temporary files cleaned daily or at session end,
- full workspace deletion after semester unless Barry explicitly requests an
  archive.

## Privacy And Assessment Boundary

The workspace should not be framed as a submission system unless the unit team
explicitly decides that. It should be a recovery and export aid.

Privacy notes:

- store the minimum identity needed to recover exports,
- avoid collecting free-text report content unless required,
- avoid detailed clickstream analytics unless approved,
- explain retention and cleanup clearly to students,
- keep any support logs separate from marking decisions unless policy allows
  otherwise.

Assessment boundary:

- exports support transparency,
- the assessed item remains the report,
- optional artefacts should not replace interpretation,
- the app should not label one scenario as the correct answer,
- saved settings should help markers understand what the student ran, not mark
  the work automatically.

## Recommendation

For rPVA 2026, use generated class accounts or per-student tokens, map each
identity to a capped workspace under `/data`, retain compact exports through the
report-writing window, and clean after semester. Keep exports small,
interpretable, and tied to model settings.
