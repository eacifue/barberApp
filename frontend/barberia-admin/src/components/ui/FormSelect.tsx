import type { SelectHTMLAttributes } from 'react'

type Option = {
  label: string
  value: string
}

type FormSelectProps = SelectHTMLAttributes<HTMLSelectElement> & {
  label: string
  options: Option[]
}

export function FormSelect({ label, options, className, ...props }: FormSelectProps) {
  return (
    <label className="flex flex-col gap-2 text-sm text-[var(--text-base)]">
      <span className="form-label text-[11px] font-semibold uppercase tracking-[0.18em]">{label}</span>
      <select
        {...props}
        className={[
          'form-control h-12 rounded-2xl px-4 outline-none transition duration-200',
          className,
        ]
          .filter(Boolean)
          .join(' ')}
      >
        {options.map((option) => (
          <option key={option.value} value={option.value}>
            {option.label}
          </option>
        ))}
      </select>
    </label>
  )
}
