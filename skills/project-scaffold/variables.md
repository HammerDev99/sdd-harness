# Variables de project-scaffold

Cada variable se pasa a `render-template.sh` como `clave=valor`. Todas deben tener valor; si no aplica, usa el texto indicado.

| Variable | Qué es | Cómo se infiere | Cuándo se pregunta |
|---|---|---|---|
| `project` | Nombre del proyecto | Nombre de la carpeta actual (`basename "$PWD"`), o el nombre dado en el mensaje del usuario | Solo si la carpeta es genérica (`tmp`, `test`, `src`) y el usuario no dio nombre |
| `description` | Descripción en una línea | Frase del mensaje del usuario; si hay README o `pyproject.toml` con descripción, úsala | Si no hay ninguna fuente; si el usuario no responde: `por definir` |
| `client` | Cliente o entidad destinataria | Mención en el mensaje ("para un cliente ganadero" -> `cliente ganadero`) | Si el mensaje no dice si hay cliente; sin cliente: `sin cliente` |
| `stack` | Tecnologías del proyecto | Mensaje del usuario; `pyproject.toml` (Python), `package.json` (Node), etc. | Si no se puede inferir; si aún no existe: `por definir` |
| `management_path` | Ruta de la carpeta de gestión del cliente | No se infiere | Solo si hay cliente; sin cliente: `no aplica` |
| `repo_url` | URL del repositorio | `git remote get-url origin`, si existe | Nunca; si no hay remoto: `por definir` |
| `date` | Fecha del scaffold | Hoy, formato `YYYY-MM-DD` (`date +%F`) | Nunca |
| `plugin_version` | Versión del plugin sdd-harness | Se obtiene en el paso 3 de `SKILL.md` (`${CLAUDE_PLUGIN_ROOT}` solo se sustituye allí) | Nunca |

## Reglas

- Pregunta una sola vez, agrupando todo lo que falte.
- `key=` vacío es válido para el script, pero este skill prefiere texto explícito ("sin cliente", "no aplica", "por definir").
- `CLAUDE.md` usa las ocho variables; el resto de plantillas, subconjuntos. Pasar variables de más no falla.

## Variables por plantilla

| Plantilla | Variables |
|---|---|
| `CLAUDE.md` | las ocho |
| `repo-readme.md` | `project`, `description`, `stack`, `date`, `plugin_version` |
| `docs-readme.md` | `project`, `date`, `plugin_version` |
| `gitignore` | ninguna |
| `agent_docs/code_conventions`, `testing`, `verification_metrics`, `logging` | `stack` |
| `agent_docs/troubleshooting` | `date` |
| `agent_docs/project_status` | `project`, `date` |
| `agent_docs/workflow`, `architecture`, `antipatterns` | ninguna |
