import type { ReactNode } from 'react'

type PageHeaderProps = {
  title: string
  subtitle: ReactNode
  actions?: ReactNode
}

/** Encabezado de página del panel: título en Gloock (la topbar lleva el h1), apoyo y acciones. */
export function PageHeader({ title, subtitle, actions }: PageHeaderProps) {
  return (
    <div className="flex flex-wrap items-end justify-between gap-4">
      <div className="max-w-2xl">
        <h2 className="font-display text-display text-ink">{title}</h2>
        <p className="mt-1 text-body-lg text-ink-muted">{subtitle}</p>
      </div>
      {actions && <div className="flex flex-wrap items-center gap-2">{actions}</div>}
    </div>
  )
}
