import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'

import { barberiaService } from '../services/barberiaService'
import { useAuthStore } from '../stores/authStore'
import type { BarberiaUpsertInput, CrearBarberiaInput } from '../types/barberia'

export function useBarberias() {
  const queryClient = useQueryClient()
  const isAdmin = useAuthStore((s) => s.usuario?.rol === 'Admin')

  // /admin/barberias (todas, también desactivadas) exige SuperAdmin; el resto usa el
  // listado público y toma de ahí la barbería de su sesión.
  const barberiasQuery = useQuery({
    queryKey: ['barberias', isAdmin],
    queryFn: () => (isAdmin ? barberiaService.getAll() : barberiaService.getAllPublic()),
  })

  const invalidar = async () => {
    await queryClient.invalidateQueries({ queryKey: ['barberias'] })
    await queryClient.invalidateQueries({ queryKey: ['barberias-resumen'] })
  }

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: BarberiaUpsertInput }) => barberiaService.update(id, data),
    onSuccess: invalidar,
  })

  const crearMutation = useMutation({
    mutationFn: (data: CrearBarberiaInput) => barberiaService.crear(data),
    onSuccess: invalidar,
  })

  const estadoMutation = useMutation({
    mutationFn: ({ id, activa }: { id: string; activa: boolean }) => barberiaService.cambiarEstado(id, activa),
    onSuccess: invalidar,
  })

  return { barberiasQuery, updateMutation, crearMutation, estadoMutation }
}

/** Solo SuperAdmin: el mes en curso de cada barbería. */
export function useResumenBarberias(enabled = true) {
  return useQuery({ queryKey: ['barberias-resumen'], queryFn: () => barberiaService.resumen(), enabled })
}
