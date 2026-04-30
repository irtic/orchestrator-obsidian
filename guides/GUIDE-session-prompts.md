# GUIDE - Session Prompts

## Objetivo
Centralizar prompts operativos reutilizables para trabajar con el vault por workstream, manteniendo sesiones separadas, escritura controlada y trazabilidad consistente.

## Regla principal
Una sesión = un workstream.

## Variables base

Reemplazar estas variables antes de usar cualquier prompt:

| Variable | Ejemplo |
|---|---|
| `{{system_id}}` | `SYS-auth-platform` |
| `{{change_id}}` | `CHG-025` |
| `{{change_folder}}` | `CHG-025-refresh-token` |
| `{{change_master_file}}` | `CHG-025-refresh-token.md` |
| `{{workstream_id}}` | `WS-api-core` |
| `{{workstream_file}}` | `WS-api-core.md` |
| `{{change_workstream_file}}` | `CHG-025.WS-api-core.md` |
| `{{repo_name}}` | `acme-api` |

## P1 - Implementación

```text
Trabaja únicamente dentro del workstream asignado para este repositorio y esta sesión.

## Contexto operativo
El vault es la fuente de verdad documental transversal.
La verdad ejecutable está en el código, tests, schemas y configuración del repositorio actual.

## Unidad de trabajo
- System: {{system_id}}
- Change: {{change_id}}
- Workstream: {{workstream_id}}
- Repo actual: {{repo_name}}

## Debes leer
1. `changes/{{change_folder}}/{{change_master_file}}`
2. `changes/{{change_folder}}/{{change_workstream_file}}`
3. `workstreams/{{workstream_file}}`
4. `guides/GUIDE-obsidian-update-protocol.md`
5. `guides/GUIDE-naming-conventions.md`
6. `guides/GUIDE-change-lifecycle.md`
7. Contratos y ADRs enlazados desde la nota del cambio y la nota del workstream

## Tu objetivo
Implementar solo la parte correspondiente a este workstream en el repositorio actual y actualizar estrictamente la nota documental autorizada.

## Restricciones obligatorias
1. Solo puedes editar:
   `changes/{{change_folder}}/{{change_workstream_file}}`
2. Solo puedes modificar:
   `## Implementación`
3. No puedes modificar:
   - la nota maestra del cambio
   - notas de otros workstreams
   - systems
   - contracts
   - adrs
   - guides
   - templates
4. No puedes:
   - crear encabezados nuevos
   - cambiar el orden de las secciones
   - editar bloques protected
   - inventar información
   - documentar trabajo de otros workstreams

## Formato obligatorio
Debes mantener exactamente estas subsecciones:
- `### Estado`
- `### Resumen técnico`
- `### Archivos modificados`
- `### Decisiones locales`
- `### Riesgos`
- `### Dependencias / bloqueos`
- `### Pendientes para otros workstreams`
- `### Evidencia`

## Reglas de contenido
- Si falta información: `Pendiente`
- Si no aplica: `No aplica`
- En `Estado` usa solo:
  - `Pendiente`
  - `En progreso`
  - `Bloqueado`
  - `Parcial`
  - `Completado`

## Entrega final
Debes devolver:
1. implementación en el repositorio actual
2. actualización estricta de `changes/{{change_folder}}/{{change_workstream_file}}`
3. resumen breve con:
   - trabajo realizado
   - bloqueos
   - pendientes para otros workstreams
   - evidencia
```

## P2 - Cierre de workstream

```text
No abras alcance nuevo. Tu objetivo es cerrar ordenadamente el trabajo del workstream actual.

## Contexto
- System: {{system_id}}
- Change: {{change_id}}
- Workstream: {{workstream_id}}
- Repo actual: {{repo_name}}

## Debes leer
1. `changes/{{change_folder}}/{{change_master_file}}`
2. `changes/{{change_folder}}/{{change_workstream_file}}`
3. `workstreams/{{workstream_file}}`
4. `guides/GUIDE-obsidian-update-protocol.md`

## Tu objetivo
Revisar lo ya implementado en el repositorio actual y dejar la nota del workstream lista como handoff limpio o cierre parcial/final.

## Restricciones
- Solo puedes editar `changes/{{change_folder}}/{{change_workstream_file}}`
- Solo puedes modificar `## Implementación`
- No cambies otras notas
- No agregues headings
- No cambies el orden
- No inventes información

## Debes actualizar
- Estado
- Resumen técnico
- Archivos modificados
- Riesgos
- Dependencias / bloqueos
- Pendientes para otros workstreams
- Evidencia
```

## P3 - Validación

```text
No implementes cambios de código.

## Contexto
- System: {{system_id}}
- Change: {{change_id}}
- Workstream: {{workstream_id}}
- Repo actual: {{repo_name}}

## Debes leer
1. `changes/{{change_folder}}/{{change_workstream_file}}`
2. `changes/{{change_folder}}/{{change_master_file}}`
3. `guides/GUIDE-obsidian-update-protocol.md`
4. `guides/GUIDE-naming-conventions.md`
5. `guides/GUIDE-change-lifecycle.md`

## Tu objetivo
Validar si la nota del workstream cumple el protocolo documental del vault.

## Verifica
- si el archivo correcto fue actualizado
- si solo se tocó `## Implementación`
- si no se agregaron headings nuevos
- si se mantuvo el orden de subsecciones
- si `Estado` usa un valor permitido
- si hay evidencia o Pendiente
- si los pendientes para otros workstreams están claros
- si hay contenido inventado o ambiguo

## Entrega
Devuelve un reporte con esta estructura:
- Estado general: Correcto / Incorrecto / Parcial
- Hallazgos críticos
- Hallazgos menores
- Recomendaciones
- Acciones correctivas mínimas
```

## P4 - Onboarding de repo nuevo

```text
Tu objetivo es integrar un nuevo repositorio al modelo documental del vault como un workstream reusable.

## Datos base
- System: {{system_id}}
- Repo nuevo: {{repo_name}}
- Workstream propuesto: {{workstream_id}}

## Debes leer
1. `guides/GUIDE-naming-conventions.md`
2. `guides/GUIDE-change-lifecycle.md`
3. `guides/GUIDE-obsidian-update-protocol.md`
4. `templates/WS-template.md`

## Tu objetivo
Crear o proponer la definición del nuevo workstream de forma abstracta, sin acoplarlo a categorías rígidas como frontend/backend/bff.

## Debes definir
- identidad del workstream
- responsabilidad
- límites
- sistema asociado
- entradas
- salidas
- dependencias
- regla de actualización en vault
```

## P5 - Consolidación

```text
No implementes código. Tu objetivo es consolidar el estado transversal del cambio.

## Contexto
- System: {{system_id}}
- Change: {{change_id}}

## Debes leer
1. `changes/{{change_folder}}/{{change_master_file}}`
2. todas las notas `changes/{{change_folder}}/CHG-*.WS-*.md`
3. contratos y ADRs enlazados si son necesarios
4. `guides/GUIDE-change-lifecycle.md`

## Tu objetivo
Actualizar el estado transversal del cambio a partir de las notas de workstream ya existentes.

## Puedes editar solo
- `changes/{{change_folder}}/{{change_master_file}}`
- únicamente la sección `## Estado transversal`
- y, si existe, `## Notas de consolidación`
```

## P6 - Solo documentación

```text
No modifiques código del repositorio actual.

## Contexto
- System: {{system_id}}
- Change: {{change_id}}
- Workstream: {{workstream_id}}
- Repo actual: {{repo_name}}

## Debes leer
1. `changes/{{change_folder}}/{{change_workstream_file}}`
2. `changes/{{change_folder}}/{{change_master_file}}`
3. `workstreams/{{workstream_file}}`
4. `guides/GUIDE-obsidian-update-protocol.md`

## Tu objetivo
Revisar el estado existente del workstream y actualizar únicamente la documentación autorizada.

## Restricciones
- solo editar `changes/{{change_folder}}/{{change_workstream_file}}`
- solo editar `## Implementación`
- no agregar headings
- no cambiar el orden
- no modificar otros documentos
```

## Regla de uso
Siempre:
1. reemplazar variables
2. elegir un solo prompt por sesión
3. mantener una sola responsabilidad por workstream
4. no mezclar implementación con consolidación salvo instrucción explícita
