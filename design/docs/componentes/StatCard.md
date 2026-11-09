# StatCard

Tarjeta KPI del dashboard web: etiqueta, cifra en Gloock, ícono y tendencia expresada en palabras.

**Props:** `label` · `value` (string ya formateado) · `icon` · `delta` (porcentaje, positivo o negativo) · `deltaLabel` («vs. semana pasada») · `invert` (true cuando bajar es bueno, p. ej. cancelaciones) · `hint` (en vez de delta).

**Reglas:** 4 KPI en fila en desktop (Citas del día, Ingresos, Clientes, Barberos activos), 2 × 2 en tablet, carrusel o lista en móvil. La tendencia lleva flecha + signo + texto, no solo color.
