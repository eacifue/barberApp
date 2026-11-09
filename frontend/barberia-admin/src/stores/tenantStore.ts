import { create } from 'zustand'
import { persist } from 'zustand/middleware'

type TenantState = {
  /** Solo SuperAdmin: barbería con la que trabaja; `null` = todas (vista consolidada). */
  barberiaElegida: string | null
  elegir: (id: string | null) => void
}

export const useTenantStore = create<TenantState>()(
  persist(
    (set) => ({
      barberiaElegida: null,
      elegir: (id) => set({ barberiaElegida: id }),
    }),
    { name: 'barberia-elegida' },
  ),
)
