import { useMemo } from 'react'

import { useAuthStore } from '../stores/authStore'

export function useTenantBarberia() {
  const usuario = useAuthStore((s) => s.usuario)
  const selectedBarberiaId = useAuthStore((s) => s.selectedBarberiaId)
  const setSelectedBarberiaId = useAuthStore((s) => s.setSelectedBarberiaId)

  const role = usuario?.rol ?? ''
  const userBarberiaId = usuario?.barberiaId ?? null
  const isAdmin = role === 'Admin'
  const isAdminBarberia = role === 'AdministradorBarberia'

  const effectiveBarberiaId = useMemo(() => {
    if (isAdminBarberia) return userBarberiaId
    return selectedBarberiaId
  }, [isAdminBarberia, userBarberiaId, selectedBarberiaId])

  const canSelectBarberia = isAdmin
  const tenantError = isAdminBarberia && !userBarberiaId
    ? 'Tu cuenta AdministradorBarberia no tiene BarberiaId asociado. Contacta al administrador del sistema.'
    : null

  return {
    role,
    isAdmin,
    isAdminBarberia,
    canSelectBarberia,
    effectiveBarberiaId,
    userBarberiaId,
    setSelectedBarberiaId,
    tenantError,
  }
}
