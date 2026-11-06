import { useState, type ReactNode } from 'react'

import { cx } from '../../components/bsm'

// Gráficas del Dashboard (design/pantallas/panel-web/Dashboard + skill dataviz):
// marcas delgadas (barras ≤ 24 px, extremo redondeado de 4 px desde la línea
// base, líneas de 2 px, marcadores de 8 px con anillo de superficie), rejilla
// de 1 px recesiva, una sola escala por gráfica, texto en tokens de tinta,
// tooltip con el valor primero y una tabla con los mismos datos.

/** Tabla accesible con los mismos datos de la gráfica. */
function DataTable({ caption, head, rows }: { caption: string; head: [string, ...string[]]; rows: Array<[string, ...ReactNode[]]> }) {
  return (
    <details className="mt-3 text-caption text-ink-muted">
      <summary className="cursor-pointer select-none rounded-xs font-semibold text-brass-ink focus-visible:shadow-focus">Ver datos</summary>
      <table className="mt-2 w-full border-collapse text-body text-ink">
        <caption className="bsm-sr">{caption}</caption>
        <thead>
          <tr>
            {head.map((h, i) => (
              <th key={h} scope="col" className={cx('border-b border-line py-1 font-semibold text-ink-muted', i ? 'text-right' : 'text-left')}>
                {h}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map(([label, ...cells]) => (
            <tr key={label}>
              <th scope="row" className="border-b border-line py-1 text-left font-normal">
                {label}
              </th>
              {cells.map((c, i) => (
                <td key={i} className="tnum border-b border-line py-1 text-right">
                  {c}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </details>
  )
}

function Tooltip({ value, label, x, y }: { value: string; label: string; x: number; y: number }) {
  return (
    <div
      role="presentation"
      className="pointer-events-none absolute z-10 -translate-x-1/2 -translate-y-full whitespace-nowrap rounded-sm bg-inverse px-2.5 py-1.5 shadow-md"
      style={{ left: x, top: y - 8 }}
    >
      <p className="tnum text-label-sm text-inverse-on">{value}</p>
      <p className="text-caption text-inverse-on opacity-80">{label}</p>
    </div>
  )
}

/* ---------- Columnas verticales (ingresos por día) ---------- */

export type ColumnDatum = {
  key: string
  /** Etiqueta del eje X (día del mes o «cerr.»). */
  x: string
  /** Etiqueta larga para tooltip y tabla. */
  label: string
  value: number | null
  /** Barra estimada: relleno lavado con borde punteado (p. ej. hoy). */
  estimated?: boolean
  /** Etiqueta directa sobre la barra (selectiva: máximo y hoy). */
  showLabel?: boolean
}

export function ColumnChart({
  data,
  format,
  formatAxis,
  height = 196,
  caption,
  valueHead,
}: {
  data: ColumnDatum[]
  format: (n: number) => string
  formatAxis: (n: number) => string
  height?: number
  caption: string
  valueHead: string
}) {
  const [hover, setHover] = useState<{ i: number; x: number; y: number } | null>(null)
  const max = Math.max(1, ...data.map((d) => d.value ?? 0))
  const step = niceStep(max / 4)
  const top = Math.max(step, Math.ceil(max / step) * step)
  const ticks = Array.from({ length: Math.round(top / step) + 1 }, (_, i) => i * step)
  const px = (v: number) => (v / top) * height

  return (
    <div>
      <div className="relative mt-3 flex gap-2" style={{ height: height + 28 }}>
        <div className="relative w-14 flex-none" aria-hidden="true">
          {ticks.map((t) => (
            <span key={t} className="tnum absolute right-0 -translate-y-1/2 text-caption text-ink-muted" style={{ bottom: px(t) + 24 }}>
              {formatAxis(t)}
            </span>
          ))}
        </div>
        <div className="relative min-w-0 flex-1" role="img" aria-label={caption}>
          {ticks.map((t) => (
            <div key={t} className="absolute inset-x-0 h-px bg-line" style={{ bottom: px(t) + 24 }} aria-hidden="true" />
          ))}
          <div className="absolute inset-x-0 bottom-6 top-0 flex items-end justify-around">
            {data.map((d, i) => {
              const h = d.value == null ? 0 : Math.max(2, px(d.value))
              return (
                <div
                  key={d.key}
                  className="relative flex h-full flex-1 items-end justify-center"
                  tabIndex={d.value == null ? -1 : 0}
                  aria-label={`${d.label}: ${d.value == null ? 'cerrado' : format(d.value)}`}
                  onPointerEnter={(e) => {
                    const r = e.currentTarget.getBoundingClientRect()
                    const p = e.currentTarget.parentElement!.getBoundingClientRect()
                    setHover({ i, x: r.left - p.left + r.width / 2, y: p.height - h })
                  }}
                  onPointerLeave={() => setHover(null)}
                  onFocus={(e) => {
                    const r = e.currentTarget.getBoundingClientRect()
                    const p = e.currentTarget.parentElement!.getBoundingClientRect()
                    setHover({ i, x: r.left - p.left + r.width / 2, y: p.height - h })
                  }}
                  onBlur={() => setHover(null)}
                >
                  {d.showLabel && d.value != null && (
                    <span className="tnum absolute whitespace-nowrap text-caption font-semibold text-ink" style={{ bottom: h + 4 }}>
                      {formatAxis(d.value)}
                    </span>
                  )}
                  {d.value != null && (
                    <div
                      className={cx('w-[70%] max-w-6 rounded-t-xs transition-[filter] duration-fast', hover?.i === i && 'brightness-110')}
                      style={
                        d.estimated
                          ? { height: h, background: 'var(--brass-soft)', border: '1.5px dashed var(--chart-1)', borderBottom: 0 }
                          : { height: h, background: 'var(--chart-1)' }
                      }
                    />
                  )}
                </div>
              )
            })}
          </div>
          <div className="absolute inset-x-0 bottom-0 flex justify-around" aria-hidden="true">
            {data.map((d) => (
              <span key={d.key} className="tnum flex-1 text-center text-caption text-ink-muted">
                {d.x}
              </span>
            ))}
          </div>
          {hover && data[hover.i].value != null && (
            <Tooltip value={`${format(data[hover.i].value!)}${data[hover.i].estimated ? ' (estimado)' : ''}`} label={data[hover.i].label} x={hover.x} y={hover.y} />
          )}
        </div>
      </div>
      <DataTable caption={caption} head={['Día', valueHead]} rows={data.map((d) => [d.label, d.value == null ? 'Cerrado' : `${format(d.value)}${d.estimated ? ' (estimado)' : ''}`])} />
    </div>
  )
}

/* ---------- Barras horizontales (ocupación, servicios) ---------- */

export type BarDatum = { key: string; label: ReactNode; text: string; value: number; display: string }

export function BarList({ data, max, color = 'var(--chart-1)', caption, valueHead }: { data: BarDatum[]; max: number; color?: string; caption: string; valueHead: string }) {
  return (
    <div>
      <ul className="flex flex-col gap-3" aria-label={caption}>
        {data.map((d) => (
          <li key={d.key} className="grid grid-cols-[minmax(0,10rem)_1fr_auto] items-center gap-3" title={`${d.text}: ${d.display}`}>
            <span className="min-w-0 truncate text-body text-ink">{d.label}</span>
            <span className="h-3 rounded-full bg-surface-sunken" aria-hidden="true">
              <span className="block h-full rounded-full" style={{ width: `${Math.min(100, (d.value / Math.max(1, max)) * 100)}%`, background: color }} />
            </span>
            <span className="tnum w-14 text-right text-label-sm text-ink">{d.display}</span>
          </li>
        ))}
      </ul>
      <DataTable caption={caption} head={['', valueHead]} rows={data.map((d) => [d.text, d.display])} />
    </div>
  )
}

/* ---------- Líneas (porcentaje semanal, dos series) ---------- */

export type LineSeries = { key: string; name: string; color: string; values: number[] }

export function LineChart({ labels, longLabels, series, caption, height = 180 }: { labels: string[]; longLabels: string[]; series: LineSeries[]; caption: string; height?: number }) {
  const [hover, setHover] = useState<number | null>(null)
  const W = 560
  const padL = 40
  const padR = 56
  const padT = 12
  const padB = 24
  const max = Math.max(5, ...series.flatMap((s) => s.values))
  const step = niceStep(max / 3)
  const top = Math.ceil(max / step) * step
  const ticks = Array.from({ length: Math.round(top / step) + 1 }, (_, i) => i * step)
  const n = labels.length
  const x = (i: number) => padL + (n === 1 ? 0 : (i / (n - 1)) * (W - padL - padR))
  const y = (v: number) => padT + (1 - v / top) * (height - padT - padB)
  const fmt = (v: number) => `${v.toFixed(1).replace('.', ',').replace(',0', '')} %`

  return (
    <div>
      <div className="mb-2 flex flex-wrap gap-4" aria-hidden="true">
        {series.map((s) => (
          <span key={s.key} className="inline-flex items-center gap-2 text-caption text-ink-muted">
            <span className="h-0.5 w-4 rounded-full" style={{ background: s.color }} />
            {s.name}
          </span>
        ))}
      </div>
      <div className="relative">
        <svg viewBox={`0 0 ${W} ${height}`} className="h-auto w-full overflow-visible" role="img" aria-label={caption} onPointerLeave={() => setHover(null)}>
          <title>{caption}</title>
          {ticks.map((t) => (
            <g key={t}>
              <line x1={padL} x2={W - padR} y1={y(t)} y2={y(t)} stroke="var(--line)" strokeWidth={1} />
              <text x={padL - 8} y={y(t)} dy="0.32em" textAnchor="end" className="tnum" fill="var(--ink-muted)" fontSize={11}>
                {t} %
              </text>
            </g>
          ))}
          {labels.map((l, i) => (
            <text key={l + i} x={x(i)} y={height - 6} textAnchor="middle" fill="var(--ink-muted)" fontSize={11}>
              {l}
            </text>
          ))}
          {hover != null && <line x1={x(hover)} x2={x(hover)} y1={padT} y2={height - padB} stroke="var(--line-strong)" strokeWidth={1} />}
          {series.map((s) => (
            <g key={s.key}>
              <polyline
                points={s.values.map((v, i) => `${x(i)},${y(v)}`).join(' ')}
                fill="none"
                stroke={s.color}
                strokeWidth={2}
                strokeLinejoin="round"
                strokeLinecap="round"
              />
              <circle cx={x(n - 1)} cy={y(s.values[n - 1])} r={4} fill={s.color} stroke="var(--surface)" strokeWidth={2} />
              <text x={x(n - 1) + 8} y={y(s.values[n - 1])} dy="0.32em" fill="var(--ink)" fontSize={11} className="tnum">
                {fmt(s.values[n - 1])}
              </text>
              {hover != null && hover !== n - 1 && <circle cx={x(hover)} cy={y(s.values[hover])} r={4} fill={s.color} stroke="var(--surface)" strokeWidth={2} />}
            </g>
          ))}
          {labels.map((_, i) => (
            <rect
              key={i}
              x={x(i) - (W - padL - padR) / Math.max(1, n - 1) / 2}
              y={0}
              width={(W - padL - padR) / Math.max(1, n - 1)}
              height={height}
              fill="transparent"
              onPointerEnter={() => setHover(i)}
            />
          ))}
        </svg>
        {hover != null && (
          <div className="pointer-events-none absolute right-0 top-0 z-10 rounded-sm bg-inverse px-2.5 py-1.5 shadow-md">
            <p className="text-caption text-inverse-on opacity-80">{longLabels[hover]}</p>
            {series.map((s) => (
              <p key={s.key} className="flex items-center gap-2 text-label-sm text-inverse-on">
                <span className="h-0.5 w-3 rounded-full" style={{ background: s.color }} />
                <span className="tnum">{fmt(s.values[hover])}</span>
                <span className="font-normal opacity-80">{s.name}</span>
              </p>
            ))}
          </div>
        )}
      </div>
      <DataTable
        caption={caption}
        head={['Semana', ...series.map((s) => s.name)] as [string, ...string[]]}
        rows={longLabels.map((l, i) => [l, ...series.map((s) => fmt(s.values[i]))])}
      />
    </div>
  )
}

/** Paso «redondo» (1, 2, 2,5, 5 × 10ⁿ) para la rejilla. */
function niceStep(raw: number): number {
  if (raw <= 0) return 1
  const exp = Math.pow(10, Math.floor(Math.log10(raw)))
  const f = raw / exp
  const nice = f <= 1 ? 1 : f <= 2 ? 2 : f <= 2.5 ? 2.5 : f <= 5 ? 5 : 10
  return nice * exp
}
