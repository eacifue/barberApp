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

  const daysOffQuery = useQuery({
    queryKey: ['days-off', barberId],
    queryFn: () => availabilityService.getDaysOff(barberId),
    enabled: Boolean(barberId),
  })

  const invalidarDiasLibres = async () => {
    await queryClient.invalidateQueries({ queryKey: ['days-off', barberId] })
    await queryClient.invalidateQueries({ queryKey: ['availability', barberId] })
  }

  const addDayOffMutation = useMutation({
    mutationFn: (payload: CreateBarberDayOffRequest) => availabilityService.addDayOff(barberId, payload),
    onSuccess: invalidarDiasLibres,
  })

  const removeDayOffMutation = useMutation({
    mutationFn: (dayOffId: string) => availabilityService.removeDayOff(barberId, dayOffId),
    onSuccess: invalidarDiasLibres,
  })

  const slotsByDateMutation = useMutation({
    mutationFn: (date: string) => availabilityService.getSlots(barberId, date),
  })

  return {
    availabilityQuery,
    upsertAvailabilityMutation,
    daysOffQuery,
    addDayOffMutation,
    removeDayOffMutation,
    slotsByDateMutation,
  }
}
