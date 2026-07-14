#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
SCAFFOLD="$ROOT/deploy/shinyproxy/practical2"

required=(
  "$SCAFFOLD/README.md"
  "$SCAFFOLD/Dockerfile.template"
  "$SCAFFOLD/dockerignore.template"
  "$SCAFFOLD/application.spec.example.yml"
  "$SCAFFOLD/validate-scaffold.sh"
)

for path in "${required[@]}"; do
  if [[ ! -f "$path" ]]; then
    printf 'missing required scaffold file: %s\n' "$path" >&2
    exit 1
  fi
done

marker_re="$(printf '%s|%s|%s' 'TO''DO' 'T''BD' 'PLACE''HOLDER')"
if grep -R -n -E "$marker_re" "$SCAFFOLD"; then
  printf 'unexpected unresolved marker found in scaffold\n' >&2
  exit 1
fi

if grep -R -n -E '(password|token|secret)[[:space:]]*[:=]' "$SCAFFOLD" | grep -v '<'; then
  printf 'possible credential value found\n' >&2
  exit 1
fi

grep -q 'R CMD INSTALL' "$SCAFFOLD/Dockerfile.template"
grep -q 'rPVA::run_practical2_shiny' "$SCAFFOLD/Dockerfile.template"
grep -q 'system.file("shiny", "practical2", package = "rPVA")' "$SCAFFOLD/Dockerfile.template"
grep -q 'org.opencontainers.image.revision' "$SCAFFOLD/Dockerfile.template"
grep -q 'libuv1-dev' "$SCAFFOLD/Dockerfile.template"
grep -q 'HEALTHCHECK' "$SCAFFOLD/Dockerfile.template"
grep -q 'id: "kpz308-rpva-practical2"' "$SCAFFOLD/application.spec.example.yml"
grep -q 'git.its.utas.edu.au/utas/kpz308-rpva-practical2:' "$SCAFFOLD/application.spec.example.yml"
grep -q 'UNI-Ecology-Teaching-Shiny-Staff' "$SCAFFOLD/application.spec.example.yml"
grep -q 'KPZ308' "$SCAFFOLD/application.spec.example.yml"
grep -q '#{proxy.userId}' "$SCAFFOLD/application.spec.example.yml"
grep -q 'data/kpz308-rpva-practical2/workspaces/' "$SCAFFOLD/application.spec.example.yml"

bash -n "$SCAFFOLD/validate-scaffold.sh"

if command -v ruby >/dev/null 2>&1; then
  ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0))' "$SCAFFOLD/application.spec.example.yml"
else
  printf 'ruby unavailable; skipped YAML parse check\n' >&2
fi

printf 'Practical 2 Shiny deployment scaffold static checks passed.\n'
