# Avatar

Foto circular del barbero o cliente; sin foto, iniciales en Gloock sobre `brass-soft`.

**Props:** `name` (genera iniciales) · `src` · `size` 24 / 32 / 48 / 64 (`avatar-*`) · `status` `'on' | 'off'` (disponible hoy).

**Flutter:** `CircleAvatar` con `CachedNetworkImageProvider` y `shimmer` mientras carga; fallback de iniciales.
