# Icon

Íconos de trazo de Lucide (2 px, puntas redondeadas) más dos propios: `navaja` (afeitado) y `barba`.

**Props:** `name` (ver `BSM.ICON_NAMES`) · `size` 16 / 20 / 24 (`icon-sm`, `icon-md`, `icon-lg`) · `label` solo si el ícono va sin texto y comunica algo.

**Tipo de servicio → ícono:** Corte `scissors` · Afeitado `navaja` · Barba `barba` · Tinte `droplets` · Tratamiento `sparkles` · Combo `layers` · Otro `ellipsis` (`BSM.SERVICE_ICON`).

**Flutter:** paquete `lucide_icons_flutter` o los SVG de `assets/Iconos` con `flutter_svg` (`colorFilter` con el color del token). Reemplaza Material Icons para que móvil y web compartan un solo set.

**Reglas**
- El color sale del texto que acompaña (`currentColor`). Sobre superficies, latón como ícono siempre es `brass-ink`, nunca `brass`.
- Ícono + palabra en estados; nunca el ícono solo como única señal.
