# Pantallas diseñadas

Diseños construidos con este sistema (componentes reales de `window.BSM`, tokens y fuentes de aquí). Cada pantalla tiene un ajuste **dark** para verla en tema oscuro.

## App móvil

Lienzo: [BarberShop Medellín — App móvil](https://claude.ai/artifact/3Bqo2YR636vVxHF5qFCatd). Pantallas de 390 × 844 (las de scroll largo se muestran completas). Prototipo navegable con Play: Onboarding → Iniciar sesión → Inicio → Reservar (4 pasos) → Ver mis citas → detalle → Reprogramar / Cancelar.

| Pantalla | Estados incluidos | Componentes |
|---|---|---|
| Splash | — | `Logo` emblema sobre `carbon` |
| Onboarding (3) | reserva en 4 pasos, horario apartado, permiso de notificaciones | `Stepper`, `ServiceCard`, `SlotGrid`, `Countdown`, `Toast` como ilustración |
| Iniciar sesión | normal, credenciales incorrectas | `Logo`, `Input` (con mostrar/ocultar), `Banner` |
| Crear cuenta | normal, validación por campo | `Input` |
| Inicio | con próxima cita, sin citas | `AppointmentCard`, `ServiceCard`, `Avatar`, `Rating`, `Badge`, `Button`, `BottomNav` |
| 1 · ¿Qué servicio deseas? | normal, error al cargar | `Stepper`, `Chip`, `ServiceCard`, `EmptyState`, `BottomNav` |
| 2 · Elige tu barbero | seleccionado, no disponible («Vuelve el lunes») | `Banner`, `BarberCard` |
| 3 · Elige fecha y hora | horario apartado, último minuto, cargando, día sin horarios, tiempo expirado | `Calendar`, `SlotGrid`, `Countdown`, `Skeleton`, `ConfirmDialog` |
| 4 · Confirma tu reserva | normal, reprogramación, salir sin reservar | `Countdown`, `Banner`, `Input`, `ConfirmDialog` |
| Reserva confirmada | — | `Button` |
| Mis citas | próximas, historial, sin citas | `Tabs`, `AppointmentCard`, `EmptyState` |
| Detalle de la cita | confirmada, cancelar cita | `StatusBadge`, `Rating`, `ConfirmDialog` |
| Calificar servicio | completada sin reseña | `Avatar`, estrellas de 48 px, `Input` |

Decisiones que fijan estos diseños:

- La barra fija inferior de los pasos 1–3 resume lo elegido («Jue 12 nov · 3:00 p. m.») y lleva «Continuar»; en el paso 4 solo «Reservar ahora».
- La cuenta regresiva vive pegada a la barra inferior en el paso 3 y arriba del resumen en el paso 4.
- En Próximas la tarjeta abre el detalle; Reprogramar y Cancelar viven en el detalle.
- Reprogramar desde el detalle entra directo al paso 3 con servicio y barbero precargados.
- El mapa del detalle es un marcador de posición hasta integrar el proveedor de mapas.
- Onboarding: ilustraciones hechas con componentes reales (no fotos ni dibujos); el permiso de notificaciones se pide con un botón propio antes del diálogo del sistema y «Ahora no» no vuelve a preguntar hasta la primera reserva.
- Login y registro: errores debajo de cada campo; el aviso general (`Banner danger`) solo cuando el servidor rechaza las credenciales. Al crear cuenta se pasa al onboarding.
- Inicio: saludo, próxima cita con «Cómo llegar» y «Ver detalle», servicios populares, barberos y la barbería (horario de hoy, dirección, Llamar, WhatsApp, Cómo llegar). Portada, slogan y dirección exacta son marcadores hasta tener los datos reales de Mi negocio.

## Panel web

Lienzo: [BarberShop Medellín — Panel web](https://claude.ai/artifact/X2AQUSnbHDbUzEjPfrebWD). Páginas fluidas a 1440 px más versiones de celular a 390 px. Prototipo con Play: Día / Semana / Historial, tocar la cita de las 11:30 a. m. de Juan Pablo Ríos abre el detalle, «Nueva cita» abre el formulario. En Gestión: Clientes → ficha de Andrés Gómez → «Nueva cita para Andrés»; Usuarios → «Nuevo usuario»; Disponibilidad cambia entre «Horarios del día» y «Reservas en curso». La sesión de ejemplo es de un **Administrador** (Camila Arango), por eso el menú muestra la sección Administración.

| Pantalla | Estados incluidos | Componentes |
|---|---|---|
| Agenda · Día | 4 barberos, línea de ahora, aviso de pendientes, filtros por estado | `Sidebar`, `Topbar`, `Chip`, `Banner`, `AgendaBoard` |
| Agenda · Detalle | panel lateral de 400 px con acciones según estado | `Avatar`, `StatusBadge`, `Button`, `IconButton` |
| Agenda · Nueva cita | barbero, servicio, fecha, horas libres, búsqueda de cliente, precio | `Modal`, `Select`, `Input`, `SlotGrid` |
| Agenda · Semana | un barbero, 7 días, domingo cerrado, hoy resaltado | `AgendaBoard` (columnas por día) |
| Agenda · Historial | filtros por fechas, barbero, estado y cliente; Cargar más | `Input`, `Select`, `StatusBadge`, `Pagination` |
| Dashboard | 4 KPI, ingresos por día, ocupación por barbero, servicios más vendidos, cancelaciones y no asistencias, próximas citas, calendario | `StatCard`, `Calendar`, `StatusBadge` + gráficas en marcado con `chart-1`/`chart-2` |
| Celular · Agenda y Dashboard | un barbero a la vez, KPI en carrusel, barra flotante | `Topbar compact`, `BottomNav floating` |
| Login del panel | normal, credenciales incorrectas, oscuro, celular | `Logo` sobre `carbon`, `Input`, `Tabs` (tema), `Banner` |
| Barberos | tabla con calificación, citas de hoy y estado (disponible, capacitación, vacaciones, inactivo); editar barbero | `Avatar`, `Rating`, `Badge`, `Modal lg`, `Switch`, `Select`, `Chip` (especialidades) |
| Servicios | filtro por tipo, tabla, editar servicio con vista previa en la app | `Chip`, `Badge`, `Modal`, `Select`, `Switch`, `ServiceCard` |
| Clientes | búsqueda, filtro por estado, paginación, ficha lateral (citas, gasto total, barbero preferido, próxima cita, historial), celular | `Input`, `Select`, `Badge`, `Pagination`, `StatusBadge`, `BottomNav floating` |
| Usuarios | cuentas del equipo por rol, nuevo usuario con selector de barbero | `Chip`, `Badge`, `Modal`, `Input revealable`, `Select`, `Banner` |
| Mi negocio | identidad, contacto, ubicación con mapa, horario y días de descanso, estado; vista previa de la tarjeta de Inicio; barra de cambios sin guardar | `Input`, `Select`, `Chip`, `Switch`, `Badge`, `Button` |
| Disponibilidad | semana con ocupación por día, horarios del día de un barbero, bloquear horario, bloqueos de hoy | `Select`, `SlotGrid mode="admin"`, `Button`, `IconButton` |
| Disponibilidad · Reservas en curso | horarios apartados por clientes que están reservando, por liberarse, liberados hoy; «Liberar ahora» | `Banner`, `StatCard`, `Avatar`, `Button danger-ghost` |
| Oscuro · Barberos y Mi negocio | tema oscuro de dos pantallas de gestión | los mismos |

Decisiones que fijan estos diseños:

- El detalle de la cita es un panel lateral, no un modal: la agenda sigue visible y se puede pasar de una cita a otra.
- Acciones del detalle por estado: Confirmada → «Iniciar servicio» (primario), «Reprogramar», «No asistió», «Cancelar cita»; Pendiente → «Confirmar»; En progreso → «Completar».
- El aviso de pendientes por confirmar va arriba de la agenda y en el contador del menú.
- Ingresos de hoy se muestran como estimado (citas del día) con lo ya cobrado en la ayuda; la barra de hoy en la gráfica va punteada.
- La vista Semana muestra un solo barbero; en celular la agenda cambia de barbero con chips.
- Gestión: listas como tabla con acciones al final de la fila; editar y crear en modal (barbero en `Modal lg`), la ficha del cliente en panel lateral como el detalle de la cita.
- Usuarios: el «Barbero ID (UUID)» se reemplaza por el selector «Barbero vinculado», que solo lista barberos sin cuenta. Los clientes no se gestionan aquí sino en Clientes.
- Desactivar en vez de eliminar en barberos, clientes y usuarios; la fila queda con `Badge neutral` «Inactivo» y la acción cambia a «Activar».
- Mi negocio: la vista previa repite la tarjeta de la barbería de Inicio en la app; los datos desconocidos (portada, slogan, dirección, teléfono, correo) quedan como marcadores entre corchetes.
- Disponibilidad: cada estado del horario lleva ícono y texto además del color (Disponible, Ocupado con el nombre del cliente, Bloqueado con el motivo, Reservando con el tiempo que queda).
- El monitor técnico «Slots / Redis» pasa a ser la pestaña «Reservas en curso» con lenguaje de negocio: «Reservando ahora», «Por liberarse» (menos de 1 minuto), «Liberados hoy». Sin claves técnicas.
- Los enlaces usan `brass-ink`, que se ajusta en tema oscuro.

## Pendiente de diseño

Perfil del barbero, Perfil del cliente, Recuperar contraseña, Centro de notificaciones, la agenda móvil del barbero y la Administración dentro de la app, según **Patrones de pantalla**.
