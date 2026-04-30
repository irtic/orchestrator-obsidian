# GUIDE - Script Usage

## Objetivo
Explicar el uso real y cotidiano de los scripts operativos del vault.

## Scripts disponibles

| Script | Propósito |
|---|---|
| `scripts/validate-structure.sh` | validar estructura mínima del vault |
| `scripts/vault-validate.sh` | validar estructura y calidad operativa |
| `scripts/chg-new.sh` | crear un cambio nuevo |
| `scripts/handoff-open.sh` | preparar un handoff para una sesión |
| `scripts/handoff-close.sh` | cerrar una sesión de workstream |
| `scripts/chg-consolidate.sh` | consolidar el estado global de un change |

---

## Flujo recomendado

1. crear un change nuevo
2. abrir un handoff para un workstream
3. ejecutar la sesión real
4. cerrar el handoff
5. consolidar el change
6. validar el vault

---

## 1. Validación estructural mínima

```bash
bash scripts/validate-structure.sh
```

O vía make:

```bash
make validate
```

Uso:
- verificar que el vault no esté roto estructuralmente
- ejecutar antes y después de cambios importantes

---

## 2. Validación operativa

### Validar todo el vault

```bash
bash scripts/vault-validate.sh
```

### Validar un change

```bash
bash scripts/vault-validate.sh change CHG-031
```

### Validar un workstream

```bash
bash scripts/vault-validate.sh workstream WS-web-app
```

Uso:
- detectar errores estructurales
- detectar warnings semánticos
- revisar si falta progreso real o evidencia

---

## 3. Crear un change nuevo

```bash
bash scripts/chg-new.sh CHG-040 token-rotation \
  --system SYS-auth-platform \
  --workstreams WS-web-app,WS-api-core \
  --objective "Implementar rotación de tokens" \
  --motivation "Reducir exposición de sesiones largas" \
  --scope "cliente web|endpoint refresh" \
  --out-of-scope "OAuth externo" \
  --contracts API-auth-refresh \
  --adrs ADR-010-session-strategy
```

Uso:
- abrir trabajo transversal nuevo
- crear change maestro y notas hijas de una vez

---

## 4. Abrir un handoff

### Implementación

```bash
bash scripts/handoff-open.sh CHG-040 WS-web-app implementation
```

### Validación

```bash
bash scripts/handoff-open.sh CHG-040 WS-api-core validation
```

Uso:
- preparar una sesión nueva
- saber exactamente qué leer y qué editar

---

## 5. Cerrar un handoff

```bash
bash scripts/handoff-close.sh CHG-040 WS-web-app Parcial \
  --summary "Se integró consumo del endpoint|Se agregó renovación silenciosa" \
  --files "src/auth/client.ts|src/auth/session.ts" \
  --decisions "La renovación se centralizó en el session manager" \
  --risks "Depende de errores consistentes desde API" \
  --blockers "Falta confirmar contrato de refresh expirado" \
  --pending-for-others "WS-api-core debe estabilizar errores" \
  --evidence "Validación manual login->refresh"
```

Uso:
- dejar evidencia del trabajo real
- registrar riesgos y dependencias
- cerrar una sesión sin perder el contexto

---

## 6. Consolidar un change

```bash
bash scripts/chg-consolidate.sh CHG-040
```

Uso:
- actualizar el resumen global del change
- sincronizar la tabla de estados del maestro
- dejar riesgos y dependencias consolidadas

---

## Recomendación operativa

Después de cada paso importante:

```bash
make validate
```

Y antes de cerrar un change:

```bash
bash scripts/vault-validate.sh change CHG-040
```

---

## Regla práctica

No uses estos scripts para improvisar documentación.
Úsalos para reforzar el protocolo del vault.
