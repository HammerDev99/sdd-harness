#!/usr/bin/env bash
# Hook Stop: pytest (y mypy si hay src/) al cerrar el turno.
# Silencio si el proyecto no tiene pyproject.toml.
# Salida: JSON con systemMessage (lo ve el usuario); nunca bloquea el cierre.
# Timeout: SDD_STOP_TIMEOUT, si no el valor de userConfig stopTimeoutSeconds
# (CLAUDE_PLUGIN_OPTION_STOPTIMEOUTSECONDS), si no 120 s.
# Sin timeout/gtimeout usa perl (alarm). pytest y mypy tienen cada uno el presupuesto completo.
# Siempre sale con 0. Compatible con bash 3.2.

input="$(cat)"
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)"
PROJECT="${CLAUDE_PROJECT_DIR:-$cwd}"

[ -n "$PROJECT" ] && [ -f "$PROJECT/pyproject.toml" ] || exit 0

emitir() {
  jq -n --arg msg "$1" '{systemMessage: $msg}'
}

prefijar() {
  printf '%s\n' "$1" | tail -n 10 | sed 's/^/sdd-harness\/tests: /'
}

cd "$PROJECT" 2>/dev/null || exit 0

segundos="${SDD_STOP_TIMEOUT:-${CLAUDE_PLUGIN_OPTION_STOPTIMEOUTSECONDS:-120}}"
case "$segundos" in
  '' | *[!0-9]*) segundos=120 ;;
esac

limite=()
sin_limite=""
if command -v timeout >/dev/null 2>&1; then
  limite=(timeout "$segundos")
elif command -v gtimeout >/dev/null 2>&1; then
  limite=(gtimeout "$segundos")
elif command -v perl >/dev/null 2>&1; then
  # perl viene con macOS: alarm + exec; SIGALRM termina con rc 142
  limite=(perl -e 'alarm shift; exec @ARGV or exit 127' "$segundos")
else
  sin_limite="(sin límite de tiempo: no hay timeout, gtimeout ni perl) "
fi

usar_uv=0
if [ -f "$PROJECT/uv.lock" ] && command -v uv >/dev/null 2>&1; then
  usar_uv=1
fi

if [ "$usar_uv" -eq 1 ]; then
  pytest_cmd=(uv run pytest)
elif command -v pytest >/dev/null 2>&1; then
  pytest_cmd=(pytest)
elif command -v python3 >/dev/null 2>&1 && python3 -c 'import pytest' >/dev/null 2>&1; then
  pytest_cmd=(python3 -m pytest)
else
  emitir "sdd-harness/tests: pytest no disponible; instálalo para verificar las pruebas."
  exit 0
fi

salida="$("${limite[@]}" "${pytest_cmd[@]}" -q -x -p no:cacheprovider 2>&1)"
rc=$?
mensaje="$(prefijar "$salida")"
if [ "$rc" -eq 124 ] || [ "$rc" -eq 142 ]; then
  mensaje="sdd-harness/tests: pytest superó el límite de ${segundos}s y se interrumpió.
$mensaje"
fi
if [ -n "$sin_limite" ]; then
  mensaje="sdd-harness/tests: $sin_limite
$mensaje"
fi

if [ -d "$PROJECT/src" ]; then
  if [ "$usar_uv" -eq 1 ]; then
    mypy_cmd=(uv run mypy)
  elif command -v mypy >/dev/null 2>&1; then
    mypy_cmd=(mypy)
  else
    mypy_cmd=()
  fi
  if [ "${#mypy_cmd[@]}" -eq 0 ]; then
    mensaje="$mensaje
sdd-harness/tests: mypy no disponible; se omite la verificación de tipos."
  else
    salida_mypy="$("${limite[@]}" "${mypy_cmd[@]}" src 2>&1)"
    rc_mypy=$?
    if [ "$rc_mypy" -eq 124 ] || [ "$rc_mypy" -eq 142 ]; then
      mensaje="$mensaje
sdd-harness/mypy: mypy superó el límite de ${segundos}s y se interrumpió."
    fi
    mensaje="$mensaje
$(printf '%s\n' "$salida_mypy" | tail -n 10 | sed 's/^/sdd-harness\/mypy: /')"
  fi
fi

emitir "$mensaje"
exit 0
