export const EstadoCita = {
  Pendiente: 'Pendiente',
  Confirmada: 'Confirmada',
  EnProgreso: 'EnProgreso',
  Completada: 'Completada',
  Cancelada: 'Cancelada',
  NoShow: 'NoShow',
} as const

export type EstadoCita = (typeof EstadoCita)[keyof typeof EstadoCita]

export interface Cita {
  id: string
  clienteId: string
  barberoId: string
  servicioId: string
  fechaCita: string
  horaInicio: string
  horaFin: string
  estado: EstadoCita
  notas?: string
  precioFinal: number
  tokenRedisBloqueo?: string
  cliente: { nombre: string; apellido: string; fotoUrl?: string }
  barbero: { nombre: string; apellido: string; fotoUrl?: string }
  servicio: { nombre: string; duracionMinutos: number }
}

export type CitaCreateInput = {
  clienteId: string
  barberoId: string
  servicioId: string
  fechaCita: string
  horaInicio: string
  tokenRedisBloqueo: string
}

export type CitaCancelInput = {
  citaId: string
  motivo?: string
}

export type SlotDisponible = {
  fechaCita: string
  horaInicio: string
  horaFin: string
  disponible: boolean
  bloqueadoPorRedis: boolean
  minutosRestantesBloqueo?: number
}

export type DisponibilidadBarbero = {
  barberoId: string
  barberoNombre: string
  servicioId: string
  duracionServicioMin: number
  fecha: string
  slots: SlotDisponible[]
}
