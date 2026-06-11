# Goal 024 Practical 1 Classroom Dry-Run Report

Date: 2026-06-11

## Scope

This was a local classroom dress rehearsal for Practical 1 on the Mac mini. It
did not deploy, SSH, configure services, build Docker images, expose a URL, or
change scientific defaults.

The rehearsal covered:

- baseline R setup and focused tests;
- Practical 1 command-line checkpoints;
- report scaffold DOCX and PDF renders;
- a fresh Chrome run of the Practical 1 Shiny app;
- comparison CSV and evidence-notes downloads;
- fallback-pack documentation.

## Start State

- Repository: `/Users/bwbrook/git/rPVA`
- Branch: `codex/rpva-goal024-classroom-dry-run`
- Start `HEAD`: `3b61507 Add Practical 1 evidence export hardening`
- Initial status:
  `## codex/rpva-goal024-classroom-dry-run...origin/main`
  plus untracked `docs/goals/024-practical-1-classroom-dry-run-fallback/`

## Non-Shiny Demonstrator Check

The Practical 1 command-line checkpoint ran successfully:

```r
toy <- run_toy_demo(
  keep_traj = TRUE,
  plot_matrix = FALSE,
  verbose = FALSE
)
toy$summary
```

Observed values matched `expected-outputs.md` exactly:

| scenario | PE | N_med |
| --- | ---: | ---: |
| det | 0.000 | 264 |
| ceiling | 0.000 | 85 |
| demographic_stochasticity | 0.000 | 82 |
| env_sd | 0.000 | 70 |
| genetics | 0.070 | 60 |

Plot evidence was written to:

- `/tmp/rpva-goal024-nonshiny/practical1-toy-plots.pdf`

## Report Scaffold Render

Both render paths succeeded:

- `/tmp/rpva-goal024-report/report-scaffold.docx`
- `/tmp/rpva-goal024-report/report-scaffold.pdf`

No PDF toolchain blocker was observed on this Mac mini run.

## Browser Method

Chrome plugin control was available and used for the visible local Shiny dry
run. The app was launched locally only:

- URL: `http://127.0.0.1:3895/`
- launch command class:
  `Rscript -e 'source("bootstrap.R"); rPVA::run_practical1_shiny(host = "127.0.0.1", port = 3895, launch.browser = FALSE)'`

The browser run used a fresh Chrome tab controlled by Codex. Browser-download
files initially landed in the Mac Downloads folder because that is Chrome's
default; they were copied to `/tmp/rpva-goal024-browser/` for stable evidence
and then the generated Downloads copies were removed.

## Shiny Path Exercised

Completed path:

1. opened Start;
2. clicked `Start baseline`;
3. ran carrying capacity;
4. ran demographic stochasticity;
5. ran environmental stochasticity;
6. ran genetic stochasticity;
7. ran catastrophe;
8. ran simple intervention;
9. rapid-clicked the intervention run path as a rerun rough-edge check;
10. ran extinction-vortex comparison;
11. opened Compare;
12. downloaded comparison CSV and evidence-notes Markdown;
13. opened Transfer.

No visible `.shiny-output-error`, `.error`, or `.shiny-error` text was detected
during the final browser checks.

## Compare And Export Evidence

Compare screen evidence:

- row count: `11`;
- export controls visible: `Comparison CSV` and `Evidence notes`;
- wrapper client width: `710`;
- wrapper scroll width: `1369`;
- table client width: `1369`;
- table `min-width`: `960px`;
- table cell `white-space`: `nowrap`;
- table cell `overflow-wrap`: `normal`.

Downloaded evidence copies:

- `/tmp/rpva-goal024-browser/practical1-comparison-chrome.csv`
  - size: `1262` bytes;
  - contained `run_id`, `deterministic_baseline`, `carrying_capacity`, and
    `extinction_vortex`.
- `/tmp/rpva-goal024-browser/practical1-evidence-notes-chrome.md`
  - size: `9606` bytes;
  - contained `Generated: 2026-06-11 ... AEST`;
  - contained `Fixed teaching seed: 42`;
  - contained `evidence, not an answer`;
  - contained `control_K` and catastrophe-frequency provenance;
  - did not contain `raw trajectory`.

Screenshot evidence:

- `/tmp/rpva-goal024-browser/start-screen.png`
- `/tmp/rpva-goal024-browser/concept-environmental-stage.png`
- `/tmp/rpva-goal024-browser/concept-genetics-risk-stage.png`
- `/tmp/rpva-goal024-browser/compare-after-dry-run.png`
- `/tmp/rpva-goal024-browser/transfer-after-dry-run.png`

## Transfer Check

The Transfer screen remained coherent after the full run. It showed the three
expected prompts:

- Which output shows extinction risk?
- Which output shows abundance?
- Which output shows uncertainty?

It also still labelled Allee effect and correlated events as future concepts,
not implemented features.

## Repo Runtime Artefact Check

Before app use, status was:

```text
## codex/rpva-goal024-classroom-dry-run...origin/main
?? docs/goals/024-practical-1-classroom-dry-run-fallback/
```

After browser use and cleanup, status still showed only Goal 024 document
changes and the goal packet. No ordinary Shiny runtime artefacts were written
into the repository.

The temporary Shiny process was stopped, and `127.0.0.1:3895` had no listener
after cleanup.

## Rough Edges Found

- Chrome-controlled selectize interaction required clicking the visible
  dropdown option; filling the combobox text alone did not change the selected
  Shiny stage. This is mainly an automation note, not a student-facing blocker.
- Chrome's browser download path wrote temporary files to Downloads before they
  were copied to `/tmp` and removed. For class, students will naturally use
  their Downloads folder, but demonstrators should know where files land.
- Rapid rerun of the same stage added duplicate comparison rows. This is
  acceptable for a teaching app, but demonstrators should remind students to
  compare named mechanisms rather than fill the table with repeated clicks.

## Changes Made

- Added `docs/teaching/woodhen/practical-1-fallback-pack.md`.
- Updated the Woodhen README, classroom dry-run checklist, instructor guide,
  and troubleshooting guide with fallback pointers.
- Added this dry-run report.
- Updated the Goal 024 log.

No app code, teaching API code, scenario/YAML values, Practical 2 mode,
assessment design, dependencies, deployment templates, services, or remote
state were changed.

## Residual Risks

- This was a local Mac mini Chrome rehearsal, not hosted service proof.
- The fallback pack is an index and recovery script, not a polished student
  handout with committed screenshots.
- A Windows/browser path remains valuable before any live class route is used.
- Hosted delivery still needs a separate service-bootstrap/staging goal if the
  project returns to ShinyProxy or another platform.

## Recommendation

Proceed next with orchestrator review of this uncommitted Goal 024 result. If
accepted, a separate closeout commit can publish the fallback/report materials.
Only after that should the project consider a new, explicitly authorized
service-bootstrap or hosted-staging goal.
