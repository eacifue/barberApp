# BottomNav

Barra de navegación inferior: en la app 4 destinos (Inicio, Reservar, Mis citas, Perfil); en el panel web móvil, flotante.

**Props:** `items` (`{icon, label, badge?}[]`) · `active` · `floating`.

**Flutter:** `NavigationBar` con `indicatorColor` `brass-soft`, íconos `brass-ink` activos / `ink-muted` inactivos, `labelBehavior: alwaysShow`, alto 72.

**Reglas:** se añade Perfil como cuarta pestaña (perfil, notificaciones, cerrar sesión). Se oculta durante los pasos 2–4 de la reserva para mantener el foco.
