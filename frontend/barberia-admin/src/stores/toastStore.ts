import { create } from 'zustand'

export type ToastVariant = 'success' | 'error' | 'info' | 'warning'

export type Toast = {
  id: string
  message: string
  variant: ToastVariant
}

type ToastState = {
  toasts: Toast[]
  push: (message: string, variant?: ToastVariant) => void
  dismiss: (id: string) => void
}

function uid() {
  return Math.random().toString(36).slice(2, 9)
}

export const useToastStore = create<ToastState>((set) => ({
  toasts: [],
  push(message, variant = 'success') {
    const id = uid()
    set((s) => ({ toasts: [...s.toasts, { id, message, variant }] }))
    setTimeout(() => {
      set((s) => ({ toasts: s.toasts.filter((t) => t.id !== id) }))
    }, 4000)
  },
  dismiss(id) {
    set((s) => ({ toasts: s.toasts.filter((t) => t.id !== id) }))
  },
}))

// helpers rápidos
export const toast = {
  success: (msg: string) => useToastStore.getState().push(msg, 'success'),
  error: (msg: string) => useToastStore.getState().push(msg, 'error'),
  info: (msg: string) => useToastStore.getState().push(msg, 'info'),
  warning: (msg: string) => useToastStore.getState().push(msg, 'warning'),
}
