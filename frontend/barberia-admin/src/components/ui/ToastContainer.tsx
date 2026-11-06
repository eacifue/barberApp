import { CircleAlert, CircleCheckBig, CircleX, Info, X } from 'lucide-react'

import { useToastStore, type ToastVariant } from '../../stores/toastStore'

const icons: Record<ToastVariant, typeof CircleCheckBig> = {
  success: CircleCheckBig,
  error: CircleX,
  warning: CircleAlert,
  info: Info,
}

const styles: Record<ToastVariant, { bar: string; icon: string; bg: string }> = {
  success: {
    bg: 'bg-[var(--surface-elevated)] border-[var(--border-subtle)]',
    bar: 'bg-[var(--success)]',
    icon: 'text-[var(--success)] bg-[var(--success-soft)]',
  },
  error: {
    bg: 'bg-[var(--surface-elevated)] border-[var(--border-subtle)]',
    bar: 'bg-[var(--danger)]',
    icon: 'text-[var(--danger)] bg-[var(--danger-soft)]',
  },
  warning: {
    bg: 'bg-[var(--surface-elevated)] border-[var(--border-subtle)]',
    bar: 'bg-[var(--warning)]',
    icon: 'text-[var(--warning)] bg-[var(--warning-soft)]',
  },
  info: {
    bg: 'bg-[var(--surface-elevated)] border-[var(--border-subtle)]',
    bar: 'bg-[var(--info)]',
    icon: 'text-[var(--info)] bg-[var(--info-soft)]',
  },
}

export function ToastContainer() {
  const { toasts, dismiss } = useToastStore()

  if (toasts.length === 0) return null

  return (
    <div className="fixed bottom-5 right-5 z-[100] flex flex-col gap-2.5 w-[340px] max-w-[calc(100vw-2rem)]">
      {toasts.map((t) => {
        const s = styles[t.variant]
        const Icon = icons[t.variant]
        return (
          <div
            key={t.id}
            role="alert"
            className={[
              'relative flex items-start gap-3 overflow-hidden rounded-[22px] border px-4 py-4 shadow-lg',
              s.bg,
            ].join(' ')}
          >
            <span className={['absolute left-0 top-0 h-full w-1 rounded-l-xl', s.bar].join(' ')} />

            <span className={['mt-0.5 flex h-8 w-8 shrink-0 items-center justify-center rounded-full', s.icon].join(' ')}>
              <Icon className="h-4 w-4" />
            </span>

            <p className="flex-1 text-sm leading-snug text-[var(--text-strong)]">{t.message}</p>

            <button
              type="button"
              onClick={() => dismiss(t.id)}
              className="ml-1 mt-0.5 shrink-0 rounded-full text-[var(--text-faint)] transition-colors hover:text-[var(--text-strong)] focus-visible:outline-none focus-visible:shadow-focus"
              aria-label="Cerrar notificación"
            >
              <X className="h-4 w-4" />
            </button>
          </div>
        )
      })}
    </div>
  )
}
