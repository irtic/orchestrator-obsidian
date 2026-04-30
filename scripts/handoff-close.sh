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
  bash scripts/handoff-close.sh <change-id> <workstream-id> <status> \
    --summary "texto|texto" \
    [--files "ruta1|ruta2"] \
    [--decisions "texto|texto"] \
    [--risks "texto|texto"] \
    [--blockers "texto|texto"] \
    [--pending-for-others "texto|texto"] \
    [--evidence "texto|texto"]

Estados válidos:
  Pendiente | En progreso | Bloqueado | Parcial | Completado
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

to_bullets() {
  local raw="$1"
  if [[ -z "$raw" ]]; then
    printf '%s\n' '- No aplica'
    return 0
  fi

  IFS='|' read -r -a parts <<< "$raw"
  local printed=0
  for part in "${parts[@]}"; do
    trimmed="$(printf '%s' "$part" | sed 's/^ *//;s/ *$//')"
    if [[ -n "$trimmed" ]]; then
      printf -- '- %s\n' "$trimmed"
      printed=1
    fi
  done

  if [[ $printed -eq 0 ]]; then
    printf '%s\n' '- No aplica'
  fi
}

if [[ $# -lt 5 ]]; then
  usage
fi

change_id="$1"
workstream_id="$2"
state="$3"
shift 3

case "$state" in
  "Pendiente"|"En progreso"|"Bloqueado"|"Parcial"|"Completado")
    ;;
  *)
    emit_json "error" "Estado inválido para cerrar handoff." "[]" "Usar uno de los estados permitidos." '["invalid_status"]'
    exit 1
    ;;
esac

summary=""
files=""
decisions=""
risks=""
blockers=""
pending_for_others=""
evidence=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --summary)
      summary="${2:-}"
      shift 2
      ;;
    --files)
      files="${2:-}"
      shift 2
      ;;
    --decisions)
      decisions="${2:-}"
      shift 2
      ;;
    --risks)
      risks="${2:-}"
      shift 2
      ;;
    --blockers)
      blockers="${2:-}"
      shift 2
      ;;
    --pending-for-others)
      pending_for_others="${2:-}"
      shift 2
      ;;
    --evidence)
      evidence="${2:-}"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

if [[ -z "$summary" ]]; then
  usage
fi

if ! change_dir="$(resolve_change_dir "$change_id")"; then
  emit_json "error" "No se encontró el change solicitado." "[]" "Verificar el ID o carpeta del change." '["change_not_found"]'
  exit 1
fi

note_file="${change_dir}/${change_id}.${workstream_id}.md"
if [[ ! -f "$note_file" ]]; then
  emit_json "error" "No se encontró la nota hija del workstream para este change." "[]" "Abrir un handoff válido antes de cerrarlo." '["handoff_note_missing"]'
  exit 1
fi

python3 - "$note_file" "$state" "$summary" "$files" "$decisions" "$risks" "$blockers" "$pending_for_others" "$evidence" <<'PY'
from pathlib import Path
import sys

note_path = Path(sys.argv[1])
state, summary, files, decisions, risks, blockers, pending, evidence = sys.argv[2:]

def bullets(raw: str, default: str) -> str:
    items = [part.strip() for part in raw.split('|') if part.strip()]
    if not items:
        return f"- {default}"
    return "\n".join(f"- {item}" for item in items)

text = note_path.read_text()
marker = "## Implementación\n"
idx = text.find(marker)
if idx == -1:
    raise SystemExit("No se encontró la sección ## Implementación")

prefix = text[:idx]
new_impl = f'''## Implementación
> OWNER: {note_path.stem.split('.', 1)[1]}
> MODE: replace-only

### Estado
{state}

### Resumen técnico
{bullets(summary, 'Pendiente')}

### Archivos modificados
{bullets(files, 'No aplica')}

### Decisiones locales
{bullets(decisions, 'No aplica')}

### Riesgos
{bullets(risks, 'No aplica')}

### Dependencias / bloqueos
{bullets(blockers, 'No aplica')}

### Pendientes para otros workstreams
{bullets(pending, 'No aplica')}

### Evidencia
{bullets(evidence, 'Pendiente')}
'''

note_path.write_text(prefix + new_impl)
PY

artifacts_json="$(path_list_to_json "$note_file")"
next_recommended="Evaluar si corresponde consolidar el change o abrir el siguiente handoff."

emit_json "ok" "Se cerró el handoff para ${workstream_id} con estado ${state}." "$artifacts_json" "$next_recommended" "[]"
