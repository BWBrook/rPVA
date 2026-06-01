# Runbook

## Required First Commands

```sh
git status --short --branch
git log --oneline --decorate --max-count=8
```

Stop if tracked package source files are dirty before you begin.

Expected dirty state at start:

- untracked Goal 004 management artefacts
- untracked Goal 005 management packet

## Read-First Commands

Use direct file reads or `rg`/`find` as useful. Start with:

```sh
sed -n '1,260p' docs/codex/post-merge-readiness-audit-2026-06-01.md
sed -n '1,260p' README.md
sed -n '1,220p' inst/extdata/toy/toy_demo.R
sed -n '1,220p' inst/extdata/woodhen/woodhen.R
find inst/extdata/woodhen -maxdepth 1 -type f | sort
```

## Teaching Directory

Create:

```text
docs/teaching/woodhen/
  README.md
  practical-1-pva-foundations.md
  practical-2-woodhen-management.md
  instructor-guide.md
  expected-outputs.md
  glossary.md
  troubleshooting.md
  report-scaffold.qmd
  marking-rubric.md
```

## Content Rules

- Write for third-year undergraduate students who are new to PVA.
- Keep instructions runnable in the project root after `source("bootstrap.R")`.
- Prefer explicit assignment and printing in R snippets so novices see output.
- Name when `keep_traj = TRUE` is required for plots.
- Do not imply that Woodhen scenario values are definitive if they are teaching
  simplifications.
- Separate "what to do", "what to notice", and "what to write in the report".
- Use placeholders for student answers, but do not leave unresolved author
  TODOs.

## Suggested Cheap Checks

Run after drafting enough material that the snippets are settled:

```sh
git diff --check
Rscript -e 'source("bootstrap.R"); toy <- run_toy_demo(keep_traj = FALSE, plot_matrix = FALSE, verbose = FALSE); print(toy$summary)'
Rscript -e 'source("bootstrap.R"); tbl <- run_scenarios("woodhen", csv_out=NULL, rds_out=NULL, keep_traj=FALSE, parallel=FALSE); print(tbl)'
```

Optional, only if useful and cheap:

```sh
Rscript -e 'source("bootstrap.R"); spec <- set_scenario("01_no_mgmt"); out <- run_pva_core(spec, keep_traj = TRUE); print(out[c("PE", "Nmed", "Nlo95", "Nhi95")])'
```

Do not run heavy simulations or remote jobs.

## Final Checks

Before final response:

```sh
git status --short --branch
find docs/teaching/woodhen -maxdepth 1 -type f | sort
```

Record final state in `Log.md`.

## Final Response Shape

Include:

- created teaching files
- validation commands and pass/fail outcomes
- note on whether the first-line goal-mode prefix worked
- residual risks
- final git status
- recommended next supervisor decision
