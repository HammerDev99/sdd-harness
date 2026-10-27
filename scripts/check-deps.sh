#!/usr/bin/env bash
# Hook SessionStart: avisa si faltan las dependencias de sdd-harness.
# Dependencias: superpowers (skills/brainstorming) y las skills
# design-patterns y refactoring de anthropic-skills.
# Salida: nada si todo está presente; si no, JSON con additionalContext
# (SessionStart lo añade al contexto del modelo). Siempre sale con 0.
# Compatible con bash 3.2.

cat >/dev/null 2>&1 || true

plugins_dir="${CLAUDE_PLUGINS_DIR:-$HOME/.claude/plugins}"
skills_dir="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

# Busca un directorio por nombre bajo una raíz (acotado, tolera raíces ausentes)
# Uso: buscar RAIZ PATRON_RUTA
buscar() {
  [ -d "$1" ] || return 1
  [ -n "$(find "$1" -maxdepth 8 -type d -path "$2" -print -quit 2>/dev/null)" ]
}

faltan=""
agregar() {
  if [ -z "$faltan" ]; then
    faltan="$1"
  else
    faltan="$faltan, $1"
  fi
}

buscar "$plugins_dir" "*/skills/brainstorming" || agregar "superpowers"

for nombre in design-patterns refactoring; do
  if ! buscar "$plugins_dir" "*/$nombre" && ! buscar "$skills_dir" "*/$nombre" \
    && [ ! -d "$skills_dir/$nombre" ]; then
    agregar "$nombre"
  fi
done

if [ -n "$faltan" ]; then
  jq -n --arg msg "sdd-harness: faltan dependencias: $faltan" \
    '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $msg}}'
fi
exit 0
