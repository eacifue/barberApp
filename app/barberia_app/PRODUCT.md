# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

> App Flutter que se publica en iOS y Android con **un solo diseño de marca** (Material 3 personalizado con los tokens de `DESIGN.md`, íconos Lucide). No se cambia a Cupertino en iOS: de cada sistema solo se respetan los gestos (atrás por deslizamiento, botón atrás de Android), las áreas seguras, los selectores y diálogos de permisos nativos, y el tamaño de texto del sistema.

## Users

Registro compartido del producto: [`../../PRODUCT.md`](../../PRODUCT.md). Usuarios, propósito, posicionamiento, restricciones, marca y principios se leen de ese archivo; aquí solo va lo propio de la app.

- **Cliente**: usuario principal de la app. Reserva, consulta Mis citas, reprograma, cancela y califica.
- **Admin / Admin Barbería**: entran a «Administrar barbería» desde Perfil, en pantalla completa fuera del shell.
- **Barbero**: la pestaña Reservar se reemplaza por «Mi agenda» (pendiente de diseño).

## Operating Context

- Navegación inferior de 4 destinos: Inicio · Reservar · Mis citas · Perfil. Se oculta en los pasos 2–4 de la reserva.
- Notificaciones push (FCM). El permiso se pide con un botón propio en el onboarding antes del diálogo del sistema.
- Ancho de referencia 360–430 (lienzos a 390 × 844).

## Capabilities and Constraints

- Flutter ≥ 3.27, Riverpod, go_router, `flutter_svg`, `intl` con locale `es_CO`.
- Tema claro y oscuro según el sistema.
