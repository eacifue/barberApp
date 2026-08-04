export const TipoServicio = {
  Corte: 1,
  Afeitado: 2,
  Barba: 3,
  Tinte: 4,
  Tratamiento: 5,
  Combo: 6,
  Otro: 7,
} as const

export type TipoServicio = (typeof TipoServicio)[keyof typeof TipoServicio]

// Map para labels
export const TipoServicioLabel: Record<TipoServicio, string> = {
  1: 'Corte',
  2: 'Afeitado',
  3: 'Barba',
  4: 'Tinte',
  5: 'Tratamiento',
  6: 'Combo',
  7: 'Otro',
} as const

export interface Servicio {
  id: string
  nombre: string
  descripcion?: string
  tipo: TipoServicio
  duracionMinutos: number
  precio: number
  fotoUrl?: string
  activo: boolean
}

export type ServicioUpsertInput = Omit<Servicio, 'id'>
