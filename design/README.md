# design · BarberShop Medellín

Paquete del rediseño para implementar en la app móvil (Flutter 3 · Material 3) y en el panel web (React + Tailwind 3). Todo sale del mismo sistema de diseño: mismos tokens, mismos nombres, mismo copy.

## Enlaces vivos

| Qué | Enlace |
|---|---|
| Sistema de diseño (tokens, componentes, logos, guías) | https://claude.ai/artifact/7JjuG41wCsxyV7GbAv9vXU |
| Lienzo · App móvil (34 pantallas, prototipo con Play) | https://claude.ai/artifact/3Bqo2YR636vVxHF5qFCatd |
| Lienzo · Panel web (29 pantallas, prototipo con Play) | https://claude.ai/artifact/X2AQUSnbHDbUzEjPfrebWD |

Son privados: quien vaya a implementar necesita que los compartas desde el menú Compartir de cada uno. Ahí se ven las pantallas renderizadas; los archivos de `pantallas/` son su fuente.

## Estructura

```
design/
├── tokens/                  tokens.json (fuente única) y tokens.css (variables claro/oscuro)
├── flutter/
│   ├── lib/core/theme/      app_colors.dart · app_text_styles.dart · app_theme.dart
│   ├── assets/fonts/        Gloock-Regular.ttf · InstrumentSans-Variable.ttf (+ licencias OFL)
│   ├── assets/icons/        íconos de tipo de servicio (SVG)
│   └── pubspec-fuentes.yaml bloque de fuentes para pubspec.yaml
├── web/
│   ├── src/globals.css      tokens + base (fondo, texto, enlaces, foco)
│   ├── src/theme.js         interruptor claro / oscuro / sistema
│   ├── tailwind.config.js   colores, tipografía, radios, sombras, motion y breakpoints en var()
│   ├── public/              fuentes woff2, favicon.svg, favicon-48.png, apple-touch-icon-180.png
│   ├── index-head.html      alternativa: fuentes desde Google Fonts
│   └── referencia-componentes/  bundle.js + bundle.css + index.d.ts: implementación de referencia de los 33 componentes
├── assets/
│   ├── logos/               emblema, horizontal, vertical, monocromos, íconos de app iOS/Android, favicon
│   └── iconos/              íconos propios (corte, afeitado, barba, tinte, tratamiento, combo, otro)
├── docs/
│   ├── 00-sistema.md        resumen del sistema
│   ├── 01-concepto.md       concepto de marca
│   ├── 02-patrones.md       patrones por pantalla (app y panel) y problemas conocidos → solución
│   ├── 03-copy.md           copy es-CO, formatos de dinero, hora y fecha
│   ├── 04-implementacion.md guía completa Flutter y web (de aquí salen los archivos de código)
│   ├── 05-pantallas.md      índice de pantallas, estados y decisiones
│   └── componentes/         una ficha por componente: props, estados, uso
└── pantallas/
    ├── app-movil/           34 pantallas .dc.html + canvas.json
    └── panel-web/           29 pantallas .dc.html + canvas.json
```

## Dónde va cada archivo en el repo

| De `design/` | A | Nota |
|---|---|---|
| `flutter/lib/core/theme/*.dart` | `app/barberia_app/lib/core/theme/` | Reemplaza los tres archivos actuales. Requiere Flutter ≥ 3.27. |
| `flutter/assets/fonts/*.ttf` | `app/barberia_app/assets/fonts/` | Añadir el bloque de `pubspec-fuentes.yaml` a `pubspec.yaml`. |
| `flutter/assets/icons/*.svg` | `app/barberia_app/assets/icons/` | Declararlos en `assets:` y usarlos con `flutter_svg`. |
| `assets/logos/app-icon-*` | proyectos iOS y Android | iOS: `app-icon-ios-1024.png`. Android adaptativo: foreground / background / monochrome. |
| `web/src/globals.css` | `frontend/barberia-admin/src/globals.css` | Reemplaza el actual. |
| `web/tailwind.config.js` | `frontend/barberia-admin/tailwind.config.js` | Colores por `var()`: `bg-brass/50` no aplica; usa los tokens `-soft` / `-bg`. |
| `web/src/theme.js` | `frontend/barberia-admin/src/theme.js` | Llamar `initTheme()` al iniciar; `setThemeChoice('claro' \| 'oscuro' \| 'sistema')` desde la topbar. |
| `web/public/*` | `frontend/barberia-admin/public/` | Fuentes en `public/fonts/`; reemplaza `favicon.svg` y `logo-mark.svg`. |

`main.dart`: `MaterialApp(theme: buildTheme(Brightness.light), darkTheme: buildTheme(Brightness.dark), themeMode: ThemeMode.system, locale: const Locale('es', 'CO'))`, con `flutter_localizations` e `intl`.

## Cómo leer una pantalla `.dc.html`

- El marcado dentro de `<x-dc>` es el layout, los estilos y el copy exactos.
- `<x-import component-from-global-scope="BSM.Button" …>` es un componente del sistema: ficha en `docs/componentes/Button.md`, referencia en `web/referencia-componentes/bundle.js`. Los atributos en kebab-case son sus props.
- `{{valor}}` se resuelve con `renderVals()` del `<script>` al final: ahí están los datos de ejemplo (barberos, citas, precios).
- `data-props` declara las variantes de la pantalla: `dark`, `panel`, `vista`, `estado`.
- `<dc-import name="Clientes" panel="ficha">` significa «la pantalla Clientes en el estado ficha».
- `canvas.json` da el orden y el tamaño de cada pantalla (390 × 844 en móvil, 1440 en web).
- Los archivos no abren solos en el navegador (necesitan el visor del lienzo): para verlos, usa los enlaces de arriba.

## Orden de implementación

1. Tokens, tema claro/oscuro, fuentes, logos e íconos en las dos plataformas.
2. Componentes base según `docs/componentes/`: en web, portar `bundle.js` a componentes React con Tailwind; en Flutter, widgets equivalentes sobre el `ThemeData`.
3. App: reserva en 4 pasos con apartado de 5 min y expiración, éxito, Mis citas, detalle, reprogramar, cancelar, calificar.
4. Panel: Agenda (día, semana, historial, detalle, nueva cita) y Dashboard.
5. App: splash, onboarding, login, registro, Inicio. Panel: login.
6. Panel: Barberos, Servicios, Clientes con ficha, Usuarios, Mi negocio, Disponibilidad y Reservas en curso.

## Reglas que no se negocian

- Copy en es-CO con tildes: `$45.000`, `3:30 p. m.`, semana desde el lunes (`docs/03-copy.md`).
- Cada estado de cita usa su token `status-*` y siempre lleva ícono + texto, nunca solo color.
- Contraste AA en ambos temas, objetivos táctiles ≥ 44 px, foco visible en web.
- Fuera `gold` `#B8860B`, `#8B6F47`, paneles semitransparentes y degradados de fondo.
- Lo que está entre corchetes (`[Foto de portada]`, `[Slogan]`, `[Dirección]`, `[Teléfono]`, `[Correo]`) son datos reales del negocio por definir.

## Pendiente de diseño

- App: perfil del barbero con reseñas, perfil del cliente, recuperar contraseña, centro de notificaciones.
- App: agenda móvil del barbero y administración dentro de la app (foto con cámara, especialidades en chips, selectores de hora, mapa).
- Panel: vista del rol Barbero («Mis citas»), estados de carga / vacío / error en Gestión, tablet 768 y laptop 1280 con el menú como drawer, confirmación al cerrar sesión.

Mientras tanto, esas pantallas se construyen con los patrones de `docs/02-patrones.md` y los componentes existentes.
