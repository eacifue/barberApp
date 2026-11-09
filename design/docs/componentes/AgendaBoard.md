# AgendaBoard

Agenda del día por columnas (una por barbero) con bloques a escala real, línea de hora actual y estados distinguibles sin color.

**Props:** `barbers` (columnas: `{name, photo?, count, sub?, avatar?, current?, items:[{client, service, start, end, status, href?, selected?} | {block:true, client:'Almuerzo', start, end}]}[]`; para la vista Semana cada columna es un día con `avatar:false`, `sub` y `current` en hoy) · `start`, `end` (`HH:mm`, horario de la barbería) · `now` · `pxPerMin`.

**Codificación sin color:** Pendiente = borde punteado; En progreso = borde doble; Cancelada y No asistió = rayado + nombre tachado; bloqueos = rayado neutro con candado. Cada bloque lleva el ícono del estado.

**Interacción (implementar en la pantalla):** tocar un bloque abre el detalle con Confirmar / En progreso / Completar / No asistió / Cancelar; arrastrar un bloque a otra hora o columna propone reprogramar y pide confirmación; tocar un hueco abre «Nueva cita» con barbero y hora precargados. En móvil se muestra una columna por barbero con selector arriba.
