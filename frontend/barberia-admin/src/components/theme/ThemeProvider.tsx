import { useEffect, useMemo, useState, type ReactNode } from 'react'

import {
  getThemeChoice,
  initTheme,
  resolveTheme,
  setThemeChoice,
  type ResolvedTheme,
  type ThemeChoice,
} from '../../theme'
import { ThemeContext, type ThemeContextValue } from './themeContext'

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
