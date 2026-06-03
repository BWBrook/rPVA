# Engine Affordance Audit For Practical 1 Shiny

## Purpose

This audit maps the current `rPVA` engine, helpers, and scenarios to a future
Practical 1 Shiny concept lab. It identifies what can be used as-is, what needs
a small wrapper, and what is a genuine gap.

This is a design audit only. It does not change package code.

## Current Ready-To-Use Pieces

| Need | Current support | Notes |
| --- | --- | --- |
| Run a single PVA simulation | `run_pva_core(spec, keep_traj, seed, verbose)` | Core engine supports deterministic and stochastic runs from a list spec. |
| Run the toy concept sequence | `run_toy_demo()` | Already returns named results and a summary table for deterministic, carrying capacity, demographic stochasticity, environmental stochasticity, and genetics. |
| Load case-study scenarios | `set_scenario(scen_name, subdir)` | Good for Woodhen Practical 2 and any future scenario folder. |
| Batch-run scenario folders | `run_scenarios(subdir, csv_out, rds_out, keep_traj, parallel)` | Useful for instructor-side comparison and Practical 2, less ideal as the direct Shiny event handler because it prints scenario names. |
| Summarise one result | `summarize_pva_result()` | Strong app-facing candidate: compact, report-ready, and already student-oriented. |
| Compare multiple results | `compare_pva_results()` | Strong app-facing candidate for the compare screen. |
| Provide diagnostic prompts | `diagnose_pva_result()` | Strong app-facing candidate for plain-language warnings and interpretation prompts. |
| Plot trajectories | `plot_pva_traj()` | Useful when `keep_traj = TRUE`; Shiny will need to manage sampling and render contexts. |
| Plot summary interval | `plot_pva_summary()` | Useful for concept and compare screens. |
| Plot extinction, mean F, and sex ratio | `plot_ext()` | Useful for genetics and extinction-risk stages; requires trajectory outputs. |
| Plot matrix diagnostics | `plot_pva_matrix()` | Useful for instructor/demo mode; may be too advanced for the default student flow. |
| Validate specs | `validate_full_pva_spec()` and related helpers | Important for guarding Shiny controls before model calls. |
| Read YAML specs | `read_spec()` | Useful for internal loading, but students should not interact with YAML in Practical 1. |

## Scenario Assets

### Toy Scenario

`inst/extdata/toy/toy_demo.yaml` provides the right conceptual base for
Practical 1:

- three-stage species,
- deterministic baseline,
- optional carrying capacity,
- demographic stochasticity,
- environmental stochasticity,
- genetics.

The current `run_toy_demo()` function constructs the staged versions in R using
`modifyList()`. This is useful because a future app can use the same pattern
without requiring students to edit YAML.

### Woodhen Scenarios

`inst/extdata/woodhen/` provides:

- `01_no_mgmt.yaml`
- `02_pig_control.yaml`
- `03_captive_pig.yaml`
- `04_rodent_eradication.yaml`
- `05_future_baseline.yaml`
- `sensitivity_analysis.yaml`

These are Practical 2 assets. They should remain available from the app only
when the student has moved from concept mode into Woodhen transfer mode, or in a
separate Practical 2 interface.

## Ready-To-Use Engine Concepts

The engine already supports these Practical 1 concepts:

- deterministic population projection,
- stage-structured demography,
- carrying capacity via `K` and `K_sd`,
- demographic stochasticity via `demographic_stochasticity`,
- environmental stochasticity via `env_sd`,
- catastrophes via `cat_freq`, `cat_surv`, and `cat_repro`,
- genetics via `genetics`, `F_init`, `lethal_equiv`, `B_on_fec`,
  `Ne_N_ratio`, `Ne_window`, and `purge_kappa`,
- removals via `removal_years` and `removal_vec`,
- releases via `release_years` and `release_vec`,
- monogamy or mate limitation through `monogamy` and `sex_ratio_init`,
- output summaries for extinction probability and abundance intervals.

This is enough for a credible minimum viable Practical 1 app.

## Pieces Needing Thin Wrappers

### Teaching Scenario Builder

The app should not hand-edit arbitrary lists in server code for each input. A
small future helper could accept a teaching-stage identifier and bounded control
values, then return a validated `pva_spec`.

Suggested future API:

```r
build_teaching_spec(stage, controls, base = "toy")
```

Responsibilities:

- start from the toy base,
- apply only allowed changes for the selected stage,
- coerce simple UI values into engine fields,
- validate the final spec,
- return a spec ready for `run_pva_core()`.

### Teaching Run Wrapper

The app will need one function that runs a spec and returns a consistent object
for UI rendering.

Suggested future API:

```r
run_teaching_pva(spec, keep_traj = TRUE, seed = 42)
```

Responsibilities:

- call `run_pva_core()`,
- attach a student-facing scenario label,
- attach a compact settings record,
- compute `summarize_pva_result()` and `diagnose_pva_result()`,
- avoid console output in Shiny contexts.

### Comparison Bundle

The compare screen should receive a simple bundle rather than raw result lists.

Suggested future API:

```r
compare_teaching_runs(results)
```

Responsibilities:

- call `compare_pva_results()`,
- preserve run labels and stage order,
- return a table safe for download,
- include any diagnostic messages needed by the app.

### Export Bundle

Practical 1 and Practical 2 both need compact exports that support student
reports without becoming a second assessment stream.

Suggested future API:

```r
export_teaching_evidence(results, selected_plots, path)
```

Responsibilities:

- export a scenario table,
- export selected plots,
- export a settings record,
- avoid large raw trajectory files by default.

## Genuine Gaps

### Named Allee-Effect Module

The engine does not expose a named Allee-effect process. It can approximate
parts of the concept through monogamy/mate limitation, low abundance, and
demographic stochasticity, but a clear teaching control would need a small
future helper or engine extension.

For the first road test, the safest option is a labelled teaching proxy:

- low-abundance fecundity penalty,
- mate-limitation demonstration,
- or instructor-led explanation that the current engine represents related
  mechanisms rather than a formal Allee module.

### Correlated Environmental Events

The engine has environmental stochasticity and catastrophes, but does not
present a separate student-facing "correlated bad years" control. A future thin
wrapper could construct a controlled set of correlated adverse years before
calling the engine, or this could remain an instructor-led concept in the first
Shiny version.

### Shiny-Safe Plot Return Behaviour

The plotting helpers print plots as a side effect and return ggplot objects
invisibly. That works in interactive R, but a Shiny implementation may benefit
from wrapper functions that return plot objects without unexpected console or
device behaviour.

### Long-Run Responsiveness

The engine is adequate for teaching-scale runs, but the app will need UI-level
guardrails:

- bounded replicate counts,
- progress indicators,
- caching for repeated default runs,
- sampled trajectory plotting,
- clear messages when a run is too expensive for classroom use.

## Minimum Shiny-Facing API

A minimum viable Practical 1 app should call only a small package-facing surface:

- `build_teaching_spec(stage, controls, base = "toy")`
- `run_teaching_pva(spec, keep_traj = TRUE, seed = 42)`
- `summarize_pva_result(out, scenario = label)`
- `diagnose_pva_result(out, scenario = label)`
- `compare_teaching_runs(results)`
- existing plot functions through Shiny-safe wrappers.

The app should not call arbitrary YAML paths, write scenario files, or expose
raw `modifyList()` editing to students.

## Refactor Guidance

Large engine refactors are not needed for the first Shiny road test. The most
valuable future work is a small adapter layer that:

- turns safe UI controls into validated specs,
- standardises labels and outputs,
- wraps plotting for Shiny,
- packages exports,
- keeps all scientific assumptions visible and testable.

That adapter layer would also help later Practical 2 and assessment-support
interfaces without changing the core simulator.
