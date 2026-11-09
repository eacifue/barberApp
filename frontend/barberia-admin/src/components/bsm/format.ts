// Formatos es-CO del sistema (design/docs/03-copy.md). Mismo resultado que
// app/barberia_app/lib/shared/format/formato.dart.

export const MONTHS = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre']
export const MONTHS_SHORT = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic']
/** Domingo primero, como `Date.getDay()`. */
export const WEEKDAYS = ['domingo', 'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado']
/** Lunes primero, para el calendario. */
export const WEEKDAYS_MONDAY = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo']

/** `$45.000` */
export function formatCOP(n: number): string {
  return '$' + Math.round(n).toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.')
}

/** `HH:mm` → minutos desde medianoche. */
export function parseHM(t: string): number {
  const [h, m] = String(t).split(':')
  return Number(h) * 60 + (Number(m) || 0)
}

/** `3:30 p. m.` (o `3:30` con `compact`). Acepta `HH:mm`, minutos o `Date`. */
export function formatTime(t: string | number | Date, compact = false): string {
  const m = t instanceof Date ? t.getHours() * 60 + t.getMinutes() : typeof t === 'number' ? t : parseHM(t)
  const hh = Math.floor(m / 60)
  const mm = m % 60
  const h12 = hh % 12 === 0 ? 12 : hh % 12
  const base = `${h12}:${mm < 10 ? '0' : ''}${mm}`
  return compact ? base : `${base} ${hh < 12 ? 'a. m.' : 'p. m.'}`
}

/** `50 min` · `1 h` · `1 h 15 min` */
export function formatDuration(min: number): string {
  if (min < 60) return `${min} min`
  const hh = Math.floor(min / 60)
  const mm = min % 60
  return `${hh} h${mm ? ` ${mm} min` : ''}`
}

/** `4,8` */
export function formatDecimal(n: number, digits = 1): string {
  return n.toFixed(digits).replace('.', ',')
}

/** `301 141 9610`: agrupa 3-3-4 un celular colombiano (acepta +57); otros números quedan igual. */
export function formatPhone(raw?: string | null): string {
  const d = String(raw ?? '').replace(/\D/g, '')
  const local = d.length === 12 && d.startsWith('57') ? d.slice(2) : d
  return local.length === 10 ? `${local.slice(0, 3)} ${local.slice(3, 6)} ${local.slice(6)}` : String(raw ?? '')
}

/** `jueves 12 de noviembre` */
export function formatLongDate(d: Date): string {
  return `${WEEKDAYS[d.getDay()]} ${d.getDate()} de ${MONTHS[d.getMonth()]}`
}

/** `12 nov` */
export function formatShortDate(d: Date, withYear = false): string {
  return `${d.getDate()} ${MONTHS_SHORT[d.getMonth()]}${withYear ? ` ${d.getFullYear()}` : ''}`
}

export function initials(name?: string): string {
  return String(name ?? '')
    .trim()
    .split(/\s+/)
    .slice(0, 2)
    .map((w) => w.charAt(0).toUpperCase())
    .join('')
}

export function cx(...parts: unknown[]): string {
  return parts.filter((p): p is string => typeof p === "string" && p.length > 0).join(' ')
}
