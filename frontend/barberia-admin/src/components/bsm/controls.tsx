import {
  useId,
  useState,
  type ButtonHTMLAttributes,
  type InputHTMLAttributes,
  type ReactNode,
  type SelectHTMLAttributes,
  type TextareaHTMLAttributes,
} from 'react'

import { STATUS, type AppointmentStatus, type Tone } from './constants'
import { cx, formatDecimal, initials } from './format'
import { Icon } from './Icon'
import type { IconName } from './icons'

/* ---------- Button ---------- */

export type ButtonVariant = 'primary' | 'secondary' | 'ghost' | 'danger' | 'danger-ghost'
export type ButtonSize = 'sm' | 'md' | 'lg'

type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: ButtonVariant
  size?: ButtonSize
  icon?: IconName
  iconRight?: IconName
  /** Bloquea el doble toque; pasa la etiqueta en gerundio («Reservando…»). */
  loading?: boolean
  block?: boolean
}

/** Un solo primario por pantalla o modal; etiqueta en tipo oración con verbo. */
export function Button({ variant = 'primary', size = 'md', icon, iconRight, loading, block, className, children, disabled, type = 'button', ...rest }: ButtonProps) {
  const iconSize = size === 'sm' ? 16 : 20
  return (
    <button
      type={type}
      {...rest}
      className={cx('bsm-btn', `bsm-btn-${variant}`, `bsm-btn-${size}`, block && 'bsm-btn-block', loading && 'is-loading', className)}
      disabled={disabled || loading}
      aria-busy={loading || undefined}
    >
      {loading ? <Icon name="loader-circle" size={iconSize} className="bsm-spin" /> : icon ? <Icon name={icon} size={iconSize} /> : null}
      {children != null && <span>{children}</span>}
      {iconRight && !loading && <Icon name={iconRight} size={iconSize} />}
    </button>
  )
}

type IconButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  icon: IconName
  /** Obligatoria: va a `aria-label` y al tooltip. Nombra el registro («Editar Laura Henao»). */
  label: string
  variant?: 'ghost' | 'secondary'
  size?: 'sm'
  /** Punto granate de novedad. */
  badge?: boolean
}

export function IconButton({ icon, label, variant = 'ghost', size, badge, className, type = 'button', ...rest }: IconButtonProps) {
  return (
    <button
      type={type}
      {...rest}
      className={cx('bsm-iconbtn', `bsm-iconbtn-${variant}`, size === 'sm' && 'bsm-iconbtn-sm', className)}
      aria-label={label}
      title={label}
    >
      <Icon name={icon} size={size === 'sm' ? 18 : 20} />
      {badge && <span className="bsm-iconbtn-dot" aria-hidden="true" />}
    </button>
  )
}

/* ---------- Campos ---------- */

type FieldShellProps = {
  id: string
  label?: ReactNode
  hint?: ReactNode
  error?: ReactNode
  optional?: boolean
  disabled?: boolean
  className?: string
  children: ReactNode
}

function FieldShell({ id, label, hint, error, optional, disabled, className, children }: FieldShellProps) {
  return (
    <div className={cx('bsm-field', error && 'has-error', disabled && 'is-disabled', className)}>
      {label && (
        <label className="bsm-field-label" htmlFor={id}>
          {label}
          {optional && <span className="bsm-field-opt"> (opcional)</span>}
        </label>
      )}
      {children}
      {error ? (
        <p className="bsm-field-msg bsm-field-error" id={`${id}-msg`}>
          <Icon name="circle-alert" size={16} />
          {error}
        </p>
      ) : hint ? (
        <p className="bsm-field-msg" id={`${id}-msg`}>
          {hint}
        </p>
      ) : null}
    </div>
  )
}

type CommonFieldProps = {
  label?: ReactNode
  hint?: ReactNode
  /** Reemplaza a `hint` y pone el borde en `danger`. Dice cómo corregir. */
  error?: ReactNode
  icon?: IconName
  trailing?: ReactNode
  optional?: boolean
  /** Contraseña con botón Mostrar / Ocultar. */
  revealable?: boolean
  className?: string
}

type InputProps = CommonFieldProps & InputHTMLAttributes<HTMLInputElement> & { multiline?: false }
type TextareaProps = CommonFieldProps & TextareaHTMLAttributes<HTMLTextAreaElement> & { multiline: true }

/** Etiqueta arriba, ayuda o error debajo. Marca lo opcional, no lo obligatorio. */
export function Input(props: InputProps | TextareaProps) {
  const autoId = useId()
  const [shown, setShown] = useState(false)
  const { label, hint, error, icon, trailing, optional, revealable, className, multiline, id: givenId, ...rest } = props
  const id = givenId ?? autoId
  const describedBy = error || hint ? `${id}-msg` : undefined
  const trailingNode =
    trailing ??
    (revealable ? (
      <IconButton
        icon={shown ? 'eye-off' : 'eye'}
        label={shown ? 'Ocultar contraseña' : 'Mostrar contraseña'}
        aria-pressed={shown}
        onClick={() => setShown((s) => !s)}
      />
    ) : null)
  const shared = {
    id,
    className: 'bsm-control-input',
    'aria-invalid': error ? true : undefined,
    'aria-describedby': describedBy,
  }
  return (
    <FieldShell id={id} label={label} hint={hint} error={error} optional={optional} disabled={rest.disabled} className={className}>
      <div className={cx('bsm-control', icon && 'has-icon', multiline && 'is-multiline')}>
        {icon && <Icon name={icon} size={20} className="bsm-control-icon" />}
        {multiline ? (
          <textarea rows={3} {...(rest as TextareaHTMLAttributes<HTMLTextAreaElement>)} {...shared} />
        ) : (
          <input
            {...(rest as InputHTMLAttributes<HTMLInputElement>)}
            {...shared}
            type={revealable ? (shown ? 'text' : 'password') : (rest as InputHTMLAttributes<HTMLInputElement>).type}
          />
        )}
        {trailingNode}
      </div>
    </FieldShell>
  )
}

export type SelectOption = string | { value: string; label: string }

type SelectProps = SelectHTMLAttributes<HTMLSelectElement> & {
  label?: ReactNode
  hint?: ReactNode
  error?: ReactNode
  optional?: boolean
  placeholder?: string
  options: SelectOption[]
}

/** Pocas opciones (≤ 15). En filtros, «Todos los …» va primero. */
export function Select({ label, hint, error, optional, placeholder, options, className, id: givenId, ...rest }: SelectProps) {
  const autoId = useId()
  const id = givenId ?? autoId
  return (
    <FieldShell id={id} label={label} hint={hint} error={error} optional={optional} disabled={rest.disabled} className={className}>
      <div className="bsm-control bsm-select">
        <select
          {...rest}
          id={id}
          className="bsm-control-input"
          aria-invalid={error ? true : undefined}
          aria-describedby={error || hint ? `${id}-msg` : undefined}
        >
          {placeholder != null && <option value="">{placeholder}</option>}
          {options.map((o) => {
            const value = typeof o === 'string' ? o : o.value
            return (
              <option key={value} value={value}>
                {typeof o === 'string' ? o : o.label}
              </option>
            )
          })}
        </select>
        <Icon name="chevron-down" size={20} className="bsm-select-chevron" />
      </div>
    </FieldShell>
  )
}

type SwitchProps = {
  label: ReactNode
  hint?: ReactNode
  checked?: boolean
  defaultChecked?: boolean
  onChange?: (checked: boolean) => void
  disabled?: boolean
  id?: string
}

/** El cambio aplica al instante; confirma con un Toast. */
export function Switch({ label, hint, checked, defaultChecked, onChange, disabled, id: givenId }: SwitchProps) {
  const autoId = useId()
  const id = givenId ?? autoId
  const [inner, setInner] = useState(!!defaultChecked)
  const on = checked ?? inner
  const toggle = () => {
    if (disabled) return
    if (checked == null) setInner(!on)
    onChange?.(!on)
  }
  return (
    <div className={cx('bsm-switch-row', disabled && 'is-disabled')}>
      <span className="bsm-switch-text">
        <label htmlFor={id} className="bsm-switch-label">
          {label}
        </label>
        {hint && <span className="bsm-switch-hint">{hint}</span>}
      </span>
      <button id={id} type="button" role="switch" aria-checked={on} disabled={disabled} className="bsm-switch" onClick={toggle}>
        <span className="bsm-switch-thumb">{on && <Icon name="check" size={14} strokeWidth={3} />}</span>
      </button>
    </div>
  )
}

type ChipProps = Omit<ButtonHTMLAttributes<HTMLButtonElement>, 'children'> & {
  children: ReactNode
  selected?: boolean
  icon?: IconName
  count?: number
  /** Convierte el chip en chip de entrada (con quitar). */
  onRemove?: () => void
  /** Etiqueta no interactiva. */
  as?: 'tag'
}

export function Chip({ children, selected, icon, count, onRemove, as, className, type = 'button', ...rest }: ChipProps) {
  if (as === 'tag') return <span className={cx('bsm-chip', 'bsm-chip-tag', className)}>{children}</span>
  if (onRemove) {
    // Chip de entrada: el contenedor no es interactivo; solo «quitar» es un botón.
    const removeLabel = typeof children === 'string' ? `Quitar ${children}` : 'Quitar'
    return (
      <span className={cx('bsm-chip', 'bsm-chip-input', className)}>
        {icon && <Icon name={icon} size={16} />}
        <span>{children}</span>
        <button type="button" className="bsm-chip-x" aria-label={removeLabel} onClick={onRemove}>
          <Icon name="x" size={16} />
        </button>
      </span>
    )
  }
  return (
    <button type={type} aria-pressed={!!selected} {...rest} className={cx('bsm-chip', selected && 'is-selected', className)}>
      {selected ? <Icon name="check" size={16} /> : icon ? <Icon name={icon} size={16} /> : null}
      <span>{children}</span>
      {count != null && <span className="bsm-chip-count">{count}</span>}
    </button>
  )
}

/* ---------- Estado y atributos ---------- */

/** Estado de cita = color + ícono + palabra, igual en app, panel y agenda. */
export function StatusBadge({ status, size, className }: { status: AppointmentStatus; size?: 'sm'; className?: string }) {
  const s = STATUS[status] ?? STATUS.Pendiente
  return (
    <span className={cx('bsm-badge', `bsm-status-${s.key}`, size === 'sm' && 'bsm-badge-sm', className)}>
      <Icon name={s.icon} size={14} strokeWidth={2.25} />
      {s.label}
    </span>
  )
}

/** Una o dos palabras. `oxblood` solo para Popular / Recomendado. */
export function Badge({ tone = 'neutral', icon, children, className }: { tone?: Tone; icon?: IconName; children?: ReactNode; className?: string }) {
  return (
    <span className={cx('bsm-badge', `bsm-tone-${tone}`, className)}>
      {icon && <Icon name={icon} size={14} strokeWidth={2.25} />}
      {children}
    </span>
  )
}

type RatingProps = { value?: number | null; count?: number; compact?: boolean; size?: number; className?: string }

/** Sin reseñas muestra «Nuevo» en vez de 0,0. */
export function Rating({ value, count, compact, size = 16, className }: RatingProps) {
  if (value == null || (count === 0 && !value)) return <Badge tone="brass">Nuevo</Badge>
  const txt = formatDecimal(value)
  const label = `Calificación ${txt} de 5${count != null ? `, ${count} reseñas` : ''}`
  return (
    <span className={cx('bsm-rating', compact && 'is-compact', className)} role="img" aria-label={label}>
      {compact ? (
        <span className="bsm-star bsm-star-full">
          <Icon name="star" size={size} />
        </span>
      ) : (
        [1, 2, 3, 4, 5].map((i) => {
          const fill = value >= i - 0.25 ? 'full' : value >= i - 0.75 ? 'half' : 'empty'
          return (
            <span key={i} className={`bsm-star bsm-star-${fill}`}>
              <Icon name="star" size={size} />
              {fill === 'half' && (
                <span className="bsm-star-fill">
                  <Icon name="star" size={size} />
                </span>
              )}
            </span>
          )
        })
      )}
      <span className="bsm-rating-value" aria-hidden="true">
        {txt}
      </span>
      {count != null && (
        <span className="bsm-rating-count" aria-hidden="true">
          ({count})
        </span>
      )}
    </span>
  )
}

type AvatarProps = { name?: string; src?: string | null; size?: number; status?: 'on' | 'off'; className?: string }

/** Foto circular; sin foto (o si falla), iniciales en Gloock sobre `brass-soft`. */
export function Avatar({ name, src, size = 48, status, className }: AvatarProps) {
  const [failed, setFailed] = useState<string | null>(null)
  const showImg = !!src && failed !== src
  return (
    <span className={cx('bsm-avatar', className)} style={{ width: size, height: size, fontSize: Math.round(size * 0.38) }} title={name}>
      {showImg ? <img src={src} alt={name ?? ''} onError={() => setFailed(src)} /> : <span aria-hidden={name ? undefined : true}>{initials(name)}</span>}
      {status && <span className={`bsm-avatar-dot bsm-avatar-dot-${status}`} aria-label={status === 'on' ? 'Disponible' : 'No disponible'} />}
    </span>
  )
}
