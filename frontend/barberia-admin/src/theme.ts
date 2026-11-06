// Tema claro / oscuro / sistema del panel (design/web/src/theme.js).
// Guarda la elección y aplica data-theme en <html>; los tokens de globals.css
// cambian con ese atributo.

export type ThemeChoice = 'claro' | 'oscuro' | 'sistema'
export type ResolvedTheme = 'light' | 'dark'

const KEY = 'bsm-theme'
const LEGACY_KEY = 'barberia-admin-theme'
const LEGACY_MAP: Record<string, ThemeChoice> = { light: 'claro', dark: 'oscuro', system: 'sistema' }

const media = () => window.matchMedia('(prefers-color-scheme: dark)')

function isChoice(value: unknown): value is ThemeChoice {
  return value === 'claro' || value === 'oscuro' || value === 'sistema'
}

export function getThemeChoice(): ThemeChoice {
  try {
    const stored = localStorage.getItem(KEY)
    if (isChoice(stored)) return stored
    const legacy = localStorage.getItem(LEGACY_KEY)
    if (legacy && LEGACY_MAP[legacy]) return LEGACY_MAP[legacy]
  } catch {
    // Almacenamiento bloqueado (modo privado): se usa el del sistema.
  }
  return 'sistema'
}

export function resolveTheme(choice: ThemeChoice): ResolvedTheme {
  return choice === 'oscuro' || (choice === 'sistema' && media().matches) ? 'dark' : 'light'
}

function apply(choice: ThemeChoice): ResolvedTheme {
  const resolved = resolveTheme(choice)
  document.documentElement.dataset.theme = resolved
  return resolved
}

export function setThemeChoice(choice: ThemeChoice): ResolvedTheme {
  try {
    localStorage.setItem(KEY, choice)
    localStorage.removeItem(LEGACY_KEY)
  } catch {
    // Sin persistencia: el tema se aplica solo en esta sesión.
  }
  return apply(choice)
}

/** Aplica el tema guardado y sigue al sistema mientras la elección sea «sistema». */
export function initTheme(onChange?: (theme: ResolvedTheme) => void): () => void {
  apply(getThemeChoice())
  const mq = media()
  const handle = () => {
    if (getThemeChoice() === 'sistema') onChange?.(apply('sistema'))
  }
  mq.addEventListener('change', handle)
  return () => mq.removeEventListener('change', handle)
}
