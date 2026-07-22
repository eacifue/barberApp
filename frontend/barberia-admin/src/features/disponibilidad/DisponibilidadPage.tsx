import { useEffect, useMemo, useState } from 'react'
import { useQuery } from '@tanstack/react-query'

import { useBarberias } from '../../hooks/useBarberias'
import { useTenantBarberia } from '../../hooks/useTenantBarberia'
import { barberoService } from '../../services/barberoService'
import { citaService } from '../../services/citaService'
import type { SlotDisponible } from '../../types/disponibilidad'
import { PageHeader } from '../../components/shared/PageHeader'
import { FormInput } from '../../components/ui/FormInput'
import { FormSelect } from '../../components/ui/FormSelect'
import { CreateCitaModal } from '../citas/CreateCitaModal'

type WeeklyDayData = {
  date: string
  slots: SlotDisponible[]
  citas: Array<{ horaInicio: string; clienteNombre: string }>
}

type WeeklyData = {
  fetchedAt: number
  days: WeeklyDayData[]
}

type CreateTarget = {
  barberiaId: string
  barberoId: string
  servicioId: string
  fecha: string
  hora: string
}

const weekLabels = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab']

function normalizeTime(value: string) {
  return value.slice(0, 5)
}

function getMonday(dateIso: string) {
  const date = new Date(`${dateIso}T00:00:00`)
  const day = date.getDay()
  const offset = day === 0 ? -6 : 1 - day
  const monday = new Date(date)
  monday.setDate(date.getDate() + offset)
  return monday
}

function getWeekDates(dateIso: string) {
  const monday = getMonday(dateIso)
  return Array.from({ length: 6 }).map((_, index) => {
    const date = new Date(monday)
    date.setDate(monday.getDate() + index)
    return date.toISOString().slice(0, 10)
  })
}

function fallbackHours() {
  const list: string[] = []
  for (let hour = 8; hour <= 19; hour += 1) {
    list.push(`${String(hour).padStart(2, '0')}:00`)
  }
  return list
}

function formatCountdown(slot: SlotDisponible, fetchedAt: number, nowMs: number) {
  const initial = slot.minutosRestantesBloqueo ?? 0
  const elapsedMinutes = Math.floor((nowMs - fetchedAt) / 60000)
  const remaining = Math.max(0, initial - elapsedMinutes)
  return `⏱ ${remaining}:00 min`
}

export function DisponibilidadPage() {
  const { canSelectBarberia, effectiveBarberiaId, tenantError } = useTenantBarberia()
  const todayIso = new Date().toISOString().slice(0, 10)
  const [selectedDate, setSelectedDate] = useState(todayIso)
  const [selectedDayInWeek, setSelectedDayInWeek] = useState(todayIso)
  const [createTarget, setCreateTarget] = useState<CreateTarget | null>(null)
  const [nowMs, setNowMs] = useState(Date.now())

  const { barberiasQuery } = useBarberias()
  const barberias = barberiasQuery.data ?? []
  const barberiaActualNombre = useMemo(() => {
    return barberias.find((barberia) => barberia.id === effectiveBarberiaId)?.nombre ?? '-'
  }, [barberias, effectiveBarberiaId])

  const [filters, setFilters] = useState({ barberoId: '', servicioId: '' })

  useEffect(() => {
    const timer = setInterval(() => setNowMs(Date.now()), 30000)
    return () => clearInterval(timer)
  }, [])

  const allBarberosQuery = useQuery({
    queryKey: ['barberos-all', barberias.map((b) => b.id).join(',')],
    enabled: barberias.length > 0,
    queryFn: async () => {
      const responses = await Promise.all(barberias.map((barberia) => barberoService.getByBarberia(barberia.id)))
      const merged = responses.flat().map((barbero) => ({ ...barbero, barberiaId: barbero.barberiaId || '' }))
      return merged
    },
  })

  const allBarberos = allBarberosQuery.data ?? []

  useEffect(() => {
    if (!filters.barberoId && allBarberos.length > 0) {
      const first = allBarberos[0]
      setFilters((prev) => ({ ...prev, barberoId: first.id, servicioId: first.servicios?.[0]?.id ?? '' }))
    }
  }, [allBarberos, filters.barberoId])

  const selectedBarbero = useMemo(
    () => allBarberos.find((barbero) => barbero.id === filters.barberoId),
    [allBarberos, filters.barberoId],
  )

  const servicios = selectedBarbero?.servicios ?? []

  useEffect(() => {
    if (servicios.length > 0 && !servicios.find((servicio) => servicio.id === filters.servicioId)) {
      setFilters((prev) => ({ ...prev, servicioId: servicios[0].id }))
    }
  }, [servicios, filters.servicioId])

  const weekDates = useMemo(() => getWeekDates(selectedDate), [selectedDate])

  useEffect(() => {
    if (!weekDates.includes(selectedDayInWeek)) {
      setSelectedDayInWeek(weekDates[0] ?? selectedDate)
    }
  }, [selectedDate, selectedDayInWeek, weekDates])

  const weeklyAvailabilityQuery = useQuery({
    queryKey: ['disponibilidad-week', filters.barberoId, filters.servicioId, weekDates.join('|')],
    enabled: Boolean(filters.barberoId && filters.servicioId && weekDates.length > 0),
    queryFn: async (): Promise<WeeklyData> => {
      const fetchedAt = Date.now()
      const dayResponses = await Promise.all(
        weekDates.map(async (date) => {
          try {
            const [disponibilidad, citas] = await Promise.all([
              citaService.getDisponibilidad(filters.barberoId, filters.servicioId, date),
              citaService.getByBarbero(filters.barberoId, date),
            ])

            const citasSimple = (citas ?? []).map((cita) => ({
              horaInicio: normalizeTime(cita.horaInicio),
              clienteNombre: `${cita.cliente.nombre} ${cita.cliente.apellido}`,
            }))

            const slots = (disponibilidad.slots ?? []).map((slot) => ({
              horaInicio: normalizeTime(slot.horaInicio),
              horaFin: normalizeTime(slot.horaFin),
              disponible: slot.disponible,
              bloqueadoPorRedis: slot.bloqueadoPorRedis,
              minutosRestantesBloqueo: slot.minutosRestantesBloqueo,
            }))

            return { date, slots, citas: citasSimple }
          } catch {
            // Un día puntual sin disponibilidad (p. ej. una fecha ya pasada, que
            // el backend rechaza) no debe tumbar la semana completa.
            return { date, slots: [], citas: [] }
          }
        }),
      )

      return { fetchedAt, days: dayResponses }
    },
  })

  const weeklyData = weeklyAvailabilityQuery.data

  const hours = useMemo(() => {
    const merged = (weeklyData?.days ?? []).flatMap((day) => day.slots.map((slot) => slot.horaInicio))
    const unique = Array.from(new Set(merged)).sort()
    return unique.length > 0 ? unique : fallbackHours()
  }, [weeklyData])

  const dayMap = useMemo(() => {
    const map = new Map<string, WeeklyDayData>()
    for (const day of weeklyData?.days ?? []) {
      map.set(day.date, day)
    }
    return map
  }, [weeklyData])

  const selectedDayData = dayMap.get(selectedDayInWeek)

  const onCreateFromCell = (date: string, hour: string) => {
    if (!selectedBarbero) return
    setCreateTarget({
      barberiaId: selectedBarbero.barberiaId,
      barberoId: selectedBarbero.id,
      servicioId: filters.servicioId,
      fecha: date,
      hora: hour,
    })
  }

  return (
    <section className="relative">
      {tenantError ? (
        <div className="mb-4 rounded-lg border border-[var(--danger)]/25 bg-[var(--danger-soft)] px-4 py-3 text-sm text-[var(--danger)]">
          {tenantError}
        </div>
      ) : null}

      <PageHeader title="Disponibilidad" subtitle="Vista semanal operativa y slots del dia" />

      {!canSelectBarberia ? (
        <p className="mb-3 text-sm text-color-muted">
          Barbería actual: <span className="font-medium text-color-base">{barberiaActualNombre}</span>
        </p>
      ) : null}

      <div className="mb-4 grid gap-3 rounded-xl border border-[var(--border2)] bg-[var(--surface2)] p-4 md:grid-cols-3">
        <FormSelect
          label="Barbero"
          value={filters.barberoId}
          onChange={(e) => setFilters({ barberoId: e.target.value, servicioId: '' })}
          options={allBarberos.map((barbero) => ({ value: barbero.id, label: `${barbero.nombre} ${barbero.apellido}` }))}
        />
        <FormSelect
          label="Servicio"
          value={filters.servicioId}
          onChange={(e) => setFilters((prev) => ({ ...prev, servicioId: e.target.value }))}
          options={servicios.map((servicio) => ({ value: servicio.id, label: servicio.nombre }))}
        />
        <FormInput
          label="Fecha"
          type="date"
          value={selectedDate}
          onChange={(e) => setSelectedDate(e.target.value)}
        />
      </div>

      <div className="mb-4 flex flex-wrap items-center gap-3 text-xs text-color-base">
        <span className="inline-flex items-center gap-1.5"><span className="h-3 w-3 rounded bg-[var(--success)]" />Verde = Disponible</span>
        <span className="inline-flex items-center gap-1.5"><span className="h-3 w-3 rounded bg-[var(--danger)]" />Rojo = Ocupado</span>
        <span className="inline-flex items-center gap-1.5"><span className="h-3 w-3 rounded bg-[var(--info)]" />Azul = Redis activo</span>
        <span className="inline-flex items-center gap-1.5"><span className="h-3 w-3 rounded bg-[var(--warning)]" />Amarillo = Bloqueado manual</span>
      </div>

      <div className="overflow-x-auto rounded-xl border border-[var(--border2)] bg-[var(--surface2)]">
        <div className="min-w-[860px]">
          <div className="grid grid-cols-[90px_repeat(6,minmax(120px,1fr))] border-b border-[var(--border)] bg-[var(--ink2)]">
            <div className="px-2 py-2 text-[10px] uppercase tracking-[0.08em] text-color-muted">Hora</div>
            {weekDates.map((date, idx) => (
              <button
                type="button"
                key={date}
                onClick={() => setSelectedDayInWeek(date)}
                className={[
                  'px-2 py-2 text-left text-[10px] uppercase tracking-[0.08em] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-[var(--focus-ring)]',
                  selectedDayInWeek === date
                    ? 'bg-[var(--accent-soft)] text-[var(--accent-strong)]'
                    : 'text-color-muted hover:bg-[var(--surface-hover)]',
                ].join(' ')}
              >
                {weekLabels[idx]}
                <div className="text-[11px] normal-case text-color-muted">{date.slice(5)}</div>
              </button>
            ))}
          </div>

          {hours.map((hour) => (
            <div key={hour} className="grid grid-cols-[90px_repeat(6,minmax(120px,1fr))] border-b border-[var(--border)] last:border-b-0">
              <div className="px-2 py-2 text-xs text-color-muted">{hour}</div>
              {weekDates.map((date) => {
                const day = dayMap.get(date)
                const slot = day?.slots.find((item) => normalizeTime(item.horaInicio) === hour)
                const cita = day?.citas.find((item) => normalizeTime(item.horaInicio) === hour)

                if (!slot) {
                  return <div key={`${date}-${hour}`} className="px-2 py-2 text-[11px] text-color-faint">-</div>
                }

                if (slot.bloqueadoPorRedis) {
                  return (
                    <div key={`${date}-${hour}`} className="p-1.5">
                      <div className="rounded-md bg-[var(--info-soft)] px-2 py-1 text-[11px] text-[var(--info)]">
                        {formatCountdown(slot, weeklyData?.fetchedAt ?? Date.now(), nowMs)}
                      </div>
                    </div>
                  )
                }

                if (slot.disponible) {
                  return (
                    <div key={`${date}-${hour}`} className="p-1.5">
                      <button
                        type="button"
                        onClick={() => onCreateFromCell(date, hour)}
                        className="w-full rounded-md bg-[var(--success-soft)] px-2 py-1 text-[11px] text-[var(--success)] hover:opacity-80 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--focus-ring)]"
                      >
                        Libre
                      </button>
                    </div>
                  )
                }

                if (cita) {
                  return (
                    <div key={`${date}-${hour}`} className="p-1.5">
                      <div className="rounded-md bg-[var(--danger-soft)] px-2 py-1 text-[11px] text-[var(--danger)]">{cita.clienteNombre}</div>
                    </div>
                  )
                }

                return (
                  <div key={`${date}-${hour}`} className="p-1.5">
                    <div className="rounded-md bg-[var(--warning-soft)] px-2 py-1 text-[11px] text-[var(--warning)]">Bloqueado</div>
                  </div>
                )
              })}
            </div>
          ))}
        </div>
      </div>

      <div className="mt-5 rounded-xl border border-[var(--border2)] bg-[var(--surface2)] p-4">
        <div className="mb-3 flex items-center justify-between">
          <h2 className="text-sm font-semibold text-color-base">Slots del dia seleccionado</h2>
          <span className="text-xs text-color-muted">{selectedDayInWeek}</span>
        </div>
        <div className="flex flex-wrap gap-2">
          {(selectedDayData?.slots ?? []).map((slot) => {
            const baseClass =
              slot.bloqueadoPorRedis
                ? 'bg-[var(--info-soft)] text-[var(--info)]'
                : slot.disponible
                  ? 'bg-[var(--success-soft)] text-[var(--success)]'
                  : 'bg-[var(--surface-strong)] text-color-base'

            return (
              <button
                type="button"
                key={`${slot.horaInicio}-${slot.horaFin}`}
                onClick={() => {
                  if (slot.disponible && !slot.bloqueadoPorRedis) {
                    onCreateFromCell(selectedDayInWeek, normalizeTime(slot.horaInicio))
                  }
                }}
                className={[
                  'inline-flex h-[30px] items-center justify-center rounded px-2 text-xs focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--focus-ring)]',
                  baseClass,
                ].join(' ')}
              >
                {normalizeTime(slot.horaInicio)}
              </button>
            )
          })}
          {(selectedDayData?.slots ?? []).length === 0 ? (
            <p className="text-sm text-color-muted">No hay slots para este dia.</p>
          ) : null}
        </div>
      </div>

      <CreateCitaModal
        open={createTarget !== null}
        onClose={() => setCreateTarget(null)}
        initialBarberiaId={createTarget?.barberiaId}
        initialBarberoId={createTarget?.barberoId}
        initialServicioId={createTarget?.servicioId}
        initialFecha={createTarget?.fecha}
        initialHora={createTarget?.hora}
      />
    </section>
  )
}
