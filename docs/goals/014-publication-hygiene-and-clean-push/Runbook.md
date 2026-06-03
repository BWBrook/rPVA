# Runbook

Start in the action repo:

```sh
cd /Users/bwbrook/git/rPVA
git status --short --branch --untracked-files=all
git branch --show-current
git fetch --prune origin
git status --short --branch --untracked-files=all
```

Read the goal packet and required context:

```sh
sed -n '1,260p' docs/goals/014-publication-hygiene-and-clean-push/Goal.md
sed -n '1,220p' docs/goals/014-publication-hygiene-and-clean-push/Plan.md
sed -n '1,260p' docs/goals/014-publication-hygiene-and-clean-push/Runbook.md
sed -n '1,220p' docs/goals/014-publication-hygiene-and-clean-push/Log.md
sed -n '1,220p' docs/goals/010-woodhen-at1-assessment-redesign/Log.md
sed -n '1,220p' docs/goals/011-practical-1-shiny-design-spike/Log.md
sed -n '1,220p' docs/goals/012-deep-server-shiny-platform-feasibility/Log.md
sed -n '1,220p' docs/goals/013-practical-1-teaching-api-adapter/Log.md
```

Regenerate docs:

```sh
Rscript -e 'source("bootstrap.R"); roxygen2::roxygenise()'
git diff -- NAMESPACE man R/teaching_api.R
```

Validation:

```sh
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R")'
Rscript -e 'source("bootstrap.R"); testthat::test_local()'
Rscript -e 'source("bootstrap.R"); renv::status()'
git diff --check
rg -n "TODO|TBD|PLACEHOLDER" R tests man docs/goals/010-woodhen-at1-assessment-redesign docs/goals/011-practical-1-shiny-design-spike docs/goals/012-deep-server-shiny-platform-feasibility docs/goals/013-practical-1-teaching-api-adapter docs/goals/014-publication-hygiene-and-clean-push docs/teaching
find docs/teaching/intake-2026-06-02-legacy-assessment-materials -type f -size +25M -print
rg -n --pcre2 "[A-Z][a-z]+ [A-Z][a-z]+|student id|student number|email|@|\\b[0-9]{6,}\\b" docs/teaching/intake-2026-06-02-legacy-assessment-materials docs/teaching/woodhen docs/teaching/shiny
```

Package build/check:

```sh
check_root=$(mktemp -d)
R CMD build --no-manual --no-build-vignettes --resave-data=no .
pkg_tar=$(ls -t rPVA_*.tar.gz | head -1)
mv "$pkg_tar" "$check_root"/
R CMD check --no-manual --no-build-vignettes "$check_root/$(basename "$pkg_tar")"
mv rPVA.Rcheck "$check_root"/
echo "Package check artifacts moved to $check_root"
```

Suggested commit split:

```sh
git add \
  docs/goals/010-woodhen-at1-assessment-redesign \
  docs/goals/011-practical-1-shiny-design-spike \
  docs/goals/012-deep-server-shiny-platform-feasibility \
  docs/teaching/intake-2026-06-02-legacy-assessment-materials \
  docs/teaching/shiny \
  docs/teaching/woodhen/README.md \
  docs/teaching/woodhen/instructor-guide.md \
  docs/teaching/woodhen/assessment-brief-2026-draft.md \
  docs/teaching/woodhen/assessment-design-crosswalk-2026.md \
  docs/teaching/woodhen/feedback-template-2026-draft.md \
  docs/teaching/woodhen/marking-rubric-2026-draft.md
git diff --cached --stat
git commit -m "Publish woodhen teaching and Shiny planning"

git add \
  R/teaching_api.R \
  tests/testthat/test-12_teaching_api.R \
  NAMESPACE \
  man \
  docs/goals/013-practical-1-teaching-api-adapter \
  docs/goals/014-publication-hygiene-and-clean-push
git diff --cached --stat
git commit -m "Add Practical 1 teaching API adapter"
```

Before pushing:

```sh
git status --short --branch --untracked-files=all
git log --oneline -5
```

Push:

```sh
git push origin main
git status --short --branch --untracked-files=all
```
