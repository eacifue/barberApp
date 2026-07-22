import type { InputHTMLAttributes } from 'react'

export function SearchInput(props: InputHTMLAttributes<HTMLInputElement>) {
  return (
    <label className="relative block">
      <span className="pointer-events-none absolute left-4 top-1/2 -translate-y-1/2 text-[var(--text-faint)]" aria-hidden="true">
        <svg viewBox="0 0 24 24" className="h-4 w-4" fill="none">
          <circle cx="11" cy="11" r="7" stroke="currentColor" strokeWidth="1.8" />
          <path d="M20 20l-4-4" stroke="currentColor" strokeWidth="1.8" />
        </svg>
      </span>
      <input
        {...props}
        className="form-control h-11 w-[280px] max-w-full rounded-full pl-11 pr-4 text-sm outline-none transition duration-200"
      />
    </label>
  )
}
