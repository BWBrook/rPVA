# Goal 038: R CI renv restore bootstrap repair

## Objective

Restore the GitHub Actions `R CI` workflow for current `origin/main` after
Goal 037 by diagnosing and repairing the bootstrap failure in the narrowest
robust way.

This is a CI/restore-path repair only. It is not a science, pedagogy,
deployment, hosting, Docker, ITS, Moodle, or student-release goal.

## Starting Evidence

- Expected base: `8210219e8fca21238ca668a88250112a4a3e4c1c`
  (`Add ITS ShinyProxy VM handoff pack`).
- Failing workflow: `R CI`, run `28076391436`, branch `main`, commit
  `8210219e8fca21238ca668a88250112a4a3e4c1c`.
- Both attempts failed in the `Bootstrap` step before `renv status`, tests, or
  the woodhen smoke test.
- Failure signature:
  - `renv::restore(confirm = FALSE, exclude = "renv")` downloaded all 88
    packages;
  - 85 packages installed;
  - `future`, `future.apply`, and `listenv` were reported as dependency-failed.
- Previous `R CI` run `27519468070` on `70dca13ce4934dfbd68072cfad41ff27c81cd3a2`
  passed.
- `70dca13..8210219` changed only Goal 037 docs/deploy-handoff files; no
  package, bootstrap, or workflow files changed.
- Local Mac bootstrap still passes with R 4.6.0 and renv 1.2.3.

## Boundaries

- Work only in `/Users/bwbrook/git/rPVA`.
- Stay on `codex/rpva-goal038-r-ci-renv-restore-fix`.
- Do not change science/model defaults, scenarios/YAML, Shiny app behavior,
  pedagogy docs outside this packet, ITS/VM/Gitea/registry handoff content,
  deployment services, credentials, accounts, DNS/TLS, Docker state, Moodle or
  student-facing material, KPZ314 material, or public/student release state.
- Do not contact Barry, Chief, ITS, Mark, students, or Moodle admins.
- Do not push, open a PR, or commit unless explicitly instructed later.

## Expected Outputs

- A root-cause report under this packet.
- A narrow CI/bootstrap fix.
- Updated `Log.md`.
- Local validation evidence and residual risk statement.
