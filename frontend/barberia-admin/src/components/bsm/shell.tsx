import type { ReactNode } from 'react'
import { NavLink } from 'react-router-dom'

import type { ThemeChoice } from '../../theme'
import { Avatar, IconButton } from './controls'
import { cx, formatTime, parseHM } from './format'
import { Icon, Logo } from './Icon'
import type { IconName } from './icons'
import { STATUS, type AppointmentStatus } from './constants'

/* ---------- Navegación ---------- */

export type NavItem = { icon: IconName; label: string; to: string; count?: number; badge?: boolean; end?: boolean }
export type NavSection = { title: string; items: NavItem[] }

type SidebarProps = {
  sections: NavSection[]
  user?: { name: string; role: string; photo?: string | null }
  onLogout?: () => void
  onNavigate?: () => void
  className?: string
}

/** Logo, secciones por rol, activo en `brass-soft` (sin barra lateral de color) y usuario. */
export function Sidebar({ sections, user, onLogout, onNavigate, className }: SidebarProps) {
  return (
    <aside className={cx('bsm-sidebar', className)} aria-label="Navegación principal">
      <div className="bsm-sidebar-brand">
        <Logo variant="horizontal" height={36} />
      </div>
      <nav className="bsm-sidebar-nav">
        {sections.map((sec) => (
          <div key={sec.title} className="bsm-sidebar-sec">
            <p className="bsm-overline bsm-sidebar-title">{sec.title}</p>
            <ul>
              {sec.items.map((it) => (
                <li key={it.to}>
                  <NavLink to={it.to} end={it.end} onClick={onNavigate} className={({ isActive }) => cx('bsm-navitem', isActive && 'is-active')}>
                    <Icon name={it.icon} size={20} />
                    <span>{it.label}</span>
                    {it.count != null && it.count > 0 && (
                      <span className="bsm-navitem-count" aria-label={`${it.count} pendientes`}>
                        {it.count}
                      </span>
                    )}
                  </NavLink>
                </li>
              ))}
            </ul>
          </div>
        ))}
      </nav>
      {user && (
        <div className="bsm-sidebar-user">
          <Avatar name={user.name} src={user.photo} size={40} />
          <div className="bsm-sidebar-who">
            <strong>{user.name}</strong>
            <span>{user.role}</span>
          </div>
          {onLogout && <IconButton icon="log-out" label="Cerrar sesión" size="sm" onClick={onLogout} />}
        </div>
      )}
    </aside>
  )
}

type TopbarProps = {
  title?: string
  search?: ReactNode
  /** Contexto de trabajo junto a las acciones (selector de barbería del SuperAdmin). */
  context?: ReactNode
  theme: 'light' | 'dark'
  onThemeChange: (choice: ThemeChoice) => void
  unread?: boolean
  onNotifications?: () => void
  onLogout?: () => void
  /** Móvil: botón de menú, sin cerrar sesión (vive en el menú). */
  compact?: boolean
  onMenu?: () => void
}

/** Título de página en Gloock, búsqueda, tema, notificaciones y cerrar sesión. */
export function Topbar({ title, search, context, theme, onThemeChange, unread, onNotifications, onLogout, compact, onMenu }: TopbarProps) {
  return (
    <header className="bsm-topbar">
      {compact && <IconButton icon="menu" label="Abrir menú" onClick={onMenu} />}
      {title && <h1 className="bsm-topbar-title">{title}</h1>}
      {search ?? <span className="flex-1" aria-hidden="true" />}
      <div className="bsm-topbar-actions">
        {context}
        <div className="bsm-tabs bsm-tabs-segmented bsm-theme-toggle" role="radiogroup" aria-label="Tema">
          {(
            [
              ['light', 'sun', 'Tema claro', 'claro'],
              ['dark', 'moon', 'Tema oscuro', 'oscuro'],
            ] as const
          ).map(([value, icon, label, choice]) => (
            <button
              key={value}
              type="button"
              role="radio"
              aria-checked={theme === value}
              aria-label={label}
              title={label}
              className={cx('bsm-tab', theme === value && 'is-active')}
              onClick={() => onThemeChange(choice)}
            >
              <Icon name={icon} size={18} />
            </button>
          ))}
        </div>
        {onNotifications && <IconButton icon="bell" label="Notificaciones" badge={unread} onClick={onNotifications} />}
        {!compact && onLogout && <IconButton icon="log-out" label="Cerrar sesión" onClick={onLogout} />}
      </div>
    </header>
  )
}

export type BottomNavAction = { icon: IconName; label: string; onClick: () => void; badge?: boolean }

type BottomNavProps = { items: Array<NavItem | BottomNavAction>; floating?: boolean; className?: string }

/** Panel en celular: barra flotante con Inicio, Agenda, Clientes, Más. */
export function BottomNav({ items, floating, className }: BottomNavProps) {
  const content = (it: NavItem | BottomNavAction) => (
    <>
      <span className="bsm-bottomnav-pill">
        <Icon name={it.icon} size={24} />
        {it.badge && <span className="bsm-iconbtn-dot" />}
      </span>
      <span className="bsm-bottomnav-label">{it.label}</span>
    </>
  )
  return (
    <nav className={cx('bsm-bottomnav', floating && 'is-floating', className)} aria-label="Navegación">
      {items.map((it) =>
        'to' in it ? (
          <NavLink key={it.to} to={it.to} end={it.end} className={({ isActive }) => cx('bsm-bottomnav-item', isActive && 'is-active')}>
            {content(it)}
          </NavLink>
        ) : (
          <button key={it.label} type="button" className="bsm-bottomnav-item bsm-bottomnav-btn" onClick={it.onClick}>
            {content(it)}
          </button>
        ),
      )}
    </nav>
  )
}

/* ---------- Agenda ---------- */

export type AgendaItem = {
  id?: string
  client?: string
  service?: string
  /** `HH:mm` */
  start: string
  end: string
  status?: AppointmentStatus
  /** Bloqueo (almuerzo, permiso): rayado neutro con candado. */
  block?: boolean
  selected?: boolean
}

export type AgendaColumn = {
  id?: string
  name: string
  photo?: string | null
  count?: number
  sub?: string
  /** `false` en la vista Semana (columnas por día). */
  avatar?: boolean
  /** Hoy, en la vista Semana. */
  current?: boolean
  items: AgendaItem[]
}

type AgendaBoardProps = {
  columns: AgendaColumn[]
  start?: string
  end?: string
  /** `HH:mm`; dibuja la línea de ahora. */
  now?: string
  pxPerMin?: number
  onItemClick?: (item: AgendaItem, column: AgendaColumn) => void
  /** Tocar un hueco: crea cita con barbero y hora precargados (hora redondeada a 15 min). */
  onSlotClick?: (column: AgendaColumn, time: string) => void
}

const toHM = (m: number) => `${String(Math.floor(m / 60)).padStart(2, '0')}:${String(m % 60).padStart(2, '0')}`

/** Bloques a escala real; el estado se distingue sin color (borde punteado, doble, rayado). */
export function AgendaBoard({ columns, start = '09:00', end = '20:00', now, pxPerMin = 1.2, onItemClick, onSlotClick }: AgendaBoardProps) {
  const s0 = parseHM(start)
  const s1 = parseHM(end)
  const hours: number[] = []
  for (let t = s0; t <= s1; t += 60) hours.push(t)
  const nowM = now != null ? parseHM(now) : null
  return (
    <div className="bsm-agenda" style={{ ['--cols' as string]: columns.length }}>
      <div className="bsm-agenda-head">
        <span className="bsm-agenda-corner" />
        {columns.map((c) => (
          <div key={c.id ?? c.name} className={cx('bsm-agenda-barber', c.current && 'is-current')}>
            {c.avatar !== false && <Avatar name={c.name} src={c.photo} size={32} />}
            <span>
              <strong>{c.name}</strong>
              <span className="bsm-meta">{c.sub ?? `${c.count ?? c.items.filter((i) => !i.block).length} citas`}</span>
            </span>
          </div>
        ))}
      </div>
      <div className="bsm-agenda-body" style={{ height: (s1 - s0) * pxPerMin }}>
        <div className="bsm-agenda-axis">
          {hours.map((t) => (
            <span key={t} style={{ top: (t - s0) * pxPerMin }}>
              {formatTime(t).replace(':00', '')}
            </span>
          ))}
        </div>
        <div className="bsm-agenda-cols">
          {hours.map((t) => (
            <span key={`l${t}`} className="bsm-agenda-hline" style={{ top: (t - s0) * pxPerMin }} />
          ))}
          {columns.map((c) => (
            <div
              key={c.id ?? c.name}
              className="bsm-agenda-col"
              onClick={
                onSlotClick
                  ? (e) => {
                      if (e.target !== e.currentTarget) return
                      const y = e.nativeEvent.offsetY
                      const m = s0 + Math.floor(y / pxPerMin / 15) * 15
                      onSlotClick(c, toHM(Math.min(m, s1 - 15)))
                    }
                  : undefined
              }
            >
              {c.items.map((a, i) => {
                const s = parseHM(a.start)
                const e = parseHM(a.end)
                const st = a.block ? null : STATUS[a.status ?? 'Pendiente']
                const short = (e - s) * pxPerMin < 44
                const label = a.block
                  ? `Bloqueado ${formatTime(s)} a ${formatTime(e)}${a.client ? `, ${a.client}` : ''}`
                  : `${a.client}, ${a.service}, ${formatTime(s)} a ${formatTime(e)}, ${st!.label}`
                return (
                  <button
                    key={a.id ?? i}
                    type="button"
                    className={cx('bsm-agenda-item', a.block ? 'is-block' : `bsm-status-${st!.key}`, short && 'is-short', a.selected && 'is-selected')}
                    style={{ top: (s - s0) * pxPerMin + 1, height: (e - s) * pxPerMin - 2 }}
                    aria-label={label}
                    aria-pressed={a.selected || undefined}
                    onClick={() => onItemClick?.(a, c)}
                  >
                    <span className="bsm-agenda-item-top">
                      <strong>{a.block ? a.client || 'Bloqueado' : a.client}</strong>
                      <Icon name={st ? st.icon : 'lock'} size={14} strokeWidth={st ? 2.25 : 2} />
                    </span>
                    {!short && (
                      <span className="bsm-agenda-item-sub">
                        {a.service ? `${a.service} · ` : ''}
                        {formatTime(s, true)}–{formatTime(e, true)}
                      </span>
                    )}
                  </button>
                )
              })}
            </div>
          ))}
          {nowM != null && nowM >= s0 && nowM <= s1 && (
            <div className="bsm-agenda-now" style={{ top: (nowM - s0) * pxPerMin }}>
              <span>{formatTime(nowM)}</span>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
