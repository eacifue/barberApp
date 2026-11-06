export const EstadoCita = {
  Pendiente: 'Pendiente',
  Confirmada: 'Confirmada',
  EnProgreso: 'EnProgreso',
  Completada: 'Completada',
  Cancelada: 'Cancelada',
  NoShow: 'NoShow',
} as const

export type EstadoCita = (typeof EstadoCita)[keyof typeof EstadoCita]

/** Forma de `CitaDto` del backend: los IDs vienen dentro de cliente/barbero/servicio. */
export interface Cita {
  id: string
  fechaCita: string
  horaInicio: string
  horaFin: string
  estado: EstadoCita
  notas?: string | null
  precioFinal: number
  createdAt?: string
  tieneReview?: boolean
  cliente: { id: string; nombre: string; apellido: string; telefono?: string; fotoUrl?: string | null }
  barbero: { id: string; nombre: string; apellido: string; fotoUrl?: string | null }
  servicio: { id: string; nombre: string; duracionMinutos: number; precio?: number }
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
