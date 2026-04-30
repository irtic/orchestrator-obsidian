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
  bash scripts/chg-consolidate.sh <change-id>
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

if [[ $# -ne 1 ]]; then
  usage
fi

change_id="$1"

if ! change_dir="$(resolve_change_dir "$change_id")"; then
  emit_json "error" "No se encontró el change solicitado." "[]" "Verificar el ID o carpeta del change." '["change_not_found"]'
  exit 1
fi

master_file="$(find "$change_dir" -maxdepth 1 -type f -name 'CHG-*-*.md' ! -name 'CHG-*.WS-*.md' | sort | head -n 1)"
if [[ -z "$master_file" || ! -f "$master_file" ]]; then
  emit_json "error" "El change no tiene archivo maestro válido." "[]" "Corregir la estructura del change antes de consolidar." '["change_master_missing"]'
  exit 1
fi

python3 - "$master_file" "$change_dir" <<'PY'
from pathlib import Path
import sys
import re

master_path = Path(sys.argv[1])
change_dir = Path(sys.argv[2])
notes = sorted(change_dir.glob('CHG-*.WS-*.md'))

if not notes:
    raise SystemExit('No existen notas de workstream para consolidar')

allowed_states = {"Pendiente", "En progreso", "Bloqueado", "Parcial", "Completado"}

def extract_section(text: str, heading: str):
    pattern = rf'^### {re.escape(heading)}$\n(.*?)(?=^### |\Z)'
    match = re.search(pattern, text, re.M | re.S)
    if not match:
        return []
    body = match.group(1).strip()
    return [line.strip()[2:] for line in body.splitlines() if line.strip().startswith('- ')]

def extract_state(text: str):
    match = re.search(r'^### Estado$\n([^\n]+)', text, re.M)
    if not match:
        return 'Pendiente'
    value = match.group(1).strip()
    return value if value in allowed_states else 'Pendiente'

state_counts = {state: 0 for state in allowed_states}
summary_lines = []
risks = []
blockers = []
state_by_workstream = {}

for note in notes:
    text = note.read_text()
    state = extract_state(text)
    state_counts[state] += 1
    workstream = note.stem.split('.', 1)[1]
    state_by_workstream[workstream] = state
    summary_lines.append(f"- {workstream}: {state}")
    risks.extend(extract_section(text, 'Riesgos'))
    blockers.extend(extract_section(text, 'Dependencias / bloqueos'))

def uniq(seq):
    seen = set()
    out = []
    for item in seq:
        if item and item not in seen and item not in {'No aplica', 'Pendiente'}:
            seen.add(item)
            out.append(item)
    return out

risks = uniq(risks)
blockers = uniq(blockers)

summary_block = '\n'.join(summary_lines) if summary_lines else 'Pendiente'
risks_block = '\n'.join(f'- {item}' for item in risks) if risks else '- No aplica'
blockers_block = '\n'.join(f'- {item}' for item in blockers) if blockers else '- No aplica'

text = master_path.read_text()

def update_workstream_table(source: str) -> str:
    lines = source.splitlines()
    out = []
    in_table = False
    for line in lines:
        if line == '## Workstreams impactados':
            in_table = True
            out.append(line)
            continue
        if in_table:
            if line.startswith('| `WS-'):
                cells = [cell.strip() for cell in line.strip().strip('|').split('|')]
                if len(cells) >= 4:
                    workstream = cells[0].strip('`')
                    if workstream in state_by_workstream:
                        cells[2] = state_by_workstream[workstream]
                        line = '| ' + ' | '.join(cells) + ' |'
                out.append(line)
                continue
            if line.startswith('## ') and line != '## Workstreams impactados':
                in_table = False
        out.append(line)
    return '\n'.join(out) + ('\n' if source.endswith('\n') else '')

text = update_workstream_table(text)

marker = '## Estado transversal\n'
idx = text.find(marker)
if idx == -1:
    raise SystemExit('No se encontró la sección ## Estado transversal')

prefix = text[:idx]
new_section = f'''## Estado transversal
> OWNER: consolidation
> MODE: replace-only

### Resumen
{summary_block}

### Riesgos abiertos
{risks_block}

### Dependencias abiertas
{blockers_block}
'''

master_path.write_text(prefix + new_section)
PY

artifacts_json="$(path_list_to_json "$master_file")"
emit_json "ok" "Se consolidó el change ${change_id}." "$artifacts_json" "Revisar el maestro consolidado y decidir si abrir nuevos handoffs o cerrar el change." "[]"
