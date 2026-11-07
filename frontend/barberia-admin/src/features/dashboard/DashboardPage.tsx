import { useMemo, useState, type ReactNode } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Link, useNavigate } from 'react-router-dom'

import { Avatar, Button, Calendar, EmptyState, Icon, Skeleton, StatCard, StatusBadge, formatCOP, formatLongDate, formatTime, useDelayedFlag } from '../../components/bsm'
import { useBarberias } from '../../hooks/useBarberias'
import { useBarberos } from '../../hooks/useBarberos'
import { citasEnRango } from '../citas/citasEnRango'
import { useTenantBarberia } from '../../hooks/useTenantBarberia'
import { citaService } from '../../services/citaService'
import { clienteService } from '../../services/clienteService'
import { useAuthStore } from '../../stores/authStore'
import { toast } from '../../stores/toastStore'
import type { Cita } from '../../types/cita'
import { addDaysIso, cuentaParaIngresos, esDiaDescanso, hhmm, mensajeDeError, minutesOf, mondayOf, nombreBarbero, nombreCliente, nowHHMM, parseIso, todayIso } from '../citas/agendaUtils'
import { invalidarCitas } from '../citas/invalidarCitas'
import { BarList, ColumnChart, LineChart, type ColumnDatum } from './charts'

const SEMANAS = 8
const WEEKDAY_SHORT = ['dom', 'lun', 'mar', 'mié', 'jue', 'vie', 'sáb']


/** `$1,71 M` · `$840 mil` · `$0` para ejes y etiquetas directas. */
function millones(n: number): string {
  if (n === 0) return '$0'
  if (n >= 1_000_000) return `$${(n / 1_000_000).toFixed(2).replace(/\.?0+$/, '').replace('.', ',')} M`
  return `$${Math.round(n / 1000)} mil`
}

function Panel({ title, subtitle, action, children, className }: { title: string; subtitle?: string; action?: ReactNode; children: ReactNode; className?: string }) {
  return (
    <section className={`bsm-card flex-col gap-4 ${className ?? ''}`} aria-label={title}>
      <div className="flex items-start justify-between gap-3">
        <div>
          <h3 className="text-title text-ink">{title}</h3>
          {subtitle && <p className="text-body text-ink-muted">{subtitle}</p>}
        </div>
        {action}
      </div>
      {children}
    </section>
  )
}

/** Hoy en la barbería: KPI, gráficas y próximas citas (design/pantallas/panel-web/Dashboard). */
export function DashboardPage() {
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const rol = useAuthStore((s) => s.usuario?.rol ?? '')
  const esBarbero = rol === 'Barbero'
  const hoy = todayIso()
  const desde = addDaysIso(mondayOf(hoy), -7 * (SEMANAS - 1))
  const hoyDate = parseIso(hoy)
  const finMes = `${hoy.slice(0, 7)}-${String(new Date(hoyDate.getFullYear(), hoyDate.getMonth() + 1, 0).getDate()).padStart(2, '0')}`
  const [mes] = useState({ year: hoyDate.getFullYear(), month: hoyDate.getMonth() })

  const { effectiveBarberiaId } = useTenantBarberia()
  const { barberiasQuery } = useBarberias()
  const barberia = barberiasQuery.data?.[0]
  const { barberosQuery } = useBarberos(esBarbero ? '' : (effectiveBarberiaId ?? ''))
  const citasQuery = useQuery({
    queryKey: ['dashboard', 'citas', desde, finMes],
    queryFn: () => citasEnRango(desde, finMes > hoy ? finMes : hoy),
    refetchInterval: 120_000,
  })
  const clientesQuery = useQuery({
    queryKey: ['dashboard', 'clientes', rol],
    enabled: !esBarbero,
    queryFn: () => (rol === 'Admin' ? clienteService.getAll() : clienteService.getAllTenant()),
  })

  const confirmMutation = useMutation({
    mutationFn: (id: string) => citaService.confirm(id),
    onSuccess: async () => {
      toast.success('Cita confirmada')
      await invalidarCitas(queryClient)
    },
    onError: (e) => toast.error(mensajeDeError(e, 'No pudimos confirmar la cita. Inténtalo de nuevo.')),
  })

  const citas = useMemo(() => citasQuery.data ?? [], [citasQuery.data])
  const barberos = useMemo(() => (barberosQuery.data ?? []).filter((b) => b.activo), [barberosQuery.data])
  const apertura = barberia?.horaApertura ? hhmm(barberia.horaApertura) : '09:00'
  const cierre = barberia?.horaCierre ? hhmm(barberia.horaCierre) : '20:00'
  const minutosAbierto = Math.max(60, minutesOf(cierre) - minutesOf(apertura))
  const descansa = (iso: string) => esDiaDescanso(barberia?.diasDescanso as Array<string | number> | undefined, iso)

  const porDia = useMemo(() => {
    const m = new Map<string, Cita[]>()
    for (const c of citas) m.set(c.fechaCita, [...(m.get(c.fechaCita) ?? []), c])
    return m
  }, [citas])

  const delDia = (iso: string) => porDia.get(iso) ?? []
  const citasHoy = delDia(hoy)
  const activasHoy = citasHoy.filter(cuentaParaIngresos)
  const mismaDiaSemanaPasada = delDia(addDaysIso(hoy, -7)).filter(cuentaParaIngresos)
  const deltaCitas = mismaDiaSemanaPasada.length ? Math.round(((activasHoy.length - mismaDiaSemanaPasada.length) / mismaDiaSemanaPasada.length) * 100) : undefined
  const estimadoHoy = activasHoy.reduce((s, c) => s + c.precioFinal, 0)
  const cobradoHoy = citasHoy.filter((c) => c.estado === 'Completada').reduce((s, c) => s + c.precioFinal, 0)
  const disponibles = barberos.filter((b) => b.disponible).length
  const clientesActivos = (clientesQuery.data ?? []).filter((c) => c.activo).length
  const clientesConCitaMes = new Set(citas.filter((c) => c.fechaCita.slice(0, 7) === hoy.slice(0, 7)).map((c) => c.cliente.id)).size

  /* Ingresos por día: últimos 14 días; cobrado = completadas, hoy = estimado. */
  const ingresos: ColumnDatum[] = useMemo(() => {
    const days = Array.from({ length: 14 }, (_, i) => addDaysIso(hoy, i - 13))
    const values = days.map((iso) => {
      const lista = porDia.get(iso) ?? []
      if (descansa(iso) && lista.length === 0) return null
      return iso === hoy ? lista.filter(cuentaParaIngresos).reduce((s, c) => s + c.precioFinal, 0) : lista.filter((c) => c.estado === 'Completada').reduce((s, c) => s + c.precioFinal, 0)
    })
    const maxIdx = values.reduce<number>((best, v, i) => ((v ?? -1) > (values[best] ?? -1) ? i : best), 0)
    return days.map((iso, i) => {
      const d = parseIso(iso)
      return {
        key: iso,
        x: values[i] == null ? '–' : String(d.getDate()),
        label: `${WEEKDAY_SHORT[d.getDay()]} ${formatLongDate(d).split(' ').slice(1).join(' ')}`,
        value: values[i],
        estimated: iso === hoy,
        showLabel: (i === maxIdx && (values[i] ?? 0) > 0) || iso === hoy,
      }
    })
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [porDia, hoy, barberia])

  /* Ocupación por barbero (hoy): minutos reservados / minutos de atención. */
  const ocupacion = barberos
    .map((b) => {
      const minutos = activasHoy.filter((c) => c.barbero.id === b.id).reduce((s, c) => s + (minutesOf(c.horaFin) - minutesOf(c.horaInicio)), 0)
      const pct = Math.round((minutos / minutosAbierto) * 100)
      const nombre = `${b.nombre} ${b.apellido}`.trim()
      return {
        key: b.id,
        text: nombre,
        value: pct,
        display: `${pct} %`,
        label: (
          <span className="flex items-center gap-2">
            <Avatar name={nombre} src={b.fotoUrl} size={24} />
            <span className="truncate">{nombre}</span>
          </span>
        ),
      }
    })
    .sort((a, b) => b.value - a.value)

  /* Servicios más vendidos: últimos 30 días, citas completadas. */
  const hace30 = addDaysIso(hoy, -30)
  const servicios = Array.from(
    citas
      .filter((c) => c.estado === 'Completada' && c.fechaCita >= hace30 && c.fechaCita <= hoy)
      .reduce((m, c) => m.set(c.servicio.nombre, (m.get(c.servicio.nombre) ?? 0) + 1), new Map<string, number>()),
  )
    .sort((a, b) => b[1] - a[1])
    .slice(0, 6)
    .map(([nombre, n]) => ({ key: nombre, text: nombre, label: nombre, value: n, display: String(n) }))

  /* Cancelaciones y no asistencias: % de las citas de cada semana (8 semanas). */
  const semanas = Array.from({ length: SEMANAS }, (_, i) => addDaysIso(mondayOf(hoy), -7 * (SEMANAS - 1 - i)))
  const porSemana = semanas.map((lunes) => {
    const fin = addDaysIso(lunes, 6)
    const lista = citas.filter((c) => c.fechaCita >= lunes && c.fechaCita <= fin && c.fechaCita <= hoy)
    const total = lista.length || 1
    return {
      cancel: (lista.filter((c) => c.estado === 'Cancelada').length / total) * 100,
      noShow: (lista.filter((c) => c.estado === 'NoShow').length / total) * 100,
    }
  })

  /* Próximas citas de hoy: desde ahora, sin las cerradas. */
  const ahora = nowHHMM()
  const proximas = citasHoy
    .filter((c) => (c.estado === 'Pendiente' || c.estado === 'Confirmada' || c.estado === 'EnProgreso') && (hhmm(c.horaFin) > ahora || c.estado === 'EnProgreso'))
    .sort((a, b) => a.horaInicio.localeCompare(b.horaInicio))
    .slice(0, 6)

  /* Calendario: ocupación por día del mes (> 80 % = punto naranja). */
  const marks: Record<number, 'few' | 'any'> = {}
  const capacidadDia = minutosAbierto * Math.max(1, disponibles)
  for (const [iso, lista] of porDia) {
    if (iso.slice(0, 7) !== hoy.slice(0, 7)) continue
    const minutos = lista.filter(cuentaParaIngresos).reduce((s, c) => s + (minutesOf(c.horaFin) - minutesOf(c.horaInicio)), 0)
    if (minutos > 0) marks[parseIso(iso).getDate()] = minutos / capacidadDia > 0.8 ? 'few' : 'any'
  }

  const loading = useDelayedFlag(citasQuery.isLoading)
  const trabajando = barberos.filter((b) => b.disponible).length

  return (
    <div className="mx-auto flex max-w-[1200px] flex-col gap-6 px-4 py-5 md:px-6 lg:px-8">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h2 className="font-display text-display text-ink">Hoy en la barbería</h2>
          <p className="text-body text-ink-muted">
            {formatLongDate(hoyDate).charAt(0).toUpperCase() + formatLongDate(hoyDate).slice(1)}
            {descansa(hoy) ? ' · Hoy la barbería descansa' : ` · Abierto de ${formatTime(apertura)} a ${formatTime(cierre)}`}
            {!esBarbero && barberos.length > 0 && ` · ${trabajando} ${trabajando === 1 ? 'barbero trabajando' : 'barberos trabajando'}`}
          </p>
        </div>
        <Button variant="secondary" icon="calendar-days" onClick={() => navigate('/citas')}>
          Ir a la agenda
        </Button>
      </div>

      {citasQuery.isError ? (
        <EmptyState tone="error" title="No pudimos cargar el resumen" body="Revisa tu conexión e inténtalo de nuevo." actionLabel="Reintentar" actionIcon="refresh-cw" actionVariant="secondary" onAction={() => void citasQuery.refetch()} />
      ) : loading ? (
        <Skeleton variant="card" rows={4} label="Cargando el resumen" />
      ) : citasQuery.isLoading ? null : (
        <>
          <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-4">
            <StatCard label="Citas de hoy" value={String(activasHoy.length)} icon="calendar-days" delta={deltaCitas} deltaLabel={`vs. ${WEEKDAY_SHORT[hoyDate.getDay()]} pasado`} hint={deltaCitas == null ? 'Sin citas el mismo día de la semana pasada' : undefined} />
            <StatCard label="Ingresos estimados de hoy" value={formatCOP(estimadoHoy)} icon="banknote" hint={`${formatCOP(cobradoHoy)} ya cobrados en el local`} />
            {!esBarbero && (
              <StatCard
                label="Clientes activos"
                value={clientesQuery.isError ? '—' : String(clientesActivos)}
                icon="users"
                hint={`${clientesConCitaMes} con cita este mes`}
              />
            )}
            {!esBarbero && (
              <StatCard
                label="Barberos activos"
                value={`${disponibles} de ${barberos.length}`}
                icon="scissors"
                hint={barberos.length - disponibles > 0 ? `${barberos.length - disponibles} no ${barberos.length - disponibles === 1 ? 'disponible' : 'disponibles'} hoy` : 'Todo el equipo disponible'}
              />
            )}
          </div>

          <div className="grid gap-4 xl:grid-cols-[3fr_2fr]">
            <Panel
              title="Ingresos por día"
              subtitle="Últimos 14 días · citas completadas"
              action={
                <span className="inline-flex items-center gap-2 text-caption text-ink-muted">
                  <span className="h-3 w-3 rounded-xs border-[1.5px] border-dashed border-chart-1 bg-brass-soft" aria-hidden="true" />
                  Hoy, estimado
                </span>
              }
            >
              <ColumnChart data={ingresos} format={formatCOP} formatAxis={millones} caption="Ingresos por día de los últimos 14 días" valueHead="Ingresos" />
            </Panel>
            {!esBarbero && (
              <Panel title="Ocupación por barbero" subtitle="Hoy · horas reservadas sobre horas de atención">
                {ocupacion.length ? (
                  <BarList data={ocupacion} max={100} caption="Ocupación de hoy por barbero" valueHead="Ocupación" />
                ) : (
                  <p className="text-body text-ink-muted">No hay barberos activos.</p>
                )}
              </Panel>
            )}
          </div>

          <div className="grid gap-4 xl:grid-cols-2">
            <Panel title="Servicios más vendidos" subtitle="Últimos 30 días · citas completadas">
              {servicios.length ? (
                <BarList data={servicios} max={servicios[0].value} color="var(--chart-2)" caption="Servicios más vendidos en los últimos 30 días" valueHead="Citas" />
              ) : (
                <p className="text-body text-ink-muted">Aún no hay citas completadas en los últimos 30 días.</p>
              )}
            </Panel>
            <Panel title="Cancelaciones y no asistencias" subtitle={`Últimas ${SEMANAS} semanas · % de las citas de cada semana`}>
              <LineChart
                caption={`Porcentaje semanal de citas canceladas y de clientes que no asistieron, últimas ${SEMANAS} semanas`}
                labels={semanas.map((l) => String(parseIso(l).getDate()))}
                longLabels={semanas.map((l) => `Semana del ${formatLongDate(parseIso(l)).split(' ').slice(1).join(' ')}`)}
                series={[
                  { key: 'cancel', name: 'Canceladas', color: 'var(--chart-1)', values: porSemana.map((s) => s.cancel) },
                  { key: 'noshow', name: 'No asistió', color: 'var(--chart-2)', values: porSemana.map((s) => s.noShow) },
                ]}
              />
            </Panel>
          </div>

          <div className="grid gap-4 xl:grid-cols-[3fr_2fr]">
            <Panel title="Próximas citas de hoy" action={<Link to="/citas" className="bsm-link">Ver agenda completa</Link>}>
              {proximas.length === 0 ? (
                <EmptyState icon="calendar-check" title="No quedan citas por hoy" body="Las nuevas reservas aparecerán aquí." />
              ) : (
                <ul className="flex flex-col">
                  {proximas.map((c) => (
                    <li key={c.id} className="flex flex-wrap items-center gap-3 border-t border-line py-3 first:border-t-0 first:pt-0">
                      <span className="tnum w-20 flex-none text-label-sm text-ink">{formatTime(hhmm(c.horaInicio))}</span>
                      <span className="flex min-w-0 flex-1 items-center gap-3">
                        <Avatar name={nombreBarbero(c)} src={c.barbero.fotoUrl} size={32} />
                        <span className="flex min-w-0 flex-col">
                          <strong className="truncate text-label-sm text-ink">{nombreCliente(c)}</strong>
                          <span className="truncate text-caption text-ink-muted">
                            {c.servicio.nombre} · con {c.barbero.nombre}
                          </span>
                        </span>
                      </span>
                      <StatusBadge status={c.estado} />
                      {c.estado === 'Pendiente' && !esBarbero && (
                        <Button size="sm" variant="secondary" icon="check" loading={confirmMutation.isPending && confirmMutation.variables === c.id} onClick={() => confirmMutation.mutate(c.id)}>
                          Confirmar
                        </Button>
                      )}
                    </li>
                  ))}
                </ul>
              )}
            </Panel>
            <section className="bsm-card flex-col" aria-label="Calendario del mes">
              <Calendar
                year={mes.year}
                month={mes.month}
                today={hoyDate.getDate()}
                selected={hoyDate.getDate()}
                disabled={(d) => descansa(`${hoy.slice(0, 7)}-${String(d).padStart(2, '0')}`)}
                marks={marks}
                legend="Punto naranja: más del 80 % de ocupación. Toca un día para abrir su agenda."
                onSelect={(d) => navigate(`/citas?fecha=${hoy.slice(0, 7)}-${String(d).padStart(2, '0')}`)}
              />
              <p className="mt-2 inline-flex items-center gap-1 text-caption text-ink-muted">
                <Icon name="info" size={16} />
                Los días en gris son de descanso.
              </p>
            </section>
          </div>
        </>
      )}
    </div>
  )
}
