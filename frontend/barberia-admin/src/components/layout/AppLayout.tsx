import { useState } from 'react'
import { Outlet, useLocation } from 'react-router-dom'

import { MobileBottomNav, Sidebar } from './Sidebar'
import { Topbar } from './Topbar'

const routeTitles: Record<string, string> = {
  '/dashboard': 'Dashboard',
  '/usuarios': 'Usuarios',
  '/barberias': 'Barberias',
  '/barberos': 'Barberos',
  '/servicios': 'Servicios',
  '/clientes': 'Clientes',
  '/citas': 'Agenda',
  '/disponibilidad': 'Disponibilidad',
  '/slots': 'Slots / Redis',
}

export function AppLayout() {
  const location = useLocation()
  const [isSidebarOpen, setIsSidebarOpen] = useState(false)
  const pageTitle = routeTitles[location.pathname] ?? 'Panel'

  return (
    <div className="app-shell premium-grid relative flex overflow-hidden text-[var(--text-base)]">
      <Sidebar open={isSidebarOpen} onClose={() => setIsSidebarOpen(false)} />
      <main className="relative z-10 flex min-w-0 flex-1 flex-col overflow-hidden">
        <Topbar
          title={pageTitle}
          onToggleNavigation={() => setIsSidebarOpen((current) => !current)}
        />
        <div className="content flex-1 overflow-y-auto px-4 pb-24 pt-4 md:px-6 md:pb-8 lg:px-8 lg:pt-6">
          <Outlet />
        </div>
        <MobileBottomNav />
      </main>
    </div>
  )
}
