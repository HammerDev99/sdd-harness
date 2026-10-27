# CLAUDE.md — {{project}}

Constitución del proyecto. Nivel 1 de divulgación progresiva (~100 líneas).
Para detalle, consulta `agent_docs/` (nivel 2) y `docs/` (nivel 3).

Scaffold: sdd-harness {{plugin_version}} ({{date}})

## Qué es este proyecto

{{description}}

## Contexto

- Cliente: {{client}}
- Carpeta de gestión del proyecto (propuesta, plan, actas, facturación): `{{management_path}}`
- Repositorio técnico: {{repo_url}}
- Stack: {{stack}}

La carpeta de gestión no recibe código ni documentación técnica; este repositorio no recibe
datos del cliente.

## Reglas críticas

1. **Datos del cliente nunca al repo.** Hojas de cálculo, PDF, nombres, documentos de
   identidad y credenciales viven en la carpeta de gestión o en `data/` (ignorado por git).
   Demos a terceros con datos anonimizados. Si el proyecto trata datos personales, decláralo
   aquí y activa la revisión de seguridad en la etapa de cierre.
2. **Spec aprobada antes de código.** No se escribe código del producto sin una spec de
   diseño aprobada por el responsable del proyecto.
3. **Normalizar antes de calcular.** Entidades separadas, sin totales embebidos en filas de
   datos, tipos explícitos para fechas, dinero y cantidades. Ver `agent_docs/antipatterns.md`.
4. **Lo supuesto se marca.** Las reglas de negocio no confirmadas por el cliente llevan la
   etiqueta *por confirmar* hasta que se validen; en investigación se usan las marcas
   `[V]` verificado, `[I]` inferido y `[NV]` no verificado.
5. **Specs y planes con superpowers.** Diseño: `superpowers:brainstorming` →
   `docs/superpowers/specs/`. Plan: `superpowers:writing-plans` → `docs/superpowers/plans/`.
   La estructura documental es exclusivamente la descrita en este archivo y en
   `docs/README.md`; no se crean otras carpetas de planeación, porque superpowers ya cubre
   specs y planes.
6. **Documentación y commits en español**, formato convencional (`feat:`, `fix:`, `docs:`),
   sin firma de IA. Convenciones de nombres en `agent_docs/code_conventions.md`.
7. **Verificar antes de declarar listo.** Ninguna tarea se da por terminada sin ejecutar los
   comandos de verificación y leer su salida (`superpowers:verification-before-completion`).

## Flujo de trabajo (siete etapas)

| Etapa | Nombre | Resultado |
|---|---|---|
| 1 | Descubrimiento | Contexto, insumos y preguntas abiertas |
| 2 | Investigación | Informes en `docs/research/` con fuentes y fecha de consulta |
| 3 | Diseño | Spec aprobada en `docs/superpowers/specs/` |
| 4 | Diagramas y revisión de arquitectura | `docs/diagrams/` validados contra la spec |
| 5 | Plan | Plan de implementación en `docs/superpowers/plans/` |
| 6 | Implementación | TDD, commits pequeños, revisión por tarea |
| 7 | Cierre | Revisión final, seguridad si hay datos personales, sincronía de docs |

La etapa vigente se registra en `agent_docs/project_status.md`. Detalle en `agent_docs/workflow.md`.

## Tabla de divulgación

| Necesitas… | Consulta |
|---|---|
| Cómo trabajamos (skills, agentes, gates) | `agent_docs/workflow.md` |
| Modelo de dominio y entidades | `agent_docs/architecture.md` |
| Qué NO hacer con los datos y el código | `agent_docs/antipatterns.md` |
| Problemas conocidos y cómo tratarlos | `agent_docs/troubleshooting.md` |
| Estado, hitos y pendientes | `agent_docs/project_status.md` |
| Convenciones de código | `agent_docs/code_conventions.md` |
| Tests y verificación | `agent_docs/testing.md`, `agent_docs/verification_metrics.md` |
| Logging | `agent_docs/logging.md` |
| Investigación | `docs/research/` |
| Diagramas | `docs/diagrams/` |
| Insumos del cliente | Carpeta de gestión: `{{management_path}}` |

## Estado actual ({{date}})

- [ ] Etapa 1 — Descubrimiento
- [ ] Siguiente hito: ver `agent_docs/project_status.md`

## Instrucciones de compactación

Preservar: las reglas críticas, la etapa vigente del flujo, el modelo de entidades de
`architecture.md`, los problemas conocidos de `troubleshooting.md`, las fechas de hitos y el
estado de la spec y del plan.
