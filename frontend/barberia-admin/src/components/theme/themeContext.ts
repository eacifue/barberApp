import { createContext, useContext } from 'react'

import type { ResolvedTheme, ThemeChoice } from '../../theme'

export type ThemeContextValue = {
  /** Tema aplicado ahora mismo. */
  theme: ResolvedTheme
  /** Elección guardada: claro, oscuro o seguir al sistema. */
  choice: ThemeChoice
  setChoice: (choice: ThemeChoice) => void
  toggleTheme: () => void
}

export const ThemeContext = createContext<ThemeContextValue | null>(null)

export function useTheme() {
  const context = useContext(ThemeContext)
  if (!context) {
    throw new Error('useTheme debe usarse dentro de ThemeProvider')
  }
  return context
}
