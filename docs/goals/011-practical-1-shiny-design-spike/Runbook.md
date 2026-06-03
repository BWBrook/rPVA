# Runbook

Start in the action repo:

```sh
cd /Users/bwbrook/git/rPVA
git status --short --branch --untracked-files=all
```

Read the goal packet:

```sh
sed -n '1,240p' docs/goals/011-practical-1-shiny-design-spike/Goal.md
sed -n '1,200p' docs/goals/011-practical-1-shiny-design-spike/Plan.md
sed -n '1,220p' docs/goals/011-practical-1-shiny-design-spike/Runbook.md
sed -n '1,220p' docs/goals/011-practical-1-shiny-design-spike/Log.md
```

Use `rg` and `sed` to inspect the required sources. Prefer concise targeted
reads over broad dumps.

Create only the allowed documentation files under:

```text
docs/teaching/shiny/
```

Keep the package code, scenarios, tests, dependencies, CI, metadata, and Goal
010 assessment drafts untouched.

Validation:

```sh
git diff --check
rg -n "TODO|TBD|PLACEHOLDER" docs/teaching/shiny docs/goals/011-practical-1-shiny-design-spike
git status --short --branch --untracked-files=all
```

If the placeholder scan returns intentional hits, explain them in `Log.md`.
Otherwise remove or rewrite them.
