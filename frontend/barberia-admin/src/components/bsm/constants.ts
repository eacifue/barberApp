import type { IconName } from './icons'

export type AppointmentStatus = 'Pendiente' | 'Confirmada' | 'EnProgreso' | 'Completada' | 'Cancelada' | 'NoShow'
export type ServiceType = 'Corte' | 'Afeitado' | 'Barba' | 'Tinte' | 'Tratamiento' | 'Combo' | 'Otro'
export type Tone = 'neutral' | 'brass' | 'success' | 'warning' | 'danger' | 'info' | 'oxblood'

/** Estado de cita → etiqueta, ícono y clase de token (design/docs/componentes/StatusBadge.md). */
export const STATUS: Record<AppointmentStatus, { label: string; icon: IconName; key: string }> = {
  Pendiente: { label: 'Pendiente', icon: 'hourglass', key: 'pendiente' },
  Confirmada: { label: 'Confirmada', icon: 'circle-check', key: 'confirmada' },
  EnProgreso: { label: 'En progreso', icon: 'scissors', key: 'enprogreso' },
  Completada: { label: 'Completada', icon: 'check-check', key: 'completada' },
  Cancelada: { label: 'Cancelada', icon: 'circle-x', key: 'cancelada' },
  NoShow: { label: 'No asistió', icon: 'user-x', key: 'noshow' },
}

export const SERVICE_ICON: Record<ServiceType, IconName> = {
  Corte: 'scissors',
  Afeitado: 'navaja',
  Barba: 'barba',
  Tinte: 'droplets',
  Tratamiento: 'sparkles',
  Combo: 'layers',
  Otro: 'ellipsis',
}

export const TONE_ICON: Record<string, IconName> = {
  success: 'circle-check',
  warning: 'triangle-alert',
  danger: 'circle-alert',
  info: 'info',
  brass: 'timer',
  neutral: 'info',
}

export type SlotState = 'available' | 'booked' | 'blocked' | 'hold'

export const SLOT_ADMIN: Record<SlotState, { label: string; icon: IconName }> = {
  available: { label: 'Disponible', icon: 'circle' },
  booked: { label: 'Ocupado', icon: 'calendar-check' },
  blocked: { label: 'Bloqueado', icon: 'lock' },
  hold: { label: 'Reservando', icon: 'timer' },
}

export function statusOf(value: string | null | undefined): AppointmentStatus {
  return value && value in STATUS ? (value as AppointmentStatus) : 'Pendiente'
}
