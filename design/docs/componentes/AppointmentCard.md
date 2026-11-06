# AppointmentCard

Tarjeta de cita para Mis citas e Inicio: bloque de fecha, servicio, barbero, horario, estado y acciones.

**Props:** `service` · `barber` · `barberPhoto` · `date` (`YYYY-MM-DD`) · `start`, `end` (`HH:mm`) · `status` · `price` · `actions`: nodos (botones `sm`) o una lista de objetos `{label, variant, icon, onClick}` que se pintan como `Button` pequeños.

**Acciones por estado**
- Pendiente / Confirmada en la lista Próximas: sin botones; la tarjeta entera abre el detalle, donde están «Reprogramar» y «Cancelar cita». En Inicio (próxima cita destacada) sí lleva «Reprogramar» y «Cómo llegar».
- Completada sin reseña: «Calificar servicio» (ghost con `star`).
- Cancelada / No asistió: «Reservar de nuevo» (ghost con `rotate-ccw`).

**Reglas:** toda la tarjeta abre el detalle; el estado nunca se comunica con una barra de color lateral sino con `StatusBadge`. Horas en 12 h: «3:30 p. m. – 4:20 p. m.».
