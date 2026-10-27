# logging.md — Logging

**Estado:** pendiente — se define con el stack ({{stack}}). Requisitos mínimos:

- Registrar cada inconsistencia encontrada al procesar datos (fuente, fila, campo, valor, regla violada) en un archivo de hallazgos reutilizable.
- Nunca registrar documentos de identidad, teléfonos ni credenciales en logs; usar IDs internos.
- Niveles consistentes (debug, info, warning, error) y mensajes en español.
