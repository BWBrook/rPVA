# Runbook

Start in the action repo:

```sh
cd /Users/bwbrook/git/rPVA
git status --short --branch --untracked-files=all
```

Read the goal packet:

```sh
sed -n '1,260p' docs/goals/013-practical-1-teaching-api-adapter/Goal.md
sed -n '1,220p' docs/goals/013-practical-1-teaching-api-adapter/Plan.md
sed -n '1,220p' docs/goals/013-practical-1-teaching-api-adapter/Runbook.md
sed -n '1,220p' docs/goals/013-practical-1-teaching-api-adapter/Log.md
```

Read the required design and code sources:

```sh
sed -n '1,260p' docs/teaching/shiny/engine-affordance-audit.md
sed -n '1,240p' docs/teaching/shiny/implementation-roadmap.md
sed -n '1,260p' docs/teaching/shiny/practical-1-design-brief.md
sed -n '1,260p' R/run_toy_demo.R
sed -n '1,260p' R/pva_helpers.R
sed -n '1,220p' R/set_scenario.R
sed -n '1,260p' tests/testthat/test-11_pva_helpers.R
```

Prefer focused tests before implementation.

Suggested validation commands:

```sh
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R")'
Rscript -e 'source("bootstrap.R"); testthat::test_local()'
git diff --check
rg -n "TODO|TBD|PLACEHOLDER" R tests docs/teaching/shiny docs/goals/013-practical-1-teaching-api-adapter
git status --short --branch --untracked-files=all
```

If the marker scan returns intentional command-string hits in the goal packet,
record that in `Log.md`.
