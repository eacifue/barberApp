import type { ReactNode } from 'react'

type PageHeaderProps = {
  title: string
  subtitle: string
  actions?: ReactNode
}

export function PageHeader({ title, subtitle, actions }: PageHeaderProps) {
  return (
    <div className="mb-8 flex flex-wrap items-end justify-between gap-4">
      <div className="max-w-2xl">
        <p className="text-[11px] font-semibold uppercase tracking-[0.2em] text-[var(--text-faint)]">Barbería SaaS</p>
        <h1 className="mt-3 font-display text-4xl leading-none text-[var(--text-strong)] md:text-5xl">{title}</h1>
        <p className="mt-3 max-w-xl text-sm leading-6 text-[var(--text-ink-muted)] md:text-base">{subtitle}</p>
      </div>
      {actions}
    </div>
  )
}
