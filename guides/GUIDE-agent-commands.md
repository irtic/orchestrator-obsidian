# GUIDE - Agent Commands

## Objetivo
Definir la interfaz operativa inicial del agente `workstream-coordinator`.

## Principio
Los comandos deben operar sobre el vault con entradas mínimas, salidas estructuradas y restricciones explícitas.

---

## `/chg-new`

### Propósito
Crear un cambio transversal nuevo y dejar listo el espacio de trabajo por workstream.

### Sintaxis conceptual
```text
/chg-new <change-id> <slug> --system <system-id> --workstreams <ws1,ws2,...>
```

### Ejemplo
```text
/chg-new CHG-031 silent-session-renewal --system SYS-auth-platform --workstreams WS-web-app,WS-api-core,WS-session-gateway
```

### Inputs obligatorios
| Campo | Tipo | Ejemplo | Regla |
|---|---|---|---|
| `change_id` | string | `CHG-031` | debe empezar por `CHG-` |
| `slug` | string | `silent-session-renewal` | minúsculas y guiones |
| `system` | string | `SYS-auth-platform` | debe existir |
| `workstreams` | lista | `WS-web-app,WS-api-core` | todos deben existir |

### Inputs opcionales
| Campo | Tipo | Ejemplo |
|---|---|---|
| `objective` | string | renovar sesión silenciosamente |
| `motivation` | string | evitar relogin |
| `scope` | lista | ui refresh, endpoint refresh |
| `out_of_scope` | lista | oauth externo |
| `contracts` | lista | `API-auth-refresh` |
| `adrs` | lista | `ADR-010-session-strategy` |

### Efectos sobre archivos

#### Crea
| Archivo |
|---|
| `changes/CHG-031-silent-session-renewal/CHG-031-silent-session-renewal.md` |
| `changes/CHG-031-silent-session-renewal/CHG-031.WS-web-app.md` |
| `changes/CHG-031-silent-session-renewal/CHG-031.WS-api-core.md` |
| `changes/CHG-031-silent-session-renewal/CHG-031.WS-session-gateway.md` |

#### No debe tocar
- `systems/*`
- `contracts/*`
- `adrs/*`
- `workstreams/*`

### Reglas de validación previas
| Verificación | Si falla |
|---|---|
| `system` existe | error |
| todos los `workstreams` existen | error |
| `change_id` no está repetido | error |
| `slug` cumple convención | error |

### Salida estándar
```json
{
  "status": "ok",
  "executive_summary": "Se creó el cambio CHG-031 con 3 workstreams impactados.",
  "artifacts": [
    "changes/CHG-031-silent-session-renewal/CHG-031-silent-session-renewal.md",
    "changes/CHG-031-silent-session-renewal/CHG-031.WS-web-app.md",
    "changes/CHG-031-silent-session-renewal/CHG-031.WS-api-core.md",
    "changes/CHG-031-silent-session-renewal/CHG-031.WS-session-gateway.md"
  ],
  "next_recommended": "/handoff-open CHG-031 WS-web-app implementation",
  "risks": []
}
```

### Errores posibles
| Código conceptual | Caso |
|---|---|
| `system_not_found` | el system no existe |
| `workstream_not_found` | falta uno o más workstreams |
| `change_already_exists` | ya existe carpeta o maestro |
| `invalid_slug` | slug inválido |
| `invalid_change_id` | ID inválido |

---

## `/handoff-open`

### Propósito
Preparar un paquete operativo para una sesión concreta.

### Sintaxis conceptual
```text
/handoff-open <change-id> <workstream-id> <mode>
```

### Ejemplo
```text
/handoff-open CHG-031 WS-web-app implementation
```

### Inputs obligatorios
| Campo | Tipo | Ejemplo | Regla |
|---|---|---|---|
| `change_id` | string | `CHG-031` | debe existir |
| `workstream_id` | string | `WS-web-app` | debe existir |
| `mode` | enum | `implementation` | valor permitido |

### Valores permitidos para `mode`
| Mode | Uso |
|---|---|
| `implementation` | cambiar código + actualizar nota |
| `closure` | cerrar/ordenar estado |
| `validation` | revisar cumplimiento |
| `documentation` | actualizar solo vault |

### Resolución interna
Debe encontrar automáticamente:

| Dato | Cómo se obtiene |
|---|---|
| carpeta del change | por `change_id` |
| archivo maestro | `CHG-xxx-slug.md` |
| archivo del workstream | `CHG-xxx.WS-yyy.md` |
| definición del workstream | `workstreams/WS-yyy.md` |

### Salida útil
```json
{
  "status": "ok",
  "executive_summary": "Handoff listo para WS-web-app en modo implementation.",
  "artifacts": {
    "read": [
      "changes/CHG-031-silent-session-renewal/CHG-031-silent-session-renewal.md",
      "changes/CHG-031-silent-session-renewal/CHG-031.WS-web-app.md",
      "workstreams/WS-web-app.md",
      "guides/GUIDE-obsidian-update-protocol.md",
      "guides/GUIDE-session-prompts.md"
    ],
    "write": [
      "changes/CHG-031-silent-session-renewal/CHG-031.WS-web-app.md"
    ]
  },
  "next_recommended": "Ejecutar sesión usando el prompt P1 de implementación.",
  "risks": []
}
```

### Restricciones
| Regla | Motivo |
|---|---|
| un workstream por handoff | evitar mezcla |
| un mode por handoff | claridad |
| no escribir archivos | este comando prepara, no ejecuta |
| no inventar referencias | usar solo lo existente |

### Errores posibles
| Código conceptual | Caso |
|---|---|
| `change_not_found` | no existe el cambio |
| `workstream_not_in_change` | el workstream no participa en ese cambio |
| `invalid_mode` | modo no permitido |
| `handoff_note_missing` | falta la nota hija |

---

## `/vault-validate`

### Propósito
Validar estructura y consistencia del vault.

### Sintaxis conceptual
```text
/vault-validate [scope] [target]
```

### Ejemplos
```text
/vault-validate
/vault-validate change CHG-025-refresh-token
/vault-validate workstream WS-web-app
```

### Inputs opcionales
| Campo | Tipo | Ejemplo | Uso |
|---|---|---|---|
| `scope` | enum | `all`, `change`, `workstream` | nivel de validación |
| `target` | string | `CHG-025-refresh-token` | objeto específico |

Si no recibe nada, valida todo el vault.

### Tipos de validación
| Scope | Qué revisa |
|---|---|
| `all` | todo el vault |
| `change` | cambio maestro + notas hijas |
| `workstream` | existencia y consistencia de un `WS-*` |

### Reglas que debe revisar

#### Modo `all`
- archivos base existen
- guides existen
- templates existen
- skill base existe
- todos los `CHG-*.WS-*.md` cumplen estructura
- estados válidos
- naming coherente

#### Modo `change`
- existe cambio maestro
- existen notas hijas referenciadas
- workstreams del maestro coinciden con notas hijas
- notas hijas tienen estructura válida

#### Modo `workstream`
- existe `workstreams/WS-*.md`
- naming correcto
- referencias mínimas correctas
- aparece correctamente en changes donde corresponda (opcional más adelante)

### Salida estándar
```json
{
  "status": "warning",
  "executive_summary": "La validación del change CHG-025 encontró 1 warning y 0 errores críticos.",
  "artifacts": [
    "changes/CHG-025-refresh-token/CHG-025-refresh-token.md",
    "changes/CHG-025-refresh-token/CHG-025.WS-web-app.md"
  ],
  "next_recommended": "Corregir pendientes estructurales antes de abrir nuevas sesiones.",
  "risks": [
    "WS-session-gateway no tiene evidencia aún"
  ]
}
```

### Severidades
| Severidad | Uso |
|---|---|
| `error` | rompe el modelo |
| `warning` | no rompe, pero debilita calidad |
| `info` | observación útil |

### Errores posibles
| Código conceptual | Caso |
|---|---|
| `invalid_scope` | scope no soportado |
| `target_not_found` | no existe el target |
| `vault_inconsistent` | inconsistencias críticas |
| `validation_runtime_error` | fallo al correr validación |

---

## Formato de respuesta estándar

Todos los comandos deben devolver:

| Campo | Uso |
|---|---|
| `status` | `ok`, `warning`, `error` |
| `executive_summary` | resumen corto |
| `artifacts` | archivos creados, actualizados o inspeccionados |
| `next_recommended` | siguiente paso sugerido |
| `risks` | riesgos abiertos |

---

## Orden recomendado de implementación
1. `/chg-new`
2. `/handoff-open`
3. `/vault-validate`

## Regla de diseño
Congelar primero el contrato documental y operativo; implementar después.
