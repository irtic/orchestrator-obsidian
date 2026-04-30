#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

assert_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    printf "Falta archivo requerido: %s\n" "$path" >&2
    exit 1
  fi
}

assert_contains() {
  local path="$1"
  local pattern="$2"
  if ! grep -q "$pattern" "$path"; then
    printf "Falta patrón '%s' en: %s\n" "$pattern" "$path" >&2
    exit 1
  fi
}

validate_workstream_note() {
  local path="$1"
  local status_value

  assert_contains "$path" "OWNER:"
  assert_contains "$path" "MODE:"
  assert_contains "$path" "## Implementación"
  assert_contains "$path" "### Estado"
  assert_contains "$path" "### Resumen técnico"
  assert_contains "$path" "### Archivos modificados"
  assert_contains "$path" "### Decisiones locales"
  assert_contains "$path" "### Riesgos"
  assert_contains "$path" "### Dependencias / bloqueos"
  assert_contains "$path" "### Pendientes para otros workstreams"
  assert_contains "$path" "### Evidencia"

  status_value="$(awk '
    /^### Estado$/ {getline; while ($0 ~ /^[[:space:]]*$/) getline; print; exit}
  ' "$path")"

  case "$status_value" in
    "Pendiente"|"En progreso"|"Bloqueado"|"Parcial"|"Completado")
      ;;
    *)
      printf "Estado inválido en %s: %s\n" "$path" "$status_value" >&2
      exit 1
      ;;
  esac
}

assert_file "README.md"
assert_file "AGENTS.md"
assert_file ".atl/skill-registry.md"
assert_file "guides/GUIDE-obsidian-update-protocol.md"
assert_file "guides/GUIDE-naming-conventions.md"
assert_file "guides/GUIDE-change-lifecycle.md"
assert_file "guides/GUIDE-session-prompts.md"
assert_file "templates/SYS-template.md"
assert_file "templates/WS-template.md"
assert_file "templates/CHG-template.md"
assert_file "templates/CHG-template.workstream.md"
assert_file "templates/ADR-template.md"
assert_file "templates/CONTRACT-template.md"
assert_file "systems/SYS-auth-platform.md"
assert_file "workstreams/WS-api-core.md"
assert_file "contracts/API-auth-refresh.md"
assert_file "adrs/ADR-010-session-strategy.md"
assert_file "changes/CHG-025-refresh-token/CHG-025-refresh-token.md"
assert_file "changes/CHG-025-refresh-token/CHG-025.WS-api-core.md"
assert_file "changes/CHG-025-refresh-token/CHG-025.WS-web-app.md"
assert_file "changes/CHG-025-refresh-token/CHG-025.WS-session-gateway.md"
assert_file "skills/workstream-coordinator/SKILL.md"

while IFS= read -r note; do
  validate_workstream_note "$note"
done < <(find changes -type f -name 'CHG-*.WS-*.md' | sort)

printf "Estructura mínima OK\n"
