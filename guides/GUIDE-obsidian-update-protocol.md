# GUIDE - Obsidian Update Protocol

## Objetivo
Definir cómo cualquier sesión o agente puede actualizar el vault sin romper estructura, ownership ni trazabilidad.

## Principios
1. El vault es la fuente de verdad documental transversal.
2. El código, tests, schemas y migraciones siguen siendo la verdad ejecutable.
3. Las sesiones NO escriben libremente.
4. Cada sesión solo puede actualizar su nota autorizada.
5. Toda actualización debe respetar template, ownership y mode.
6. Si falta información, escribir `Pendiente`.
7. Si una sección no aplica, escribir `No aplica`.

## Unidad autorizada de escritura
- `changes/CHG-<id>-<slug>/CHG-<id>.<workstream>.md`

## Reglas obligatorias de edición
1. no crear encabezados nuevos
2. no cambiar el orden de secciones
3. no editar bloques `protected`
4. no escribir fuera del archivo autorizado
5. no documentar trabajo de otros workstreams
6. no reescribir contexto, alcance o decisiones globales
7. no inventar información
8. usar el template tal como existe

## Estados permitidos
- `Pendiente`
- `En progreso`
- `Bloqueado`
- `Parcial`
- `Completado`

## Formato obligatorio dentro de implementación
- `### Estado`
- `### Resumen técnico`
- `### Archivos modificados`
- `### Decisiones locales`
- `### Riesgos`
- `### Dependencias / bloqueos`
- `### Pendientes para otros workstreams`
- `### Evidencia`
