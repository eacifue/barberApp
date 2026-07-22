import { http } from './http'
import type { Barbero, BarberoUpsertInput } from '../types/barbero'

type ApiLikeResponse<T> = {
  data?: T
}

function unwrap<T>(payload: T | ApiLikeResponse<T>): T {
  if (payload && typeof payload === 'object' && 'data' in (payload as Record<string, unknown>)) {
    return (payload as ApiLikeResponse<T>).data as T
  }
  return payload as T
}

type RawBarbero = {
  id: string
  barberiaId?: string
  nombre: string
  apellido: string
  telefono: string
  correo: string
  fotoUrl?: string
  biografia?: string
  aniosExperiencia?: number
  añosExperiencia?: number
  especialidades?: string[]
  tokenFCM?: string
  tokenFcm?: string
  disponible?: boolean
  ratingPromedio?: number
  activo?: boolean
  barberiaNombre?: string
  servicios?: Array<{
    id: string
    nombre: string
    duracionMinutos: number
    precio: number
  }>
}

function normalizeBarbero(raw: RawBarbero, fallbackBarberiaId?: string): Barbero {
  return {
    id: raw.id,
    barberiaId: raw.barberiaId ?? fallbackBarberiaId ?? '',
    nombre: raw.nombre,
    apellido: raw.apellido,
    telefono: raw.telefono,
    correo: raw.correo,
    fotoUrl: raw.fotoUrl,
    biografia: raw.biografia,
    añosExperiencia: Number(raw.añosExperiencia ?? raw.aniosExperiencia ?? 0),
    especialidades: raw.especialidades ?? [],
    tokenFCM: raw.tokenFCM ?? raw.tokenFcm,
    disponible: Boolean(raw.disponible ?? true),
    ratingPromedio: Number(raw.ratingPromedio ?? 0),
    activo: Boolean(raw.activo ?? true),
    barberiaNombre: raw.barberiaNombre,
    servicios: raw.servicios ?? [],
  }
}

function toApiPayload(data: BarberoUpsertInput) {
  return {
    barberiaId: data.barberiaId,
    nombre: data.nombre.trim(),
    apellido: data.apellido.trim(),
    telefono: data.telefono.trim(),
    correo: data.correo.trim(),
    fotoUrl: data.fotoUrl?.trim() || null,
    biografia: data.biografia?.trim() || null,
    aniosExperiencia: Number(data.añosExperiencia),
    especialidades: data.especialidades,
    servicioIds: data.servicioIds,
  }
}

export const barberoService = {
  async getByBarberia(barberiaId: string): Promise<Barbero[]> {
    const response = await http.get<RawBarbero[] | ApiLikeResponse<RawBarbero[]>>(`/v1/barberias/${barberiaId}/barberos`)
    const payload = unwrap(response.data) ?? []
    return payload.map((item) => normalizeBarbero(item, barberiaId))
  },

  async getById(id: string): Promise<Barbero> {
    const response = await http.get<RawBarbero | ApiLikeResponse<RawBarbero>>(`/v1/barberos/${id}`)
    return normalizeBarbero(unwrap(response.data))
  },

  async create(data: BarberoUpsertInput): Promise<Barbero> {
    const response = await http.post<RawBarbero | ApiLikeResponse<RawBarbero>>('/v1/barberos', toApiPayload(data))
    return normalizeBarbero(unwrap(response.data), data.barberiaId)
  },

  async update(id: string, data: BarberoUpsertInput): Promise<Barbero> {
    const response = await http.put<RawBarbero | ApiLikeResponse<RawBarbero>>(`/v1/barberos/${id}`, toApiPayload(data))
    return normalizeBarbero(unwrap(response.data), data.barberiaId)
  },

  async updateFCM(id: string, token: string): Promise<void> {
    await http.put(`/v1/barberos/${id}/fcm-token`, { tokenFCM: token })
  },

  async remove(id: string): Promise<void> {
    await http.delete(`/v1/barberos/${id}`)
  },
}
