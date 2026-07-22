export interface Barberia {
  id: string
  nombre: string
  descripcion?: string
  telefono: string
  correo: string
  direccion: string
  ciudad: string
  departamento: string
  pais: string
  latitud: number
  longitud: number
  horaApertura: string
  horaCierre: string
  diasDescanso: number[]
  activa: boolean
  totalBarberos?: number
}

export type BarberiaUpsertInput = Omit<Barberia, 'id' | 'totalBarberos'>
