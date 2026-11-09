# Countdown

Cuenta regresiva del bloqueo temporal de 5 minutos mientras el cliente confirma.

**Props:** `seconds` · `total` (300) · `variant` `'compact'` · `label`.

**Comportamiento**
- 5:00 → 1:01: latón, «Horario apartado por».
- ≤ 1:00: naranja `warning`, «Tu horario se libera en», un aviso háptico y anuncio a lectores de pantalla una sola vez.
- 0:00: diálogo «Tu horario se liberó» con acción «Elegir otro horario» (vuelve al paso 3 con la misma fecha).

**Flutter:** `Timer.periodic` con hora de expiración del servidor (no restar en local); `LinearProgressIndicator` de 4 px; cifras con `FontFeature.tabularFigures()`.
