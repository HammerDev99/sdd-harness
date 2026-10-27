# testing.md — Tests y verificación

**Estado:** pendiente — se completa con el stack ({{stack}}).

## Invariantes de dominio

Reglas que los tests deben cubrir desde el primer día. Se llenan al aprobar la spec:

1. _pendiente — por ejemplo, conservación de cantidades entre entradas, salidas y saldo._
2. _pendiente — por ejemplo, unicidad de identificadores por periodo._
3. _pendiente — por ejemplo, toda transacción referencia su documento de soporte._

## Práctica

- TDD: prueba que falla, implementación mínima, refactor (`superpowers:test-driven-development`).
- Un caso de prueba por invariante, incluidos los casos conocidos que deben fallar.
- Los datos de prueba son sintéticos; nunca datos reales del cliente.
- Antes de declarar algo listo, ejecutar la suite completa y leer la salida (`superpowers:verification-before-completion`).
