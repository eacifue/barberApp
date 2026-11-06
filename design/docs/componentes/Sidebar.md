# Sidebar

Navegación lateral del panel web: logo, secciones por rol, ítem activo en `brass-soft` y tarjeta del usuario.

**Props:** `sections` (`{title, items:[{icon, label, count?}]}[]`) · `active` (label) · `user` (`{name, role}`).

**Menú por rol**
- Admin: Principal (Dashboard) · Mi barbería (Agenda, Disponibilidad, Clientes, Barberos, Servicios) · Administración (Mi negocio, Usuarios).
- Admin Barbería: Principal · Mi barbería.
- Barbero: Principal (Dashboard) · Agenda (Mis citas).

**Reglas:** fijo desde 1280 px; drawer por debajo. El contador muestra citas pendientes de hoy. Sin barra de color a la izquierda del activo.
