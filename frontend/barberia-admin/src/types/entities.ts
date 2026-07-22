export type Barberia = {
  id: string
  nombre: string
  ciudad: string
  estado: 'Activa' | 'Inactiva'
}

export type Barbero = {
  id: string
  nombre: string
  especialidad: string
}

export type Servicio = {
  id: string
  nombre: string
  duracionMin: number
  precio: number
}
