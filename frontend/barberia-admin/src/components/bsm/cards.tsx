import type { ReactNode } from 'react'

import { renderActions, type ActionSpec } from './actions'

import { SERVICE_ICON, type AppointmentStatus, type ServiceType } from './constants'
import { Avatar, Badge, Chip, Rating, StatusBadge } from './controls'
import { cx, formatCOP, formatDecimal, formatDuration, formatTime, MONTHS, MONTHS_SHORT, WEEKDAYS } from './format'
import { Icon } from './Icon'
import type { IconName } from './icons'

type ServiceCardProps = {
  name: string
  type?: ServiceType
  description?: string
  duration: number
  price: number | string
  image?: string | null
  /** p. ej. «Popular». */
  tag?: string
  selected?: boolean
  onClick?: () => void
  className?: string
}

/** Va dentro de un contenedor `role="radiogroup"`. */
export function ServiceCard({ name, type = 'Corte', description, duration, price, image, tag, selected, onClick, className }: ServiceCardProps) {
  return (
    <button type="button" role="radio" aria-checked={!!selected} className={cx('bsm-card', 'bsm-card-press', 'bsm-service', selected && 'is-selected', className)} onClick={onClick}>
      {image ? (
        <img className="bsm-service-img" src={image} alt="" />
      ) : (
        <span className="bsm-service-icon">
          <Icon name={SERVICE_ICON[type] ?? 'scissors'} size={24} />
        </span>
      )}
      <span className="bsm-service-body">
        <span className="bsm-service-top">
          <span className="bsm-card-title">{name}</span>
          {tag && <Badge tone="oxblood">{tag}</Badge>}
        </span>
        {description && <span className="bsm-card-desc">{description}</span>}
        <span className="bsm-service-meta">
          <span className="bsm-meta">
            <Icon name="clock" size={16} />
            {formatDuration(duration || 30)}
          </span>
          <span className="bsm-price">{typeof price === 'number' ? formatCOP(price) : price}</span>
        </span>
      </span>
      {selected && (
        <span className="bsm-card-check" aria-hidden="true">
          <Icon name="check" size={16} strokeWidth={3} />
        </span>
      )}
    </button>
  )
}

type BarberCardProps = {
  name: string
  photo?: string | null
  rating?: number | null
  reviews?: number
  years: number
  specialties?: string[]
  /** `false` = «No disponible hoy», no seleccionable; va al final de la lista. */
  available?: boolean
  unavailableLabel?: string
  /** Precio especial para el servicio elegido. */
  specialPrice?: number
  selected?: boolean
  onClick?: () => void
  onProfile?: () => void
  className?: string
}

export function BarberCard({ name, photo, rating, reviews, years, specialties, available, unavailableLabel, specialPrice, selected, onClick, onProfile, className }: BarberCardProps) {
  const unavailable = available === false
  return (
    <div className={cx('bsm-card', 'bsm-barber', selected && 'is-selected', unavailable && 'is-unavailable', className)}>
      <button type="button" role="radio" aria-checked={!!selected} aria-disabled={unavailable || undefined} className="bsm-barber-hit" onClick={unavailable ? undefined : onClick}>
        <Avatar name={name} src={photo} size={64} />
        <span className="bsm-barber-body">
          <span className="bsm-card-title">{name}</span>
          <span className="bsm-barber-line">
            <Rating value={rating} count={reviews} compact />
            <span className="bsm-dot-sep" aria-hidden="true">
              ·
            </span>
            <span className="bsm-meta">
              {years} {years === 1 ? 'año' : 'años'} de experiencia
              {specialPrice != null && ` · ${formatCOP(specialPrice)}`}
            </span>
          </span>
          {specialties && specialties.length > 0 && (
            <span className="bsm-chip-row">
              {specialties.slice(0, 3).map((s) => (
                <Chip key={s} as="tag">
                  {s}
                </Chip>
              ))}
            </span>
          )}
          {unavailable && (
            <Badge tone="neutral" icon="calendar-x">
              {unavailableLabel || 'No disponible hoy'}
            </Badge>
          )}
        </span>
        {selected && (
          <span className="bsm-card-check" aria-hidden="true">
            <Icon name="check" size={16} strokeWidth={3} />
          </span>
        )}
      </button>
      {onProfile && (
        <button type="button" className="bsm-link bsm-barber-profile" onClick={onProfile}>
          Ver perfil
          <Icon name="chevron-right" size={16} />
        </button>
      )}
    </div>
  )
}

type AppointmentCardProps = {
  service: string
  barber: string
  barberPhoto?: string | null
  date: string | Date
  /** `HH:mm` */
  start: string
  end: string
  status: AppointmentStatus
  price?: number
  /** Si se pasa, la tarjeta entera abre el detalle. */
  onOpen?: () => void
  actions?: ReactNode | ActionSpec[]
  className?: string
}

/** El estado se comunica con StatusBadge, nunca con una barra de color lateral. */
export function AppointmentCard({ service, barber, barberPhoto, date, start, end, status, price, onOpen, actions, className }: AppointmentCardProps) {
  const d = date instanceof Date ? date : new Date(`${date}T12:00:00`)
  return (
    <article className={cx('bsm-card', 'bsm-appt', onOpen && 'bsm-card-press', className)} onClick={onOpen}>
      <div className="bsm-appt-date" aria-hidden="true">
        <span className="bsm-appt-wd">{WEEKDAYS[d.getDay()].slice(0, 3)}</span>
        <span className="bsm-appt-day">{d.getDate()}</span>
        <span className="bsm-appt-mon">{MONTHS_SHORT[d.getMonth()]}</span>
      </div>
      <div className="bsm-appt-body">
        <div className="bsm-appt-head">
          <h3 className="bsm-card-title">
            {onOpen ? (
              <button
                type="button"
                className="bsm-appt-open"
                onClick={(e) => {
                  e.stopPropagation()
                  onOpen()
                }}
              >
                {service}
              </button>
            ) : (
              service
            )}
          </h3>
          <StatusBadge status={status} />
        </div>
        <p className="bsm-appt-line">
          <Avatar name={barber} src={barberPhoto} size={24} />
          con {barber}
        </p>
        <p className="bsm-appt-line bsm-meta">
          <Icon name="clock" size={16} />
          <span className="bsm-sr">{`${WEEKDAYS[d.getDay()]} ${d.getDate()} de ${MONTHS[d.getMonth()]}, `}</span>
          {formatTime(start)} – {formatTime(end)}
          {price != null && <span className="bsm-appt-price">{formatCOP(price)}</span>}
        </p>
        {actions != null && (
          <div className="bsm-appt-actions" onClick={(e) => e.stopPropagation()}>
            {renderActions(actions)}
          </div>
        )}
      </div>
    </article>
  )
}

type StatCardProps = {
  label: string
  /** Ya formateado. */
  value: string
  icon?: IconName
  /** Porcentaje, positivo o negativo. */
  delta?: number
  deltaLabel?: string
  /** `true` cuando bajar es bueno (p. ej. cancelaciones). */
  invert?: boolean
  hint?: ReactNode
  className?: string
}

/** La tendencia lleva flecha + signo + texto, no solo color. */
export function StatCard({ label, value, icon, delta, deltaLabel, invert, hint, className }: StatCardProps) {
  const up = delta != null && delta >= 0
  const good = invert ? !up : up
  return (
    <section className={cx('bsm-card', 'bsm-stat', className)}>
      <div className="bsm-stat-head">
        <span className="bsm-stat-label">{label}</span>
        {icon && (
          <span className="bsm-stat-icon">
            <Icon name={icon} size={20} />
          </span>
        )}
      </div>
      <p className="bsm-stat-value">{value}</p>
      {delta != null ? (
        <p className={cx('bsm-stat-delta', good ? 'is-good' : 'is-bad')}>
          <Icon name={up ? 'trending-up' : 'trending-down'} size={16} />
          <strong>
            {up ? '+' : '−'}
            {formatDecimal(Math.abs(delta), Number.isInteger(delta) ? 0 : 1)} %
          </strong>
          <span> {deltaLabel || 'vs. semana pasada'}</span>
        </p>
      ) : hint ? (
        <p className="bsm-stat-delta">{hint}</p>
      ) : null}
    </section>
  )
}
