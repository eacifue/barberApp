import { useMemo } from 'react'

import { barberiaIdDelToken } from '../services/jwt'
import { useAuthStore } from '../stores/authStore'
import { useTenantStore } from '../stores/tenantStore'
import { useBarberias } from './useBarberias'

/**
 * La barbería con la que trabaja el panel.
 * - SuperAdmin (`Admin`): la que eligió en la barra superior; sin elección, todas.
 * - Administrador de barbería y barbero: la de su sesión (claim `barberiaId`).
 */
export function useTenantBarberia() {
  const usuario = useAuthStore((s) => s.usuario)
  const token = useAuthStore((s) => s.token)
  const elegida = useTenantStore((s) => s.barberiaElegida)
  const { barberiasQuery } = useBarberias()

  const role = usuario?.rol ?? ''
  const isAdmin = role === 'Admin'
  const isAdminBarberia = role === 'AdministradorBarberia'

  const effectiveBarberiaId = isAdmin ? elegida : barberiaIdDelToken(token)
  const barberia = useMemo(
    () => barberiasQuery.data?.find((b) => b.id === effectiveBarberiaId),
    [barberiasQuery.data, effectiveBarberiaId],
  )

  return {
    role,
    isAdmin,
    isAdminBarberia,
    /** SuperAdmin en «Todas las barberías»: solo vistas consolidadas. */
    todas: isAdmin && !elegida,
    effectiveBarberiaId,
    barberia,
    barberias: barberiasQuery.data ?? [],
  }
}
