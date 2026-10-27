setup() {
  cd "$BATS_TEST_DIRNAME/.."
  OUT="$BATS_TEST_TMPDIR"
}

@test "render sustituye variables" {
  run scripts/render-template.sh templates/docs-readme.md "$OUT/out.md" project=Demo date=2026-10-27 plugin_version=0.1.0
  [ "$status" -eq 0 ]
  ! grep -q '{{' "$OUT/out.md"
}

@test "render falla si falta variable" {
  run scripts/render-template.sh templates/CLAUDE.md "$OUT/c.md" project=Demo
  [ "$status" -eq 1 ]
  [[ "$output" == *"Faltan variables"* ]] || false
  [ ! -f "$OUT/c.md" ]
}

@test "render no sobrescribe destino existente" {
  echo "original" > "$OUT/e.md"
  run scripts/render-template.sh templates/docs-readme.md "$OUT/e.md" project=Demo date=2026-10-27 plugin_version=0.1.0
  [ "$status" -eq 0 ]
  [[ "$output" == *"Omitido"* ]] || false
  [ "$(cat "$OUT/e.md")" = "original" ]
}

@test "ninguna plantilla menciona carpetas PDCA" {
  ! grep -rE 'plannings/|sprints/|validate/' templates/
}

@test "existen las nueve plantillas de agent_docs" {
  [ "$(ls templates/agent_docs/*.md | wc -l | tr -d ' ')" -eq 9 ]
}

@test "sustitucion literal con caracteres especiales y acentos" {
  run scripts/render-template.sh templates/project-readme.md "$OUT/p.md" \
    project=Demo client="Compañía Ñandú & Hijos" description="descripción útil" \
    repo_url='https://x.org/a/b?c=1&d=2|e' management_path='/a b/c\d.e' \
    date=2026-10-27 plugin_version=0.1.0
  [ "$status" -eq 0 ]
  grep -qF 'https://x.org/a/b?c=1&d=2|e' "$OUT/p.md"
  grep -qF 'Compañía Ñandú & Hijos' "$OUT/p.md"
  grep -qF '/a b/c\d.e' "$OUT/p.md"
}

@test "valor vacio es valido" {
  run scripts/render-template.sh templates/docs-readme.md "$OUT/v.md" project= date=2026-10-27 plugin_version=0.1.0
  [ "$status" -eq 0 ]
}

@test "faltan variables lista nombres sin duplicados" {
  run scripts/render-template.sh templates/CLAUDE.md "$OUT/f.md" project=Demo
  [ "$status" -eq 1 ]
  [ "$output" = "Faltan variables: plugin_version, date, description, client, management_path, repo_url, stack" ]
}

@test "append crea, anexa y no duplica el bloque" {
  run scripts/render-template.sh --append templates/gitignore "$OUT/.gitignore"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Creado"* ]] || false
  printf 'node_modules/\n' > "$OUT/g2"
  run scripts/render-template.sh --append templates/gitignore "$OUT/g2"
  [ "$status" -eq 0 ]
  grep -q 'node_modules/' "$OUT/g2"
  grep -q 'sdd-harness: datos sensibles' "$OUT/g2"
  run scripts/render-template.sh --append templates/gitignore "$OUT/g2"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Omitido (bloque presente)"* ]] || false
  [ "$(grep -c 'sdd-harness: datos sensibles' "$OUT/g2")" -eq 1 ]
}

@test "plantilla inexistente es error de uso" {
  run scripts/render-template.sh templates/nada.md "$OUT/n.md"
  [ "$status" -eq 2 ]
}

@test "project_status contiene las secciones requeridas" {
  grep -q '^## Etapa del flujo' templates/agent_docs/project_status.md
  grep -q '^## Hechos confirmados por la investigación' templates/agent_docs/project_status.md
}

@test "CLAUDE.md contiene la linea de scaffold" {
  grep -qF 'Scaffold: sdd-harness {{plugin_version}} ({{date}})' templates/CLAUDE.md
}

@test "research-report contiene marcas y secciones" {
  for s in '[V]' '[I]' '[NV]' 'Fuentes (URL, fecha de consulta)' 'Implicaciones' 'Resumen en diez líneas'; do
    grep -qF "$s" templates/research-report.md
  done
}
