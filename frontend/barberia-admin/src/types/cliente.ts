export interface Cliente {
  id: string
  barberiaId?: string | null
  barberiaNombre?: string | null
  nombre: string
  apellido: string
  telefono: string
  correo: string
  fotoUrl?: string
  tokenFCM?: string
  ultimaCita?: string
  totalCitas: number
  activo: boolean
}

export type ClienteUpsertInput = Pick<Cliente, 'nombre' | 'apellido' | 'telefono' | 'correo' | 'activo' | 'barberiaId'> & {
  password?: string
}
