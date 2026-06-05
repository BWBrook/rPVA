#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
SCAFFOLD="$ROOT/deploy/shinyproxy/practical1"

required=(
  "$SCAFFOLD/README.md"
  "$SCAFFOLD/Dockerfile.template"
  "$SCAFFOLD/application.example.yml"
  "$SCAFFOLD/nginx-practical1.example.conf"
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
  printf 'possible non-placeholder credential value found\n' >&2
  exit 1
fi

bash -n "$SCAFFOLD/validate-scaffold.sh"

if command -v ruby >/dev/null 2>&1; then
  ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0))' "$SCAFFOLD/application.example.yml"
elif command -v python3 >/dev/null 2>&1; then
  python3 - "$SCAFFOLD/application.example.yml" <<'PY'
import sys
try:
    import yaml
except Exception as exc:
    raise SystemExit(f"python yaml parser unavailable: {exc}")
with open(sys.argv[1], "r", encoding="utf-8") as handle:
    yaml.safe_load(handle)
PY
else
  printf 'no local YAML parser found; skipped YAML parse check\n' >&2
fi

printf 'Practical 1 Shiny deployment scaffold static checks passed.\n'
