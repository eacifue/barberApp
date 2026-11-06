import { useEffect, useMemo, useState } from 'react'
import { useInfiniteQuery, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useSearchParams } from 'react-router-dom'

import { PageHeader } from '../../components/shared/PageHeader'
import { Badge } from '../../components/ui/Badge'
import { Button } from '../../components/ui/Button'
import { FormInput } from '../../components/ui/FormInput'
import { FormSelect } from '../../components/ui/FormSelect'
import { Modal } from '../../components/ui/Modal'
import { useBarberos } from '../../hooks/useBarberos'
import { useTenantBarberia } from '../../hooks/useTenantBarberia'
import { citaService } from '../../services/citaService'
import { toast } from '../../stores/toastStore'
import type { Cita, EstadoCita } from '../../types/cita'
import { CreateCitaModal } from './CreateCitaModal'

type SchedulerView = 'day' | 'week' | 'history'

const historyPageSize = 25

const estadoOptions: Array<{ value: string; label: string }> = [
  { value: '', label: 'Todos los estados' },
  { value: 'Pendiente', label: 'Pendiente' },
  { value: 'Confirmada', label: 'Confirmada' },
  { value: 'Completada', label: 'Completada' },
  { value: 'Cancelada', label: 'Cancelada' },
]

function toIsoDate(date: Date) {
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
}

function getTodayIso() {
  return toIsoDate(new Date())
}

function getYesterdayIso() {
  const date = new Date()
  date.setDate(date.getDate() - 1)
  return toIsoDate(date)
}

function getMonday(isoDate: string) {
  const current = new Date(`${isoDate}T00:00:00`)
  const day = current.getDay()
  const mondayOffset = day === 0 ? -6 : 1 - day
  const monday = new Date(current)
  monday.setDate(current.getDate() + mondayOffset)
  return monday
}

function getWeekRange(isoDate: string) {
  const monday = getMonday(isoDate)
  const sunday = new Date(monday)
  sunday.setDate(monday.getDate() + 6)
  return {
    from: toIsoDate(monday),
    to: toIsoDate(sunday),
  }
}

function getWeekDates(isoDate: string) {
  const monday = getMonday(isoDate)
  return Array.from({ length: 7 }).map((_, index) => {
    const date = new Date(monday)
    date.setDate(monday.getDate() + index)
    return toIsoDate(date)
  })
}

function addDays(isoDate: string, days: number) {
  const date = new Date(`${isoDate}T00:00:00`)
  date.setDate(date.getDate() + days)
  return toIsoDate(date)
}

function getEstadoVariant(estado: EstadoCita) {
  if (estado === 'Confirmada') return 'info'
  if (estado === 'Completada') return 'success'
  if (estado === 'Cancelada') return 'danger'
  return 'muted'
}

function normalizeHour(time: string) {
  return time.slice(0, 5)
}

function compareDateTimeAsc(a: Cita, b: Cita) {
  const left = `${a.fechaCita}T${normalizeHour(a.horaInicio)}`
  const right = `${b.fechaCita}T${normalizeHour(b.horaInicio)}`
  return left.localeCompare(right)
}

function compareDateTimeDesc(a: Cita, b: Cita) {
  return compareDateTimeAsc(b, a)
}

function formatMoney(value: number) {
  return `$${Math.round(value).toLocaleString('es-CO')}`
}

function AppointmentCard({
  cita,
  onConfirm,
  onComplete,
  onCancel,
  onDetail,
  loading,
}: {
  cita: Cita
  onConfirm: (id: string) => void
  onComplete: (id: string) => void
  onCancel: (id: string) => void
  onDetail: (cita: Cita) => void
  loading: boolean
}) {
  const canConfirm = cita.estado === 'Pendiente'
  const canComplete = cita.estado === 'Confirmada' || cita.estado === 'EnProgreso'
  const canCancel = cita.estado === 'Pendiente' || cita.estado === 'Confirmada'

  return (
    <article className="rounded-xl border border-[var(--border2)] bg-[var(--surface2)] p-3 transition hover:border-brass-ink">
      <div className="mb-2 flex items-center justify-between gap-2">
        <p className="truncate font-mono text-xs text-ink">
          {normalizeHour(cita.horaInicio)}–{normalizeHour(cita.horaFin)}
        </p>
        <Badge variant={getEstadoVariant(cita.estado)}>{cita.estado}</Badge>
      </div>
      <p className="truncate text-sm font-medium text-ink">
        {cita.cliente.nombre} {cita.cliente.apellido}
      </p>
      <p className="mt-1 truncate text-xs text-ink-muted">Barbero: {cita.barbero.nombre} {cita.barbero.apellido}</p>
      <p className="truncate text-xs text-ink-muted">Servicio: {cita.servicio.nombre}</p>
      <div className="mt-3 flex items-center gap-1.5">
        {canConfirm ? (
          <Button size="sm" variant="gold" className="h-7 flex-1 px-2 text-[11px]" onClick={() => onConfirm(cita.id)} loading={loading}>
            Confirmar
          </Button>
        ) : null}
        {canComplete ? (
          <Button size="sm" variant="gold" className="h-7 flex-1 px-2 text-[11px]" onClick={() => onComplete(cita.id)} loading={loading}>
            Completar
          </Button>
        ) : null}
        <Button
          size="sm"
          variant="ghost"
          className="h-7 w-7 shrink-0 px-0 text-[11px]"
          title="Ver detalle"
          aria-label="Ver detalle"
          onClick={() => onDetail(cita)}
        >
          ⋯
        </Button>
        {canCancel ? (
          <Button
            size="sm"
            variant="danger"
            className="h-7 w-7 shrink-0 px-0 text-[11px]"
            title="Cancelar"
            aria-label="Cancelar"
            onClick={() => onCancel(cita.id)}
            loading={loading}
          >
            ✕
          </Button>
        ) : null}
      </div>
    </article>
  )
}

export function AppointmentsScheduler() {
  const queryClient = useQueryClient()
  const [searchParams] = useSearchParams()
  const todayIso = useMemo(() => getTodayIso(), [])
  const yesterdayIso = useMemo(() => getYesterdayIso(), [])
  const queryFecha = searchParams.get('fecha')
  const initialDate = queryFecha && /^\d{4}-\d{2}-\d{2}$/.test(queryFecha) ? queryFecha : todayIso

  const { effectiveBarberiaId, tenantError } = useTenantBarberia()

  const [view, setView] = useState<SchedulerView>('week')
  const [selectedDate, setSelectedDate] = useState(initialDate)
  const [fromDate, setFromDate] = useState('')
  const [toDate, setToDate] = useState('')
  const [selectedBarberoId, setSelectedBarberoId] = useState('')
  const [status, setStatus] = useState('')
  const [openCreateModal, setOpenCreateModal] = useState(false)
  const [detailCita, setDetailCita] = useState<Cita | null>(null)

  const { barberosQuery } = useBarberos(effectiveBarberiaId ?? '')
  const barberos = barberosQuery.data ?? []

  useEffect(() => {
    if (!selectedBarberoId || !barberos.some((x) => x.id === selectedBarberoId)) {
      setSelectedBarberoId('')
    }
  }, [barberos, selectedBarberoId])

  const weekRange = useMemo(() => getWeekRange(selectedDate), [selectedDate])
  const weekDates = useMemo(() => getWeekDates(selectedDate), [selectedDate])

  const dateFilter = useMemo(() => {
    if (view === 'day') {
      return { date: selectedDate, from: undefined, to: undefined }
    }

    if (view === 'week') {
      return { date: undefined, from: weekRange.from, to: weekRange.to }
    }

    const historyFrom = fromDate || undefined
    const historyTo = toDate || yesterdayIso
    return { date: undefined, from: historyFrom, to: historyTo }
  }, [view, selectedDate, weekRange.from, weekRange.to, fromDate, toDate, yesterdayIso])

  const schedulerEnabled = Boolean(effectiveBarberiaId) && view !== 'history'

  const upcomingAnchorQuery = useQuery({
    queryKey: ['appointments-anchor', effectiveBarberiaId],
    enabled: Boolean(effectiveBarberiaId),
    queryFn: () =>
      citaService.getAdminList({
        from: todayIso,
        to: addDays(todayIso, 60),
        status: 'Pendiente',
        page: 1,
        pageSize: 1,
      }),
  })

  const schedulerQuery = useQuery({
    queryKey: [
      'appointments-scheduler',
      view,
      effectiveBarberiaId,
      selectedBarberoId || 'all',
      status || 'all',
      dateFilter.date || '-',
      dateFilter.from || '-',
      dateFilter.to || '-',
    ],
    enabled: schedulerEnabled,
    queryFn: () =>
      citaService.getAdminList({
        barberoId: selectedBarberoId || undefined,
        date: dateFilter.date,
        from: dateFilter.from,
        to: dateFilter.to,
        status: status || undefined,
        page: 1,
        pageSize: 250,
      }),
  })

  const historyQuery = useInfiniteQuery({
    queryKey: [
      'appointments-history',
      effectiveBarberiaId,
      selectedBarberoId || 'all',
      status || 'all',
      dateFilter.from || '-',
      dateFilter.to || '-',
    ],
    enabled: Boolean(effectiveBarberiaId) && view === 'history',
    initialPageParam: 1,
    queryFn: ({ pageParam }) =>
      citaService.getAdminList({
        barberoId: selectedBarberoId || undefined,
        from: dateFilter.from,
        to: dateFilter.to,
        status: status || undefined,
        page: pageParam,
        pageSize: historyPageSize,
      }),
    getNextPageParam: (lastPage, pages) => {
      if (lastPage.length < historyPageSize) return undefined
      return pages.length + 1
    },
  })

  const dayCitas = useMemo(() => {
    return (schedulerQuery.data ?? []).slice().sort(compareDateTimeAsc)
  }, [schedulerQuery.data])

  const weekMap = useMemo(() => {
    const map = new Map<string, Cita[]>()
    for (const date of weekDates) {
      map.set(date, [])
    }

    for (const cita of schedulerQuery.data ?? []) {
      if (!map.has(cita.fechaCita)) continue
      map.get(cita.fechaCita)?.push(cita)
    }

    for (const [, list] of map) {
      list.sort(compareDateTimeAsc)
    }

    return map
  }, [schedulerQuery.data, weekDates])

  const historyCitas = useMemo(() => {
    return (historyQuery.data?.pages ?? []).flat().slice().sort(compareDateTimeDesc)
  }, [historyQuery.data?.pages])

  useEffect(() => {
    if (queryFecha) return
    const firstUpcoming = upcomingAnchorQuery.data?.[0]
    if (!firstUpcoming) return
    if (selectedDate === todayIso && firstUpcoming.fechaCita !== todayIso) {
      setSelectedDate(firstUpcoming.fechaCita)
    }
  }, [queryFecha, upcomingAnchorQuery.data, selectedDate, todayIso])

  const refreshAgenda = async () => {
    await queryClient.invalidateQueries({ queryKey: ['appointments-scheduler'] })
    await queryClient.invalidateQueries({ queryKey: ['appointments-history'] })
  }

  const confirmMutation = useMutation({
    mutationFn: (id: string) => citaService.confirm(id),
    onSuccess: async () => {
      toast.success('Cita confirmada correctamente.')
      await refreshAgenda()
    },
    onError: () => {
      toast.error('No se pudo confirmar la cita.')
    },
  })

  const completeMutation = useMutation({
    mutationFn: (id: string) => citaService.complete(id),
    onSuccess: async () => {
      toast.success('Cita completada correctamente.')
      await refreshAgenda()
    },
    onError: () => {
      toast.error('No se pudo completar la cita.')
    },
  })

  const cancelMutation = useMutation({
    mutationFn: (id: string) => citaService.cancel(id, { citaId: id, motivo: 'Cancelada desde la agenda' }),
    onSuccess: async () => {
      toast.success('Cita cancelada correctamente.')
      await refreshAgenda()
    },
    onError: () => {
      toast.error('No se pudo cancelar la cita.')
    },
  })

  const isUpdatingAppointment = confirmMutation.isPending || completeMutation.isPending || cancelMutation.isPending

  return (
    <section className="relative">
      {tenantError ? (
        <div className="mb-4 rounded-lg border border-[var(--danger)]/25 bg-[var(--danger-soft)] px-4 py-3 text-sm text-[var(--danger)]">
          {tenantError}
        </div>
      ) : null}

      <PageHeader
        title="Agenda"
        subtitle="Planificación de citas por día, semana e historial"
        actions={
          <div className="flex flex-wrap items-center gap-2">
            <Button size="sm" variant="ghost" onClick={() => setSelectedDate((prev) => addDays(prev, -7))}>
              Semana -
            </Button>
            <Button size="sm" variant="ghost" onClick={() => setSelectedDate((prev) => addDays(prev, 7))}>
              Semana +
            </Button>
            <Button size="sm" variant={view === 'day' ? 'gold' : 'ghost'} onClick={() => setView('day')}>
              Día
            </Button>
            <Button size="sm" variant={view === 'week' ? 'gold' : 'ghost'} onClick={() => setView('week')}>
              Semana
            </Button>
            <Button size="sm" variant={view === 'history' ? 'gold' : 'ghost'} onClick={() => setView('history')}>
              Historial
            </Button>
            <Button onClick={() => setOpenCreateModal(true)}>Nueva cita</Button>
          </div>
        }
      />

      <div className="mb-5 grid gap-3 rounded-xl border border-[var(--border2)] bg-[var(--surface2)] p-4 sm:grid-cols-2 md:grid-cols-3 xl:grid-cols-6">
        <FormInput
          label="Fecha"
          type="date"
          value={selectedDate}
          onChange={(e) => setSelectedDate(e.target.value)}
        />

        <FormInput
          label="Desde"
          type="date"
          value={fromDate}
          onChange={(e) => setFromDate(e.target.value)}
        />

        <FormInput
          label="Hasta"
          type="date"
          value={toDate}
          onChange={(e) => setToDate(e.target.value)}
        />

        <FormSelect
          label="Barbero"
          value={selectedBarberoId}
          onChange={(e) => setSelectedBarberoId(e.target.value)}
          options={[
            { value: '', label: 'Todos los barberos' },
            ...barberos.map((barbero) => ({ value: barbero.id, label: `${barbero.nombre} ${barbero.apellido}` })),
          ]}
        />

        <FormSelect
          label="Estado"
          value={status}
          onChange={(e) => setStatus(e.target.value)}
          options={estadoOptions}
        />
      </div>

      {view === 'day' ? (
        <div className="grid gap-3">
          {schedulerQuery.isLoading ? <p className="text-sm text-ink-muted">Cargando agenda del día...</p> : null}
          {!schedulerQuery.isLoading && dayCitas.length === 0 ? (
            <p className="rounded-xl border border-[var(--border2)] bg-[var(--surface2)] p-4 text-sm text-ink-muted">
              No hay citas para el día seleccionado.
            </p>
          ) : null}
          {dayCitas.map((cita) => (
            <AppointmentCard
              key={cita.id}
              cita={cita}
              onConfirm={(id) => confirmMutation.mutate(id)}
              onComplete={(id) => completeMutation.mutate(id)}
              onCancel={(id) => cancelMutation.mutate(id)}
              onDetail={(cita) => setDetailCita(cita)}
              loading={isUpdatingAppointment}
            />
          ))}
        </div>
      ) : null}

      {view === 'week' ? (
        <div className="overflow-x-auto rounded-xl border border-[var(--border2)] bg-[var(--surface2)] p-3">
          <div className="grid auto-cols-[240px] grid-flow-col gap-3">
            {weekDates.map((date) => (
              <div key={date} className="rounded-lg border border-[var(--border)] bg-[var(--ink2)] p-2">
                <div className="mb-2 border-b border-[var(--border)] pb-2">
                  <p className="text-xs uppercase tracking-[0.08em] text-ink-muted">{date}</p>
                </div>
                <div className="max-h-[520px] space-y-2 overflow-y-auto pr-1">
                  {(weekMap.get(date) ?? []).map((cita) => (
                    <AppointmentCard
                      key={cita.id}
                      cita={cita}
                      onConfirm={(id) => confirmMutation.mutate(id)}
                      onComplete={(id) => completeMutation.mutate(id)}
                      onCancel={(id) => cancelMutation.mutate(id)}
                      onDetail={(cita) => setDetailCita(cita)}
                      loading={isUpdatingAppointment}
                    />
                  ))}
                  {(weekMap.get(date)?.length ?? 0) === 0 ? (
                    <p className="text-xs text-ink-muted">Sin citas</p>
                  ) : null}
                </div>
              </div>
            ))}
          </div>
        </div>
      ) : null}

      {view === 'history' ? (
        <div className="space-y-3">
          {historyQuery.isLoading ? <p className="text-sm text-ink-muted">Cargando historial...</p> : null}
          {!historyQuery.isLoading && historyCitas.length === 0 ? (
            <p className="rounded-xl border border-[var(--border2)] bg-[var(--surface2)] p-4 text-sm text-ink-muted">
              No hay citas en el historial para los filtros seleccionados.
            </p>
          ) : null}
          {historyCitas.map((cita) => (
            <AppointmentCard
              key={cita.id}
              cita={cita}
              onConfirm={(id) => confirmMutation.mutate(id)}
              onComplete={(id) => completeMutation.mutate(id)}
              onCancel={(id) => cancelMutation.mutate(id)}
              onDetail={(cita) => setDetailCita(cita)}
              loading={isUpdatingAppointment}
            />
          ))}
          {historyQuery.hasNextPage ? (
            <div className="flex justify-center pt-2">
              <Button variant="ghost" onClick={() => historyQuery.fetchNextPage()} disabled={historyQuery.isFetchingNextPage}>
                {historyQuery.isFetchingNextPage ? 'Cargando...' : 'Cargar más'}
              </Button>
            </div>
          ) : null}
        </div>
      ) : null}

      <CreateCitaModal
        open={openCreateModal}
        onClose={() => setOpenCreateModal(false)}
      />

      <Modal open={Boolean(detailCita)} onClose={() => setDetailCita(null)} title="Detalle de cita" size="md">
        {detailCita ? (
          <div className="space-y-2 text-sm text-ink">
            <p><strong>Cliente:</strong> {detailCita.cliente.nombre} {detailCita.cliente.apellido}</p>
            <p><strong>Barbero:</strong> {detailCita.barbero.nombre} {detailCita.barbero.apellido}</p>
            <p><strong>Servicio:</strong> {detailCita.servicio.nombre}</p>
            <p><strong>Fecha:</strong> {detailCita.fechaCita}</p>
            <p><strong>Horario:</strong> {normalizeHour(detailCita.horaInicio)} - {normalizeHour(detailCita.horaFin)}</p>
            <p><strong>Precio:</strong> {formatMoney(detailCita.precioFinal)}</p>
            <p><strong>Estado:</strong> {detailCita.estado}</p>
            {detailCita.notas ? <p><strong>Notas:</strong> {detailCita.notas}</p> : null}
          </div>
        ) : null}
      </Modal>
    </section>
  )
}
