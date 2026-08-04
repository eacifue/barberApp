import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'

import { barberiaService } from '../services/barberiaService'
import { useAuthStore } from '../stores/authStore'
import type { BarberiaUpsertInput } from '../types/barberia'

export function useBarberias() {
  const queryClient = useQueryClient()
  const usuario = useAuthStore((s) => s.usuario)

  const role = usuario?.rol ?? ''
  const barberiaId = usuario?.barberiaId ?? null
  const isAdmin = role === 'Admin'
  const isAdminBarberia = role === 'AdministradorBarberia'

  const barberiasQuery = useQuery({
    queryKey: ['barberias', role, barberiaId],
    enabled: isAdmin || (isAdminBarberia && Boolean(barberiaId)),
    queryFn: async () => {
      if (isAdminBarberia && barberiaId) {
        const single = await barberiaService.getPublicById(barberiaId)
        return [single]
      }
      return barberiaService.getAll()
    },
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
