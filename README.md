# workstream-vault

Vault documental-operativo para coordinar cambios transversales entre múltiples repositorios.

## Empieza aquí en 60 segundos

### Qué es
Un vault para coordinar trabajo transversal por `systems`, `changes` y `workstreams`, sin mezclar contexto entre repositorios.

### Qué puedes hacer rápido
- ver el estado actual de un change
- abrir una sesión de trabajo para un workstream
- cerrar la sesión dejando evidencia
- consolidar el estado global
- validar la salud del vault

### Comandos mínimos

```bash
make validate
bash scripts/workstream-coordinator.sh CHG-031
bash scripts/workstream-coordinator.sh open CHG-031
bash scripts/workstream-coordinator.sh check CHG-031
```

### Flujo rápido
1. consultar el change
2. abrir trabajo
3. cerrar sesión
4. consolidar
5. validar

Ejemplo:

```bash
bash scripts/workstream-coordinator.sh CHG-031
bash scripts/workstream-coordinator.sh open CHG-031
bash scripts/workstream-coordinator.sh close CHG-031 parcial "Resumen técnico breve"
bash scripts/workstream-coordinator.sh sync CHG-031
bash scripts/workstream-coordinator.sh check CHG-031
```

### Si quieres ejemplos reales
- `guides/GUIDE-coordinator-cookbook.md`
- `guides/GUIDE-human-interface.md`
- `guides/GUIDE-coordinator-agent.md`

## Modelo
- System
- Change
- Workstream
- Contract
- ADR

## Regla principal
Las sesiones NO escriben libremente.
Cada sesión solo actualiza su nota `CHG-*.WS-*.md`.

## Uso rápido

### Validar estructura
```bash
make validate
```

### Validar operación del vault
```bash
bash scripts/vault-validate.sh
```

### Crear un change nuevo
```bash
bash scripts/chg-new.sh CHG-040 token-rotation --system SYS-auth-platform --workstreams WS-web-app,WS-api-core
```

### Abrir un handoff
```bash
bash scripts/handoff-open.sh CHG-040 WS-web-app implementation
```

### Cerrar un handoff
```bash
bash scripts/handoff-close.sh CHG-040 WS-web-app Parcial --summary "Resumen 1|Resumen 2"
```

### Consolidar un change
```bash
bash scripts/chg-consolidate.sh CHG-040
```

## Guías clave
- `guides/GUIDE-obsidian-update-protocol.md`
- `guides/GUIDE-session-prompts.md`
- `guides/GUIDE-agent-commands.md`
- `guides/GUIDE-script-usage.md`
- `guides/GUIDE-human-interface.md`
- `guides/GUIDE-coordinator-cookbook.md`
- `guides/GUIDE-coordinator-agent.md`

## OpenCode

Este repo incluye un `opencode.json` local con el agente:

- `workstream-coordinator`

Su prompt base vive en:

- `skills/workstream-coordinator/assets/agent-system-prompt.md`

## Carpetas
- `systems/`
- `workstreams/`
- `changes/`
- `contracts/`
- `adrs/`
- `guides/`
- `templates/`
- `logs/`
- `skills/`
- `.atl/`
