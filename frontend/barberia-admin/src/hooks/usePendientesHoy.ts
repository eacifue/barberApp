import { useQuery } from '@tanstack/react-query'

import { todayIso } from '../features/citas/agendaUtils'
import { citaService } from '../services/citaService'

/** Citas pendientes de hoy: contador del menú y aviso de la agenda. */
export function usePendientesHoy(enabled = true) {
  const hoy = todayIso()
  return useQuery({
    queryKey: ['agenda-pendientes', hoy],
    queryFn: () => citaService.getAdminList({ date: hoy, status: 'Pendiente', page: 1, pageSize: 100 }),
    enabled,
    refetchInterval: 60_000,
  })
}
