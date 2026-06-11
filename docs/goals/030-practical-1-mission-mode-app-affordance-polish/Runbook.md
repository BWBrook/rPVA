# Runbook

Goal 030 is a narrow local Shiny app-polish goal. Do not change live services,
remote state, science defaults, or assessment design.

## Local Guard

```sh
pwd
git branch --show-current
git rev-parse HEAD
git rev-parse origin/main
git status --short --branch
```

Expected:

```text
branch: codex/rpva-goal030-mission-app-affordances
HEAD/origin-main base: 9d2504b Add Practical 1 mission tutorial curriculum
```

The only expected starting dirty state is the untracked Goal 030 packet
directory created by the orchestrator.

## Source Facts To Use

Use accepted repo-local records and live repo files:

- `docs/teaching/shiny/practical-1-mission-tutorial.md`
- `docs/goals/029-practical-1-mission-tutorial-curriculum/pedagogy-review.md`
- `docs/teaching/woodhen/practical-1-mission-worksheet.md`
- `docs/teaching/woodhen/practical-1-instructor-beat-sheet.md`
- `inst/shiny/practical1/app.R`
- `inst/shiny/practical1/www/styles.css`
- `tests/testthat/test-13_practical1_shiny.R`

Use Barry's approved direction:

```text
App-led Practical 1 with a lightweight mission worksheet. Goal 030 should make
the browser app visibly support that mission tutorial while preserving the
existing science and export contract.
```

Do not read Chief of Staff, Goal Composer, sibling project folders, KPZ314
materials, or archive material.

## Implementation Boundaries

Allowed file families:

- `inst/shiny/practical1/app.R`
- `inst/shiny/practical1/www/styles.css`
- `inst/shiny/practical1/README.md`
- `tests/testthat/test-13_practical1_shiny.R`
- narrow teaching docs if needed
- Goal 030 packet files

Do not modify:

- `R/teaching_api.R` unless a clear blocker makes this unavoidable; stop first
  if that happens;
- scenario/YAML files;
- deployment or ShinyProxy files;
- assessment docs, except for a pointer if the orchestrator explicitly asks;
- Practical 2 materials.

## Suggested App Text Targets

These are examples of acceptable intent, not mandatory exact wording:

- Start: "This creates your baseline as run 1 for later comparison."
- Concept Lab: "Work through the mission path by changing one visible control
  at a time, then compare."
- Stage cue: "Mission 2: Island ceiling" or equivalent mission/progress label.
- Compare: "Choose a clean comparison: baseline, one risk mechanism, and one
  intervention or vortex run."
- Compare: "Repeated clicks are less useful than a targeted one-factor change."
- Export: preserve "evidence, not an answer."

## Commands

Focused validation:

```sh
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
git diff --check
```

Marker scan:

```sh
files=$( { git diff --name-only --diff-filter=ACMRTUXB; git ls-files --others --exclude-standard; } | sort -u )
pattern="$(printf '%s|%s|%s|%s|%s|%s' 'TO''DO' 'T''BD' 'FIX''ME' 'PLACE''HOLDER' 'X''XX' 'CHANGE''ME')"
test -z "$files" || printf "%s\n" "$files" | xargs rg -n --pcre2 "(?i)($pattern)" || true
```

Secret/private-key scan:

```sh
files=$( { git diff --name-only --diff-filter=ACMRTUXB; git ls-files --others --exclude-standard; } | sort -u )
test -z "$files" || printf "%s\n" "$files" | xargs rg -n --pcre2 "(?i)(api[_-]?key|secret|token|password|credential|passwd|private[ _-]?key|BEGIN (RSA|OPENSSH|EC|PRIVATE) KEY)" || true
```

Stricter scan:

```sh
files=$( { git diff --name-only --diff-filter=ACMRTUXB; git ls-files --others --exclude-standard; } | sort -u )
test -z "$files" || printf "%s\n" "$files" | xargs rg -n --pcre2 "(?i)(api[_-]?key|secret|token|password|credential|passwd)\s*[:=]\s*['\"]?[^'\"[:space:]]{8,}|BEGIN (RSA|OPENSSH|EC|PRIVATE) KEY" || true
```

## Browser Smoke Expectations

Record:

- app URL and port;
- browser automation path used;
- visible mission/progress cue observed;
- Compare guidance observed;
- comparison CSV path;
- evidence-notes Markdown path;
- screenshot paths if captured;
- proof the Shiny process stopped and the port closed.

## Final Report Checklist

Include:

- branch, HEAD, and status;
- changed files;
- summary of affordances;
- validation results;
- browser evidence paths;
- export-shape confirmation;
- boundaries observed;
- recommendation for closeout or further revision.
