BarberShop Medellín es una barbería clásica premium, cercana y rápida de usar. Un solo sistema sirve a la app de clientes (Flutter) y al panel de administración (React + Tailwind): mismos nombres de token, mismos componentes, mismo copy.

## Principios

1. **Latón, carbón y marfil.** Un solo dorado (`brass`). El resto de la interfaz es neutra y cálida; el color de estado solo aparece cuando significa algo.
2. **Rápido antes que bonito.** Reservar en menos de un minuto; en recepción, ver el día y actuar en un toque. Cada pantalla tiene una acción principal.
3. **Clásico en la tipografía, moderno en la interacción.** Gloock para títulos y cifras; Instrument Sans para todo lo que se lee o se toca.
4. **Nada se comunica solo con color.** Estado = color + ícono + palabra.

## Voz y copy

- Español de Colombia, tuteo: «Reserva», «Tu cita», «¿Seguro que deseas…?» → «¿Cancelar esta cita?».
- Tipo oración en todo: botones, pestañas, títulos. Única excepción: el estilo `overline` (FECHA Y HORA) en resúmenes.
- Verbos concretos en botones («Reservar ahora», «Crear cita», «Sí, cancelar cita»); nunca «Aceptar», «OK» ni «Enviar».
- Errores en dos partes: qué pasó + qué hacer («No pudimos cargar los horarios. Revisa tu conexión e inténtalo de nuevo.»).
- Sin emoji en la interfaz. Sin jerga técnica («Key Redis» → «Horario en reserva»).
- Formatos: dinero `$45.000` (punto de miles, sin decimales); hora 12 h `3:30 p. m.`; fecha `jueves 12 de noviembre` / corta `12 nov`; duración `50 min`, `1 h 15 min`; decimales con coma `4,8`.
- Glosario y textos finales por pantalla: sección **Copy en español**.

## Color

- Fondo de pantalla `bg`; tarjetas, tablas, sidebar y barras sobre `surface` con borde `line`; capas flotantes en `surface-raised` + `shadow-lg`; hundidos (cabecera de tabla, pistas, skeleton) en `surface-sunken`.
- Texto en `ink`; secundario en `ink-muted`. Ambos pasan 4.5:1 sobre las cuatro superficies en los dos temas.
- `brass` es relleno: botón primario, slot y día elegidos, pestaña activa, progreso. El texto encima siempre es `on-brass` (carbón), nunca blanco.
- Latón como texto o ícono sobre superficies: `brass-ink`. Fondos tintados de selección: `brass-soft`.
- `oxblood` (granate del poste) es acento escaso: etiqueta Popular, línea de ahora en la agenda, punto de notificación. No significa error.
- Bordes de controles: `line-strong` (≥3:1). `line` es solo decorativo.
- Estados semánticos: `success`, `warning` (naranja, lejos del latón), `danger`, `info`, `neutral`, cada uno con su `-bg`. Estados de cita y de slot son alias de estos (`status-*`, `slot-*`): cambiar un semántico cambia ambos.
- `carbon` e `ivory` no cambian con el tema: splash, ícono de app y panel de marca del login.
- Gráficas: `chart-1` … `chart-5` en ese orden fijo; más de 5 series se agrupan en «Otros».

## Tipografía

- **Gloock** (display, 400): `display-lg`, `display`, `title-lg`, `kpi`. Solo títulos de pantalla, nombre del barbero en su perfil, cifras protagonistas. Nunca en párrafos, botones, tablas ni formularios.
- **Instrument Sans** (variable 400–700): `title`, `title-sm`, `body-lg`, `body`, `label`, `label-sm`, `caption`, `overline`, `numeric`.
- Móvil lee en `body-lg` (16/24); el panel web en `body` (14/20). Inputs siempre a 16 px.
- Precios, horas, contadores y columnas numéricas con cifras tabulares (`font-variant-numeric: tabular-nums`; en Flutter `FontFeature.tabularFigures()`).
- Peso 600 para etiquetas y títulos de tarjeta; 700 solo para el día elegido del calendario y acciones de snackbar.

## Espaciado y layout

- Base 4: `space-1` … `space-16`. Padding de tarjeta `space-4`; entre tarjetas de lista `space-3`; entre secciones `space-6` (móvil) / `space-8` (web).
- Móvil (360–430): margen lateral 16, una columna, CTA principal en barra inferior fija con `control-lg`.
- Web: sidebar `sidebar-width` fijo desde `bp-lg`; drawer + barra flotante por debajo de `bp-md`; contenido de dashboard máx. 1200 px.
- Objetivos táctiles ≥ `touch-min` (44 px) en todo lo que se toca, incluidos íconos, días del calendario y slots.

## Forma, bordes y elevación

- Radios: controles `radius-sm` (8), tarjetas y tablas `radius-md` (12), modales y snackbars `radius-lg` (16), bottom sheet `radius-xl` (24), chips y avatares `radius-full`, badges y bloques de agenda `radius-xs`.
- Las tarjetas no llevan sombra: se separan con `line`. `shadow-md` para menús y la barra flotante; `shadow-lg` para modales, sheets y snackbars. Sin efecto vidrio ni degradados de fondo.
- Seleccionado = fondo `brass-soft` + borde `brass-ink` 2 px + check en latón. Nunca una barra de color en el borde izquierdo.

## Iconografía

- Un solo set en móvil y web: **Lucide** (trazo 2 px, puntas redondeadas), 16 / 20 / 24 px (`icon-sm/md/lg`). Reemplaza Material Icons en Flutter.
- Dos íconos propios con la misma gramática: `navaja` (Afeitado) y `barba` (Barba), en `assets/Iconos`.
- Tipo de servicio → ícono: Corte `scissors`, Afeitado `navaja`, Barba `barba`, Tinte `droplets`, Tratamiento `sparkles`, Combo `layers`, Otro `ellipsis`; sobre un cuadro `brass-soft` de 48 px con el ícono en `brass-ink`.
- Sin emoji como ícono.

## Movimiento

- `duration-fast` (120 ms) para hover y selección; `duration-base` (200 ms) para pestañas y menús; `duration-slow` (320 ms) para modales, sheets y el cambio de paso; `ease-standard`, `ease-enter`, `ease-exit`.
- Celebración única: check animado (Lottie) en «Reserva confirmada», `duration-celebrate`, sin bucle.
- Con «reducir movimiento»: sin shimmer, sin desplazamientos; solo cambios de opacidad. La cuenta regresiva sigue.

## Estados de interacción

- Hover: un paso de superficie (`surface-sunken`) o `brass-strong` en rellenos latón.
- Foco de teclado (web): `focus-ring`, 2 px del fondo + 2 px sólidos de `focus`; nunca se quita.
- Deshabilitado: `surface-sunken` + `ink-disabled`; los slots y días no disponibles además van tachados o sin enfocar.
- Carga: `Skeleton` con la forma real tras 300 ms; botones con `loading` y gerundio.
- Vacío y error: `EmptyState` con siguiente paso; errores recuperables en `Banner` o `Toast` con «Reintentar».

## Estados de cita

| Backend | Etiqueta | Ícono | Color | En agenda |
|---|---|---|---|---|
| `Pendiente` | Pendiente | `hourglass` | `status-pendiente` | borde punteado |
| `Confirmada` | Confirmada | `circle-check` | `status-confirmada` | borde sólido |
| `EnProgreso` | En progreso | `scissors` | `status-enprogreso` | borde doble |
| `Completada` | Completada | `check-check` | `status-completada` (latón) | sin borde |
| `Cancelada` | Cancelada | `circle-x` | `status-cancelada` | rayado + tachado |
| `NoShow` | No asistió | `user-x` | `status-noshow` | rayado + tachado |

## Accesibilidad

- Contraste verificado: todo par texto/fondo nombrado en las notas de uso de los tokens pasa AA en claro y oscuro; bordes de control, foco e íconos con significado ≥3:1.
- La leyenda de Disponibilidad lleva ícono + palabra en cada estado; los estados de cita, ícono + palabra; las tendencias de KPI, flecha + signo + texto.
- Etiqueta visible en todo campo; `IconButton` siempre con `label`. Cuenta regresiva anunciada una sola vez al entrar al último minuto.
- Tamaño de texto del sistema: los diseños aguantan 130 % sin cortar (tarjetas crecen en alto, no se trunca el precio).

## Logo

- Usa `Logo` (React) o los SVG de `assets/Logos`: `emblema.svg` y `logo-horizontal.svg` sobre fondos claros; `*-sobre-oscuro.svg` sobre `carbon` o tema oscuro; `*-mono-*` para un solo color (sellos, grabados, impresión).
- Ícono de app: `app-icon-ios.svg` / `app-icon-ios-1024.png`; Android adaptativo con `app-icon-android-foreground.svg` + `-background.svg` + `-monochrome.svg`. Favicon: `favicon.svg`.
- Zona de respeto: medio ancho del emblema. Mínimos: emblema 16 px, horizontal 28 px de alto.

## Consumir el sistema

- Web: variables CSS de `tokens.css` (`var(--brass)`, `var(--space-4)`, `var(--font-sans)`…) bajo `[data-theme="light"|"dark"]`; componentes en `components/bundle.js` como `window.BSM` (React 18) con `components/bundle.css`.
- Flutter: mapeo token → `ColorScheme` / `TextTheme` / `ThemeExtension` en la sección **Implementación**.
- Pantallas y flujos (reserva, agenda, gestión) y las reglas que resuelven los problemas conocidos: sección **Patrones de pantalla**.
