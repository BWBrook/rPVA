# Runbook

Start in the action repo:

```sh
cd /Users/bwbrook/git/rPVA
git status --short --branch --ignored=matching
git fetch --prune origin
git rev-list --left-right --count main...origin/main
```

Read the goal packet and required context:

```sh
sed -n '1,320p' docs/goals/015-practical-1-shiny-mvp-scaffold/Goal.md
sed -n '1,220p' docs/goals/015-practical-1-shiny-mvp-scaffold/Plan.md
sed -n '1,260p' docs/goals/015-practical-1-shiny-mvp-scaffold/Runbook.md
sed -n '1,220p' docs/goals/015-practical-1-shiny-mvp-scaffold/Log.md
sed -n '1,260p' docs/teaching/shiny/practical-1-design-brief.md
sed -n '1,220p' docs/teaching/shiny/implementation-roadmap.md
sed -n '1,240p' docs/teaching/shiny/engine-affordance-audit.md
sed -n '1,260p' R/teaching_api.R
sed -n '1,320p' R/plot_pva.R
sed -n '1,240p' R/pva_helpers.R
sed -n '1,220p' tests/testthat/test-12_teaching_api.R
```

Suggested implementation paths:

```text
R/shiny_practical1.R
inst/shiny/practical1/app.R
inst/shiny/practical1/www/styles.css
tests/testthat/test-13_practical1_shiny.R
docs/goals/015-practical-1-shiny-mvp-scaffold/evidence/
```

Dependency/doc regeneration:

```sh
Rscript -e 'source("bootstrap.R"); renv::install("shiny"); renv::snapshot(prompt = FALSE)'
Rscript -e 'source("bootstrap.R"); roxygen2::roxygenise()'
```

If `roxygen2` is missing, install it temporarily:

```sh
Rscript -e 'source("bootstrap.R"); renv::install("roxygen2", record = FALSE)'
Rscript -e 'source("bootstrap.R"); roxygen2::roxygenise()'
```

Validation:

```sh
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R")'
Rscript -e 'source("bootstrap.R"); testthat::test_local()'
Rscript -e 'source("bootstrap.R"); renv::status()'
git diff --check
rg -n "TODO|TBD|PLACEHOLDER" R tests inst/shiny docs/teaching/shiny docs/goals/015-practical-1-shiny-mvp-scaffold
```

Launch smoke:

```sh
Rscript -e 'source("bootstrap.R"); shiny::runApp(system.file("shiny", "practical1", package = "rPVA"), host = "127.0.0.1", port = 3851, launch.browser = FALSE)' &
server_pid=$!
sleep 8
curl -fsS http://127.0.0.1:3851/ >/tmp/rpva-practical1-start.html
kill "$server_pid"
wait "$server_pid" 2>/dev/null || true
rm -f /tmp/rpva-practical1-start.html
```

Screenshot evidence while the server is running:

```sh
mkdir -p docs/goals/015-practical-1-shiny-mvp-scaffold/evidence
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --disable-gpu --screenshot=docs/goals/015-practical-1-shiny-mvp-scaffold/evidence/practical1-desktop.png --window-size=1440,1000 http://127.0.0.1:3851/
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --disable-gpu --screenshot=docs/goals/015-practical-1-shiny-mvp-scaffold/evidence/practical1-mobile.png --window-size=390,900 http://127.0.0.1:3851/
```

Before committing:

```sh
git status --short --branch --ignored=matching
git diff --stat
git diff --check
```

Commit and push only if validation passed:

```sh
git add DESCRIPTION NAMESPACE renv.lock R/shiny_practical1.R man inst/shiny/practical1 tests/testthat/test-13_practical1_shiny.R docs/teaching/shiny docs/goals/015-practical-1-shiny-mvp-scaffold
git diff --cached --check
git diff --cached --stat
git commit -m "Add Practical 1 Shiny MVP scaffold"
git push origin main
git status --short --branch --ignored=matching
git rev-parse --short HEAD
```
