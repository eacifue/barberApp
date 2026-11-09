import { useMemo, useState, type ReactNode } from 'react'
import { useInfiniteQuery, useQuery } from '@tanstack/react-query'
import { useSearchParams } from 'react-router-dom'

import {
  AgendaBoard,
  Avatar,
  Banner,
  Button,
  Chip,
  EmptyState,
  IconButton,
  Input,
  Select,
  Skeleton,
  StatusBadge,
  Table,
  Tabs,
  formatCOP,
  formatDecimal,
  formatLongDate,
  formatShortDate,
  formatTime,
  useDelayedFlag,
  type AgendaColumn,
  type TableColumn,
} from '../../components/bsm'
import { useBarberias } from '../../hooks/useBarberias'
import { useBarberos } from '../../hooks/useBarberos'
import { useMediaQuery } from '../../hooks/useMediaQuery'
import { useTenantBarberia } from '../../hooks/useTenantBarberia'
import { citaService } from '../../services/citaService'
import { useAuthStore } from '../../stores/authStore'
import type { Cita, EstadoCita } from '../../types/cita'
import {
  ESTADOS,
  addDaysIso,
  compareAsc,
  compareDesc,
  cuentaParaIngresos,
  hhmm,
  mondayOf,
  nombreBarbero,
  nombreCliente,
  nowHHMM,
  parseIso,
  todayIso,
  weekDays,
  esDiaDescanso,
} from './agendaUtils'
import { CitaDetailPanel } from './CitaDetailPanel'
import { CreateCitaModal } from './CreateCitaModal'

type Vista = 'dia' | 'semana' | 'historial'
const PAGE = 25
const WEEKDAY_SHORT = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']

function capitalizar(s: string) {
  return s.charAt(0).toUpperCase() + s.slice(1)
}

function rangoSemana(lunes: string) {
  const a = parseIso(lunes)
  const b = parseIso(addDaysIso(lunes, 6))
  const mes = (d: Date) => formatShortDate(d).split(' ')[1]
  return a.getMonth() === b.getMonth() ? `${a.getDate()} – ${b.getDate()} de ${formatLongDate(b).split(' de ')[1]}` : `${a.getDate()} ${mes(a)} – ${b.getDate()} ${mes(b)}`
}

/**
 * Agenda: pantalla principal del panel (design/pantallas/panel-web/Main,
 * Agenda-semana, Agenda-historial, Agenda-movil).
 */
export function AgendaPage() {
  const [params, setParams] = useSearchParams()
  const fechaParam = params.get('fecha')
  const vistaParam = params.get('vista') as Vista | null
  const hoy = todayIso()
  const rol = useAuthStore((s) => s.usuario?.rol ?? '')
  const esBarbero = rol === 'Barbero'
  const phone = !useMediaQuery('(min-width: 768px)')
  const wide = useMediaQuery('(min-width: 1024px)')

  const vista: Vista = vistaParam === 'semana' || vistaParam === 'historial' ? vistaParam : 'dia'
  const fecha = fechaParam && /^\d{4}-\d{2}-\d{2}$/.test(fechaParam) ? fechaParam : hoy
  const setParam = (key: string, value: string) =>
    setParams(
      (prev) => {
        const next = new URLSearchParams(prev)
        next.set(key, value)
        return next
      },
      { replace: true },
    )
  const setVista = (v: string) => setParam('vista', v)
  const setFecha = (f: string) => setParam('fecha', f)

  const [barberoFiltro, setBarberoFiltro] = useState('')
  const [barberoSemana, setBarberoSemana] = useState('')
  const [barberoMovil, setBarberoMovil] = useState('')
  const [estadoFiltro, setEstadoFiltro] = useState<EstadoCita | ''>('')
  const [seleccion, setSeleccion] = useState<Cita | null>(null)
  const [nueva, setNueva] = useState<{ barberoId?: string; fecha?: string; hora?: string; reprogramar?: Cita | null } | null>(null)

  // Historial
  const [desde, setDesde] = useState(addDaysIso(hoy, -30))
  const [hasta, setHasta] = useState(hoy)
  const [barberoHist, setBarberoHist] = useState('')
  const [estadoHist, setEstadoHist] = useState('')
  const [clienteHist, setClienteHist] = useState('')

  const { effectiveBarberiaId } = useTenantBarberia()
  const { barberiasQuery } = useBarberias()
  const barberia = barberiasQuery.data?.find((b) => b.id === effectiveBarberiaId)
  const { barberosQuery } = useBarberos(esBarbero ? '' : (effectiveBarberiaId ?? ''))
  const barberos = useMemo(() => (barberosQuery.data ?? []).filter((b) => b.activo), [barberosQuery.data])

  const apertura = barberia?.horaApertura ? hhmm(barberia.horaApertura) : '09:00'
  const cierre = barberia?.horaCierre ? hhmm(barberia.horaCierre) : '20:00'
  const descansa = (iso: string) => esDiaDescanso(barberia?.diasDescanso as Array<string | number> | undefined, iso)

  /* ---------- Día ---------- */
  const diaQuery = useQuery({
    queryKey: ['agenda', 'dia', fecha],
    enabled: vista === 'dia',
    queryFn: () => citaService.getAdminList({ date: fecha, page: 1, pageSize: 250 }),
  })
  const citasDia = useMemo(() => (diaQuery.data ?? []).slice().sort(compareAsc), [diaQuery.data])

  /* ---------- Semana ---------- */
  const lunes = mondayOf(fecha)
  const barberoSemanaId = barberoSemana || barberos[0]?.id || ''
  const semanaQuery = useQuery({
    queryKey: ['agenda', 'semana', lunes, esBarbero ? 'propio' : barberoSemanaId],
    enabled: vista === 'semana' && (esBarbero || Boolean(barberoSemanaId)),
    queryFn: () =>
      citaService.getAdminList({ from: lunes, to: addDaysIso(lunes, 6), barberoId: esBarbero ? undefined : barberoSemanaId, page: 1, pageSize: 250 }),
  })

  /* ---------- Historial ---------- */
  const historialQuery = useInfiniteQuery({
    queryKey: ['agenda-historial', desde, hasta, barberoHist, estadoHist],
    enabled: vista === 'historial',
    initialPageParam: 1,
    queryFn: ({ pageParam }) =>
      citaService.getAdminList({ from: desde || undefined, to: hasta || undefined, barberoId: barberoHist || undefined, status: estadoHist || undefined, page: pageParam, pageSize: PAGE }),
    getNextPageParam: (last, pages) => (last.length < PAGE ? undefined : pages.length + 1),
  })
  const historial = useMemo(() => {
    const q = clienteHist.trim().toLowerCase()
    const digits = q.replace(/\D/g, '')
    return (historialQuery.data?.pages ?? [])
      .flat()
      .filter((c) => !q || nombreCliente(c).toLowerCase().includes(q) || (digits.length >= 3 && (c.cliente.telefono ?? '').replace(/\D/g, '').includes(digits)))
      .sort(compareDesc)
  }, [historialQuery.data, clienteHist])

  /* ---------- Selección: siempre la versión más reciente de la cita ---------- */
  const todas = [...citasDia, ...(semanaQuery.data ?? []), ...historial]
  const citaSeleccionada = seleccion ? (todas.find((c) => c.id === seleccion.id) ?? seleccion) : null

  const loadingDia = useDelayedFlag(diaQuery.isLoading)
  const loadingSemana = useDelayedFlag(semanaQuery.isLoading)

  /* ---------- Columnas del tablero del día ---------- */
  const conteoPorEstado = useMemo(() => {
    const m = new Map<string, number>()
    for (const c of citasDia) m.set(c.estado, (m.get(c.estado) ?? 0) + 1)
    return m
  }, [citasDia])
  const visiblesDia = citasDia.filter((c) => !estadoFiltro || c.estado === estadoFiltro)
  const pendientesHoy = fecha === hoy ? citasDia.filter((c) => c.estado === 'Pendiente') : []
  const estimado = citasDia.filter(cuentaParaIngresos).reduce((s, c) => s + c.precioFinal, 0)

  const columnasBase = esBarbero || barberos.length === 0
    ? Array.from(new Map(citasDia.map((c) => [c.barbero.id, { id: c.barbero.id, nombre: nombreBarbero(c), fotoUrl: c.barbero.fotoUrl }])).values())
    : barberos.map((b) => ({ id: b.id, nombre: `${b.nombre} ${b.apellido}`.trim(), fotoUrl: b.fotoUrl }))
  const barberoMovilId = barberoMovil || columnasBase[0]?.id || ''
  const columnasFiltradas = columnasBase.filter((b) => (phone ? b.id === barberoMovilId : !barberoFiltro || b.id === barberoFiltro))
  const columnasDia: AgendaColumn[] = columnasFiltradas.map((b) => {
    const suyas = visiblesDia.filter((c) => c.barbero.id === b.id)
    return {
      id: b.id,
      name: b.nombre,
      photo: b.fotoUrl,
      count: citasDia.filter((c) => c.barbero.id === b.id && cuentaParaIngresos(c)).length,
      items: suyas.map((c) => ({
        id: c.id,
        client: nombreCliente(c),
        service: c.servicio.nombre,
        start: hhmm(c.horaInicio),
        end: hhmm(c.horaFin),
        status: c.estado,
        selected: citaSeleccionada?.id === c.id,
      })),
    }
  })

  /* ---------- Columnas de la semana ---------- */
  const columnasSemana: AgendaColumn[] = weekDays(fecha).map((iso) => {
    const d = parseIso(iso)
    const suyas = (semanaQuery.data ?? []).filter((c) => c.fechaCita === iso).sort(compareAsc)
    const cerrado = descansa(iso)
    return {
      id: iso,
      name: `${WEEKDAY_SHORT[d.getDay()]} ${d.getDate()}`,
      avatar: false,
      current: iso === hoy,
      sub: cerrado ? 'Cerrado' : `${suyas.filter(cuentaParaIngresos).length} citas`,
      items: suyas.map((c) => ({
        id: c.id,
        client: nombreCliente(c),
        service: c.servicio.nombre,
        start: hhmm(c.horaInicio),
        end: hhmm(c.horaFin),
        status: c.estado,
        selected: citaSeleccionada?.id === c.id,
      })),
    }
  })
  const semana = semanaQuery.data ?? []

  const abrir = (id?: string) => {
    if (!id) return
    const c = todas.find((x) => x.id === id)
    if (c) setSeleccion(c)
  }

  /* ---------- Encabezado ---------- */
  const navFecha = (dias: number) => setFecha(addDaysIso(fecha, dias))
  const titulo =
    vista === 'dia'
      ? `${fecha === hoy ? 'Hoy, ' : ''}${fecha === hoy ? formatLongDate(parseIso(fecha)) : capitalizar(formatLongDate(parseIso(fecha)))}`
      : vista === 'semana'
        ? rangoSemana(lunes)
        : 'Historial de citas'

  const toolbar = (
    <div className="flex flex-wrap items-center gap-3">
      {vista !== 'historial' && (
        <div className="flex items-center gap-1">
          <IconButton icon="chevron-left" variant="secondary" size="sm" label={vista === 'dia' ? 'Día anterior' : 'Semana anterior'} onClick={() => navFecha(vista === 'dia' ? -1 : -7)} />
          <Button variant="secondary" size="sm" onClick={() => setFecha(hoy)} disabled={vista === 'dia' ? fecha === hoy : mondayOf(hoy) === lunes}>
            {vista === 'dia' ? 'Hoy' : 'Esta semana'}
          </Button>
          <IconButton icon="chevron-right" variant="secondary" size="sm" label={vista === 'dia' ? 'Día siguiente' : 'Semana siguiente'} onClick={() => navFecha(vista === 'dia' ? 1 : 7)} />
        </div>
      )}
      <h2 className="mr-auto font-display text-title-lg text-ink" aria-live="polite">
        {titulo}
      </h2>
      <Tabs
        variant="segmented"
        label="Vista de la agenda"
        value={vista}
        onChange={setVista}
        items={[
          { value: 'dia', label: 'Día' },
          { value: 'semana', label: 'Semana' },
          { value: 'historial', label: 'Historial' },
        ]}
      />
      {!esBarbero && (
        <Button icon="plus" onClick={() => setNueva({ fecha: vista === 'historial' ? hoy : fecha })}>
          Nueva cita
        </Button>
      )}
    </div>
  )

  /* ---------- Cuerpo por vista ---------- */
  let cuerpo: ReactNode
  if (vista === 'dia') {
    const cerrado = descansa(fecha)
    cuerpo = (
      <>
        <div className="flex flex-wrap items-center gap-3">
          {phone ? (
            <div role="group" aria-label="Barbero" className="bsm-chip-row">
              {columnasBase.map((b) => (
                <Chip key={b.id} selected={b.id === barberoMovilId} count={citasDia.filter((c) => c.barbero.id === b.id && cuentaParaIngresos(c)).length} onClick={() => setBarberoMovil(b.id)}>
                  {b.nombre.split(' ')[0]}
                </Chip>
              ))}
            </div>
          ) : (
            !esBarbero && (
              <div className="w-56">
                <Select
                  aria-label="Filtrar por barbero"
                  value={barberoFiltro}
                  onChange={(e) => setBarberoFiltro(e.target.value)}
                  options={[{ value: '', label: 'Todos los barberos' }, ...columnasBase.map((b) => ({ value: b.id, label: b.nombre }))]}
                />
              </div>
            )
          )}
          {!phone && (
            <div role="group" aria-label="Filtrar por estado" className="bsm-chip-row">
              <Chip selected={!estadoFiltro} count={citasDia.length} onClick={() => setEstadoFiltro('')}>
                Todas
              </Chip>
              {ESTADOS.map((e) => (
                <Chip key={e.value} selected={estadoFiltro === e.value} count={conteoPorEstado.get(e.value) ?? 0} onClick={() => setEstadoFiltro(estadoFiltro === e.value ? '' : e.value)}>
                  {e.label}
                </Chip>
              ))}
            </div>
          )}
          <span className="ml-auto text-body text-ink-muted tnum">
            {citasDia.length} {citasDia.length === 1 ? 'cita' : 'citas'} · {formatCOP(estimado)} estimado
          </span>
        </div>

        {pendientesHoy.length > 0 && !esBarbero && (
          <Banner
            tone="warning"
            icon="hourglass"
            title={`${pendientesHoy.length} ${pendientesHoy.length === 1 ? 'cita pendiente' : 'citas pendientes'} por confirmar hoy`}
            actionLabel={estadoFiltro === 'Pendiente' ? 'Ver todas' : 'Revisar'}
            onAction={() => setEstadoFiltro(estadoFiltro === 'Pendiente' ? '' : 'Pendiente')}
          >
            {pendientesHoy
              .slice(0, 4)
              .map((c) => `${nombreCliente(c)} ${formatTime(hhmm(c.horaInicio))}`)
              .join(', ')}
            {pendientesHoy.length > 4 ? ` y ${pendientesHoy.length - 4} más` : ''}
          </Banner>
        )}

        {diaQuery.isError ? (
          <EmptyState tone="error" title="No pudimos cargar la agenda" body="Revisa tu conexión e inténtalo de nuevo." actionLabel="Reintentar" actionIcon="refresh-cw" actionVariant="secondary" onAction={() => void diaQuery.refetch()} />
        ) : loadingDia ? (
          <Skeleton variant="card" rows={3} label="Cargando la agenda" />
        ) : diaQuery.isLoading ? null : cerrado && citasDia.length === 0 ? (
          <EmptyState icon="store" title="La barbería descansa este día" body="Elige otro día para ver o crear citas." actionLabel="Ir a hoy" actionVariant="secondary" onAction={() => setFecha(hoy)} />
        ) : columnasDia.length === 0 ? (
          <EmptyState icon="users" title="No hay barberos activos" body="Activa o crea barberos para ver su agenda." />
        ) : (
          <AgendaBoard
            columns={columnasDia}
            start={apertura}
            end={cierre}
            now={fecha === hoy ? nowHHMM() : undefined}
            pxPerMin={phone ? 1.05 : 1.1}
            onItemClick={(item) => abrir(item.id)}
            onSlotClick={esBarbero ? undefined : (col, hora) => setNueva({ barberoId: col.id, fecha, hora })}
          />
        )}
        {!esBarbero && !phone && citasDia.length === 0 && !diaQuery.isLoading && !cerrado && (
          <p className="text-center text-body text-ink-muted">No hay citas este día. Toca un espacio libre del tablero para crear una.</p>
        )}
      </>
    )
  } else if (vista === 'semana') {
    const canceladas = semana.filter((c) => c.estado === 'Cancelada').length
    const noAsistieron = semana.filter((c) => c.estado === 'NoShow').length
    cuerpo = (
      <>
        <div className="flex flex-wrap items-center gap-3">
          {!esBarbero && (
            <div className="w-56">
              <Select aria-label="Barbero de la semana" value={barberoSemanaId} onChange={(e) => setBarberoSemana(e.target.value)} options={barberos.map((b) => ({ value: b.id, label: `${b.nombre} ${b.apellido}`.trim() }))} />
            </div>
          )}
          {!esBarbero && <span className="text-body text-ink-muted">La vista Semana muestra un barbero a la vez.</span>}
          <span className="ml-auto text-body text-ink-muted tnum">
            {semana.filter(cuentaParaIngresos).length} citas esta semana · {canceladas} {canceladas === 1 ? 'cancelada' : 'canceladas'} · {noAsistieron} no {noAsistieron === 1 ? 'asistió' : 'asistieron'}
          </span>
        </div>
        {semanaQuery.isError ? (
          <EmptyState tone="error" title="No pudimos cargar la semana" body="Revisa tu conexión e inténtalo de nuevo." actionLabel="Reintentar" actionIcon="refresh-cw" actionVariant="secondary" onAction={() => void semanaQuery.refetch()} />
        ) : loadingSemana ? (
          <Skeleton variant="card" rows={3} label="Cargando la semana" />
        ) : semanaQuery.isLoading ? null : (
          <AgendaBoard
            columns={columnasSemana}
            start={apertura}
            end={cierre}
            now={weekDays(fecha).includes(hoy) ? nowHHMM() : undefined}
            pxPerMin={1.1}
            onItemClick={(item) => abrir(item.id)}
            onSlotClick={esBarbero ? undefined : (col, hora) => (descansa(col.id ?? '') ? undefined : setNueva({ barberoId: barberoSemanaId, fecha: col.id, hora }))}
          />
        )}
      </>
    )
  } else {
    const cobrados = historial.filter((c) => c.estado === 'Completada').reduce((s, c) => s + c.precioFinal, 0)
    const pct = (estado: EstadoCita) => (historial.length ? formatDecimal((historial.filter((c) => c.estado === estado).length / historial.length) * 100, 0) : '0')
    const columnas: TableColumn<Cita>[] = [
      { key: 'fecha', label: 'Fecha', sort: 'desc', render: (c) => <span className="tnum">{formatShortDate(parseIso(c.fechaCita), true)}</span> },
      { key: 'hora', label: 'Hora', render: (c) => <span className="tnum whitespace-nowrap">{formatTime(hhmm(c.horaInicio))}</span> },
      {
        key: 'cliente',
        label: 'Cliente',
        render: (c) => (
          <span className="flex items-center gap-3">
            <Avatar name={nombreCliente(c)} src={c.cliente.fotoUrl} size={32} />
            <span className="flex flex-col text-left">
              <strong className="text-label-sm text-ink">{nombreCliente(c)}</strong>
              {c.cliente.telefono && <span className="text-caption text-ink-muted tnum">{c.cliente.telefono}</span>}
            </span>
          </span>
        ),
      },
      { key: 'servicio', label: 'Servicio', render: (c) => c.servicio.nombre },
      { key: 'barbero', label: 'Barbero', muted: true, render: (c) => nombreBarbero(c) },
      { key: 'estado', label: 'Estado', render: (c) => <StatusBadge status={c.estado} /> },
      { key: 'precio', label: 'Precio', align: 'right', render: (c) => formatCOP(c.precioFinal) },
    ]
    const total = historial.length
    cuerpo = (
      <>
        <div className="grid gap-3 md:grid-cols-3 lg:grid-cols-5">
          <Input label="Desde" type="date" icon="calendar" value={desde} max={hasta || undefined} onChange={(e) => setDesde(e.target.value)} />
          <Input label="Hasta" type="date" icon="calendar" value={hasta} min={desde || undefined} onChange={(e) => setHasta(e.target.value)} />
          {!esBarbero && (
            <Select
              label="Barbero"
              value={barberoHist}
              onChange={(e) => setBarberoHist(e.target.value)}
              options={[{ value: '', label: 'Todos los barberos' }, ...barberos.map((b) => ({ value: b.id, label: `${b.nombre} ${b.apellido}`.trim() }))]}
            />
          )}
          <Select label="Estado" value={estadoHist} onChange={(e) => setEstadoHist(e.target.value)} options={[{ value: '', label: 'Todos los estados' }, ...ESTADOS]} />
          <Input label="Cliente" icon="search" placeholder="Nombre o teléfono" value={clienteHist} onChange={(e) => setClienteHist(e.target.value)} />
        </div>
        {!historialQuery.isLoading && !historialQuery.isError && (
          <p className="text-body text-ink-muted tnum">
            {total} {total === 1 ? 'cita' : 'citas'} cargadas · {formatCOP(cobrados)} cobrados · {pct('Cancelada')} % canceladas · {pct('NoShow')} % no asistieron
          </p>
        )}
        <Table
          caption="Historial de citas"
          columns={columnas}
          rows={historial}
          rowKey={(c) => c.id}
          isSelected={(c) => c.id === citaSeleccionada?.id}
          onRowClick={(c) => setSeleccion(c)}
          state={
            historialQuery.isError ? (
              <EmptyState tone="error" title="No pudimos cargar el historial" body="Revisa tu conexión e inténtalo de nuevo." actionLabel="Reintentar" actionIcon="refresh-cw" actionVariant="secondary" onAction={() => void historialQuery.refetch()} />
            ) : historialQuery.isLoading ? (
              <Skeleton variant="row" rows={6} label="Cargando el historial" />
            ) : historial.length === 0 ? (
              <EmptyState icon="history" title="No hay citas en este periodo" body="Prueba con otras fechas o quita filtros." />
            ) : undefined
          }
        />
        {historial.length > 0 && (
          <div className="flex flex-col items-center gap-2">
            <p className="text-caption text-ink-muted tnum">
              {historialQuery.hasNextPage ? `Mostrando ${total} citas` : `Estas son todas las citas del periodo (${total}).`}
            </p>
            {historialQuery.hasNextPage && (
              <Button variant="secondary" icon={historialQuery.isFetchingNextPage ? undefined : 'history'} loading={historialQuery.isFetchingNextPage} onClick={() => void historialQuery.fetchNextPage()}>
                {historialQuery.isFetchingNextPage ? 'Cargando…' : 'Cargar más'}
              </Button>
            )}
          </div>
        )}
      </>
    )
  }

  const panel = citaSeleccionada && (
    <CitaDetailPanel
      cita={citaSeleccionada}
      overlay={!wide}
      onClose={() => setSeleccion(null)}
      onReprogramar={(c) => setNueva({ reprogramar: c, fecha: c.fechaCita })}
    />
  )

  return (
    <div className="flex h-full min-h-0">
      <div className="min-w-0 flex-1 overflow-y-auto">
        <div className="mx-auto flex max-w-[1400px] flex-col gap-5 px-4 py-5 md:px-6 lg:px-8">
          {toolbar}
          {cuerpo}
        </div>
      </div>
      {panel}
      <CreateCitaModal
        open={nueva != null}
        onClose={() => setNueva(null)}
        initialBarberoId={nueva?.barberoId}
        initialFecha={nueva?.fecha}
        initialHora={nueva?.hora}
        reprogramarDe={nueva?.reprogramar ?? null}
        onCreated={() => {
          if (nueva?.reprogramar) setSeleccion(null)
        }}
      />
    </div>
  )
}
