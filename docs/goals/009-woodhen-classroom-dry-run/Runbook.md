# Runbook

## Required First Commands

```sh
git status --short --branch --ignored=matching
git log --oneline --decorate --max-count=8
Rscript -e 'source("bootstrap.R"); print(renv::status(sources = FALSE))'
```

Stop if tracked files outside the new Goal 009 packet are dirty before work
begins.

## Read-First Commands

```sh
sed -n '1,240p' docs/teaching/woodhen/README.md
sed -n '1,260p' docs/teaching/woodhen/practical-1-pva-foundations.md
sed -n '1,300p' docs/teaching/woodhen/practical-2-woodhen-management.md
sed -n '1,260p' docs/teaching/woodhen/instructor-guide.md
sed -n '1,260p' docs/teaching/woodhen/expected-outputs.md
sed -n '1,220p' docs/teaching/woodhen/report-scaffold.qmd
sed -n '1,260p' docs/teaching/woodhen/troubleshooting.md
sed -n '1,260p' docs/goals/008-teaching-render-readiness/Log.md
```

## Narrow Edit Targets

Allowed files are:

```text
docs/teaching/woodhen/*.md
docs/teaching/woodhen/report-scaffold.qmd
docs/goals/009-woodhen-classroom-dry-run/Log.md
docs/codex/<optional-short-audit-note>.md
```

Do not edit:

```text
R/
NAMESPACE
DESCRIPTION
renv.lock
tests/
.github/
inst/extdata/
```

## Dry-Run Commands

Practical 1 smoke:

```sh
Rscript -e 'source("bootstrap.R"); toy <- run_toy_demo(keep_traj = TRUE, plot_matrix = FALSE, verbose = FALSE); print(toy$summary); pdf(tempfile(fileext = ".pdf")); plot_pva_summary(toy$results$genetics); plot_ext(toy$results$genetics); dev.off()'
```

Practical 2 scenario table:

```sh
Rscript -e 'source("bootstrap.R"); tbl <- run_scenarios("woodhen", csv_out = NULL, rds_out = NULL, keep_traj = FALSE, parallel = FALSE); print(tbl)'
```

Practical 2 helper/plot pattern:

```sh
Rscript -e 'source("bootstrap.R"); spec <- set_scenario("02_pig_control", "woodhen"); sim <- run_pva_core(spec, keep_traj = TRUE, seed = 123, verbose = FALSE); print(summarize_pva_result(sim)); print(diagnose_pva_result(sim)); pdf(tempfile(fileext = ".pdf")); print(plot_pva_panel(plot_pva_traj(sim, sample = 50), plot_pva_summary(sim), plot_ext(sim))); dev.off()'
```

Bounded sensitivity:

```sh
Rscript -e 'source("bootstrap.R"); base <- set_scenario("sensitivity_analysis", "woodhen"); s1 <- run_pva_core(base, keep_traj = FALSE, seed = 123); s2 <- run_pva_core(modifyList(base, list(surv = base$surv * 0.90)), keep_traj = FALSE, seed = 123); s3 <- run_pva_core(modifyList(base, list(K = 250)), keep_traj = FALSE, seed = 123); s4 <- run_pva_core(modifyList(base, list(cat_freq = 0.10)), keep_traj = FALSE, seed = 123); print(compare_pva_results(list(s1, s2, s3, s4), scenarios = c("baseline", "survival_minus_10pct", "K_250", "cat_freq_0.10")))'
```

Report scaffold:

```sh
rm -rf /tmp/rpva-goal009-render
mkdir -p /tmp/rpva-goal009-render/docx /tmp/rpva-goal009-render/pdf
quarto render docs/teaching/woodhen/report-scaffold.qmd --to docx --output-dir /tmp/rpva-goal009-render/docx
quarto render docs/teaching/woodhen/report-scaffold.qmd --to pdf --output-dir /tmp/rpva-goal009-render/pdf
find /tmp/rpva-goal009-render -maxdepth 3 -type f | sort
```

## Final Checks

```sh
Rscript -e 'source("bootstrap.R"); testthat::test_local()'
git diff --check
find docs/teaching/woodhen -maxdepth 1 -type f \( -name 'report-scaffold.pdf' -o -name 'report-scaffold.docx' -o -name 'report-scaffold.html' -o -name 'report-scaffold.knit.md' -o -name '.gitignore' \) -print
git diff --name-only
git status --short --branch --ignored=matching
```

If Quarto regenerates `docs/teaching/woodhen/.gitignore`, remove it before
final status; the root ignore rule from Goal 008 should keep it out of status
noise, but the teaching folder should not keep the generated helper file.

## Final Response Shape

Include:

- whether formal goal mode was active
- changed files
- dry-run commands and outcomes
- report scaffold render outcomes
- expected-output mismatches found or confirmed absent
- full test and diff hygiene outcomes
- residual risks
- final git status
