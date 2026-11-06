import { create } from 'zustand'

export type ToastVariant = 'success' | 'error' | 'info' | 'warning'

export type ToastAction = { label: string; onAction: () => void }

export type Toast = {
  id: string
  message: string
  variant: ToastVariant
  action?: ToastAction
}

type ToastState = {
  toasts: Toast[]
  push: (message: string, variant?: ToastVariant, action?: ToastAction) => void
  dismiss: (id: string) => void
}

function uid() {
  return Math.random().toString(36).slice(2, 9)
}

let timer: ReturnType<typeof setTimeout> | undefined

// Sistema: un solo aviso a la vez (el nuevo reemplaza al anterior); 4 s, o 6 s con acción.
export const useToastStore = create<ToastState>((set) => ({
  toasts: [],
  push(message, variant = 'success', action) {
    const id = uid()
    if (timer) clearTimeout(timer)
    set({ toasts: [{ id, message, variant, action }] })
    timer = setTimeout(() => {
      set((s) => ({ toasts: s.toasts.filter((t) => t.id !== id) }))
    }, action ? 6000 : 4000)
  },
  dismiss(id) {
    set((s) => ({ toasts: s.toasts.filter((t) => t.id !== id) }))
  },
}))

// helpers rápidos
export const toast = {
  success: (msg: string, action?: ToastAction) => useToastStore.getState().push(msg, 'success', action),
  error: (msg: string, action?: ToastAction) => useToastStore.getState().push(msg, 'error', action),
  info: (msg: string, action?: ToastAction) => useToastStore.getState().push(msg, 'info', action),
  warning: (msg: string, action?: ToastAction) => useToastStore.getState().push(msg, 'warning', action),
}
