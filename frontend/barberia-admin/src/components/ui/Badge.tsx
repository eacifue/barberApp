import type { ReactNode } from 'react'
import clsx from 'clsx'

type BadgeVariant = 'success' | 'warning' | 'danger' | 'info' | 'muted'

type BadgeProps = {
  children: ReactNode
  variant?: BadgeVariant
  dot?: boolean
}

export function Badge({ children, variant = 'muted', dot = false }: BadgeProps) {
  return (
    <span
      className={clsx(
        'inline-flex items-center gap-1.5 rounded-full px-3 py-1.5 text-xs font-semibold',
        {
          'bg-[var(--success-soft)] text-[var(--success)]': variant === 'success',
          'bg-[var(--warning-soft)] text-[var(--warning)]': variant === 'warning',
          'bg-[var(--danger-soft)] text-[var(--danger)]': variant === 'danger',
          'bg-[var(--info-soft)] text-[var(--info)]': variant === 'info',
          'bg-[var(--surface-hover)] text-[var(--text-muted)]': variant === 'muted',
        },
      )}
    >
      {dot ? <span className="h-1.5 w-1.5 rounded-full bg-current" aria-hidden="true" /> : null}
      {children}
    </span>
  )
}
