export interface SlotDisponible {
  horaInicio: string
  horaFin: string
  disponible: boolean
  bloqueadoPorRedis: boolean
  minutosRestantesBloqueo?: number
}
