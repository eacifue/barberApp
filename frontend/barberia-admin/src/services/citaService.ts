import { http } from './http'
import type {
  Cita,
  CitaCancelInput,
  CitaCreateInput,
  DisponibilidadBarbero,
} from '../types/cita'

type ApiLikeResponse<T> = {
  data?: T
}

type BloqueoResult = {
  exitoso: boolean
  tokenBloqueo?: string
  mensajeError?: string
}

function unwrap<T>(payload: T | ApiLikeResponse<T>): T {
  if (payload && typeof payload === 'object' && 'data' in (payload as Record<string, unknown>)) {
    return (payload as ApiLikeResponse<T>).data as T
  }
  return payload as T
}

export const citaService = {
  async getAdminList(params: {
    barberoId?: string
    fechaInicio?: string
    fechaFin?: string
    date?: string
    from?: string
    to?: string
    status?: string
    page?: number
    pageSize?: number
  }): Promise<Cita[]> {
    const response = await http.get<Cita[] | ApiLikeResponse<Cita[]>>('/v1/admin/citas', {
      params,
    })
    return unwrap(response.data) ?? []
  },

  async getByBarbero(barberoId: string, fecha: string): Promise<Cita[]> {
    const response = await http.get<Cita[] | ApiLikeResponse<Cita[]>>(`/v1/barberos/${barberoId}/citas`, {
      params: { fecha },
    })
    return unwrap(response.data) ?? []
  },

  async getById(id: string): Promise<Cita> {
    const response = await http.get<Cita | ApiLikeResponse<Cita>>(`/v1/citas/${id}`)
    return unwrap(response.data)
  },

  async create(payload: CitaCreateInput): Promise<Cita> {
    const response = await http.post<Cita | ApiLikeResponse<Cita>>('/v1/citas', payload)
    return unwrap(response.data)
  },

  async confirm(id: string): Promise<Cita> {
    const response = await http.put<Cita | ApiLikeResponse<Cita>>(`/v1/citas/${id}/confirmar`)
    return unwrap(response.data)
  },

  async complete(id: string): Promise<Cita> {
    const response = await http.put<Cita | ApiLikeResponse<Cita>>(`/v1/citas/${id}/completar`)
    return unwrap(response.data)
  },

  /** Confirmada → En progreso. */
  async start(id: string): Promise<Cita> {
    const response = await http.put<Cita | ApiLikeResponse<Cita>>(`/v1/citas/${id}/iniciar`)
    return unwrap(response.data)
  },

  /** Pendiente o Confirmada → No asistió (desde la hora de inicio). */
  async noShow(id: string): Promise<Cita> {
    const response = await http.put<Cita | ApiLikeResponse<Cita>>(`/v1/citas/${id}/no-asistio`)
    return unwrap(response.data)
  },

  async cancel(id: string, payload: CitaCancelInput): Promise<Cita> {
    const response = await http.put<Cita | ApiLikeResponse<Cita>>(`/v1/citas/${id}/cancelar`, payload)
    return unwrap(response.data)
  },

  async getDisponibilidad(barberoId: string, servicioId: string, fecha: string): Promise<DisponibilidadBarbero> {
    const response = await http.get<DisponibilidadBarbero | ApiLikeResponse<DisponibilidadBarbero>>(
      `/v1/barberos/${barberoId}/disponibilidad`,
      { params: { servicioId, fecha } },
    )
    return unwrap(response.data)
  },

  async bloquearSlot(
    barberoId: string,
    servicioId: string,
    fechaCita: string,
    horaInicio: string,
    clienteId?: string,
  ): Promise<BloqueoResult> {
    const response = await http.post<BloqueoResult | ApiLikeResponse<BloqueoResult>>('/v1/slots/bloquear', {
      barberoId,
      servicioId,
      fechaCita,
      horaInicio,
      clienteId,
    })
    return unwrap(response.data)
  },
}
