# Log

## 2026-06-02 - Supervisor Goal Publication

- Supervisor created Goal 011 after Goal 010 produced a draft Woodhen AT1
  assessment package and Barry handed R&D direction back to the supervisor.
- Strategic decision: this goal is a Shiny requirements/design spike, not a
  Shiny implementation goal.
- Goal 010 remains uncommitted and unpublished pending Lab Leader review. Do
  not commit it as part of Goal 011.
- Expected output surface: `docs/teaching/shiny/`.
- Expected model: `gpt-5.5` with high reasoning because this is a
  teaching/product architecture task.

## 2026-06-02 - Execution Start

- Formal goal mode appeared active for this action-thread run.
- Started from `/Users/bwbrook/git/rPVA` on `main`.
- Read the Goal 011 packet:
  - `Goal.md`
  - `Plan.md`
  - `Runbook.md`
  - `Log.md`
- Starting `git status --short --branch --untracked-files=all` showed:
  - `## main...origin/main`
  - pre-existing tracked edits in:
    - `docs/teaching/woodhen/README.md`
    - `docs/teaching/woodhen/instructor-guide.md`
  - pre-existing untracked Goal 010 packet, legacy intake folder, and 2026
    Woodhen assessment draft files.
  - untracked Goal 011 packet files.
- Boundary confirmed: create or update only `docs/teaching/shiny/` and this
  Goal 011 `Log.md`; no commit or push.

## 2026-06-02 - Source Review

- Read required teaching and assessment context:
  - `docs/teaching/woodhen/practical-1-pva-foundations.md`
  - `docs/teaching/woodhen/practical-2-woodhen-management.md`
  - `docs/teaching/woodhen/report-scaffold.qmd`
  - `docs/teaching/woodhen/assessment-brief-2026-draft.md`
  - `docs/teaching/woodhen/assessment-design-crosswalk-2026.md`
  - `docs/teaching/intake-2026-06-02-legacy-assessment-materials/1_rPVA_overview.md`
  - `docs/teaching/intake-2026-06-02-legacy-assessment-materials/2_woodhen_notes.converted.md`
- Reviewed current engine and helper surface in `R/`, including:
  - `run_toy_demo()`
  - `run_pva_core()`
  - `set_scenario()`
  - `run_scenarios()`
  - `summarize_pva_result()`
  - `compare_pva_results()`
  - `diagnose_pva_result()`
  - plotting helpers in `R/plot_pva.R`
- Reviewed toy and Woodhen scenario inputs under `inst/extdata/`.
- Main design finding: Practical 1 can be framed around a simple invented
  species and existing toy/engine calls. The future Shiny app mainly needs a
  thin teaching-facing API/control layer, not a broad engine refactor.

## 2026-06-02 - Draft Shiny Design Package

- Created `docs/teaching/shiny/`.
- Created:
  - `docs/teaching/shiny/README.md`
  - `docs/teaching/shiny/practical-1-design-brief.md`
  - `docs/teaching/shiny/engine-affordance-audit.md`
  - `docs/teaching/shiny/deployment-and-setup-options.md`
  - `docs/teaching/shiny/implementation-roadmap.md`
- Recommended design direction:
  - browser-first hosted or server-hosted Shiny for the 2026 Practical 1 road
    test,
  - static/browser-first fallback materials,
  - optional local R/Shiny continuation path,
  - future implementation should start with a thin teaching-facing API adapter
    before the full Shiny UI.
- No Shiny app, dependencies, package code, scenarios, tests, CI, metadata, or
  Goal 010 assessment files were edited.

## 2026-06-02 - Validation

- Ran `git diff --check`:
  - passed with no whitespace or patch hygiene issues.
- Ran the required marker scan across `docs/teaching/shiny` and the Goal 011
  packet:
  - no hits in the new Shiny design documents.
  - intentional hits remain only in the Goal 011 contract text where `Goal.md`
    and `Runbook.md` quote the validation command itself.
- Ran `git status --short --branch --untracked-files=all`:
  - `## main...origin/main`
  - pre-existing tracked edits remain in:
    - `docs/teaching/woodhen/README.md`
    - `docs/teaching/woodhen/instructor-guide.md`
  - pre-existing Goal 010 packet, legacy intake files, and Woodhen assessment
    draft files remain untracked.
  - new Goal 011 output files are untracked under `docs/teaching/shiny/`.
  - Goal 011 packet files remain untracked, with this `Log.md` updated.
- Allowed-surface check:
  - Goal 011-created/updated paths are limited to `docs/teaching/shiny/` and
    `docs/goals/011-practical-1-shiny-design-spike/Log.md`.
  - No package code, scenario YAML, tests, CI, dependencies, metadata, Shiny app
    implementation files, Goal 010 assessment files, commits, pushes, branches,
    or PRs were created or changed by this goal.
