import type { ButtonHTMLAttributes, ReactNode } from 'react'
import clsx from 'clsx'

type ButtonVariant = 'gold' | 'ghost' | 'danger'
type ButtonSize = 'sm' | 'md' | 'lg'

type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  children: ReactNode
  variant?: ButtonVariant
  size?: ButtonSize
  loading?: boolean
}

export function Button({
  variant = 'gold',
  size = 'md',
  loading = false,
  className,
  children,
  disabled,
  ...props
}: ButtonProps) {
  const isDisabled = disabled || loading

  return (
    <button
      type="button"
      disabled={isDisabled}
      className={clsx(
        'inline-flex items-center justify-center gap-2 rounded-full font-semibold transition duration-200 focus-visible:outline-none focus-visible:shadow-focus disabled:cursor-not-allowed disabled:opacity-60',
        {
          'bg-brass text-brass-on hover:bg-brass-strong': variant === 'gold',
          'border border-[var(--border-strong)] bg-[var(--surface-overlay)] text-[var(--text-base)] hover:bg-[var(--surface-hover)]':
            variant === 'ghost',
          'border border-danger bg-[var(--danger-soft)] text-[var(--danger)] hover:bg-surface-sunken':
            variant === 'danger',
        },
        {
          'h-9 px-4 text-xs': size === 'sm',
          'h-11 px-5 text-sm': size === 'md',
          'h-12 px-6 text-base': size === 'lg',
        },
        className,
      )}
      {...props}
    >
      {loading ? (
        <span
          className="inline-block h-3.5 w-3.5 animate-spin rounded-full border-2 border-current border-r-transparent"
          aria-hidden="true"
        />
      ) : null}
      {children}
    </button>
  )
}
