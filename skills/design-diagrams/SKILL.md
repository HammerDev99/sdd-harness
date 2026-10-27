---
name: design-diagrams
description: Evalúa cuáles de ocho tipos de diagramas Mermaid son pertinentes según la spec de diseño, registra la decisión en docs/diagrams/README.md y genera y valida los diagramas pertinentes como archivos .mmd.
when_to_use: Cuando el usuario pida "diagramas", "diagramas Mermaid", "modelo ER", "diagrama de secuencia", "diagrama de clases", "modelo de dominio", "diagrama de estados", "actores y funciones", "qué diagramas conviene" o esté en la etapa 4 (Patrones y diagramas) con una spec aprobada.
---

# design-diagrams

Decide qué diagramas aportan valor y genera solo esos. Esta skill es dueña de `docs/diagrams/README.md`.

## Reglas

- No generes un diagrama por defecto: cada uno de los ocho tipos queda como Pertinente o Descartado, con motivo.
- Un diagrama por archivo `.mmd`, solo código Mermaid. Sigue las reglas de sintaxis de `${CLAUDE_PLUGIN_ROOT}/skills/design-diagrams/catalog.md`.
- Los diagramas deben ser coherentes con la spec: no inventes entidades ni actores que no estén en ella.

## Pasos

1. Lee la spec más reciente en `docs/superpowers/specs/` (y `CLAUDE.md`). Si no hay spec, dilo y sugiere `superpowers:brainstorming`; detente.
2. Lee `${CLAUDE_PLUGIN_ROOT}/skills/design-diagrams/catalog.md`. Para cada uno de los ocho tipos decide Pertinente o Descartado según sus criterios, con un motivo de una línea basado en la spec.
3. Crea `docs/diagrams/README.md`: si no existe, renderízalo con `"${CLAUDE_PLUGIN_ROOT}/scripts/render-template.sh" "${CLAUDE_PLUGIN_ROOT}/templates/diagrams-readme.md" docs/diagrams/README.md project="<proyecto>" date="<AAAA-MM-DD>" plugin_version="<versión>"`, con la versión de `jq -r .version "${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json"`. Si ya existe, edítalo en lugar de renderizar.
4. Rellena el README: sustituye la fila `_pendiente_` por una fila por diagrama generado (Archivo, Tipo, Para qué sirve, Momento) y añade la tabla de decisión:

   | Tipo | Decisión | Motivo |
   |---|---|---|
   | ER | Pertinente | … |
   | Contexto C4-1 | Descartado | … |

   La columna Decisión usa exactamente las palabras `Pertinente` y `Descartado`. Reemplaza también la línea de descartados y la de validación.
5. Genera cada diagrama pertinente en `docs/diagrams/<nombre>.mmd` (nombres del catálogo) a partir del esqueleto, adaptado a la spec.
6. Valida cada `.mmd`, en este orden de preferencia:
   - Si hay una herramienta MCP de Mermaid disponible (por ejemplo `validate_and_render_mermaid_diagram`), úsala con el contenido del archivo.
   - Si no, y `command -v mmdc` lo encuentra, ejecuta `mmdc -i docs/diagrams/<nombre>.mmd -o /tmp/<nombre>.svg` (borra la salida después).
   - Si no hay ninguna, anota "no validado" para ese diagrama en la línea de validación del README.
   Si un diagrama falla, corrige la sintaxis (revisa las reglas del catálogo) y revalida; no dejes archivos inválidos.
7. Revisión de arquitectura: señala incoherencias que los diagramas revelen en la spec (entidad sin relación, estado inalcanzable) y propónlas al usuario; no edites la spec.

## Reporte final

Tabla de los ocho tipos con decisión y motivo, lista de archivos generados con su resultado de validación y las incoherencias detectadas.
