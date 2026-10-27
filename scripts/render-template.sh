#!/usr/bin/env bash
# Renderiza una plantilla de sdd-harness sustituyendo {{clave}} por valor.
# Uso: render-template.sh [--append] PLANTILLA DESTINO [clave=valor ...]
# Salida: 0 ok u omitido; 1 faltan variables; 2 error de uso.
# Compatible con bash 3.2. La sustitución es literal (awk + ENVIRON, sin sed).

uso() {
  echo "Uso: render-template.sh [--append] PLANTILLA DESTINO [clave=valor ...]" >&2
  exit 2
}

append=0
template=""
dest=""
keys=()
vals=()

while [ $# -gt 0 ]; do
  case "$1" in
    --append) append=1 ;;
    *=*)
      if [ -z "$template" ] || [ -z "$dest" ]; then
        uso
      fi
      keys+=("${1%%=*}")
      vals+=("${1#*=}")
      ;;
    *)
      if [ -z "$template" ]; then
        template="$1"
      elif [ -z "$dest" ]; then
        dest="$1"
      else
        uso
      fi
      ;;
  esac
  shift
done

[ -n "$template" ] && [ -n "$dest" ] || uso
if [ ! -f "$template" ]; then
  echo "Plantilla no encontrada: $template" >&2
  exit 2
fi

tmp_a="$(mktemp)"
tmp_b="$(mktemp)"
trap 'rm -f "$tmp_a" "$tmp_b"' EXIT
cp "$template" "$tmp_a"

i=0
while [ "$i" -lt "${#keys[@]}" ]; do
  RT_KEY="{{${keys[$i]}}}" RT_VAL="${vals[$i]}" awk '
    BEGIN { k = ENVIRON["RT_KEY"]; v = ENVIRON["RT_VAL"]; kl = length(k) }
    {
      line = $0; out = ""
      while ((p = index(line, k)) > 0) {
        out = out substr(line, 1, p - 1) v
        line = substr(line, p + kl)
      }
      print out line
    }' "$tmp_a" > "$tmp_b"
  mv "$tmp_b" "$tmp_a"
  tmp_b="$(mktemp)"
  i=$((i + 1))
done

# Variables sin resolver (nombres únicos, en orden de aparición)
missing="$(grep -o '{{[A-Za-z_][A-Za-z0-9_]*}}' "$tmp_a" | sed 's/^{{//; s/}}$//' | awk '!s[$0]++' | paste -sd, - | sed 's/,/, /g')"
if [ -n "$missing" ]; then
  echo "Faltan variables: $missing"
  exit 1
fi

if [ -e "$dest" ] && [ "$append" -eq 0 ]; then
  echo "Omitido (existe): $dest"
  exit 0
fi

mkdir -p "$(dirname "$dest")"

if [ "$append" -eq 1 ] && [ -e "$dest" ]; then
  marker="$(head -n 1 "$tmp_a")"
  if grep -qxF -- "$marker" "$dest"; then
    echo "Omitido (bloque presente): $dest"
    exit 0
  fi
  # Separador: línea en blanco si el destino no termina en salto doble
  if [ -s "$dest" ] && [ -n "$(tail -c 1 "$dest")" ]; then
    printf '\n' >> "$dest"
  fi
  [ -s "$dest" ] && printf '\n' >> "$dest"
  cat "$tmp_a" >> "$dest"
  echo "Anexado: $dest"
  exit 0
fi

cat "$tmp_a" > "$dest"
echo "Creado: $dest"
exit 0
