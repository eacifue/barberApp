import { useRef, type KeyboardEvent } from 'react'

import { SLOT_ADMIN, type SlotState } from './constants'
import { IconButton } from './controls'
import { cx, formatTime, MONTHS, parseHM, WEEKDAYS_MONDAY } from './format'
import { Icon } from './Icon'

/* ---------- Stepper ---------- */

const DEFAULT_STEPS = ['Servicio', 'Barbero', 'Horario', 'Confirmar']

type StepperProps = {
  current: number
  steps?: string[]
  /** Tocar un paso hecho regresa a él conservando la selección. */
  onStep?: (step: number) => void
}

export function Stepper({ current, steps = DEFAULT_STEPS, onStep }: StepperProps) {
  return (
    <nav className="bsm-stepper" aria-label="Progreso de la reserva">
      <p className="bsm-stepper-count">
        <strong>
          Paso {current} de {steps.length}
        </strong>
        {` · ${steps[current - 1]}`}
      </p>
      <ol className="bsm-stepper-list">
        {steps.map((s, i) => {
          const n = i + 1
          const state = n < current ? 'done' : n === current ? 'current' : 'todo'
          const label = (
            <>
              {state === 'done' && <Icon name="check" size={14} strokeWidth={3} />}
              {s}
            </>
          )
          return (
            <li key={s} className={`bsm-step is-${state}`} aria-current={state === 'current' ? 'step' : undefined}>
              <span className="bsm-step-bar" />
              {state === 'done' && onStep ? (
                <button type="button" className="bsm-step-label bsm-step-back" onClick={() => onStep(n)}>
                  {label}
                </button>
              ) : (
                <span className="bsm-step-label">{label}</span>
              )}
            </li>
          )
        })}
      </ol>
    </nav>
  )
}

/* ---------- Calendar ---------- */

type CalendarProps = {
  year: number
  /** 0–11 */
  month: number
  /** Día de hoy si cae en este mes. */
  today?: number
  selected?: number
  /** Días pasados, de descanso de la barbería y libres del barbero. */
  disabled?: (day: number) => boolean
  /** `few` = pocos horarios (punto naranja); `any` = hay horarios. */
  marks?: Record<number, 'few' | 'any'>
  legend?: string
  onSelect?: (day: number) => void
  onPrevMonth?: () => void
  onNextMonth?: () => void
  prevDisabled?: boolean
  nextDisabled?: boolean
  className?: string
}

/** Lunes primero, celdas de 44 px; flechas mueven el foco entre días. */
export function Calendar({ year, month, today, selected, disabled, marks = {}, legend, onSelect, onPrevMonth, onNextMonth, prevDisabled, nextDisabled, className }: CalendarProps) {
  const gridRef = useRef<HTMLDivElement>(null)
  const offset = (new Date(year, month, 1).getDay() + 6) % 7
  const days = new Date(year, month + 1, 0).getDate()
  const cells: Array<number | null> = [...Array(offset).fill(null), ...Array.from({ length: days }, (_, i) => i + 1)]
  const isOff = (d: number) => !!disabled?.(d)
  const focusDay = selected && !isOff(selected) ? selected : today && !isOff(today) ? today : cells.find((d) => d != null && !isOff(d)) ?? 1

  const onKeyDown = (e: KeyboardEvent<HTMLButtonElement>, d: number) => {
    const step = { ArrowLeft: -1, ArrowRight: 1, ArrowUp: -7, ArrowDown: 7 }[e.key]
    if (!step) return
    e.preventDefault()
    let next = d + step
    while (next >= 1 && next <= days && isOff(next)) next += step > 0 ? 1 : -1
    if (next < 1 || next > days) return
    gridRef.current?.querySelector<HTMLButtonElement>(`[data-day="${next}"]`)?.focus()
  }

  return (
    <div className={cx('bsm-cal', className)}>
      <div className="bsm-cal-head">
        <h3 className="bsm-cal-title" aria-live="polite">
          {MONTHS[month].charAt(0).toUpperCase() + MONTHS[month].slice(1)} {year}
        </h3>
        <div className="bsm-cal-nav">
          <IconButton icon="chevron-left" label="Mes anterior" size="sm" onClick={onPrevMonth} disabled={prevDisabled || !onPrevMonth} />
          <IconButton icon="chevron-right" label="Mes siguiente" size="sm" onClick={onNextMonth} disabled={nextDisabled || !onNextMonth} />
        </div>
      </div>
      <div className="bsm-cal-grid" role="grid" ref={gridRef}>
        {WEEKDAYS_MONDAY.map((w, i) => (
          <span key={w} className="bsm-cal-wd" role="columnheader" aria-label={w}>
            {['L', 'M', 'M', 'J', 'V', 'S', 'D'][i]}
          </span>
        ))}
        {cells.map((d, i) => {
          if (d == null) return <span key={`e${i}`} />
          const dis = isOff(d)
          const sel = selected === d
          const isToday = today === d
          return (
            <button
              key={d}
              type="button"
              role="gridcell"
              data-day={d}
              disabled={dis}
              tabIndex={d === focusDay ? 0 : -1}
              aria-selected={sel || undefined}
              aria-current={isToday ? 'date' : undefined}
              aria-label={`${d} de ${MONTHS[month]}${marks[d] === 'few' ? ', pocos horarios' : ''}${dis ? ', sin horarios' : ''}`}
              className={cx('bsm-cal-day', sel && 'is-selected', isToday && 'is-today', dis && 'is-disabled')}
              onClick={() => onSelect?.(d)}
              onKeyDown={(e) => onKeyDown(e, d)}
            >
              <span>{d}</span>
              {marks[d] && <span className={`bsm-cal-mark bsm-cal-mark-${marks[d]}`} />}
            </button>
          )
        })}
      </div>
      {legend && <p className="bsm-cal-legend">{legend}</p>}
    </div>
  )
}

/* ---------- SlotGrid ---------- */

export type Slot = { time: string; state?: SlotState; note?: string }

type SlotGridProps = {
  slots: Slot[]
  selected?: string
  mode?: 'client' | 'admin'
  label?: string
  onSelect?: (slot: Slot) => void
}

const GROUPS: Array<[string, number, number]> = [
  ['Mañana', 0, 720],
  ['Tarde', 720, 1080],
  ['Noche', 1080, 1440],
]

/**
 * Cliente: libre / elegido / no disponible, por Mañana-Tarde-Noche; los no
 * disponibles van tachados y no son enfocables. Admin: los 4 estados con ícono
 * y palabra, y leyenda que no depende del color.
 */
export function SlotGrid({ slots, selected, mode = 'client', label, onSelect }: SlotGridProps) {
  if (mode === 'admin') {
    return (
      <div className="bsm-slots is-admin">
        <ul className="bsm-slot-legend" aria-label="Leyenda">
          {(Object.keys(SLOT_ADMIN) as SlotState[]).map((k) => (
            <li key={k} className={`bsm-slot-key bsm-slotstate-${k}`}>
              <Icon name={SLOT_ADMIN[k].icon} size={16} />
              {SLOT_ADMIN[k].label}
            </li>
          ))}
        </ul>
        <div className="bsm-slot-grid">
          {slots.map((s) => {
            const state = s.state ?? 'available'
            const st = SLOT_ADMIN[state]
            return (
              <button
                key={s.time}
                type="button"
                className={`bsm-slot bsm-slotstate-${state}`}
                aria-label={`${formatTime(s.time)}, ${st.label}${s.note ? `, ${s.note}` : ''}`}
                onClick={() => onSelect?.(s)}
              >
                <span className="bsm-slot-time">{formatTime(s.time)}</span>
                <span className="bsm-slot-state">
                  <Icon name={st.icon} size={14} strokeWidth={2.25} />
                  {s.note || st.label}
                </span>
              </button>
            )
          })}
        </div>
      </div>
    )
  }
  return (
    <div className="bsm-slots" role="radiogroup" aria-label={label || 'Horarios disponibles'}>
      {GROUPS.map(([name, from, to]) => {
        const inGroup = slots.filter((s) => {
          const m = parseHM(s.time)
          return m >= from && m < to
        })
        if (!inGroup.length) return null
        return (
          <section key={name} className="bsm-slot-group">
            <h4 className="bsm-overline">
              {name}
              <span className="bsm-slot-sfx">{from < 720 ? ' · a. m.' : ' · p. m.'}</span>
            </h4>
            <div className="bsm-slot-grid">
              {inGroup.map((s) => {
                const sel = selected === s.time
                const off = !!s.state && s.state !== 'available'
                return (
                  <button
                    key={s.time}
                    type="button"
                    role="radio"
                    aria-checked={sel}
                    disabled={off}
                    aria-label={formatTime(s.time) + (off ? ', no disponible' : '')}
                    className={cx('bsm-slot', sel && 'is-selected', off && 'is-off')}
                    onClick={() => onSelect?.(s)}
                  >
                    {formatTime(s.time, true)}
                  </button>
                )
              })}
            </div>
          </section>
        )
      })}
    </div>
  )
}

/* ---------- Countdown ---------- */

type CountdownProps = {
  /** Segundos restantes, calculados desde la expiración del servidor. */
  seconds: number
  total?: number
  variant?: 'compact'
  label?: string
}

/** Latón hasta 1:01; en el último minuto pasa a `warning` y se anuncia una sola vez. */
export function Countdown({ seconds, total = 300, variant, label }: CountdownProps) {
  const s = Math.max(0, Math.floor(seconds))
  const mm = Math.floor(s / 60)
  const ss = s % 60
  const low = s <= 60
  // El texto aparece una vez al entrar al último minuto y no cambia después,
  // así que el lector de pantalla lo anuncia una sola vez.
  const announcement = low && s > 0 ? 'Queda menos de un minuto para confirmar tu horario.' : ''
  return (
    <div
      className={cx('bsm-countdown', low && 'is-low', variant === 'compact' && 'is-compact')}
      role="timer"
      aria-live="off"
      aria-label={`Tiempo restante ${mm} minutos ${ss} segundos`}
    >
      <Icon name="timer" size={20} />
      <div className="bsm-countdown-text">
        <span className="bsm-countdown-label">{low ? 'Tu horario se libera en' : label || 'Horario apartado por'}</span>
        {variant !== 'compact' && <span className="bsm-countdown-hint">{low ? 'Confirma ahora para no perderlo.' : 'Lo guardamos 5 min mientras confirmas.'}</span>}
      </div>
      <span className="bsm-countdown-time">
        {mm}:{ss < 10 ? '0' : ''}
        {ss}
      </span>
      <span className="bsm-countdown-bar" aria-hidden="true">
        <span style={{ transform: `scaleX(${Math.min(1, s / total)})` }} />
      </span>
      <span className="bsm-sr" aria-live="assertive">
        {announcement}
      </span>
    </div>
  )
}
