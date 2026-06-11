# Log

## 2026-06-11 - Orchestrator Packet Creation

- Goal 023 was accepted, committed, and published to `origin/main` before this
  branch was created.
- Starting base for Goal 024:
  - branch: `codex/rpva-goal024-classroom-dry-run`;
  - base commit: `3b61507 Add Practical 1 evidence export hardening`;
  - source: `origin/main`.
- Goal purpose:
  - run a local classroom dress rehearsal for Practical 1;
  - use Chrome plugin control where available, with documented browser fallback
    paths;
  - create or update lightweight fallback materials before service staging;
  - keep all deployment, remote, account, credential, Docker, ShinyProxy,
    nginx, systemd, firewall, DNS, TLS, public/student exposure, and
    class-workspace work out of scope.
- Packet files:
  - `docs/goals/024-practical-1-classroom-dry-run-fallback/Goal.md`
  - `docs/goals/024-practical-1-classroom-dry-run-fallback/Plan.md`
  - `docs/goals/024-practical-1-classroom-dry-run-fallback/Runbook.md`
  - `docs/goals/024-practical-1-classroom-dry-run-fallback/Log.md`

Status: packet ready for `woodhen`; execution not yet started.

## 2026-06-11 - Woodhen Execution Start

- Read first, before editing:
  - `docs/goals/024-practical-1-classroom-dry-run-fallback/Goal.md`
  - `docs/goals/024-practical-1-classroom-dry-run-fallback/Plan.md`
  - `docs/goals/024-practical-1-classroom-dry-run-fallback/Runbook.md`
  - `docs/goals/024-practical-1-classroom-dry-run-fallback/Log.md`
- Starting checks:
  - `pwd`: `/Users/bwbrook/git/rPVA`
  - branch: `codex/rpva-goal024-classroom-dry-run`
  - short HEAD: `3b61507`
  - status:
    `## codex/rpva-goal024-classroom-dry-run...origin/main`
    with untracked
    `docs/goals/024-practical-1-classroom-dry-run-fallback/`
  - repo-local `AGENTS.md`: not present.
- Read the required context listed in `Goal.md`, including the top-level
  package README, the 2026-06-04 handoff, Goals 016/022/023 records, current
  Shiny teaching docs, Woodhen teaching docs, the Practical 1 app, teaching API,
  and focused teaching/Shiny tests.
- Interpretation:
  - branch matches the Goal 024 handoff;
  - `HEAD` is the accepted and published Goal 023 commit;
  - the untracked Goal 024 packet is expected project state from orchestrator
    setup;
  - no unrelated dirty state was observed before Goal 024 execution work.

## 2026-06-11 - Baseline And Non-Shiny Checks

- Baseline gates passed:
  - `Rscript -e 'source("bootstrap.R")'`
  - `Rscript -e 'renv::status(sources = FALSE)'`
  - `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'`
  - `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'`
- Report scaffold renders:
  - DOCX succeeded at `/tmp/rpva-goal024-report/report-scaffold.docx`;
  - PDF succeeded at `/tmp/rpva-goal024-report/report-scaffold.pdf`;
  - no local PDF toolchain blocker was observed.
- Practical 1 command-line checkpoint:
  - `run_toy_demo(keep_traj = TRUE, plot_matrix = FALSE, verbose = FALSE)`
    matched `expected-outputs.md` exactly for `PE` and `N_med`;
  - plot evidence was written to
    `/tmp/rpva-goal024-nonshiny/practical1-toy-plots.pdf`.

## 2026-06-11 - Chrome Shiny Dress Rehearsal

- Chrome plugin control was available and used for the local browser rehearsal.
- Launched Practical 1 Shiny locally only:
  - URL: `http://127.0.0.1:3895/`
  - command class:
    `Rscript -e 'source("bootstrap.R"); rPVA::run_practical1_shiny(host = "127.0.0.1", port = 3895, launch.browser = FALSE)'`
- Before app use:
  - `lsof -nP -iTCP:3895 -sTCP:LISTEN` showed no listener;
  - `git status --short --branch` showed only the expected untracked Goal 024
    packet.
- Browser path completed:
  - Start screen loaded;
  - `Start baseline` moved to Concept Lab and showed the deterministic baseline;
  - ran carrying capacity, demographic stochasticity, environmental
    stochasticity, genetic stochasticity, catastrophe, simple intervention, and
    extinction-vortex comparison;
  - rapid-clicked/reran the intervention path as a rough-edge check;
  - opened Compare with 11 rows;
  - confirmed export controls were visible;
  - confirmed Compare table horizontal scanning:
    wrapper client width `710`, wrapper scroll width `1369`, table client width
    `1369`, table `min-width` `960px`, cells `white-space: nowrap`, and cells
    `overflow-wrap: normal`;
  - downloaded and inspected the comparison CSV and evidence-notes Markdown;
  - opened Transfer and confirmed the three transfer questions plus future
    Allee/correlated-event labels.
- Download evidence:
  - `/tmp/rpva-goal024-browser/practical1-comparison-chrome.csv`
    (`1262` bytes);
  - `/tmp/rpva-goal024-browser/practical1-evidence-notes-chrome.md`
    (`9606` bytes);
  - CSV contained `run_id`, `deterministic_baseline`, `carrying_capacity`, and
    `extinction_vortex`;
  - notes contained `Generated: 2026-06-11 ... AEST`, `Fixed teaching seed: 42`,
    `evidence, not an answer`, `control_K`, and catastrophe-frequency
    provenance;
  - notes did not contain `raw trajectory`.
- Screenshot evidence:
  - `/tmp/rpva-goal024-browser/start-screen.png`
  - `/tmp/rpva-goal024-browser/concept-environmental-stage.png`
  - `/tmp/rpva-goal024-browser/concept-genetics-risk-stage.png`
  - `/tmp/rpva-goal024-browser/compare-after-dry-run.png`
  - `/tmp/rpva-goal024-browser/transfer-after-dry-run.png`
- Cleanup:
  - Chrome's default Downloads copies were removed after copying evidence to
    `/tmp/rpva-goal024-browser/`;
  - finalized the Chrome automation tab;
  - stopped the temporary Shiny process;
  - confirmed port `3895` was closed.
- Rough edges:
  - Chrome automation needed visible selectize-option clicks rather than simply
    filling the combobox text;
  - repeated rapid intervention clicks create duplicate comparison rows, which
    is acceptable but worth a demonstrator reminder;
  - class downloads will normally land in the student's browser Downloads
    folder, so demonstrators should know where to ask students to look.

## 2026-06-11 - Fallback And Report Updates

- Created `docs/teaching/woodhen/practical-1-fallback-pack.md`.
- Updated:
  - `docs/teaching/woodhen/README.md`
  - `docs/teaching/woodhen/classroom-dry-run-checklist.md`
  - `docs/teaching/woodhen/instructor-guide.md`
  - `docs/teaching/woodhen/troubleshooting.md`
- Created:
  - `docs/goals/024-practical-1-classroom-dry-run-fallback/dry-run-report.md`
- Scope stayed documentation-only:
  - no app code, teaching API code, tests, scenario/YAML values, Practical 2
    mode, assessment design, dependencies, deployment templates, services,
    Docker, remote state, accounts, credentials, public exposure, commits,
    pushes, merges, or PRs were changed.

## 2026-06-11 - Final Validation

- Final validation gates passed:
  - `git status --short --branch`
  - `git diff --check`
  - `Rscript -e 'source("bootstrap.R")'`
  - `Rscript -e 'renv::status(sources = FALSE)'`
  - `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'`
  - `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'`
- Full test suite was not rerun because Goal 024 changed only documentation and
  goal-report artefacts after the already accepted Goal 023 app/API/test
  commit.
- Report-scaffold validation:
  - DOCX render succeeded at `/tmp/rpva-goal024-report/report-scaffold.docx`;
  - PDF render succeeded at `/tmp/rpva-goal024-report/report-scaffold.pdf`.
- Browser and export validation:
  - Chrome plugin was available and used;
  - local app dress rehearsal completed on `127.0.0.1:3895`;
  - comparison CSV and evidence-notes Markdown were downloaded, copied to
    `/tmp/rpva-goal024-browser/`, inspected, and confirmed understandable
    without the live app open;
  - temporary browser Downloads copies were removed;
  - `lsof -nP -iTCP:3895 -sTCP:LISTEN` showed no listener after cleanup.
- Text scans over changed/new files:
  - unresolved-marker scan returned no hits;
  - secret-pattern scan hits were limited to policy/boundary wording in the
    Goal 024 packet and log (`account`, `token`, `credential`, `secret-pattern`
    scan wording); no real-looking credentials, keys, private TLS material,
    student identifiers, or plausible secrets were found.
- Final changed/new files:
  - `docs/goals/024-practical-1-classroom-dry-run-fallback/Goal.md`
  - `docs/goals/024-practical-1-classroom-dry-run-fallback/Log.md`
  - `docs/goals/024-practical-1-classroom-dry-run-fallback/Plan.md`
  - `docs/goals/024-practical-1-classroom-dry-run-fallback/Runbook.md`
  - `docs/goals/024-practical-1-classroom-dry-run-fallback/dry-run-report.md`
  - `docs/teaching/woodhen/README.md`
  - `docs/teaching/woodhen/classroom-dry-run-checklist.md`
  - `docs/teaching/woodhen/instructor-guide.md`
  - `docs/teaching/woodhen/practical-1-fallback-pack.md`
  - `docs/teaching/woodhen/troubleshooting.md`
- Recommendation:
  - send this uncommitted Goal 024 result to the rPVA orchestrator for review;
  - if accepted, use a separate closeout commit/publication goal;
  - keep any hosted service/bootstrap work in a later explicitly authorized
    goal.
