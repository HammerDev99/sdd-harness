# workflow.md — Cómo trabajamos con IA

## Proceso

1. **Diseño** — `superpowers:brainstorming`. Resultado: spec en `docs/superpowers/specs/YYYY-MM-DD-<tema>-design.md`, aprobada por el responsable antes de planear.
2. **Plan** — `superpowers:writing-plans` → `docs/superpowers/plans/`. Se elige ejecución inline o por subagentes.
3. **Implementación** — TDD (`superpowers:test-driven-development`), commits pequeños en español.
4. **Verificación** — `superpowers:verification-before-completion` antes de declarar algo listo; revisión con `superpowers:requesting-code-review`.
5. **Investigación** — agentes paralelos (`superpowers:dispatching-parallel-agents`) para revisión de literatura; resultados en `docs/research/` con fuentes y fecha de consulta.

## Etapas del flujo

| Etapa | Nombre | Entrada | Salida |
|---|---|---|---|
| 1 | Scaffold | Brief, insumos del cliente | Estructura creada y primer commit |
| 2 | Diseño | Brief y preguntas abiertas | Spec aprobada |
| 3 | Investigación | Preguntas abiertas (paralela a 2 si la spec depende de hechos externos) | Informes en `docs/research/` |
| 4 | Patrones y diagramas | Spec | Sección "Patrones aplicados"; diagramas pertinentes y revisión de arquitectura |
| 5 | Plan | Spec y diagramas | Plan de implementación |
| 6 | Ejecución | Plan | Código con pruebas (TDD), revisado por tarea |
| 7 | Cierre | Rama completa | Revisión final, revisión de seguridad según la declaración de `CLAUDE.md`, docs sincronizadas |

La etapa vigente se anota en `project_status.md`. Al retomar el trabajo, se lee allí y se continúa desde ese punto.

## Layout de documentación

- Nivel 1 `CLAUDE.md` → nivel 2 `agent_docs/` → nivel 3 `docs/`.
- La estructura documental es exclusivamente la descrita en `docs/README.md`: specs, planes y verificación viven en el flujo de superpowers (`docs/superpowers/`).

## Fuentes de verdad

- Insumos y actas del cliente: la carpeta de gestión (ruta en `CLAUDE.md`).
- Decisiones de diseño: la spec vigente en `docs/superpowers/specs/`.
- Reglas de negocio: `docs/research/` + confirmaciones del cliente registradas en `project_status.md`.

## Gates

- No se escribe código del producto sin spec aprobada.
- No se presentan reglas de negocio como ciertas sin la etiqueta *por confirmar* o una fuente.
- No se exportan datos del cliente fuera de la carpeta de gestión ni de `data/`.
