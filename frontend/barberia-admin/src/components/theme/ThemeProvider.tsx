import { createContext, useContext, useEffect, useMemo, useState, type ReactNode } from 'react'

import {
  getThemeChoice,
  initTheme,
  resolveTheme,
  setThemeChoice,
  type ResolvedTheme,
  type ThemeChoice,
} from '../../theme'

type ThemeContextValue = {
  /** Tema aplicado ahora mismo. */
  theme: ResolvedTheme
  /** Elección guardada: claro, oscuro o seguir al sistema. */
  choice: ThemeChoice
  setChoice: (choice: ThemeChoice) => void
  toggleTheme: () => void
}

const ThemeContext = createContext<ThemeContextValue | null>(null)

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [choice, setChoiceState] = useState<ThemeChoice>(() => getThemeChoice())
  const [theme, setTheme] = useState<ResolvedTheme>(() => resolveTheme(getThemeChoice()))

  useEffect(() => initTheme(setTheme), [])

  const value = useMemo<ThemeContextValue>(() => {
    const setChoice = (next: ThemeChoice) => {
      setChoiceState(next)
      setTheme(setThemeChoice(next))
    }
    return {
      theme,
      choice,
      setChoice,
      toggleTheme: () => setChoice(theme === 'dark' ? 'claro' : 'oscuro'),
    }
  }, [choice, theme])

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>
}

export function useTheme() {
  const context = useContext(ThemeContext)
  if (!context) {
    throw new Error('useTheme debe usarse dentro de ThemeProvider')
  }
  return context
}
