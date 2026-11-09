# Tabs

Pestañas con subrayado latón (Próximas / Historial) y control segmentado (Día · Semana · Historial).

**Props:** `items` (`string[]` o `{value,label,icon,count}[]`) · `value` · `onChange` · `variant` `'underline' | 'segmented'` · `label`.

**Flutter:** subrayado → `TabBar` con `indicatorColor` `brass`, `labelColor` `ink`, `unselectedLabelColor` `ink-muted`; segmentado → `SegmentedButton`.

**Reglas:** etiquetas en tipo oración («Próximas», no «PRÓXIMAS»); contador opcional en el badge redondo.
