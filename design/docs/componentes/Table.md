# Table

Tabla de datos del panel web: cabecera hundida, filas de 56 px, cifras a la derecha y acciones al final.

**Props:** `columns` (`{key, label, align?, muted?, sort?, render?(row)}[]`) · `rows` · `caption`.

**Reglas**
- Celda de persona: `Avatar` 32 + nombre + correo.
- Acciones de fila con `IconButton` y `label` que nombra el registro («Editar Laura Henao»).
- Debajo de 768 px la tabla se convierte en lista de tarjetas (mismo orden de campos).
- Vacío y error dentro de la tabla con `EmptyState`; carga con `Skeleton variant='row'`.
