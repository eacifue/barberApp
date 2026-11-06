import { useId, type FC } from 'react'
import { Button } from './Button'
import { useDialogFocus } from '../../hooks/useDialogFocus'

type ConfirmVariant = 'danger' | 'warning' | 'info'

type ConfirmDialogProps = {
  open: boolean
  onClose: () => void
  onConfirm: () => void | Promise<void>
  title: string
  message: string
  variant?: ConfirmVariant
  confirmLabel?: string
  loading?: boolean
}

function TrashIcon() {
  return (
    <svg viewBox="0 0 24 24" className="h-6 w-6" fill="none" aria-hidden="true">
      <path d="M3 6h18M8 6V4h8v2M19 6l-1 14H6L5 6" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round" />
      <path d="M10 11v5M14 11v5" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" />
    </svg>
  )
}

function WarningIcon() {
  return (
    <svg viewBox="0 0 24 24" className="h-6 w-6" fill="none" aria-hidden="true">
      <path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z" stroke="currentColor" strokeWidth="1.7" strokeLinejoin="round" />
      <path d="M12 9v5M12 17.5v.5" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
    </svg>
  )
}

function InfoIcon() {
  return (
    <svg viewBox="0 0 24 24" className="h-6 w-6" fill="none" aria-hidden="true">
      <circle cx="12" cy="12" r="9" stroke="currentColor" strokeWidth="1.7" />
      <path d="M12 11v5M12 8.5v.5" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
    </svg>
  )
}

const variantConfig: Record<
  ConfirmVariant,
  { icon: FC; iconBg: string; iconColor: string; accent: string; confirmClass: string }
> = {
  danger: {
    icon: TrashIcon,
    iconBg: 'bg-[var(--danger-soft)]',
    iconColor: 'text-[var(--danger)]',
    accent: 'border-[var(--danger)]/30',
    confirmClass:
      'bg-[var(--danger)] text-danger-on hover:opacity-90',
  },
  warning: {
    icon: WarningIcon,
    iconBg: 'bg-[var(--warning-soft)]',
    iconColor: 'text-[var(--warning)]',
    accent: 'border-[var(--warning)]/30',
    confirmClass:
      'bg-[var(--warning)] text-inverse-on hover:opacity-90',
  },
  info: {
    icon: InfoIcon,
    iconBg: 'bg-[var(--info-soft)]',
    iconColor: 'text-[var(--info)]',
    accent: 'border-[var(--info)]/30',
    confirmClass:
      'bg-[var(--info)] text-inverse-on hover:opacity-90',
  },
}

export function ConfirmDialog({
  open,
  onClose,
  onConfirm,
  title,
  message,
  variant = 'danger',
  confirmLabel,
  loading = false,
}: ConfirmDialogProps) {
  const titleId = useId()
  const handleClose = () => {
    if (!loading) onClose()
  }
  const dialogRef = useDialogFocus(open, handleClose)

  if (!open) return null

  const cfg = variantConfig[variant]
  const IconComponent = cfg.icon
  const label = confirmLabel ?? (variant === 'danger' ? 'Eliminar' : 'Confirmar')

  return (
    <div className="fixed inset-0 z-[60] flex items-center justify-center p-4">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-[var(--modal-backdrop)]"
        onClick={handleClose}
        aria-hidden="true"
      />

      {/* Panel */}
      <div
        ref={dialogRef}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        tabIndex={-1}
        className={[
          'surface-card premium-ring relative z-10 w-full max-w-[420px] rounded-2xl border border-[var(--border-2)] p-6 text-[var(--text-base)] focus:outline-none',
          cfg.accent,
        ].join(' ')}
      >
        {/* Icon + title */}
        <div className="flex items-start gap-4">
          <div
            className={[
              'flex h-12 w-12 shrink-0 items-center justify-center rounded-xl',
              cfg.iconBg,
              cfg.iconColor,
            ].join(' ')}
          >
            <IconComponent />
          </div>

          <div className="min-w-0 flex-1">
            <h4 id={titleId} className="font-display text-base font-semibold text-[var(--text-strong)]">
              {title}
            </h4>
            <p className="mt-1.5 text-sm leading-relaxed text-[var(--text-ink-muted)]">{message}</p>
          </div>
        </div>

        {/* Divider */}
        <div className="my-5 h-px bg-[var(--border)]" />

        {/* Actions */}
        <div className="flex items-center justify-end gap-2.5">
          <Button variant="ghost" size="sm" onClick={onClose} disabled={loading}>
            Cancelar
          </Button>

          <button
            type="button"
            onClick={onConfirm}
            disabled={loading}
            className={[
              'inline-flex h-9 items-center gap-2 rounded-lg px-4 text-sm font-medium transition',
              'focus-visible:outline-none',
              'disabled:cursor-not-allowed disabled:opacity-50',
              cfg.confirmClass,
            ].join(' ')}
          >
            {loading ? (
              <svg className="h-4 w-4 animate-spin" viewBox="0 0 24 24" fill="none">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z" />
              </svg>
            ) : null}
            {label}
          </button>
        </div>
      </div>
    </div>
  )
}
