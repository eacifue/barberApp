import { useMemo } from 'react'
import { Activity, ArrowRight, CalendarCheck2, CircleDollarSign, Scissors, UsersRound, UserRoundCheck } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'

import { useBarberias } from '../../hooks/useBarberias'
import { useTenantBarberia } from '../../hooks/useTenantBarberia'
import { barberoService } from '../../services/barberoService'
import { citaService } from '../../services/citaService'
import { clienteService } from '../../services/clienteService'
import { slotsRedisService } from '../../services/slotsRedisService'
import { EstadoCita } from '../../types/cita'
import type { Cita } from '../../types/cita'
import { PageHeader } from '../../components/shared/PageHeader'
import { StatCard } from '../../components/shared/StatCard'
import { Badge } from '../../components/ui/Badge'
import { Button } from '../../components/ui/Button'
import { DataTable } from '../../components/ui/DataTable'

function toIsoDateLocal(date: Date) {
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
}

function monthBounds(date = new Date()) {
  const start = new Date(date.getFullYear(), date.getMonth(), 1)
  const end = new Date(date.getFullYear(), date.getMonth() + 1, 0)
  return {
    start: toIsoDateLocal(start),
    end: toIsoDateLocal(end),
  }
}

async function getAdminCitasRange(from: string, to: string) {
  const pageSize = 200
  const maxPages = 20
  let page = 1
  const all = [] as Awaited<ReturnType<typeof citaService.getAdminList>>

  while (page <= maxPages) {
    const chunk = await citaService.getAdminList({ from, to, page, pageSize })
    if (chunk.length === 0) break

    all.push(...chunk)
    if (chunk.length < pageSize) break
    page += 1
  }

  return Array.from(new Map(all.map((cita) => [cita.id, cita])).values())
}

function getEstadoVariant(estado: string) {
  if (estado === EstadoCita.Confirmada) return 'success'
  if (estado === EstadoCita.Pendiente) return 'warning'
  if (estado === EstadoCita.EnProgreso) return 'info'
  if (estado === EstadoCita.Completada) return 'muted'
  return 'danger'
}

export function DashboardPage() {
  const navigate = useNavigate()
  const today = useMemo(() => toIsoDateLocal(new Date()), [])
  const thisMonth = useMemo(() => monthBounds(), [])
  const { isAdminBarberia, effectiveBarberiaId, tenantError } = useTenantBarberia()

  // ── Barberias ──────────────────────────────────────────────────────────────
  const { barberiasQuery } = useBarberias()
  const barberias = barberiasQuery.data ?? []

  // ── Barberos de la única barbería ───────────────────────────────────────────
  const allBarberosQuery = useQuery({
    queryKey: ['dashboard-barberos', effectiveBarberiaId],
    enabled: Boolean(effectiveBarberiaId),
    queryFn: () => barberoService.getByBarberia(effectiveBarberiaId as string),
  })

  const allBarberos = useMemo(() => allBarberosQuery.data ?? [], [allBarberosQuery.data])
  const barberoIds = useMemo(() => new Set(allBarberos.map((barbero) => barbero.id)), [allBarberos])
  const barberosActivos = useMemo(() => allBarberos.filter((b) => b.activo).length, [allBarberos])
  const barberosLoading = barberiasQuery.isLoading || allBarberosQuery.isLoading

  const clientesQuery = useQuery({
    queryKey: ['dashboard-clientes', isAdminBarberia, effectiveBarberiaId],
    queryFn: () => (isAdminBarberia ? clienteService.getAllTenant() : clienteService.getAll()),
  })

  // ── Citas HOY: endpoint admin, robusto e independiente por barbero ─────────
  const citasHoyQuery = useQuery({
    queryKey: ['dashboard-citas-hoy', today],
    queryFn: () => getAdminCitasRange(today, today),
  })

  // ── Citas del mes para el mini-calendario (lazy, no bloquea métricas) ──────
  const citasMesQuery = useQuery({
    queryKey: ['dashboard-citas-mes', thisMonth.start, thisMonth.end],
    staleTime: 5 * 60 * 1000, // 5 min – no necesita ser tan fresco
    queryFn: () => getAdminCitasRange(thisMonth.start, thisMonth.end),
  })

  // ── Slots Redis ────────────────────────────────────────────────────────────
  const slotsRedisQuery = useQuery({
    queryKey: ['slots-activos-dashboard'],
    queryFn: async () => {
      try { return await slotsRedisService.getActivos() } catch { return [] }
    },
  })

  const citasHoyRaw = citasHoyQuery.data ?? []
  const citasMesRaw = citasMesQuery.data ?? []
  const slotsActivosRaw = slotsRedisQuery.data ?? []

  const citasHoy = useMemo(() => {
    if (!isAdminBarberia) return citasHoyRaw
    return citasHoyRaw.filter((cita) => barberoIds.has(cita.barberoId))
  }, [isAdminBarberia, citasHoyRaw, barberoIds])

  const citasMes = useMemo(() => {
    if (!isAdminBarberia) return citasMesRaw
    return citasMesRaw.filter((cita) => barberoIds.has(cita.barberoId))
  }, [isAdminBarberia, citasMesRaw, barberoIds])

  const slotsActivos = useMemo(() => {
    if (!isAdminBarberia) return slotsActivosRaw
    return slotsActivosRaw.filter((slot) => barberoIds.has(slot.barberoId))
  }, [isAdminBarberia, slotsActivosRaw, barberoIds])

  const clientes = clientesQuery.data ?? []

  const barberiaScopeLabel = useMemo(() => {
    if (!isAdminBarberia) return null
    if (!effectiveBarberiaId) return 'Sin barbería asignada'
    return barberias.find((barberia) => barberia.id === effectiveBarberiaId)?.nombre ?? 'Mi barbería'
  }, [isAdminBarberia, effectiveBarberiaId, barberias])

  const citasPendientes = citasHoy.filter((c) => c.estado === EstadoCita.Pendiente).length
  const ingresosHoy = citasHoy
    .filter((cita) => cita.estado === EstadoCita.Completada || cita.estado === EstadoCita.EnProgreso)
    .reduce((total, cita) => total + cita.precioFinal, 0)
  const clientesConActividad = new Set(citasMes.map((cita) => cita.clienteId)).size

  const citasRecientes = useMemo(
    () => [...citasHoy].sort((a, b) => `${a.horaInicio}`.localeCompare(`${b.horaInicio}`)).slice(0, 10),
    [citasHoy],
  )

  const systemStatusLoading = slotsRedisQuery.isLoading || citasHoyQuery.isLoading

  const calendar = useMemo(() => {
    const now = new Date()
    const year = now.getFullYear()
    const month = now.getMonth()
    const firstDay = new Date(year, month, 1)
    const lastDay = new Date(year, month + 1, 0)
    const startOffset = (firstDay.getDay() + 6) % 7
    const daysInMonth = lastDay.getDate()

    const items: Array<{ day: number | null; dateIso: string | null }> = []
    for (let i = 0; i < startOffset; i += 1) {
      items.push({ day: null, dateIso: null })
    }
    for (let day = 1; day <= daysInMonth; day += 1) {
      const date = new Date(year, month, day)
      items.push({ day, dateIso: toIsoDateLocal(date) })
    }

    const citasPorDia = new Set(citasMes.map((cita) => cita.fechaCita.slice(0, 10)))

    return {
      title: now.toLocaleDateString('es-ES', { month: 'long', year: 'numeric' }),
      items,
      citasPorDia,
      todayIso: toIsoDateLocal(new Date()),
    }
  }, [citasMes])

  return (
    <section>
      <PageHeader
        title="Dashboard"
        subtitle={
          tenantError
            ? 'No se pudo cargar el dashboard por una configuración incompleta del tenant.'
            : isAdminBarberia
              ? `Monitorea agenda, ingresos, clientes y capacidad operativa de ${barberiaScopeLabel ?? 'tu barbería'}.`
              : 'Monitorea agenda, ingresos, clientes y capacidad operativa desde un panel más claro, ligero y orientado a acción.'
        }
        actions={
          tenantError ? null : (
            <div className="flex flex-wrap gap-3">
              <Button variant="ghost" onClick={() => navigate('/clientes')}>Clientes</Button>
              <Button onClick={() => navigate('/citas')}>Ir a agenda</Button>
            </div>
          )
        }
      />

      {tenantError ? (
        <div className="surface-panel rounded-[28px] px-5 py-10 text-center text-sm text-[var(--warning)]">
          {tenantError}
        </div>
      ) : null}

      {!tenantError ? (
        <>
        <div className="grid gap-4 xl:grid-cols-[1.2fr_0.8fr]">
        <article className="surface-panel rounded-[32px] p-6 md:p-8">
          <div className="flex flex-wrap items-start justify-between gap-6">
            <div className="max-w-2xl">
              <p className="text-[11px] font-semibold uppercase tracking-[0.2em] text-[var(--text-faint)]">Resumen diario</p>
              <h2 className="mt-3 font-display text-4xl leading-none text-[var(--text-strong)] md:text-5xl">
                La operación de hoy está bajo control.
              </h2>
              <p className="mt-4 max-w-xl text-sm leading-6 text-[var(--text-ink-muted)] md:text-base">
                Visualiza de inmediato el estado de las citas, la ocupación del equipo y la actividad comercial sin cambiar de módulo.
              </p>
            </div>
            <div className="grid w-full gap-3 sm:grid-cols-2 xl:w-auto xl:grid-cols-1">
              <div className="rounded-[24px] border border-[var(--border-subtle)] bg-[var(--surface-overlay)] p-4">
                <p className="text-xs uppercase tracking-[0.18em] text-[var(--text-faint)]">Citas pendientes</p>
                {citasHoyQuery.isLoading ? (
                  <span className="mt-3 block h-8 w-12 animate-pulse rounded-lg bg-[var(--surface-hover)]" aria-hidden="true" />
                ) : (
                  <p className="mt-3 text-3xl font-semibold text-[var(--text-strong)]">{citasPendientes}</p>
                )}
              </div>
              <div className="rounded-[24px] border border-[var(--border-subtle)] bg-[var(--surface-overlay)] p-4">
                <p className="text-xs uppercase tracking-[0.18em] text-[var(--text-faint)]">Clientes con actividad</p>
                {citasMesQuery.isLoading ? (
                  <span className="mt-3 block h-8 w-12 animate-pulse rounded-lg bg-[var(--surface-hover)]" aria-hidden="true" />
                ) : (
                  <p className="mt-3 text-3xl font-semibold text-[var(--text-strong)]">{clientesConActividad}</p>
                )}
              </div>
            </div>
          </div>
        </article>

        {!isAdminBarberia ? (
          <aside className="surface-panel rounded-[32px] p-6">
            <p className="text-[11px] font-semibold uppercase tracking-[0.2em] text-[var(--text-faint)]">Estado del sistema</p>
            <div className="mt-4 space-y-3">
              {systemStatusLoading ? (
                <div className="rounded-[22px] border border-[var(--border-subtle)] bg-[var(--surface-overlay)] px-4 py-3 text-sm text-[var(--text-ink-muted)]">
                  Revisando estado del sistema…
                </div>
              ) : (
                <>
                  {slotsActivos.length > 0 ? (
                    <div className="rounded-[22px] border border-[var(--border-subtle)] bg-[var(--info-soft)] px-4 py-3 text-sm text-[var(--info)]">
                      {slotsActivos.length} slots bloqueados activos.
                    </div>
                  ) : null}

                  {citasPendientes > 0 ? (
                    <div className="rounded-[22px] border border-[var(--border-subtle)] bg-[var(--warning-soft)] px-4 py-3 text-sm text-[var(--warning)]">
                      {citasPendientes} citas sin confirmar requieren atención.
                    </div>
                  ) : null}

                  {slotsActivos.length === 0 && citasPendientes === 0 ? (
                    <div className="rounded-[22px] border border-[var(--border-subtle)] bg-[var(--success-soft)] px-4 py-3 text-sm text-[var(--success)]">
                      No hay alertas críticas por ahora.
                    </div>
                  ) : null}
                </>
              )}
            </div>
          </aside>
        ) : null}
      </div>

      <div className="mt-5 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard
          label="Citas del día"
          value={String(citasHoy.length)}
          loading={citasHoyQuery.isLoading}
          icon={<CalendarCheck2 className="h-5 w-5" />}
          caption="Reservas previstas para hoy"
          valueTone="text-brass-ink"
        />
        <StatCard
          label="Ingresos"
          value={`$${ingresosHoy.toFixed(2)}`}
          loading={citasHoyQuery.isLoading}
          icon={<CircleDollarSign className="h-5 w-5" />}
          caption="Ingresos generados hoy"
        />
        <StatCard
          label="Clientes"
          value={String(clientes.length)}
          loading={clientesQuery.isLoading}
          icon={<UsersRound className="h-5 w-5" />}
          caption="Base activa de clientes"
        />
        <StatCard
          label="Barberos activos"
          value={String(barberosActivos)}
          loading={barberosLoading}
          icon={<UserRoundCheck className="h-5 w-5" />}
          caption="Equipo disponible en el sistema"
        />
      </div>

      <div className="mt-5 grid gap-4 xl:grid-cols-[1.7fr_1fr]">
        <div className="surface-panel rounded-[32px] p-5 md:p-6">
          <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
            <div>
              <h3 className="font-display text-3xl text-[var(--text-strong)]">Citas recientes</h3>
              <p className="mt-2 text-sm text-[var(--text-ink-muted)]">Turnos del día ordenados por hora y estado.</p>
            </div>
            <Button variant="ghost" onClick={() => navigate('/citas')}>
              Ver agenda
              <ArrowRight className="h-4 w-4" />
            </Button>
          </div>
          <DataTable<Cita>
            loading={citasHoyQuery.isLoading}
            emptyMessage="No hay citas recientes hoy."
            columns={[
              { key: 'index', header: '#', width: '50px', render: (_row, index) => index + 1 },
              {
                key: 'cliente',
                header: 'Cliente',
                width: '1.2fr',
                render: (row) => `${row.cliente.nombre} ${row.cliente.apellido}`,
              },
              {
                key: 'barbero',
                header: 'Barbero',
                width: '1fr',
                render: (row) => `${row.barbero.nombre} ${row.barbero.apellido}`,
              },
              { key: 'servicio', header: 'Servicio', width: '1fr', render: (row) => row.servicio.nombre },
              { key: 'hora', header: 'Hora', width: '90px', render: (row) => row.horaInicio.slice(0, 5) },
              {
                key: 'estado',
                header: 'Estado',
                width: '130px',
                render: (row) => <Badge variant={getEstadoVariant(row.estado)}>{row.estado}</Badge>,
              },
            ]}
            data={citasRecientes}
          />
        </div>

        <aside className="surface-panel rounded-[32px] p-5 md:p-6">
          <div className="flex items-center justify-between gap-3">
            <div>
              <p className="text-[11px] font-semibold uppercase tracking-[0.18em] text-[var(--text-faint)]">Calendario operativo</p>
              <h3 className="mt-2 font-display text-3xl capitalize text-[var(--text-strong)]">{calendar.title}</h3>
            </div>
            <span className="flex h-11 w-11 items-center justify-center rounded-2xl bg-[var(--accent-soft)] text-brass-ink">
              <Activity className="h-5 w-5" />
            </span>
          </div>
          <div className="mb-3 mt-5 grid grid-cols-7 text-center text-[11px] uppercase tracking-[0.18em] text-[var(--text-faint)]">
            <div>L</div><div>M</div><div>X</div><div>J</div><div>V</div><div>S</div><div>D</div>
          </div>
          <div className="grid grid-cols-7 gap-2">
            {calendar.items.map((item, idx) => {
              if (!item.day || !item.dateIso) {
                return <div key={`empty-${idx}`} className="h-12" />
              }

              const hasCitas = calendar.citasPorDia.has(item.dateIso)
              const isToday = item.dateIso === calendar.todayIso

              return (
                <button
                  type="button"
                  key={item.dateIso}
                  onClick={() => navigate(`/citas?fecha=${item.dateIso}`)}
                  className={[
                    'relative h-12 rounded-2xl border border-transparent text-sm text-[var(--text-base)] transition hover:border-[var(--border-subtle)] hover:bg-[var(--surface-hover)] focus-visible:outline-none focus-visible:shadow-focus',
                    isToday ? 'border-[var(--border-subtle)] bg-[var(--accent-soft)] text-brass-ink' : 'bg-[var(--surface-overlay)]',
                  ].join(' ')}
                >
                  {item.day}
                  {hasCitas ? <span className="absolute bottom-1.5 left-1/2 h-1.5 w-1.5 -translate-x-1/2 rounded-full bg-brass" /> : null}
                </button>
              )
            })}
          </div>
          <div className="mt-5 rounded-[24px] border border-[var(--border-subtle)] bg-[var(--surface-overlay)] p-4">
            <div className="flex items-start gap-3">
              <span className="mt-0.5 flex h-10 w-10 items-center justify-center rounded-2xl bg-[var(--accent-soft)] text-brass-ink">
                <Scissors className="h-4 w-4" />
              </span>
              <div>
                <p className="text-sm font-semibold text-[var(--text-strong)]">Operación del mes</p>
                <p className="mt-1 text-sm leading-6 text-[var(--text-ink-muted)]">
                  {citasMes.length} citas registradas en el mes actual.
                </p>
              </div>
            </div>
          </div>
        </aside>
      </div>
      </>
      ) : null}
    </section>
  )
}
