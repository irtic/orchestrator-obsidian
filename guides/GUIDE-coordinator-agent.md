# GUIDE - Coordinator Agent

## Objetivo
Definir la primera capa de agente real sobre el vault, para que `workstream-coordinator` actúe como una fachada conversacional y no solo como un wrapper de scripts.

## Principio
La persona expresa intención.
El agente resuelve contexto, elige el flujo correcto y usa el vault sin exponer complejidad innecesaria.

---

## Qué significa “agente real” aquí

No significa magia.
Significa que la interfaz debe poder:

- entender intención humana
- inferir parámetros faltantes razonables
- decidir el siguiente paso operativo
- pedir precisión solo si hay ambigüedad real
- responder con lenguaje humano y no con detalles internos crudos

---

## Responsabilidades del agente

### 1. Entender la intención

Debe reconocer intenciones como:
- crear cambio
- abrir trabajo
- cerrar trabajo
- consolidar estado
- consultar estado
- validar salud del vault
- orientar onboarding de un repo nuevo

### 2. Resolver contexto

Debe intentar resolver antes de preguntar:
- `change_id`
- `workstream_id`
- `mode`
- `scope`

Fuentes típicas de resolución:
- IDs explícitos (`CHG-031`, `WS-web-app`)
- referencias parciales únicas (`silent-session-renewal`, `web-app`)
- estado actual del change
- workstream activo o pendiente más razonable

### 3. Elegir flujo

| Intención detectada | Flujo esperado |
|---|---|
| crear cambio | `chg-new` |
| abrir trabajo | `handoff-open` |
| cerrar trabajo | `handoff-close` |
| consolidar | `chg-consolidate` |
| consultar estado | lectura del maestro |
| validar | `vault-validate` |
| integrar repo nuevo | flujo de onboarding |

### 4. Responder como fachada

La respuesta debe incluir, cuando aplique:
- qué pasó
- qué archivos o notas quedaron afectados
- warnings o riesgos
- siguiente paso recomendado

---

## Regla de inferencia

### Inferir primero
Si la inferencia es única y razonable, actuar.

### Preguntar después
Preguntar solo si:
- hay más de un change posible
- hay más de un workstream posible
- falta un dato crítico para escribir
- la acción puede degradar o sobrescribir información útil

### Nunca asumir de más
Si el riesgo de escribir mal es alto, pedir precisión mínima.

---

## Contrato conversacional mínimo

### Inputs que debería tolerar

```text
CHG-031
status silent-session-renewal
open CHG-031
open CHG-031 validation
close CHG-031 parcial "Resumen técnico breve"
check web-app
sync silent-session-renewal
```

### Comportamiento esperado

| Input humano | Comportamiento |
|---|---|
| `CHG-031` | mostrar estado del change |
| `open CHG-031` | abrir handoff del workstream más probable |
| `open CHG-031 validation` | abrir handoff en modo validación |
| `close CHG-031 parcial "..."` | cerrar el workstream inferible si es único |
| `check web-app` | validar el workstream si el match es único |
| `sync silent-session-renewal` | consolidar el change resuelto desde el slug |

---

## Cuándo debe preguntar

Ejemplos correctos de pregunta mínima:

```text
Veo más de un workstream posible para este change. ¿Quieres WS-web-app o WS-api-core?
```

```text
Puedo cerrar el handoff, pero me falta el resumen técnico mínimo. ¿Quieres dejar algo como resumen?
```

Ejemplos incorrectos:

```text
No entendí. Usa la sintaxis exacta /work-open <CHG-id> <WS-id> <mode>
```

Eso NO es una fachada; eso es delegar el problema al usuario.

---

## Reglas de escritura

Cuando el flujo implique documentación del vault:
- respetar ownership y mode
- editar solo la nota autorizada
- no crear headings nuevos
- no reordenar secciones
- no tocar bloques protegidos
- si falta información: `Pendiente`
- si no aplica: `No aplica`

---

## Capas del sistema

| Capa | Rol |
|---|---|
| agente | entiende intención y resuelve flujo |
| router | normaliza inputs y llama scripts |
| scripts | ejecutan operación concreta |
| vault | guarda la verdad documental transversal |

---

## Respuesta ideal

Formato deseable:

```text
Estado: ok|warning|error
Hecho: <resultado humano>
Warnings / riesgos:
- <si aplica>
Siguiente paso recomendado:
- <acción concreta>
```

---

## Regla final

El usuario no debería tener que pensar como shell.
Si necesita hacerlo, entonces todavía no estamos delante de un agente real.
