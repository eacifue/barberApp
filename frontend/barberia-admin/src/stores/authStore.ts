import { create } from 'zustand'
import { persist } from 'zustand/middleware'

export type AuthUsuario = {
  id: string
  nombre: string
  rol: string
  barberiaId?: string | null
  barberoId?: string | null
}

type AuthState = {
  token: string | null
  usuario: AuthUsuario | null
  login: (token: string, usuario: AuthUsuario) => void
  logout: () => void
  isAuthenticated: () => boolean
  isAdmin: () => boolean
  isAdminBarberia: () => boolean
  isBarbero: () => boolean
  isCliente: () => boolean
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      token: null,
      usuario: null,
      login: (token, usuario) => {
        const role = usuario.rol
        const barberiaId = usuario.barberiaId ?? null

        set({ token, usuario })

        localStorage.setItem('token', token)
        localStorage.setItem('user', JSON.stringify(usuario))
        localStorage.setItem('role', role)
        if (barberiaId) {
          localStorage.setItem('barberiaId', barberiaId)
        } else {
          localStorage.removeItem('barberiaId')
        }
      },
      logout: () => {
        set({ token: null, usuario: null })
        localStorage.removeItem('token')
        localStorage.removeItem('user')
        localStorage.removeItem('role')
        localStorage.removeItem('barberiaId')
      },
      isAuthenticated: () => Boolean(get().token),
      isAdmin: () => get().usuario?.rol === 'Admin',
      isAdminBarberia: () => get().usuario?.rol === 'AdministradorBarberia',
      isBarbero: () => get().usuario?.rol === 'Barbero',
      isCliente: () => get().usuario?.rol === 'Cliente',
    }),
    { name: 'barberia-auth' },
  ),
)

