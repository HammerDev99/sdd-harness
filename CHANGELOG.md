# Changelog

## 0.1.0 — 2026-10-27

### Añadido

- Manifiesto del plugin (`userConfig.stopTimeoutSeconds`) y marketplace local en el mismo repo.
- Skills: `project-workflow` (entrada, siete etapas), `project-scaffold`, `research-lines`, `design-diagrams`, `project-folder`.
- Agentes: `code-reviewer`, `senior-architect`, `security-scanner`, `doc-auditor`.
- Hooks (nunca bloquean): `check-deps` (SessionStart), `post-edit` con ruff (PostToolUse) y `on-stop` con pytest y mypy (Stop). Solo actúan con `pyproject.toml`, salvo `check-deps`.
- Plantillas (CLAUDE.md, nueve `agent_docs`, READMEs, informe de investigación) y script de renderizado.
- Pruebas con bats (manifiesto, plantillas, skills, agentes, hooks), seis casos de eval y CI.

### Pendiente

- Ejecutar los evals con `claude plugin eval` y registrar resultados en `docs/smoke-test.md`.
- Instalación estable (`marketplace add` + `install --scope user`) y prueba de humo en directorio vacío, tras integrar la rama.
