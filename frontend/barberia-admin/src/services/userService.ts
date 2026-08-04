import { http } from './http'

export type UserDto = {
  id: string
  nombre: string
  apellido: string
  correo: string
  telefono: string
  rol: string
  barberoId: string | null
  activo: boolean
  createdAt: string
}

export type CreateUserPayload = {
  nombre: string
  apellido: string
  correo: string
  telefono: string
  password: string
  rol: string
  barberoId?: string | null
}

export type UpdateUserPayload = {
  nombre?: string
  apellido?: string
  telefono?: string
  rol?: string
  barberoId: string | null
  activo?: boolean
}

type ApiResp<T> = { success: boolean; message: string; data: T | null }

export const userService = {
  getAll: () => http.get<ApiResp<UserDto[]>>('/v1/users').then((r) => r.data.data ?? []),

  getById: (id: string) => http.get<ApiResp<UserDto>>(`/v1/users/${id}`).then((r) => r.data.data!),

  create: (payload: CreateUserPayload) =>
    http.post<ApiResp<UserDto>>('/v1/users', payload).then((r) => r.data.data!),

  update: (id: string, payload: UpdateUserPayload) =>
    http.put<ApiResp<UserDto>>(`/v1/users/${id}`, payload).then((r) => r.data.data!),

  remove: (id: string) =>
    http.delete<ApiResp<null>>(`/v1/users/${id}`).then((r) => r.data),
}
