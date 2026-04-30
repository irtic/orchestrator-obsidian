# GUIDE - Human Interface

## Objetivo
Definir la interfaz humana simplificada del agente `workstream-coordinator`.

## Principio
La persona expresa intención. El agente resuelve los pasos internos.

Los scripts y comandos internos existen, pero NO deberían ser la interfaz principal del usuario.

---

## Comandos visibles

| Comando | Intención |
|---|---|
| `/change-new` | iniciar un cambio nuevo |
| `/work-open` | preparar trabajo para un workstream |
| `/work-close` | cerrar una sesión de trabajo |
| `/change-sync` | actualizar el estado global del change |
| `/change-status` | consultar el estado actual del change |
| `/check-vault` | revisar la salud del vault |

---

## `/change-new`

### Significado
Quiero empezar un cambio nuevo.

### Ejemplo
```text
/change-new CHG-040 token-rotation en SYS-auth-platform para WS-web-app y WS-api-core
```

### Qué hace internamente
- valida system
- valida workstreams
- crea la carpeta del change
- crea el maestro
- crea las notas por workstream

### Traducción interna
- `chg-new.sh`

---

## `/work-open`

### Significado
Quiero preparar la próxima sesión para un workstream.

### Ejemplo
```text
/work-open CHG-040 WS-web-app
```

O con modo explícito:

```text
/work-open CHG-040 WS-api-core validation
```

### Qué hace internamente
- localiza el change
- localiza la nota hija
- localiza el workstream
- devuelve qué leer y qué escribir

### Traducción interna
- `handoff-open.sh`

---

## `/work-close`

### Significado
Terminé esta parte y quiero dejar el resultado registrado.

### Ejemplo
```text
/work-close CHG-040 WS-web-app Parcial
```

### Qué hace internamente
- actualiza la sección `## Implementación`
- registra estado
- registra resumen técnico
- registra archivos, riesgos, bloqueos, pendientes y evidencia

### Traducción interna
- `handoff-close.sh`

---

## `/change-sync`

### Significado
Quiero actualizar el estado global del change.

### Ejemplo
```text
/change-sync CHG-040
```

### Qué hace internamente
- consolida las notas hijas
- actualiza `Estado transversal`
- sincroniza la tabla `Workstreams impactados`

### Traducción interna
- `chg-consolidate.sh`

---

## `/change-status`

### Significado
Quiero ver cómo va este change.

### Ejemplo
```text
/change-status CHG-040
```

### Qué debería mostrar
- estado por workstream
- riesgos abiertos
- bloqueos
- siguiente acción recomendada

### Implementación sugerida
- lectura del maestro
- validación opcional del change

---

## `/check-vault`

### Significado
Quiero revisar la salud del sistema documental.

### Ejemplo global
```text
/check-vault
```

### Ejemplo por change
```text
/check-vault CHG-040
```

### Qué hace internamente
- valida estructura
- valida consistencia
- reporta warnings semánticos

### Traducción interna
- `vault-validate.sh`

---

## Flujo humano ideal

| Paso | Comando |
|---|---|
| iniciar cambio | `/change-new` |
| preparar sesión | `/work-open` |
| cerrar sesión | `/work-close` |
| consolidar | `/change-sync` |
| consultar estado | `/change-status` |
| validar salud | `/check-vault` |

---

## Regla de diseño

Los comandos visibles deben reflejar intención, no implementación.

### Bueno
- `/change-new`
- `/work-open`
- `/work-close`

### Malo
- `/run-handoff-script`
- `/write-obsidian-note`
- `/update-change-master`

---

## Regla final

El usuario no debería pensar en scripts.
El agente debe encapsular la complejidad operativa del vault.
