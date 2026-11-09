import { Navigate, createBrowserRouter } from 'react-router-dom'

import { AdminGuard, AuthGuard, GuestGuard, StaffGuard } from './routeGuards'
import { AppLayout } from './components/layout/AppLayout'
import { LoginPage } from './features/auth/LoginPage'
import { RecuperarPage } from './features/auth/RecuperarPage'
import { DashboardPage } from './features/dashboard/DashboardPage'
import { BarberiasList } from './features/barberias/BarberiasList'
import { BarberiasAdminPage } from './features/barberias/BarberiasAdminPage'
import { BarberosList } from './features/barberos/BarberosList'
import { ServiciosList } from './features/servicios/ServiciosList'
import { ClientesList } from './features/clientes/ClientesList'
import { AgendaPage } from './features/citas/AgendaPage'
import { DisponibilidadPage } from './features/disponibilidad/DisponibilidadPage'
import { UsersPage } from './features/users/UsersPage'

export const router = createBrowserRouter([
  {
    element: <GuestGuard />,
    children: [
      { path: '/login', element: <LoginPage /> },
      { path: '/recuperar', element: <RecuperarPage /> },
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
          { path: 'citas', element: <AgendaPage /> },
          {
            element: <StaffGuard />,
            children: [
              { path: 'barberos', element: <BarberosList /> },
              { path: 'servicios', element: <ServiciosList /> },
              { path: 'clientes', element: <ClientesList /> },
              { path: 'disponibilidad', element: <DisponibilidadPage /> },
              // Mi negocio: el SuperAdmin edita la barbería elegida; el Admin Barbería, la suya.
              { path: 'negocio', element: <BarberiasList /> },
              { path: 'slots', element: <Navigate to="/disponibilidad?vista=reservas" replace /> },
            ],
          },
          {
            // Gestionar barberías y cuentas de administrador exige rol Admin en la API.
            element: <AdminGuard />,
            children: [
              { path: 'barberias', element: <BarberiasAdminPage /> },
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
