import type { ReactNode } from 'react'

import { SkeletonRow } from './SkeletonRow'

type Column<T> = {
  key: keyof T | string
  header: string
  width?: string
  render?: (row: T, index: number) => ReactNode
}

type DataTableProps<T> = {
  columns: Column<T>[]
  data: T[]
  onRowClick?: (row: T) => void
  loading?: boolean
  emptyMessage?: string
}

export function DataTable<T extends object>({
  columns,
  data,
  onRowClick,
  loading = false,
  emptyMessage = 'No hay registros para mostrar',
}: DataTableProps<T>) {
  const templateColumns = columns.map((col) => col.width ?? '1fr').join(' ')
  // Ancho mínimo para que las columnas tengan espacio real y quede scroll
  // horizontal en pantallas angostas, en vez de aplastarse unas con otras.
  const minWidth = Math.max(columns.length * 130, 560)

  return (
    <div className="surface-panel overflow-hidden rounded-[28px]" role="table" aria-rowcount={data.length}>
      <div className="overflow-x-auto">
        <div role="rowgroup">
          <div
            role="row"
            className="grid gap-x-4 border-b border-[var(--border-subtle)] bg-[var(--surface-overlay)] px-5 py-4"
            style={{ gridTemplateColumns: templateColumns, minWidth }}
          >
            {columns.map((col) => (
              <div
                key={String(col.key)}
                role="columnheader"
                className="text-[11px] font-semibold uppercase tracking-[0.18em] text-[var(--text-faint)]"
              >
                {col.header}
              </div>
            ))}
          </div>
        </div>

        {loading ? (
          <div className="space-y-2 p-3" role="status" aria-live="polite" aria-label="Cargando datos">
            {Array.from({ length: 5 }).map((_, idx) => (
              <SkeletonRow key={idx} templateColumns={templateColumns} columnCount={columns.length} minWidth={minWidth} />
            ))}
          </div>
        ) : null}

        {!loading && data.length > 0 ? (
          <div role="rowgroup">
            {data.map((row, rowIndex) => (
              <div
                key={rowIndex}
                role="row"
                tabIndex={onRowClick ? 0 : undefined}
                onKeyDown={
                  onRowClick
                    ? (event) => {
                        if (event.key === 'Enter' || event.key === ' ') {
                          event.preventDefault()
                          onRowClick(row)
                        }
                      }
                    : undefined
                }
                className={[
                  'grid gap-x-4 border-b border-[var(--border-subtle)] px-5 py-4 text-sm text-[var(--text-base)] last:border-b-0',
                  onRowClick
                    ? 'cursor-pointer transition-colors hover:bg-[var(--surface-hover)] focus-visible:outline-none focus-visible:ring-inset focus-visible:shadow-focus'
                    : '',
                ].join(' ')}
                style={{ gridTemplateColumns: templateColumns, minWidth }}
                onClick={() => onRowClick?.(row)}
              >
                {columns.map((col) => (
                  <div key={String(col.key)} role="cell">
                    {col.render
                      ? col.render(row, rowIndex)
                      : String((row as Record<string, unknown>)[String(col.key)] ?? '')}
                  </div>
                ))}
              </div>
            ))}
          </div>
        ) : null}
      </div>

      {!loading && data.length === 0 ? (
        <div className="flex flex-col items-center justify-center gap-3 px-6 py-14 text-center text-sm text-[var(--text-ink-muted)]">
          <svg viewBox="0 0 24 24" className="h-8 w-8 text-[var(--text-faint)]" fill="none" aria-hidden="true">
            <rect x="4" y="5" width="16" height="14" rx="2" stroke="currentColor" strokeWidth="1.5" />
            <path d="M8 9h8M8 13h8" stroke="currentColor" strokeWidth="1.5" />
          </svg>
          <span>{emptyMessage}</span>
        </div>
      ) : null}
    </div>
  )
}
