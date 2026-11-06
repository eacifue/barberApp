# Select

Lista desplegable para elegir una opción entre pocas (≤ 15); en móvil abre la hoja nativa.

**Props:** `label` · `options` (`string[]` o `{value,label}[]`) · `placeholder` · `hint` · `error` · `optional` · resto de props de `<select>`.

**Flutter:** `DropdownMenu` / `DropdownButtonFormField` con la misma decoración que `Input`. Para listas largas (clientes, barberos > 15) usar búsqueda con `SearchAnchor`.

**Reglas:** opción «Todos los barberos» / «Todos los estados» como primera en filtros. En Usuarios, el rol Barbero muestra un `Select` de barberos en vez del campo «Barbero ID (UUID)».
