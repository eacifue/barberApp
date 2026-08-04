import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'

import { barberiaService } from '../services/barberiaService'
import { useAuthStore } from '../stores/authStore'
import type { BarberiaUpsertInput } from '../types/barberia'

export function useBarberias() {
  const queryClient = useQueryClient()
  const isAdmin = useAuthStore((s) => s.usuario?.rol === 'Admin')

  // /admin/barberias requiere rol Admin; AdministradorBarberia usa el
  // endpoint público, que devuelve la misma (única) barbería.
  const barberiasQuery = useQuery({
    queryKey: ['barberias', isAdmin],
    queryFn: () => (isAdmin ? barberiaService.getAll() : barberiaService.getAllPublic()),
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: BarberiaUpsertInput }) => barberiaService.update(id, data),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ['barberias'] })
    },
  })

  return {
    barberiasQuery,
    updateMutation,
  }
}
