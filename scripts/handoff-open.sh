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
  local read_json="$3"
  local write_json="$4"
  local next_recommended="$5"
  local risks_json="$6"

  printf '{\n'
  printf '  "status": %s,\n' "$(json_escape "$status")"
  printf '  "executive_summary": %s,\n' "$(json_escape "$summary")"
  printf '  "artifacts": {\n'
  printf '    "read": %s,\n' "$read_json"
  printf '    "write": %s\n' "$write_json"
  printf '  },\n'
  printf '  "next_recommended": %s,\n' "$(json_escape "$next_recommended")"
  printf '  "risks": %s\n' "$risks_json"
  printf '}\n'
}

usage() {
  cat <<'EOF' >&2
Uso:
  bash scripts/handoff-open.sh <change-id> <workstream-id> <mode>

Modes permitidos:
  implementation
  closure
  validation
  documentation
EOF
  exit 1
}

resolve_change_dir() {
  local change_ref="$1"
  local matches=()

  if [[ -d "changes/$change_ref" ]]; then
    printf '%s\n' "changes/$change_ref"
    return 0
  fi

  while IFS= read -r match; do
    matches+=("$match")
  done < <(find changes -maxdepth 1 -type d -name "$change_ref-*" | sort)

  if [[ ${#matches[@]} -eq 1 ]]; then
    printf '%s\n' "${matches[0]}"
    return 0
  fi

  return 1
}

if [[ $# -ne 3 ]]; then
  usage
fi

change_id="$1"
workstream_id="$2"
mode="$3"

case "$mode" in
  implementation|closure|validation|documentation)
    ;;
  *)
    emit_json "error" "El modo solicitado no es válido." "[]" "[]" "Usar uno de los modos permitidos." '["invalid_mode"]'
    exit 1
    ;;
esac

workstream_file="workstreams/${workstream_id}.md"
if [[ ! -f "$workstream_file" ]]; then
  emit_json "error" "No se encontró el workstream solicitado." "[]" "[]" "Registrar o corregir el workstream antes de abrir handoff." '["workstream_not_found"]'
  exit 1
fi

if ! change_dir="$(resolve_change_dir "$change_id")"; then
  emit_json "error" "No se encontró el change solicitado." "[]" "[]" "Verificar el ID o carpeta del change." '["change_not_found"]'
  exit 1
fi

master_file="$(find "$change_dir" -maxdepth 1 -type f -name 'CHG-*-*.md' ! -name 'CHG-*.WS-*.md' | sort | head -n 1)"
note_file="${change_dir}/${change_id}.${workstream_id}.md"

if [[ -z "$master_file" || ! -f "$master_file" ]]; then
  emit_json "error" "El change no tiene archivo maestro válido." "[]" "[]" "Corregir la estructura del change antes de abrir handoff." '["change_master_missing"]'
  exit 1
fi

if [[ ! -f "$note_file" ]]; then
  emit_json "error" "Falta la nota del workstream para este change." "[]" "[]" "Crear la nota hija o revisar el workstream asociado." '["handoff_note_missing"]'
  exit 1
fi

if ! grep -q "\[\[${change_id}.${workstream_id}\]\]" "$master_file"; then
  emit_json "error" "El workstream no figura como parte del change." "[]" "[]" "Revisar la tabla de workstreams del change maestro." '["workstream_not_in_change"]'
  exit 1
fi

read_files=(
  "$master_file"
  "$note_file"
  "$workstream_file"
  "guides/GUIDE-obsidian-update-protocol.md"
  "guides/GUIDE-session-prompts.md"
  "guides/GUIDE-change-lifecycle.md"
)

write_files=()
next_recommended="Ejecutar la sesión usando el prompt correspondiente al modo ${mode}."

case "$mode" in
  implementation|closure|documentation)
    write_files+=("$note_file")
    ;;
  validation)
    next_recommended="Revisar la nota y reportar hallazgos sin modificar archivos, salvo instrucción explícita."
    ;;
esac

read_json="$(path_list_to_json "${read_files[@]}")"
if [[ ${#write_files[@]} -gt 0 ]]; then
  write_json="$(path_list_to_json "${write_files[@]}")"
else
  write_json='[]'
fi

emit_json "ok" "Handoff listo para ${workstream_id} en modo ${mode}." "$read_json" "$write_json" "$next_recommended" "[]"
