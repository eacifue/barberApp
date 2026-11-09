import type { ReactNode } from 'react'

/** Tarjeta de sección del Dashboard: título, subtítulo y acción opcional. */
export function Panel({ title, subtitle, action, children, className }: { title: string; subtitle?: string; action?: ReactNode; children: ReactNode; className?: string }) {
  return (
    <section className={`bsm-card flex-col gap-4 ${className ?? ''}`} aria-label={title}>
      <div className="flex items-start justify-between gap-3">
        <div>
          <h3 className="text-title text-ink">{title}</h3>
          {subtitle && <p className="text-body text-ink-muted">{subtitle}</p>}
        </div>
        {action}
      </div>
      {children}
    </section>
  )
}
