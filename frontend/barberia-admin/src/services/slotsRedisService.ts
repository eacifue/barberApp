import { http } from './http'
import type { AxiosError } from 'axios'

export type SlotActivo = {
  keyRedis: string
  cliente: string
  clienteId?: string
  barberoId: string
  fechaCita: string
  horaInicio: string
  tokenBloqueo: string
  bloqueadoEn: string
  expiraEn: string
}

type ApiLikeResponse<T> = {
  data?: T
}

type AnyRecord = Record<string, unknown>

function unwrap<T>(payload: T | ApiLikeResponse<T>): T {
  if (payload && typeof payload === 'object' && 'data' in (payload as AnyRecord)) {
    return (payload as ApiLikeResponse<T>).data as T
  }
  return payload as T
}

function readString(source: AnyRecord, ...keys: string[]) {
  for (const key of keys) {
    const value = source[key]
    if (typeof value === 'string' && value.trim().length > 0) return value
  }
  return ''
}

function parseKeyRedis(keyRedis: string) {
  const parts = keyRedis.split(':')
  if (parts.length >= 5) {
    return {
      barberoId: parts[2] ?? '',
      fechaCita: parts[3] ?? '',
      horaInicio: parts[4] ?? '',
    }
  }
  return { barberoId: '', fechaCita: '', horaInicio: '' }
}

function normalizeSlot(item: unknown): SlotActivo | null {
  if (!item || typeof item !== 'object') return null
  const raw = item as AnyRecord

  const keyRedis = readString(raw, 'keyRedis', 'key', 'redisKey', 'KeyRedis', 'Key')
  const parsed = parseKeyRedis(keyRedis)

  const bloqueadoEn = readString(raw, 'bloqueadoEn', 'lockedAt', 'BloqueadoEn')
  const expiraEnRaw = readString(raw, 'expiraEn', 'expiresAt', 'ExpiraEn')
  const minutosRestantes = Number(raw.minutosRestantes ?? raw.minutosRestantesBloqueo ?? raw.MinutosRestantes ?? 0)

  const expiraEn =
    expiraEnRaw ||
    (Number.isFinite(minutosRestantes) && minutosRestantes > 0
      ? new Date(Date.now() + minutosRestantes * 60_000).toISOString()
      : '')

  const cliente =
    readString(raw, 'clienteNombre', 'cliente', 'ClienteNombre', 'Cliente') ||
    readString(raw, 'clienteId', 'ClienteId') ||
    'Cliente'

  const tokenBloqueo = readString(raw, 'tokenBloqueo', 'TokenBloqueo', 'token')

  const barberoId = readString(raw, 'barberoId', 'BarberoId') || parsed.barberoId
  const fechaCita = readString(raw, 'fechaCita', 'FechaCita') || parsed.fechaCita
  const horaInicio = readString(raw, 'horaInicio', 'HoraInicio') || parsed.horaInicio

  if (!keyRedis || !barberoId || !fechaCita || !horaInicio || !tokenBloqueo) {
    return null
  }

  return {
    keyRedis,
    cliente,
    clienteId: readString(raw, 'clienteId', 'ClienteId') || undefined,
    barberoId,
    fechaCita,
    horaInicio,
    tokenBloqueo,
    bloqueadoEn,
    expiraEn,
  }
}

export const slotsRedisService = {
  async getActivos(): Promise<SlotActivo[]> {
    try {
      const response = await http.get<unknown[] | ApiLikeResponse<unknown[]>>('/v1/slots/activos')
      const rawList = unwrap(response.data) ?? []
      return rawList.map(normalizeSlot).filter((x): x is SlotActivo => Boolean(x))
    } catch (error) {
      const axiosError = error as AxiosError
      if (axiosError.response?.status === 404) {
        return []
      }
      throw error
    }
  },

  async limpiarExpirados(): Promise<void> {
    await http.delete('/v1/slots/activos/limpiar-expirados')
  },

  async liberar(slot: SlotActivo): Promise<void> {
    await http.delete('/v1/slots/liberar', {
      data: {
        tokenBloqueo: slot.tokenBloqueo,
        barberoId: slot.barberoId,
        fechaCita: slot.fechaCita,
        horaInicio: slot.horaInicio,
      },
    })
  },
}
