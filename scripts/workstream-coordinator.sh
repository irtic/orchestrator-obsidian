#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

usage() {
  cat <<'EOF' >&2
Uso:
  bash scripts/workstream-coordinator.sh <command> [...args]

Comandos humanos soportados:
  /change-new
  /work-open
  /work-close
  /change-sync
  /change-status
  /check-vault
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

infer_workstream_for_change() {
  local change_dir="$1"
  python3 - <<'PY' "$change_dir"
from pathlib import Path
import sys, re

change_dir = Path(sys.argv[1])
notes = sorted(change_dir.glob('CHG-*.WS-*.md'))

active_candidates = []
pending_candidates = []
all_candidates = []
for note in notes:
    text = note.read_text()
    workstream = note.stem.split('.', 1)[1]
    match = re.search(r'^### Estado$\n([^\n]+)', text, re.M)
    state = match.group(1).strip() if match else 'Pendiente'
    all_candidates.append(workstream)
    if state in {'En progreso', 'Parcial'}:
        active_candidates.append(workstream)
    if state == 'Pendiente':
        pending_candidates.append(workstream)

if len(active_candidates) == 1:
    print(active_candidates[0])
elif len(pending_candidates) == 1:
    print(pending_candidates[0])
elif len(all_candidates) == 1:
    print(all_candidates[0])
PY
}

render_change_status() {
  local change_dir="$1"
  python3 - <<'PY' "$change_dir"
from pathlib import Path
import sys, re

change_dir = Path(sys.argv[1])
masters = sorted([p for p in change_dir.glob('CHG-*-*.md') if '.WS-' not in p.name])
if not masters:
    raise SystemExit('No se encontró maestro del change')

master = masters[0]
text = master.read_text()

def section(heading):
    pattern = rf'^### {re.escape(heading)}$\n(.*?)(?=^### |\Z)'
    match = re.search(pattern, text, re.M | re.S)
    if not match:
        return []
    body = match.group(1).strip()
    return [line.strip()[2:] for line in body.splitlines() if line.strip().startswith('- ')]

rows = []
for line in text.splitlines():
    if line.startswith('| `WS-'):
        cells = [cell.strip() for cell in line.strip().strip('|').split('|')]
        if len(cells) >= 4:
            rows.append((cells[0].strip('`'), cells[2]))

print('Estado: ok')
print(f'Hecho: Estado actual de {master.stem}.')
if rows:
    print('Workstreams:')
    for ws, state in rows:
        print(f'- {ws}: {state}')

risks = section('Riesgos abiertos')
blockers = section('Dependencias abiertas')
if risks:
    print('Warnings / riesgos:')
    for item in risks:
        print(f'- {item}')
if blockers:
    print('Dependencias abiertas:')
    for item in blockers:
        print(f'- {item}')

pending = [ws for ws, state in rows if state != 'Completado']
if pending:
    print('Siguiente paso recomendado:')
    print(f'- Abrir trabajo para {pending[0]} o consolidar más avances.')
PY
}

human_summary() {
  python3 -c '
import json, sys
data = json.load(sys.stdin)

status = data.get("status", "ok")
summary = data.get("executive_summary", "")
next_step = data.get("next_recommended", "")
risks = data.get("risks", [])
artifacts = data.get("artifacts", [])

print(f"Estado: {status}")
if summary:
    print(f"Hecho: {summary}")

if isinstance(artifacts, dict):
    read_items = artifacts.get("read", [])
    write_items = artifacts.get("write", [])
    if read_items:
      print("Lecturas:")
      for item in read_items:
          print(f"- {item}")
    if write_items:
      print("Escrituras:")
      for item in write_items:
          print(f"- {item}")
else:
    if artifacts:
      print("Afectado:")
      for item in artifacts:
          print(f"- {item}")

if risks:
    print("Warnings / riesgos:")
    for item in risks:
        print(f"- {item}")

if next_step:
    print("Siguiente paso recomendado:")
    print(f"- {next_step}")
 '
}

if [[ $# -lt 1 ]]; then
  usage
fi

command="$1"
shift || true

case "$command" in
  /change-new)
    if [[ $# -lt 4 ]]; then
      printf 'Uso: /change-new <CHG-id> <slug> <system> <ws1,ws2,...> [args extra de chg-new]\n' >&2
      exit 1
    fi
    change_id="$1"; slug="$2"; system_id="$3"; workstreams="$4"
    shift 4
    bash scripts/chg-new.sh "$change_id" "$slug" --system "$system_id" --workstreams "$workstreams" "$@" | human_summary
    ;;

  /work-open)
    if [[ $# -lt 1 ]]; then
      printf 'Uso: /work-open <CHG-id> [WS-id] [mode]\n' >&2
      exit 1
    fi
    change_id="$1"
    workstream_id="${2:-}"
    mode="${3:-implementation}"

    if [[ -z "$workstream_id" ]]; then
      if ! change_dir="$(resolve_change_dir "$change_id")"; then
        printf 'No se encontró el change: %s\n' "$change_id" >&2
        exit 1
      fi
      inferred_ws="$(infer_workstream_for_change "$change_dir" || true)"
      if [[ -n "$inferred_ws" ]]; then
        workstream_id="$inferred_ws"
      else
        printf 'Debes indicar workstream porque hay múltiples notas hijas en %s\n' "$change_id" >&2
        exit 1
      fi
    fi

    bash scripts/handoff-open.sh "$change_id" "$workstream_id" "$mode" | human_summary
    ;;

  /work-close)
    if [[ $# -lt 4 ]]; then
      printf 'Uso: /work-close <CHG-id> <WS-id> <Estado> <summary> [--files ...]\n' >&2
      exit 1
    fi
    change_id="$1"; workstream_id="$2"; state="$3"; summary="$4"
    shift 4
    bash scripts/handoff-close.sh "$change_id" "$workstream_id" "$state" --summary "$summary" "$@" | human_summary
    ;;

  /change-sync)
    if [[ $# -ne 1 ]]; then
      printf 'Uso: /change-sync <CHG-id>\n' >&2
      exit 1
    fi
    bash scripts/chg-consolidate.sh "$1" | human_summary
    ;;

  /change-status)
    if [[ $# -ne 1 ]]; then
      printf 'Uso: /change-status <CHG-id>\n' >&2
      exit 1
    fi
    if ! change_dir="$(resolve_change_dir "$1")"; then
      printf 'No se encontró el change: %s\n' "$1" >&2
      exit 1
    fi
    render_change_status "$change_dir"
    ;;

  /check-vault)
    if [[ $# -eq 0 ]]; then
      bash scripts/vault-validate.sh | human_summary
    elif [[ "$1" =~ ^CHG- ]]; then
      bash scripts/vault-validate.sh change "$1" | human_summary
    elif [[ "$1" =~ ^WS- ]]; then
      bash scripts/vault-validate.sh workstream "$1" | human_summary
    else
      printf 'No pude inferir si el target es change o workstream: %s\n' "$1" >&2
      exit 1
    fi
    ;;

  *)
    usage
    ;;
esac
