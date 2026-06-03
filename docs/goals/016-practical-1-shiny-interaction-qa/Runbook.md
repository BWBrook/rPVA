# Runbook

Start in the action repo:

```sh
cd /Users/bwbrook/git/rPVA
git status --short --branch --ignored=matching
git fetch --prune origin
git rev-list --left-right --count main...origin/main
```

Read the packet and required context:

```sh
sed -n '1,320p' docs/goals/016-practical-1-shiny-interaction-qa/Goal.md
sed -n '1,220p' docs/goals/016-practical-1-shiny-interaction-qa/Plan.md
sed -n '1,260p' docs/goals/016-practical-1-shiny-interaction-qa/Runbook.md
sed -n '1,220p' docs/goals/016-practical-1-shiny-interaction-qa/Log.md
sed -n '1,220p' docs/goals/015-practical-1-shiny-mvp-scaffold/Log.md
sed -n '1,260p' docs/teaching/shiny/practical-1-design-brief.md
sed -n '1,220p' docs/teaching/shiny/implementation-roadmap.md
sed -n '1,220p' docs/teaching/shiny/README.md
sed -n '1,360p' inst/shiny/practical1/app.R
sed -n '1,260p' inst/shiny/practical1/www/styles.css
sed -n '1,160p' R/shiny_practical1.R
sed -n '1,260p' R/teaching_api.R
sed -n '1,220p' tests/testthat/test-13_practical1_shiny.R
```

Check browser automation fallback:

```sh
command -v npx
export CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
export PWCLI="$CODEX_HOME/skills/playwright/scripts/playwright_cli.sh"
test -x "$PWCLI"
```

Launch the app:

```sh
Rscript -e 'source("bootstrap.R"); shiny::runApp(system.file("shiny", "practical1", package = "rPVA"), host = "127.0.0.1", port = 3862, launch.browser = FALSE)'
```

Use Browser if available. Otherwise, use the Playwright CLI wrapper:

```sh
"$PWCLI" open http://127.0.0.1:3862/
"$PWCLI" snapshot
```

Interact through the UI. Re-run `snapshot` after tab changes or meaningful
updates. Capture screenshots into:

```text
docs/goals/016-practical-1-shiny-interaction-qa/evidence/
```

If the wrapper cannot drive a Shiny control cleanly, create a temporary script
under `/tmp`, for example `/tmp/rpva-goal016-clickthrough.js`, and run it with
`npx --yes --package playwright node /tmp/rpva-goal016-clickthrough.js`. Do not
commit that script.

Suggested QA checks:

- Start screen baseline metrics visible.
- Click Start baseline.
- Select each implemented stage and click Run stage.
- Confirm the selected stage label or current summary updates.
- Confirm visible text does not show Shiny errors such as `Error:` or
  `object not found`.
- Confirm trajectory and summary plots appear.
- Confirm extinction/genetics plot appears for `genetic_stochasticity`,
  `catastrophe`, or `extinction_vortex`.
- Visit Compare after multiple runs and confirm multiple rows/labels.
- Click Reset comparison and confirm the table returns to a clear baseline.
- Visit Transfer and confirm the three transfer questions and future concepts.
- Repeat a representative post-interaction view at mobile width.

Validation:

```sh
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R")'
Rscript -e 'source("bootstrap.R"); testthat::test_local()'
Rscript -e 'source("bootstrap.R"); renv::status()'
git diff --check
rg -n "TODO|TBD|PLACEHOLDER" R tests inst/shiny docs/teaching/shiny docs/goals/016-practical-1-shiny-interaction-qa
lsof -nP -iTCP:3862 -sTCP:LISTEN || true
```

Before committing:

```sh
git status --short --branch --ignored=matching
git diff --stat
git diff --check
```

Commit and push only if validation passed:

```sh
git add \
  inst/shiny/practical1 \
  tests/testthat/test-13_practical1_shiny.R \
  docs/teaching/shiny/README.md \
  docs/goals/016-practical-1-shiny-interaction-qa
git diff --cached --check
git diff --cached --stat
git commit -m "Harden Practical 1 Shiny interactions"
git push origin main
git status --short --branch --ignored=matching
git rev-parse --short HEAD
```
