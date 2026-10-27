# sdd-harness

Plugin de Claude Code que integra SDD (Spec-Driven Development) con un harness de calidad:
scaffold de documentación por niveles, líneas de investigación con agentes, diagramas de diseño,
carpeta de gestión del cliente, agentes revisores y hooks de calidad para Python. Orquesta las
skills de superpowers en vez de duplicarlas.

**Estado:** v0.1.0, fase personal; publicación diferida. Spec en `docs/superpowers/specs/`.

Origen: metodología CDAID v2 del repo `sdd-framework` y la estructuración del proyecto
Control_Biologicos_Vacunacion (2026-10-27), que sirve de caso de referencia.

## Requisitos

- Claude Code 2.1.311 o superior.
- Skills de terceros (se invocan por nombre, no se copian): `superpowers`, `anthropic-skills:design-patterns` y `anthropic-skills:refactoring`. El hook `check-deps` avisa si falta alguna.
- `jq` (lo usan todos los hooks).
- Opcionales para los hooks de Python: `ruff`, `pytest`, `mypy`, `uv`.

## Instalación local

Pendiente de ejecutar tras integrar la rama (ver `docs/smoke-test.md`):

```bash
claude plugin marketplace add ~/Documents/GitHub/sdd-harness
claude plugin install sdd-harness@sdd-harness --scope user
claude plugin list
```

Actualizar: `claude plugin update sdd-harness`.

## Desarrollo

- Probar el plugin localmente: `claude --plugin-dir .`
- Recargar tras cambios: `/reload-plugins`
- Ejecutar las pruebas: `bats tests/`
- Validar el manifiesto: `claude plugin validate --strict .`
- Evals: `claude plugin eval . --runs 1 --ablation none --scaffold --allow-tools Write Edit Bash`

## Flujo de siete etapas

La skill `project-workflow` clasifica el trabajo (spike, acotado o arquitectural). Spike y acotado se delegan a `superpowers:brainstorming`. El camino arquitectural recorre siete etapas, cada una con gate y registro en `agent_docs/project_status.md`:

| Etapa | Qué hace |
|---|---|
| 1 Scaffold | Repo técnico y carpeta de gestión si hay cliente (`project-scaffold`, `project-folder`) |
| 2 Diseño | Brainstorming y spec |
| 3 Investigación | Líneas paralelas en `docs/research/` (`research-lines`) |
| 4 Patrones y diagramas | Patrones GoF y diagramas (`design-diagrams`, agente `senior-architect`) |
| 5 Plan | Plan por tareas (`superpowers:writing-plans`) |
| 6 Ejecución | TDD y refactoring por catálogo de smells |
| 7 Cierre | Revisión final (`code-reviewer`, `security-scanner`, `doc-auditor`) e integración de la rama |

Al invocarse de nuevo, la skill lee la etapa en `project_status.md` y continúa desde ahí.

## Hooks

- `check-deps` (SessionStart): siempre activo; avisa qué dependencias faltan.
- `post-edit` (PostToolUse, Edit|Write): `ruff check` y `ruff format --check` sobre el `.py` editado.
- `on-stop` (Stop): `pytest -q -x` y `mypy src` (si existe `src/`), salida recortada a diez líneas.
- `post-edit` y `on-stop` solo actúan si el proyecto tiene `pyproject.toml`.
- Ninguno bloquea nunca: salen con 0 y devuelven el aviso como contexto.
- El tiempo máximo de `on-stop` se configura con `stopTimeoutSeconds` (por defecto 120 s). `timeout`/`gtimeout` (coreutils) son opcionales: sin ellos se usa `perl` (incluido en macOS); solo si falta también perl se ejecuta sin límite, con aviso. pytest y mypy reciben cada uno el presupuesto completo; el timeout de 600 s del hook en `hooks/hooks.json` es un tope externo de Claude Code.

## Criterio de paso a público

Tras tres proyectos (al menos uno sin cliente): textos neutros en plantillas, README en inglés con sección en español, marketplace publicado en GitHub y `dependencies` declaradas si hay marketplace estable de superpowers.
