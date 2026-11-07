import { useEffect, useMemo, useState } from 'react'
import { useMutation, useQuery, useQueryClient, type UseQueryResult } from '@tanstack/react-query'
import { Link, useSearchParams } from 'react-router-dom'

import { Banner, Button, ConfirmDialog, Countdown, EmptyState, IconButton, Select, Skeleton, SlotGrid, Table, Tabs, formatDuration, formatLongDate, formatShortDate, formatTime, type Slot, type TableColumn } from '../../components/bsm'
import { PageHeader } from '../../components/shared/PageHeader'
import { useBarberias } from '../../hooks/useBarberias'
import { useBarberos } from '../../hooks/useBarberos'
import { useTenantBarberia } from '../../hooks/useTenantBarberia'
import { citaService } from '../../services/citaService'
import { slotsRedisService, type ReservaEnCurso } from '../../services/slotsRedisService'
import { toast } from '../../stores/toastStore'
import type { Cita, SlotDisponible } from '../../types/cita'
import { addDaysIso, esDiaDescanso, hhmm, mensajeDeError, minutesOf, mondayOf, parseIso, todayIso, weekDays } from '../citas/agendaUtils'
import { CreateCitaModal } from '../citas/CreateCitaModal'

type Dia = { fecha: string; slots: SlotDisponible[]; citas: Cita[]; error: boolean }
type Vista = 'horarios' | 'reservas'

const DOW = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']

/** Estado de cada horario para el panel: ocupado por cita, apartado en la app, bloqueado o libre. */
function slotsDelDia(d: Dia | undefined): Slot[] {
  if (!d) return []
  const citas = d.citas.filter((c) => c.estado !== 'Cancelada' && c.estado !== 'NoShow')
  return d.slots.map((s) => {
    const t = hhmm(s.horaInicio)
    const m = minutesOf(t)
    const cita = citas.find((c) => m >= minutesOf(hhmm(c.horaInicio)) && m < minutesOf(hhmm(c.horaFin)))
    if (cita) return { time: t, state: 'booked', note: `${cita.cliente.nombre} ${cita.cliente.apellido.charAt(0)}.`.trim() }
    if (s.bloqueadoPorRedis) return { time: t, state: 'hold', note: s.minutosRestantesBloqueo ? `Reservando · ${s.minutosRestantesBloqueo} min` : 'Reservando' }
    if (!s.disponible) return { time: t, state: 'blocked', note: 'No disponible' }
    return { time: t, state: 'available' }
  })
}

/**
 * Disponibilidad (design/pantallas/panel-web/Disponibilidad): qué horarios ven
 * los clientes en la app y quién está reservando ahora.
 */
export function DisponibilidadPage() {
  const [params, setParams] = useSearchParams()
  const vista: Vista = params.get('vista') === 'reservas' ? 'reservas' : 'horarios'
  const reservasQuery = useQuery({ queryKey: ['slots-activos'], queryFn: slotsRedisService.getActivos, refetchInterval: 10_000 })

  return (
    <div className="mx-auto flex max-w-[1200px] flex-col gap-5 px-4 py-5 md:px-6 lg:px-8">
      <PageHeader title="Disponibilidad" subtitle="Qué horarios ven tus clientes en la app y quién está reservando ahora." />
      <Tabs
        label="Vistas de disponibilidad"
        value={vista}
        onChange={(v) => setParams(v === 'reservas' ? { vista: 'reservas' } : {}, { replace: true })}
        items={[
          { value: 'horarios', label: 'Horarios del día', icon: 'clock' },
          { value: 'reservas', label: 'Reservas en curso', icon: 'timer', count: reservasQuery.data?.length || undefined },
        ]}
      />
      {vista === 'horarios' ? <Horarios onVerReservas={() => setParams({ vista: 'reservas' }, { replace: true })} /> : <Reservas query={reservasQuery} />}
    </div>
  )
}

function Horarios({ onVerReservas }: { onVerReservas: () => void }) {
  const { effectiveBarberiaId } = useTenantBarberia()
  const { barberosQuery } = useBarberos(effectiveBarberiaId ?? '')
  const { barberiasQuery } = useBarberias()
  const barberia = barberiasQuery.data?.find((b) => b.id === effectiveBarberiaId) ?? barberiasQuery.data?.[0]
  const barberos = useMemo(() => (barberosQuery.data ?? []).filter((b) => b.activo), [barberosQuery.data])
  const hoy = todayIso()

  const [barberoSel, setBarberoSel] = useState('')
  const [servicioSel, setServicioSel] = useState('')
  const [semana, setSemana] = useState(() => mondayOf(hoy))
  const [diaSel, setDiaSel] = useState(hoy)
  const [nueva, setNueva] = useState<{ fecha: string; hora: string } | null>(null)

  const barbero = barberos.find((b) => b.id === barberoSel) ?? barberos[0]
  const servicios = barbero?.servicios ?? []
  const servicio = servicios.find((s) => s.id === servicioSel) ?? servicios[0]
  const dias = weekDays(semana)
  const diaEf = dias.includes(diaSel) ? diaSel : (dias.find((d) => d >= hoy) ?? dias[0])

  const semanaQuery = useQuery({
    queryKey: ['disponibilidad-semana', barbero?.id, servicio?.id, semana],
    enabled: Boolean(barbero && servicio),
    refetchInterval: 30_000,
    queryFn: async (): Promise<Dia[]> =>
      Promise.all(
        dias.map(async (fecha) => {
          if (fecha < hoy) return { fecha, slots: [], citas: [], error: false }
          try {
            const [disp, citas] = await Promise.all([citaService.getDisponibilidad(barbero!.id, servicio!.id, fecha), citaService.getByBarbero(barbero!.id, fecha)])
            return { fecha, slots: disp.slots ?? [], citas: citas ?? [], error: false }
          } catch {
            return { fecha, slots: [], citas: [], error: true }
          }
        }),
      ),
  })
  const porFecha = new Map((semanaQuery.data ?? []).map((d) => [d.fecha, d]))
  const slots = slotsDelDia(porFecha.get(diaEf))
  const cuenta = (estado: Slot['state']) => slots.filter((s) => s.state === estado).length
  const apartados = slots.filter((s) => s.state === 'hold')
  const cerrado = (f: string) => esDiaDescanso(barberia?.diasDescanso as Array<string | number> | undefined, f)

  if (barberosQuery.isLoading) return <Skeleton variant="slots" label="Cargando barberos" />
  if (!barberos.length)
    return <EmptyState icon="scissors" title="Aún no tienes barberos activos" body="Agrega un barbero con servicios y horario para ver su disponibilidad." action={<Link to="/barberos" className="bsm-btn bsm-btn-primary">Ir a Barberos</Link>} />

  const finSemana = parseIso(dias[6])
  const rango = `${parseIso(dias[0]).getDate()} – ${formatShortDate(finSemana, finSemana.getFullYear() !== new Date().getFullYear())}`

  return (
    <div className="flex flex-col gap-5">
      <div className="grid gap-4 md:grid-cols-[1fr_1fr_auto] md:items-end">
        <Select label="Barbero" value={barbero?.id ?? ''} options={barberos.map((b) => ({ value: b.id, label: `${b.nombre} ${b.apellido}` }))} onChange={(e) => { setBarberoSel(e.target.value); setServicioSel('') }} />
        <Select
          label="Servicio"
          value={servicio?.id ?? ''}
          placeholder={servicios.length ? undefined : 'Este barbero no tiene servicios'}
          options={servicios.map((s) => ({ value: s.id, label: `${s.nombre} · ${formatDuration(s.duracionMinutos)}` }))}
          hint="La duración del servicio define qué horarios caben."
          onChange={(e) => setServicioSel(e.target.value)}
        />
        <div className="flex items-center gap-1 md:mb-[22px]">
          <IconButton icon="chevron-left" label="Semana anterior" disabled={semana <= mondayOf(hoy)} onClick={() => setSemana(addDaysIso(semana, -7))} />
          <span className="min-w-[140px] text-center text-label-sm text-ink">{rango}</span>
          <IconButton icon="chevron-right" label="Semana siguiente" onClick={() => setSemana(addDaysIso(semana, 7))} />
          {semana !== mondayOf(hoy) && (
            <Button variant="ghost" size="sm" onClick={() => { setSemana(mondayOf(hoy)); setDiaSel(hoy) }}>
              Hoy
            </Button>
          )}
        </div>
      </div>

      {!servicio ? (
        <EmptyState icon="clipboard-list" title={`${barbero?.nombre} no tiene servicios asignados`} body="Asígnale servicios para que aparezca en la app." action={<Link to="/barberos" className="bsm-btn bsm-btn-secondary">Ir a Barberos</Link>} />
      ) : (
        <>
          <div role="group" aria-label="Días de la semana" className="grid grid-cols-7 gap-1 md:gap-2">
            {dias.map((f) => {
              const d = porFecha.get(f)
              const s = slotsDelDia(d)
              const ocupados = s.filter((x) => x.state !== 'available').length
              const pasado = f < hoy
              const sinHorario = cerrado(f) || (d && !d.error && !pasado && s.length === 0)
              const sub = pasado ? 'Pasado' : semanaQuery.isLoading ? '…' : sinHorario ? (cerrado(f) ? 'Cerrado' : 'No atiende') : d?.error ? 'Sin datos' : `${ocupados} de ${s.length}`
              const pct = s.length ? Math.round((ocupados / s.length) * 100) : 0
              const sel = f === diaEf
              return (
                <button
                  key={f}
                  type="button"
                  aria-pressed={sel}
                  disabled={pasado}
                  aria-label={`${formatLongDate(parseIso(f))}, ${sub === `${ocupados} de ${s.length}` ? `${ocupados} de ${s.length} horarios ocupados` : sub.toLowerCase()}`}
                  onClick={() => setDiaSel(f)}
                  className={`flex flex-col items-center gap-1 rounded-md border px-1 py-2 text-center transition-colors disabled:opacity-50 ${sel ? 'border-brass bg-brass-soft' : 'border-line bg-surface hover:border-brass'}`}
                >
                  <span className="text-caption text-ink-muted">{f === hoy ? 'Hoy' : DOW[parseIso(f).getDay()]}</span>
                  <span className="font-display text-title text-ink">{parseIso(f).getDate()}</span>
                  <span className="hidden text-caption text-ink-muted md:block">{sub}</span>
                  <span className="h-1 w-full max-w-[48px] overflow-hidden rounded-full bg-line" aria-hidden="true">
                    <span className="block h-full bg-brass" style={{ width: `${pct}%` }} />
                  </span>
                </button>
              )
            })}
          </div>

          <section className="flex flex-col gap-4 rounded-lg border border-line bg-surface p-5" aria-labelledby="bsm-disp-dia">
            <div className="flex flex-wrap items-baseline justify-between gap-2">
              <h3 id="bsm-disp-dia" className="font-display text-title text-ink first-letter:uppercase">
                {formatLongDate(parseIso(diaEf))} · {barbero.nombre}
              </h3>
              {slots.length > 0 && (
                <p className="text-body-sm text-ink-muted">
                  {cuenta('available')} libres · {cuenta('booked')} ocupados · {cuenta('blocked')} no disponibles{cuenta('hold') ? ` · ${cuenta('hold')} reservando` : ''}
                </p>
              )}
            </div>

            {apartados.length > 0 && (
              <Banner tone="info" icon="timer" title={apartados.length === 1 ? `Un cliente está reservando las ${formatTime(apartados[0].time)}` : `${apartados.length} horarios apartados ahora`} actionLabel="Ver reservas en curso" onAction={onVerReservas}>
                Si no confirma en unos minutos, el horario se libera solo.
              </Banner>
            )}

            {semanaQuery.isLoading ? (
              <Skeleton variant="slots" label="Cargando horarios" />
            ) : porFecha.get(diaEf)?.error ? (
              <EmptyState tone="error" title="No pudimos cargar los horarios de este día" body="Revisa tu conexión e inténtalo de nuevo." actionLabel="Reintentar" actionIcon="refresh-cw" actionVariant="secondary" onAction={() => void semanaQuery.refetch()} />
            ) : slots.length === 0 ? (
              <EmptyState icon="calendar-x" title={cerrado(diaEf) ? 'La barbería cierra este día' : `${barbero.nombre} no atiende este día`} body={cerrado(diaEf) ? 'Los días de descanso se cambian en Mi negocio.' : 'Puede ser su día de descanso o un día libre. Se ajusta en la ficha del barbero.'} />
            ) : (
              <SlotGrid mode="admin" label={`Horarios de ${barbero.nombre}`} slots={slots} onSelect={(s) => s.state === 'available' && setNueva({ fecha: diaEf, hora: s.time })} />
            )}

            <p className="text-caption text-ink-muted">
              Toca un horario libre para agendar una cita. Los días libres y vacaciones se configuran en la ficha del barbero. <Link to="/barberos">Ir a Barberos</Link>
            </p>
          </section>
        </>
      )}

      <CreateCitaModal
        open={nueva != null}
        onClose={() => setNueva(null)}
        onCreated={() => void semanaQuery.refetch()}
        initialBarberoId={barbero?.id}
        initialServicioId={servicio?.id}
        initialFecha={nueva?.fecha}
        initialHora={nueva?.hora}
      />
    </div>
  )
}

function useAhora(ms = 1000) {
  const [ahora, setAhora] = useState(() => Date.now())
  useEffect(() => {
    const id = setInterval(() => setAhora(Date.now()), ms)
    return () => clearInterval(id)
  }, [ms])
  return ahora
}

function Reservas({ query }: { query: UseQueryResult<ReservaEnCurso[]> }) {
  const queryClient = useQueryClient()
  const ahora = useAhora()
  const [liberar, setLiberar] = useState<ReservaEnCurso | null>(null)
  const liberarMutation = useMutation({
    mutationFn: (r: ReservaEnCurso) => slotsRedisService.liberar(r),
    onSuccess: async () => {
      toast.success('Horario liberado. Avisamos al cliente.')
      setLiberar(null)
      await queryClient.invalidateQueries({ queryKey: ['slots-activos'] })
      await queryClient.invalidateQueries({ queryKey: ['disponibilidad-semana'] })
    },
    onError: async (e) => {
      toast.error(mensajeDeError(e, 'No pudimos liberar el horario.'))
      setLiberar(null)
      await queryClient.invalidateQueries({ queryKey: ['slots-activos'] })
    },
  })
  // Se esconden en cuanto vencen, sin esperar al siguiente refresco.
  const filas = (query.data ?? []).filter((r) => new Date(r.expiraEn).getTime() > ahora)
  const restantes = (r: ReservaEnCurso) => Math.max(0, Math.round((new Date(r.expiraEn).getTime() - ahora) / 1000))

  const columnas: TableColumn<ReservaEnCurso>[] = [
    {
      key: 'cliente',
      label: 'Cliente',
      render: (r) => (
        <span className="flex flex-col text-left">
          <strong className="text-label-sm text-ink">{r.clienteNombre}</strong>
          <span className="text-caption text-ink-muted">Desde la app</span>
        </span>
      ),
    },
    { key: 'barbero', label: 'Barbero', muted: true, render: (r) => r.barberoNombre },
    { key: 'horario', label: 'Horario apartado', render: (r) => `${formatShortDate(parseIso(r.fechaCita.slice(0, 10)))} · ${formatTime(hhmm(r.horaInicio))}` },
    { key: 'desde', label: 'Apartado a las', muted: true, render: (r) => formatTime(new Date(r.bloqueadoEn)) },
    { key: 'libera', label: 'Se libera en', render: (r) => <Countdown variant="compact" seconds={restantes(r)} /> },
    {
      key: 'acciones',
      label: 'Acciones',
      align: 'right',
      render: (r) => (
        <Button variant="secondary" size="sm" onClick={() => setLiberar(r)}>
          Liberar ahora
        </Button>
      ),
    },
  ]

  return (
    <div className="flex flex-col gap-4">
      <p className="text-body-sm text-ink-muted">Cuando un cliente elige un horario en la app, se le aparta 5 minutos para que confirme. Si no confirma, el horario se libera solo.</p>
      <Table
        caption="Reservas en curso"
        columns={columnas}
        rows={filas}
        rowKey={(r) => `${r.barberoId}-${r.fechaCita}-${r.horaInicio}`}
        state={
          query.isError ? (
            <EmptyState tone="error" title="No pudimos cargar las reservas en curso" body="Revisa tu conexión e inténtalo de nuevo." actionLabel="Reintentar" actionIcon="refresh-cw" actionVariant="secondary" onAction={() => void query.refetch()} />
          ) : query.isLoading ? (
            <Skeleton variant="row" rows={3} label="Cargando reservas en curso" />
          ) : filas.length === 0 ? (
            <EmptyState icon="timer" title="Nadie está reservando ahora" body="La lista se actualiza cada 10 segundos." />
          ) : undefined
        }
      />
      <p className="text-caption text-ink-muted">«Liberar ahora» devuelve el horario a la app al instante; el cliente recibe el aviso «Tu horario se liberó» y puede elegir otro.</p>
      <ConfirmDialog
        open={liberar != null}
        tone="danger"
        icon="timer"
        title={`¿Liberar el horario de ${liberar?.clienteNombre ?? ''}?`}
        body={liberar ? `Las ${formatTime(hhmm(liberar.horaInicio))} con ${liberar.barberoNombre} vuelven a estar disponibles en la app. ${liberar.clienteNombre} pierde el horario si aún no confirma.` : ''}
        confirmLabel="Liberar horario"
        loading={liberarMutation.isPending}
        onCancel={() => setLiberar(null)}
        onConfirm={() => liberar && liberarMutation.mutate(liberar)}
      />
    </div>
  )
}
