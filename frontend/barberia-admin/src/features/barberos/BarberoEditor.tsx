import { useMemo, useState, type KeyboardEvent } from 'react'
import { useQueryClient } from '@tanstack/react-query'

import {
  Avatar,
  Banner,
  Button,
  Chip,
  EmptyState,
  IconButton,
  Input,
  Modal,
  Select,
  Skeleton,
  Switch,
  formatCOP,
  formatDuration,
  formatShortDate,
  formatTime,
} from '../../components/bsm'
import { useAvailability } from '../../hooks/useAvailability'
import { useBarberos } from '../../hooks/useBarberos'
import { availabilityService } from '../../services/availabilityService'
import { toast } from '../../stores/toastStore'
import type { AvailabilityDay, BarberAvailability, BarberAvailabilityInput } from '../../types/availability'
import type { Barbero, BarberoUpsertInput } from '../../types/barbero'
import type { Servicio } from '../../types/servicio'
import { hhmm, mensajeDeError, minutesOf, parseIso, todayIso } from '../citas/agendaUtils'

const DIAS: Array<{ key: AvailabilityDay; label: string }> = [
  { key: 'Monday', label: 'Lunes' },
  { key: 'Tuesday', label: 'Martes' },
  { key: 'Wednesday', label: 'Miércoles' },
  { key: 'Thursday', label: 'Jueves' },
  { key: 'Friday', label: 'Viernes' },
  { key: 'Saturday', label: 'Sábado' },
  { key: 'Sunday', label: 'Domingo' },
]
const GET_DAY: Record<AvailabilityDay, number> = { Sunday: 0, Monday: 1, Tuesday: 2, Wednesday: 3, Thursday: 4, Friday: 5, Saturday: 6 }

type Form = {
  nombre: string
  apellido: string
  telefono: string
  correo: string
  fotoUrl: string
  biografia: string
  anios: string
  especialidades: string[]
  servicioIds: string[]
}
type Errores = Partial<Record<keyof Form, string>>

function formDe(b: Barbero | null): Form {
  return {
    nombre: b?.nombre ?? '',
    apellido: b?.apellido ?? '',
    telefono: b?.telefono ?? '',
    correo: b?.correo ?? '',
    fotoUrl: b?.fotoUrl ?? '',
    biografia: b?.biografia ?? '',
    anios: b ? String(b.añosExperiencia) : '',
    especialidades: b?.especialidades ?? [],
    servicioIds: (b?.servicios ?? []).map((s) => s.id),
  }
}

function validar(f: Form, horario: BarberAvailabilityInput[]): Errores & { horario?: string } {
  const e: Errores & { horario?: string } = {}
  if (!f.nombre.trim()) e.nombre = 'Escribe el nombre.'
  if (!f.apellido.trim()) e.apellido = 'Escribe el apellido.'
  if (f.telefono.replace(/\D/g, '').length < 7) e.telefono = 'Ingresa un teléfono de al menos 7 dígitos.'
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(f.correo.trim())) e.correo = 'Ingresa un correo válido, como nombre@correo.com.'
  const a = Number(f.anios || 0)
  if (!Number.isInteger(a) || a < 0 || a > 60) e.anios = 'Ingresa los años como un número entre 0 y 60.'
  if (f.fotoUrl.trim() && !/^https?:\/\//i.test(f.fotoUrl.trim())) e.fotoUrl = 'Usa un enlace que empiece por https://'
  if (f.servicioIds.length === 0) e.servicioIds = 'Elige al menos un servicio.'
  const malo = horario.find((h) => h.isActive && (!h.startTime || !h.endTime || minutesOf(h.startTime) >= minutesOf(h.endTime)))
  if (malo) e.horario = `Revisa el ${DIAS.find((d) => d.key === malo.dayOfWeek)?.label.toLowerCase()}: la salida debe ser después de la entrada.`
  return e
}

type Props = {
  /** `null` = barbero nuevo. */
  barbero: Barbero | null
  barberiaId: string
  servicios: Servicio[]
  apertura: string
  cierre: string
  diasDescanso: number[]
  onClose: () => void
  onDesactivar?: (b: Barbero) => void
}

/** Modal de barbero: espera el horario guardado antes de montar el formulario. */
export function BarberoEditor(props: Props) {
  const { barbero, onClose } = props
  const { availabilityQuery } = useAvailability(barbero?.id ?? '')
  const title = barbero ? 'Editar barbero' : 'Nuevo barbero'
  if (barbero && availabilityQuery.isLoading) {
    return (
      <Modal open onClose={onClose} size="lg" title={title} subtitle={`${barbero.nombre} ${barbero.apellido}`}>
        <Skeleton variant="row" rows={6} label="Cargando barbero" />
      </Modal>
    )
  }
  return <Formulario key={barbero?.id ?? 'nuevo'} {...props} guardado={availabilityQuery.data ?? []} />
}

function Formulario({ barbero, barberiaId, servicios, apertura, cierre, diasDescanso, onClose, onDesactivar, guardado }: Props & { guardado: BarberAvailability[] }) {
  const queryClient = useQueryClient()
  const { createMutation, updateMutation } = useBarberos(barberiaId)

  const [form, setForm] = useState<Form>(() => formDe(barbero))
  const [especialidad, setEspecialidad] = useState('')
  const [horario, setHorario] = useState<BarberAvailabilityInput[]>(() =>
    DIAS.map(({ key }) => {
      const g = guardado.find((x) => x.dayOfWeek === key && x.isActive)
      if (g) return { dayOfWeek: key, isActive: true, startTime: hhmm(g.startTime), endTime: hhmm(g.endTime) }
      // Barbero nuevo: por defecto el horario de la barbería en sus días abiertos.
      const abre = !barbero && !diasDescanso.includes(GET_DAY[key])
      return { dayOfWeek: key, isActive: abre, startTime: apertura, endTime: cierre }
    }),
  )
  const [errores, setErrores] = useState<Errores & { horario?: string }>({})
  const [dirty, setDirty] = useState(false)
  const [horarioDirty, setHorarioDirty] = useState(!barbero)
  const [guardandoHorario, setGuardandoHorario] = useState(false)

  const horas = useMemo(() => {
    const out: Array<{ value: string; label: string }> = []
    for (let m = minutesOf(apertura); m <= minutesOf(cierre); m += 30) {
      const v = `${String(Math.floor(m / 60)).padStart(2, '0')}:${String(m % 60).padStart(2, '0')}`
      out.push({ value: v, label: formatTime(v) })
    }
    return out
  }, [apertura, cierre])

  const set = <K extends keyof Form>(k: K, v: Form[K]) => {
    setForm((f) => ({ ...f, [k]: v }))
    setDirty(true)
    if (errores[k]) setErrores((e) => ({ ...e, [k]: undefined }))
  }
  const setDia = (key: AvailabilityDay, patch: Partial<BarberAvailabilityInput>) => {
    setHorario((h) => h.map((d) => (d.dayOfWeek === key ? { ...d, ...patch } : d)))
    setDirty(true)
    setHorarioDirty(true)
    if (errores.horario) setErrores((e) => ({ ...e, horario: undefined }))
  }
  const agregarEspecialidad = () => {
    const t = especialidad.trim()
    if (!t) return
    if (!form.especialidades.some((x) => x.toLowerCase() === t.toLowerCase())) set('especialidades', [...form.especialidades, t])
    setEspecialidad('')
  }
  const onEspecialidadKey = (e: KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' || e.key === ',') {
      e.preventDefault()
      agregarEspecialidad()
    }
  }
  const toggleServicio = (id: string, on: boolean) => set('servicioIds', on ? [...form.servicioIds, id] : form.servicioIds.filter((x) => x !== id))

  const guardando = createMutation.isPending || updateMutation.isPending || guardandoHorario

  const guardar = async () => {
    const e = validar(form, horario)
    setErrores(e)
    if (Object.keys(e).some((k) => e[k as keyof typeof e])) return
    const payload: BarberoUpsertInput = {
      nombre: form.nombre,
      apellido: form.apellido,
      telefono: form.telefono,
      correo: form.correo,
      fotoUrl: form.fotoUrl,
      biografia: form.biografia,
      añosExperiencia: Number(form.anios || 0),
      especialidades: form.especialidades,
      disponible: barbero?.disponible ?? true,
      activo: barbero?.activo ?? true,
      servicioIds: form.servicioIds,
    }
    let guardadoId = barbero?.id
    try {
      if (barbero) await updateMutation.mutateAsync({ id: barbero.id, data: payload })
      else guardadoId = (await createMutation.mutateAsync(payload)).id
    } catch (err) {
      toast.error(mensajeDeError(err, 'No pudimos guardar el barbero. Inténtalo de nuevo.'))
      return
    }
    if (horarioDirty && guardadoId) {
      setGuardandoHorario(true)
      try {
        // Un barbero recién creado aún no tiene hook propio: se llama directo al servicio.
        await availabilityService.upsertByBarber(guardadoId, { availability: horario })
        await queryClient.invalidateQueries({ queryKey: ['availability', guardadoId] })
      } catch (err) {
        toast.error(mensajeDeError(err, 'Guardamos el barbero, pero no su horario. Ábrelo y guarda el horario otra vez.'))
        onClose()
        return
      } finally {
        setGuardandoHorario(false)
      }
    }
    toast.success(barbero ? 'Cambios guardados' : `${form.nombre.trim()} ya está en el equipo`)
    onClose()
  }

  const nombre = `${form.nombre} ${form.apellido}`.trim()
  const activos = servicios.filter((s) => s.activo)

  return (
    <Modal
      open
      onClose={onClose}
      size="lg"
      dirty={dirty && !guardando}
      title={barbero ? 'Editar barbero' : 'Nuevo barbero'}
      subtitle={barbero ? nombre : 'Aparece en la app cuando tenga al menos un servicio y horario.'}
      footer={
        <>
          {barbero?.activo && onDesactivar && (
            <Button variant="ghost" icon="ban" className="mr-auto !text-danger" onClick={() => onDesactivar(barbero)} disabled={guardando}>
              Desactivar barbero
            </Button>
          )}
          <Button variant="secondary" onClick={onClose} disabled={guardando}>
            Cancelar
          </Button>
          <Button onClick={() => void guardar()} loading={guardando}>
            {guardando ? 'Guardando…' : barbero ? 'Guardar cambios' : 'Crear barbero'}
          </Button>
        </>
      }
    >
      {barbero && !barbero.activo && (
        <Banner tone="warning" title="Este barbero está desactivado">
          Los clientes no lo ven en la app. Actívalo desde la tabla del equipo.
        </Banner>
      )}

      <section className="flex flex-col gap-4" aria-labelledby="bsm-b-perfil">
        <h3 id="bsm-b-perfil" className="bsm-overline">Perfil</h3>
        <div className="flex items-center gap-4">
          <Avatar name={nombre || undefined} src={/^https?:\/\//i.test(form.fotoUrl.trim()) ? form.fotoUrl.trim() : null} size={72} />
          <div className="min-w-0 flex-1">
            <Input label="Foto" optional icon="image-plus" placeholder="https://…" value={form.fotoUrl} hint="Enlace a una foto cuadrada, JPG o PNG." error={errores.fotoUrl} onChange={(e) => set('fotoUrl', e.target.value)} />
          </div>
        </div>
        <div className="grid gap-4 md:grid-cols-2">
          <Input label="Nombre" autoComplete="off" value={form.nombre} error={errores.nombre} onChange={(e) => set('nombre', e.target.value)} />
          <Input label="Apellido" autoComplete="off" value={form.apellido} error={errores.apellido} onChange={(e) => set('apellido', e.target.value)} />
          <Input label="Teléfono" type="tel" inputMode="tel" value={form.telefono} error={errores.telefono} onChange={(e) => set('telefono', e.target.value)} />
          <Input label="Correo" type="email" autoComplete="off" value={form.correo} error={errores.correo} onChange={(e) => set('correo', e.target.value)} />
          <Input label="Años de experiencia" type="number" inputMode="numeric" min={0} max={60} value={form.anios} error={errores.anios} onChange={(e) => set('anios', e.target.value)} />
        </div>
        <Input label="Biografía" multiline optional value={form.biografia} hint="Dos o tres frases. Se ve en el perfil del barbero." onChange={(e) => set('biografia', e.target.value)} />
      </section>

      <section className="flex flex-col gap-3" aria-labelledby="bsm-b-esp">
        <h3 id="bsm-b-esp" className="bsm-overline">Especialidades</h3>
        {form.especialidades.length > 0 && (
          <div className="bsm-chip-row">
            {form.especialidades.map((t) => (
              <Chip key={t} as="tag" onRemove={() => set('especialidades', form.especialidades.filter((x) => x !== t))}>
                {t}
              </Chip>
            ))}
          </div>
        )}
        <div className="flex items-end gap-2">
          <div className="min-w-0 flex-1">
            <Input label="Agregar especialidad" optional placeholder="Fade, barba clásica…" value={especialidad} hint="En la app se muestran las tres primeras. Enter para agregar." onChange={(e) => setEspecialidad(e.target.value)} onKeyDown={onEspecialidadKey} />
          </div>
          <Button variant="secondary" icon="plus" onClick={agregarEspecialidad} disabled={!especialidad.trim()} className="mb-[22px]">
            Agregar
          </Button>
        </div>
      </section>

      <section className="flex flex-col gap-3" aria-labelledby="bsm-b-serv">
        <div>
          <h3 id="bsm-b-serv" className="bsm-overline">Servicios que presta</h3>
          <p className={errores.servicioIds ? 'mt-1 text-caption text-danger' : 'mt-1 text-caption text-ink-muted'} role={errores.servicioIds ? 'alert' : undefined}>
            {errores.servicioIds ?? (barbero && form.servicioIds.length === 0 ? 'Confirma los servicios que presta. Al menos uno.' : 'Al menos uno. Se cobra el precio general.')}
          </p>
        </div>
        {activos.length === 0 ? (
          <EmptyState icon="scissors" title="No hay servicios activos" body="Crea o activa servicios en el catálogo para asignarlos." />
        ) : (
          <div className="grid gap-x-6 gap-y-3 md:grid-cols-2">
            {activos.map((s) => (
              <Switch key={s.id} label={s.nombre} hint={`${formatDuration(s.duracionMinutos)} · ${formatCOP(s.precio)}`} checked={form.servicioIds.includes(s.id)} onChange={(on) => toggleServicio(s.id, on)} />
            ))}
          </div>
        )}
      </section>

      <section className="flex flex-col gap-3" aria-labelledby="bsm-b-hor">
        <div>
          <h3 id="bsm-b-hor" className="bsm-overline">Horario semanal</h3>
          <p className={errores.horario ? 'mt-1 text-caption text-danger' : 'mt-1 text-caption text-ink-muted'} role={errores.horario ? 'alert' : undefined}>
            {errores.horario ?? `Dentro del horario de la barbería (${formatTime(apertura)} – ${formatTime(cierre)}).`}
          </p>
        </div>
        <div className="flex flex-col divide-y divide-line rounded-md border border-line">
          {horario.map((d) => {
            const dia = DIAS.find((x) => x.key === d.dayOfWeek)!
            const cerrado = diasDescanso.includes(GET_DAY[d.dayOfWeek])
            return (
              <div key={d.dayOfWeek} className="flex flex-wrap items-center gap-x-4 gap-y-2 px-4 py-3">
                <div className="w-[150px]">
                  <Switch label={dia.label} hint={cerrado ? 'La barbería cierra' : undefined} checked={d.isActive} onChange={(on) => setDia(d.dayOfWeek, { isActive: on })} />
                </div>
                {d.isActive ? (
                  <div className="flex flex-1 items-center gap-2">
                    <div className="min-w-[130px] flex-1">
                      <Select aria-label={`Entrada ${dia.label}`} value={d.startTime} options={horas} onChange={(e) => setDia(d.dayOfWeek, { startTime: e.target.value })} />
                    </div>
                    <span className="text-ink-muted" aria-hidden="true">–</span>
                    <div className="min-w-[130px] flex-1">
                      <Select aria-label={`Salida ${dia.label}`} value={d.endTime} options={horas} onChange={(e) => setDia(d.dayOfWeek, { endTime: e.target.value })} />
                    </div>
                  </div>
                ) : (
                  <span className="text-body-sm text-ink-muted">Descansa</span>
                )}
              </div>
            )
          })}
        </div>
      </section>

      {barbero ? (
        <DiasLibres barberId={barbero.id} />
      ) : (
        <p className="text-body-sm text-ink-muted">Los días libres se agregan después de crear el barbero.</p>
      )}
    </Modal>
  )
}

function DiasLibres({ barberId }: { barberId: string }) {
  const { daysOffQuery, addDayOffMutation, removeDayOffMutation } = useAvailability(barberId)
  const [abierto, setAbierto] = useState(false)
  const [fecha, setFecha] = useState('')
  const [motivo, setMotivo] = useState('')
  const [error, setError] = useState<string | null>(null)
  const hoy = todayIso()
  const dias = daysOffQuery.data ?? []

  const agregar = async () => {
    if (!fecha) return setError('Elige la fecha.')
    if (fecha < hoy) return setError('Elige hoy o una fecha futura.')
    if (dias.some((d) => d.date === fecha)) return setError('Ese día ya está marcado como libre.')
    try {
      await addDayOffMutation.mutateAsync({ date: fecha, reason: motivo.trim() || undefined })
      toast.success('Día libre agregado')
      setFecha('')
      setMotivo('')
      setError(null)
      setAbierto(false)
    } catch (err) {
      setError(mensajeDeError(err, 'No pudimos agregar el día libre.'))
    }
  }
  const quitar = async (id: string) => {
    try {
      await removeDayOffMutation.mutateAsync(id)
      toast.success('Día libre quitado')
    } catch (err) {
      toast.error(mensajeDeError(err, 'No pudimos quitar el día libre.'))
    }
  }

  return (
    <section className="flex flex-col gap-3" aria-labelledby="bsm-b-libres">
      <div>
        <h3 id="bsm-b-libres" className="bsm-overline">Días libres</h3>
        <p className="mt-1 text-caption text-ink-muted">Se aplican al instante: ese día no se ofrecen horas para reservar.</p>
      </div>
      {daysOffQuery.isLoading ? (
        <Skeleton variant="text" rows={2} label="Cargando días libres" />
      ) : daysOffQuery.isError ? (
        <Banner tone="danger" title="No pudimos cargar los días libres" actionLabel="Reintentar" onAction={() => void daysOffQuery.refetch()} />
      ) : dias.length === 0 ? (
        <p className="text-body-sm text-ink-muted">No tiene días libres próximos.</p>
      ) : (
        <ul className="flex flex-col divide-y divide-line rounded-md border border-line">
          {dias.map((d) => {
            const fechaTxt = formatShortDate(parseIso(d.date), d.date.slice(0, 4) !== hoy.slice(0, 4))
            const dow = ['dom', 'lun', 'mar', 'mié', 'jue', 'vie', 'sáb'][parseIso(d.date).getDay()]
            return (
              <li key={d.id} className="flex items-center gap-3 py-2 pl-4 pr-2">
                <span className="flex-1 text-body-sm text-ink">
                  <span className="capitalize">{dow}</span> {fechaTxt}
                  {d.reason && <span className="text-ink-muted"> · {d.reason}</span>}
                </span>
                <IconButton icon="x" size="sm" label={`Quitar día libre del ${dow} ${fechaTxt}`} disabled={removeDayOffMutation.isPending} onClick={() => void quitar(d.id)} />
              </li>
            )
          })}
        </ul>
      )}
      {abierto ? (
        <div className="flex flex-col gap-3 rounded-md border border-line p-4">
          <div className="grid gap-4 md:grid-cols-2">
            <Input label="Fecha" type="date" min={hoy} value={fecha} error={error ?? undefined} onChange={(e) => { setFecha(e.target.value); setError(null) }} />
            <Input label="Motivo" optional placeholder="Vacaciones, diligencia…" value={motivo} onChange={(e) => setMotivo(e.target.value)} />
          </div>
          <div className="flex justify-end gap-2">
            <Button variant="secondary" size="sm" onClick={() => { setAbierto(false); setError(null) }}>
              Cancelar
            </Button>
            <Button size="sm" onClick={() => void agregar()} loading={addDayOffMutation.isPending}>
              Agregar día libre
            </Button>
          </div>
        </div>
      ) : (
        <div>
          <Button variant="secondary" size="sm" icon="calendar-plus" onClick={() => setAbierto(true)}>
            Agregar día libre
          </Button>
        </div>
      )}
    </section>
  )
}
