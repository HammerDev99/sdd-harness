---
name: project-folder
description: Crea la carpeta de gestión del cliente (00_Assets a 06_Facturacion y README.md) separada del repositorio técnico, y deja la regla de separación documentada en ambos lados.
when_to_use: Cuando el usuario pida "crear la carpeta de gestión", "carpeta del cliente", "carpeta de proyecto del cliente", "estructura de gestión" o separar propuesta, actas y facturación del repositorio técnico.
---

# project-folder

Crea la carpeta de gestión de un proyecto (propuesta, plan, actas, facturación) fuera del código. Es idempotente: no sobrescribe nada existente.

## Reglas

- La carpeta de gestión nunca recibe código ni documentación técnica. El repositorio nunca recibe datos del cliente. Escribe solo los archivos descritos aquí.
- Si la ruta ya contiene archivos del usuario, no los muevas ni los borres.

## Pasos

1. Determina `management_path`. Si el usuario no la dio, pregúntala (una sola pregunta, junto con las variables que falten). Conviértela en ruta absoluta o relativa al directorio actual, sin barra final.
2. Resuelve las variables de la plantilla: `project` (nombre del proyecto; infiérelo del mensaje, del `CLAUDE.md` o del nombre del directorio), `client` (si no hay, "sin cliente"), `description` (si no hay, "por definir"), `repo_url` (`git remote get-url origin` si existe; si no, "por definir"), `date` (`date +%Y-%m-%d`) y `plugin_version` (`jq -r .version "${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json"`). Todas deben llevar valor.
3. Crea las carpetas con un solo comando, sustituyendo la ruta real:
   `mkdir -p "<management_path>/00_Assets" "<management_path>/01_Propuesta" "<management_path>/02_Planificacion" "<management_path>/03_Ejecucion" "<management_path>/04_Control" "<management_path>/05_Cierre" "<management_path>/06_Facturacion"`
4. En cada carpeta numerada que esté vacía crea un `.gitkeep` vacío (`touch`), para que la estructura sobreviva a un control de versiones.
5. Renderiza el README de gestión (valores con espacios entre comillas), p. ej.:
   `"${CLAUDE_PLUGIN_ROOT}/scripts/render-template.sh" "${CLAUDE_PLUGIN_ROOT}/templates/project-readme.md" "<management_path>/README.md" project="Demo" client="cliente ganadero" description="..." management_path="<management_path>" repo_url="..." date="2026-10-27" plugin_version="0.1.0"`
   Conserva la salida (`Creado:` / `Omitido (existe):`). Si responde `Faltan variables: ...`, no escribió nada: resuélvelas y repite.
6. Si existe el repositorio técnico (hay `README.md` en el directorio actual o en la ruta que indique el usuario y no es la carpeta de gestión): busca el encabezado `## Fuente de verdad documental` con `grep -n "Fuente de verdad documental" README.md`. Si ya está, regístralo como omitido. Si no, añade al final del `README.md` del repositorio:

   ```
   ## Fuente de verdad documental

   La gestión del proyecto (propuesta, plan, actas, insumos y facturación) vive en
   `<management_path>`. La carpeta de gestión no recibe código ni documentación técnica;
   este repositorio no recibe datos del cliente.
   ```
   Si no hay repositorio técnico, indícalo y sugiere repetir este paso cuando exista.

## Reporte final

Reporte en español con dos listas: **Creados** (carpetas y archivos nuevos, incluida la sección añadida al README del repositorio) y **Omitidos** (lo que ya existía). Recuerda la regla de separación en una línea.
