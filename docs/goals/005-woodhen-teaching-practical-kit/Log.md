# Log

## Current Status

Published by the supervisor on 2026-06-01 13:11 AEST.

This goal is ready for `woodhen`.

## Supervisor Context

This is the first live bounded-supervision test after adopting two workflow
rules:

- use a first-line goal-mode prefix in the action-agent delegation message
- stop after Goal 005 completion for supervisor review and Barry's approval
  before issuing Goal 006

Current unlocked envelope:

- create the Woodhen teaching practical kit under `docs/teaching/woodhen/`
- run cheap local checks needed to keep examples honest
- update this goal log
- no package code, YAML, scientific assumption, dependency, CI, commit, push,
  PR, or Shiny implementation changes

## Expected Deliverables

- `docs/teaching/woodhen/README.md`
- `docs/teaching/woodhen/practical-1-pva-foundations.md`
- `docs/teaching/woodhen/practical-2-woodhen-management.md`
- `docs/teaching/woodhen/instructor-guide.md`
- `docs/teaching/woodhen/expected-outputs.md`
- `docs/teaching/woodhen/glossary.md`
- `docs/teaching/woodhen/troubleshooting.md`
- `docs/teaching/woodhen/report-scaffold.qmd`
- `docs/teaching/woodhen/marking-rubric.md`
- this `Log.md` updated with commands, artefacts, recommendations, risks, and
  final git state

## Notes For Executor

Do not commit or push. Do not implement Shiny. Do not change package code,
scenario YAML, tests, CI, dependencies, or scientific assumptions.

If you need Barry's scientific judgement to make a teaching claim honest, stop
and say exactly what judgement is needed.

## Execution Log (2026-06-01)

### Start state

- Ran `git status --short --branch`
  - `## main...origin/main`
  - untracked:
    - `docs/codex/post-merge-readiness-audit-2026-06-01.md`
    - `docs/goals/004-post-merge-readiness-audit/`
    - `docs/goals/005-woodhen-teaching-practical-kit/`
- Ran `git log --oneline --decorate --max-count=8`
  - latest commit still `3736f00 (HEAD -> main, origin/main, origin/HEAD) Merge pull request #2 from BWBrook/codex/refactor-pva-core`
- Confirmed this goal-mode packet is the active source of truth per packet order.

### Work performed

- Created `docs/teaching/woodhen/` and added:
  - `README.md`
  - `practical-1-pva-foundations.md`
  - `practical-2-woodhen-management.md`
  - `instructor-guide.md`
  - `expected-outputs.md`
  - `glossary.md`
  - `troubleshooting.md`
  - `report-scaffold.qmd`
  - `marking-rubric.md`
- Kept changes fully documentation-first (no package, YAML, dependency, CI, or
  Shiny changes).

### Validation commands run

- `git diff --check`
  - pass, no whitespace/patch issues
- `Rscript -e 'source("bootstrap.R"); toy <- run_toy_demo(keep_traj = FALSE, plot_matrix = FALSE, verbose = FALSE); print(toy$summary)'`
  - returned toy summary with:
    - det: PE 0, N_med 264
    - ceiling: PE 0, N_med 85
    - demographic_stochasticity: PE 0, N_med 82
    - env_sd: PE 0, N_med 70
    - genetics: PE 0.07, N_med 60
- `Rscript -e 'source("bootstrap.R"); tbl <- run_scenarios("woodhen", csv_out=NULL, rds_out=NULL, keep_traj=FALSE, parallel=FALSE); print(tbl)'`
  - returned woodhen baseline table:
    - no intervention: PE 0.666, Nmed 16, Nlo95 1, Nhi95 31
    - pig control: PE 0.566, Nmed 57, Nlo95 2, Nhi95 184
    - captive pig: PE 0.082, Nmed 119, Nlo95 4, Nhi95 199
    - rodent eradication: PE 0.000, Nmed 832, Nlo95 340, Nhi95 1386
    - future baseline: PE 0.000, Nmed 1510, Nlo95 1109, Nhi95 1957
- `Rscript -e 'source("bootstrap.R"); ... sensitivity reference block in docs/teaching/woodhen/expected-outputs.md'`
  - recorded fixed-seed sensitivity comparison in that file and referenced in Practical 2.

### Boundary checks

- No package code edits.
- No YAML edits.
- No dependency, CI, or lockfile edits.
- No Shiny implementation edits.
- No commits, pushes, PR creation, or branch mutations.

### Goal-mode note

- The first-line prefix `/goal` appeared to be active and correctly routed execution
  to this goal packet with explicit start/finish checks against `Goal.md`, `Plan.md`,
  `Runbook.md`, and `Log.md`.

### Final git state (post-execution)

- `## main...origin/main`
- untracked teaching/artifact tree now includes:
  - `docs/codex/post-merge-readiness-audit-2026-06-01.md`
  - `docs/goals/004-post-merge-readiness-audit/`
  - `docs/goals/005-woodhen-teaching-practical-kit/`

### Residual risks / follow-up

- Sensitivity examples in Practical 2 are seeded for reproducibility in teaching handout,
  but students running without fixed seeds will get different numeric values.
- Clarification may be needed from Barry on whether future practicals should include
  a short calibration exercise for students who struggle with stochastic variability.
- No render check was run for `report-scaffold.qmd` in this pass.
