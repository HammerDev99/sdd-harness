# code_conventions.md — Convenciones de código

**Stack:** {{stack}}. Detalle en la spec de diseño vigente (`docs/superpowers/specs/`).

**Estado:** pendiente — completar cuando se defina el stack.

- Entidades y campos del dominio en el idioma del negocio; infraestructura y patrones en inglés (`Repository`, `Service`, `get_by_id`). Fijar la convención al aprobar la spec.
- Capas con dependencias en un solo sentido: presentación → servicios → dominio ← repositorios. La presentación no contiene acceso a datos ni reglas de negocio.
- Entidades inmutables cuando el lenguaje lo permita; los servicios devuelven resultados con hallazgos, no excepciones crudas.
- Patrones de diseño en su forma mínima (funciones y estructuras simples) antes que jerarquías de clases.
- Catálogos con ID estable y una columna `*_raw` para conservar el texto original de la fuente.
- Tipos explícitos para fechas, dinero y cantidades.
- Nada de lógica de negocio en la capa de presentación: los cálculos derivados se hacen en el dominio y se exponen ya calculados.
- Commits en español, formato convencional (`feat:`, `fix:`, `docs:`), sin firma de IA.
