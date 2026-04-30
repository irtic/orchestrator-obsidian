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
      mapfile -t notes < <(find "$change_dir" -maxdepth 1 -type f -name 'CHG-*.WS-*.md' | sort)
      if [[ ${#notes[@]} -eq 1 ]]; then
        workstream_id="$(basename "${notes[0]}" .md | cut -d'.' -f2)"
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
    bash scripts/vault-validate.sh change "$1" | human_summary
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
