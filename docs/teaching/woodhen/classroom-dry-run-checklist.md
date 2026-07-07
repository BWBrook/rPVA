# Classroom Dry-Run Checklist

Use this checklist on the teaching machine before the Woodhen road-test session.
It is written for demonstrators who need to confirm the workflow, not diagnose
package internals.

## Before Students Arrive

- Start from the repository root.
- Run `source("bootstrap.R")` in R and confirm the ready message appears.
- Open `practical-1-pva-foundations.md`, `practical-2-woodhen-management.md`,
  `expected-outputs.md`, `troubleshooting.md`, and
  `practical-1-fallback-pack.md`.
- Open `practical-1-day-of-class-pack.md` and
  `practical-1-go-no-go-checklist.md` for the app-led delivery decision.
- Render the report scaffold to a temp output folder with sample staff
  validation choices:

```sh
RPVA_DECISION_LENS="classroom validation" \
RPVA_SELECTED_SCENARIO_ID="02_pig_control" \
RPVA_CHOSEN_SENSITIVITY_ID="K_350" \
RPVA_SENSITIVITY_REASON="Habitat recovery may be incomplete." \
RPVA_EXPECTED_DIRECTION="A lower habitat ceiling should reduce final abundance." \
RPVA_ADVICE_CHANGE_CONDITION="Advice would change if lower habitat capacity sharply reduced recovery confidence." \
quarto render docs/teaching/woodhen/report-scaffold.qmd --to docx --output-dir /tmp/rpva-teaching-report

RPVA_DECISION_LENS="classroom validation" \
RPVA_SELECTED_SCENARIO_ID="02_pig_control" \
RPVA_CHOSEN_SENSITIVITY_ID="K_350" \
RPVA_SENSITIVITY_REASON="Habitat recovery may be incomplete." \
RPVA_EXPECTED_DIRECTION="A lower habitat ceiling should reduce final abundance." \
RPVA_ADVICE_CHANGE_CONDITION="Advice would change if lower habitat capacity sharply reduced recovery confidence." \
quarto render docs/teaching/woodhen/report-scaffold.qmd --to pdf --output-dir /tmp/rpva-teaching-report
```

If PDF fails but DOCX succeeds, keep teaching with DOCX and record the PDF tool
error for later setup work. Render DOCX and PDF sequentially.

## Practical 1 Checkpoints

- `run_toy_demo(keep_traj = TRUE, plot_matrix = FALSE, verbose = FALSE)` runs.
- `toy$summary` matches `expected-outputs.md` closely:
  - `det`, `ceiling`, `demographic_stochasticity`, and `env_sd` have `PE = 0`.
  - `genetics` has `PE = 0.07` and `N_med = 60`.
- A trajectory plot, summary plot, and extinction plot display or write to a PDF
  device.
- Students can explain why `keep_traj = TRUE` matters for trajectory/extinction
  plots.
- If using the Practical 1 Shiny concept lab, students can save the comparison
  CSV and evidence-notes Markdown file from the Compare screen.
- If Shiny is unavailable, use `practical-1-fallback-pack.md` and keep the same
  interpretation target: extinction risk, final abundance, and uncertainty.

## Practical 2 Checkpoints

- `run_scenarios("woodhen", csv_out = NULL, rds_out = NULL, keep_traj = FALSE,
  parallel = FALSE)` runs and matches the five-row reference table.
- The `02_pig_control` diagnostic example reports:
  - `PE = 0.566`
  - `Nmed = 57`
  - a `high_extinction_probability` warning.
- The bounded sensitivity table has four rows:
  - `baseline`
  - `survival_minus_10pct`
  - `K_250`
  - `cat_freq_0.10`
- Students can state which comparison is a management scenario and which is a
  one-factor sensitivity check.

## End-Of-Practical Evidence

Each group should leave with:

- their command log,
- one toy-model figure or output table,
- the Practical 1 Shiny comparison CSV and evidence-notes file, if the browser
  app was used,
- one Woodhen scenario table,
- one management-scenario plot,
- one bounded sensitivity table,
- checkpoint answers from both practicals,
- a started report scaffold with one management recommendation and one caveat.

## Demonstrator Triage

- If `source("bootstrap.R")` fails, use `troubleshooting.md` before continuing.
- If plots are blank, rerun the simulation with `keep_traj = TRUE`.
- If `PE = 0` is treated as proof of safety, redirect students to uncertainty,
  horizon length, and unmodelled ecological processes.
- If scenario tables differ from `expected-outputs.md`, check whether a seed,
  scenario key, or one-factor sensitivity input was changed.
- If app downloads fail, ask students to retry once, then switch to the
  fallback pack rather than losing class time to browser-specific download
  debugging.
