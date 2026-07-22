import type { InputHTMLAttributes } from 'react'

type FormInputProps = InputHTMLAttributes<HTMLInputElement> & {
  label: string
  error?: string
  required?: boolean
  hint?: string
}

export function FormInput({ label, error, required, hint, className, ...props }: FormInputProps) {
  return (
    <label className="flex flex-col gap-2">
      <span className="form-label text-[11px] font-semibold uppercase tracking-[0.18em]">
        {label}
        {required ? <span className="ml-1 text-[var(--danger)]">*</span> : null}
      </span>
      <input
        aria-invalid={Boolean(error)}
        {...props}
        className={[
          'form-control h-12 rounded-2xl px-4 outline-none transition duration-200',
          error ? 'border-[var(--danger)] focus-visible:outline-[rgba(180,79,70,0.2)]' : '',
          className,
        ]
          .filter(Boolean)
          .join(' ')}
      />
      {error ? <span className="form-message-error text-xs">{error}</span> : null}
      {!error && hint ? <span className="text-xs text-[var(--text-muted)]">{hint}</span> : null}
    </label>
  )
}
