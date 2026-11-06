# Rating

Calificación de 0 a 5 con estrellas `brass-ink`, promedio con coma decimal y número de reseñas.

**Props:** `value` (0–5) · `count` · `compact` (una estrella + número, para tarjetas) · `size`.

**Flutter:** `Row` de `Icon(LucideIcons.star)` rellenas con `brass-ink` y vacías con `line-strong`; texto `label-sm` con `NumberFormat('0.0', 'es_CO')`.

**Reglas:** sin reseñas, mostrar «Nuevo» con `Badge tone='brass'` en vez de 0,0. Para calificar (después de una cita Completada) usar estrellas de 44 px tocables.
