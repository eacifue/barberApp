import { useQueryClient } from '@tanstack/react-query'

import { useTenantBarberia } from '../../hooks/useTenantBarberia'
import { useTenantStore } from '../../stores/tenantStore'
import { Select } from '../bsm'

/** Solo SuperAdmin: elige con qué barbería trabaja el panel, o todas (vista consolidada). */
export function BarberiaSelector({ compact }: { compact?: boolean }) {
  const queryClient = useQueryClient()
  const elegir = useTenantStore((s) => s.elegir)
  const { effectiveBarberiaId, barberias } = useTenantBarberia()

  const cambiar = (id: string) => {
    elegir(id || null)
    // Cada consulta trae datos de la barbería anterior: se descartan y se vuelven a pedir.
    void queryClient.resetQueries()
  }

  return (
    <Select
      aria-label="Barbería con la que trabajas"
      className={compact ? 'w-[11rem]' : 'w-[16rem]'}
      value={effectiveBarberiaId ?? ''}
      onChange={(e) => cambiar(e.target.value)}
      options={[
        { value: '', label: compact ? 'Todas' : 'Todas las barberías' },
        ...barberias.map((b) => ({ value: b.id, label: b.activa ? b.nombre : `${b.nombre} (desactivada)` })),
      ]}
    />
  )
}
