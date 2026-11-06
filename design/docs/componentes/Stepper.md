# Stepper

Progreso de la reserva: «Paso X de 4» más cuatro segmentos con nombre (Servicio · Barbero · Horario · Confirmar).

**Props:** `current` (1–4) · `steps` (por defecto los cuatro).

**Flutter:** `Row` de 4 `Expanded` con barra de 4 px (`brass` hechos y actual, `line` pendientes) y etiqueta `caption`; tocar un paso hecho regresa a él conservando la selección.
