# Runbook

## Start Guard

```sh
pwd
git rev-parse --abbrev-ref HEAD
git rev-parse HEAD
git status --short --branch
git fetch --prune origin
```

Only proceed if the worktree is clean and the Goal 039 branch is based on
current `origin/main`.

## Reference Inventory

```sh
rg -n "kpz308-rpva-practical1|kpz308-rpva-practical|git\\.its\\.utas|Gitea|ITS" \
  deploy/shinyproxy/practical1 docs/teaching/shiny docs/goals/037-its-shinyproxy-vm-handoff-pack
```

Treat Goal 037 as historical unless a current sendable/operator handoff surface
would otherwise keep pointing Barry or ITS at the stale `practical1` id.

## Bundle

```sh
bundle_dir=/tmp/rpva-goal039-its-handoff
rm -rf "$bundle_dir"
mkdir -p "$bundle_dir"
cp deploy/shinyproxy/practical1/its-vm-handoff.md "$bundle_dir/"
cp deploy/shinyproxy/practical1/gitea-registry-runbook.md "$bundle_dir/"
cp deploy/shinyproxy/practical1/application.its-staging.example.yml "$bundle_dir/"
cp docs/goals/039-gitea-handoff-identity-refresh/mark-update-draft.md "$bundle_dir/"
cp docs/goals/039-gitea-handoff-identity-refresh/README-send-to-ITS.md "$bundle_dir/"
(cd "$bundle_dir" && shasum -a 256 * > SHA256SUMS.txt)
```

Do not include image tarballs, registry tokens, real credentials, private keys,
student identifiers, live ShinyProxy config, VM payloads, or internal review
reports.

## Validation

Patch hygiene:

```sh
git diff --check
```

YAML parse:

```sh
ruby -e 'require "yaml"; YAML.load_file("deploy/shinyproxy/practical1/application.its-staging.example.yml")'
```

Scaffold checks:

```sh
bash -n deploy/shinyproxy/practical1/validate-scaffold.sh
bash deploy/shinyproxy/practical1/validate-scaffold.sh
```

R project status:

```sh
Rscript -e 'renv::status(sources = FALSE)'
```

Targeted stale-name search for current handoff surfaces:

```sh
rg -n "kpz308-rpva-practical1" \
  deploy/shinyproxy/practical1 docs/teaching/shiny/README.md \
  docs/goals/039-gitea-handoff-identity-refresh
```

Historical check:

```sh
rg -n "kpz308-rpva-practical1" docs/goals/037-its-shinyproxy-vm-handoff-pack
```

Marker scan:

```sh
files=$(git diff --name-only --diff-filter=ACMRTUXB; git ls-files --others --exclude-standard)
pattern="$(printf '%s|%s|%s|%s|%s|%s' 'TO''DO' 'T''BD' 'FIX''ME' 'PLACE''HOLDER' 'X''XX' 'CHANGE''ME')"
printf "%s\n" "$files" /tmp/rpva-goal039-its-handoff/SHA256SUMS.txt |
  xargs rg -n --pcre2 "(?i)($pattern)" || true
```

Secret/private-key/token scan:

```sh
files=$(git diff --name-only --diff-filter=ACMRTUXB; git ls-files --others --exclude-standard)
printf "%s\n" "$files" /tmp/rpva-goal039-its-handoff/SHA256SUMS.txt |
  xargs rg -n --pcre2 "(?i)(api[_-]?key|secret|token|password|credential|passwd|private[ _-]?key|BEGIN (RSA|OPENSSH|EC|PRIVATE) KEY)" || true
```

## Wake-Up

Report:

- branch/status;
- changed files;
- stale-name search results;
- bundle path and checksums;
- validation results;
- residual ITS/Barry questions;
- whether the result is ready for orchestrator review.
