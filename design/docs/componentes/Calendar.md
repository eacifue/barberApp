# Calendar

Calendario mensual para elegir fecha: lunes primero, hoy con anillo, día elegido en latón, días sin atención deshabilitados.

**Props:** `year` · `month` (0–11) · `today` · `selected` · `disabled(day) → boolean` · `marks` (`{día: 'few' | 'any'}`) · `legend`.

**Flutter:** `CalendarDatePicker` con `ThemeData.datePickerTheme` (dayBackgroundColor seleccionado `brass`, `todayBorder` `brass-ink`) o `table_calendar`. Celdas de 44 px.

**Reglas**
- Deshabilitar: días pasados, días de descanso de la barbería y días libres del barbero.
- Punto naranja = pocos horarios libres; un día lleno se deshabilita.
- Abrir en la primera fecha con horarios, no en hoy si hoy está lleno.
