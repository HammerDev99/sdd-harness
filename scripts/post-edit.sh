#!/usr/bin/env bash
# Hook PostToolUse (Edit|Write): ruff sobre el archivo .py editado.
# Silencio si el archivo no es .py o el proyecto no tiene pyproject.toml.
# Salida: JSON con additionalContext (llega al modelo junto al resultado de
# la herramienta); nunca bloquea. Siempre sale con 0. Compatible con bash 3.2.

input="$(cat)"
file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)"
PROJECT="${CLAUDE_PROJECT_DIR:-$cwd}"

case "$file" in
  *.py) ;;
  *) exit 0 ;;
esac
[ -n "$PROJECT" ] && [ -f "$PROJECT/pyproject.toml" ] || exit 0

emitir() {
  jq -n --arg msg "$1" \
    '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $msg}}'
}

cd "$PROJECT" 2>/dev/null || exit 0

if [ -f "$PROJECT/uv.lock" ] && command -v uv >/dev/null 2>&1; then
  ruff_cmd=(uv run ruff)
elif command -v ruff >/dev/null 2>&1; then
  ruff_cmd=(ruff)
else
  emitir "sdd-harness/ruff: ruff no disponible; instálalo para verificar el estilo."
  exit 0
fi

salida="$("${ruff_cmd[@]}" check --output-format concise --no-cache "$file" 2>&1)"
rc_check=$?
salida_fmt="$("${ruff_cmd[@]}" format --check --no-cache "$file" 2>&1)"
rc_fmt=$?

if [ "$rc_check" -ne 0 ] || [ "$rc_fmt" -ne 0 ]; then
  todo="$salida"
  if [ "$rc_fmt" -ne 0 ]; then
    todo="$todo
$salida_fmt"
  fi
  recorte="$(printf '%s\n' "$todo" | tail -n 10 | sed 's/^/sdd-harness\/ruff: /')"
  emitir "$recorte"
fi
exit 0
