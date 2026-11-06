# ConfirmDialog

Diálogo de confirmación para acciones destructivas o que liberan un horario.

**Props:** `title` (pregunta) · `body` (consecuencia concreta) · `confirmLabel` (verbo explícito) · `cancelLabel` («Volver») · `tone` `'danger' | 'info'` · `icon`.

**Reglas:** el título pregunta, el cuerpo dice qué se pierde, el botón repite el verbo: «¿Cancelar esta cita?» → «Sí, cancelar cita». Nunca «Aceptar/Cancelar».
