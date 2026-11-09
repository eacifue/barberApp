import { useQueryClient } from '@tanstack/react-query'

import { useTenantBarberia } from '../../hooks/useTenantBarberia'
import { useTenantStore } from '../../stores/tenantStore'
import { Button, EmptyState } from '../bsm'

/**
 * SuperAdmin en «Todas las barberías» entrando a una sección que trabaja con una sola
 * (agenda, clientes, equipo…): no se mezclan datos, se pide elegir.
 */
export function ElegirBarberia() {
  const queryClient = useQueryClient()
  const elegir = useTenantStore((s) => s.elegir)
  const { barberias } = useTenantBarberia()
  const activas = barberias.filter((b) => b.activa)

  return (
    <div className="mx-auto flex max-w-[640px] flex-col px-4 py-10 md:px-6">
      <EmptyState
        icon="store"
        title="Elige una barbería"
        body="Esta sección trabaja con una sola barbería. Elígela aquí o en el selector de arriba; el Dashboard y Barberías muestran todas juntas."
        action={
          activas.length > 0 && (
            <div className="flex flex-wrap justify-center gap-2">
              {activas.map((b) => (
                <Button
                  key={b.id}
                  variant="secondary"
                  icon="store"
                  onClick={() => {
                    elegir(b.id)
                    void queryClient.resetQueries()
                  }}
                >
                  {b.nombre}
                </Button>
              ))}
            </div>
          )
        }
      />
    </div>
  )
}
