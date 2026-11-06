# BarberCard

Tarjeta del barbero en el paso 2: foto, nombre, calificación, años de experiencia y hasta 3 especialidades.

**Props:** `name` · `photo` · `rating` · `reviews` · `years` · `specialties` (string[]) · `available` (false = «No disponible hoy», no seleccionable) · `unavailableLabel` · `selected` · `onClick` · `onProfile` (muestra «Ver perfil»).

**Reglas**
- No disponible: se muestra al final, en gris, con motivo si existe («Vuelve el lunes»).
- Si el barbero tiene precio especial para el servicio, mostrarlo en la línea de experiencia.
