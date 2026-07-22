import { create } from 'zustand'

type UIState = {
  sidebarCollapsed: boolean
  pageTitle: string
  setPageTitle: (title: string) => void
  toggleSidebar: () => void
}

export const useUIStore = create<UIState>((set) => ({
  sidebarCollapsed: false,
  pageTitle: 'Dashboard',
  setPageTitle: (pageTitle) => set({ pageTitle }),
  toggleSidebar: () => set((state) => ({ sidebarCollapsed: !state.sidebarCollapsed })),
}))
