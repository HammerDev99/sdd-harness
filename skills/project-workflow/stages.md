# Etapas del flujo SDD (camino arquitectural)

Fuente de verdad del orden, las skills y los gates. `SKILL.md` indica cómo recorrerlas. Ningún gate se salta ni se da por cumplido sin evidencia (archivo, comando o confirmación del usuario).

Registro en `agent_docs/project_status.md`, sección `## Etapa del flujo`, con una línea de la forma `Etapa del flujo: N — nombre — fecha` (fecha `YYYY-MM-DD`). Se escribe al **completar el gate** de la etapa: la línea indica la etapa que sigue o está en curso, no la que se acaba de cerrar (ver "Convención de la línea" abajo).

| Etapa | Qué hace | Skill invocada | Gate | Qué escribe en `project_status.md` |
|---|---|---|---|---|
| 1 Scaffold | Crea el repositorio técnico; crea la carpeta de gestión si hay cliente | `sdd-harness:project-scaffold`, `sdd-harness:project-folder` (solo si hay cliente) | Archivos creados y primer commit | `Etapa del flujo: 2 — Diseño — <fecha>` |
| 2 Diseño | Brainstorming hasta tener la spec de diseño | `superpowers:brainstorming` | Spec escrita (en `docs/superpowers/specs/`) y aprobada por el usuario | `Etapa del flujo: 4 — Patrones y diagramas — <fecha>`, pero solo si no hay investigación en paralelo pendiente (ver etapa 3). Si el usuario decide investigar después de cerrar la spec, escribe `3 — Investigación` |
| 3 Investigación | Paralela a la etapa 2 si la spec depende de hechos externos | `sdd-harness:research-lines` | Informes en `docs/research/` y hallazgos confirmados en `project_status.md` | Al iniciar en paralelo: línea `Investigación en paralelo: iniciada — <fecha>` bajo la línea de etapa (que sigue en `2 — Diseño`). Al cerrar 2 y 3: `Etapa del flujo: 4 — Patrones y diagramas — <fecha>` y la línea de investigación pasa a `Investigación en paralelo: completada — <fecha>` (u `omitida — <fecha>` si el usuario prescinde) |
| 4 Patrones y diagramas | Revisa la spec con patrones de diseño; genera los diagramas pertinentes; revisión de arquitectura | `anthropic-skills:design-patterns` (primero), `sdd-harness:design-diagrams`, agente `sdd-harness:senior-architect` | Spec con sección "Patrones aplicados" y `docs/diagrams/README.md` existente | `Etapa del flujo: 5 — Plan — <fecha>` |
| 5 Plan | Plan por tareas | `superpowers:writing-plans` | Plan revisado y método de ejecución elegido | `Etapa del flujo: 6 — Ejecución — <fecha>` y el método elegido |
| 6 Ejecución | TDD por tarea; en el paso REFACTOR, catálogo de smells | `superpowers:subagent-driven-development` o `superpowers:executing-plans`; `superpowers:test-driven-development`; `anthropic-skills:refactoring` | Todas las tareas completas en el ledger | `Etapa del flujo: 7 — Cierre — <fecha>` |
| 7 Cierre | Revisión final con el catálogo de refactoring como instrumento; seguridad si `CLAUDE.md` declara `Datos personales: sí`; sincronía de docs | `superpowers:requesting-code-review`; agentes `sdd-harness:code-reviewer`, `sdd-harness:security-scanner` (solo si `CLAUDE.md` tiene la línea `Datos personales: sí`), `sdd-harness:doc-auditor`; `superpowers:finishing-a-development-branch` | Rama integrada y `project_status.md` actualizado | `Etapa del flujo: 7 — Cierre completado — <fecha>` |

## Convención de la línea

La línea nombra la etapa **pendiente** (la siguiente por cerrar). Al reanudar, la skill empieza en esa etapa. `7 — Cierre completado` significa que el flujo terminó. Las plantillas del scaffold nacen con `Etapa del flujo: 1 — ...`; la etapa 1 reescribe esa línea al cerrar su gate.

Si la línea no existe, la sección falta o `project_status.md` no existe, la etapa pendiente es la 1 (o la etapa que las evidencias del repositorio demuestren cerrada, verificadas una a una contra su gate).

## Detalle por etapa

### 1 Scaffold
Si ya se cumple el gate (`ls README.md CLAUDE.md agent_docs` y `git log --oneline -1`), no vuelvas a invocar el scaffold: avanza a la etapa 2. Si no, invoca `sdd-harness:project-scaffold`. Si el proyecto tiene cliente, invoca también `sdd-harness:project-folder`. Gate: los archivos existen (`ls README.md CLAUDE.md agent_docs`) y hay un primer commit (`git log --oneline -1`). Si el scaffold no hizo commit (repo ya existente), propónlo y espera la respuesta del usuario; no lo hagas sin que lo pida.

### 2 Diseño
Invoca `superpowers:brainstorming`. Gate: la spec existe en disco y el usuario la aprobó. Antes de invocar, decide si la spec depende de hechos externos (normas, APIs, referentes, cifras). Si sí, lanza la etapa 3 en paralelo y registra de inmediato `Investigación en paralelo: iniciada — <fecha>` bajo la línea de etapa. La línea de etapa permanece en `2 — Diseño` hasta que se cumplan los gates de 2 y 3.

### 3 Investigación
Invoca `sdd-harness:research-lines` (espera la aprobación de las líneas antes de lanzar agentes, como indica esa skill). Gate: existen informes en `docs/research/` y los hechos confirmados están en `project_status.md`. Los hallazgos alimentan la spec: si cambian el diseño, vuelve a la etapa 2 para actualizarla.

### 4 Patrones y diagramas
Orden obligatorio: (a) `anthropic-skills:design-patterns` sobre la spec; (b) añade a la spec la sección `## Patrones aplicados` (patrón, dónde se aplica, por qué; si ninguno aplica, dilo con la razón); (c) `sdd-harness:design-diagrams`; (d) dispara el agente `sdd-harness:senior-architect` para revisar spec y diagramas y entrega sus hallazgos al usuario. Gate: la sección "Patrones aplicados" existe (`grep -n "Patrones aplicados" <spec>`) y `docs/diagrams/README.md` existe.

### 5 Plan
Invoca `superpowers:writing-plans`. Gate: plan revisado y método de ejecución elegido por el usuario (`superpowers:subagent-driven-development` o `superpowers:executing-plans`). Registra el método en `project_status.md`.

### 6 Ejecución
Ejecuta con el método elegido. Cada tarea sigue `superpowers:test-driven-development`; en el paso REFACTOR, recuerda a quien implementa invocar `anthropic-skills:refactoring` (catálogo de smells y técnicas). Gate: todas las tareas figuran completas en el ledger del plan.

### 7 Cierre
Invoca `superpowers:requesting-code-review` y dispara `sdd-harness:code-reviewer` con el catálogo de `anthropic-skills:refactoring` como instrumento. Comprueba la declaración de datos personales con `grep -n "^Datos personales:" CLAUDE.md`. Si la línea es `Datos personales: sí`, dispara `sdd-harness:security-scanner`. Si dice `Datos personales: por definir` (o no existe), pregunta al usuario y actualiza esa línea a `sí` o `no` antes de decidir. Si es `no`, no lo dispares. Dispara `sdd-harness:doc-auditor` para verificar la sincronía de docs. Cierra con `superpowers:finishing-a-development-branch`. Gate: rama integrada y `project_status.md` actualizado.
