# Switch

Interruptor de encendido/apagado con etiqueta y ayuda; encendido se pinta en latón con check.

**Props:** `label` · `hint` · `checked` / `defaultChecked` · `onChange(checked)` · `disabled`.

**Flutter:** `SwitchListTile` con `activeTrackColor` `brass`, `activeColor`/thumb `on-brass`, `thumbIcon` check, `inactiveTrackColor` `surface-sunken`, `trackOutlineColor` `line-strong`.

**Reglas:** el cambio aplica al instante (sin botón Guardar) y confirma con `Toast`. Para opciones que requieren guardar, usar casilla dentro del formulario.
