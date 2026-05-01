# workstream-vault

Vault documental-operativo para coordinar cambios transversales entre múltiples repositorios.

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
