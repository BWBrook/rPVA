# Log

## 2026-06-24 - Start

- Verified repo path: `/Users/bwbrook/git/rPVA`.
- Fetched origin and verified `origin/main`:
  `8210219e8fca21238ca668a88250112a4a3e4c1c`.
- Starting checkout was clean.
- Created branch `codex/rpva-goal038-r-ci-renv-restore-fix` from
  `origin/main`.

## 2026-06-24 - Diagnosis

- Retrieved failed run `28076391436`, attempt 2 job `83122453023`, to:
  `/tmp/rpva-goal038-ci-logs/run-28076391436-job-83122453023.log`.
- Retrieved prior successful run `27519468070`, job `81334420719`, to:
  `/tmp/rpva-goal038-ci-logs/run-27519468070-job-81334420719.log`.
- Confirmed Goal 037 changed only docs/deploy handoff paths, not `renv.lock`,
  `bootstrap.R`, or `.github/workflows/r-ci.yaml`.
- Confirmed the lockfile dependency graph is acyclic:
  - `listenv` has indegree 0;
  - `future` depends on `listenv` plus other normal imports;
  - `future.apply` depends on `future`.
- Observed environment drift:
  - passing run used runner image `ubuntu24/20260607.184`;
  - failing rerun used runner image `ubuntu24/20260615.205`.
- Observed RSPM context:
  - both CI runs used `RENV_CONFIG_REPOS_OVERRIDE` pointing to
    `https://packagemanager.posit.co/cran/__linux__/noble/latest`;
  - the current RSPM metadata advertises `listenv` `1.0.0`, while the lockfile
    correctly pins `listenv` `0.10.1`.
- Root-cause judgement: this is a CI/RSPM/renv Linux binary restore edge case
  around the locked `listenv` version after runner/RSPM drift, not a Goal 037
  content change and not a corrupt lockfile.

## 2026-06-24 - Fix

- Added a CI-only priming step before `Bootstrap` in `.github/workflows/r-ci.yaml`.
- The step activates renv and installs the exact locked `listenv` 0.10.1 source
  tarball into the active renv library using base `install.packages()`.
- This avoids broad dependency hydration, avoids package upgrades, and breaks
  the observed restore cycle before `renv::restore()` handles the remaining
  lockfile packages through the existing RSPM binary path.
- Tested the exact shell/R fragment with a temporary renv library and an RSPM
  override set; it installed only `listenv` 0.10.1 from source and loaded that
  version successfully.

## 2026-06-24 - Validation

- `git diff --check`: passed.
- `actionlint .github/workflows/r-ci.yaml`: passed.
- `Rscript -e 'source("bootstrap.R")'`: passed.
- `Rscript -e 'renv::status(sources = FALSE)'`: no issues found.
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'`:
  passed.
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'`:
  passed.
- `Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter = "summary")'`:
  passed.
- Marker scan over changed/untracked text: no hits.
- Secret/private-key-pattern scan over changed/untracked text:
  - hits are limited to boundary wording in `Goal.md` and the scan command text
    in `Runbook.md`;
  - no secret values, credentials, private keys, tokens, or student identifiers
    were found.
- Stricter assignment/private-key-block scan: no hits.

Residual risk: local validation cannot fully prove the GitHub-hosted
Ubuntu/RSPM binary restore path. Final proof requires publishing this repair to
`main` or otherwise running `R CI` in GitHub Actions.

Status: ready for orchestrator review.
