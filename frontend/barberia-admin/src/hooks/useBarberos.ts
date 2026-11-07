import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'

import { barberoService } from '../services/barberoService'
import type { BarberoUpsertInput } from '../types/barbero'

export function useBarberos(barberiaId: string, incluirInactivos = false) {
  const queryClient = useQueryClient()

  const barberosQuery = useQuery({
    queryKey: ['barberos', barberiaId, incluirInactivos],
    queryFn: () => barberoService.getByBarberia(barberiaId, incluirInactivos),
    enabled: Boolean(barberiaId),
  })

  const createMutation = useMutation({
    mutationFn: (payload: BarberoUpsertInput) => barberoService.create(payload),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ['barberos'] })
    },
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: BarberoUpsertInput }) => barberoService.update(id, data),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ['barberos'] })
    },
  })

  const updateFCMMutation = useMutation({
    mutationFn: ({ id, token }: { id: string; token: string }) => barberoService.updateFCM(id, token),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ['barberos'] })
    },
  })

  const removeMutation = useMutation({
    mutationFn: (id: string) => barberoService.remove(id),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ['barberos'] })
    },
  })

  return {
    barberosQuery,
    createMutation,
    updateMutation,
    updateFCMMutation,
    removeMutation,
  }
}
