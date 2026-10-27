#!/usr/bin/env bash
# Fixture: proyecto con una spec corta de diseño.
mkdir -p docs/superpowers/specs docs/diagrams
cat > docs/superpowers/specs/2026-10-27-hato-claro-design.md <<'EOF'
# Hato Claro — spec de diseño

## Objetivo
Registrar animales, vacunaciones y movimientos de una finca lechera, y generar el reporte mensual de trazabilidad.

## Entidades
- Animal (id, arete, fecha_nacimiento, estado: activo | vendido | muerto)
- Vacunacion (animal, vacuna, fecha, lote)
- Movimiento (animal, origen, destino, fecha)

## Caso de uso central
El administrador registra una vacunación; el sistema valida que el animal esté activo, guarda el evento y actualiza el reporte mensual.

## Proceso crítico
Cierre mensual: reunir eventos, validar completitud, calcular totales, emitir reporte, archivar.
EOF
printf '# CLAUDE.md — Hato Claro\n' > CLAUDE.md
