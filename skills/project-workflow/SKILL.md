---
name: project-workflow
description: Punto de entrada del flujo SDD. Clasifica el trabajo (spike, acotado, arquitectural); spike y acotado se delegan a superpowers:brainstorming, y el arquitectural recorre siete etapas con gate explícito, registradas en agent_docs/project_status.md y reanudables.
when_to_use: Cuando el usuario diga "nuevo proyecto", "estructurar el proyecto", "cómo trabajamos", "siguiente etapa", "framework de trabajo" o "iniciar proyecto con cliente", o pida retomar el flujo de un proyecto ya iniciado.
---

# project-workflow

Orquesta el flujo SDD. No hace el trabajo de cada etapa: invoca la skill o el agente que corresponde, verifica el gate y registra el avance. La tabla de etapas, skills y gates está en `${CLAUDE_PLUGIN_ROOT}/skills/project-workflow/stages.md`; léela completa antes de la primera etapa.

## Reglas

- El estado vive en `agent_docs/project_status.md`, nunca solo en la memoria de la sesión. Al retomar, lee el archivo; no confíes en lo que recuerdes.
- Nunca saltes un gate. Una etapa se cierra solo con la evidencia que `stages.md` exige para su gate (archivo, salida de comando o confirmación explícita del usuario). Si falta evidencia, repite o completa la etapa.
- Una etapa a la vez, salvo la investigación (etapa 3), que puede correr en paralelo a la etapa 2.
- Las skills y agentes de otros plugins se invocan por nombre completo; nunca copies su contenido. Los agentes del plugin son `sdd-harness:senior-architect`, `sdd-harness:code-reviewer`, `sdd-harness:security-scanner` y `sdd-harness:doc-auditor`.
- Las decisiones son del usuario: cuando un gate pida aprobación, pregunta y espera la respuesta antes de avanzar.

## Paso 1: clasificar

Clasifica el trabajo en uno de tres caminos. Si es ambiguo, haz una sola pregunta al usuario.

| Camino | Señales | Qué hacer |
|---|---|---|
| Spike | Exploración desechable, prueba de concepto, sin entregable duradero | Delega íntegramente a `superpowers:brainstorming` y termina. |
| Acotado | Cambio o función puntual en un proyecto existente, sin decisiones de arquitectura nuevas | Delega íntegramente a `superpowers:brainstorming` y termina. |
| Arquitectural | Proyecto nuevo, o cambio que introduce componentes, datos, integraciones o decisiones que perdurarán | Continúa con el paso 2. |

Para spike y acotado: invoca `superpowers:brainstorming` con el Skill tool, no ejecutes ninguna etapa de este flujo, no toques `project_status.md` y da por terminada esta skill.

Un proyecto nuevo (con o sin cliente) es siempre arquitectural.

## Paso 2: determinar la etapa actual

1. Comprueba si existe el archivo con `ls agent_docs/project_status.md`.
2. Si existe, localiza la línea con `grep -n "^Etapa del flujo: [0-9]" agent_docs/project_status.md`. El formato es `Etapa del flujo: N — nombre — fecha`. Ignora la línea de ejemplo del encabezado de formato si la hay (la línea válida empieza por `Etapa del flujo: ` seguida de un dígito).
3. Si la línea indica una etapa N (1 a 7), esa es la etapa pendiente: informa al usuario "Retomo en la etapa N — nombre" y continúa desde ahí, con estas comprobaciones previas:
   - **N = 1:** comprueba primero el gate de la etapa 1: `ls README.md CLAUDE.md agent_docs` (los tres existen) y `git log --oneline -1` (hay al menos un commit). Si se cumple, NO vuelvas a invocar `sdd-harness:project-scaffold`: registra el avance (paso 4) hacia la etapa 2 y continúa allí. Si falta algo, invoca solo lo que falte (el scaffold es idempotente) y, si falta el commit, propónlo al usuario.
   - **N entre 2 y 7:** verifica el gate de la etapa N-1 contra `stages.md`; si no se cumple, retrocede a esa etapa.
   - **N = 2:** busca además la línea `Investigación en paralelo:` con `grep -n "^Investigación en paralelo:" agent_docs/project_status.md` y revisa `ls docs/research/`. Si dice `iniciada`, la investigación sigue abierta: comprueba el gate de la etapa 3 (informes en `docs/research/` y hallazgos en `project_status.md`) y, si no se cumple, reanuda `sdd-harness:research-lines` junto con el diseño. Si ya existe la spec aprobada pero la investigación está pendiente, reanuda solo la etapa 3. La línea de etapa pasa a 4 únicamente cuando los gates de 2 y 3 estén cumplidos.
4. Si el archivo o la línea no existen, la etapa pendiente es la 1. Si el directorio ya contiene un proyecto, verifica gate por gate desde la etapa 1 qué está realmente cerrado y empieza en la primera etapa sin evidencia.
5. `Etapa del flujo: 7 — Cierre completado` significa flujo terminado: informa y pregunta si el usuario quiere iniciar una nueva iteración (vuelve al paso 1).

## Paso 3: ejecutar las etapas

Para cada etapa pendiente, en orden: invoca lo que indica `stages.md`, verifica el gate y registra el avance (paso 4). Resumen de lo que añade cada etapa a lo que dice la tabla:

**Etapa 1, Scaffold.** Invoca `sdd-harness:project-scaffold`. Si el proyecto tiene cliente, invoca después `sdd-harness:project-folder`. En un proyecto nuevo con cliente esta etapa va **antes** del brainstorming: la estructura y el `CLAUDE.md` deben existir cuando se diseñe. Si falta nombre, cliente o stack, pregunta una sola vez antes de invocar.

**Etapa 2, Diseño.** Invoca `superpowers:brainstorming`. Antes de empezar, decide si la spec dependerá de hechos externos (normas, APIs de terceros, referentes, cifras). Si sí, arranca la etapa 3 en paralelo y registra de inmediato, bajo la línea `Etapa del flujo: 2 — ...`, la línea `Investigación en paralelo: iniciada — <fecha>` (paso 4).

**Etapa 3, Investigación.** Invoca `sdd-harness:research-lines`. Si corre en paralelo a la etapa 2, lanza las líneas aprobadas en segundo plano mientras sigue el brainstorming, e incorpora los hallazgos a la spec cuando lleguen. No cierres la etapa 2 hasta que la 3 haya terminado o el usuario decida prescindir de ella; si decide prescindir, cambia la línea a `Investigación en paralelo: omitida — <fecha>`. Al cerrarla, cámbiala a `Investigación en paralelo: completada — <fecha>`.

**Etapa 4, Patrones y diagramas.** Orden fijo: primero `anthropic-skills:design-patterns` sobre la spec; después añade a la spec la sección `## Patrones aplicados` (es obligatoria; si ningún patrón aplica, la sección lo declara con su razón); luego `sdd-harness:design-diagrams`; por último dispara el agente `sdd-harness:senior-architect` para que revise la spec y los diagramas. Presenta sus hallazgos al usuario y resuelve los bloqueantes antes del gate.

**Etapa 5, Plan.** Invoca `superpowers:writing-plans`. Cuando el plan esté revisado, pregunta al usuario el método de ejecución: `superpowers:subagent-driven-development` o `superpowers:executing-plans`. Registra la elección.

**Etapa 6, Ejecución.** Ejecuta con el método elegido. Cada tarea sigue `superpowers:test-driven-development`. En el paso REFACTOR de cada ciclo, recuerda invocar `anthropic-skills:refactoring` (catálogo de smells y técnicas) y repítelo en los briefs de los implementadores. El gate exige todas las tareas completas en el ledger.

**Etapa 7, Cierre.** Invoca `superpowers:requesting-code-review` y dispara `sdd-harness:code-reviewer` con el catálogo de `anthropic-skills:refactoring` como instrumento de revisión. Comprueba con `grep -n "^Datos personales:" CLAUDE.md` la declaración de datos personales. Solo si la línea es `Datos personales: sí` dispara `sdd-harness:security-scanner`. Si dice `Datos personales: por definir` (o la línea no existe), pregunta al usuario, actualiza la línea a `Datos personales: sí` o `Datos personales: no` y decide según su respuesta. Dispara `sdd-harness:doc-auditor` para verificar la sincronía entre código y documentación. Resuelve los hallazgos y cierra con `superpowers:finishing-a-development-branch`.

## Paso 4: registrar el avance

Al cumplirse el gate de una etapa, y antes de iniciar la siguiente:

1. Abre `agent_docs/project_status.md` y localiza la sección `## Etapa del flujo`.
2. Reemplaza la línea `Etapa del flujo: ...` por la de la etapa que sigue, con la fecha de hoy (`date +%Y-%m-%d`), usando el valor exacto de la columna "Qué escribe en project_status.md" de `stages.md`. Ejemplo: `Etapa del flujo: 3 — Investigación — 2026-10-27`. Edita solo esa línea; no borres el resto del archivo ni la línea de formato.
3. Si la etapa produjo datos que la tabla pide registrar (método de ejecución, hallazgos), añádelos bajo las secciones correspondientes del mismo archivo.
4. Si el archivo no existe aún (la etapa 1 lo crea), escríbelo recién creado el scaffold.

Las etapas 2 y 3 en paralelo: la línea de etapa se queda en `2 — Diseño` mientras dure la investigación, acompañada de la línea `Investigación en paralelo: iniciada — <fecha>` (se añade justo debajo de la línea de etapa). Escribe la línea de la etapa 4 solo cuando ambos gates estén cumplidos, y en ese mismo momento actualiza la línea de investigación a `completada` u `omitida`. Si el usuario decide investigar después de cerrar la spec, escribe `3 — Investigación` como etapa pendiente.

## Reporte final

Tras cada sesión de trabajo, informa en español: etapa en que se retomó, etapas cerradas con la evidencia de cada gate, etapa pendiente (la que quedó escrita en `project_status.md`) y la decisión que se espera del usuario, si hay alguna.
