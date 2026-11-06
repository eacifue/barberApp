# StatusBadge

Badge del estado de una cita: color del estado + ícono + palabra, iguales en app, panel y agenda.

**Props:** `status` `'Pendiente' | 'Confirmada' | 'EnProgreso' | 'Completada' | 'Cancelada' | 'NoShow'` (los valores del backend) · `size='sm'`.

| Estado | Etiqueta | Ícono | Tokens |
|---|---|---|---|
| Pendiente | Pendiente | `hourglass` | `status-pendiente` / `-bg` |
| Confirmada | Confirmada | `circle-check` | `status-confirmada` / `-bg` |
| EnProgreso | En progreso | `scissors` | `status-enprogreso` / `-bg` |
| Completada | Completada | `check-check` | `status-completada` / `-bg` |
| Cancelada | Cancelada | `circle-x` | `status-cancelada` / `-bg` |
| NoShow | No asistió | `user-x` | `status-noshow` / `-bg` |

**Flutter:** un `enum AppointmentStatus` con `label`, `icon`, `color`, `background` leídos de `AppColors`; widget `Container` alto 24, radio `radius-xs`, texto `label-sm`.
