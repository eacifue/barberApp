export interface Cliente {
  id: string
  nombre: string
  apellido: string
  telefono: string
  correo: string
  fotoUrl?: string
  tokenFCM?: string
  ultimaCita?: string
  totalCitas: number
  activo: boolean
  /** Rol de la cuenta: la lista de clientes trae también al personal. */
  rol?: string
  createdAt?: string
}

export type ClienteUpsertInput = Pick<Cliente, 'nombre' | 'apellido' | 'telefono' | 'correo' | 'activo'> & {
  password?: string
}
