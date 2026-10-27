# antipatterns.md — Qué NO hacer

Lecciones de los insumos del cliente. Cada antipatrón tiene su regla positiva.

| # | Antipatrón observado | Por qué daña | Regla |
|---|---|---|---|
| 1 | Columna que mezcla conceptos distintos (zona, rol y persona en una misma celda) | Imposible agrupar o filtrar | Un concepto, una entidad. |
| 2 | Filas de totales dentro de la tabla de datos | Rompe sumas y cargas automáticas | Los totales se calculan; no se almacenan en la tabla de hechos. |
| 3 | Una columna por fecha | No escala; imposible filtrar | Formato largo: una fila por (fecha, sujeto, concepto, valor). |
| 4 | Movimientos negativos sin tipo | Se confunden con correcciones o errores | Tipo de movimiento explícito. |
| 5 | Mismo concepto con nombres distintos | Duplica entidades | Catálogos con ID y tabla de alias. |
| 6 | Fechas como texto o inconsistentes | Alertas falsas o ausentes | Fechas tipadas; validar coherencia entre fechas. |
| 7 | Rótulos equivocados (periodo o año erróneo) | Lecturas erróneas | Todo registro lleva periodo y año explícitos. |
| 8 | Mezclar personas con organizaciones | Rompe reportes por persona | Organización separada de Persona. |

_Agregar filas a medida que aparezcan en los insumos reales del proyecto._

## Antipatrones de proceso

- Construir pantallas antes de normalizar los datos: el valor del MVP suele estar en el cálculo, no en la interfaz.
- Presentar reglas de negocio como ciertas sin confirmarlas con el cliente: marcarlas *por confirmar*.
- Subir datos del cliente a servicios externos o repos: ver regla crítica 1 en `CLAUDE.md`.
