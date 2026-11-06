---
name: BarberShop Medellín
description: Barbería clásica premium, cercana y rápida de usar. Un sistema para la app Flutter y el panel React.
colors:
  bg: "#F6F2EA"
  surface: "#FFFDF8"
  surface-raised: "#FFFFFF"
  surface-sunken: "#EEE8DC"
  line: "#E3DACB"
  line-strong: "#8C8172"
  ink: "#1C1814"
  ink-muted: "#675D52"
  ink-disabled: "#A99F92"
  brass: "#C6A15B"
  brass-strong: "#B08A45"
  on-brass: "#1C1814"
  brass-ink: "#7A5C24"
  brass-soft: "#F2E7D0"
  oxblood: "#7B2D26"
  oxblood-soft: "#F4E3E0"
  carbon: "#1C1814"
  ivory: "#F6F2EA"
  inverse: "#1C1814"
  on-inverse: "#F4EEE4"
  success: "#1A6E44"
  success-bg: "#E2F2E8"
  warning: "#A8460B"
  warning-bg: "#FCEBDD"
  danger: "#B42318"
  danger-bg: "#FCE7E5"
  on-danger: "#FFFFFF"
  info: "#1F5FAD"
  info-bg: "#E3EDF9"
  neutral: "#675D52"
  neutral-bg: "#ECE6DA"
  chart-1: "#A87A24"
  chart-2: "#3A6FB8"
  chart-3: "#B5503C"
  chart-4: "#8A5BB0"
  chart-5: "#2F8A5A"
typography:
  display-lg:
    fontFamily: "Gloock, Iowan Old Style, Palatino, Georgia, serif"
    fontSize: "40px"
    fontWeight: 400
    lineHeight: "44px"
    letterSpacing: "-0.01em"
  display:
    fontFamily: "Gloock, Iowan Old Style, Palatino, Georgia, serif"
    fontSize: "32px"
    fontWeight: 400
    lineHeight: "36px"
  title-lg:
    fontFamily: "Gloock, Iowan Old Style, Palatino, Georgia, serif"
    fontSize: "24px"
    fontWeight: 400
    lineHeight: "30px"
  kpi:
    fontFamily: "Gloock, Iowan Old Style, Palatino, Georgia, serif"
    fontSize: "36px"
    fontWeight: 400
    lineHeight: "40px"
    letterSpacing: "-0.01em"
    fontFeature: "tnum"
  title:
    fontFamily: "Instrument Sans, Segoe UI, Roboto, system-ui, sans-serif"
    fontSize: "20px"
    fontWeight: 600
    lineHeight: "26px"
  title-sm:
    fontFamily: "Instrument Sans, Segoe UI, Roboto, system-ui, sans-serif"
    fontSize: "17px"
    fontWeight: 600
    lineHeight: "24px"
  body-lg:
    fontFamily: "Instrument Sans, Segoe UI, Roboto, system-ui, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: "24px"
  body:
    fontFamily: "Instrument Sans, Segoe UI, Roboto, system-ui, sans-serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: "20px"
  label:
    fontFamily: "Instrument Sans, Segoe UI, Roboto, system-ui, sans-serif"
    fontSize: "15px"
    fontWeight: 600
    lineHeight: "20px"
  label-sm:
    fontFamily: "Instrument Sans, Segoe UI, Roboto, system-ui, sans-serif"
    fontSize: "13px"
    fontWeight: 600
    lineHeight: "16px"
  caption:
    fontFamily: "Instrument Sans, Segoe UI, Roboto, system-ui, sans-serif"
    fontSize: "12px"
    fontWeight: 500
    lineHeight: "16px"
  overline:
    fontFamily: "Instrument Sans, Segoe UI, Roboto, system-ui, sans-serif"
    fontSize: "11px"
    fontWeight: 600
    lineHeight: "16px"
    letterSpacing: "0.08em"
  numeric:
    fontFamily: "Instrument Sans, Segoe UI, Roboto, system-ui, sans-serif"
    fontSize: "28px"
    fontWeight: 600
    lineHeight: "32px"
    letterSpacing: "-0.01em"
    fontFeature: "tnum"
rounded:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "24px"
  full: "9999px"
spacing:
  "0-5": "2px"
  "1": "4px"
  "2": "8px"
  "3": "12px"
  "4": "16px"
  "5": "20px"
  "6": "24px"
  "8": "32px"
  "10": "40px"
  "12": "48px"
  "16": "64px"
components:
  button-primary:
    backgroundColor: "{colors.brass}"
    textColor: "{colors.on-brass}"
    typography: "{typography.label}"
    rounded: "{rounded.sm}"
    padding: "0 20px"
    height: "44px"
  button-primary-hover:
    backgroundColor: "{colors.brass-strong}"
    textColor: "{colors.on-brass}"
  button-primary-lg:
    backgroundColor: "{colors.brass}"
    textColor: "{colors.on-brass}"
    typography: "{typography.label}"
    rounded: "{rounded.sm}"
    height: "52px"
  button-secondary:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    typography: "{typography.label}"
    rounded: "{rounded.sm}"
    height: "44px"
  button-ghost:
    textColor: "{colors.brass-ink}"
    typography: "{typography.label}"
    rounded: "{rounded.sm}"
    height: "44px"
  button-danger:
    backgroundColor: "{colors.danger}"
    textColor: "{colors.on-danger}"
    typography: "{typography.label}"
    rounded: "{rounded.sm}"
    height: "44px"
  input:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    typography: "{typography.body-lg}"
    rounded: "{rounded.sm}"
    height: "44px"
  card:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    rounded: "{rounded.md}"
    padding: "16px"
  card-selected:
    backgroundColor: "{colors.brass-soft}"
    textColor: "{colors.ink}"
    rounded: "{rounded.md}"
    padding: "16px"
  chip:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    typography: "{typography.label-sm}"
    rounded: "{rounded.full}"
    height: "36px"
  chip-selected:
    backgroundColor: "{colors.brass-soft}"
    textColor: "{colors.ink}"
    typography: "{typography.label-sm}"
    rounded: "{rounded.full}"
  slot-selected:
    backgroundColor: "{colors.brass}"
    textColor: "{colors.on-brass}"
    typography: "{typography.label}"
    rounded: "{rounded.sm}"
    height: "44px"
  badge:
    typography: "{typography.label-sm}"
    rounded: "{rounded.xs}"
    padding: "2px 8px"
  modal:
    backgroundColor: "{colors.surface-raised}"
    rounded: "{rounded.lg}"
    padding: "24px"
  toast:
    backgroundColor: "{colors.inverse}"
    textColor: "{colors.on-inverse}"
    rounded: "{rounded.lg}"
---

# Design System: BarberShop Medellín

> Fuente de verdad: `design/` (tokens en `design/tokens/tokens.json` y `tokens.css`, fichas en `design/docs/componentes/`, pantallas en `design/pantallas/`). Este archivo resume ese paquete para quien implemente; si algo difiere, manda `design/`. El frontmatter lleva los valores del **tema claro**; los del oscuro están en `design/tokens/tokens.css` bajo `[data-theme="dark"]` y en `.impeccable/design.json`.

## Overview

**Creative North Star: "Latón y Portal"**

Una barbería clásica de barrio con oficio: puerta en arco, poste de barbero, latón pulido, sillas de cuero, papel marfil. La interfaz es neutra y cálida (marfil y carbón) y un solo dorado, el latón, marca lo que se elige o se activa. El granate del poste aparece muy poco, como firma. Clásica en la tipografía (Gloock, letrero de vitrina) y moderna en la interacción (Instrument Sans, controles grandes, respuesta inmediata).

Es una interfaz de trabajo: rápido antes que bonito. El cliente reserva en menos de un minuto y recepción ve el día y actúa en un toque. Cada pantalla tiene una acción principal. La densidad es cómoda en el móvil (lectura a 16 px) y compacta en el panel (lectura a 14 px, tablas densas), con los mismos tokens y nombres en las dos plataformas.

Lo que se descartó: los tres dorados anteriores (`#8B6F47` bronce, `#B8860B` gold), el efecto vidrio, los paneles semitransparentes, los degradados de fondo, Inter, Material Icons y el emblema de tijeras cruzadas.

**Key Characteristics:**
- Marfil y carbón cálidos, un solo dorado (`brass`) como relleno de selección y acción.
- Gloock solo en títulos y cifras; Instrument Sans en todo lo que se lee o se toca.
- Tarjetas planas separadas por hairlines; sombra solo en lo que flota.
- Estado = color + ícono + palabra, siempre.
- Claro y oscuro de primera clase en las dos plataformas.

## Colors

Neutros cálidos de papel y tinta, un latón protagonista y un granate escaso; los colores de estado solo aparecen cuando significan algo.

### Primary
- **Latón pulido** (`brass`): relleno del botón primario, slot y día elegidos, paso activo, pestaña activa, progreso y logo. El texto encima siempre es `on-brass` (carbón), nunca blanco. No sirve como texto ni como ícono sobre superficies claras (2,2:1).
- **Latón hundido** (`brass-strong`): hover y pressed de cualquier relleno `brass`.
- **Tinta de latón** (`brass-ink`): latón cuando es texto o ícono (enlaces, precio destacado, ítem activo del sidebar, foco). ≥ 5:1 en las superficies claras; en oscuro se aclara.
- **Latón lavado** (`brass-soft`): fondo tintado de lo seleccionado (chip, tarjeta, ítem del sidebar, badge Completada).

### Secondary
- **Granate de poste** (`oxblood`, fondo `oxblood-soft`): acento escaso. Etiqueta Popular, línea de «ahora» en la agenda, punto de notificación. **No significa error.**

### Neutral
- **Marfil** (`bg`): fondo de pantalla y de página.
- **Papel** (`surface`): tarjetas, tablas, sidebar, topbar, barra inferior.
- **Papel claro** (`surface-raised`): capas flotantes (modales, sheets, menús), siempre con sombra.
- **Papel hundido** (`surface-sunken`): cabecera de tabla, pista del control segmentado, base del skeleton, hover de filas.
- **Hilo** (`line`): hairlines decorativas y bordes de tarjeta. No sirve como borde de control.
- **Hilo marcado** (`line-strong`): borde de inputs, selects, botón secundario, chip sin elegir y slot disponible (≥ 3:1).
- **Tinta** (`ink`), **tinta suave** (`ink-muted`), **tinta apagada** (`ink-disabled`): texto principal, secundario (≥ 4,5:1 en las cuatro superficies) y deshabilitado (solo lo que no hace falta leer).
- **Carbón** y **marfil de marca** (`carbon`, `ivory`): constantes que no cambian con el tema. Se usan en el splash, el ícono de app y el panel de marca del login.

### Semánticos y estados
- `success`, `warning` (naranja, deliberadamente lejos del latón), `danger`, `info` y `neutral`, cada uno con su `-bg`.
- Estados de cita (alias): Pendiente → warning · Confirmada → success · En progreso → info · Completada → brass-ink sobre brass-soft · Cancelada → danger · No asistió → neutral.
- Slots (alias): disponible → success · ocupado → neutral · bloqueado → warning · reservando → info.
- Gráficas: `chart-1` … `chart-5` en ese orden fijo; a partir de 6 series se agrupan en «Otros».

### Named Rules
**The One Brass Rule.** Hay un solo dorado. Cualquier `#B8860B`, `#8B6F47`, degradado dorado o latón usado como color de texto sobre claro es un error.

**The Never White On Brass Rule.** Sobre un relleno latón el texto y los íconos son `on-brass` (carbón), en los dos temas.

**The Color Plus Word Rule.** Ningún estado se comunica solo con color: lleva ícono y etiqueta. Leyendas, badges, slots y tendencias de KPI incluidos.

## Typography

**Display Font:** Gloock (con Iowan Old Style, Palatino, Georgia)
**Body Font:** Instrument Sans variable 400–700 (con Segoe UI, Roboto, system-ui)

**Character:** Un serif de alto contraste con aire de letrero de vitrina, frente a una grotesca cálida y de ancho variable que aguanta tablas densas. El serif da la ceremonia y el sans hace el trabajo.

### Hierarchy
- **Display lg** (Gloock 400, 40/44): pantalla de éxito, splash y título principal del dashboard web.
- **Display** (Gloock 400, 32/36): título de pantalla en móvil y de página en web.
- **Title lg** (Gloock 400, 24/30): título de modal, nombre del barbero en su perfil.
- **KPI** (Gloock 400, 36/40, tnum): cifra de tarjeta KPI e importes destacados.
- **Title** (Sans 600, 20/26): encabezado de sección.
- **Title sm** (Sans 600, 17/24): título de tarjeta (servicio, barbero, cita).
- **Body lg** (Sans 400, 16/24): lectura en móvil; tamaño mínimo de todo input.
- **Body** (Sans 400, 14/20): texto por defecto del panel (celdas, formularios, listas).
- **Label** (Sans 600, 15/20): botones, pestañas, navegación.
- **Label sm** (Sans 600, 13/16): badges, chips, etiquetas de campo, encabezados de columna.
- **Caption** (Sans 500, 12/16): metadatos, ayudas, leyendas.
- **Overline** (Sans 600, 11/16, 0.08em, MAYÚSCULAS): rótulos de resumen (SERVICIO, FECHA Y HORA). Es la única mayúscula del sistema.
- **Numeric** (Sans 600, 28/32, tnum): cuenta regresiva y horas grandes.

### Named Rules
**The Sign Painter Rule.** Gloock solo en títulos de pantalla, nombre del barbero en su perfil y cifras protagonistas. Nunca en párrafos, botones, tablas ni formularios.

**The Tabular Money Rule.** Precios, horas, contadores y columnas numéricas usan cifras tabulares (`tabular-nums` / `FontFeature.tabularFigures()`).

**The Sentence Case Rule.** Botones, pestañas y títulos en tipo oración. «Continuar», nunca «CONTINUAR».

## Layout

- Escala base 4 (`space-1` … `space-16`). Padding de tarjeta 16; entre tarjetas de lista 12; entre secciones 24 en móvil y 32 en web.
- **Móvil (360–430):** margen lateral 16, una columna. El CTA principal va en una barra inferior fija con botón de 52 px. `BottomNav` de 72 px más el área segura.
- **Web:** sidebar fijo de 264 px y topbar de 64 px desde 1280. Por debajo de 1280 el sidebar pasa a drawer; por debajo de 768 aparece la `BottomNav` flotante y las tablas se muestran como tarjetas. El dashboard tiene un ancho máximo de 1200 px.
- Breakpoints: 390 · 768 · 1280 · 1440.
- Objetivo táctil mínimo de 44 px en todo lo que se toca, incluidos íconos, días del calendario y slots.
- Detalles de cita y ficha de cliente en un panel lateral de 400 px, no en modal: la agenda sigue visible.

## Elevation & Depth

Plano por capas tonales: la profundidad sale del paso de superficie (`bg` → `surface` → `surface-raised`, y `surface-sunken` hacia abajo) y de las hairlines `line`. La sombra solo aparece en lo que flota sobre el contenido.

### Shadow Vocabulary
- **Apoyo** (`shadow-sm`, claro `0 1px 2px #1C18140F`): barra de acción inferior fija y bloque arrastrado en la agenda.
- **Menú** (`shadow-md`, claro `0 4px 12px #1C181414, 0 1px 3px #1C18140F`): menús, selects abiertos, popovers y barra flotante del web móvil.
- **Capa** (`shadow-lg`, claro `0 12px 32px #1C18141F, 0 2px 6px #1C181414`): modales, diálogos, bottom sheets y snackbars.
- En oscuro las sombras son negras más densas (ver `tokens.css`).

### Named Rules
**The Flat Card Rule.** Las tarjetas no llevan sombra; se separan con `line`.

**The No Glass Rule.** Sin `backdrop-filter`, sin paneles semitransparentes, sin degradados de fondo. El velo detrás de modales es `scrim`.

## Shapes

Una sola escala de radios para las dos plataformas: controles 8 (`sm`), tarjetas, tablas y banners 12 (`md`), modales, menús y snackbars 16 (`lg`), bottom sheet y foto de portada 24 (`xl`), chips, avatares e interruptores en píldora (`full`), badges, celdas de calendario y bloques de agenda 4 (`xs`). El arco del Portal es la única silueta de marca; el patrón de franjas del poste (latón y granate a −35°) sirve para el splash, empaques o la vitrina, nunca como fondo de pantallas de trabajo.

### Named Rules
**The Selected State Rule.** Seleccionado = fondo `brass-soft` + borde `brass-ink` de 2 px + check en latón. Nunca una barra de color en el borde izquierdo.

## Components

Táctiles y seguros: controles altos, bordes visibles, respuesta inmediata (120 ms) y sin rebote. Las fichas completas (props, estados, equivalente Flutter) están en `design/docs/componentes/`. La implementación de referencia web es `design/web/referencia-componentes/bundle.js`.

### Buttons
- **Shape:** esquinas suaves (8 px). Alturas 36 / 44 / 52 (`sm` / `md` / `lg`).
- **Primary:** relleno `brass`, texto `on-brass`, estilo `label`. Uno solo por pantalla o modal; en móvil el CTA de pantalla es `lg` a ancho completo en la barra fija.
- **Secondary:** fondo `surface`, borde `line-strong`, texto `ink`.
- **Ghost:** solo texto en `brass-ink`.
- **Danger / Danger ghost:** lo destructivo va en dos pasos: `danger-ghost` abre un `ConfirmDialog` y el `danger` relleno solo vive dentro del diálogo.
- **Hover / Focus:** hover un paso de superficie o `brass-strong`; foco web `focus-ring` (2 px del fondo + 2 px de `focus`), nunca se quita. `loading` muestra la etiqueta en gerundio («Reservando…») y bloquea el doble toque.

### Chips
- **Style:** píldora, borde `line-strong`, texto `label-sm`.
- **State:** elegido en `brass-soft` + borde `brass-ink` + check. «Todos» va primero en los filtros.

### Cards / Containers
- **Corner Style:** 12 px.
- **Background:** `surface` sobre `bg`.
- **Shadow Strategy:** ninguna (The Flat Card Rule).
- **Border:** `line` de 1 px.
- **Internal Padding:** 16 px.
- Firma: `ServiceCard` con cuadro `brass-soft` de 48 px y el ícono del tipo en `brass-ink` (Corte `scissors`, Afeitado `navaja`, Barba `barba`, Tinte `droplets`, Tratamiento `sparkles`, Combo `layers`, Otro `ellipsis`).

### Inputs / Fields
- **Style:** fondo `surface`, borde `line-strong`, radio 8 px, 44 px de alto, texto a 16 px. Etiqueta siempre visible encima.
- **Focus:** borde `brass-ink` y `focus-ring` en web.
- **Error / Disabled:** error debajo del campo en `danger`, en dos partes (qué pasó + qué hacer); deshabilitado en `surface-sunken` + `ink-disabled`.

### Navigation
- **Móvil:** `BottomNav` de 4 destinos (Inicio · Reservar · Mis citas · Perfil); el activo con indicador en píldora `brass` e ícono `on-brass`.
- **Web:** `Sidebar` en `surface`; ítem activo en `brass-soft` con texto `brass-ink`; contador de pendientes. `Topbar` con el título de página en Gloock 24 y selector de tema claro / oscuro / sistema.

### Status Badge
Radio de 4 px, texto `label-sm`, color del estado sobre su `-bg`, con ícono Lucide: Pendiente `hourglass`, Confirmada `circle-check`, En progreso `scissors`, Completada `check-check`, Cancelada `circle-x`, No asistió `user-x`. En la agenda el borde también codifica el estado: punteado, sólido, doble, ninguno, o rayado y tachado.

### Countdown (horario apartado)
Cifra `numeric` tabular, «Horario apartado por 4:32». Bajo 60 s pasa a `warning` y se anuncia una vez. Sigue corriendo con «reducir movimiento».

### Iconography
Lucide en las dos plataformas (trazo 2 px, puntas redondeadas) a 16 / 20 / 24 px, más `navaja` y `barba` propios con la misma gramática (`design/assets/iconos/`). Sin emoji.

### Motion
120 ms para hover y selección, 200 ms para pestañas y menús, 320 ms para modales, sheets y cambio de paso. Curvas `ease-standard` `cubic-bezier(0.2, 0, 0, 1)`, `ease-enter` y `ease-exit`. Una sola celebración: el check en latón de «Reserva confirmada» (900 ms, sin bucle). Con «reducir movimiento» solo hay cambios de opacidad.

## Do's and Don'ts

### Do:
- **Do** usar `brass` solo como relleno y `brass-ink` cuando el latón es texto o ícono.
- **Do** dar a cada estado de cita su token `status-*`, su ícono y su palabra.
- **Do** escribir el copy en es-CO con tildes: `$45.000`, `3:30 p. m.`, `jueves 12 de noviembre`, semana desde el lunes (`design/docs/03-copy.md`).
- **Do** definir los estados de carga (Skeleton tras 300 ms), vacío (EmptyState con siguiente paso), error (Banner o Toast con «Reintentar») y deshabilitado en cada pantalla.
- **Do** mantener los objetivos táctiles ≥ 44 px y el foco visible en web.
- **Do** probar cada pantalla en claro y en oscuro, y con el texto del sistema al 130 %.

### Don't:
- **Don't** usar `gold #B8860B`, `#8B6F47`, degradados dorados ni un segundo dorado.
- **Don't** usar efecto vidrio, paneles semitransparentes ni degradados de fondo.
- **Don't** poner texto blanco sobre latón.
- **Don't** usar Gloock en botones, tablas, formularios ni párrafos.
- **Don't** poner sombra en las tarjetas ni una barra de color en el borde izquierdo para marcar la selección.
- **Don't** usar `oxblood` para errores; el error es `danger`.
- **Don't** usar MAYÚSCULAS en botones o pestañas, «Aceptar», «OK» ni «Enviar».
- **Don't** usar emoji ni Material Icons; los íconos son Lucide.
- **Don't** inventar datos del negocio: portada, slogan, dirección, teléfono y correo van como marcadores entre corchetes.
