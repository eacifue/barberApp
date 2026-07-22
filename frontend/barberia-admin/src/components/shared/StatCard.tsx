import type { ReactNode } from 'react'

type StatCardTrend = {
  symbol: string
  text: string
  tone: 'positive' | 'neutral'
}

type StatCardProps = {
  label: string
  value: string
  caption?: string
  icon?: ReactNode
  trend?: StatCardTrend
  valueTone?: string
  loading?: boolean
}

export function StatCard({
  label,
  value,
  caption,
  icon,
  trend,
  valueTone = 'text-[var(--text-strong)]',
  loading = false,
}: StatCardProps) {
  return (
    <article className="surface-panel rounded-[28px] p-5">
      <div className="flex items-start justify-between gap-4">
        <div>
          <p className="text-[11px] font-semibold uppercase tracking-[0.18em] text-[var(--text-faint)]">{label}</p>
          {loading ? (
            <span className="mt-4 block h-8 w-16 animate-pulse rounded-lg bg-[var(--surface-hover)]" aria-hidden="true" />
          ) : (
            <p className={['mt-4 font-display text-[2rem] leading-none', valueTone].join(' ')}>{value}</p>
          )}
        </div>
        {icon ? (
          <span className="flex h-11 w-11 items-center justify-center rounded-2xl bg-[var(--accent-soft)] text-[var(--accent)]">
            {icon}
          </span>
        ) : null}
      </div>
      {trend && !loading ? (
        <p
          className={[
            'mt-4 text-xs',
            trend.tone === 'positive' ? 'text-[var(--success)]' : 'text-[var(--text-faint)]',
          ].join(' ')}
        >
          {trend.symbol} {trend.text}
        </p>
      ) : null}
      {caption ? <p className="mt-2 text-sm text-[var(--text-muted)]">{caption}</p> : null}
    </article>
  )
}
