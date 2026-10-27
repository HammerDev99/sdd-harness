---
name: project-scaffold
description: Crea la estructura documental SDD de un proyecto (README.md, CLAUDE.md, agent_docs/, docs/, .gitignore) a partir de las plantillas del plugin, sin sobrescribir nada existente.
when_to_use: Cuando el usuario pida "configurar carpetas de agent_docs", "organizar agent_docs", "solo la estructura", "scaffold de documentación" o "CLAUDE.md", o quiera estructurar un proyecto nuevo o existente.
---

# project-scaffold

Genera la estructura documental de un proyecto con `render-template.sh`. Es idempotente: nunca sobrescribe archivos existentes.

## Reglas

- Nunca crees `docs/plannings/`, `docs/sprints/` ni `docs/validate/`.
- No renderices `diagrams-readme.md` (lo gestiona la skill design-diagrams), `research-report.md` ni `project-readme.md`.
- No pidas lo que puedas inferir. Las variables y su inferencia están en `${CLAUDE_PLUGIN_ROOT}/skills/project-scaffold/variables.md`; léelo antes de preguntar.

## Pasos

1. Resuelve las ocho variables (`project`, `description`, `client`, `stack`, `management_path`, `repo_url`, `date`, `plugin_version`) según `variables.md`. Haz una sola pregunta agrupada solo por las que falten. Si el usuario ya dio el dato en su mensaje, no lo repitas.
2. Todas las variables deben llevar valor: para lo que no aplique pasa texto explícito ("sin cliente", "no aplica", "por definir"). Nunca dejes una variable sin pasar.
3. Renderiza cada plantilla con un comando por plantilla, desde la raíz del proyecto, y conserva la salida (`Creado:` / `Omitido (existe):`). Entrecomilla siempre cada valor (`clave="valor"`), porque descripción, cliente y stack llevan espacios. La versión del plugin se obtiene con `jq -r .version "${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json"`; úsala en `plugin_version`. Formato: `"${CLAUDE_PLUGIN_ROOT}/scripts/render-template.sh" "${CLAUDE_PLUGIN_ROOT}/templates/<plantilla>" <destino> clave="valor" ...`. Plantillas:
   - `"${CLAUDE_PLUGIN_ROOT}/scripts/render-template.sh" "${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md" CLAUDE.md` con las ocho variables.
   - `"${CLAUDE_PLUGIN_ROOT}/scripts/render-template.sh" "${CLAUDE_PLUGIN_ROOT}/templates/repo-readme.md" README.md` con `project`, `description`, `stack`, `date`, `plugin_version`.
   - `"${CLAUDE_PLUGIN_ROOT}/scripts/render-template.sh" "${CLAUDE_PLUGIN_ROOT}/templates/docs-readme.md" docs/README.md` con `project`, `date`, `plugin_version`.
   - `"${CLAUDE_PLUGIN_ROOT}/scripts/render-template.sh" "${CLAUDE_PLUGIN_ROOT}/templates/gitignore" .gitignore --append` (sin variables).
   - Cada `"${CLAUDE_PLUGIN_ROOT}/templates/agent_docs/<nombre>.md"` a `agent_docs/<nombre>.md`, para los nueve: `workflow`, `code_conventions`, `testing`, `verification_metrics`, `architecture`, `logging`, `antipatterns`, `troubleshooting`, `project_status`. Variables: `stack` en `code_conventions`, `testing`, `verification_metrics` y `logging`; `date` en `troubleshooting`; `project` y `date` en `project_status`; ninguna en el resto. Pasar variables de más es inofensivo.
   Ejemplo completo: `"${CLAUDE_PLUGIN_ROOT}/scripts/render-template.sh" "${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md" CLAUDE.md project="Demo" description="Sistema de ejemplo" client="cliente ganadero" stack="Python" management_path="../gestion-demo" repo_url="por definir" date="2026-10-27" plugin_version="0.1.0"`
4. Si el script responde `Faltan variables: ...` (código 1), no escribió nada: resuelve esas variables y repite solo esa plantilla.
5. Crea `docs/research`, `docs/superpowers/specs`, `docs/superpowers/plans` y `docs/diagrams` con `mkdir -p`. En cada una crea un `.gitkeep` vacío solo si el directorio está vacío (sin archivos); si ya tiene contenido u otro `.gitkeep`, regístralo como omitido.
6. Si el directorio no es un repositorio git (`git rev-parse --git-dir` falla): `git init`, `git add -A` y `git commit -m "docs: scaffold inicial (sdd-harness <plugin_version>)"`. Si ya es repositorio, no hagas commit; sugiérelo.

## Reporte final

Termina con un reporte en español con dos listas de rutas:

- **Creados**: cada archivo o directorio nuevo.
- **Omitidos**: cada `Omitido (existe): ruta` y `Omitido (bloque presente): .gitignore` tal cual los imprimió el script.

Añade una línea sobre el commit (hecho, o sugerido si ya había repositorio) y recuerda que `CLAUDE.md` registra la versión del plugin usada.
