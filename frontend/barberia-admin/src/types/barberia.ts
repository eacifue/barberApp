export interface Barberia {
  id: string
  nombre: string
  descripcion?: string
  slogan?: string
  sitioWeb?: string
  /** URL de la foto horizontal del local (tarjeta de Inicio en la app). */
  fotoPortada?: string
  telefono: string
  correo: string
  direccion: string
  ciudad: string
  departamento: string
  pais: string
  latitud: number
  longitud: number
  horaApertura: string
  horaCierre: string
  /** Días de `Date.getDay()` (0 = domingo); barberiaService convierte desde `DiaSemana`. */
  diasDescanso: number[]
  activa: boolean
  totalBarberos?: number
}

export type BarberiaUpsertInput = Omit<Barberia, 'id' | 'totalBarberos'>

/** Una fila del resumen del SuperAdmin: el mes en curso de cada barbería (hora de Colombia). */
export interface ResumenBarberia {
  barberiaId: string
  nombre: string
  activa: boolean
  /** Sin canceladas ni «no asistió». */
  citasMes: number
  /** Cobrado: citas completadas. */
  ingresosMes: number
  clientes: number
  barberosActivos: number
}

export interface NuevoAdministrador {
  nombre: string
  apellido: string
  telefono: string
  correo: string
  password: string
}

export type CrearBarberiaInput = BarberiaUpsertInput & { administrador: NuevoAdministrador }
