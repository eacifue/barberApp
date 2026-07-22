import { useCallback } from 'react'
import { useNavigate } from 'react-router-dom'
import { useQueryClient } from '@tanstack/react-query'

import { useAuthStore } from '../stores/authStore'

/**
 * Hook centralizado de logout.
 * 1. Limpia la cache de React Query (evita datos residuales entre sesiones).
 * 2. Limpia el estado de Zustand (token, usuario, barberiaId).
 * 3. Redirige a /login.
 */
export function useLogout() {
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const logout = useAuthStore((s) => s.logout)

  return useCallback(() => {
    // 1. Limpiar toda la cache de React Query
    queryClient.clear()

    // 2. Limpiar estado de autenticación (Zustand + localStorage persist)
    logout()

    // 3. Redirigir al login
    navigate('/login', { replace: true })
  }, [queryClient, logout, navigate])
}
