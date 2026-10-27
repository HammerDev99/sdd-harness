setup() {
  cd "$BATS_TEST_DIRNAME/.."
}

@test "cuatro agentes con frontmatter válido" {
  [ "$(ls agents/*.md | wc -l)" -eq 4 ]
  for f in agents/*.md; do
    grep -q '^name:' "$f"
    grep -q '^description:' "$f"
    grep -q '^tools:' "$f"
    grep -q '^model:' "$f"
    ! grep -qE '^(permissionMode|hooks):' "$f"
  done
}

@test "senior-architect no tiene herramientas de escritura" {
  ! grep -E '^tools:.*(Write|Edit|Bash)' agents/senior-architect.md
}

@test "modelos y herramientas según la tabla de la spec" {
  grep -q '^tools: Read, Grep, Glob, Bash$' agents/code-reviewer.md
  grep -q '^model: opus$' agents/code-reviewer.md
  grep -q '^model: opus$' agents/senior-architect.md
  grep -q '^tools: Read, Grep, Glob, Bash$' agents/security-scanner.md
  grep -q '^model: sonnet$' agents/security-scanner.md
  grep -q '^tools: Read, Grep, Glob$' agents/doc-auditor.md
  grep -q '^model: haiku$' agents/doc-auditor.md
}

@test "agentes con Bash declaran la restricción de solo lectura" {
  grep -q 'git diff' agents/code-reviewer.md
  grep -q 'pytest --collect-only' agents/code-reviewer.md
  grep -q 'anthropic-skills:refactoring' agents/code-reviewer.md
  grep -q 'Instrumentos' agents/code-reviewer.md
  grep -q 'rg' agents/security-scanner.md
}
