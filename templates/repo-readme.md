# {{project}}

{{description}}

**Stack:** {{stack}}

## Estructura de la documentación

```
CLAUDE.md            Constitución del proyecto para agentes IA (nivel 1)
agent_docs/          Guías operativas por tema (nivel 2)
docs/                Historial: investigación, specs, planes, diagramas (nivel 3)
  research/          Revisión de literatura
  superpowers/       Specs y planes de implementación
  diagrams/          Diagramas Mermaid
data/                Datos locales ignorados por git
```

Este repositorio **no** contiene datos del cliente.

## Cómo se trabaja

El proyecto sigue un flujo de desarrollo guiado por especificaciones (SDD) en siete etapas:
Scaffold, diseño, investigación, patrones y diagramas, plan, ejecución y cierre. La etapa
vigente y los pendientes están en `agent_docs/project_status.md`; el detalle del proceso, en
`agent_docs/workflow.md`.

Scaffold: sdd-harness {{plugin_version}} ({{date}})
