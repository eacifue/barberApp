import axios from 'axios'

import { http } from './http'
import type {
  AvailabilityDay,
  BarberAvailability,
  BarberDayOff,
  BarberSlot,
  CreateBarberDayOffRequest,
  UpsertBarberAvailabilityRequest,
} from '../types/availability'

type ApiLikeResponse<T> = {
  data?: T
}

function unwrap<T>(payload: T | ApiLikeResponse<T>): T {
  if (payload && typeof payload === 'object' && 'data' in (payload as Record<string, unknown>)) {
    return (payload as ApiLikeResponse<T>).data as T
  }
  return payload as T
}

function normalizeTime(value: string | undefined): string {
  if (!value) return ''
  return value.slice(0, 5)
}

function toApiTime(value: string | undefined): string | undefined {
  if (!value) return undefined
  return value.length === 5 ? `${value}:00` : value
}

const dayToDotnetEnum: Record<AvailabilityDay, number> = {
  Monday: 1,
  Tuesday: 2,
  Wednesday: 3,
  Thursday: 4,
  Friday: 5,
  Saturday: 6,
  Sunday: 0,
}

const dotnetEnumToDay: Record<number, AvailabilityDay> = {
  0: 'Sunday',
  1: 'Monday',
  2: 'Tuesday',
  3: 'Wednesday',
  4: 'Thursday',
  5: 'Friday',
  6: 'Saturday',
}

function normalizeDay(value: unknown): AvailabilityDay {
  if (typeof value === 'number') {
    return dotnetEnumToDay[value] ?? 'Monday'
  }
  if (typeof value === 'string') {
    if ((['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'] as string[]).includes(value)) {
      return value as AvailabilityDay
    }

    const maybeNumber = Number(value)
    if (!Number.isNaN(maybeNumber)) {
      return dotnetEnumToDay[maybeNumber] ?? 'Monday'
    }
  }

  return 'Monday'
}

type RawBarberAvailability = Omit<BarberAvailability, 'dayOfWeek'> & {
  dayOfWeek: AvailabilityDay | number | string
}

function normalizeAvailability(item: RawBarberAvailability): BarberAvailability {
  return {
    ...item,
    dayOfWeek: normalizeDay(item.dayOfWeek),
    startTime: normalizeTime(item.startTime),
    endTime: normalizeTime(item.endTime),
  }
}

const dayToLegacyEnum: Record<string, number> = {
  Monday: 1,
  Tuesday: 2,
  Wednesday: 3,
  Thursday: 4,
  Friday: 5,
  Saturday: 6,
  Sunday: 7,
}

const legacyToDay: Record<string, string> = {
  Lunes: 'Monday',
  Martes: 'Tuesday',
  Miercoles: 'Wednesday',
  Jueves: 'Thursday',
  Viernes: 'Friday',
  Sabado: 'Saturday',
  Domingo: 'Sunday',
}

type LegacyHorario = {
  id: string
  barberoId: string
  diaSemana: string
  horaInicio: string
  horaFin: string
  intervaloCitasMinutos: number
}

function fromLegacyHorario(item: LegacyHorario): BarberAvailability {
  return {
    id: item.id,
    barberId: item.barberoId,
    dayOfWeek: (legacyToDay[item.diaSemana] ?? 'Monday') as BarberAvailability['dayOfWeek'],
    startTime: normalizeTime(item.horaInicio),
    endTime: normalizeTime(item.horaFin),
    isActive: true,
  }
}

export const availabilityService = {
  async getByBarber(barberId: string): Promise<BarberAvailability[]> {
    try {
      const response = await http.get<RawBarberAvailability[] | ApiLikeResponse<RawBarberAvailability[]>>(
        `/v1/barbers/${barberId}/availability`,
      )
      const payload = unwrap(response.data) ?? []
      return payload.map(normalizeAvailability)
    } catch (error) {
      if (!axios.isAxiosError(error) || error.response?.status !== 404) {
        throw error
      }

      const legacyResponse = await http.get<LegacyHorario[] | ApiLikeResponse<LegacyHorario[]>>(
        `/v1/barberos/${barberId}/horarios`,
      )

      const payload = unwrap(legacyResponse.data) ?? []
      return payload.map(fromLegacyHorario)
    }
  },

  async upsertByBarber(barberId: string, request: UpsertBarberAvailabilityRequest): Promise<BarberAvailability[]> {
    const payload = {
      availability: request.availability.map((item) => ({
        dayOfWeek: dayToDotnetEnum[item.dayOfWeek],
        isActive: item.isActive,
        startTime: toApiTime(item.startTime),
        endTime: toApiTime(item.endTime),
      })),
    }

    try {
      const response = await http.post<RawBarberAvailability[] | ApiLikeResponse<RawBarberAvailability[]>>(
        `/v1/barbers/${barberId}/availability`,
        payload,
      )

      return (unwrap(response.data) ?? []).map(normalizeAvailability)
    } catch (error) {
      if (!axios.isAxiosError(error) || error.response?.status !== 404) {
        throw error
      }

      const horarios = request.availability
        .filter((item) => item.isActive && item.startTime && item.endTime)
        .map((item) => ({
          diaSemana: dayToLegacyEnum[item.dayOfWeek],
          horaInicio: toApiTime(item.startTime),
          horaFin: toApiTime(item.endTime),
          intervaloCitas: 30,
        }))

      const legacyResponse = await http.post<LegacyHorario[] | ApiLikeResponse<LegacyHorario[]>>(
        `/v1/barberos/${barberId}/horarios`,
        { horarios },
      )

      return (unwrap(legacyResponse.data) ?? []).map(fromLegacyHorario)
    }
  },

  async addDayOff(barberId: string, request: CreateBarberDayOffRequest): Promise<BarberDayOff> {
    const response = await http.post<BarberDayOff | ApiLikeResponse<BarberDayOff>>(
      `/v1/barbers/${barberId}/day-off`,
      request,
    )
    return unwrap(response.data)
  },

  async getSlots(barberId: string, date: string): Promise<BarberSlot[]> {
    const response = await http.get<BarberSlot[] | ApiLikeResponse<BarberSlot[]>>(
      `/v1/barbers/${barberId}/slots`,
      { params: { date } },
    )
    return unwrap(response.data) ?? []
  },
}
