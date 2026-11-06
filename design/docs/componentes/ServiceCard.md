# ServiceCard

Tarjeta de servicio seleccionable del paso 1 de la reserva: tipo, nombre, descripción, duración y precio.

**Props:** `name` · `type` (`Corte`, `Afeitado`, `Barba`, `Tinte`, `Tratamiento`, `Combo`, `Otro`) · `description` · `duration` (min) · `price` (número COP) · `image` (opcional; reemplaza el ícono) · `tag` (p. ej. «Popular») · `selected` · `onClick`.

**Flutter:** `Card` con `InkWell`, `Semantics(inMutuallyExclusiveGroup: true, checked: selected)`; seleccionado: fondo `brass-soft`, borde `brass-ink` 2 px y check en latón.

**Reglas**
- Va dentro de un contenedor `role='radiogroup'`. Tocar selecciona; la barra fija inferior muestra la elección y «Continuar» (mismo patrón en los pasos 1–3).
- Precio con `formatCOP` («$35.000»), duración «30 min» / «1 h 15 min».
- Precio especial del barbero: se muestra en el paso 2, no aquí («desde $35.000» si varía).
