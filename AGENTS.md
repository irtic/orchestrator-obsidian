# AGENTS

## Skills disponibles

| Skill | Descripción |
|---|---|
| `workstream-coordinator` | Coordina cambios transversales mediante systems, changes y workstreams sobre el vault |

## Regla principal
Usar `workstream-coordinator` como fachada principal cuando:
- un cambio afecte múltiples repositorios o unidades de ejecución
- se necesite preparar handoff entre sesiones
- se registre un nuevo workstream
- se consolide progreso transversal
- se valide estructura del vault

## Contrato esperado del agente

El agente debe:
- priorizar intención humana antes que sintaxis rígida
- inferir `change`, `workstream`, `mode` y `scope` antes de pedir aclaraciones
- usar el vault como fuente documental transversal
- usar el repositorio actual como fuente ejecutable de verdad
- preguntar solo cuando exista ambigüedad real o falte información crítica
- devolver siempre siguiente paso recomendado
