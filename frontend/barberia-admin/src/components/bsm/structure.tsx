import { useEffect, useId, useRef, useState, type KeyboardEvent, type ReactNode } from 'react'
import { createPortal } from 'react-dom'

import { renderActions, type ActionSpec } from './actions'
import { TONE_ICON } from './constants'
import { Button, IconButton, type ButtonVariant } from './controls'
import { cx } from './format'
import { Icon } from './Icon'
import type { IconName } from './icons'

/* ---------- Tabs ---------- */

export type TabItem = { value: string; label: ReactNode; icon?: IconName; count?: number; ariaLabel?: string }

type TabsProps = {
  items: Array<string | TabItem>
  value: string
  onChange?: (value: string) => void
  variant?: 'underline' | 'segmented'
  label?: string
  className?: string
}

/** Subrayado latón (Próximas / Historial) o control segmentado (Día · Semana · Historial). */
export function Tabs({ items, value, onChange, variant = 'underline', label, className }: TabsProps) {
  const list = items.map((it) => (typeof it === 'string' ? { value: it, label: it } : it))
  const ref = useRef<HTMLDivElement>(null)
  const onKeyDown = (e: KeyboardEvent<HTMLDivElement>) => {
    const dir = e.key === 'ArrowRight' ? 1 : e.key === 'ArrowLeft' ? -1 : 0
    if (!dir) return
    e.preventDefault()
    const idx = list.findIndex((t) => t.value === value)
    const next = list[(idx + dir + list.length) % list.length]
    onChange?.(next.value)
    requestAnimationFrame(() => ref.current?.querySelector<HTMLButtonElement>('[aria-selected="true"]')?.focus())
  }
  return (
    <div ref={ref} className={cx('bsm-tabs', `bsm-tabs-${variant}`, className)} role="tablist" aria-label={label} onKeyDown={onKeyDown}>
      {list.map((it) => {
        const active = value === it.value
        return (
          <button
            key={it.value}
            type="button"
            role="tab"
            aria-selected={active}
            aria-label={it.ariaLabel}
            tabIndex={active ? 0 : -1}
            className={cx('bsm-tab', active && 'is-active')}
            onClick={() => onChange?.(it.value)}
          >
            {it.icon && <Icon name={it.icon} size={18} />}
            {it.label}
            {it.count != null && <span className="bsm-tab-count">{it.count}</span>}
          </button>
        )
      })}
    </div>
  )
}

/* ---------- Table ---------- */

export type TableColumn<R> = {
  key: string
  label: ReactNode
  align?: 'right'
  muted?: boolean
  sort?: 'asc' | 'desc'
  onSort?: () => void
  render?: (row: R) => ReactNode
}

type TableProps<R> = {
  columns: TableColumn<R>[]
  rows: R[]
  caption?: string
  rowKey?: (row: R, index: number) => string
  isSelected?: (row: R) => boolean
  onRowClick?: (row: R) => void
  /** Se muestra en lugar de las filas (carga, vacío o error). */
  state?: ReactNode
  className?: string
}

/** Cabecera hundida, cifras a la derecha, acciones al final; bajo 768 px se vuelve lista de tarjetas. */
export function Table<R>({ columns, rows, caption, rowKey, isSelected, onRowClick, state, className }: TableProps<R>) {
  return (
    <div className={cx('bsm-table-wrap', className)}>
      <table className="bsm-table">
        {caption && <caption className="bsm-sr">{caption}</caption>}
        <thead>
          <tr>
            {columns.map((c) => (
              <th
                key={c.key}
                scope="col"
                className={cx(c.align === 'right' && 'is-num', c.sort && 'is-sorted')}
                aria-sort={c.sort === 'asc' ? 'ascending' : c.sort === 'desc' ? 'descending' : undefined}
              >
                {c.onSort ? (
                  <button type="button" className="bsm-th-sort" onClick={c.onSort}>
                    {c.label}
                    {c.sort && <Icon name="chevron-down" size={14} className={c.sort === 'asc' ? 'bsm-flip' : ''} />}
                  </button>
                ) : (
                  <>
                    {c.label}
                    {c.sort && <Icon name="chevron-down" size={14} className={c.sort === 'asc' ? 'bsm-flip' : ''} />}
                  </>
                )}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {state ? (
            <tr className="bsm-table-state">
              <td colSpan={columns.length}>{state}</td>
            </tr>
          ) : (
            rows.map((r, i) => (
              <tr
                key={rowKey ? rowKey(r, i) : i}
                className={cx(isSelected?.(r) && 'is-selected', onRowClick && 'is-clickable')}
                onClick={onRowClick ? () => onRowClick(r) : undefined}
              >
                {columns.map((c) => (
                  <td key={c.key} className={cx(c.align === 'right' && 'is-num', c.muted && 'is-muted')} data-label={typeof c.label === 'string' ? c.label : undefined}>
                    {c.render ? c.render(r) : String((r as Record<string, unknown>)[c.key] ?? '')}
                  </td>
                ))}
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  )
}

/* ---------- Pagination ---------- */

type PaginationProps =
  | { variant?: 'pages'; page: number; pages: number; total: number; perPage?: number; onPageChange: (page: number) => void }
  | { variant: 'more'; shown: number; total: number; loading?: boolean; onLoadMore: () => void }

/** «26–50 de 132» + páginas, o «Cargar más» para el historial. */
export function Pagination(props: PaginationProps) {
  if (props.variant === 'more') {
    return (
      <div className="bsm-pager is-more">
        <p className="bsm-pager-info">
          Mostrando {props.shown} de {props.total}
        </p>
        {props.shown < props.total && (
          <Button variant="secondary" icon={props.loading ? undefined : 'history'} loading={props.loading} onClick={props.onLoadMore}>
            {props.loading ? 'Cargando…' : 'Cargar más'}
          </Button>
        )}
      </div>
    )
  }
  const { page, pages, total, perPage = 25, onPageChange } = props
  const from = total === 0 ? 0 : (page - 1) * perPage + 1
  const to = Math.min(page * perPage, total)
  const list: Array<number | '…'> = []
  for (let p = 1; p <= pages; p++) {
    if (p === 1 || p === pages || Math.abs(p - page) <= 1) list.push(p)
    else if (list[list.length - 1] !== '…') list.push('…')
  }
  return (
    <nav className="bsm-pager" aria-label="Paginación">
      <p className="bsm-pager-info">
        {from}–{to} de {total}
      </p>
      <div className="bsm-pager-pages">
        <IconButton icon="chevron-left" label="Página anterior" size="sm" disabled={page <= 1} onClick={() => onPageChange(page - 1)} />
        {list.map((p, i) =>
          p === '…' ? (
            <span key={`g${i}`} className="bsm-pager-gap">
              …
            </span>
          ) : (
            <button
              key={p}
              type="button"
              className={cx('bsm-pager-page', p === page && 'is-active')}
              aria-current={p === page ? 'page' : undefined}
              aria-label={`Página ${p}`}
              onClick={() => onPageChange(p)}
            >
              {p}
            </button>
          ),
        )}
        <IconButton icon="chevron-right" label="Página siguiente" size="sm" disabled={page >= pages} onClick={() => onPageChange(page + 1)} />
      </div>
    </nav>
  )
}

/* ---------- Diálogos ---------- */

const FOCUSABLE = 'a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])'

/** Foco al entrar, Tab atrapado dentro, Esc cierra y el foco vuelve a quien abrió. */
function useDialog(open: boolean, onEscape: () => void) {
  const ref = useRef<HTMLDivElement>(null)
  const escRef = useRef(onEscape)
  useEffect(() => {
    escRef.current = onEscape
  })
  useEffect(() => {
    if (!open) return
    const opener = document.activeElement as HTMLElement | null
    const node = ref.current
    const first = node?.querySelector<HTMLElement>('[data-autofocus]') ?? node?.querySelector<HTMLElement>('.bsm-modal-body ' + FOCUSABLE) ?? node?.querySelector<HTMLElement>(FOCUSABLE)
    first?.focus()
    const prevOverflow = document.body.style.overflow
    document.body.style.overflow = 'hidden'
    return () => {
      document.body.style.overflow = prevOverflow
      opener?.focus?.()
    }
  }, [open])
  const onKeyDown = (e: KeyboardEvent<HTMLDivElement>) => {
    if (e.key === 'Escape') {
      e.stopPropagation()
      escRef.current()
      return
    }
    if (e.key !== 'Tab' || !ref.current) return
    const items = Array.from(ref.current.querySelectorAll<HTMLElement>(FOCUSABLE))
    if (!items.length) return
    const firstEl = items[0]
    const lastEl = items[items.length - 1]
    if (e.shiftKey && document.activeElement === firstEl) {
      e.preventDefault()
      lastEl.focus()
    } else if (!e.shiftKey && document.activeElement === lastEl) {
      e.preventDefault()
      firstEl.focus()
    }
  }
  return { ref, onKeyDown }
}

type ModalProps = {
  open: boolean
  onClose: () => void
  title: string
  subtitle?: ReactNode
  children?: ReactNode
  /** Secundario + primario: nodos o `{label, variant, icon, onClick}`. */
  footer?: ReactNode | ActionSpec[]
  /** `lg` = 760 px (barbero con horario semanal). */
  size?: 'md' | 'lg'
  /** Bottom sheet (móvil). */
  sheet?: boolean
  /** Con cambios sin guardar: cerrar pregunta «¿Descartar cambios?». */
  dirty?: boolean
}

export function Modal({ open, onClose, title, subtitle, children, footer, size = 'md', sheet, dirty }: ModalProps) {
  const titleId = useId()
  const [asking, setAsking] = useState(false)
  const requestClose = () => (dirty ? setAsking(true) : onClose())
  const { ref, onKeyDown } = useDialog(open, () => {
    if (!asking) requestClose()
  })
  if (!open) return null
  return createPortal(
    <>
      <div
        className="bsm-scrim"
        onMouseDown={(e) => {
          if (e.target === e.currentTarget) requestClose()
        }}
      >
        <div ref={ref} className={cx('bsm-modal', sheet && 'is-sheet', size === 'lg' && 'is-lg')} role="dialog" aria-modal="true" aria-labelledby={titleId} onKeyDown={onKeyDown}>
          {sheet && <span className="bsm-sheet-handle" aria-hidden="true" />}
          <header className="bsm-modal-head">
            <div>
              <h2 id={titleId} className="bsm-modal-title">
                {title}
              </h2>
              {subtitle && <p className="bsm-modal-sub">{subtitle}</p>}
            </div>
            <IconButton icon="x" label="Cerrar" onClick={requestClose} />
          </header>
          <div className="bsm-modal-body">{children}</div>
          {footer != null && <footer className="bsm-modal-foot">{renderActions(footer, 'md')}</footer>}
        </div>
      </div>
      <ConfirmDialog
        open={asking}
        tone="danger"
        title="¿Descartar cambios?"
        body="Perderás lo que escribiste en este formulario."
        confirmLabel="Descartar cambios"
        cancelLabel="Seguir editando"
        onCancel={() => setAsking(false)}
        onConfirm={() => {
          setAsking(false)
          onClose()
        }}
      />
    </>,
    document.body,
  )
}

type ConfirmDialogProps = {
  open: boolean
  /** Pregunta: «¿Cancelar esta cita?» */
  title: string
  /** Consecuencia concreta: qué se pierde. */
  body: ReactNode
  /** Repite el verbo: «Sí, cancelar cita». Nunca «Aceptar». */
  confirmLabel: string
  cancelLabel?: string
  tone?: 'danger' | 'info'
  icon?: IconName
  loading?: boolean
  onConfirm: () => void
  onCancel: () => void
}

export function ConfirmDialog({ open, title, body, confirmLabel, cancelLabel = 'Volver', tone = 'danger', icon, loading, onConfirm, onCancel }: ConfirmDialogProps) {
  const titleId = useId()
  const bodyId = useId()
  const { ref, onKeyDown } = useDialog(open, () => {
    if (!loading) onCancel()
  })
  if (!open) return null
  const confirmVariant: ButtonVariant = tone === 'danger' ? 'danger' : 'primary'
  return createPortal(
    <div
      className="bsm-scrim"
      onMouseDown={(e) => {
        if (e.target === e.currentTarget && !loading) onCancel()
      }}
    >
      <div ref={ref} className="bsm-modal bsm-confirm" role="alertdialog" aria-modal="true" aria-labelledby={titleId} aria-describedby={bodyId} onKeyDown={onKeyDown}>
        <span className={`bsm-confirm-icon bsm-tone-${tone}`}>
          <Icon name={icon ?? (tone === 'danger' ? 'triangle-alert' : 'info')} size={24} />
        </span>
        <h2 id={titleId} className="bsm-confirm-title">
          {title}
        </h2>
        <p id={bodyId} className="bsm-confirm-body">
          {body}
        </p>
        <div className="bsm-confirm-actions">
          <Button variant="secondary" onClick={onCancel} disabled={loading} data-autofocus>
            {cancelLabel}
          </Button>
          <Button variant={confirmVariant} onClick={onConfirm} loading={loading}>
            {confirmLabel}
          </Button>
        </div>
      </div>
    </div>,
    document.body,
  )
}

/* ---------- Avisos ---------- */

export type ToastTone = 'success' | 'danger' | 'info' | 'warning'

type ToastProps = {
  tone?: ToastTone
  children: ReactNode
  actionLabel?: string
  onAction?: () => void
  onDismiss?: () => void
  icon?: IconName
}

/** Snackbar en `inverse`. Errores que bloquean van en Banner, no aquí. */
export function Toast({ tone = 'success', children, actionLabel, onAction, onDismiss, icon }: ToastProps) {
  return (
    <div className="bsm-toast" role={tone === 'danger' ? 'alert' : 'status'}>
      <Icon name={icon ?? TONE_ICON[tone]} size={20} />
      <p className="bsm-toast-text">{children}</p>
      {actionLabel && (
        <button type="button" className="bsm-toast-action" onClick={onAction}>
          {actionLabel}
        </button>
      )}
      {onDismiss && (
        <button type="button" className="bsm-toast-x" aria-label="Cerrar aviso" onClick={onDismiss}>
          <Icon name="x" size={18} />
        </button>
      )}
    </div>
  )
}

type BannerProps = {
  tone?: 'info' | 'success' | 'warning' | 'danger' | 'brass'
  title?: ReactNode
  children?: ReactNode
  actionLabel?: string
  onAction?: () => void
  icon?: IconName
  className?: string
}

/** Aviso en línea: sesión por expirar, reprogramación, error de carga con «Reintentar». */
export function Banner({ tone = 'info', title, children, actionLabel, onAction, icon, className }: BannerProps) {
  return (
    <div className={cx('bsm-banner', `bsm-tone-${tone}`, className)} role={tone === 'danger' || tone === 'warning' ? 'alert' : 'status'}>
      <Icon name={icon ?? TONE_ICON[tone]} size={20} />
      <div className="bsm-banner-text">
        {title && <p className="bsm-banner-title">{title}</p>}
        {children && <p className="bsm-banner-body">{children}</p>}
      </div>
      {actionLabel && (
        <button type="button" className="bsm-banner-action" onClick={onAction}>
          {actionLabel}
        </button>
      )}
    </div>
  )
}

/* ---------- Carga y vacío ---------- */

type SkeletonProps = { variant?: 'text' | 'card' | 'slots' | 'row'; rows?: number; label?: string }

function Bone({ w, h, r }: { w: number | string; h: number; r?: string }) {
  return <span className="bsm-skel" style={{ width: w, height: h, borderRadius: r }} />
}

/** Forma del contenido real; sin brillo con «reducir movimiento». Mostrar tras 300 ms. */
export function Skeleton({ variant = 'text', rows = 1, label = 'Cargando' }: SkeletonProps) {
  const one = (i: number) => {
    if (variant === 'card')
      return (
        <div key={i} className="bsm-card bsm-skel-card">
          <Bone w={48} h={48} r="var(--radius-sm)" />
          <div className="bsm-skel-lines">
            <Bone w="60%" h={16} />
            <Bone w="90%" h={12} />
            <Bone w="40%" h={12} />
          </div>
        </div>
      )
    if (variant === 'slots')
      return (
        <div key={i} className="bsm-slot-grid">
          {Array.from({ length: 8 }, (_, j) => (
            <span key={j} className="bsm-skel" style={{ height: 44, borderRadius: 'var(--radius-sm)' }} />
          ))}
        </div>
      )
    if (variant === 'row')
      return (
        <div key={i} className="bsm-skel-row">
          <Bone w={32} h={32} r="50%" />
          <Bone w="24%" h={14} />
          <Bone w="30%" h={14} />
          <Bone w="14%" h={14} />
          <Bone w={80} h={22} r="var(--radius-xs)" />
        </div>
      )
    return (
      <div key={i} className="bsm-skel-lines">
        <Bone w="70%" h={14} />
        <Bone w="100%" h={14} />
        <Bone w="55%" h={14} />
      </div>
    )
  }
  return (
    <div className="bsm-skel-wrap" aria-busy="true" aria-label={label} role="status">
      {Array.from({ length: rows }, (_, i) => one(i))}
    </div>
  )
}

type EmptyStateProps = {
  icon?: IconName
  title: string
  body?: ReactNode
  action?: ReactNode
  actionLabel?: string
  actionIcon?: IconName
  actionVariant?: ButtonVariant
  onAction?: () => void
  tone?: 'error'
  className?: string
}

/** Vacío o error con siguiente paso: «No pudimos cargar …» + «Reintentar». */
export function EmptyState({ icon, title, body, action, actionLabel, actionIcon, actionVariant = 'primary', onAction, tone, className }: EmptyStateProps) {
  return (
    <div className={cx('bsm-empty', tone === 'error' && 'is-error', className)} role={tone === 'error' ? 'alert' : undefined}>
      <span className="bsm-empty-icon">
        <Icon name={icon ?? (tone === 'error' ? 'wifi-off' : 'calendar')} size={28} />
      </span>
      <h3 className="bsm-empty-title">{title}</h3>
      {body && <p className="bsm-empty-body">{body}</p>}
      {action ??
        (actionLabel && (
          <Button variant={actionVariant} icon={actionIcon} onClick={onAction}>
            {actionLabel}
          </Button>
        ))}
    </div>
  )
}
