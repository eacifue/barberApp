import { formatShortDate } from '../../components/bsm'
import type { Cita } from '../../types/cita'
import { compareDesc, nombreBarbero, parseIso, todayIso } from '../citas/agendaUtils'

export type Metricas = {
  citas: Cita[]
  total: number
  completadas: number
  canceladas: number
  noAsistio: number
  gasto: number
  ultima: Cita | null
  proxima: Cita | null
  preferido: { nombre: string; veces: number } | null
}

/** Resume las citas de un cliente (ventana de la consulta: último año y próximos 90 días). */
export function metricasDe(citas: Cita[], hoy: string, ahora: string): Metricas {
  const orden = citas.slice().sort(compareDesc)
  const completadas = orden.filter((c) => c.estado === 'Completada')
  const porBarbero = new Map<string, { nombre: string; veces: number }>()
  for (const c of orden) {
    if (c.estado === 'Cancelada') continue
    const e = porBarbero.get(c.barbero.id) ?? { nombre: nombreBarbero(c), veces: 0 }
    e.veces++
    porBarbero.set(c.barbero.id, e)
  }
  const proximas = orden
    .filter((c) => (c.estado === 'Pendiente' || c.estado === 'Confirmada') && (c.fechaCita.slice(0, 10) > hoy || (c.fechaCita.slice(0, 10) === hoy && c.horaInicio.slice(0, 5) >= ahora)))
    .reverse()
  return {
    citas: orden,
    total: orden.length,
    completadas: completadas.length,
    canceladas: orden.filter((c) => c.estado === 'Cancelada').length,
    noAsistio: orden.filter((c) => c.estado === 'NoShow').length,
    gasto: completadas.reduce((s, c) => s + (c.precioFinal || 0), 0),
    ultima: completadas[0] ?? null,
    proxima: proximas[0] ?? null,
    preferido: [...porBarbero.values()].sort((a, b) => b.veces - a.veces)[0] ?? null,
  }
}

export function fechaCorta(iso: string, hoy = todayIso()): string {
  const d = iso.slice(0, 10)
  if (d === hoy) return 'Hoy'
  return formatShortDate(parseIso(d), d.slice(0, 4) !== hoy.slice(0, 4))
}
