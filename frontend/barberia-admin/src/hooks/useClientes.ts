import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'

import { useTenantBarberia } from './useTenantBarberia'
import { clienteService } from '../services/clienteService'
import type { ClienteUpsertInput } from '../types/cliente'

export function useClientes() {
  const queryClient = useQueryClient()
  const { isAdminBarberia } = useTenantBarberia()

  const clientesQuery = useQuery({
    queryKey: ['clientes', isAdminBarberia ? 'tenant' : 'admin'],
    queryFn: () => (isAdminBarberia ? clienteService.getAllTenant() : clienteService.getAll()),
  })

  const createMutation = useMutation({
    mutationFn: (payload: ClienteUpsertInput) => clienteService.create(payload),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ['clientes'] })
    },
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: ClienteUpsertInput }) => clienteService.update(id, data),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ['clientes'] })
    },
  })

  const removeMutation = useMutation({
    mutationFn: (id: string) => clienteService.remove(id),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ['clientes'] })
    },
  })

  return {
    clientesQuery,
    createMutation,
    updateMutation,
    removeMutation,
  }
}
