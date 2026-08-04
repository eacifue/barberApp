import { http } from './http'
import { TipoServicio, type Servicio, type ServicioUpsertInput } from '../types/servicio'

type ApiLikeResponse<T> = {
  data?: T
}

type ServicioApi = Omit<Servicio, 'tipo' | 'precio' | 'duracionMinutos'> & {
  tipo: number | string
  precio: number | string
  duracionMinutos: number | string
}

const tipoMapByName: Record<string, Servicio['tipo']> = {
  corte: TipoServicio.Corte,
  afeitado: TipoServicio.Afeitado,
  barba: TipoServicio.Barba,
  tinte: TipoServicio.Tinte,
  tratamiento: TipoServicio.Tratamiento,
  combo: TipoServicio.Combo,
  otro: TipoServicio.Otro,
}

function unwrap<T>(payload: T | ApiLikeResponse<T>): T {
  if (payload && typeof payload === 'object' && 'data' in (payload as Record<string, unknown>)) {
    return (payload as ApiLikeResponse<T>).data as T
  }
  return payload as T
}

function normalizeTipo(tipo: unknown): Servicio['tipo'] {
  if (typeof tipo === 'number' && tipo >= 1 && tipo <= 7) return tipo as Servicio['tipo']
  if (typeof tipo === 'string') {
    const byName = tipoMapByName[tipo.trim().toLowerCase()]
    if (byName) return byName

    const asNumber = Number(tipo)
    if (!Number.isNaN(asNumber) && asNumber >= 1 && asNumber <= 7) {
      return asNumber as Servicio['tipo']
    }
  }
  return TipoServicio.Otro
}

function normalizeServicio(raw: ServicioApi): Servicio {
  return {
    ...raw,
    tipo: normalizeTipo(raw.tipo),
    duracionMinutos: Number(raw.duracionMinutos ?? 0),
    precio: Number(raw.precio ?? 0),
  }
}

function toApiPayload(data: ServicioUpsertInput) {
  return {
    nombre: data.nombre.trim(),
    descripcion: data.descripcion ?? '',
    tipo: Number(data.tipo),
    duracionMinutos: Number(data.duracionMinutos),
    precio: Number(data.precio),
    fotoUrl: data.fotoUrl?.trim() || null,
  }
}

export const servicioService = {
  async getByBarberia(barberiaId: string): Promise<Servicio[]> {
    const response = await http.get<ServicioApi[] | ApiLikeResponse<ServicioApi[]>>(`/v1/barberias/${barberiaId}/servicios`)
    const payload = unwrap(response.data) ?? []
    return payload.map((item) => normalizeServicio(item))
  },

  async getById(id: string): Promise<Servicio> {
    const response = await http.get<ServicioApi | ApiLikeResponse<ServicioApi>>(`/v1/servicios/${id}`)
    return normalizeServicio(unwrap(response.data))
  },

  async create(data: ServicioUpsertInput): Promise<Servicio> {
    const response = await http.post<ServicioApi | ApiLikeResponse<ServicioApi>>('/v1/servicios', toApiPayload(data))
    return normalizeServicio(unwrap(response.data))
  },

  async update(id: string, data: ServicioUpsertInput): Promise<Servicio> {
    const response = await http.put<ServicioApi | ApiLikeResponse<ServicioApi>>(`/v1/servicios/${id}`, toApiPayload(data))
    return normalizeServicio(unwrap(response.data))
  },

  async remove(id: string): Promise<void> {
    await http.delete(`/v1/servicios/${id}`)
  },
}
