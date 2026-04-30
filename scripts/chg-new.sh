#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

json_escape() {
  printf '%s' "$1" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
}

path_list_to_json() {
  python3 - "$@" <<'PY'
import json, sys
print(json.dumps(sys.argv[1:]))
PY
}

emit_json() {
  local status="$1"
  local summary="$2"
  local artifacts_json="$3"
  local next_recommended="$4"
  local risks_json="$5"

  printf '{\n'
  printf '  "status": %s,\n' "$(json_escape "$status")"
  printf '  "executive_summary": %s,\n' "$(json_escape "$summary")"
  printf '  "artifacts": %s,\n' "$artifacts_json"
  printf '  "next_recommended": %s,\n' "$(json_escape "$next_recommended")"
  printf '  "risks": %s\n' "$risks_json"
  printf '}\n'
}

usage() {
  cat <<'EOF' >&2
Uso:
  bash scripts/chg-new.sh <change-id> <slug> --system <system-id> --workstreams <ws1,ws2,...>

Opcionales:
  --objective "texto"
  --motivation "texto"
  --scope "item 1|item 2"
  --out-of-scope "item 1|item 2"
  --contracts "API-a,API-b"
  --adrs "ADR-001,ADR-002"
EOF
  exit 1
}

require_file() {
  local path="$1"
  local code="$2"
  local message="$3"
  if [[ ! -f "$path" ]]; then
    emit_json "error" "$message" "[]" "Verificar referencias de entrada antes de reintentar." "[$(json_escape "$code")]"
    exit 1
  fi
}

if [[ $# -lt 5 ]]; then
  usage
fi

change_id="$1"
slug="$2"
shift 2

system_id=""
workstreams_csv=""
objective="Pendiente"
motivation="Pendiente"
scope_raw="Pendiente"
out_of_scope_raw="Pendiente"
contracts_csv=""
adrs_csv=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --system)
      system_id="${2:-}"
      shift 2
      ;;
    --workstreams)
      workstreams_csv="${2:-}"
      shift 2
      ;;
    --objective)
      objective="${2:-}"
      shift 2
      ;;
    --motivation)
      motivation="${2:-}"
      shift 2
      ;;
    --scope)
      scope_raw="${2:-}"
      shift 2
      ;;
    --out-of-scope)
      out_of_scope_raw="${2:-}"
      shift 2
      ;;
    --contracts)
      contracts_csv="${2:-}"
      shift 2
      ;;
    --adrs)
      adrs_csv="${2:-}"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

if [[ ! "$change_id" =~ ^CHG-[0-9]+$ ]]; then
  emit_json "error" "El change_id es inválido." "[]" "Usar formato CHG-<número>." '["invalid_change_id"]'
  exit 1
fi

if [[ ! "$slug" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  emit_json "error" "El slug es inválido." "[]" "Usar minúsculas y guiones medios." '["invalid_slug"]'
  exit 1
fi

if [[ -z "$system_id" || -z "$workstreams_csv" ]]; then
  usage
fi

require_file "systems/${system_id}.md" "system_not_found" "No se encontró el system indicado."

change_dir="changes/${change_id}-${slug}"
master_file="${change_dir}/${change_id}-${slug}.md"

if [[ -e "$change_dir" ]]; then
  emit_json "error" "El change ya existe." "[]" "Usar otro change_id o slug." '["change_already_exists"]'
  exit 1
fi

IFS=',' read -r -a raw_workstreams <<< "$workstreams_csv"
workstreams=()
for ws in "${raw_workstreams[@]}"; do
  ws_trimmed="$(printf '%s' "$ws" | tr -d '[:space:]')"
  [[ -z "$ws_trimmed" ]] && continue
  require_file "workstreams/${ws_trimmed}.md" "workstream_not_found" "No se encontró uno de los workstreams indicados."
  workstreams+=("$ws_trimmed")
done

if [[ ${#workstreams[@]} -eq 0 ]]; then
  emit_json "error" "No se proporcionaron workstreams válidos." "[]" "Indicar al menos un workstream existente." '["workstream_not_found"]'
  exit 1
fi

list_to_markdown() {
  local raw="$1"
  if [[ -z "$raw" || "$raw" == "Pendiente" ]]; then
    printf '%s\n' '- Pendiente'
    return 0
  fi

  IFS='|' read -r -a items <<< "$raw"
  for item in "${items[@]}"; do
    item_trimmed="$(printf '%s' "$item" | sed 's/^ *//;s/ *$//')"
    [[ -n "$item_trimmed" ]] && printf -- '- %s\n' "$item_trimmed"
  done
}

refs_to_markdown() {
  local csv="$1"
  if [[ -z "$csv" ]]; then
    printf '%s\n' '- Pendiente'
    return 0
  fi

  IFS=',' read -r -a refs <<< "$csv"
  for ref in "${refs[@]}"; do
    ref_trimmed="$(printf '%s' "$ref" | tr -d '[:space:]')"
    [[ -n "$ref_trimmed" ]] && printf -- '- [[%s]]\n' "$ref_trimmed"
  done
}

workstreams_table() {
  for ws in "${workstreams[@]}"; do
    repo_line="$(grep -m1 '^\- Repo:' "workstreams/${ws}.md" || true)"
    repo_name="$(printf '%s' "$repo_line" | sed -E 's/^- Repo: `([^`]+)`/\1/')"
    [[ -z "$repo_name" || "$repo_name" == "$repo_line" ]] && repo_name="Pendiente"
    printf '| `%s` | `%s` | Pendiente | [[%s.%s]] |\n' "$ws" "$repo_name" "$change_id" "$ws"
  done
}

mkdir -p "$change_dir"

cat > "$master_file" <<EOF
# ${change_id} - $(printf '%s' "$slug" | tr '-' ' ' | sed 's/\b\([a-z]\)/\u\1/g')

## Control
> OWNER: architect
> MODE: protected

## Objetivo
${objective}

## Motivación
${motivation}

## Alcance
$(list_to_markdown "$scope_raw")

## No alcance
$(list_to_markdown "$out_of_scope_raw")

## Sistema
- [[${system_id}]]

## Referencias
### Contratos
$(refs_to_markdown "$contracts_csv")

### ADRs
$(refs_to_markdown "$adrs_csv")

## Workstreams impactados
| Workstream | Repo | Estado | Nota |
|---|---|---|---|
$(workstreams_table)

## Estado transversal
> OWNER: consolidation
> MODE: replace-only

### Resumen
Pendiente
EOF

created_files=("$master_file")

for ws in "${workstreams[@]}"; do
  note_file="${change_dir}/${change_id}.${ws}.md"
  cat > "$note_file" <<EOF
# ${change_id} - ${ws}

## Control
> OWNER: ${ws}
> MODE: replace-only

## Contexto
> OWNER: architect
> MODE: protected

### Cambio maestro
[[${change_id}-${slug}]]

### Workstream
[[${ws}]]

### Sistema
[[${system_id}]]

### Contratos aplicables
$(refs_to_markdown "$contracts_csv")

### ADRs aplicables
$(refs_to_markdown "$adrs_csv")

## Implementación
> OWNER: ${ws}
> MODE: replace-only

### Estado
Pendiente

### Resumen técnico
- Pendiente

### Archivos modificados
- Pendiente

### Decisiones locales
- Pendiente

### Riesgos
- Pendiente

### Dependencias / bloqueos
- Pendiente

### Pendientes para otros workstreams
- Pendiente

### Evidencia
- Pendiente
EOF
  created_files+=("$note_file")
done

artifacts_json="$(path_list_to_json "${created_files[@]}")"
emit_json "ok" "Se creó el cambio ${change_id} con ${#workstreams[@]} workstreams impactados." "$artifacts_json" "/handoff-open ${change_id} ${workstreams[0]} implementation" "[]"
