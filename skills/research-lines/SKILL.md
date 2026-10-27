---
name: research-lines
description: Propone de 3 a 5 líneas de investigación para un proyecto, espera aprobación, lanza un agente por línea con un brief estándar (marcas V/I/NV, fuentes con fecha) y consolida los hechos confirmados en agent_docs/project_status.md.
when_to_use: Cuando el usuario pida "investigar", "líneas de investigación", "revisión de literatura", "levantar información del dominio", "investigar referentes", "qué dice la norma", "lanzar agentes de investigación" o esté en la etapa 2 (Investigación) del flujo SDD.
---

# research-lines

Investigación en tres pasos: proponer, ejecutar en paralelo, consolidar. El paso 1 termina siempre esperando la respuesta del usuario.

## Reglas

- No lances ningún agente antes de que el usuario apruebe explícitamente la tabla de líneas.
- Los informes se escriben solo en `docs/research/NN_tema.md` (NN consecutivo de dos dígitos, tema en minúsculas con guion bajo). No sobrescribas informes existentes: continúa la numeración.
- Ningún dato del cliente va en los informes ni en los briefs.

## Pasos

1. **Proponer.** Lee `CLAUDE.md`, `agent_docs/project_status.md` y `docs/superpowers/specs/` si existen, y los insumos que el usuario mencione. Propón entre 3 y 5 líneas en una tabla con estas columnas exactas:

   | # | Pregunta | Fuentes esperadas | Decisión que desbloquea | Prioridad |
   |---|---|---|---|---|

   Prioridad: alta, media o baja. Termina el mensaje pidiendo aprobación o ajustes y **detente**: espera la respuesta del usuario. Si pide cambios, reescribe la tabla y vuelve a esperar.
2. **Ejecutar.** Con la tabla aprobada, invoca la skill `superpowers:dispatching-parallel-agents` y lanza un agente por línea aprobada, todos en el mismo mensaje. Para cada uno, lee `${CLAUDE_PLUGIN_ROOT}/skills/research-lines/brief-template.md` y sustituye `{{line_question}}` por la pregunta de la línea, `{{context}}` por un resumen del proyecto (qué es, stack, decisión que desbloquea la línea, sin datos del cliente) y `{{report_path}}` por `docs/research/NN_tema.md`. Entrega el brief completo como prompt del agente. Comprueba al terminar que cada archivo existe y tiene las secciones "Implicaciones" y "Resumen en diez líneas"; si falta alguno, relanza solo esa línea.
3. **Consolidar.** Lee los resúmenes de diez líneas y las implicaciones. En `agent_docs/project_status.md`, bajo `## Hechos confirmados por la investigación`, añade un punto por hecho `[V]` con la ruta del informe de origen (p. ej. `- Hecho. (docs/research/01_tema.md)`); los `[I]` y `[NV]` van como "por confirmar". Si el archivo no existe, indica que debe ejecutarse antes project-scaffold. Evita duplicar hechos ya presentes.

## Reporte final

Lista los informes creados, los hechos añadidos a `project_status.md`, las preguntas que quedan por confirmar con el cliente y el siguiente paso del flujo (diseño con `superpowers:brainstorming`).
