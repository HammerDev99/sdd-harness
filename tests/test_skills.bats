setup() {
  cd "$BATS_TEST_DIRNAME/.."
}

# Valor de una clave del frontmatter (primer bloque entre ---).
fm_get() {
  awk -v k="$2" '
    NR==1 && $0=="---" { infm=1; next }
    infm && $0=="---" { exit }
    infm && index($0, k ":")==1 { sub("^" k ":[ ]*", ""); print; exit }
  ' "$1"
}

@test "existe al menos una skill con SKILL.md" {
  n=$(ls skills/*/SKILL.md 2>/dev/null | wc -l)
  [ "$n" -ge 1 ]
}

@test "cada SKILL.md tiene menos de 500 lineas" {
  n=0
  for f in skills/*/SKILL.md; do
    [ -f "$f" ] || continue
    n=$((n+1))
    [ "$(wc -l < "$f")" -lt 500 ]
  done
  [ "$n" -ge 1 ]
}

@test "frontmatter con name, description y when_to_use" {
  n=0
  for f in skills/*/SKILL.md; do
    [ -f "$f" ] || continue
    n=$((n+1))
    for k in name description when_to_use; do
      [ -n "$(fm_get "$f" "$k")" ] || { echo "falta $k en $f"; false; }
    done
  done
  [ "$n" -ge 1 ]
}

@test "name coincide con el directorio" {
  n=0
  for f in skills/*/SKILL.md; do
    [ -f "$f" ] || continue
    n=$((n+1))
    [ "$(fm_get "$f" name)" = "$(basename "$(dirname "$f")")" ]
  done
  [ "$n" -ge 1 ]
}
