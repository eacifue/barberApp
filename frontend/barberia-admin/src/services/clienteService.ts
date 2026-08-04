import { http } from './http'
import type { Cliente, ClienteUpsertInput } from '../types/cliente'

type ApiLikeResponse<T> = {
  data?: T
}

function unwrap<T>(payload: T | ApiLikeResponse<T>): T {
  if (payload && typeof payload === 'object' && 'data' in (payload as Record<string, unknown>)) {
    return (payload as ApiLikeResponse<T>).data as T
  }
  return payload as T
}

function toCreatePayload(data: ClienteUpsertInput) {
  return {
    nombre: data.nombre.trim(),
    apellido: data.apellido.trim(),
    telefono: data.telefono.trim(),
    correo: data.correo.trim(),
    password: data.password?.trim() ?? '',
  }
}

function toUpdatePayload(data: ClienteUpsertInput) {
  return {
    nombre: data.nombre.trim(),
    apellido: data.apellido.trim(),
    telefono: data.telefono.trim(),
    correo: data.correo.trim(),
    password: data.password?.trim() || null,
    activo: data.activo,
  }
}

export const clienteService = {
  async getAll(): Promise<Cliente[]> {
    const response = await http.get<Cliente[] | ApiLikeResponse<Cliente[]>>('/v1/admin/clientes')
    return unwrap(response.data) ?? []
  },

  async getAllTenant(): Promise<Cliente[]> {
    const response = await http.get<Cliente[] | ApiLikeResponse<Cliente[]>>('/v1/clientes')
    return unwrap(response.data) ?? []
  },

  async getById(id: string): Promise<Cliente> {
    const response = await http.get<Cliente | ApiLikeResponse<Cliente>>(`/v1/admin/clientes/${id}`)
    return unwrap(response.data)
  },

  async create(data: ClienteUpsertInput): Promise<Cliente> {
    const response = await http.post<Cliente | ApiLikeResponse<Cliente>>('/v1/admin/clientes', toCreatePayload(data))
    return unwrap(response.data)
  },

  async update(id: string, data: ClienteUpsertInput): Promise<Cliente> {
    const response = await http.put<Cliente | ApiLikeResponse<Cliente>>(`/v1/admin/clientes/${id}`, toUpdatePayload(data))
    return unwrap(response.data)
  },

  async remove(id: string): Promise<void> {
    await http.delete(`/v1/admin/clientes/${id}`)
  },
}
