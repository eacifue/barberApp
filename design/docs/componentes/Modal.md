# Modal

Ventana modal para formularios (Nueva cita, crear/editar barbero, servicio, cliente). En móvil se presenta como bottom sheet.

**Props:** `title` · `subtitle` · `children` (el formulario) · `footer` (botones: secundario + primario; nodos o lista `{label, variant, icon, href}`) · `size='lg'` (760 px, p. ej. barbero con horario semanal) · `sheet` (bottom sheet) · `inline` (solo para previsualizar).

**Flutter:** `showModalBottomSheet(isScrollControlled: true, useSafeArea: true)` con radio superior `radius-xl` y asa.

**Reglas:** cerrar con X, Esc o el velo si no hay cambios; con cambios, preguntar «¿Descartar cambios?». El foco entra al primer campo y vuelve al botón que abrió el modal.
