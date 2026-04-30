#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

scope="${1:-all}"
target="${2:-}"

json_escape() {
  printf '%s' "$1" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
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

path_list_to_json() {
  python3 - "$@" <<'PY'
import json, sys
print(json.dumps(sys.argv[1:]))
PY
}

append_warning() {
  local warning="$1"
  if [[ -z "${warnings:-}" ]]; then
    warnings="$warning"
  else
    warnings+=$'\n'"$warning"
  fi
}

warnings_to_json() {
  if [[ -z "${warnings:-}" ]]; then
    printf '[]'
  else
    python3 - <<'PY' "$warnings"
import json, sys
items = [line.strip() for line in sys.argv[1].splitlines() if line.strip()]
print(json.dumps(items))
PY
  fi
}

extract_note_field() {
  local path="$1"
  local heading="$2"
  awk -v heading="$heading" '
    $0 == "### " heading {capture=1; next}
    capture && /^### / {exit}
    capture {print}
  ' "$path"
}

note_has_real_progress() {
  local path="$1"
  local summary_text evidence_text
  summary_text="$(extract_note_field "$path" "Resumen técnico")"
  evidence_text="$(extract_note_field "$path" "Evidencia")"

  if printf '%s\n%s\n' "$summary_text" "$evidence_text" | grep -qvE '^[[:space:]]*$|^- (Pendiente|No aplica)$'; then
    return 0
  fi
  return 1
}

note_has_real_evidence() {
  local path="$1"
  local evidence_text
  evidence_text="$(extract_note_field "$path" "Evidencia")"
  if printf '%s\n' "$evidence_text" | grep -qvE '^[[:space:]]*$|^- (Pendiente|No aplica)$'; then
    return 0
  fi
  return 1
}

validate_note_file() {
  local path="$1"
  grep -q "OWNER:" "$path"
  grep -q "MODE:" "$path"
  grep -q "## Implementación" "$path"
  grep -q "### Estado" "$path"
  grep -q "### Resumen técnico" "$path"
  grep -q "### Archivos modificados" "$path"
  grep -q "### Decisiones locales" "$path"
  grep -q "### Riesgos" "$path"
  grep -q "### Dependencias / bloqueos" "$path"
  grep -q "### Pendientes para otros workstreams" "$path"
  grep -q "### Evidencia" "$path"

  local status_value
  status_value="$(awk '
    /^### Estado$/ {getline; while ($0 ~ /^[[:space:]]*$/) getline; print; exit}
  ' "$path")"

  case "$status_value" in
    "Pendiente"|"En progreso"|"Bloqueado"|"Parcial"|"Completado")
      ;;
    *)
      printf 'Estado inválido en %s: %s\n' "$path" "$status_value" >&2
      return 1
      ;;
  esac
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

validate_all() {
  warnings=""
  bash scripts/validate-structure.sh >/dev/null
  while IFS= read -r note; do
    if ! note_has_real_progress "$note"; then
      append_warning "La nota ${note} sigue sin progreso real documentado."
    fi
    if ! note_has_real_evidence "$note"; then
      append_warning "La nota ${note} no tiene evidencia real todavía."
    fi
  done < <(find changes -type f -name 'CHG-*.WS-*.md' | sort)

  local artifacts_json
  artifacts_json="$(path_list_to_json README.md guides templates systems workstreams changes skills)"
  local status="ok"
  local summary="La validación completa del vault pasó correctamente."
  local risks_json
  risks_json="$(warnings_to_json)"
  if [[ "$risks_json" != "[]" ]]; then
    status="warning"
    summary="La validación completa del vault pasó con warnings semánticos."
  fi
  emit_json "$status" "$summary" "$artifacts_json" "Usar /vault-validate change <change-folder> para validar un cambio específico." "$risks_json"
}

validate_change() {
  warnings=""
  if [[ -z "$target" ]]; then
    printf 'Uso: vault-validate change <change-folder-o-id>\n' >&2
    exit 1
  fi

  local change_dir
  if ! change_dir="$(resolve_change_dir "$target")"; then
    emit_json "error" "No se encontró el change solicitado." "[]" "Verificar el nombre de carpeta o el ID del change." '["target_not_found"]'
    exit 1
  fi

  local master_file
  master_file="$(find "$change_dir" -maxdepth 1 -type f -name 'CHG-*-*.md' ! -name 'CHG-*.WS-*.md' | sort | head -n 1)"
  if [[ -z "$master_file" ]]; then
    emit_json "error" "El change no tiene archivo maestro." "[]" "Crear el archivo maestro del change." '["missing_change_master"]'
    exit 1
  fi

  local notes=()
  while IFS= read -r note; do
    notes+=("$note")
    validate_note_file "$note"
    if ! note_has_real_progress "$note"; then
      append_warning "La nota ${note} sigue completamente en Pendiente o sin progreso real."
    fi
    if ! note_has_real_evidence "$note"; then
      append_warning "La nota ${note} no tiene evidencia real todavía."
    fi
  done < <(find "$change_dir" -maxdepth 1 -type f -name 'CHG-*.WS-*.md' | sort)

  if [[ ${#notes[@]} -eq 0 ]]; then
    emit_json "error" "El change no tiene notas por workstream." "[]" "Crear notas CHG-*.WS-*.md para el change." '["missing_workstream_notes"]'
    exit 1
  fi

  local artifacts_json
  artifacts_json="$(path_list_to_json "$master_file" "${notes[@]}")"
  local status="ok"
  local summary="La validación del change pasó correctamente."
  local risks_json
  risks_json="$(warnings_to_json)"
  if [[ "$risks_json" != "[]" ]]; then
    status="warning"
    summary="La validación del change pasó con warnings semánticos."
  fi
  emit_json "$status" "$summary" "$artifacts_json" "Abrir un handoff con /handoff-open para un workstream de este change." "$risks_json"
}

validate_workstream() {
  warnings=""
  if [[ -z "$target" ]]; then
    printf 'Uso: vault-validate workstream <WS-id>\n' >&2
    exit 1
  fi

  local workstream_file="workstreams/${target}.md"
  if [[ ! -f "$workstream_file" ]]; then
    emit_json "error" "No se encontró el workstream solicitado." "[]" "Registrar primero el workstream con /ws-register." '["target_not_found"]'
    exit 1
  fi

  local notes=()
  while IFS= read -r note; do
    notes+=("$note")
    validate_note_file "$note"
    if ! note_has_real_progress "$note"; then
      append_warning "La nota ${note} sigue sin progreso real documentado."
    fi
    if ! note_has_real_evidence "$note"; then
      append_warning "La nota ${note} no tiene evidencia real todavía."
    fi
  done < <(find changes -type f -name "CHG-*.${target}.md" | sort)

  local risks='[]'
  if [[ ${#notes[@]} -eq 0 ]]; then
    risks='["El workstream existe pero aún no participa en ningún change documentado."]'
  fi

  local artifacts_json
  artifacts_json="$(path_list_to_json "$workstream_file" "${notes[@]}")"
  local warnings_json
  warnings_json="$(warnings_to_json)"
  if [[ "$warnings_json" != "[]" && "$risks" == "[]" ]]; then
    risks="$warnings_json"
  elif [[ "$warnings_json" != "[]" && "$risks" != "[]" ]]; then
    risks="$(python3 - <<'PY' "$risks" "$warnings_json"
import json, sys
left = json.loads(sys.argv[1])
right = json.loads(sys.argv[2])
print(json.dumps(left + right))
PY
)"
  fi

  local status="ok"
  local summary="La validación del workstream terminó correctamente."
  if [[ "$risks" != "[]" ]]; then
    status="warning"
    summary="La validación del workstream terminó con warnings semánticos."
  fi
  emit_json "$status" "$summary" "$artifacts_json" "Si corresponde, asociar este workstream a un nuevo change con /chg-new." "$risks"
}

case "$scope" in
  all)
    validate_all
    ;;
  change)
    validate_change
    ;;
  workstream)
    validate_workstream
    ;;
  *)
    emit_json "error" "Scope de validación no soportado." "[]" "Usar: all, change o workstream." '["invalid_scope"]'
    exit 1
    ;;
esac
