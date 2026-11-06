# SlotGrid

Grilla de horarios. Modo cliente: libre, elegido o no disponible, agrupados en Mañana/Tarde/Noche. Modo admin: los 4 estados de Disponibilidad con ícono y palabra.

**Props:** `slots` (`{time:'HH:mm', state:'available'|'booked'|'blocked'|'hold', note?}[]`) · `selected` · `mode` `'client' | 'admin'` · `label`.

**Cliente (paso 3):** al tocar un horario se bloquea 5 min y aparece `Countdown`; la barra inferior fija muestra «3:00 p. m. · 50 min» + «Continuar». Los no disponibles se ven tachados y no son enfocables; el cliente no ve por qué (ocupado, bloqueado o en reserva).

**Admin (Disponibilidad):** Disponible (`slot-available`, círculo), Ocupado (`slot-booked`, calendario), Bloqueado (`slot-blocked`, candado, borde punteado), Reservando (`slot-hold`, temporizador + cuenta regresiva). La leyenda repite ícono + palabra, así que no depende del color.
