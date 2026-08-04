import { useMemo } from 'react'

import { useAuthStore } from '../stores/authStore'
import { useBarberias } from './useBarberias'

export function useTenantBarberia() {
  const usuario = useAuthStore((s) => s.usuario)
  const { barberiasQuery } = useBarberias()

  const role = usuario?.rol ?? ''
  const isAdmin = role === 'Admin'
  const isAdminBarberia = role === 'AdministradorBarberia'

  // The app only ever serves a single barbershop — always resolve it as
  // the one (and only) result from the barberias list.
  const effectiveBarberiaId = useMemo(() => {
    return barberiasQuery.data?.[0]?.id ?? null
  }, [barberiasQuery.data])

  return {
    role,
    isAdmin,
    isAdminBarberia,
    canSelectBarberia: false,
    effectiveBarberiaId,
    tenantError: null,
  }
}
