/** Días en orden de semana colombiana (lunes primero), con su número de `Date.getDay()`. */
export const DIAS_SEMANA = [
  { getDay: 1, label: 'Lunes' },
  { getDay: 2, label: 'Martes' },
  { getDay: 3, label: 'Miércoles' },
  { getDay: 4, label: 'Jueves' },
  { getDay: 5, label: 'Viernes' },
  { getDay: 6, label: 'Sábado' },
  { getDay: 0, label: 'Domingo' },
]

export const PAISES = ['Colombia', 'México', 'Argentina', 'Chile', 'Perú', 'Ecuador', 'Venezuela']

export const DEPARTAMENTOS = [
  'Amazonas', 'Antioquia', 'Arauca', 'Atlántico', 'Bogotá D. C.', 'Bolívar', 'Boyacá', 'Caldas', 'Caquetá', 'Casanare', 'Cauca', 'Cesar', 'Chocó', 'Córdoba',
  'Cundinamarca', 'Guainía', 'Guaviare', 'Huila', 'La Guajira', 'Magdalena', 'Meta', 'Nariño', 'Norte de Santander', 'Putumayo', 'Quindío', 'Risaralda',
  'San Andrés y Providencia', 'Santander', 'Sucre', 'Tolima', 'Valle del Cauca', 'Vaupés', 'Vichada',
]

/** «Lunes a sábado, 9:00 a. m. – 8:00 p. m. · Domingo cerrado» */
export function resumenHorario(descanso: number[], abre: string, cierra: string): string {
  const abiertos = DIAS_SEMANA.map((d) => ({ ...d, abierto: !descanso.includes(d.getDay) }))
  const tramos: string[] = []
  let i = 0
  while (i < abiertos.length) {
    if (!abiertos[i].abierto) {
      i++
      continue
    }
    let j = i
    while (j + 1 < abiertos.length && abiertos[j + 1].abierto) j++
    const a = abiertos[i].label
    const b = abiertos[j].label.toLowerCase()
    tramos.push(i === j ? a : j === i + 1 ? `${a} y ${b}` : `${a} a ${b}`)
    i = j + 1
  }
  if (!tramos.length) return 'Cerrado todos los días'
  const cerrados = abiertos.filter((d) => !d.abierto).map((d) => d.label)
  const dias = tramos.length === 1 && cerrados.length === 0 ? 'Todos los días' : tramos.join(', ')
  const pie = cerrados.length ? ` · ${cerrados.join(' y ')} cerrado` : ''
  return `${dias}, ${abre} – ${cierra}${pie}`
}
