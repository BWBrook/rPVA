# Practical 1 Landing Tutorial Report

## Summary

Goal 044 adds a local-first first-run landing/tutorial screen to the Practical
1 Shiny app. The screen gives students a brief, plain-language explanation of
PVA, previews the practical mission, tells them what evidence to save, and
keeps `Start baseline` as the action that creates or restores baseline as run
1 before moving into Concept Lab.

## Changed App Behaviour

- The Start tab is now a landing/tutorial surface rather than a compact
  baseline-output panel.
- `Start baseline` still uses the existing server path:
  `current_run(baseline_run)`, `run_history(list(baseline_run))`, and
  `updateNavbarPage(..., selected = "Concept Lab")`.
- Concept Lab now includes an `Introduction` button that returns students to
  the Start tab without changing the current run history.
- Compare CSV and evidence-notes Markdown exports are unchanged.

## Visual Assets

Generated with the built-in Codex image generation tool and copied from the
Codex generated-image cache into the app asset directory. Final project assets
were resized with `sips -Z 960` to 960 x 540 PNGs.

| Asset | Final path | Size | SHA-256 |
| --- | --- | ---: | --- |
| Woodhen/population scene | `inst/shiny/practical1/www/img/landing-woodhen-population.png` | 947K | `5f64b7ec1610efc12807ea308dd41390779d58bcc5d44fbceddea4eeaac93d40` |
| Trajectory/evidence motif | `inst/shiny/practical1/www/img/landing-trajectory-evidence.png` | 825K | `fd14618fe19b3de025b3b3d8ad30b5734345a6045e802b3046cb9e6fa90533e2` |
| Conservation decision motif | `inst/shiny/practical1/www/img/landing-conservation-decision.png` | 873K | `3952f3aafe4cce222ed1f83fb81c7a8a7dbcbf0010393003f2debb5a96b43178` |

Original generated files remain under:
`/Users/bwbrook/.codex/generated_images/019eaa9b-0251-7791-bd70-12cfef0533dd/`.

### Prompts

Woodhen/population scene:

> Create a polished ecological illustration for a university conservation modelling practical: a Lord Howe woodhen-like brown rail standing in native island forest understory, with a small group of subtle bird silhouettes in the background suggesting a population. No words, letters, numbers, diagrams, logos, or watermarks.

Trajectory/evidence motif:

> Create a polished abstract illustration of population viability analysis evidence: multiple smooth population trajectory lines rising, flattening, and diverging across a clean chart-like field, with small translucent data points and a subtle notebook/evidence motif. No words, letters, numbers, axis labels, logos, or watermarks.

Conservation decision motif:

> Create a polished conservation decision illustration for a population viability practical: field notes, a small habitat island map shape, a subtle rescue or habitat improvement symbol made from natural elements, and a few bird silhouettes moving through vegetation. No words, letters, numbers, map labels, logos, or watermarks.

## Validation Evidence

- `git diff --check`: passed.
- `Rscript -e 'source("bootstrap.R")'`: passed.
- `Rscript -e 'renv::status(sources = FALSE)'`: passed.
- Focused teaching API test passed, including the evidence export shape checks.
- Focused Practical 1 Shiny test passed, including the new landing/tutorial
  structure, asset, and responsive-style assertions.
- Browser smoke used local Google Chrome via Playwright after the in-app
  Browser DOM snapshot path failed with
  `TypeError: o.incrementalAriaSnapshot is not a function`.

Browser evidence:

| Evidence | Path |
| --- | --- |
| Smoke result JSON | `/tmp/rpva-goal044-landing-tutorial/browser-smoke-result.json` |
| Landing screenshot | `/tmp/rpva-goal044-landing-tutorial/landing-screen.png` |
| Post-start baseline/control screenshot | `/tmp/rpva-goal044-landing-tutorial/post-start-baseline.png` |
| Compare/export screenshot | `/tmp/rpva-goal044-landing-tutorial/compare-export-controls.png` |
| Transfer screenshot | `/tmp/rpva-goal044-landing-tutorial/transfer-screen.png` |
| Comparison CSV download | `/tmp/rpva-goal044-landing-tutorial/practical1-comparison-smoke.csv` |
| Evidence notes Markdown download | `/tmp/rpva-goal044-landing-tutorial/practical1-evidence-notes-smoke.md` |

Smoke result:

- landing screen title and plain-language PVA/evidence copy visible;
- all three landing images loaded at 960 x 540 with alt text;
- `Start baseline` moved into Concept Lab with baseline/current run visible as
  run 1;
- carrying-capacity run completed;
- Compare table contained baseline plus carrying-capacity rows;
- comparison CSV had `run_id` and three lines including the header;
- evidence notes contained the accepted "evidence, not an answer" framing;
- Transfer screen opened;
- the only console issue was the browser requesting missing `/favicon.ico`
  with a 404.

Text scans:

- marker scan: clean;
- strict secret/private-key/token assignment and key-block scan: clean;
- broad sensitive-term scan found only policy/boundary wording;
- student-facing duplicate-baseline wording search found no instruction to run
  `Deterministic baseline` again after `Start baseline`.

## Boundary Confirmation

No science/model/YAML/defaults, Practical 2 mode, export shape, Docker image,
ITS/Gitea/stochastic/VM/dev/prod service state, Moodle/student release,
accounts, credentials, or remote state changes are part of this goal.

## Recommendation

Ready for orchestrator review and Barry's next incremental local test of the
opening Practical 1 student experience.
