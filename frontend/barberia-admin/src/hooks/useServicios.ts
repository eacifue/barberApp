import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'

import { servicioService } from '../services/servicioService'
import type { ServicioUpsertInput } from '../types/servicio'

export function useServicios(barberiaId: string) {
  const queryClient = useQueryClient()

  const serviciosQuery = useQuery({
    queryKey: ['servicios', barberiaId],
    queryFn: () => servicioService.getByBarberia(barberiaId),
    enabled: Boolean(barberiaId),
  })

  const createMutation = useMutation({
    mutationFn: (payload: ServicioUpsertInput) => servicioService.create(payload),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ['servicios'] })
    },
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: ServicioUpsertInput }) => servicioService.update(id, data),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ['servicios'] })
    },
  })

  const removeMutation = useMutation({
    mutationFn: (id: string) => servicioService.remove(id),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ['servicios'] })
    },
  })

  return {
    serviciosQuery,
    createMutation,
    updateMutation,
    removeMutation,
  }
}
