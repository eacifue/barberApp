import {
  createContext,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react'

type ThemeMode = 'light' | 'dark'
type ThemePreference = ThemeMode | 'system'

type ThemeContextValue = {
  theme: ThemeMode
  preference: ThemePreference
  setPreference: (preference: ThemePreference) => void
  toggleTheme: () => void
}

const STORAGE_KEY = 'barberia-admin-theme'

const ThemeContext = createContext<ThemeContextValue | null>(null)

function getSystemTheme(): ThemeMode {
  if (typeof window === 'undefined') return 'dark'
  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
}

function resolveTheme(preference: ThemePreference): ThemeMode {
  return preference === 'system' ? getSystemTheme() : preference
}

function getInitialPreference(): ThemePreference {
  if (typeof window === 'undefined') return 'system'

  const stored = window.localStorage.getItem(STORAGE_KEY)
  if (stored === 'light' || stored === 'dark' || stored === 'system') return stored

  return 'system'
}

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [preference, setPreferenceState] = useState<ThemePreference>(() => getInitialPreference())
  const [theme, setTheme] = useState<ThemeMode>(() => resolveTheme(getInitialPreference()))

  useEffect(() => {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')

    const applyTheme = (nextPreference: ThemePreference) => {
      const nextTheme = resolveTheme(nextPreference)
      setTheme(nextTheme)
      document.documentElement.dataset.theme = nextTheme
      document.documentElement.style.colorScheme = nextTheme
    }

    applyTheme(preference)
    window.localStorage.setItem(STORAGE_KEY, preference)

    const handleChange = () => {
      if (preference === 'system') {
        applyTheme('system')
      }
    }

    mediaQuery.addEventListener('change', handleChange)
    return () => mediaQuery.removeEventListener('change', handleChange)
  }, [preference])

  const value = useMemo<ThemeContextValue>(
    () => ({
      theme,
      preference,
      setPreference: setPreferenceState,
      toggleTheme: () => {
        setPreferenceState((current) => {
          const resolved = resolveTheme(current)
          return resolved === 'dark' ? 'light' : 'dark'
        })
      },
    }),
    [preference, theme],
  )

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>
}

export function useTheme() {
  const context = useContext(ThemeContext)
  if (!context) {
    throw new Error('useTheme debe usarse dentro de ThemeProvider')
  }

  return context
}