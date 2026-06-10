# Log

## 2026-06-10 - Orchestrator Setup

- Barry authorized Goal 023 after discussion with the rPVA orchestrator.
- Chosen direction:
  - Practical 1 evidence export and road-test hardening before ShinyProxy or
    remote service work.
- Rationale:
  - the current app can show the Practical 1 concept lab, but it needs a
    student-retainable evidence path before hosted staging is worth much;
  - compact session-local exports may reduce first-road-test dependence on
    persistent student workspaces and identity infrastructure;
  - service bootstrap remains a later decision.
- rPVA orchestrator created branch:
  `codex/rpva-goal023-evidence-export-hardening`
  from `origin/main`.
- Starting action-repo state before goal packet creation:
  - branch: `main`
  - HEAD: `91491d6 Add Practical 1 staging validation closeout`
  - status: `## main...origin/main`
- Goal packet path:
  `docs/goals/023-practical-1-evidence-export-road-test-hardening/`
- Boundaries for `woodhen`:
  - no ShinyProxy, nginx, systemd, firewall, DNS, TLS, Docker service,
    account, credential, class workspace, external exposure, or remote service
    changes;
  - no commits or pushes;
  - no Practical 2 app mode, scenario/YAML changes, or research-grade Lord
    Howe woodhen analysis;
  - work locally in `/Users/bwbrook/git/rPVA`.

Status: packet ready for `woodhen`; execution not yet started.

## 2026-06-10 - Woodhen Start State

- Read first, before editing:
  - `docs/goals/023-practical-1-evidence-export-road-test-hardening/Goal.md`
  - `docs/goals/023-practical-1-evidence-export-road-test-hardening/Plan.md`
  - `docs/goals/023-practical-1-evidence-export-road-test-hardening/Runbook.md`
  - `docs/goals/023-practical-1-evidence-export-road-test-hardening/Log.md`
- Starting checks:
  - `pwd`: `/Users/bwbrook/git/rPVA`
  - branch: `codex/rpva-goal023-evidence-export-hardening`
  - short HEAD: `91491d6`
  - status:
    `## codex/rpva-goal023-evidence-export-hardening...origin/main`
    with untracked
    `docs/goals/023-practical-1-evidence-export-road-test-hardening/`
  - repo-local `AGENTS.md`: not present.
- Interpretation:
  - branch matches the Goal 023 handoff;
  - untracked Goal 023 packet is expected project state from orchestrator
    setup;
  - no unrelated dirty state was observed before implementation work.

## 2026-06-10 - Export Contract And Implementation

- Read the required app, test, recent-goal, Shiny teaching, and Woodhen
  teaching context listed in `Goal.md`.
- Export shape chosen:
  - separate downloads rather than a zip bundle, to avoid a new dependency or
    platform-specific archive assumptions;
  - `practical1-comparison-YYYYMMDD.csv` for the comparison table;
  - `practical1-evidence-notes-YYYYMMDD.md` for settings/provenance,
    fixed-seed note, comparison/settings text, and interpretation prompts;
  - no raw trajectory arrays, no server persistence, no account/workspace
    assumptions.
- Test-first evidence:
  - added a teaching API test for `build_teaching_evidence_export()`;
  - watched it fail because the helper did not yet exist;
  - added a Shiny structural test for Compare-tab download buttons and watched
    it fail because the controls/handlers were absent.
- Implementation:
  - added internal helper functions in `R/teaching_api.R`;
  - added Compare-tab download buttons and `downloadHandler()` wiring in
    `inst/shiny/practical1/app.R`;
  - added small layout styling for export controls;
  - kept the existing Start -> Concept Lab -> Compare -> Transfer flow.
- Focused tests after implementation:
  - `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'`
    passed;
  - `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'`
    passed.
- Targeted docs updated so students/demonstrators know the export is evidence,
  not an answer.
- Changed files at this checkpoint:
  - `R/teaching_api.R`
  - `inst/shiny/practical1/app.R`
  - `inst/shiny/practical1/www/styles.css`
  - `inst/shiny/practical1/README.md`
  - `tests/testthat/test-12_teaching_api.R`
  - `tests/testthat/test-13_practical1_shiny.R`
  - `docs/teaching/shiny/README.md`
  - `docs/teaching/shiny/implementation-roadmap.md`
  - `docs/teaching/shiny/practical-1-design-brief.md`
  - `docs/teaching/shiny/student-workspace-and-export-design.md`
  - `docs/teaching/woodhen/classroom-dry-run-checklist.md`
  - `docs/goals/023-practical-1-evidence-export-road-test-hardening/Log.md`

## 2026-06-10 - Validation And Browser Export Smoke

- Additional red/green check after browser-smoke inspection:
  - the downloaded notes initially showed duplicated timezone text from the
    export timestamp;
  - added a focused test asserting no duplicated timezone label;
  - fixed `format_teaching_export_time()`;
  - reran `tests/testthat/test-12_teaching_api.R` successfully.
- Required validation rerun after the timestamp fix:
  - `git diff --check` passed with no output;
  - `Rscript -e 'source("bootstrap.R")'` passed and reported the project
    consistent;
  - `Rscript -e 'renv::status(sources = FALSE)'` passed with no issues;
  - `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R")'`
    passed with 33 assertions;
  - `Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter = "summary")'`
    passed across all test files.
- Final text scans over changed/new files:
  - unresolved-marker scan returned no hits;
  - secret-pattern scan hits were limited to policy/design wording about
    accounts, tokens, credentials, and the scan command itself; no real-looking
    secrets, keys, private TLS material, student identifiers, or plausible
    credentials were found.
- Browser-visible local smoke:
  - launched Practical 1 Shiny on `127.0.0.1:3893`;
  - used the in-app Browser first to confirm the app loaded, the Start
    baseline was visible, a carrying-capacity run could be produced, Compare
    showed the export controls, and the table contained baseline plus
    carrying-capacity rows;
  - in-app Browser download handling reported downloads unsupported, so the
    packet-approved Playwright fallback was used for download endpoint
    inspection;
  - Playwright drove the local browser flow, opened Compare, confirmed the
    "Save evidence" section, and exposed the live Shiny download endpoints;
  - fetched both session-local download endpoints with `curl` into
    `/tmp/rpva-goal023-curl-downloads.7OOADy/`;
  - downloaded files:
    - `/tmp/rpva-goal023-curl-downloads.7OOADy/practical1-comparison.csv`
      (`342` bytes);
    - `/tmp/rpva-goal023-curl-downloads.7OOADy/practical1-evidence-notes.md`
      (`2261` bytes);
  - evidence screenshot:
    `/tmp/rpva-goal023-compare-export-screen.png`.
- Download content checks:
  - comparison CSV contained `run_id`, `deterministic_baseline`, and
    `carrying_capacity`;
  - evidence notes contained `Generated: 2026-06-10 ... AEST`, `Fixed teaching
    seed: 42`, `evidence, not an answer`, `control_K`, and `control_K_sd`;
  - evidence notes did not contain `raw trajectory`, `AEST AEST`, or
    `UTC UTC`.
- Cleanup:
  - stopped the temporary Shiny process;
  - `lsof -nP -iTCP:3893 -sTCP:LISTEN || true` returned no listener;
  - closed the Playwright browser session;
  - removed the generated `.playwright-cli/` scratch directory from the repo.
- Boundary confirmation:
  - no new dependencies;
  - no public exported API or `NAMESPACE` change;
  - no scenario/YAML science, Practical 2 app mode, or research-grade Lord
    Howe woodhen analysis changes;
  - no ShinyProxy, nginx, systemd, firewall, DNS, TLS, Docker service,
    account, credential, class workspace, remote, deployment, public, or
    student-facing service changes;
  - no commit, push, or PR.

## 2026-06-10 - Compare Table Readability Refinement

- Orchestrator review accepted the export shape but requested a narrow
  readability pass because the browser Compare table wrapped labels and
  numbers awkwardly in the road-test screenshot.
- Scope preserved:
  - no export-shape change;
  - no dependency, public API, `NAMESPACE`, scenario/YAML/science, Practical 2,
    remote, service, Docker, account, credential, commit, push, or PR change.
- Test-first evidence:
  - added a focused structural test in
    `tests/testthat/test-13_practical1_shiny.R` requiring the Compare table to
    use horizontal scrolling, table `min-width`, cell `white-space: nowrap`,
    and normal `overflow-wrap`;
  - watched the focused Shiny test fail on the missing CSS properties;
  - added a narrow `.compare-table` CSS override in
    `inst/shiny/practical1/www/styles.css`;
  - reran the focused Shiny test successfully.
- CSS change:
  - kept the existing Compare wrapper;
  - added touch-friendly horizontal scrolling;
  - set `.compare-table table` to `min-width: 960px`;
  - set Compare table cells to `white-space: nowrap` and
    `overflow-wrap: normal`;
  - left settings and metric tables unchanged.
- Validation:
  - `git diff --check` passed with no output;
  - `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'`
    passed after the CSS update.
  - final unresolved-marker scan returned no hits;
  - final secret-pattern scan hits were limited to policy/design wording about
    accounts, tokens, credentials, and the scan command itself; no real-looking
    sensitive values were found.
- Browser smoke:
  - launched Practical 1 Shiny on `127.0.0.1:3894`;
  - Playwright drove Start -> Concept Lab -> carrying-capacity run -> Compare;
  - confirmed the comparison table had two body rows and export controls were
    visible;
  - computed browser metrics:
    - wrapper client width: `462`;
    - wrapper scroll width: `1277`;
    - table client width: `1277`;
    - table min-width: `960px`;
    - cell white-space: `nowrap`;
    - cell overflow-wrap: `normal`;
  - screenshot saved at `/tmp/rpva-goal023-compare-readability.png`.
- Cleanup:
  - stopped the temporary Shiny process;
  - `lsof -nP -iTCP:3894 -sTCP:LISTEN || true` returned no listener;
  - closed the Playwright browser session;
  - removed the generated `.playwright-cli/` scratch directory from the repo.
