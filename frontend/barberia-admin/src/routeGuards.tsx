import { Navigate, Outlet } from 'react-router-dom'

import { useAuthStore } from './stores/authStore'

/** Protege las rutas privadas: redirige a /login si no hay token */
export function AuthGuard() {
  const token = useAuthStore((s) => s.token)
  if (!token) return <Navigate to="/login" replace />
  return <Outlet />
}

/** Redirige al dashboard si ya está autenticado */
export function GuestGuard() {
  const token = useAuthStore((s) => s.token)
  if (token) return <Navigate to="/dashboard" replace />
  return <Outlet />
}

/** Solo Admin puede acceder */
export function AdminGuard() {
  const usuario = useAuthStore((s) => s.usuario)
  if (usuario?.rol !== 'Admin') return <Navigate to="/dashboard" replace />
  return <Outlet />
}

/** Gestión de la barbería: Admin y Admin Barbería. El barbero solo ve su agenda. */
export function StaffGuard() {
  const usuario = useAuthStore((s) => s.usuario)
  if (usuario?.rol === 'Barbero') return <Navigate to="/citas" replace />
  return <Outlet />
}
