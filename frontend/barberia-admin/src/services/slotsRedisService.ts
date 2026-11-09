import { http } from './http'

/** `ReservaEnCursoDto`: un horario que un cliente apartó en la app y aún no confirma. */
export type ReservaEnCurso = {
  barberoId: string
  barberoNombre: string
  clienteId: string
  clienteNombre: string
  /** `yyyy-MM-dd` */
  fechaCita: string
  /** `HH:mm:ss` */
  horaInicio: string
  bloqueadoEn: string
  expiraEn: string
  segundosRestantes: number
}

type ApiResp<T> = { success: boolean; message: string; data: T | null }

export const slotsRedisService = {
  async getActivos(): Promise<ReservaEnCurso[]> {
    const response = await http.get<ApiResp<ReservaEnCurso[]>>('/v1/slots/activos')
    return response.data.data ?? []
  },

  /** Recepción libera el horario; el backend avisa al cliente. */
  async liberar(r: Pick<ReservaEnCurso, 'barberoId' | 'fechaCita' | 'horaInicio'>): Promise<void> {
    await http.post('/v1/slots/activos/liberar', { barberoId: r.barberoId, fechaCita: r.fechaCita.slice(0, 10), horaInicio: r.horaInicio })
  },
}
