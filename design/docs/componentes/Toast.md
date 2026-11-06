# Toast

Snackbar en `inverse` para confirmar una acción o informar un error recuperable, con una acción opcional.

**Props:** `tone` (cambia el ícono y el rol ARIA) · `children` · `action` · `dismissible` · `icon`.

**Flutter:** `SnackBar(behavior: SnackBarBehavior.floating)` con `backgroundColor` `inverse`, `actionTextColor` `inverse-action`, radio `radius-lg`, encima de la `NavigationBar`.

**Reglas:** 4 s (6 s con acción); no apilar más de uno; errores que bloquean van en `Banner`, no en toast.
