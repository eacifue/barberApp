import type { ReactNode } from 'react'
import { useMatch, useNavigate } from 'react-router-dom'
import {
  CalendarDays,
  Clock3,
  Home,
  Scissors,
  Shield,
  Store,
  UserCircle2,
  Users,
  X,
} from 'lucide-react'

import { useAuthStore } from '../../stores/authStore'

type NavItemConfig = {
  to: string
  label: string
  icon: ReactNode
}

function SectionTitle({ children }: { children: ReactNode }) {
  return <p className="px-3 py-2 text-[10px] font-semibold uppercase tracking-[0.2em] text-[var(--text-faint)]">{children}</p>
}

function SidebarItem({ item }: { item: NavItemConfig }) {
  const navigate = useNavigate()
  const match = useMatch({ path: item.to, end: true })
  const isActive = Boolean(match)

  return (
    <button
      type="button"
      onClick={() => navigate(item.to)}
      className={[
        'flex w-full items-center gap-3 rounded-2xl px-3 py-3 text-left text-[13px] font-medium transition duration-200',
        'text-[var(--text-muted)] hover:-translate-y-0.5 hover:bg-[var(--surface-hover)] hover:text-[var(--text-strong)]',
        'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--focus-ring)]',
        isActive ? 'bg-[var(--accent-soft)] text-[var(--accent)] shadow-[inset_0_0_0_1px_var(--border-subtle)]' : '',
      ].join(' ')}
    >
      <span className="flex h-9 w-9 items-center justify-center rounded-xl border border-[var(--border-subtle)] bg-[var(--surface-overlay)] text-current">
        {item.icon}
      </span>
      <span className="truncate">{item.label}</span>
    </button>
  )
}

const principalItems: NavItemConfig[] = [{ to: '/dashboard', label: 'Dashboard', icon: <Shield className="h-4 w-4" /> }]

const adminItems: NavItemConfig[] = [
  { to: '/usuarios', label: 'Usuarios', icon: <Users className="h-4 w-4" /> },
  { to: '/barberias', label: 'Barberias', icon: <Store className="h-4 w-4" /> },
  { to: '/barberos', label: 'Barberos', icon: <UserCircle2 className="h-4 w-4" /> },
  { to: '/servicios', label: 'Servicios', icon: <Scissors className="h-4 w-4" /> },
  { to: '/clientes', label: 'Clientes', icon: <Users className="h-4 w-4" /> },
  { to: '/citas', label: 'Agenda', icon: <CalendarDays className="h-4 w-4" /> },
  { to: '/disponibilidad', label: 'Disponibilidad', icon: <Clock3 className="h-4 w-4" /> },
]

// Accesos más usados en el día a día — se muestran primero en el acceso rápido móvil.
// Slots/Redis vive en /slots pero ya no aparece en ningún menú (ver auditoría, C-04).
const adminMobileItems: NavItemConfig[] = [
  { to: '/citas', label: 'Agenda', icon: <CalendarDays className="h-4 w-4" /> },
  { to: '/clientes', label: 'Clientes', icon: <Users className="h-4 w-4" /> },
  { to: '/servicios', label: 'Servicios', icon: <Scissors className="h-4 w-4" /> },
]

const adminBarberiaItems: NavItemConfig[] = [
  { to: '/barberos', label: 'Barberos', icon: <UserCircle2 className="h-4 w-4" /> },
  { to: '/servicios', label: 'Servicios', icon: <Scissors className="h-4 w-4" /> },
  { to: '/clientes', label: 'Clientes', icon: <Users className="h-4 w-4" /> },
  { to: '/citas', label: 'Agenda', icon: <CalendarDays className="h-4 w-4" /> },
  { to: '/disponibilidad', label: 'Disponibilidad', icon: <Clock3 className="h-4 w-4" /> },
]

const adminBarberiaMobileItems: NavItemConfig[] = [
  { to: '/citas', label: 'Agenda', icon: <CalendarDays className="h-4 w-4" /> },
  { to: '/clientes', label: 'Clientes', icon: <Users className="h-4 w-4" /> },
  { to: '/servicios', label: 'Servicios', icon: <Scissors className="h-4 w-4" /> },
]

const barberoItems: NavItemConfig[] = [
  { to: '/citas', label: 'Mis Citas', icon: <CalendarDays className="h-4 w-4" /> },
]

const clienteItems: NavItemConfig[] = [
  { to: '/citas', label: 'Mis Citas', icon: <CalendarDays className="h-4 w-4" /> },
]

function getNavigation(rol: string) {
  if (rol === 'Admin') return { sectionItems: adminItems, sectionLabel: 'Gestión', mobileItems: adminMobileItems }
  if (rol === 'AdministradorBarberia')
    return { sectionItems: adminBarberiaItems, sectionLabel: 'Mi Barbería', mobileItems: adminBarberiaMobileItems }
  if (rol === 'Barbero') return { sectionItems: barberoItems, sectionLabel: 'Agenda', mobileItems: barberoItems }
  return { sectionItems: clienteItems, sectionLabel: 'Reservas', mobileItems: clienteItems }
}

type SidebarProps = {
  open: boolean
  onClose: () => void
}

export function Sidebar({ open, onClose }: SidebarProps) {
  const usuario = useAuthStore((s) => s.usuario)
  const rol = usuario?.rol ?? 'Cliente'
  const { sectionItems, sectionLabel } = getNavigation(rol)

  const initials = (usuario?.nombre ?? 'U')
    .split(' ')
    .map((w) => w[0])
    .slice(0, 2)
    .join('')
    .toUpperCase()

  const rolLabel: Record<string, string> = {
    Admin: 'Administrador',
    AdministradorBarberia: 'Admin Barbería',
    Barbero: 'Barbero',
    Cliente: 'Cliente',
  }

  return (
    <>
      <div
        className={[
          'fixed inset-0 z-30 bg-black/45 backdrop-blur-sm transition duration-200 lg:hidden',
          open ? 'pointer-events-auto opacity-100' : 'pointer-events-none opacity-0',
        ].join(' ')}
        onClick={onClose}
        aria-hidden="true"
      />
      <aside
        className={[
          'surface-panel fixed inset-y-3 left-3 z-40 flex w-[292px] max-w-[calc(100vw-1.5rem)] flex-col rounded-[28px] px-3 py-3 transition duration-300 lg:static lg:inset-auto lg:ml-4 lg:mt-4 lg:h-[calc(100dvh-2rem)] lg:w-[288px] lg:translate-x-0',
          open ? 'translate-x-0' : '-translate-x-[115%] lg:translate-x-0',
        ].join(' ')}
      >
        <div className="flex items-start justify-between gap-3 rounded-[24px] border border-[var(--border-subtle)] bg-[var(--surface-overlay)] px-4 py-4">
          <div>
            <div className="mb-3 inline-flex h-11 w-11 items-center justify-center rounded-2xl bg-[var(--accent-soft)] text-[var(--accent)]">
              <Home className="h-5 w-5" />
            </div>
            <p className="font-display text-[1.4rem] text-[var(--text-strong)]">Barber Admin</p>
            <p className="mt-1 text-xs text-[var(--text-muted)]">Gestión elegante para operaciones diarias</p>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="inline-flex h-9 w-9 items-center justify-center rounded-full border border-[var(--border-subtle)] text-[var(--text-muted)] transition hover:border-[var(--accent)] hover:text-[var(--accent)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--focus-ring)] lg:hidden"
            aria-label="Cerrar navegación"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        <nav className="flex-1 space-y-5 overflow-y-auto px-1 py-5">
          <div className="space-y-1">
            <SectionTitle>Principal</SectionTitle>
            {principalItems.map((item) => (
              <SidebarItem key={item.to} item={item} />
            ))}
          </div>

          <div className="space-y-1">
            <SectionTitle>{sectionLabel}</SectionTitle>
            {sectionItems.map((item) => (
              <SidebarItem key={item.to} item={item} />
            ))}
          </div>
        </nav>

        <div className="rounded-[24px] border border-[var(--border-subtle)] bg-[var(--surface-overlay)] p-4">
          <div className="flex items-center gap-3">
            <div className="flex h-11 w-11 items-center justify-center rounded-full bg-[var(--accent-soft)] text-sm font-semibold text-[var(--accent)]">
              {initials}
            </div>
            <div>
              <p className="text-sm font-semibold text-[var(--text-strong)]">{usuario?.nombre ?? 'Usuario'}</p>
              <p className="text-xs text-[var(--text-muted)]">{rolLabel[rol] ?? rol}</p>
            </div>
          </div>
        </div>
      </aside>
    </>
  )
}

export function MobileBottomNav() {
  const usuario = useAuthStore((s) => s.usuario)
  const rol = usuario?.rol ?? 'Cliente'
  const navigate = useNavigate()
  const { mobileItems } = getNavigation(rol)
  const items = [...principalItems, ...mobileItems].slice(0, 4)

  return (
    <nav className="surface-panel fixed inset-x-4 bottom-4 z-20 flex items-center justify-between rounded-[24px] px-2 py-2 lg:hidden">
      {items.map((item) => (
        <button
          key={item.to}
          type="button"
          onClick={() => navigate(item.to)}
          className="flex min-w-0 flex-1 flex-col items-center gap-1 rounded-2xl px-2 py-2 text-[10px] font-semibold text-[var(--text-muted)] transition hover:bg-[var(--surface-hover)] hover:text-[var(--text-strong)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--focus-ring)]"
        >
          <span className="flex h-9 w-9 items-center justify-center rounded-xl bg-[var(--surface-overlay)] text-current">
            {item.icon}
          </span>
          <span className="truncate">{item.label}</span>
        </button>
      ))}
    </nav>
  )
}
