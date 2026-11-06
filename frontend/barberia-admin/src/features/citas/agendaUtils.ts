import type { Cita, EstadoCita } from '../../types/cita'

// Fechas en hora local (la barbería opera en Medellín). No usar toISOString():
// en UTC−5 cambia de día a partir de las 7:00 p. m.

export function isoLocal(d: Date): string {
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}

export function todayIso(): string {
  return isoLocal(new Date())
}

/** `YYYY-MM-DD` → Date a mediodía local (evita saltos por horario de verano). */
export function parseIso(iso: string): Date {
  const [y, m, d] = iso.split('-').map(Number)
  return new Date(y, m - 1, d, 12)
}

export function addDaysIso(iso: string, days: number): string {
  const d = parseIso(iso)
  d.setDate(d.getDate() + days)
  return isoLocal(d)
}

/** Lunes de la semana de `iso`. */
export function mondayOf(iso: string): string {
  const d = parseIso(iso)
  const offset = (d.getDay() + 6) % 7
  d.setDate(d.getDate() - offset)
  return isoLocal(d)
}

export function weekDays(iso: string): string[] {
  const monday = mondayOf(iso)
  return Array.from({ length: 7 }, (_, i) => addDaysIso(monday, i))
}

/** `15:00:00` → `15:00` */
export function hhmm(time: string): string {
  return time.slice(0, 5)
}

export function minutesOf(time: string): number {
  const [h, m] = time.split(':').map(Number)
  return h * 60 + (m || 0)
}

export function nowHHMM(): string {
  const n = new Date()
  return `${String(n.getHours()).padStart(2, '0')}:${String(n.getMinutes()).padStart(2, '0')}`
}

export function nombreCliente(c: Cita): string {
  return `${c.cliente.nombre} ${c.cliente.apellido}`.trim()
}

export function nombreBarbero(c: Cita): string {
  return `${c.barbero.nombre} ${c.barbero.apellido}`.trim()
}

export function compareAsc(a: Cita, b: Cita): number {
  return a.fechaCita === b.fechaCita ? a.horaInicio.localeCompare(b.horaInicio) : a.fechaCita.localeCompare(b.fechaCita)
}

export function compareDesc(a: Cita, b: Cita): number {
  return -compareAsc(a, b)
}

/** La cita ya empezó (en hora local): habilita «No asistió». */
export function yaEmpezo(c: Cita, now = new Date()): boolean {
  const inicio = parseIso(c.fechaCita)
  const [h, m] = c.horaInicio.split(':').map(Number)
  inicio.setHours(h, m || 0, 0, 0)
  return now.getTime() >= inicio.getTime()
}

export const ESTADOS: Array<{ value: EstadoCita; label: string }> = [
  { value: 'Pendiente', label: 'Pendiente' },
  { value: 'Confirmada', label: 'Confirmada' },
  { value: 'EnProgreso', label: 'En progreso' },
  { value: 'Completada', label: 'Completada' },
  { value: 'Cancelada', label: 'Cancelada' },
  { value: 'NoShow', label: 'No asistió' },
]

/** Cuentan para ingresos estimados: lo que no se canceló ni quedó sin asistir. */
export function cuentaParaIngresos(c: Cita): boolean {
  return c.estado !== 'Cancelada' && c.estado !== 'NoShow'
}

/** Mensaje del backend (`{ message }`) o un texto de respaldo. */
export function mensajeDeError(error: unknown, fallback: string): string {
  const data = (error as { response?: { data?: { message?: string } } })?.response?.data
  if (data?.message) return data.message
  if (error instanceof Error && error.message && !error.message.startsWith('Request failed')) return error.message
  return fallback
}

const DIAS_ENUM = ['domingo', 'lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado']

/**
 * ¿La barbería descansa ese día? `barberiaService` entrega los días como
 * números de `Date.getDay()` (0 = domingo); se aceptan también los nombres del
 * enum `DiaSemana` del backend («Domingo», «Miercoles») por si llegan sin convertir.
 */
export function esDiaDescanso(diasDescanso: ReadonlyArray<string | number> | undefined, iso: string): boolean {
  if (!diasDescanso?.length) return false
  const dow = parseIso(iso).getDay()
  return diasDescanso.some((d) =>
    typeof d === 'number' ? d === dow : d.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase() === DIAS_ENUM[dow],
  )
}
