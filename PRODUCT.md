# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

> Este registro es el compartido del producto y su plataforma corresponde al **panel web** (`frontend/barberia-admin`). La app móvil (`app/barberia_app`) tiene su propio `PRODUCT.md` con plataforma `adaptive`, que remite a este archivo para todo lo demás.

## Users

- **Cliente** (app móvil, iOS y Android). Reserva desde el celular, normalmente fuera del local, y quiere hacerlo en menos de un minuto viendo precio, duración y barbero con foto y calificación. Después consulta, reprograma o cancela sus citas y recibe recordatorios.
- **Recepción** (panel web). Es el usuario diario del panel: trabaja en el computador del mostrador, a veces desde el celular, con clientes delante o al teléfono. Su trabajo es ver la agenda del día, confirmar, iniciar, completar o marcar «No asistió», y crear citas para quien llama o llega sin reserva.
- **Administración** (panel web y sección admin de la app; roles `Admin` y `AdministradorBarberia`). Gestiona equipo, servicios, clientes, usuarios, disponibilidad y datos del negocio, y revisa el Dashboard. Uso menos frecuente que recepción.
- **Barbero** (rol `Barbero`). Consulta y actualiza sus propias citas. Su vista dedicada («Mis citas» en el panel, «Mi agenda» en la app) está pendiente de diseño.

## Product Purpose

BarberShop Medellín es la plataforma propia de reservas y gestión de la barbería: los clientes reservan en 4 pasos (servicio → barbero → fecha y hora → confirmar) y el negocio opera su agenda diaria desde el panel. El éxito es que el cliente reserve sin llamar, que no haya dobles reservas y que recepción resuelva cada cita en un toque.

## Positioning

Es la herramienta de una barbería concreta con marca propia, no un marketplace ni un SaaS genérico. El horario elegido se aparta 5 minutos en el servidor mientras el cliente confirma, lo que evita dobles reservas entre la app y el mostrador. Reprogramar conserva servicio y barbero y entra directo a elegir otro horario.

## Operating Context

- Cliente: celular, una mano, a menudo con prisa; recibe notificaciones push (Firebase) sobre confirmación, recordatorio y cancelación.
- Recepción: computador de mostrador con la agenda abierta todo el día; interrupciones constantes; necesita pasar de una cita a otra sin perder la vista del día (detalle en panel lateral, no en modal).
- Pago siempre en el local; no hay pagos en línea.
- Idioma único: español de Colombia, tuteo; moneda COP.

## Capabilities and Constraints

- Backend .NET (ASP.NET Core) + PostgreSQL + Redis + FCM, compartido por app y panel. El rediseño no cambia la API salvo donde se marque explícitamente.
- Estados de cita: `Pendiente`, `Confirmada`, `EnProgreso`, `Completada`, `Cancelada`, `NoShow`.
- Roles: `Cliente`, `Barbero`, `AdministradorBarberia` («Admin Barbería»), `Admin` («Administrador»).
- Tipos de servicio: Corte, Afeitado, Barba, Tinte, Tratamiento, Combo, Otro.
- Desactivar en vez de eliminar barberos, clientes y usuarios.
- **Sedes:** la marca tendrá varias sedes. Hoy el código opera con una sola (se retiró `barberiaId` de barberos, servicios y clientes) y los diseños de `design/` asumen una única barbería («Mi negocio»). **Pendiente de decidir:** cómo se elige o cambia de sede en la app y en el panel, y qué datos son por sede (agenda, barberos, horario, dirección).
- **Pendiente de backend por confirmar:** calificaciones y reseñas, filtros del historial de la agenda, métricas de la ficha de cliente (gasto total, barbero preferido), recuperación de contraseña.

## Brand Commitments

- Nombre: **BarberShop Medellín**. Logo «el Portal» (arco con poste de barbero) en `design/assets/logos/`.
- Voz: cercana y directa, tuteo, tipo oración, verbos concretos en botones, sin emoji ni jerga técnica. Glosario y formatos obligatorios en `design/docs/03-copy.md` (`$45.000`, `3:30 p. m.`, semana desde el lunes).
- El sistema de diseño en `design/` es la fuente de verdad visual para las dos plataformas (ver `DESIGN.md`).

## Evidence on Hand

- Paquete de diseño completo en `design/`: tokens, temas Flutter y web, 33 fichas de componentes, 34 pantallas de app y 29 de panel (`design/pantallas/`), copy por pantalla.
- Brief de producto original: `docs/CLAUDE_DESIGN_BRIEF.md`.
- **No existen todavía** y no se inventan: foto de portada, slogan, dirección, teléfono y correo reales del negocio (van como marcadores `[Foto de portada]`, `[Slogan]`, `[Dirección]`, `[Teléfono]`, `[Correo]`), reseñas reales ni cifras de uso.

## Product Principles

1. **Reservar en menos de un minuto.** Cada pantalla tiene una sola acción principal; lo elegido siempre está a la vista.
2. **Recepción actúa en un toque.** La agenda del día es el centro del panel y no se tapa para ver o cambiar una cita.
3. **El horario apartado es una promesa.** El cliente siempre sabe cuánto tiempo le queda y qué pasa si se vence.
4. **Nada se comunica solo con color.** Todo estado lleva color, ícono y palabra.
5. **Lenguaje del negocio, no del sistema.** «Reservas en curso», no «Slots / Redis»; «Barbero vinculado», no un UUID.

## Accessibility & Inclusion

- Contraste WCAG AA en tema claro y oscuro; bordes de control, foco e íconos con significado ≥ 3:1.
- Objetivos táctiles ≥ 44 px; foco de teclado visible en web.
- Textos del sistema al 130 % sin cortar; inputs a 16 px.
- «Reducir movimiento»: solo cambios de opacidad; la cuenta regresiva sigue.
