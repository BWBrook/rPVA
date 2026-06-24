# Goal 038 R CI restore failure report

## Summary

The `R CI` failure on `8210219` is best explained as a CI/RSPM/renv binary
restore edge case affecting the locked `listenv` 0.10.1 dependency chain. The
Goal 037 diff did not touch package, bootstrap, workflow, or test files, and
the lockfile graph for `listenv`, `future`, and `future.apply` is structurally
sane.

The repair is intentionally workflow-only: before the normal `Bootstrap` step,
CI installs the exact locked `listenv` 0.10.1 source tarball into the active
renv library. This removes `listenv` from the problematic restore action set,
so `renv::restore()` can continue with the remaining packages using the
existing RSPM binary path.

## Evidence

Failing run:

- Run: `https://github.com/BWBrook/rPVA/actions/runs/28076391436`
- Workflow: `R CI`
- Branch: `main`
- Commit: `8210219e8fca21238ca668a88250112a4a3e4c1c`
- Attempt 1 job: `83121443330`, failed in `Bootstrap`
- Attempt 2 job: `83122453023`, failed in `Bootstrap`

Attempt 2 log excerpt:

```text
Successfully downloaded 88 packages in 1.7 seconds.
Successfully installed 85 packages in 24 seconds.
The following package(s) were not installed successfully:
- [future]: dependency failed (listenv)
- [future.apply]: dependency failed (future)
- [listenv]: dependency failed (future, future.apply)
Error: failed to install "future", "future.apply", "listenv"
```

Prior successful run:

- Run: `https://github.com/BWBrook/rPVA/actions/runs/27519468070`
- Commit: `70dca13ce4934dfbd68072cfad41ff27c81cd3a2`
- `Bootstrap`, `renv status`, test suite, and woodhen smoke test all passed.
- The successful log installed `listenv`, then `future`, then `future.apply`.

Recent changes:

```text
deploy/shinyproxy/practical1/README.md
deploy/shinyproxy/practical1/application.its-staging.example.yml
deploy/shinyproxy/practical1/gitea-registry-runbook.md
deploy/shinyproxy/practical1/its-vm-handoff.md
deploy/shinyproxy/practical1/staging-gate-checklist.md
docs/goals/037-its-shinyproxy-vm-handoff-pack/
docs/teaching/shiny/README.md
```

No package, bootstrap, workflow, or test file changed in Goal 037.

## Dependency Graph Check

Local renv graph calculation from `renv.lock`:

```text
listenv -> indegree 0, dependent future
future -> imports digest, globals, listenv, parallelly
future.apply -> depends on future
```

There is no real cycle. `listenv` should be installable before `future`.

## Environment Drift

The last passing run used runner image `ubuntu24/20260607.184`; the failing
rerun used runner image `ubuntu24/20260615.205`. Both used:

```text
RENV_CONFIG_REPOS_OVERRIDE=https://packagemanager.posit.co/cran/__linux__/noble/latest
```

Current RSPM metadata advertises `listenv` 1.0.0 while the lockfile pins
`listenv` 0.10.1. The failing run downloaded the locked 0.10.1 binary but then
left `listenv`, `future`, and `future.apply` stuck in renv's install graph.

## Fix

Added this step before `Bootstrap`:

```yaml
- name: Prime renv restore dependency
  run: |
    Rscript --vanilla - <<'RS'
    source("renv/activate.R")
    install.packages(
      "https://cran.r-project.org/src/contrib/Archive/listenv/listenv_0.10.1.tar.gz",
      repos = NULL,
      type = "source",
      lib = .libPaths()[1]
    )
    RS
```

The step is intentionally limited to one pure-R package and one locked version.
It does not alter `renv.lock`, package code, app code, or test code.

## Residual Risk

Local validation can prove syntax, local bootstrap, tests, and the preinstall
fragment. It cannot fully prove the Ubuntu/RSPM binary restore path without a
published GitHub Actions run. Final proof requires publishing this branch to
`main` or otherwise running the workflow in GitHub Actions.
