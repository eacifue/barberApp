# Button

Botón de acción con cuatro variantes: primario (latón), secundario (borde), ghost (texto latón) y peligro.

**Props:** `variant` `'primary' | 'secondary' | 'ghost' | 'danger' | 'danger-ghost'` · `size` `'sm' | 'md' | 'lg'` (36 / 44 / 52) · `icon`, `iconRight` · `loading` · `disabled` · `block` (ancho completo) · `children` (la etiqueta) · resto de props de `<button>`.

**Flutter:** primary → `FilledButton` (backgroundColor `brass`, foreground `on-brass`); secondary → `OutlinedButton` (side `line-strong`); ghost → `TextButton` (foreground `brass-ink`); danger → `FilledButton` con `danger` / `on-danger`. `minimumSize` 44 (md) o 52 (lg), radio `radius-sm`, texto estilo `label`.

**Reglas**
- Un solo primario por pantalla o modal. En móvil el CTA de pantalla es `lg` + `block` en una barra inferior fija.
- Etiqueta en tipo oración y con verbo: «Reservar ahora», «Crear cita», «Sí, cancelar cita». Nunca MAYÚSCULAS («CONTINUAR» → «Continuar»).
- Destructivo en dos pasos: `danger-ghost` abre `ConfirmDialog`; el `danger` relleno vive solo dentro del diálogo.
- `loading` conserva la etiqueta en gerundio («Reservando…») y bloquea el doble toque.
