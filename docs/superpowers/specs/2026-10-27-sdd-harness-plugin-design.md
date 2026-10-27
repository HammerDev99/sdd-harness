# Spec de diseño — Plugin sdd-harness v0.1

| Campo | Valor |
|---|---|
| Fecha | 2026-10-27 |
| Estado | Borrador para revisión de Daniel |
| Autor | Daniel Arbeláez Álvarez (con Claude) |
| Antecedentes | `~/Documents/GitHub/sdd-framework` (skill sdd-framework-v2, 14 agentes); proyecto de referencia `Control_Biologicos_Vacunacion`; investigación sobre el formato de plugins de Claude Code (docs oficiales, 2026-10-27) |
| Siguiente paso | `superpowers:writing-plans` → `docs/superpowers/plans/` |

## 1. Propósito

Codificar como plugin de Claude Code el flujo de trabajo que se aplicó en el proyecto
Control_Biologicos_Vacunacion: scaffold de documentación en tres niveles, brainstorming con
superpowers, investigación paralela con agentes, spec, análisis de patrones, diagramas, plan,
ejecución con TDD, revisión y cierre; más el harness que lo sostiene: agentes revisores, hooks
de calidad y plantillas.

Decisiones tomadas en el brainstorming:

| Decisión | Elección |
|---|---|
| Audiencia | Personal primero, público después. Diseño parametrizable; publicación cuando esté probado en tres proyectos. |
| Qué migra de sdd-framework | El flujo y cuatro agentes. No migran las plantillas CDAID de SPEC/sprint/auditoría ni las copias de skills de dominio. |
| Hooks | Python primero: ruff al editar, pytest y mypy por turno. Activos solo si existe `pyproject.toml`. |
| Gestión del cliente | Sí, skill opcional `project-folder` que crea la estructura de carpetas de gestión en una ruta local (Drive sincronizado u otra). |
| Enfoque | A: orquestador delgado en un solo plugin, skills autocontenidas, sin código de aplicación. |
| Skills de terceros | superpowers, anthropic-skills:design-patterns y anthropic-skills:refactoring se invocan por nombre; no se copian. |

### Criterios de éxito de la v0.1

1. En un repo vacío, `project-workflow` lleva desde "nuevo proyecto" hasta un scaffold completo sin que el usuario repita información que ya dio.
2. Cada skill dispara con frases en español naturales y produce su artefacto, verificado por evals.
3. El scaffold nunca crea `docs/plannings/`, `docs/sprints/` ni `docs/validate/`.
4. Los hooks no se ejecutan en proyectos sin `pyproject.toml` y no bloquean nunca; devuelven contexto.
5. `claude plugin validate --strict .` pasa sin advertencias.
6. El plugin se instala y actualiza en la máquina de Daniel desde un marketplace local en el mismo repo.

## 2. Usuarios y escenarios

| Usuario | Escenario |
|---|---|
| Daniel en un proyecto nuevo con cliente | Pide estructurar el proyecto; el flujo crea carpeta de gestión y repo técnico, abre brainstorming y propone líneas de investigación. |
| Daniel en un proyecto existente | Pide "configurar agent_docs"; solo corre `project-scaffold` sobre lo que falta, sin tocar lo existente. |
| Daniel tras aprobar una spec | Pide diagramas; `design-diagrams` evalúa pertinencia y genera los Mermaid validados. |
| Revisor final | `code-reviewer` recibe el paquete de revisión con el catálogo de refactoring como instrumento. |

## 3. Fuera de alcance (v0.1)

- Hooks para stacks distintos de Python.
- Plantillas CDAID de SPEC, sprint, gate y auditoría; métricas de verificación automatizadas.
- Integración con Google Drive por API.
- Copias de skills de terceros dentro del plugin.
- Marketplace público, README en inglés, textos neutros de plantillas (fase pública).

## 4. Arquitectura del plugin

### 4.1 Estructura

```
sdd-harness/
├── .claude-plugin/
│   ├── plugin.json          name, version 0.1.0, description, author, license MIT, userConfig
│   └── marketplace.json     marketplace local: name "sdd-harness", plugins [{name, source: "./"}]
├── skills/
│   ├── project-workflow/    SKILL.md + stages.md (gates y rutas por etapa)
│   ├── project-scaffold/    SKILL.md + variables.md
│   ├── research-lines/      SKILL.md + brief-template.md
│   ├── design-diagrams/     SKILL.md + catalog.md (8 tipos, criterios de pertinencia)
│   └── project-folder/      SKILL.md
├── agents/                  code-reviewer.md, senior-architect.md, security-scanner.md, doc-auditor.md
├── hooks/hooks.json
├── scripts/                 check-deps.sh, post-edit.sh, on-stop.sh (bash + jq)
├── templates/               CLAUDE.md, agent_docs/*.md (9), docs/README.md, docs/diagrams/README.md,
│                            gitignore, research-report.md, project-readme.md
├── evals/                   un caso por skill
├── tests/                   bats para scripts, fixtures mínimos
├── .github/workflows/ci.yml validate --strict + bats
├── README.md · CHANGELOG.md · docs/superpowers/{specs,plans}/
```

### 4.2 Reglas de diseño

1. **Skills autocontenidas**: `SKILL.md` menor de 500 líneas con `name`, `description` y `when_to_use`; el detalle en archivos de apoyo de la misma carpeta. Permite partir el plugin en varios en la fase pública.
2. **Superpowers no se duplica**: el flujo invoca por nombre `superpowers:brainstorming`, `superpowers:writing-plans`, `superpowers:executing-plans`, `superpowers:subagent-driven-development`, `superpowers:test-driven-development`, `superpowers:requesting-code-review`, `superpowers:finishing-a-development-branch`, `superpowers:dispatching-parallel-agents`. Igual `anthropic-skills:design-patterns` y `anthropic-skills:refactoring`.
3. **Dependencias verificadas, no declaradas**: superpowers está instalado como plugin sincronizado desde claude.ai (6.4.2), sin marketplace local. El manifiesto no declara `dependencies`; `check-deps.sh` en `SessionStart` comprueba la presencia de las tres y avisa. Si en la fase pública existe un marketplace estable, se pasa a `dependencies`.
4. **Plantillas copiadas, no cargadas**: un plugin no inyecta `CLAUDE.md`; `project-scaffold` escribe los archivos desde `templates/` sustituyendo variables.
5. **Idioma**: documentación, plantillas y mensajes en español; nombres de skills, agentes, archivos y variables en inglés.
6. **Sin código de aplicación**: Markdown, JSON y tres scripts bash. Sin dependencias Python propias; `jq` requerido para los hooks.
7. **Nunca bloquear**: hooks y verificaciones devuelven contexto; la decisión es del usuario.

## 5. Skills

### 5.1 project-workflow (entrada)

- `when_to_use`: "nuevo proyecto", "estructurar el proyecto", "cómo trabajamos", "siguiente etapa", "framework de trabajo", "iniciar proyecto con cliente".
- Clasifica con los tres caminos de superpowers (spike, acotado, arquitectural). Spike y acotado: delega íntegramente a `superpowers:brainstorming` y termina.
- Arquitectural: siete etapas, cada una con gate explícito y registro en `agent_docs/project_status.md` (sección "Etapa del flujo"), nunca solo en memoria de sesión.

| Etapa | Qué hace | Skill invocada | Gate |
|---|---|---|---|
| 1 Scaffold | Repo técnico; carpeta de gestión si hay cliente | `project-scaffold`, `project-folder` | Archivos creados y primer commit |
| 2 Diseño | Brainstorming | `superpowers:brainstorming` | Spec escrita |
| 3 Investigación | Paralela a 2 si la spec depende de hechos externos | `research-lines` | Informes en `docs/research/` y hallazgos en `project_status.md` |
| 4 Patrones y diagramas | Revisión de la spec con patrones; diagramas pertinentes | `anthropic-skills:design-patterns`, `design-diagrams`, agente `senior-architect` | Spec con sección "Patrones aplicados"; `docs/diagrams/README.md` |
| 5 Plan | Plan por tareas | `superpowers:writing-plans` | Plan revisado y método de ejecución elegido |
| 6 Ejecución | TDD; en el paso REFACTOR, catálogo de smells | `executing-plans` o `subagent-driven-development`, `test-driven-development`, `anthropic-skills:refactoring` | Tareas completas en el ledger |
| 7 Cierre | Revisión final con refactoring como instrumento; seguridad si hay PII; sincronía de docs | `requesting-code-review`, agentes `code-reviewer`, `security-scanner`, `doc-auditor`, `finishing-a-development-branch` | Rama integrada; `project_status.md` actualizado |

- Reanudación: al invocarse, lee la etapa en `project_status.md` y continúa desde ahí.

### 5.2 project-scaffold

- `when_to_use`: "configurar carpetas de agent_docs", "organizar agent_docs", "solo la estructura", "scaffold de documentación", "CLAUDE.md".
- Entrada: nombre del proyecto, descripción en una línea, si hay cliente, stack si existe, ruta de gestión si hay cliente. Pregunta solo lo que no puede inferir del directorio.
- Salida: `README.md`, `CLAUDE.md` (~100 líneas), `agent_docs/` con los nueve archivos (`workflow`, `code_conventions`, `testing`, `verification_metrics`, `architecture`, `logging`, `antipatterns`, `troubleshooting`, `project_status`), `docs/README.md`, `docs/{research, superpowers/specs, superpowers/plans, diagrams}/`, `.gitignore` con bloque de datos sensibles. `git init` y commit inicial en español si no hay repo.
- Idempotente: no sobrescribe archivos existentes; reporta qué creó y qué omitió.
- Prohibido: `docs/plannings/`, `docs/sprints/`, `docs/validate/`.
- Registra en `CLAUDE.md` la versión del plugin con la que se hizo el scaffold.

### 5.3 research-lines

- `when_to_use`: "revisión de literatura", "líneas de investigación", "investigar referentes", "qué dice la norma", "lanzar agentes de investigación".
- Paso 1: a partir del brief o la spec propone de tres a cinco líneas, cada una con pregunta, fuentes esperadas, qué decisión desbloquea y prioridad. Espera aprobación.
- Paso 2: lanza un agente por línea (`superpowers:dispatching-parallel-agents`) con el brief de `brief-template.md`: informe en `docs/research/NN_tema.md`, afirmaciones marcadas `[V]` verificado, `[I]` inferido, `[NV]` no verificado, URL y fecha de consulta, sección final "Implicaciones" y resumen de diez líneas. Extensión objetivo 900–1800 palabras.
- Paso 3: al recibir los informes, consolida en `project_status.md` los hallazgos que cambian decisiones y las preguntas abiertas.

### 5.4 design-diagrams

- `when_to_use`: "diagramas", "diagrama de clases", "modelo de dominio", "diagrama de estados", "actores y funciones", "qué diagramas conviene".
- Evalúa ocho tipos con criterio de pertinencia en `catalog.md`: ER, clases de dominio, actores y responsabilidades, estados, ciclo de vida, secuencia del caso de uso central, flujo del proceso crítico, contexto (C4 nivel 1).
- Escribe `docs/diagrams/README.md` con la tabla pertinente / descartado y por qué, genera los pertinentes en Mermaid y los valida: herramienta de Mermaid si está disponible, `mmdc` si está instalado, y si no, deja constancia de "no validado".
- Reglas de sintaxis que conoce: sin `;` en etiquetas, miembros de clase sin corchetes ni paréntesis fuera de métodos, un modal por archivo.

### 5.5 project-folder

- `when_to_use`: "carpeta del cliente", "estructura de gestión del proyecto", "carpeta en Drive", "propuesta y facturación".
- Crea en la ruta indicada `00_Assets`, `01_Propuesta`, `02_Planificacion`, `03_Ejecucion`, `04_Control`, `05_Cierre`, `06_Facturacion` y `README.md` desde `project-readme.md` (estado, cliente, descripción, insumos, decisiones, pendientes, riesgos, KPIs, enlace al repo).
- Regla explícita en ambos README: la carpeta de gestión no recibe código ni documentación técnica; el repo no recibe datos del cliente.

## 6. Agentes

| Agente | Modelo | `tools` | Uso |
|---|---|---|---|
| code-reviewer | el más capaz disponible | Read, Grep, Glob, Bash de solo lectura | Etapa 7; recibe paquete de revisión, Review Focus del plan, rulings del ledger y la instrucción de clasificar smells con `anthropic-skills:refactoring`. |
| senior-architect | el más capaz disponible | Read, Grep, Glob | Etapa 4; revisa la spec contra SOLID y patrones, y los diagramas contra la spec. |
| security-scanner | sonnet | Read, Grep, Glob, Bash limitado a `grep`/`rg` | Etapa 7, obligatorio si el proyecto declara datos personales en `CLAUDE.md`. |
| doc-auditor | haiku | Read, Grep, Glob | Etapa 7; sincronía entre `CLAUDE.md`, `agent_docs/` y código. |

Migración desde sdd-framework: se conserva el cuerpo del prompt; `permissionMode` y `hooks` se eliminan porque el formato de plugin los ignora; el control se hace con `tools`/`disallowedTools`.

## 7. Hooks

`hooks/hooks.json`, scripts en `scripts/` con `${CLAUDE_PLUGIN_ROOT}`; todos leen el JSON de stdin con `jq`; todos salen con 0 (nunca bloquean) y escriben el aviso en stdout como contexto.

| Evento | Matcher | Script | Comportamiento |
|---|---|---|---|
| SessionStart | — | `check-deps.sh` | Verifica que existan superpowers, anthropic-skills:design-patterns y anthropic-skills:refactoring (busca sus directorios bajo `~/.claude/plugins/`); avisa cuáles faltan. |
| PostToolUse | `Edit\|Write` | `post-edit.sh` | Si el archivo termina en `.py` y existe `pyproject.toml` en el proyecto: `ruff check` y `ruff format --check` sobre ese archivo; imprime los hallazgos. |
| Stop | — | `on-stop.sh` | Si existe `pyproject.toml`: `pytest -q -x` y `mypy src` (si existe `src/`), salida recortada a diez líneas; tiempo máximo configurable (`userConfig.stopTimeoutSeconds`, por defecto 120). |

Herramientas usadas si están disponibles: `uv run` cuando hay `uv.lock`, si no `python -m`.

## 8. Plantillas y variables

Variables: `{{project}}`, `{{description}}`, `{{client}}`, `{{stack}}`, `{{management_path}}`, `{{repo_url}}`, `{{date}}`, `{{plugin_version}}`. Sustitución simple por texto; sin motor de plantillas.

| Plantilla | Destino |
|---|---|
| `CLAUDE.md` | raíz del proyecto |
| `agent_docs/*.md` (9) | `agent_docs/` |
| `docs-readme.md` | `docs/README.md` |
| `diagrams-readme.md` | `docs/diagrams/README.md` |
| `gitignore` | `.gitignore` (se anexa si ya existe) |
| `research-report.md` | esqueleto que el agente de investigación debe seguir |
| `project-readme.md` | `README.md` de la carpeta de gestión |

## 9. Pruebas

- `claude plugin validate --strict .` en CI (GitHub Actions) en cada push.
- `evals/`: un caso por skill con graders `tool_used` (dispara con la frase en español) y `file_exists` (artefacto producido). Casos mínimos: scaffold crea `CLAUDE.md` y `agent_docs/workflow.md` y no crea `docs/plannings/`; research-lines escribe `docs/research/01_*.md`; design-diagrams escribe `docs/diagrams/README.md`; project-folder crea `06_Facturacion/`; workflow invoca `superpowers:brainstorming` tras el scaffold.
- `tests/` con `bats`: `post-edit.sh` reporta error en un `.py` roto y guarda silencio sin `pyproject.toml`; `on-stop.sh` respeta el tiempo máximo; `check-deps.sh` avisa cuando falta una dependencia.
- Humo manual documentado en README: `claude --plugin-dir` sobre un repo vacío hasta completar el scaffold.

## 10. Distribución

- Desarrollo: `claude --plugin-dir ~/Documents/GitHub/sdd-harness` y `/reload-plugins`.
- Instalación estable local: `claude plugin marketplace add ~/Documents/GitHub/sdd-harness` y `claude plugin install sdd-harness@sdd-harness --scope user`; actualizaciones con `claude plugin update`.
- Versionado semántico desde 0.1.0; `CHANGELOG.md`; cada release sube `version` en el manifiesto.
- Paso a público: tras tres proyectos (al menos uno sin cliente), textos neutros en plantillas, README en inglés con sección en español, marketplace publicado en GitHub, `dependencies` declaradas si hay marketplace estable de superpowers.

## 11. Riesgos

| Riesgo | Mitigación |
|---|---|
| Cambios en el formato de plugins entre versiones de Claude Code | `validate --strict` en CI; versión mínima de Claude Code en README. |
| Hooks lentos en proyectos grandes | `pytest -x`, matcher estrecho, tiempo máximo configurable. |
| Skills que no disparan por descripción débil | Evals de disparo desde la v0.1; iterar `when_to_use`. |
| Dependencias ausentes en otra máquina | `check-deps.sh` avisa al inicio; README lista las tres. |
| Deriva entre plantillas y proyectos ya creados | Versión del plugin registrada en cada `CLAUDE.md`. |

## 12. Preguntas abiertas (no bloquean)

- Nombre definitivo del marketplace local (propuesto: igual al plugin).
- Si `project-folder` debe crear también la carpeta `Reunion_*` por reunión o dejarlo al uso.
