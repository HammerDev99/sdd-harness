# Plugin sdd-harness v0.1 — Plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Plugin de Claude Code instalable localmente que orquesta el flujo SDD (scaffold, brainstorming, investigación, patrones y diagramas, plan, ejecución, cierre) sobre superpowers, con cuatro agentes, tres hooks Python y plantillas en español.

**Architecture:** Solo Markdown, JSON y bash. Cinco skills autocontenidas en `skills/<nombre>/SKILL.md` con archivos de apoyo; plantillas en `templates/` renderizadas por `scripts/render-template.sh`; hooks en `hooks/hooks.json` que llaman scripts que leen JSON de stdin con `jq` y nunca bloquean; agentes migrados de sdd-framework al formato de plugin. Validación con `claude plugin validate --strict`, `bats` para scripts y `claude plugin eval` para disparo de skills.

**Tech Stack:** Claude Code ≥ 2.1.311 (plugins, `claude plugin eval`), bash 3.2+ (macOS), `jq`, `bats-core`, GitHub Actions.

**Spec:** `docs/superpowers/specs/2026-10-27-sdd-harness-plugin-design.md` (citada como §N). Investigación de formato: informe del agente claude-code-guide del 2026-10-27, resumido en §4.2 de la spec.

## Global Constraints

- `SKILL.md` menor de 500 líneas, con frontmatter `name`, `description`, `when_to_use` (§4.2.1).
- Documentación, plantillas y mensajes en español; nombres de skills, agentes, archivos y variables en inglés (§4.2.5).
- Sin código de aplicación ni dependencias Python; bash + `jq` únicamente (§4.2.6).
- Hooks y scripts salen siempre con código 0 y escriben avisos en stdout (§4.2.7, §7).
- Hooks activos solo si existe `pyproject.toml` en el proyecto (§7).
- El scaffold nunca crea `docs/plannings/`, `docs/sprints/` ni `docs/validate/` (§5.2).
- Variables de plantilla: `{{project}}`, `{{description}}`, `{{client}}`, `{{stack}}`, `{{management_path}}`, `{{repo_url}}`, `{{date}}`, `{{plugin_version}}` (§8).
- Skills de terceros invocadas por nombre: `superpowers:*`, `anthropic-skills:design-patterns`, `anthropic-skills:refactoring`; nunca copiadas (§4.2.2). El manifiesto no declara `dependencies` (§4.2.3).
- Versión inicial `0.1.0`; `claude plugin validate --strict .` sin advertencias (§10, §9).
- Commits en español, formato convencional, sin firma de IA.

## Review Focus

1. `project-scaffold` sobre un proyecto que ya tiene `CLAUDE.md`: no debe sobrescribirlo, debe reportarlo como omitido (Task 3, eval `scaffold-existing`).
2. `post-edit.sh` con ruta de archivo con espacios o acentos: debe pasar la ruta entera a ruff, sin romperla (Task 9 `post-edit respeta rutas con espacios`).
3. `on-stop.sh` en proyecto con `pyproject.toml` pero sin pytest instalado: debe salir 0 con aviso, no con traza (Task 9 `on-stop sin pytest avisa y sale 0`).
4. `check-deps.sh` cuando `~/.claude/plugins` no existe o está vacío: aviso de las tres dependencias y salida 0 (Task 9 `check-deps sin plugins avisa las tres`).
5. `render-template.sh` con una variable sin valor: debe fallar con código 1 listando las variables faltantes, nunca emitir `{{var}}` en el archivo destino (Task 2 `render falla si falta variable`).

---

## Estructura de archivos

```
.claude-plugin/plugin.json · .claude-plugin/marketplace.json
skills/project-workflow/{SKILL.md,stages.md}
skills/project-scaffold/{SKILL.md,variables.md}
skills/research-lines/{SKILL.md,brief-template.md}
skills/design-diagrams/{SKILL.md,catalog.md}
skills/project-folder/SKILL.md
agents/{code-reviewer,senior-architect,security-scanner,doc-auditor}.md
hooks/hooks.json
scripts/{render-template.sh,check-deps.sh,post-edit.sh,on-stop.sh}
templates/{CLAUDE.md,docs-readme.md,diagrams-readme.md,gitignore,research-report.md,project-readme.md}
templates/agent_docs/{workflow,code_conventions,testing,verification_metrics,architecture,logging,antipatterns,troubleshooting,project_status}.md
evals/{scaffold-new,scaffold-existing,research-lines,design-diagrams,project-folder,workflow-routes}/{prompt.md,graders/*.md}
tests/{test_manifest,test_templates,test_skills,test_agents,test_hooks}.bats · tests/fixtures/
.github/workflows/ci.yml · README.md · CHANGELOG.md
```

Responsabilidades: cada skill solo describe comportamiento y referencia sus archivos de apoyo y los scripts; los scripts son la única lógica ejecutable; `tests/` prueba scripts y estructura, `evals/` prueba disparo y artefactos.

---

### Task 1: Manifiesto, marketplace local, CI y bats

**Files:**
- Create: `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `CHANGELOG.md`, `.github/workflows/ci.yml`, `tests/test_manifest.bats`
- Modify: `README.md` (sección "Desarrollo")

**Interfaces:**
- Produces: `plugin.json` con `name: "sdd-harness"`, `version: "0.1.0"`, `description` en español, `author: {name: "Daniel Arbeláez Álvarez"}`, `license: "MIT"`, `userConfig: {stopTimeoutSeconds: {type: "number", default: 120, description: "..."}}`; `marketplace.json` con `name: "sdd-harness"`, `owner`, `plugins: [{name: "sdd-harness", source: "./", description}]`.

- [ ] **Step 1: Instalar bats** — Run: `brew install bats-core` → `bats --version` imprime `Bats 1.x`.
- [ ] **Step 2: Escribir el test**

```bash
# tests/test_manifest.bats
@test "validate --strict pasa sin advertencias" {
  run claude plugin validate --strict .
  [ "$status" -eq 0 ]
}
@test "manifest declara nombre y versión 0.1.0" {
  [ "$(jq -r .name .claude-plugin/plugin.json)" = "sdd-harness" ]
  [ "$(jq -r .version .claude-plugin/plugin.json)" = "0.1.0" ]
  [ "$(jq -r '.dependencies // "none"' .claude-plugin/plugin.json)" = "none" ]
}
```

- [ ] **Step 3: Ejecutar → FAIL** — Run: `bats tests/test_manifest.bats` → falla porque no existe `plugin.json`.
- [ ] **Step 4: Crear `plugin.json`, `marketplace.json`, `CHANGELOG.md` (entrada `0.1.0 — sin publicar`), `ci.yml`** (en push y PR: instala `bats-core` y `jq` con apt, instala Claude Code CLI con `npm i -g @anthropic-ai/claude-code`, corre `claude plugin validate --strict .` y `bats tests/`). README: sección "Desarrollo" con `claude --plugin-dir .`, `/reload-plugins`, `bats tests/`.
- [ ] **Step 5: Ejecutar → PASS** — `bats tests/test_manifest.bats` → 2 tests OK.
- [ ] **Step 6: Commit** — `git commit -m "chore: manifiesto del plugin, marketplace local, CI y bats"`

---

### Task 2: Plantillas y script de renderizado

**Files:**
- Create: `scripts/render-template.sh`, `templates/CLAUDE.md`, `templates/docs-readme.md`, `templates/diagrams-readme.md`, `templates/gitignore`, `templates/research-report.md`, `templates/project-readme.md`, `templates/agent_docs/*.md` (9), `tests/test_templates.bats`

**Interfaces:**
- Produces: `scripts/render-template.sh TEMPLATE DEST KEY=VALUE...` — sustituye cada `{{KEY}}` por `VALUE`; si quedan `{{...}}` sin resolver, no escribe `DEST`, imprime `Faltan variables: a, b` y sale con 1; si `DEST` existe, sale 0 sin tocarlo e imprime `Omitido (existe): DEST`; opción `--append` para `gitignore`. Variables fijas de §8.
- Produces: plantillas con el contenido generalizado del proyecto de referencia (CLAUDE.md ~100 líneas con reglas críticas, tabla de divulgación a los nueve archivos, estado, instrucciones de compactación y línea `Scaffold: sdd-harness {{plugin_version}} ({{date}})`; nueve agent_docs con estructura de secciones y estado "pendiente" donde aplique; `research-report.md` con marcas `[V]/[I]/[NV]`, "Fuentes (URL, fecha de consulta)", "Implicaciones" y "Resumen en diez líneas"; `project-readme.md` con las secciones del README de gestión: estado, cliente, descripción, insumos, decisiones, pendientes, riesgos, KPIs, enlace al repo, y la regla "la carpeta de gestión no recibe código ni documentación técnica").

- [ ] **Step 1: Tests**

```bash
@test "render sustituye variables" {
  run scripts/render-template.sh templates/docs-readme.md "$BATS_TMPDIR/out.md" project=Demo date=2026-10-27 plugin_version=0.1.0
  [ "$status" -eq 0 ]; ! grep -q '{{' "$BATS_TMPDIR/out.md"
}
@test "render falla si falta variable" {
  run scripts/render-template.sh templates/CLAUDE.md "$BATS_TMPDIR/c.md" project=Demo
  [ "$status" -eq 1 ]; [[ "$output" == *"Faltan variables"* ]]; [ ! -f "$BATS_TMPDIR/c.md" ]
}
@test "render no sobrescribe destino existente" { ... crea archivo, run, [ "$status" -eq 0 ], contenido intacto, output contiene "Omitido" }
@test "ninguna plantilla menciona carpetas PDCA" {
  ! grep -rE 'plannings/|sprints/|validate/' templates/
}
@test "existen las nueve plantillas de agent_docs" { [ "$(ls templates/agent_docs/*.md | wc -l)" -eq 9 ]; }
```

- [ ] **Step 2 → FAIL. Step 3: Implementar script (bash, `sed` con delimitador seguro, variables leídas de argumentos `k=v`) y plantillas. Step 4 → PASS** (`bats tests/test_templates.bats`).
- [ ] **Step 5: Commit** — `git commit -m "feat: plantillas de scaffold y script de renderizado"`

---

### Task 3: Skill project-scaffold

**Files:**
- Create: `skills/project-scaffold/SKILL.md`, `skills/project-scaffold/variables.md`, `evals/scaffold-new/{prompt.md,graders/*.md}`, `evals/scaffold-existing/{prompt.md,graders/*.md}`, `tests/test_skills.bats`

**Interfaces:**
- Consumes: `scripts/render-template.sh` (Task 2).
- Produces: skill que, dadas las variables (preguntadas solo si no se infieren), ejecuta `render-template.sh` por cada plantilla hacia su destino de §8, crea `docs/{research,superpowers/specs,superpowers/plans,diagrams}/` con `.gitkeep`, `git init` + commit `docs: scaffold inicial (sdd-harness {{plugin_version}})` si no hay repo, y termina con un reporte "Creados / Omitidos". `when_to_use` con las frases de §5.2. `variables.md` documenta cada variable, cómo se infiere (nombre = carpeta; fecha = hoy; `plugin_version` = `jq .version ${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`) y cuándo se pregunta.
- Produces (`tests/test_skills.bats`, genérico para todas las skills): cada `skills/*/SKILL.md` tiene menos de 500 líneas y frontmatter con `name`, `description`, `when_to_use`; `name` coincide con el directorio.

- [ ] **Step 1: Tests bats** (los dos genéricos anteriores) y **evals**: `scaffold-new/prompt.md` = "Estructura este proyecto nuevo llamado Demo para un cliente ganadero, stack Python"; graders `file_exists` para `CLAUDE.md`, `agent_docs/workflow.md`, `docs/superpowers/specs/.gitkeep`; grader `regex` negativo que falla si existe texto `docs/plannings` en el árbol (`tool_used` con `Bash` y `input_match` `ls`? → usar `file_exists` con `negate: true` sobre `docs/plannings` si el grader lo soporta; si no, grader `llm` con la pregunta "¿se creó docs/plannings/?" esperando no). `scaffold-existing/prompt.md` igual pero el caso parte de un fixture con `CLAUDE.md` existente y grader `regex` sobre la respuesta: `Omitido.*CLAUDE.md`.
- [ ] **Step 2 → FAIL** (`bats tests/test_skills.bats` falla porque no hay skills).
- [ ] **Step 3: Escribir SKILL.md y variables.md.** **Step 4 → PASS** bats; eval: `claude plugin eval . --case scaffold-new --runs 1 --ablation none` → caso aprobado.
- [ ] **Step 5: Commit** — `git commit -m "feat(skills): project-scaffold con evals"`

---

### Task 4: Skill project-folder

**Files:**
- Create: `skills/project-folder/SKILL.md`, `evals/project-folder/{prompt.md,graders/*.md}`

**Interfaces:**
- Consumes: `templates/project-readme.md`, `render-template.sh`.
- Produces: skill que pide `management_path` (si no viene) y variables de cliente, crea `00_Assets 01_Propuesta 02_Planificacion 03_Ejecucion 04_Control 05_Cierre 06_Facturacion` y `README.md` renderizado; si el repo técnico existe, añade a su `README.md` la sección "Fuente de verdad documental" con la ruta de gestión y la regla de separación. Nunca escribe código ni docs técnicas en la ruta de gestión.

- [ ] **Step 1: Eval** `project-folder/prompt.md` = "Crea la carpeta de gestión del cliente en ./gestion para el proyecto Demo"; graders `file_exists` `gestion/06_Facturacion`, `gestion/README.md`; `regex` sobre `gestion/README.md`: `no recibe código`.
- [ ] **Step 2: Escribir SKILL.md.** **Step 3:** `bats tests/test_skills.bats` → PASS; eval `--case project-folder --runs 1 --ablation none` → aprobado.
- [ ] **Step 4: Commit** — `git commit -m "feat(skills): project-folder"`

---

### Task 5: Skill research-lines

**Files:**
- Create: `skills/research-lines/SKILL.md`, `skills/research-lines/brief-template.md`, `evals/research-lines/{prompt.md,graders/*.md}`

**Interfaces:**
- Consumes: `templates/research-report.md`.
- Produces: skill en tres pasos (§5.3): propone 3–5 líneas en una tabla (pregunta, fuentes esperadas, decisión que desbloquea, prioridad) y espera aprobación; lanza un agente por línea con `superpowers:dispatching-parallel-agents` usando `brief-template.md` (ruta `docs/research/NN_tema.md`, marcas `[V]/[I]/[NV]`, URL + fecha, "Implicaciones", resumen de diez líneas, 900–1800 palabras); consolida hallazgos en `agent_docs/project_status.md` sección "Hechos confirmados por la investigación". `brief-template.md` contiene el texto completo del brief con placeholders `{{line_question}}`, `{{context}}`, `{{report_path}}`.

- [ ] **Step 1: Eval** `research-lines/prompt.md` = "Propón las líneas de investigación para este proyecto" sobre un fixture con `CLAUDE.md` de un proyecto ficticio; graders: `regex` en la respuesta `\|.*Prioridad` (tabla con columna Prioridad) y `llm`: "¿propuso entre 3 y 5 líneas y pidió aprobación antes de lanzar agentes?".
- [ ] **Step 2: Escribir SKILL.md y brief-template.md.** **Step 3:** bats PASS; eval aprobado.
- [ ] **Step 4: Commit** — `git commit -m "feat(skills): research-lines con brief estándar"`

---

### Task 6: Skill design-diagrams

**Files:**
- Create: `skills/design-diagrams/SKILL.md`, `skills/design-diagrams/catalog.md`, `evals/design-diagrams/{prompt.md,graders/*.md}`

**Interfaces:**
- Consumes: `templates/diagrams-readme.md`.
- Produces: `catalog.md` con los ocho tipos (ER, clases de dominio, actores y responsabilidades, estados, ciclo de vida, secuencia del caso de uso central, flujo del proceso crítico, contexto C4-1), para cada uno: cuándo es pertinente, cuándo se descarta, esqueleto Mermaid y reglas de sintaxis (sin `;` en etiquetas, miembros de clase sin corchetes ni paréntesis salvo métodos, un modal por archivo). Skill: lee la spec, evalúa los ocho, escribe `docs/diagrams/README.md` con tabla pertinente/descartado y motivo, genera los pertinentes como `docs/diagrams/<nombre>.mmd`, valida con la herramienta Mermaid disponible o `mmdc`; si no hay ninguna, anota "no validado" en el README.

- [ ] **Step 1: Eval** `design-diagrams/prompt.md` = "Evalúa qué diagramas conviene y genera los pertinentes" sobre fixture con una spec corta; graders `file_exists` `docs/diagrams/README.md`, `regex` en ese README: `Descartado` y `Pertinente`.
- [ ] **Step 2: Escribir SKILL.md y catalog.md.** **Step 3:** bats PASS; eval aprobado.
- [ ] **Step 4: Commit** — `git commit -m "feat(skills): design-diagrams con catálogo de pertinencia"`

---

### Task 7: Skill project-workflow

**Files:**
- Create: `skills/project-workflow/SKILL.md`, `skills/project-workflow/stages.md`, `evals/workflow-routes/{prompt.md,graders/*.md}`

**Interfaces:**
- Consumes: las cuatro skills anteriores por nombre `sdd-harness:project-scaffold`, etc.
- Produces: `stages.md` con la tabla de siete etapas de §5.1 (qué hace, skill invocada, gate, qué escribe en `project_status.md` sección "Etapa del flujo: N — nombre — fecha"). SKILL.md: clasificación con los tres caminos; spike y acotado → `superpowers:brainstorming` y fin; arquitectural → recorre etapas leyendo la etapa actual de `project_status.md` para reanudar; nunca salta un gate; en la etapa 4 invoca `anthropic-skills:design-patterns` antes de `design-diagrams` y exige la sección "Patrones aplicados" en la spec; en la etapa 6 recuerda `anthropic-skills:refactoring` en el paso REFACTOR; en la 7 dispara `code-reviewer` con el catálogo de refactoring y `security-scanner` si `CLAUDE.md` declara datos personales.

- [ ] **Step 1: Eval** `workflow-routes/prompt.md` = "Quiero iniciar un proyecto nuevo para un cliente; define el framework de trabajo"; graders `tool_used` Skill con `input_match` `project-scaffold` y `tool_used` Skill con `input_match` `superpowers:brainstorming`; `tool_order`: scaffold antes de brainstorming.
- [ ] **Step 2: Escribir SKILL.md y stages.md.** **Step 3:** bats PASS (cinco skills); eval aprobado.
- [ ] **Step 4: Commit** — `git commit -m "feat(skills): project-workflow, orquestación por etapas"`

---

### Task 8: Agentes migrados

**Files:**
- Create: `agents/code-reviewer.md`, `agents/senior-architect.md`, `agents/security-scanner.md`, `agents/doc-auditor.md`, `tests/test_agents.bats`
- Source: `~/Documents/GitHub/sdd-framework/.claude/agents/<mismo nombre>.md`

**Interfaces:**
- Produces: frontmatter `name`, `description` (español), `tools`, `model`; sin `permissionMode` ni `hooks`. Tabla de §6: code-reviewer `tools: Read, Grep, Glob, Bash` con instrucción explícita de solo comandos de lectura (`git diff`, `git log`, `pytest --collect-only`), `model: opus`; senior-architect `tools: Read, Grep, Glob`, `model: opus` (pierde Write/Edit/Bash respecto al origen: en el flujo solo revisa); security-scanner `tools: Read, Grep, Glob, Bash`, `model: sonnet`, Bash limitado a `grep`/`rg` por instrucción; doc-auditor `tools: Read, Grep, Glob`, `model: haiku`. Cuerpos en español, generalizados (sin "this Python project" fijo: "el proyecto, en el stack declarado en CLAUDE.md"). code-reviewer añade sección "Instrumentos": `anthropic-skills:refactoring` para clasificar smells, Review Focus del plan y rulings del ledger.

- [ ] **Step 1: Test**

```bash
@test "cuatro agentes con frontmatter válido" {
  [ "$(ls agents/*.md | wc -l)" -eq 4 ]
  for f in agents/*.md; do
    grep -q '^name:' "$f"; grep -q '^description:' "$f"; grep -q '^tools:' "$f"; grep -q '^model:' "$f"
    ! grep -qE '^(permissionMode|hooks):' "$f"
  done
}
@test "senior-architect no tiene herramientas de escritura" { ! grep -E '^tools:.*(Write|Edit|Bash)' agents/senior-architect.md; }
```

- [ ] **Step 2 → FAIL. Step 3: Migrar y adaptar los cuatro archivos. Step 4 → PASS**; `claude plugin validate --strict .` sigue limpio.
- [ ] **Step 5: Commit** — `git commit -m "feat(agents): code-reviewer, senior-architect, security-scanner y doc-auditor migrados"`

---

### Task 9: Hooks y scripts

**Files:**
- Create: `hooks/hooks.json`, `scripts/check-deps.sh`, `scripts/post-edit.sh`, `scripts/on-stop.sh`, `tests/test_hooks.bats`, `tests/fixtures/py_ok/` (pyproject + módulo limpio + test que pasa), `tests/fixtures/py_bad/` (módulo con `import os` sin usar y espacio en el nombre `mi modulo.py`), `tests/fixtures/no_py/` (sin pyproject)

**Interfaces:**
- Produces: `hooks.json` con `SessionStart` → `check-deps.sh`; `PostToolUse` matcher `Edit|Write` → `post-edit.sh`; `Stop` → `on-stop.sh`; comandos `"${CLAUDE_PLUGIN_ROOT}/scripts/<x>.sh"`. Todos leen stdin JSON; `PROJECT="${CLAUDE_PROJECT_DIR:-$(jq -r '.cwd // empty')}"`; todos `exit 0`.
  - `check-deps.sh`: busca bajo `${CLAUDE_PLUGINS_DIR:-$HOME/.claude/plugins}` directorios `skills/brainstorming` (superpowers), `skills/design-patterns` y `skills/refactoring` (anthropic-skills); imprime `sdd-harness: faltan dependencias: <lista>` o nada.
  - `post-edit.sh`: `FILE=$(jq -r '.tool_input.file_path // empty')`; si no termina en `.py` o no hay `$PROJECT/pyproject.toml` → silencio; si no, `ruff check "$FILE"` y `ruff format --check "$FILE"` (vía `uv run` si hay `uv.lock`), salida prefijada `sdd-harness/ruff:`; si ruff no está instalado, aviso `ruff no disponible`.
  - `on-stop.sh`: si no hay `pyproject.toml` → silencio; si no, `timeout "${SDD_STOP_TIMEOUT:-120}" pytest -q -x` (`uv run` si hay lock) y `mypy src` si existe `src/`; salida recortada a las últimas diez líneas con prefijo `sdd-harness/tests:`; sin pytest → aviso y salida 0. (`timeout` en macOS: usar `gtimeout` si existe, si no ejecutar sin límite y avisarlo.)

- [ ] **Step 1: Tests**

```bash
@test "post-edit guarda silencio sin pyproject" { run bash -c 'echo "{\"tool_input\":{\"file_path\":\"x.py\"}}" | CLAUDE_PROJECT_DIR=tests/fixtures/no_py scripts/post-edit.sh'; [ "$status" -eq 0 ]; [ -z "$output" ]; }
@test "post-edit reporta ruff en archivo roto" { ... fixtures/py_bad, archivo "mi modulo.py" ...; [ "$status" -eq 0 ]; [[ "$output" == *"F401"* ]]; }
@test "post-edit respeta rutas con espacios" { ... misma entrada; [[ "$output" != *"No such file"* ]]; }
@test "on-stop pasa en fixture limpio" { ... py_ok; [ "$status" -eq 0 ]; [[ "$output" == *"passed"* ]]; }
@test "on-stop sin pytest avisa y sale 0" { ... PATH sin pytest; [ "$status" -eq 0 ]; [[ "$output" == *"pytest no disponible"* ]]; }
@test "check-deps sin plugins avisa las tres" { run bash -c 'echo "{}" | CLAUDE_PLUGINS_DIR=$BATS_TMPDIR/vacio scripts/check-deps.sh'; [ "$status" -eq 0 ]; [[ "$output" == *"superpowers"* && "$output" == *"design-patterns"* && "$output" == *"refactoring"* ]]; }
@test "hooks.json es válido y referencia los tres scripts" { jq -e '.hooks.SessionStart and .hooks.PostToolUse and .hooks.Stop' hooks/hooks.json; }
```

- [ ] **Step 2 → FAIL. Step 3: Implementar scripts (`chmod +x`) y hooks.json. Step 4 → PASS**; `claude plugin validate --strict .` limpio.
- [ ] **Step 5: Commit** — `git commit -m "feat(hooks): verificación de dependencias, ruff al editar y pytest/mypy al cerrar turno"`

---

### Task 10: Instalación local, humo y documentación

**Files:**
- Modify: `README.md`, `CHANGELOG.md`
- Create: `docs/smoke-test.md`

- [ ] **Step 1: Validación completa** — Run: `claude plugin validate --strict . && bats tests/` → todo OK. Run: `claude plugin eval . --runs 1 --ablation none` → los seis casos aprobados (anotar en `docs/smoke-test.md` los que requieran ajuste de `when_to_use`).
- [ ] **Step 2: Instalación estable** — Run: `claude plugin marketplace add ~/Documents/GitHub/sdd-harness && claude plugin install sdd-harness@sdd-harness --scope user && claude plugin list` → `sdd-harness` listado como enabled.
- [ ] **Step 3: Humo manual** — en un directorio vacío `mkdir /tmp/demo-sdd && cd /tmp/demo-sdd && claude`, pedir "estructura este proyecto nuevo"; verificar `CLAUDE.md`, nueve `agent_docs`, ausencia de `docs/plannings`, commit inicial. Registrar el resultado en `docs/smoke-test.md` con fecha.
- [ ] **Step 4: Documentación** — README: instalación, desarrollo, flujo de siete etapas, dependencias (superpowers, anthropic-skills), versión mínima de Claude Code 2.1.311, criterio de paso a público (§10). `CHANGELOG.md`: `0.1.0 — 2026-10-xx` con el contenido.
- [ ] **Step 5: Commit** — `git commit -m "docs: instalación local, prueba de humo y changelog 0.1.0"`

---

## Orden y dependencias

1 → 2 → 3 → {4, 5, 6} → 7 → {8, 9} → 10. Las tareas 4, 5 y 6 son independientes entre sí; 8 y 9 también. Un error en la Task 2 (render) afecta a 3 y 4; un error en 9 (hooks) no afecta a ninguna skill.
