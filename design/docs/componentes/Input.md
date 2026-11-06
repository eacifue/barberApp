# Input

Campo de texto con etiqueta arriba, ayuda o error debajo y opcionalmente ícono inicial o acción final.

**Props:** `label` · `hint` · `error` (reemplaza a `hint`, pone el borde en `danger`) · `icon` · `trailing` (un nodo al final del campo) · `revealable` (contraseña con botón Mostrar/Ocultar) · `optional` (añade «(opcional)») · `multiline` · resto de props de `<input>`.

**Flutter:** `TextFormField` con `InputDecoration`: `filled` con `surface`, `OutlineInputBorder` `line-strong` 1 px / foco `focus` 2 px / error `danger`, `labelText` fuera del campo (usar `Column` con `Text` estilo `label-sm`), `helperText`/`errorText` estilo `caption`. Texto a 16 px.

**Reglas**
- Marcar lo opcional, no lo obligatorio.
- Validar al salir del campo y al enviar; el mensaje dice cómo corregir: «Ingresa un número de 10 dígitos.».
- Teléfono, correo y número con su teclado (`keyboardType`). Hora con selector, nunca «Formato HH:mm».
