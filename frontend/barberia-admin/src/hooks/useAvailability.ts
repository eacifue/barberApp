import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'

import { availabilityService } from '../services/availabilityService'
import type { CreateBarberDayOffRequest, UpsertBarberAvailabilityRequest } from '../types/availability'

export function useAvailability(barberId: string) {
  const queryClient = useQueryClient()

  const availabilityQuery = useQuery({
    queryKey: ['availability', barberId],
    queryFn: () => availabilityService.getByBarber(barberId),
    enabled: Boolean(barberId),
  })

  const upsertAvailabilityMutation = useMutation({
    mutationFn: (payload: UpsertBarberAvailabilityRequest) =>
      availabilityService.upsertByBarber(barberId, payload),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ['availability', barberId] })
    },
  })

  const addDayOffMutation = useMutation({
    mutationFn: (payload: CreateBarberDayOffRequest) => availabilityService.addDayOff(barberId, payload),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ['availability', barberId] })
    },
  })

  const slotsByDateMutation = useMutation({
    mutationFn: (date: string) => availabilityService.getSlots(barberId, date),
  })

  return {
    availabilityQuery,
    upsertAvailabilityMutation,
    addDayOffMutation,
    slotsByDateMutation,
  }
}
