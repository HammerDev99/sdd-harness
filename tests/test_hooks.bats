setup() {
  cd "$BATS_TEST_DIRNAME/.."
  ROOT="$PWD"
}

@test "post-edit guarda silencio sin pyproject" {
  run bash -c 'echo "{\"tool_input\":{\"file_path\":\"x.py\"}}" | CLAUDE_PROJECT_DIR=tests/fixtures/no_py scripts/post-edit.sh'
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "post-edit reporta ruff en archivo roto" {
  run bash -c 'echo "{\"tool_input\":{\"file_path\":\"$PWD/tests/fixtures/py_bad/mi modulo.py\"}}" | CLAUDE_PROJECT_DIR="$PWD/tests/fixtures/py_bad" scripts/post-edit.sh'
  [ "$status" -eq 0 ]
  [[ "$output" == *"F401"* ]]
  [[ "$output" == *"sdd-harness/ruff:"* ]]
  # El aviso viaja como JSON válido por additionalContext
  echo "$output" | jq -e '.hookSpecificOutput.hookEventName == "PostToolUse" and (.hookSpecificOutput.additionalContext | length > 0)'
}

@test "post-edit respeta rutas con espacios" {
  run bash -c 'echo "{\"tool_input\":{\"file_path\":\"$PWD/tests/fixtures/py_bad/mi modulo.py\"}}" | CLAUDE_PROJECT_DIR="$PWD/tests/fixtures/py_bad" scripts/post-edit.sh'
  [ "$status" -eq 0 ]
  [[ "$output" != *"No such file"* ]]
  [[ "$output" == *"mi modulo.py"* ]]
}

@test "post-edit ignora archivos que no son .py" {
  run bash -c 'echo "{\"tool_input\":{\"file_path\":\"$PWD/README.md\"}}" | CLAUDE_PROJECT_DIR="$PWD/tests/fixtures/py_bad" scripts/post-edit.sh'
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "post-edit avisa si ruff no está disponible" {
  run bash -c 'echo "{\"tool_input\":{\"file_path\":\"$PWD/tests/fixtures/py_bad/mi modulo.py\"}}" | CLAUDE_PROJECT_DIR="$PWD/tests/fixtures/py_bad" PATH="$(dirname "$(command -v jq)"):/usr/bin:/bin" scripts/post-edit.sh'
  [ "$status" -eq 0 ]
  [[ "$output" == *"ruff no disponible"* ]]
}

@test "on-stop guarda silencio sin pyproject" {
  run bash -c 'echo "{}" | CLAUDE_PROJECT_DIR=tests/fixtures/no_py scripts/on-stop.sh'
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "on-stop pasa en fixture limpio" {
  run bash -c 'echo "{}" | CLAUDE_PROJECT_DIR="$PWD/tests/fixtures/py_ok" scripts/on-stop.sh'
  [ "$status" -eq 0 ]
  [[ "$output" == *"passed"* ]]
  [[ "$output" == *"sdd-harness/tests:"* ]]
  echo "$output" | jq -e '.systemMessage | length > 0'
  # Nunca bloquea el cierre del turno
  [ "$(echo "$output" | jq -r '.decision // "none"')" = "none" ]
}

@test "on-stop sin pytest avisa y sale 0" {
  # PATH aislado con solo las utilidades necesarias: sin pytest ni python3
  mini="$BATS_TEST_TMPDIR/minbin"
  mkdir -p "$mini"
  for t in jq sed tail cat printf bash dirname; do
    ln -sf "$(command -v $t)" "$mini/$t"
  done
  run bash -c 'echo "{}" | CLAUDE_PROJECT_DIR="$PWD/tests/fixtures/py_ok" PATH="$1" scripts/on-stop.sh' _ "$mini"
  [ "$status" -eq 0 ]
  [[ "$output" == *"pytest no disponible"* ]]
}

@test "on-stop respeta SDD_STOP_TIMEOUT cuando hay limitador" {
  if ! command -v timeout >/dev/null 2>&1 && ! command -v gtimeout >/dev/null 2>&1; then
    skip "ni timeout ni gtimeout disponibles"
  fi
  fake="$BATS_TEST_TMPDIR/fakebin"
  mkdir -p "$fake"
  printf '#!/usr/bin/env bash\nsleep 20\n' > "$fake/pytest"
  chmod +x "$fake/pytest"
  start=$SECONDS
  run bash -c 'echo "{}" | CLAUDE_PROJECT_DIR="$PWD/tests/fixtures/py_ok" SDD_STOP_TIMEOUT=1 PATH="'"$fake"':$PATH" scripts/on-stop.sh'
  [ "$status" -eq 0 ]
  [ $((SECONDS - start)) -lt 15 ]
}

@test "on-stop usa el valor de userConfig si no hay SDD_STOP_TIMEOUT" {
  run grep -q 'CLAUDE_PLUGIN_OPTION_STOPTIMEOUTSECONDS' scripts/on-stop.sh
  [ "$status" -eq 0 ]
}

@test "check-deps sin plugins avisa las tres" {
  mkdir -p "$BATS_TEST_TMPDIR/vacio" "$BATS_TEST_TMPDIR/vacio2"
  run bash -c 'echo "{}" | CLAUDE_PLUGINS_DIR="$1" CLAUDE_SKILLS_DIR="$2" scripts/check-deps.sh' _ "$BATS_TEST_TMPDIR/vacio" "$BATS_TEST_TMPDIR/vacio2"
  [ "$status" -eq 0 ]
  [[ "$output" == *"superpowers"* && "$output" == *"design-patterns"* && "$output" == *"refactoring"* ]]
  [[ "$output" == *"sdd-harness: faltan dependencias"* ]]
}

@test "check-deps no avisa cuando las tres dependencias existen" {
  p="$BATS_TEST_TMPDIR/plugins"
  s="$BATS_TEST_TMPDIR/skills"
  mkdir -p "$p/synced/id/id/skills/brainstorming" "$s/synced/id/design-patterns" "$s/synced/id/refactoring"
  run bash -c 'echo "{}" | CLAUDE_PLUGINS_DIR="$1" CLAUDE_SKILLS_DIR="$2" scripts/check-deps.sh' _ "$p" "$s"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "check-deps tolera directorios inexistentes" {
  run bash -c 'echo "{}" | CLAUDE_PLUGINS_DIR=/no/existe CLAUDE_SKILLS_DIR=/tampoco scripts/check-deps.sh'
  [ "$status" -eq 0 ]
  [[ "$output" == *"superpowers"* ]]
}

@test "hooks.json es válido y referencia los tres scripts" {
  jq -e '.hooks.SessionStart and .hooks.PostToolUse and .hooks.Stop' hooks/hooks.json
  jq -e '.hooks.PostToolUse[0].matcher == "Edit|Write"' hooks/hooks.json
  grep -q 'scripts/check-deps.sh' hooks/hooks.json
  grep -q 'scripts/post-edit.sh' hooks/hooks.json
  grep -q 'scripts/on-stop.sh' hooks/hooks.json
}
