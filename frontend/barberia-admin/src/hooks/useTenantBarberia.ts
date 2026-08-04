import { useMemo } from 'react'

import { useAuthStore } from '../stores/authStore'
import { useBarberias } from './useBarberias'

export function useTenantBarberia() {
  const usuario = useAuthStore((s) => s.usuario)
  const { barberiasQuery } = useBarberias()

  const role = usuario?.rol ?? ''
  const userBarberiaId = usuario?.barberiaId ?? null
  const isAdmin = role === 'Admin'
  const isAdminBarberia = role === 'AdministradorBarberia'

  // The app only ever serves a single barbershop. AdministradorBarberia
  // accounts already carry their shop's id; Admin accounts aren't tied to
  // one in the data model, so resolve it the same way the mobile admin
  // side does: the one (and only) result from the barberias list.
  const effectiveBarberiaId = useMemo(() => {
    if (isAdminBarberia) return userBarberiaId
    return barberiasQuery.data?.[0]?.id ?? null
  }, [isAdminBarberia, userBarberiaId, barberiasQuery.data])

  const tenantError = isAdminBarberia && !userBarberiaId
    ? 'Tu cuenta AdministradorBarberia no tiene BarberiaId asociado. Contacta al administrador del sistema.'
    : null

  return {
    role,
    isAdmin,
    isAdminBarberia,
    canSelectBarberia: false,
    effectiveBarberiaId,
    userBarberiaId,
    tenantError,
  }
}
