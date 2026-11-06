# Chip

Chip de filtro (selección con check), de entrada (con quitar) o etiqueta informativa.

**Props:** `selected` · `icon` · `count` · `onRemove` (convierte en chip de entrada) · `as='tag'` (etiqueta no interactiva) · `children`.

**Flutter:** filtro → `FilterChip` (`selectedColor` `brass-soft`, `side` `brass-ink` al elegir, `line-strong` sin elegir); entrada → `InputChip` con `onDeleted`; etiqueta → `Chip` sin borde con `surface-sunken`. Forma `StadiumBorder`.

**Reglas**
- Filtro por tipo de servicio en el paso 1 y por estado en la agenda; «Todos» siempre primero.
- Especialidades del barbero: chips de entrada («Escribe y presiona Enter»), nunca texto separado por comas.
- En tarjetas, máximo 3 etiquetas.
