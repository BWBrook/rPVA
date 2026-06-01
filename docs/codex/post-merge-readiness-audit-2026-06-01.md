# rPVA Post-Merge Readiness Audit - 2026-06-01

## Executive Summary

`rPVA` is now in a credible post-refactor state for a focused Woodhen teaching
road test, but it is not yet a zero-to-hero teaching product. The engine runs,
the Woodhen scenario set is stable, CI covers the main smoke path, and prior
semantic-equivalence evidence supports the refactor. The next two months should
therefore be spent mostly above the engine: student-facing lesson flow,
Woodhen interpretation support, report scaffolding, demonstrator notes, and
only then interface design.

The most important recommendation is to resist building RShiny first. A Shiny
app could become useful for teaching and professional use, but it should follow
a well-designed scripted/tutorial workflow. Otherwise the app will hide
unsettled pedagogy behind widgets.

The package can likely support the road test if the next work is tightly
ranked:

1. Build the two-practical Woodhen teaching kit.
2. Convert the current Woodhen scripts/comments into a guided reproducible
   workflow with report-ready outputs.
3. Add interpretation and diagnostics scaffolding so students know what the
   numbers and plots mean.
4. Clean up package hygiene and installation/documentation friction.
5. Define, but do not yet implement, the student/professional interface
   requirements for a later RShiny prototype.

## Current State

Branch and publication state at audit start:

- local branch: `main`
- local/remote sync: `HEAD -> main`, `origin/main`, `origin/HEAD` at
  `3736f00`
- PR #2: merged at `2026-05-31T12:17:28Z`
- merge commit: `3736f00b4c8b40a27403e79144dfbfebfadc5686`
- dirty state: only the expected untracked goal packet
  `docs/goals/004-post-merge-readiness-audit/`

Cheap checks run during this audit:

```sh
git diff --check HEAD
```

Result: pass, no output.

```sh
Rscript -e 'st <- renv::status(sources = FALSE); cat("synchronized=", isTRUE(st$synchronized), "\n")'
```

Result: pass. Output included `synchronized= TRUE`.

```sh
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-09_scenarios.R", reporter = "summary")'
```

Result: pass. Output ended with `DONE`.

```sh
Rscript -e 'source("bootstrap.R"); tbl <- run_scenarios("woodhen", csv_out=NULL, rds_out=NULL, keep_traj=FALSE, parallel=FALSE); print(tbl)'
```

Result: pass. The five-scenario Woodhen summary reproduced the prior evidence:

| scenario | years | reps | PE | Nmed | Nlo95 | Nhi95 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| woodhen_no_intervention | 40 | 1000 | 0.666 | 16 | 1 | 31 |
| woodhen_pig_control | 40 | 1000 | 0.566 | 57 | 2 | 184 |
| woodhen_captive_pig | 40 | 1000 | 0.082 | 119 | 4 | 199 |
| woodhen_rat_eradication | 5 | 1000 | 0.000 | 832 | 340 | 1386 |
| woodhen_future_baseline | 75 | 1000 | 0.000 | 1510 | 1109 | 1957 |

Evidence inspected:

- `README.md`
- `DESCRIPTION`
- `.github/workflows/r-ci.yaml`
- `R/`
- `inst/extdata/woodhen/`
- `inst/extdata/toy/`
- `tests/testthat/`
- `docs/codex/refactor-branch-review-2026-05-30.md`
- `docs/codex/semantic-equivalence-audit-2026-05-30.md`
- `docs/goals/003-pr-readiness-package/Log.md`

## Teaching Road-Test Target

The target is a third-year undergraduate teaching road test in about two
months:

- two practical classes, roughly three hours each
- students begin with little or no PVA background
- Woodhen is the central case study
- students should finish able to run, diagnose, extend, and report on a PVA
- outputs need to support assessable report writing

The natural teaching sequence is:

Class 1:

- introduce stage-structured population models and extinction risk
- run the toy model in steps
- interpret deterministic growth, carrying capacity, demographic stochasticity,
  environmental stochasticity, and inbreeding
- connect each mechanism to one plot and one table

Class 2:

- run the Woodhen historical and management scenarios
- compare intervention outcomes
- perform a bounded sensitivity exercise
- generate report-ready tables/plots
- write a short management interpretation with uncertainty and assumptions

At present, the computational pieces exist, but the teaching journey is not yet
packaged as that two-class path.

## Package Hygiene

Strengths:

- `renv` is synchronized under the current local setup.
- `bootstrap.R` provides a simple entry point and now avoids redundant `renv`
  restore churn when already synchronized.
- CI runs on `main` and pull requests, restores dependencies, bootstraps,
  runs the test suite, and executes the Woodhen smoke test.
- The optional `ggrastr` path is kept out of the default restore/check path,
  which is appropriate for teaching setup simplicity.

Teaching-readiness gaps:

- There is no vignette, Quarto worksheet, or package article. The README is
  doing too much work.
- Package docs are function-level and sparse. They do not yet teach the
  workflow or interpretation.
- `DESCRIPTION` says `Depends: R (>= 4.1.0)` while the active project lockfile
  and CI evidence are centered on R 4.6.0. This may be fine for eventual broad
  compatibility, but teaching setup needs an explicit recommended R version.
- `scenario_raw.rds` is tracked at repo root. That may be historical, but it
  looks like a generated artefact and should be reviewed before a polished
  teaching/release package.
- Both `LICENSE` and `LICENSE.md` exist. That is common for R packages with
  `MIT + file LICENSE`, but the teaching/release docs should make the intended
  packaging convention clear.

Road-test implication: package hygiene does not block the road test, but a
student setup guide must be clearer than the current README-only path.

## Woodhen Case Study Readiness

Strengths:

- The five core Woodhen scenarios are present and runnable.
- The scenario comments are pedagogically promising: they tell a conservation
  story rather than merely listing parameters.
- The case spans real teaching contrasts: no intervention, pig control,
  captive breeding plus pig control, rodent eradication, and future baseline.
- `run_scenarios("woodhen")` returns a compact, report-relevant summary.
- The semantic-equivalence audit previously confirmed the Woodhen summary
  matched pre-refactor behaviour.

Teaching-readiness gaps:

- The Woodhen script is still a runnable script, not a guided practical. It
  asks students to "repeat" and compare, but does not provide a structured
  worksheet, prompts, checkpoints, expected observations, or report questions.
- The sensitivity scenario is a comment-rich template, but it is not yet
  integrated into a bounded exercise with guardrails. Novices could change
  parameters that are mathematically valid but scientifically unhelpful.
- There is no data provenance or literature note packaged beside the Woodhen
  scenario to explain where inputs came from, how simplified they are, and what
  assumptions students may critique.
- Outputs are not yet report-ready. Students get tables and plots, but not a
  recommended comparison table, figure set, caption prompts, or interpretation
  rubric.

Road-test implication: Woodhen is the right anchor, but it needs a teaching
wrapper before it is safe to hand to novice students.

## Tutorial And Pedagogy

Strengths:

- `run_toy_demo()` is exactly the right kind of beginner ramp: it incrementally
  adds mechanisms and returns both results and a summary table.
- The README already explains the toy sequence and "what to watch for".
- The toy tests cover default compute-only behaviour and richer plotting mode.

Teaching-readiness gaps:

- The toy material lives as README text and `inst/extdata/toy/toy_demo.R`, not
  as a worksheet with learning objectives, tasks, expected outputs, and
  reflection questions.
- There is no glossary for terms students will need: lambda, stable stage
  distribution, stochasticity, extinction probability, median final abundance,
  conditional vs unconditional mean, inbreeding coefficient, lethal equivalents,
  carrying capacity, catastrophe, and sensitivity analysis.
- There is no "student gets stuck here" troubleshooting guide for common
  issues such as missing trajectories when `keep_traj = FALSE`, interpreting
  `PE = 0`, or confusing female-only stage vectors with total population.
- There is no marked or markable report scaffold.

Road-test implication: the toy ramp is a strong foundation, but it needs to be
converted into a two-hour learning object, not just example code.

## Engine/API Usability

Strengths:

- The post-refactor public surface is small and appropriate:
  `read_spec()`, `set_scenario()`, `run_pva_core()`, `run_scenarios()`,
  `run_toy_demo()`, and plotting helpers.
- `run_pva_core()` now defaults to quiet, summary-only output, which is better
  for batch and CI use.
- Strict validation catches deprecated `demo_sd`, unknown fields, quoted stand-
  ins, stage-length mismatches, invalid probabilities, and action-vector
  mismatches.
- `run_scenarios()` gives students a low-friction way to run the Woodhen set.

Teaching-readiness gaps:

- `run_scenarios()` returns invisibly. That is R-idiomatic, but it can confuse
  novices unless all teaching calls explicitly assign or print the result.
- Plot functions require `keep_traj = TRUE`, but the core and batch defaults
  are `keep_traj = FALSE`. That is technically sensible, but it must be taught
  explicitly.
- Function documentation lacks worked examples. Students will rely on README
  snippets and scripts rather than help pages.
- Some internal/unexported functionality has `.Rd` files, which is not harmful
  but may clutter package help for students.
- Scenario path handling is good for installed extdata, but student edits will
  likely need a clear copy-to-working-folder pattern so they are not editing
  package source directly.

Road-test implication: the API is small enough to teach, but needs a curated
"only use these six functions first" layer.

## Scenario Authoring And Validation

Strengths:

- YAML scenarios are readable and heavily commented.
- Base-plus-delta composition is a good mental model for teaching scenarios.
- Strict validation is a major improvement for student errors.
- Management actions are represented with explicit years and vectors, making
  intervention scenarios inspectable.

Teaching-readiness gaps:

- There is no student-facing schema reference or "what can I safely change?"
  table.
- Error messages are useful for developers, but students need a troubleshooting
  translation layer.
- The difference between live YAML keys, commented placeholders, and deprecated
  fields needs documentation.
- The sensitivity-analysis exercise needs bounded recipes, for example:
  "Change exactly one of survival, K, catastrophe frequency, or fecundity; keep
  a control run; record PE and Nmed; explain ecological plausibility."

Road-test implication: scenario authoring is close, but validation needs to be
paired with teaching documentation.

## Diagnostics, Plotting, And Reporting

Strengths:

- Matrix diagnostics are available through `plot_pva_matrix()`.
- Trajectory, summary, extinction, inbreeding, and sex-ratio plotting are
  available.
- `plot_pva_panel()` can combine the main visuals.
- Numeric summaries include PE, median final abundance, and 95 percent
  intervals for final survivors.

Teaching-readiness gaps:

- Plot titles and labels are not yet report-polished. Some titles are compact
  developer labels rather than student/report labels.
- There is no one-call "make Woodhen report bundle" that returns the standard
  table and figure set for assessment.
- There is no interpretation helper that turns scenario outputs into deltas,
  relative risk reduction, or management comparison text.
- Students need explicit guidance on conditional versus unconditional summaries
  and why extinction probability and final abundance can tell different
  stories.
- Report production is not scaffolded. There is no Quarto/R Markdown template,
  example answer, figure caption checklist, or marking rubric.

Road-test implication: reporting support is the biggest teaching gap after the
worksheet itself.

## Interface Options, Including RShiny

A better interface should support these tasks before choosing technology:

- select or duplicate a scenario
- change a bounded set of parameters with ecological explanations
- run deterministic, stochastic, and management scenarios
- compare scenarios in a standard table
- render standard plots
- show assumptions and warnings near the parameter being changed
- export report-ready tables/figures
- preserve reproducibility: seed, YAML/spec, package version, and date

Option 1: scripted/tutorial workflow

- Best next step.
- Low implementation cost.
- Keeps students close to R code and reproducible research practice.
- Exposes PVA concepts directly.
- Required before any UI can be designed honestly.

Option 2: lightweight R helpers/report templates

- Good second step.
- A `make_woodhen_report_inputs()` or similar helper and a Quarto template
  could standardize outputs without hiding the workflow.
- This would also define requirements for Shiny.

Option 3: RShiny

- Attractive later, especially for professional users and demos.
- Not a must-do before the road test unless the teaching goal changes from
  "learn PVA in R" to "explore PVA through a GUI".
- Premature now because the pedagogical flow, report products, and parameter
  guardrails are not yet fully specified.

Recommendation: do a UI requirements spike during the road-test preparation,
but defer Shiny implementation until the scripted Woodhen practical and report
template have been tested.

## Testing And CI

Strengths:

- CI covers dependency setup, bootstrap, full `testthat`, and Woodhen smoke.
- Scenario tests pin the five core Woodhen summaries.
- Validation tests cover strict schema and important edge cases.
- Prior semantic-equivalence evidence is durable and documented.

Teaching-readiness gaps:

- CI does not yet exercise rendered teaching documents, because none exist.
- There is no test for a student-report workflow or standard figure/table
  bundle.
- Optional plotting with `ggrastr` remains intentionally outside default CI.
  That is acceptable, but should not become part of teaching assumptions.
- The CI dependency setup is relatively slow. This is not a classroom problem,
  but it affects development feedback time.

Road-test implication: CI is good enough for engine confidence. Add teaching
artifact checks only after the teaching materials exist.

## Ranked Roadmap

### Must Do Before Road Test

1. Create the two-practical teaching kit.

   Deliver student worksheets for Practical 1 and Practical 2, an instructor
   guide, expected outputs, and a glossary. This is the main blocker for the
   zero-to-hero goal.

2. Package the Woodhen workflow as a guided road-test path.

   Convert `inst/extdata/woodhen/woodhen.R` and scenario comments into a
   stepwise practical: run baseline, compare interventions, perform one
   bounded sensitivity analysis, and record standard outputs.

3. Add a report scaffold.

   Provide a Quarto or R Markdown report template with sections for methods,
   scenario table, plots, uncertainty, assumptions, management interpretation,
   and limitations. Include a short marking rubric or checklist.

4. Add interpretation support.

   Students need explicit prompts and helper outputs for PE, Nmed, intervals,
   management deltas, conditional vs unconditional abundance, and why a
   scenario with `PE = 0` still has uncertainty.

5. Write a setup and troubleshooting guide for the teaching room.

   Include recommended R version, bootstrap path, expected run times, common
   errors, how to restore `renv`, and what to do if plotting or package loading
   fails.

### Should Do If Time Allows

6. Create a student-safe scenario authoring reference.

   Include live YAML keys, allowed ranges, safe changes for the sensitivity
   exercise, and examples of bad changes with the validation error they trigger.

7. Create standard Woodhen output helpers or a standard report-input object.

   This could be code in a later implementation goal, but the audit-level
   design should specify the table and plots first.

8. Polish plot labels and report aesthetics.

   Improve titles, captions, axis labels, and legends for classroom reporting.

9. Add a rendered-document CI check once teaching documents exist.

   Keep it cheap: render one compact teaching/report template with a reduced
   scenario if needed.

10. Draft RShiny requirements and wireframes.

   Define what the app must do and what it must not hide. Do not build it until
   the scripted workflow has been road-tested.

### Defer Until After Road Test

11. Full RShiny implementation.

   Build after the teaching path proves which controls, diagnostics, and
   exports matter.

12. New case-study expansion beyond Woodhen.

   Thylacine and other cases can broaden appeal later, but Woodhen should be
   made excellent first.

13. Optional raster plotting dependency work.

   Keep `ggrastr` optional unless there is a clear teaching need for very large
   trajectory plots.

14. Scientific model changes or new assumptions.

   Any changes to Woodhen assumptions, defaults, or model structure need
   Barry's domain judgement and should be separate from teaching packaging.

15. Large simulation or HPC scaling work.

   Not needed for a two-class road test.

## Recommended Next Goals

1. `005-woodhen-teaching-practical-kit`

   Produce the two practical worksheets, instructor guide, glossary,
   troubleshooting page, expected outputs, and report/rubric scaffold. This
   should be mostly documentation and teaching design, with no engine changes.

2. `006-woodhen-report-and-diagnostics-scaffold`

   Specify and then implement the minimal report-ready table/plot/diagnostic
   support needed by the Woodhen practical. This may include small helper
   functions if Barry approves code changes in that goal.

3. `007-interface-requirements-and-shiny-design-spike`

   Design the future student/professional interface after the scripted workflow
   is clear. Deliver requirements, wireframes, and a decision on whether to
   prototype Shiny before or after the road test.

## Residual Risks

- The audit did not run a full `R CMD check`, because the packet did not
  require it and the current state matched recent full validation evidence.
- The audit did not independently review Woodhen scientific assumptions.
- Teaching-readiness ranking is based on repository inspection and cheap smoke
  checks, not a live student trial.
- No UI prototype was built, by design.
- No package code, YAML, CI, dependency, or README changes were made in this
  goal.

