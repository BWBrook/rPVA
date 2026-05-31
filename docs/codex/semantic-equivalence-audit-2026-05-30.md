# rPVA semantic equivalence audit - 2026-05-30

## Scope

Executor: `rpva_agent`

Repository: `/Users/bwbrook/git/rPVA`

Branch: `codex/refactor-pva-core`

Comparison target:

- `origin/main`: `dfc7c12`
- refactor package-code point: `ea56a9e`

No merge to `main`, pull request, broad model redesign, remote/HPC run, or
optional dependency policy change was performed. The Mac mini was sufficient
for this audit.

## Method

I added a reusable two-process comparison harness:

- `docs/codex/semantic-equivalence-harness.R`
- `docs/codex/semantic-equivalence-runner.R`

The harness creates a detached `origin/main` worktree and a detached refactor
worktree, then runs each side in a separate `Rscript --vanilla` process. It
constructs equivalent specs for the old `demo_sd` key and the new
`demographic_stochasticity` key rather than asking either branch to accept the
other branch's schema.

`origin/main` still imports `tidyr`, while the refactor branch intentionally no
longer does. The harness detects imports from `origin/main:DESCRIPTION` and
installs missing comparison-only packages into a temporary library layered ahead
of the project `renv` library. This keeps `renv.lock` and the project library
synchronized after the run.

Command:

```sh
Rscript docs/codex/semantic-equivalence-harness.R \
  --repo /Users/bwbrook/git/rPVA \
  --output docs/codex/semantic-equivalence-results-2026-05-30.csv
```

Result: pass.

## Comparison Results

The generated CSV is:

- `docs/codex/semantic-equivalence-results-2026-05-30.csv`

| Section | Item | Status | Max absolute difference | Note |
| --- | --- | --- | ---: | --- |
| metadata | origin_main_sha | recorded | NA | `dfc7c12` |
| metadata | head_sha | recorded | NA | `ea56a9e` |
| intentional_api | stochasticity_key | intentional_difference | NA | `origin/main` uses `demo_sd`; refactor uses `demographic_stochasticity` |
| intentional_api | run_pva_core_keep_traj_default | intentional_difference | NA | `origin/main=TRUE`; refactor `FALSE` |
| intentional_api | run_pva_core_verbose_default | intentional_difference | NA | `origin/main=TRUE`; refactor `FALSE` |
| intentional_api | run_scenarios_keep_traj_argument | intentional_difference | NA | `origin/main=FALSE`; refactor `TRUE` |
| intentional_api | demo_sd_acceptance | intentional_difference | NA | `origin/main=TRUE`; refactor `FALSE` |
| intentional_api | demographic_stochasticity_acceptance | intentional_difference | NA | `origin/main=FALSE`; refactor `TRUE` |
| core_cases | deterministic_minimal | equivalent | 0 | Numeric outputs matched |
| core_cases | fixed_seed_demographic | equivalent | 0 | Numeric outputs matched |
| core_cases | fixed_seed_environmental | equivalent | 0 | Numeric outputs matched |
| core_cases | deterministic_management | equivalent | 0 | Numeric outputs matched |
| scenario_smoke | woodhen_summary | equivalent | 0 | Scenario names and numeric summaries matched |

The core comparisons cover deterministic dynamics, fixed-seed demographic
stochasticity, fixed-seed environmental stochasticity, and management actions
including carrying capacity, removal, and release. The scenario smoke compares
the public woodhen summary table.

## Behaviour Preserved

For explicit equivalent calls, the refactor branch preserved the numeric
outputs checked by the harness:

- final total abundances
- total abundance trajectories
- extinction probability trajectories
- final abundance summaries
- trajectory means
- sex-ratio means
- inbreeding means
- woodhen scenario names and numeric summaries

All compared numeric fields had maximum absolute difference `0`.

## Intentional Differences

The audit treats these as intentional branch changes:

- spec key migration from `demo_sd` to `demographic_stochasticity`
- `run_pva_core()` default `keep_traj = FALSE`
- `run_pva_core()` default `verbose = FALSE`
- `run_scenarios()` now exposes a `keep_traj` argument
- strict schema validation rejects legacy `demo_sd`

These changes are API/spec contract changes, not stochastic model differences.

## Defect Found And Fixed

The audit exposed one narrow validation compatibility defect: explicit empty
management-year vectors such as `removal_years = integer(0)` and
`release_years = integer(0)` were rejected by strict validation, even though
omitted management years normalize to empty integer vectors and old main
accepted the explicit empty form.

Fix:

- `R/spec_validation.R` now allows empty integer sequences for
  `removal_years` and `release_years` while keeping non-empty year values
  integer-valued and positive.
- `tests/testthat/test-10_validation.R` now covers explicit empty management
  years with zero-valued action vectors.

No broad scientific/model behaviour was changed.

## Validation

Post-fix validation on the Mac mini:

```sh
git diff --check origin/main...HEAD
```

Result: pass, no output.

```sh
Rscript -e 'st <- renv::status(); cat("synchronized=", isTRUE(st$synchronized), "\n")'
```

Result: pass.

```text
No issues found -- the project is in a consistent state.
synchronized= TRUE
```

```sh
Rscript -e 'source("bootstrap.R")'
```

Result: pass.

```text
- The library is already synchronized with the lockfile.
r-pva is ready
```

```sh
Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter = "summary")'
```

Result: pass. Output ended with:

```text
DONE
```

```sh
Rscript -e 'source("bootstrap.R"); print(run_scenarios("woodhen", csv_out = NULL, rds_out = NULL, keep_traj = FALSE, parallel = FALSE))'
```

Result: pass.

```text
                 scenario years reps    PE Nmed Nlo95 Nhi95
1 woodhen_no_intervention    40 1000 0.666   16     1    31
2     woodhen_pig_control    40 1000 0.566   57     2   184
3     woodhen_captive_pig    40 1000 0.082  119     4   199
4 woodhen_rat_eradication     5 1000 0.000  832   340  1386
5 woodhen_future_baseline    75 1000 0.000 1510  1109  1957
```

```sh
R CMD build --no-build-vignettes /Users/bwbrook/git/rPVA
```

Result: pass. Built `rPVA_0.0.1.000.tar.gz` in a temporary directory.

```sh
R_LIBS=/Users/bwbrook/Library/Caches/org.R-project.R/R/renv/library/rPVA-dd56ac5f/macos/R-4.6/aarch64-apple-darwin25.4.0 \
_R_CHECK_FORCE_SUGGESTS_=false \
R CMD check --no-manual --no-build-vignettes --no-multiarch rPVA_0.0.1.000.tar.gz
```

Result: pass.

```text
Status: OK
```

`R CMD check` reported the expected informational line that suggested package
`ggrastr` was unavailable. This matches the branch policy that `ggrastr` and
`Cairo` remain optional. `R CMD build` also emitted a harmless local Git
fsmonitor socket copy warning before package preparation; package preparation,
build, and check all completed successfully.

No top-level build/check artifacts remained in the repo after validation.

## Residual Risks

- The equivalence harness is a small deterministic/fixed-seed audit, not a
  large ensemble or exhaustive stochastic proof.
- The audit does not independently review the scientific assumptions in the
  PVA model.
- Optional raster plotting remains untested unless `ggrastr`/`Cairo` are
  installed for a separate optional-dependency check.
- Human review is still needed before merge.

## Recommended Next Step

Review `codex/refactor-pva-core` with this audit as the behavioural baseline,
then decide whether the next focused goal is human/code review cleanup or a
separate scientific/model issue with dedicated tests.
