import { useEffect, useState } from 'react'
import { Outlet, useLocation } from 'react-router-dom'

import { useAuthStore } from '../../stores/authStore'
import { useLogout } from '../../hooks/useLogout'
import { useMediaQuery } from '../../hooks/useMediaQuery'
import { usePendientesHoy } from '../../hooks/usePendientesHoy'
import { BottomNav, ConfirmDialog, Sidebar, Topbar, cx, type BottomNavAction, type NavItem, type NavSection } from '../bsm'
import { useTheme } from '../theme/ThemeProvider'

const ROUTE_TITLES: Record<string, string> = {
  '/dashboard': 'Dashboard',
  '/citas': 'Agenda',
  '/disponibilidad': 'Disponibilidad',
  '/clientes': 'Clientes',
  '/barberos': 'Barberos',
  '/servicios': 'Servicios',
  '/barberias': 'Mi negocio',
  '/usuarios': 'Usuarios',
  '/slots': 'Reservas en curso',
}

const ROLE_LABEL: Record<string, string> = {
  Admin: 'Administrador',
  AdministradorBarberia: 'Admin Barbería',
  Barbero: 'Barbero',
}

/** Menú por rol (design/docs/componentes/Sidebar.md). */
function navigation(rol: string, pendientes: number): NavSection[] {
  const principal: NavSection = { title: 'Principal', items: [{ icon: 'layout-dashboard', label: 'Dashboard', to: '/dashboard' }] }
  if (rol === 'Barbero') {
    return [principal, { title: 'Agenda', items: [{ icon: 'calendar-days', label: 'Mis citas', to: '/citas' }] }]
  }
  const miBarberia: NavSection = {
    title: 'Mi barbería',
    items: [
      { icon: 'calendar-days', label: 'Agenda', to: '/citas', count: pendientes },
      { icon: 'clock', label: 'Disponibilidad', to: '/disponibilidad' },
      { icon: 'users', label: 'Clientes', to: '/clientes' },
      { icon: 'scissors', label: 'Barberos', to: '/barberos' },
      { icon: 'clipboard-list', label: 'Servicios', to: '/servicios' },
    ],
  }
  if (rol !== 'Admin') return [principal, miBarberia]
  return [
    principal,
    miBarberia,
    {
      title: 'Administración',
      items: [
        { icon: 'store', label: 'Mi negocio', to: '/barberias' },
        { icon: 'user-cog', label: 'Usuarios', to: '/usuarios' },
      ],
    },
  ]
}

/**
 * Estructura del panel: Sidebar fijo desde 1280 px (drawer por debajo),
 * Topbar con título en Gloock y, bajo 768 px, barra inferior flotante con
 * Inicio · Agenda · Clientes · Más (design/docs/02-patrones.md · Panel web).
 */
export function AppLayout() {
  const location = useLocation()
  const usuario = useAuthStore((s) => s.usuario)
  const rol = usuario?.rol ?? ''
  const logout = useLogout()
  const { theme, setChoice } = useTheme()
  const desktop = useMediaQuery('(min-width: 1280px)')
  const phone = !useMediaQuery('(min-width: 768px)')
  const [drawerOpen, setDrawerOpen] = useState(false)
  const [askLogout, setAskLogout] = useState(false)

  const pendientesQuery = usePendientesHoy(rol !== 'Barbero')
  const pendientes = pendientesQuery.data?.length ?? 0
  const sections = navigation(rol, pendientes)
  const title = ROUTE_TITLES[location.pathname] ?? 'Panel'

  // Esc cierra el drawer (navegar también lo cierra, vía onNavigate).
  useEffect(() => {
    if (!drawerOpen) return
    const onKey = (e: KeyboardEvent) => e.key === 'Escape' && setDrawerOpen(false)
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [drawerOpen])

  const phoneItems: Array<NavItem | BottomNavAction> = [
    { icon: 'layout-dashboard', label: 'Inicio', to: '/dashboard' },
    { icon: 'calendar-days', label: 'Agenda', to: '/citas', badge: pendientes > 0 },
    ...(rol === 'Barbero' ? [] : [{ icon: 'users', label: 'Clientes', to: '/clientes' } as NavItem]),
    { icon: 'menu', label: 'Más', onClick: () => setDrawerOpen(true) },
  ]

  const sidebar = (
    <Sidebar
      sections={sections}
      user={usuario ? { name: usuario.nombre, role: ROLE_LABEL[rol] ?? rol } : undefined}
      onLogout={() => setAskLogout(true)}
      onNavigate={() => setDrawerOpen(false)}
    />
  )

  return (
    <div className="flex h-dvh overflow-hidden bg-bg text-ink">
      {desktop ? (
        <div className="h-full flex-none">{sidebar}</div>
      ) : (
        <>
          <div
            className={cx('fixed inset-0 z-40 bg-scrim transition-opacity duration-base ease-standard', drawerOpen ? 'opacity-100' : 'pointer-events-none opacity-0')}
            onClick={() => setDrawerOpen(false)}
            aria-hidden="true"
          />
          <div
            className={cx(
              'fixed inset-y-0 left-0 z-50 shadow-lg transition-transform duration-slow ease-enter',
              drawerOpen ? 'translate-x-0' : '-translate-x-full',
            )}
            aria-hidden={!drawerOpen}
            inert={!drawerOpen}
          >
            {sidebar}
          </div>
        </>
      )}

      <div className="flex min-w-0 flex-1 flex-col">
        <Topbar
          title={title}
          theme={theme}
          onThemeChange={setChoice}
          compact={!desktop}
          onMenu={() => setDrawerOpen(true)}
          onLogout={() => setAskLogout(true)}
        />
        <main id="contenido" className={cx('min-h-0 flex-1 overflow-y-auto', phone ? 'pb-28' : '')}>
          <Outlet />
        </main>
        {phone && (
          <div className="pointer-events-none fixed inset-x-3 bottom-3 z-30">
            <div className="pointer-events-auto">
              <BottomNav floating items={phoneItems} />
            </div>
          </div>
        )}
      </div>

      <ConfirmDialog
        open={askLogout}
        tone="danger"
        icon="log-out"
        title="¿Cerrar sesión?"
        body="Tendrás que volver a ingresar con tu correo."
        confirmLabel="Cerrar sesión"
        onCancel={() => setAskLogout(false)}
        onConfirm={() => {
          setAskLogout(false)
          logout()
        }}
      />
    </div>
  )
}
