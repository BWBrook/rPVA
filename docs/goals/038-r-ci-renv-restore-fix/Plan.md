# Plan

1. Verify the repo is clean, `origin/main` is `8210219`, and create/use branch
   `codex/rpva-goal038-r-ci-renv-restore-fix`.
2. Retrieve failing and prior successful GitHub Actions evidence with `gh`.
3. Compare:
   - recent file changes;
   - failed vs successful runner and RSPM context;
   - lockfile records for `listenv`, `future`, and `future.apply`;
   - renv's dependency graph from the lockfile.
4. Choose the smallest fix that targets the observed restore failure without
   changing package versions or broadening into dependency churn.
5. Validate:
   - workflow syntax;
   - local bootstrap;
   - renv status;
   - focused teaching API test;
   - focused Practical 1 Shiny test;
   - full test suite because workflow/bootstrap surface changed;
   - patch hygiene and text scans.
6. Leave changes uncommitted for orchestrator review and wake the orchestrator.
