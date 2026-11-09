# Patrones de pantalla

Reglas de estructura y comportamiento para rediseñar cada pantalla con los componentes del sistema. Toda pantalla define sus estados: carga (`Skeleton`), vacío (`EmptyState`), error (`EmptyState tone='error'` o `Banner danger` con «Reintentar»), éxito (`Toast`) y deshabilitado.

## App móvil

### Navegación

- `BottomNav` con 4 destinos: **Inicio · Reservar · Mis citas · Perfil**. Perfil reúne datos, notificaciones y cerrar sesión (hoy no existe).
- Rol Barbero en la app: la pestaña Reservar se reemplaza por **Mi agenda** (lista del día con acciones En progreso / Completada / No asistió).
- Administración (solo `Admin` y `AdministradorBarberia`): entrada desde Perfil → «Administrar barbería», pantalla completa fuera del shell.
- Durante los pasos 2–4 de la reserva se oculta la barra inferior; la flecha atrás vuelve un paso conservando lo elegido.

### Splash y onboarding

- Splash: fondo `carbon`, `emblema-sobre-oscuro.svg` centrado, sin texto adicional; máximo 1 s.
- Onboarding (solo primera apertura, 3 pantallas, saltable): «Reserva en 4 pasos» · «Te guardamos el horario 5 minutos» · «Te avisamos antes de tu cita». La tercera pide el permiso de notificaciones con un botón propio («Activar recordatorios») antes del diálogo del sistema, y un secundario «Ahora no».

### Login, registro y recuperación

- Login: `Logo` horizontal, título `display` «Inicia sesión», correo + contraseña (con mostrar/ocultar), primario «Entrar», enlaces «¿Olvidaste tu contraseña?» y «Crear cuenta».
- Registro: nombre, apellido, teléfono (teclado numérico, formato `300 123 4567`), correo, contraseña con ayuda «Mínimo 6 caracteres.». Primario «Crear cuenta».
- Recuperar contraseña (nuevo, 3 pantallas): correo → código de 6 dígitos (campo segmentado, reenviar en 60 s) → nueva contraseña + confirmar → `Toast` «Contraseña actualizada» y vuelve a login.

### Inicio (cliente)

De arriba abajo:
1. Saludo `display` «Hola, Andrés» + campana con punto si hay avisos (abre el centro de notificaciones).
2. **Próxima cita** destacada (`AppointmentCard` con «Cómo llegar» y «Reprogramar»); sin cita: tarjeta con CTA primario «Reservar» (`control-lg`).
3. **Servicios populares**: carrusel horizontal de `ServiceCard` compactas; tocar abre el paso 2 con ese servicio elegido.
4. **Nuestros barberos**: carrusel de avatares 64 + nombre + `Rating compact`; tocar abre el perfil.
5. **La barbería**: foto de portada (`radius-xl`), slogan, dirección con mini-mapa, horario de hoy («Abierto hasta las 8:00 p. m.» / «Cerrado · abre el lunes 9:00 a. m.»), botones Llamar, WhatsApp y Cómo llegar.
- Admins ven además una tarjeta «Administrar barbería». Las métricas internas salen del Inicio del cliente.

### Reserva (4 pasos)

Cabecera común: flecha atrás, `Stepper`, título `display`.

1. **¿Qué servicio deseas?** Chips de tipo (`Chip`, «Todos» primero) + lista de `ServiceCard`. Tocar una tarjeta la selecciona; la barra fija inferior muestra «Corte + barba · 50 min · $50.000» y «Continuar» (mismo patrón en los pasos 1–3).
2. **Elige tu barbero.** `Banner brass` de contexto «Corte + barba · 50 min · $50.000» con «Cambiar». Lista de `BarberCard`; no disponibles al final. Precio especial del barbero, si existe, en su tarjeta.
3. **Elige fecha y hora.** Tarjeta de contexto (servicio + barbero, con «Cambiar»), `Calendar`, título «Horarios para el jueves 12 de noviembre», `SlotGrid`. Al tocar un horario: se bloquea en el servidor, aparece `Countdown` arriba de la barra fija y la barra muestra «3:00 p. m. · 50 min» + «Continuar». Tocar otro horario libera el anterior. Sin horarios: `EmptyState` «No hay horarios este día» + «Ver el próximo día disponible».
4. **Confirma tu reserva.** `Countdown compact` arriba. Resumen en una tarjeta con `overline` (Servicio, Barbero, Fecha y hora, Lugar) y total en `title`; línea «Pago en el local». Campo «Alguna nota para el barbero (opcional)». Primario «Reservar ahora» en la barra fija. En modo reprogramación, `Banner info` «Estás reprogramando tu cita» y el primario dice «Confirmar nuevo horario».
- **Salir con horario apartado:** `ConfirmDialog tone='info'` «¿Salir sin reservar?» / «Tu horario apartado se liberará.» / «Salir» · «Seguir reservando».
- **Expiración:** al llegar a 0:00, `ConfirmDialog` «Tu horario se liberó» / «Pasaron 5 minutos sin confirmar. Elige de nuevo; puede que siga libre.» / «Elegir horario» (vuelve al paso 3 en la misma fecha).
- **Conflicto al confirmar** (otro cliente lo tomó): vuelve al paso 3 con `Banner danger` «Ese horario ya no está disponible. Elige otro.».
- **Éxito:** pantalla completa, check Lottie latón, `display-lg` «Reserva confirmada», «Jueves 12 de noviembre · 3:00 p. m. con Julián», «Te enviaremos un recordatorio antes de tu cita.», primario «Ver mis citas», secundario «Volver al inicio», ghost «Añadir al calendario».

### Mis citas y detalle

- `Tabs` «Próximas (n)» / «Historial». Lista de `AppointmentCard` agrupada por mes en historial. En Próximas la tarjeta entera abre el detalle (sin botones dentro, para evitar cancelaciones por error); en Historial lleva «Calificar servicio» o «Reservar de nuevo».
- Detalle: estado arriba, servicio y precio, barbero (tocable → perfil), fecha y hora, **Ubicación** con mini-mapa y «Cómo llegar», notas. Acciones al pie: «Reprogramar» (secundario) y «Cancelar cita» (`danger-ghost` → `ConfirmDialog`). Si el servicio o el barbero ya no existen, «Reprogramar» se deshabilita con la razón debajo.
- Completada sin reseña: tarjeta «¿Cómo te fue con Julián?» con 5 estrellas de 44 px y comentario opcional; enviar muestra `Toast` «¡Gracias por tu reseña!».

### Pantallas nuevas

- **Perfil del barbero:** foto grande (`radius-xl`), nombre `title-lg`, `Rating` + n.º de reseñas, años de experiencia, especialidades como etiquetas, biografía, servicios con precio (especial tachando el general), reseñas recientes; CTA fijo «Reservar con Julián».
- **Perfil del cliente:** avatar con «Cambiar foto» (cámara o galería), datos editables, `Switch` de recordatorios y de promociones, «Cambiar contraseña», «Cerrar sesión» (`danger-ghost`, con confirmación).
- **Centro de notificaciones:** lista por día («Hoy», «Ayer», fecha), ícono por tipo, no leídas con punto granate; tocar abre la cita. Vacío: «No tienes avisos».
- **Administración en la app:** mismas pestañas (Barbería, Barberos, Servicios, Clientes) con formularios en bottom sheet; foto con cámara/galería, especialidades con chips, horario con selectores de hora, ubicación con mapa.

## Panel web

### Estructura

`Sidebar` + `Topbar` + contenido sobre `bg`. Título de página en la topbar (`display` 24). Debajo de 1280 px el sidebar pasa a drawer; debajo de 768 px aparece la `BottomNav floating` con Inicio, Agenda, Clientes, Más.

### Dashboard

- Fila de 4 `StatCard`: Citas del día, Ingresos del día, Clientes activos, Barberos activos.
- Gráficas (con `chart-1…5`, una sola escala por gráfica, tooltip al pasar): ingresos por día (barras, últimos 14 días), ocupación por barbero (barras horizontales en %, una por barbero), servicios más vendidos (barras horizontales), cancelaciones y no-show (línea semanal, en % de citas).
- «Próximas citas de hoy» (lista compacta con `StatusBadge` y acción rápida) y «Calendario del mes» (`Calendar` con puntos de ocupación). «Estado del sistema» se reduce a un indicador en la topbar.

### Agenda (pantalla principal)

- Barra de herramientas: `Tabs segmented` Día · Semana · Historial, fecha con flechas y «Hoy», filtros (barbero, estado como `Chip`), primario «Nueva cita».
- **Día:** `AgendaBoard` por barbero con línea de ahora; tocar un hueco crea cita con barbero y hora precargados; arrastrar un bloque propone reprogramar con confirmación.
- **Semana:** columnas por día, filas por hora, bloques compactos (cliente + ícono de estado); filtro de barbero obligatorio si hay más de 3.
- **Historial:** `Table` con Desde/Hasta, `Pagination variant='more'` (25).
- **Detalle de cita** (panel lateral derecho de 400 px, no modal): cliente con teléfono y WhatsApp, servicio, barbero, horario, precio, notas, historial de cambios. Acciones según estado:
  - Pendiente → Confirmar · Cancelar
  - Confirmada → Iniciar (En progreso) · No asistió · Cancelar
  - En progreso → Completar
  - Completada / Cancelada / No asistió → solo lectura
- **Nueva cita:** `Modal` con barbero, servicio, fecha, `SlotGrid` de horas libres, cliente (búsqueda por nombre, correo o teléfono con «Crear cliente nuevo» al final), precio final precargado y editable, notas.

### Barberos, Servicios, Clientes, Usuarios

- Tabla + `Modal size='lg'`. Barbero: foto con subir/arrastrar, biografía, años, especialidades con chips, servicios que presta (mín. 1, con precio especial opcional), **Horario semanal** (fila por día de lunes a domingo con `Switch` «Trabaja» + selectores de hora inicio/fin + intervalo), **Días libres** (fecha o rango + motivo).
- Servicio: nombre, descripción, tipo (`Select` con ícono), duración (10–240 min, pasos de 5), precio en COP con máscara `$` y miles, foto.
- Clientes: fila tocable abre **ficha del cliente** (panel lateral): datos, total de citas, gasto total, barbero preferido, última visita, historial, notificaciones activas sí/no.
- Usuarios: rol con `Select`; si el rol es Barbero, `Select` «Barbero vinculado» con los barberos sin cuenta (reemplaza el UUID).

### Disponibilidad

- Filtros barbero / servicio / fecha; `SlotGrid mode='admin'` con leyenda de 4 estados; tocar un slot libre permite «Bloquear» con motivo; uno bloqueado, «Desbloquear».
- El antiguo monitor «Slots / Redis» se integra aquí como pestaña **Reservas en curso**: tabla con cliente, horario apartado, «Se libera en 3:12» y acción «Liberar ahora»; KPIs «En curso», «Por liberarse (< 1 min)», «Liberados hoy».

### Mi negocio

- Formulario en tarjetas: Identidad (nombre, slogan, descripción, portada), Contacto (teléfono, WhatsApp, correo, sitio web), **Ubicación** (búsqueda de dirección + mapa con pin arrastrable; lat/long solo lectura), Horario (apertura/cierre con selector, días de descanso con chips L M M J V S D), `Switch` «Barbería activa». Vista previa de cómo se ve en la app.

## Problemas conocidos → solución

| Problema | Solución |
|---|---|
| Tres dorados, dos tipografías, radios distintos | Un solo `brass`, Gloock + Instrument Sans, una escala de radios |
| Textos sin tildes / en inglés | Sección Copy en español; días con `Intl` es-CO |
| UUID de barbero a mano | `Select` «Barbero vinculado» |
| Foto por URL | Subir / tomar foto con recorte cuadrado |
| Especialidades separadas por coma | `Chip` de entrada |
| Hora en texto «HH:mm» | Selectores de hora (`showTimePicker` / input time) |
| Latitud/longitud numéricas | Búsqueda de dirección + pin en mapa |
| Dashboard móvil con datos internos | Inicio del cliente orientado a reservar |
| «Key Redis» y jerga técnica | «Reservas en curso» con lenguaje de negocio |
| «CONTINUAR» en mayúsculas | Tipo oración en todos los botones |
| Leyenda que depende del color | Ícono + palabra en cada estado |
