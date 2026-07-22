import { useId, type ReactNode } from 'react'

import { useDialogFocus } from '../../hooks/useDialogFocus'

type ModalProps = {
  open: boolean
  onClose: () => void
  title: string
  children: ReactNode
  size?: 'sm' | 'md' | 'lg'
}

const widthMap: Record<NonNullable<ModalProps['size']>, string> = {
  sm: '400px',
  md: '580px',
  lg: '860px',
}

function XIcon() {
  return (
    <svg viewBox="0 0 16 16" className="h-4 w-4" fill="none" aria-hidden="true">
      <path d="M3 3l10 10M13 3L3 13" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
    </svg>
  )
}

export function Modal({ open, onClose, title, children, size = 'md' }: ModalProps) {
  const titleId = useId()
  const dialogRef = useDialogFocus(open, onClose)

  if (!open) return null

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center p-3 sm:items-center sm:p-4">
      {/* Backdrop */}
      <div className="absolute inset-0 bg-[var(--modal-backdrop)] backdrop-blur-md" onClick={onClose} aria-hidden="true" />

      <div
        ref={dialogRef}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        tabIndex={-1}
        className="surface-panel premium-ring relative z-10 flex w-full flex-col overflow-hidden rounded-[28px] border border-[var(--border-2)] focus:outline-none"
        style={{ maxWidth: widthMap[size], maxHeight: 'calc(100dvh - 1.5rem)' }}
      >
        <div className="flex shrink-0 items-center justify-between gap-3 border-b border-[var(--border-subtle)] px-6 py-5">
          <div className="flex items-center gap-2.5">
            <span className="h-2 w-2 rounded-full bg-[var(--accent)]" />
            <h3 id={titleId} className="font-display text-xl text-[var(--text-strong)]">
              {title}
            </h3>
          </div>
          <button
            type="button"
            onClick={onClose}
            aria-label="Cerrar"
            className="flex h-9 w-9 items-center justify-center rounded-full border border-[var(--border-subtle)] text-[var(--text-faint)] transition hover:bg-[var(--surface-hover)] hover:text-[var(--text-strong)]"
          >
            <XIcon />
          </button>
        </div>

        <div className="overflow-y-auto px-6 py-5">{children}</div>
      </div>
    </div>
  )
}
