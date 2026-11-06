# Logo

Marca de BarberShop Medellín: el Portal (arco de fachada) con el poste de barbero en latón y granate.

**Usar para:** cabecera del sidebar web, login, splash, correos. En la app, el emblema solo en el splash y en la pantalla de éxito; no en cada topbar.

**Props:** `variant` `'horizontal' | 'emblem'` · `height` (px, por defecto 40 / 48) · `surface` `'auto' | 'light' | 'dark'` (`auto` sigue el tema; `dark` fuerza la versión para fondos oscuros, p. ej. sobre `carbon`).

**Flutter:** `SvgPicture.asset('assets/images/emblema.svg')` y `emblema-sobre-oscuro.svg` según `Theme.of(context).brightness`. El nombre se escribe como texto en Gloock 400 + MEDELLÍN en Instrument Sans 600 con tracking 0.34em, o se usa `logo-horizontal*.svg` (texto ya en curvas).

**Reglas**
- Zona de respeto: la mitad del ancho del emblema alrededor.
- Tamaño mínimo: emblema 16 px de alto (favicon usa su versión simplificada), horizontal 28 px.
- No recolorear el poste, no rotar, no poner sobre fotos sin un panel `carbon` detrás.
