# Woodhen Teaching Kit

This folder contains the first teaching-focused teaching kit for the `rPVA` road
test, built as two three-hour practicals for third-year students with no prior
PVA background.

Target students: ecology, conservation, or applied modelling classes.

## Contents

- `practical-1-pva-foundations.md`
- `practical-2-woodhen-management.md`
- `instructor-guide.md`
- `expected-outputs.md`
- `glossary.md`
- `troubleshooting.md`
- `report-scaffold.qmd`
- `marking-rubric.md`

## Quick start for students

Run from the repo root in R:

```r
source("bootstrap.R")
```

Each practical is designed to be run independently, but best delivered in this
order:

1. `practical-1-pva-foundations.md`
2. `practical-2-woodhen-management.md`

For each worksheet:

- Run the listed code blocks exactly as shown.
- Fill response boxes.
- Save all R outputs for your short report.

## Teaching outcomes

After these two practicals, students should be able to:

- explain the core PVA mechanics (growth, stochasticity, density limits, extinction),
- run the toy model and interpret its outputs,
- run and compare Woodhen scenarios,
- run a bounded one-factor sensitivity exercise,
- produce a short assessment-style interpretation with uncertainty and management
  implications.

## What is in scope

- Student-facing worksheets and assessment scaffolds.
- Instructor guidance.
- Terminology support and troubleshooting.
- Expected reference outputs.

## What is explicitly out of scope

- package code changes,
- scenario/YAML edits,
- dependency/CI adjustments,
- Shiny implementation.
