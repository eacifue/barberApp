import { useState } from 'react'
import { Menu } from 'lucide-react'

import { useAuthStore } from '../../stores/authStore'
import { useTheme } from '../theme/ThemeProvider'
import { useLogout } from '../../hooks/useLogout'
import { Modal } from '../ui/Modal'
import { SearchInput } from '../ui/SearchInput'

type TopbarProps = {
  title: string
  onToggleNavigation?: () => void
}

function LogoutIcon() {
  return (
    <svg viewBox="0 0 24 24" className="h-4 w-4" fill="none" aria-hidden="true">
      <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" stroke="currentColor" strokeWidth="1.6" />
      <polyline points="16 17 21 12 16 7" stroke="currentColor" strokeWidth="1.6" />
      <line x1="21" y1="12" x2="9" y2="12" stroke="currentColor" strokeWidth="1.6" />
    </svg>
  )
}

export function Topbar({ title, onToggleNavigation }: TopbarProps) {
  const [isLogoutOpen, setIsLogoutOpen] = useState(false)
  const { theme, toggleTheme } = useTheme()
  const logout = useLogout()
  const usuario = useAuthStore((s) => s.usuario)

  const handleLogoutConfirm = () => {
    setIsLogoutOpen(false)
    logout()
  }

  return (
    <>
      <header className="flex h-16 items-center gap-3 border-b border-[var(--border-subtle)] bg-[var(--surface-elevated)] px-4 py-3 md:px-6">
        <button
          type="button"
          onClick={onToggleNavigation}
          className="inline-flex h-10 w-10 items-center justify-center rounded-full border border-[var(--border-strong)] bg-[var(--surface-overlay)] text-[var(--text-base)] transition duration-200 hover:border-brass-ink hover:text-brass-ink focus-visible:outline-none focus-visible:shadow-focus lg:hidden"
          aria-label="Abrir navegación"
        >
          <Menu className="h-4 w-4" />
        </button>
        <h1 className="mr-auto font-display text-lg text-[var(--text-strong)] md:text-xl">{title}</h1>
        <div className="hidden md:block">
          <SearchInput placeholder="Buscar clientes, citas o módulos" />
        </div>
        <button
          type="button"
          onClick={toggleTheme}
          className="inline-flex h-10 w-10 items-center justify-center rounded-full border border-[var(--border-strong)] bg-[var(--surface-overlay)] text-[var(--text-base)] transition duration-200 hover:border-brass-ink hover:text-brass-ink focus-visible:outline-none focus-visible:shadow-focus"
          aria-label={theme === 'dark' ? 'Activar modo claro' : 'Activar modo oscuro'}
          title={theme === 'dark' ? 'Activar modo claro' : 'Activar modo oscuro'}
        >
          {theme === 'dark' ? (
            <svg viewBox="0 0 24 24" className="h-4 w-4" fill="none" aria-hidden="true">
              <circle cx="12" cy="12" r="4" stroke="currentColor" strokeWidth="1.7" />
              <path d="M12 2.75v2.5M12 18.75v2.5M21.25 12h-2.5M5.25 12h-2.5M18.54 5.46l-1.77 1.77M7.23 16.77l-1.77 1.77M18.54 18.54l-1.77-1.77M7.23 7.23L5.46 5.46" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" />
            </svg>
          ) : (
            <svg viewBox="0 0 24 24" className="h-4 w-4" fill="none" aria-hidden="true">
              <path d="M20.2 14.1a8.25 8.25 0 1 1-10.3-10.3 7 7 0 1 0 10.3 10.3Z" stroke="currentColor" strokeWidth="1.7" strokeLinejoin="round" />
            </svg>
          )}
        </button>

        <div className="hidden items-center gap-2 rounded-full border border-[var(--border-strong)] bg-[var(--surface-overlay)] px-3 py-1.5 md:flex">
          <span className="text-xs text-[var(--text-ink-muted)]">{usuario?.nombre ?? 'Usuario'}</span>
          <span className="text-[10px] font-medium text-brass-ink">
            {usuario?.rol ?? ''}
          </span>
          <button
            type="button"
            onClick={() => setIsLogoutOpen(true)}
            className="ml-1 rounded-full p-1 text-[var(--text-ink-muted)] transition-colors hover:bg-[var(--surface-hover)] hover:text-[var(--danger)]"
            aria-label="Cerrar sesión"
            title="Cerrar sesión"
          >
            <LogoutIcon />
          </button>
        </div>
      </header>

      <Modal open={isLogoutOpen} title="Confirmar cierre de sesión" onClose={() => setIsLogoutOpen(false)}>
        <div className="space-y-4">
          <p className="text-sm text-[var(--text-ink-muted)]">¿Estás seguro de que deseas cerrar sesión?</p>
          <div className="flex justify-end gap-2">
            <button
              type="button"
              onClick={() => setIsLogoutOpen(false)}
              className="rounded-xl border border-[var(--border-strong)] px-4 py-2 text-sm text-[var(--text-ink-muted)] transition-colors hover:bg-[var(--surface-hover)] hover:text-[var(--text-strong)]"
            >
              Cancelar
            </button>
            <button
              type="button"
              onClick={handleLogoutConfirm}
              className="rounded-xl bg-[var(--danger)] px-4 py-2 text-sm font-semibold text-danger-on transition hover:opacity-92"
            >
              Cerrar sesión
            </button>
          </div>
        </div>
      </Modal>
    </>
  )
}

