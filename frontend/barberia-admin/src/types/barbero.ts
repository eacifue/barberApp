export interface Barbero {
  id: string
  nombre: string
  apellido: string
  telefono: string
  correo: string
  fotoUrl?: string
  biografia?: string
  añosExperiencia: number
  especialidades: string[]
  tokenFCM?: string
  disponible: boolean
  ratingPromedio: number
  activo: boolean
  servicios?: Array<{
    id: string
    nombre: string
    duracionMinutos: number
    precio: number
  }>
}

export type BarberoUpsertInput = {
  nombre: string
  apellido: string
  telefono: string
  correo: string
  fotoUrl?: string
  biografia?: string
  añosExperiencia: number
  especialidades: string[]
  tokenFCM?: string
  disponible: boolean
  activo: boolean
  servicioIds: string[]
}
