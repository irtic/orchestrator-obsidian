# GUIDE - Command Mapping

## Objetivo
Documentar cómo la interfaz humana simplificada del agente `workstream-coordinator` se traduce a la capa interna basada en scripts.

## Principio
La interfaz visible expresa intención.
La capa interna resuelve parámetros, ejecuta scripts y devuelve una respuesta humana clara.

---

## Mapeo general

| Comando humano | Script interno |
|---|---|
| `/change-new` | `scripts/chg-new.sh` |
| `/work-open` | `scripts/handoff-open.sh` |
| `/work-close` | `scripts/handoff-close.sh` |
| `/change-sync` | `scripts/chg-consolidate.sh` |
| `/change-status` | lectura del maestro + validación opcional |
| `/check-vault` | `scripts/vault-validate.sh` |

---

## `/change-new`

### Intención humana
Quiero iniciar un cambio nuevo.

### Ejemplo
```text
/change-new CHG-040 token-rotation en SYS-auth-platform para WS-web-app y WS-api-core
```

### Parámetros que el agente debe resolver
| Campo | Fuente |
|---|---|
| `change_id` | input del usuario |
| `slug` | input del usuario |
| `system` | input del usuario |
| `workstreams` | input del usuario |

### Acción interna
```bash
bash scripts/chg-new.sh <change-id> <slug> --system <system-id> --workstreams <ws1,ws2,...>
```

### Respuesta ideal al usuario
- cambio creado
- workstreams incluidos
- siguiente paso sugerido

---

## `/work-open`

### Intención humana
Quiero preparar la próxima sesión para un workstream.

### Ejemplo
```text
/work-open CHG-040 WS-web-app
```

### Resolución esperada
Si no se indica modo, usar `implementation` por defecto.

### Acción interna
```bash
bash scripts/handoff-open.sh <change-id> <workstream-id> <mode>
```

### Respuesta ideal al usuario
- handoff listo
- qué leer
- qué archivo puede editar
- siguiente acción sugerida

---

## `/work-close`

### Intención humana
Quiero cerrar esta sesión y registrar el resultado.

### Ejemplo
```text
/work-close CHG-040 WS-web-app Parcial
```

### Resolución esperada
Si faltan detalles, el agente debe pedir solo:
- resumen
- archivos
- riesgos
- pendientes
- evidencia

### Acción interna
```bash
bash scripts/handoff-close.sh <change-id> <workstream-id> <status> ...
```

### Respuesta ideal al usuario
- handoff cerrado
- estado registrado
- siguiente paso sugerido

---

## `/change-sync`

### Intención humana
Quiero actualizar el estado global del change.

### Ejemplo
```text
/change-sync CHG-040
```

### Acción interna
```bash
bash scripts/chg-consolidate.sh <change-id>
```

### Respuesta ideal al usuario
- consolidación realizada
- estados por workstream
- riesgos y bloqueos abiertos

---

## `/change-status`

### Intención humana
Quiero ver cómo va este change.

### Ejemplo
```text
/change-status CHG-040
```

### Acción interna sugerida
- leer el change maestro
- opcionalmente llamar `vault-validate.sh change <change-id>`

### Respuesta ideal al usuario
- estado por workstream
- riesgos abiertos
- siguiente paso recomendado

---

## `/check-vault`

### Intención humana
Quiero revisar la salud del vault.

### Ejemplos
```text
/check-vault
/check-vault CHG-040
/check-vault WS-web-app
```

### Resolución esperada
| Input | Scope interno |
|---|---|
| sin target | `all` |
| `CHG-*` | `change` |
| `WS-*` | `workstream` |

### Acción interna
```bash
bash scripts/vault-validate.sh
bash scripts/vault-validate.sh change <change-id>
bash scripts/vault-validate.sh workstream <workstream-id>
```

### Respuesta ideal al usuario
- estado general
- warnings semánticos
- siguiente paso sugerido

---

## Resolución inteligente

## Regla
El agente debe inferir primero y preguntar después.

### Ejemplo
Si el usuario dice:
```text
/work-open CHG-040
```

Entonces el agente:
- si hay un solo workstream pendiente, lo usa
- si hay varios, pregunta cuál

---

## Reglas de UX

1. No exponer shell por defecto
2. Preguntar solo cuando falte información crítica
3. Siempre devolver siguiente paso recomendado
4. Responder en lenguaje humano, no con detalles internos salvo que sean útiles

---

## Regla final

La persona usa intención.
El agente resuelve operación.
