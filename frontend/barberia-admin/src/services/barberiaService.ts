import { http } from './http'
import type { Barberia, BarberiaUpsertInput } from '../types/barberia'

type ApiLikeResponse<T> = {
  data?: T
}

function unwrap<T>(payload: T | ApiLikeResponse<T>): T {
  if (payload && typeof payload === 'object' && 'data' in (payload as Record<string, unknown>)) {
    return (payload as ApiLikeResponse<T>).data as T
  }
  return payload as T
}

// Frontend usa números 0-6 estilo JS (0=Dom, 1=Lun, ..., 6=Sab).
// Backend usa nombres del enum DiaSemana (Lunes=1..Domingo=7).
const FRONTEND_TO_API: Record<number, string> = {
  0: 'Domingo',
  1: 'Lunes',
  2: 'Martes',
  3: 'Miercoles',
  4: 'Jueves',
  5: 'Viernes',
  6: 'Sabado',
}

const API_TO_FRONTEND: Record<string, number> = {
  Domingo: 0,
  Lunes: 1,
  Martes: 2,
  Miercoles: 3,
  Jueves: 4,
  Viernes: 5,
  Sabado: 6,
}

/** Convierte number[] del frontend → string[] que espera el backend */
function toApiDias(dias: number[]): string[] {
  return dias.map((d) => FRONTEND_TO_API[d]).filter(Boolean)
}

/** Convierte string[] del backend → number[] que usa el frontend */
function fromApiDias(dias: unknown): number[] {
  if (!Array.isArray(dias)) return []
  return (dias as string[])
    .map((d) => API_TO_FRONTEND[d])
    .filter((v) => v !== undefined)
}

type RawBarberia = Omit<Barberia, 'diasDescanso'> & { diasDescanso: unknown }

function normalizeBarberia(raw: RawBarberia): Barberia {
  return { ...raw, diasDescanso: fromApiDias(raw.diasDescanso) }
}

export const barberiaService = {
  async getAll(): Promise<Barberia[]> {
    const response = await http.get<RawBarberia[] | ApiLikeResponse<RawBarberia[]>>('/v1/admin/barberias')
    const raw = unwrap(response.data) ?? []
    return raw.map(normalizeBarberia)
  },

  async getById(id: string): Promise<Barberia> {
    const response = await http.get<RawBarberia | ApiLikeResponse<RawBarberia>>(`/v1/admin/barberias/${id}`)
    return normalizeBarberia(unwrap(response.data))
  },

  async getPublicById(id: string): Promise<Barberia> {
    const response = await http.get<RawBarberia | ApiLikeResponse<RawBarberia>>(`/v1/barberias/${id}`)
    return normalizeBarberia(unwrap(response.data))
  },

  async update(id: string, data: BarberiaUpsertInput): Promise<Barberia> {
    const payload = { ...data, diasDescanso: toApiDias(data.diasDescanso) }
    const response = await http.put<RawBarberia | ApiLikeResponse<RawBarberia>>(`/v1/admin/barberias/${id}`, payload)
    return normalizeBarberia(unwrap(response.data))
  },
}
