# IconButton

Botón de solo ícono de 44 × 44 (36 en tablas de escritorio) con etiqueta accesible obligatoria.

**Props:** `icon` · `label` (obligatoria: va a `aria-label` y tooltip) · `variant` `'ghost' | 'secondary'` · `size` `'sm'` · `badge` (punto granate de novedad) · `disabled`.

**Flutter:** `IconButton` con `tooltip` = `label`, `visualDensity` estándar (no compacta) en móvil.

**Reglas:** acciones de fila (editar, desactivar), navegación del calendario, cerrar modal, menú. Si la acción es destructiva, abre `ConfirmDialog`.
