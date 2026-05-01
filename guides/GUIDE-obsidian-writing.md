# GUIDE - Obsidian Writing

## Objetivo
Definir reglas de escritura para notas del vault usando Markdown compatible con Obsidian.

## Principio
El vault usa Obsidian como interfaz humana, por lo tanto las notas deben escribirse con sintaxis válida y consistente para Obsidian.

Esta guía NO redefine el workflow del vault.
Solo define cómo escribir bien las notas dentro de la estructura existente.

---

## Regla principal

Para enlaces internos del vault, usar siempre:

```md
[[Nota]]
```

No usar enlaces Markdown normales para notas internas salvo caso excepcional.

### Correcto
```md
[[CHG-031-silent-session-renewal]]
[[WS-web-app]]
[[ADR-010-session-strategy]]
```

### Incorrecto
```md
[CHG-031](changes/CHG-031-silent-session-renewal/...)
```

---

## Wikilinks

Usar wikilinks para:
- systems
- workstreams
- changes
- contracts
- ADRs
- guides

### Con texto custom
```md
[[WS-web-app|web app]]
```

Usarlo solo cuando mejora la lectura. Si no, preferir el nombre directo.

---

## Headings

Los headings del vault deben permanecer estables.

### Regla
- no renombrar headings definidos por template sin decisión explícita
- no agregar headings nuevos en notas operativas `CHG-*.WS-*.md`
- respetar la jerarquía existente

---

## Callouts

Los callouts son opcionales.

### Usarlos solo cuando aportan valor real
Buenas candidatas:
- guías
- documentación explicativa
- advertencias importantes

### No abusar en notas operativas
En notas como `CHG-*.WS-*.md`, preferir estructura simple del template.

### Ejemplo válido
```md
> [!warning]
> No modificar esta sección fuera del workstream asignado.
```

---

## Frontmatter

El frontmatter es opcional en este sistema.

### Regla actual
No es obligatorio para el MVP.

Si se usa, debe aportar valor real, por ejemplo:
- `tags`
- `aliases`
- `status`

No agregar frontmatter por moda.

---

## Embeds

Los embeds se pueden usar, pero con criterio.

### Buenos casos
- imágenes de arquitectura
- diagramas exportados
- PDFs relevantes

### Evitar
- embeds decorativos
- embeds que dificultan lectura de notes operativas simples

---

## Mermaid

Mermaid sí puede aportar mucho para:
- arquitectura
- flujos
- dependencias entre workstreams

Pero no debe reemplazar documentación textual clave.

---

## Comentarios y texto oculto

Usar comentarios de Obsidian solo si ayudan a mantenimiento interno y no rompen la legibilidad.

```md
%% comentario interno %%
```

No esconder información que debería ser explícita en el workflow.

---

## Reglas prácticas del vault

1. usar `[[wikilinks]]` para todo enlace interno
2. mantener headings del template
3. no convertir notas operativas en documentos narrativos largos
4. usar callouts solo cuando realmente mejoren la lectura
5. mantener Markdown simple y estable

---

## Relación con workstream-coordinator

`workstream-coordinator` decide:
- qué archivo tocar
- cuándo tocarlo
- qué secciones están permitidas

Esta guía define:
- cómo escribir correctamente dentro de esas restricciones

---

## Regla final

Primero manda el workflow.
Después manda el formato.

La sintaxis Obsidian es una mejora de escritura, no una excusa para romper la estructura del vault.
