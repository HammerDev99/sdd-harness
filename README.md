# sdd-harness

Plugin de Claude Code que integra SDD (Spec-Driven Development) con un harness de calidad:
scaffold de documentación por niveles, líneas de investigación con agentes, diagramas de diseño,
carpeta de gestión del cliente, agentes revisores y hooks de calidad para Python. Orquesta las
skills de superpowers en vez de duplicarlas.

**Estado:** diseño. Spec en `docs/superpowers/specs/`. Fase personal; publicación diferida.

Origen: metodología CDAID v2 del repo `sdd-framework` y la estructuración del proyecto
Control_Biologicos_Vacunacion (2026-10-27), que sirve de caso de referencia.

## Desarrollo

- Probar el plugin localmente: `claude --plugin-dir .`
- Recargar tras cambios: `/reload-plugins`
- Ejecutar las pruebas: `bats tests/`
- Validar el manifiesto: `claude plugin validate --strict .`
