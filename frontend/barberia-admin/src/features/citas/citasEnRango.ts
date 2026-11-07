import { citaService } from '../../services/citaService'
import type { Cita } from '../../types/cita'

/** Todas las citas entre dos fechas ISO (inclusive), paginando de 200 en 200. */
export async function citasEnRango(from: string, to: string): Promise<Cita[]> {
  const pageSize = 200
  const all: Cita[] = []
  for (let page = 1; page <= 20; page++) {
    const chunk = await citaService.getAdminList({ from, to, page, pageSize })
    all.push(...chunk)
    if (chunk.length < pageSize) break
  }
  return Array.from(new Map(all.map((c) => [c.id, c])).values())
}
