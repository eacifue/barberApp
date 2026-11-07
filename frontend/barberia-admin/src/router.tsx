import { Navigate, Outlet, createBrowserRouter } from 'react-router-dom'

import { useAuthStore } from './stores/authStore'
import { AppLayout } from './components/layout/AppLayout'
import { LoginPage } from './features/auth/LoginPage'
import { DashboardPage } from './features/dashboard/DashboardPage'
import { BarberiasList } from './features/barberias/BarberiasList'
import { BarberosList } from './features/barberos/BarberosList'
import { ServiciosList } from './features/servicios/ServiciosList'
import { ClientesList } from './features/clientes/ClientesList'
import { AgendaPage } from './features/citas/AgendaPage'
import { DisponibilidadPage } from './features/disponibilidad/DisponibilidadPage'
import { UsersPage } from './features/users/UsersPage'

/** Protege las rutas privadas: redirige a /login si no hay token */
function AuthGuard() {
  const token = useAuthStore((s) => s.token)
  if (!token) return <Navigate to="/login" replace />
  return <Outlet />
}

/** Redirige al dashboard si ya está autenticado */
function GuestGuard() {
  const token = useAuthStore((s) => s.token)
  if (token) return <Navigate to="/dashboard" replace />
  return <Outlet />
}

/** Solo Admin puede acceder */
function AdminGuard() {
  const usuario = useAuthStore((s) => s.usuario)
  if (usuario?.rol !== 'Admin') return <Navigate to="/dashboard" replace />
  return <Outlet />
}

export const router = createBrowserRouter([
  {
    element: <GuestGuard />,
    children: [
      { path: '/login', element: <LoginPage /> },
    ],
  },
  {
    element: <AuthGuard />,
    children: [
      {
        path: '/',
        element: <AppLayout />,
        children: [
          { index: true, element: <Navigate to="/dashboard" replace /> },
          { path: 'dashboard', element: <DashboardPage /> },
          { path: 'barberias', element: <BarberiasList /> },
          { path: 'barberos', element: <BarberosList /> },
          { path: 'servicios', element: <ServiciosList /> },
          { path: 'clientes', element: <ClientesList /> },
          { path: 'citas', element: <AgendaPage /> },
          { path: 'disponibilidad', element: <DisponibilidadPage /> },
          { path: 'slots', element: <Navigate to="/disponibilidad?vista=reservas" replace /> },
          {
            element: <AdminGuard />,
            children: [
              { path: 'usuarios', element: <UsersPage /> },
            ],
          },
        ],
      },
    ],
  },
  // Galería de componentes del sistema de diseño: solo en desarrollo.
  ...(import.meta.env.DEV
    ? [{ path: '/_componentes', lazy: async () => ({ Component: (await import('./features/dev/ComponentesPage')).ComponentesPage }) }]
    : []),
  // Ruta desconocida: va a login para que el guard decida
  { path: '*', element: <Navigate to="/login" replace /> },
])
