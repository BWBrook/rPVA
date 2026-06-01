# Log

## 2026-06-01 - Goal Created By Supervisor

Goal 009 created after Goal 008 was committed and pushed to `main` as
`f5c569e Publish Goal 008 teaching render readiness`.

Selected task: dry-run the Woodhen teaching kit as a classroom workflow and make
small teaching-document fixes backed by runnable evidence.

Supervisor model decision:

- use `gpt-5.5`
- use `thinking = "high"`

Reasoning:

- This goal is more pedagogical and judgement-heavy than a pure cleanup task.
- The action agent must evaluate student friction, demonstrator needs, and
  classroom sequencing, not just run commands.
- The implementation surface is still bounded to teaching documents and logs.

Known starting context:

- `main` is synced with `origin/main` at `f5c569e`.
- Goal 008 made the report scaffold renderable to DOCX and PDF.
- Full tests passed at Goal 008 publication: `[ FAIL 0 | WARN 0 | SKIP 0 | PASS 110 ]`.
- Current desired next state is a stronger two-practical road-test path, still
  without Shiny, engine changes, scenario changes, or dependency changes.

Action agent should append dated execution entries below.

## 2026-06-01 - Execution Start

- Confirmed starting state:
  - `git status --short --branch --ignored=matching` -> `main...origin/main`,
    with only `?? docs/goals/009-woodhen-classroom-dry-run/` and
    `!! renv/staging/`.
  - `git log --oneline --decorate --max-count=8` -> HEAD
    `f5c569e (HEAD -> main, origin/main, origin/HEAD) Publish Goal 008 teaching render readiness`.
  - `Rscript -e 'source("bootstrap.R"); print(renv::status(sources = FALSE))'`
    equivalent status check -> synchronized / no issues found.
- No dirty tracked package, metadata, scenario, dependency, CI, test, or teaching
  files were present before implementation.

## 2026-06-01 - Dry-Run Evidence

- Read teaching docs in delivery order:
  - `README.md`
  - `practical-1-pva-foundations.md`
  - `practical-2-woodhen-management.md`
  - `instructor-guide.md`
  - `expected-outputs.md`
  - `report-scaffold.qmd`
  - `troubleshooting.md`
  - Goal 008 `Log.md`
- Practical 1 smoke:
  - `Rscript -e 'source("bootstrap.R"); toy <- run_toy_demo(keep_traj = TRUE, plot_matrix = FALSE, verbose = FALSE); print(toy$summary); pdf(tempfile(fileext = ".pdf")); plot_pva_summary(toy$results$genetics); plot_ext(toy$results$genetics); dev.off()'`
  - Result: passed; summary matched `expected-outputs.md`:
    - `det`: `PE = 0`, `N_med = 264`
    - `ceiling`: `PE = 0`, `N_med = 85`
    - `demographic_stochasticity`: `PE = 0`, `N_med = 82`
    - `env_sd`: `PE = 0`, `N_med = 70`
    - `genetics`: `PE = 0.07`, `N_med = 60`
  - `run_toy_demo(keep_traj = FALSE, plot_matrix = FALSE, verbose = FALSE)$summary`
    also matched the same summary table.
- Practical 2 scenario table:
  - `Rscript -e 'source("bootstrap.R"); tbl <- run_scenarios("woodhen", csv_out = NULL, rds_out = NULL, keep_traj = FALSE, parallel = FALSE); print(tbl)'`
  - Result: passed; five-row table matched `expected-outputs.md`:
    - `woodhen_no_intervention`: `PE = 0.666`, `Nmed = 16`
    - `woodhen_pig_control`: `PE = 0.566`, `Nmed = 57`
    - `woodhen_captive_pig`: `PE = 0.082`, `Nmed = 119`
    - `woodhen_rat_eradication`: `PE = 0`, `Nmed = 832`
    - `woodhen_future_baseline`: `PE = 0`, `Nmed = 1510`
- Practical 2 diagnostic/plot pattern:
  - `02_pig_control` with `keep_traj = TRUE`, `seed = 123` passed.
  - `summarize_pva_result()` returned `PE = 0.566`, `Nmed = 57`, `Nlo95 = 2`,
    `Nhi95 = 184`, `extinct_reps = 566`, `trajectory_available = TRUE`.
  - `diagnose_pva_result()` returned `high_extinction_probability` warning and
    `wide_final_abundance_interval` note.
  - Headless PDF plotting device completed and closed.
- Bounded sensitivity:
  - `compare_pva_results()` for baseline, `survival_minus_10pct`, `K_250`, and
    `cat_freq_0.10` passed.
  - Output matched expected reference values:
    - `baseline`: `PE = 0`, `Nmed = 1510`, `Nlo95 = 1109`, `Nhi95 = 1957`
    - `survival_minus_10pct`: `PE = 0`, `Nmed = 1484`, `Nlo95 = 1091`,
      `Nhi95 = 1968`
    - `K_250`: `PE = 0`, `Nmed = 745`, `Nlo95 = 466`, `Nhi95 = 1070`
    - `cat_freq_0.10`: `PE = 0`, `Nmed = 1483`, `Nlo95 = 1052`, `Nhi95 = 1975`
- Report scaffold:
  - rendered DOCX and PDF to `/tmp/rpva-goal009-render/{docx,pdf}`.
  - Outputs:
    - `/tmp/rpva-goal009-render/docx/report-scaffold.docx`
    - `/tmp/rpva-goal009-render/pdf/report-scaffold.pdf`
- Expected-output comparison:
  - No stale expected-output values found.
  - No `expected-outputs.md` edits were required.

## 2026-06-01 - Teaching Document Polish

- Added `docs/teaching/woodhen/classroom-dry-run-checklist.md` for demonstrator
  pre-class and end-of-practical checks.
- Updated `README.md` to list the checklist and direct demonstrators to use it.
- Updated `instructor-guide.md` to add the checklist to pre-class setup and to
  include the Practical 1 toy summary in minimum group evidence.
- Updated `practical-1-pva-foundations.md` with a small note that
  `plot_matrix = FALSE` is acceptable if a matrix plot window interrupts the R
  session; the summary table is unchanged.
- Updated `report-scaffold.qmd` so its sensitivity block includes the same four
  bounded cases used in Practical 2 and `expected-outputs.md`, adding
  `cat_freq_0.10`.

## 2026-06-01 - Final Validation

- Reran:
  - `rm -rf /tmp/rpva-goal009-render && mkdir -p /tmp/rpva-goal009-render/docx /tmp/rpva-goal009-render/pdf`
  - `quarto render docs/teaching/woodhen/report-scaffold.qmd --to docx --output-dir /tmp/rpva-goal009-render/docx`
  - `quarto render docs/teaching/woodhen/report-scaffold.qmd --to pdf --output-dir /tmp/rpva-goal009-render/pdf`
  - `Rscript -e 'source("bootstrap.R"); testthat::test_local()'`
  - `git diff --check`
  - `find docs/teaching/woodhen -maxdepth 1 -type f ( -name 'report-scaffold.pdf' -o -name 'report-scaffold.docx' -o -name 'report-scaffold.html' -o -name 'report-scaffold.knit.md' -o -name '.gitignore' )`
  - `git diff --name-only`
  - `git status --short --branch --ignored=matching`
- Results:
  - DOCX render passed.
  - PDF render passed.
  - `testthat::test_local()` passed: `[ FAIL 0 | WARN 0 | SKIP 0 | PASS 110 ]`.
  - `git diff --check` passed.
  - Removed Quarto-generated `docs/teaching/woodhen/.gitignore` after render.
  - No report scaffold DOCX/PDF/HTML/knit artefacts or local helper `.gitignore`
    remain in `docs/teaching/woodhen`.
  - Changed files are within the allowed surface:
    - `docs/teaching/woodhen/README.md`
    - `docs/teaching/woodhen/instructor-guide.md`
    - `docs/teaching/woodhen/practical-1-pva-foundations.md`
    - `docs/teaching/woodhen/report-scaffold.qmd`
    - `docs/teaching/woodhen/classroom-dry-run-checklist.md`
    - `docs/goals/009-woodhen-classroom-dry-run/Log.md`
  - Final status remains on `main...origin/main`, with only expected teaching/log
    edits, untracked Goal 009 packet, untracked checklist, and ignored
    `renv/staging/`.
- Formal goal mode appeared active for this run.

## 2026-06-01 - Supervisor Acceptance

- Supervisor reviewed the changed teaching docs and new checklist.
- Supervisor reran acceptance gates:
  - DOCX render to `/tmp/rpva-supervisor-goal009-render/docx`: passed.
  - PDF render to `/tmp/rpva-supervisor-goal009-render/pdf`: passed.
  - `Rscript -e 'source("bootstrap.R"); testthat::test_local()'`: passed with
    `[ FAIL 0 | WARN 0 | SKIP 0 | PASS 110 ]`.
  - `git diff --check`: passed.
  - no report scaffold PDF/DOCX/HTML/knit outputs and no local Quarto helper
    `.gitignore` remain in `docs/teaching/woodhen/`.
- Accepted changed scope:
  - `docs/teaching/woodhen/README.md`
  - `docs/teaching/woodhen/instructor-guide.md`
  - `docs/teaching/woodhen/practical-1-pva-foundations.md`
  - `docs/teaching/woodhen/report-scaffold.qmd`
  - `docs/teaching/woodhen/classroom-dry-run-checklist.md`
  - `docs/goals/009-woodhen-classroom-dry-run/`
- Supervisor verdict: accepted. Pause before Goal 010 or Goal 009
  commit/push packaging.

## 2026-06-01 - Publication Validation and Push

- Rechecked working tree before commit:
  - `git status --short --branch` shows only:
    - `docs/teaching/woodhen/README.md` (modified)
    - `docs/teaching/woodhen/instructor-guide.md` (modified)
    - `docs/teaching/woodhen/practical-1-pva-foundations.md` (modified)
    - `docs/teaching/woodhen/report-scaffold.qmd` (modified)
    - `docs/teaching/woodhen/classroom-dry-run-checklist.md` (untracked)
    - `docs/goals/009-woodhen-classroom-dry-run/` (untracked)
- Publication validation commands:
  - `git diff --check` passed with no whitespace or patch issues.
  - Rendered DOCX and PDF to `/tmp/rpva-goal009-pub/docx` and
    `/tmp/rpva-goal009-pub/pdf` successfully:
    - `/tmp/rpva-goal009-pub/docx/report-scaffold.docx`
    - `/tmp/rpva-goal009-pub/pdf/report-scaffold.pdf`
  - `Rscript -e 'source("bootstrap.R"); testthat::test_local()'` passed:
    - `[ FAIL 0 | WARN 0 | SKIP 0 | PASS 110 ]`.
- Staged exact publish paths only:
  - `docs/teaching/woodhen/README.md`
  - `docs/teaching/woodhen/instructor-guide.md`
  - `docs/teaching/woodhen/practical-1-pva-foundations.md`
  - `docs/teaching/woodhen/report-scaffold.qmd`
  - `docs/teaching/woodhen/classroom-dry-run-checklist.md`
  - `docs/goals/009-woodhen-classroom-dry-run/Log.md`
- Commit created: `Publish Goal 009 classroom dry-run audit`.
- Push sent to `origin/main` and accepted by remote `main`.
- Final status after push:
  - `git status --short --branch` clean: `## main...origin/main`.
