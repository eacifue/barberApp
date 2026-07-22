import { useEffect, useMemo, useState } from 'react'
import { useQuery } from '@tanstack/react-query'

import { useBarberias } from '../../hooks/useBarberias'
import { useTenantBarberia } from '../../hooks/useTenantBarberia'
import { useAvailability } from '../../hooks/useAvailability'
import { useBarberos } from '../../hooks/useBarberos'
import { useServicios } from '../../hooks/useServicios'
import { citaService } from '../../services/citaService'
import type { AvailabilityDay, BarberAvailabilityInput } from '../../types/availability'
import type { Barbero, BarberoUpsertInput } from '../../types/barbero'
import { PageHeader } from '../../components/shared/PageHeader'
import { Avatar } from '../../components/ui/Avatar'
import { Badge } from '../../components/ui/Badge'
import { Button } from '../../components/ui/Button'
import { ConfirmDialog } from '../../components/ui/ConfirmDialog'
import { DataTable } from '../../components/ui/DataTable'
import { FormInput } from '../../components/ui/FormInput'
import { FormSelect } from '../../components/ui/FormSelect'
import { Modal } from '../../components/ui/Modal'
import { toast } from '../../stores/toastStore'

const initialForm: BarberoUpsertInput = {
  barberiaId: '',
  nombre: '',
  apellido: '',
  telefono: '',
  correo: '',
  biografia: '',
  añosExperiencia: 0,
  especialidades: [],
  tokenFCM: '',
  disponible: true,
  activo: true,
  servicioIds: [],
}

const dayConfig: Array<{ key: AvailabilityDay; label: string }> = [
  { key: 'Monday', label: 'Lunes' },
  { key: 'Tuesday', label: 'Martes' },
  { key: 'Wednesday', label: 'Miercoles' },
  { key: 'Thursday', label: 'Jueves' },
  { key: 'Friday', label: 'Viernes' },
  { key: 'Saturday', label: 'Sabado' },
  { key: 'Sunday', label: 'Domingo' },
]

export function BarberosList() {
  const { canSelectBarberia, effectiveBarberiaId, setSelectedBarberiaId, tenantError } = useTenantBarberia()
  const { barberiasQuery } = useBarberias()
  const barberias = barberiasQuery.data ?? []

  const { barberosQuery, createMutation, updateMutation, removeMutation } = useBarberos(effectiveBarberiaId ?? '')

  const [openModal, setOpenModal] = useState(false)
  const [editing, setEditing] = useState<Barbero | null>(null)
  const [form, setForm] = useState<BarberoUpsertInput>(initialForm)
  const [specialityInput, setSpecialityInput] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [confirmTarget, setConfirmTarget] = useState<Barbero | null>(null)
  const [openAvailabilityModal, setOpenAvailabilityModal] = useState(false)
  const [availabilityTarget, setAvailabilityTarget] = useState<Barbero | null>(null)
  const [availabilityRows, setAvailabilityRows] = useState<BarberAvailabilityInput[]>([])
  const [dayOffDate, setDayOffDate] = useState('')
  const [dayOffReason, setDayOffReason] = useState('')

  const serviciosBarberiaId = openModal ? form.barberiaId : (effectiveBarberiaId ?? '')
  const { serviciosQuery } = useServicios(serviciosBarberiaId)
  const { availabilityQuery, upsertAvailabilityMutation, addDayOffMutation } = useAvailability(
    availabilityTarget?.id ?? '',
  )

  const todayIso = useMemo(() => new Date().toISOString().slice(0, 10), [])
  const citasHoyQuery = useQuery({
    queryKey: ['barberos-citas-hoy', todayIso],
    queryFn: () => citaService.getAdminList({ date: todayIso, page: 1, pageSize: 250 }),
  })
  const citasHoyPorBarbero = useMemo(() => {
    const map = new Map<string, number>()
    for (const cita of citasHoyQuery.data ?? []) {
      map.set(cita.barberoId, (map.get(cita.barberoId) ?? 0) + 1)
    }
    return map
  }, [citasHoyQuery.data])

  useEffect(() => {
    if (!canSelectBarberia) return
    if (!effectiveBarberiaId && barberias.length > 0) {
      setSelectedBarberiaId(barberias[0].id)
    }
  }, [barberias, canSelectBarberia, effectiveBarberiaId, setSelectedBarberiaId])

  const barberos = barberosQuery.data ?? []
  const servicios = serviciosQuery.data ?? []
  const isSaving = createMutation.isPending || updateMutation.isPending

  const barberiaOptions = barberias.map((b) => ({ label: b.nombre, value: b.id }))

  const selectedBarberiaName = useMemo(() => {
    return barberias.find((b) => b.id === effectiveBarberiaId)?.nombre ?? '-'
  }, [barberias, effectiveBarberiaId])

  const resetForm = () => {
    setOpenModal(false)
    setEditing(null)
    setForm({ ...initialForm, barberiaId: effectiveBarberiaId ?? '' })
    setSpecialityInput('')
    setError(null)
  }

  const openCreateModal = () => {
    setEditing(null)
    setForm({ ...initialForm, barberiaId: effectiveBarberiaId ?? '' })
    setSpecialityInput('')
    setError(null)
    setOpenModal(true)
  }

  const openEditModal = (barbero: Barbero) => {
    setEditing(barbero)
    setForm({
      barberiaId: barbero.barberiaId,
      nombre: barbero.nombre,
      apellido: barbero.apellido,
      telefono: barbero.telefono,
      correo: barbero.correo,
      biografia: barbero.biografia ?? '',
      añosExperiencia: barbero.añosExperiencia,
      especialidades: barbero.especialidades ?? [],
      tokenFCM: barbero.tokenFCM ?? '',
      disponible: barbero.disponible,
      activo: barbero.activo,
      servicioIds: (barbero.servicios ?? []).map((servicio) => servicio.id),
    })
    setSpecialityInput('')
    setError(null)
    setOpenModal(true)
  }

  const addSpeciality = (value: string) => {
    const normalized = value.trim()
    if (!normalized) return
    if (form.especialidades.includes(normalized)) return
    setForm((prev) => ({ ...prev, especialidades: [...prev.especialidades, normalized] }))
    setSpecialityInput('')
  }

  const removeSpeciality = (value: string) => {
    setForm((prev) => ({
      ...prev,
      especialidades: prev.especialidades.filter((item) => item !== value),
    }))
  }

  const onSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    setError(null)

    if (!form.nombre.trim() || !form.apellido.trim() || !form.correo.trim() || !form.barberiaId.trim()) {
      setError('Completa los campos obligatorios: Nombre, Apellido, Correo y Barberia.')
      return
    }

    if (!/^\d{7,15}$/.test(form.telefono.trim())) {
      setError('El teléfono debe contener solo dígitos y tener entre 7 y 15 caracteres.')
      return
    }

    if (form.servicioIds.length === 0) {
      setError('Debes asociar al menos un servicio.')
      return
    }

    try {
      if (editing) {
        await updateMutation.mutateAsync({ id: editing.id, data: form })
        toast.success(`Barbero "${form.nombre} ${form.apellido}" actualizado correctamente.`)
      } else {
        await createMutation.mutateAsync(form)
        toast.success(`Barbero "${form.nombre} ${form.apellido}" creado correctamente.`)
      }
      resetForm()
    } catch {
      setError('No se pudo guardar el barbero. Verifica datos e intenta de nuevo.')
    }
  }

  const onDelete = (barbero: Barbero) => {
    setConfirmTarget(barbero)
  }

  const openAvailability = (barbero: Barbero) => {
    setAvailabilityTarget(barbero)
    setOpenAvailabilityModal(true)
    setDayOffDate('')
    setDayOffReason('')
  }

  useEffect(() => {
    if (!openAvailabilityModal) return

    const current = availabilityQuery.data ?? []
    const rows = dayConfig.map((item) => {
      const found = current.find((x) => x.dayOfWeek === item.key)
      return {
        dayOfWeek: item.key,
        isActive: found?.isActive ?? (item.key !== 'Saturday' && item.key !== 'Sunday'),
        startTime: found?.startTime ?? '09:00',
        endTime: found?.endTime ?? '18:00',
      }
    })
    setAvailabilityRows(rows)
  }, [availabilityQuery.data, openAvailabilityModal])

  const saveAvailability = async () => {
    if (!availabilityTarget) return

    const hasInvalid = availabilityRows.some((row) => row.isActive && (!row.startTime || !row.endTime || row.startTime >= row.endTime))
    if (hasInvalid) {
      toast.error('Hay horarios invalidos. Verifica hora de inicio y fin.')
      return
    }

    await upsertAvailabilityMutation.mutateAsync({ availability: availabilityRows })
    toast.success(`Disponibilidad actualizada para ${availabilityTarget.nombre} ${availabilityTarget.apellido}.`)
  }

  const saveDayOff = async () => {
    if (!availabilityTarget || !dayOffDate) {
      toast.warning('Selecciona una fecha para marcar dia no disponible.')
      return
    }

    await addDayOffMutation.mutateAsync({
      date: dayOffDate,
      reason: dayOffReason.trim() || undefined,
    })

    setDayOffDate('')
    setDayOffReason('')
    toast.success('Dia no disponible registrado correctamente.')
  }

  const handleConfirmDelete = async () => {
    if (!confirmTarget) return
    try {
      await removeMutation.mutateAsync(confirmTarget.id)
      toast.success(`Barbero "${confirmTarget.nombre} ${confirmTarget.apellido}" eliminado.`)
    } catch {
      toast.error('No se pudo eliminar el barbero. Intenta de nuevo.')
    } finally {
      setConfirmTarget(null)
    }
  }

  return (
    <section className="relative">
      {tenantError ? (
        <div className="mb-4 rounded-lg border border-[var(--danger)]/25 bg-[var(--danger-soft)] px-4 py-3 text-sm text-[var(--danger)]">
          {tenantError}
        </div>
      ) : null}

      <PageHeader
        title="Barberos"
        subtitle="Administracion del equipo, perfiles y experiencia"
        actions={<Button onClick={openCreateModal}>Agregar barbero</Button>}
      />

      {canSelectBarberia ? (
        <div className="mb-4 max-w-sm">
          <FormSelect
            label="Filtrar por barberia"
            value={effectiveBarberiaId ?? ''}
            onChange={(e) => setSelectedBarberiaId(e.target.value || null)}
            options={
              barberiaOptions.length > 0
                ? barberiaOptions
                : [{ label: 'Sin barberias disponibles', value: '' }]
            }
          />
        </div>
      ) : null}

      <DataTable<Barbero>
        loading={barberosQuery.isLoading || barberiasQuery.isLoading}
        emptyMessage="No hay barberos para la barberia seleccionada"
        columns={[
          {
            key: 'perfil',
            header: 'Nombre',
            width: '1.7fr',
            render: (row) => (
              <div className="flex items-center gap-2.5">
                <Avatar
                  fotoUrl={row.fotoUrl}
                  nombre={row.nombre}
                  apellido={row.apellido}
                  size="md"
                  dashedFallback
                />
                <div>
                  <p className="text-sm text-color-strong">{row.nombre} {row.apellido}</p>
                  <p className="text-xs text-[var(--gold-l)]">Rating {row.ratingPromedio.toFixed(1)}</p>
                </div>
              </div>
            ),
          },
          {
            key: 'especialidades',
            header: 'Especialidades',
            width: '1.5fr',
            render: (row) => {
              const visible = row.especialidades.slice(0, 2)
              const hidden = row.especialidades.length - visible.length

              return (
                <div className="flex flex-wrap items-center gap-1.5">
                  {visible.map((item) => (
                    <span
                      key={item}
                      className="rounded-full bg-[rgba(184,134,11,.12)] px-2 py-0.5 text-xs text-[var(--gold-l)]"
                    >
                      {item}
                    </span>
                  ))}
                  {hidden > 0 ? (
                    <span className="rounded-full bg-[rgba(184,134,11,.12)] px-2 py-0.5 text-xs text-[var(--gold-l)]">
                      +{hidden} mas
                    </span>
                  ) : null}
                </div>
              )
            },
          },
          {
            key: 'barberiaNombre',
            header: 'Barberia',
            width: '1fr',
            render: (row) => row.barberiaNombre || selectedBarberiaName,
          },
          {
            key: 'citasHoy',
            header: 'Citas hoy',
            width: '0.8fr',
            render: (row) =>
              citasHoyQuery.isLoading ? (
                <span className="inline-block h-3.5 w-5 animate-pulse rounded bg-[var(--surface-hover)]" aria-hidden="true" />
              ) : (
                citasHoyPorBarbero.get(row.id) ?? 0
              ),
          },
          {
            key: 'estado',
            header: 'Estado',
            width: '1fr',
            render: (row) => {
              if (!row.activo) return <Badge variant="danger" dot>Inactivo</Badge>
              return row.disponible ? (
                <Badge variant="success" dot>Disponible</Badge>
              ) : (
                <Badge variant="warning" dot>No disponible</Badge>
              )
            },
          },
          {
            key: 'acciones',
            header: 'Acciones',
            width: '1fr',
            render: (row) => (
              <div className="flex items-center gap-2">
                <Button size="sm" variant="ghost" onClick={() => openEditModal(row)}>
                  Editar
                </Button>
                <Button size="sm" variant="ghost" onClick={() => openAvailability(row)}>
                  Disponibilidad
                </Button>
                <Button
                  size="sm"
                  variant="danger"
                  onClick={() => onDelete(row)}
                  loading={removeMutation.isPending}
                >
                  Eliminar
                </Button>
              </div>
            ),
          },
        ]}
        data={barberos}
      />

      <Modal open={openModal} onClose={resetForm} title={editing ? 'Editar barbero' : 'Nuevo barbero'} size="md">
        <form className="space-y-4" onSubmit={onSubmit}>
          <div className="grid grid-cols-1 gap-3 md:grid-cols-2">
            <FormInput
              label="Nombre"
              required
              value={form.nombre}
              onChange={(e) => setForm((prev) => ({ ...prev, nombre: e.target.value }))}
            />
            <FormInput
              label="Apellido"
              required
              value={form.apellido}
              onChange={(e) => setForm((prev) => ({ ...prev, apellido: e.target.value }))}
            />
            <FormInput
              label="Correo"
              type="email"
              required
              value={form.correo}
              onChange={(e) => setForm((prev) => ({ ...prev, correo: e.target.value }))}
            />
            <FormInput
              label="Telefono"
              required
              value={form.telefono}
              onChange={(e) =>
                setForm((prev) => ({ ...prev, telefono: e.target.value.replace(/\D/g, '') }))
              }
            />
            {canSelectBarberia ? (
              <FormSelect
                label="Barberia"
                required
                value={form.barberiaId}
                onChange={(e) =>
                  setForm((prev) => ({ ...prev, barberiaId: e.target.value, servicioIds: [] }))
                }
                options={barberiaOptions}
              />
            ) : null}
            <FormInput
              label="Anios experiencia"
              type="number"
              min={0}
              value={form.añosExperiencia}
              onChange={(e) => setForm((prev) => ({ ...prev, añosExperiencia: Number(e.target.value || 0) }))}
            />

            <div className="md:col-span-2">
              <p className="mb-1.5 text-[10px] uppercase tracking-[0.08em] text-[var(--text-muted)]">
                Servicios asociados *
              </p>
              <div className="rounded-md border border-[0.5px] border-[var(--border2)] bg-[var(--surface3)] px-2 py-2">
                {servicios.length === 0 ? (
                  <p className="text-xs text-color-muted">
                    No hay servicios activos para la barbería seleccionada.
                  </p>
                ) : (
                  <div className="grid grid-cols-1 gap-1.5 md:grid-cols-2">
                    {servicios.map((servicio) => {
                      const checked = form.servicioIds.includes(servicio.id)
                      return (
                        <label
                          key={servicio.id}
                          className="inline-flex cursor-pointer items-center gap-2 rounded-md px-2 py-1 text-sm text-color-base hover:bg-white/5"
                        >
                          <input
                            type="checkbox"
                            checked={checked}
                            onChange={(e) => {
                              setForm((prev) => ({
                                ...prev,
                                servicioIds: e.target.checked
                                  ? [...prev.servicioIds, servicio.id]
                                  : prev.servicioIds.filter((id) => id !== servicio.id),
                              }))
                            }}
                          />
                          <span>{servicio.nombre}</span>
                        </label>
                      )
                    })}
                  </div>
                )}
              </div>
            </div>

            <div className="md:col-span-2">
              <p className="mb-1.5 text-[10px] uppercase tracking-[0.08em] text-[var(--text-muted)]">Especialidades</p>
              <div className="rounded-md border border-[0.5px] border-[var(--border2)] bg-[var(--surface3)] px-2 py-2">
                <div className="mb-2 flex flex-wrap gap-1.5">
                  {form.especialidades.map((item) => (
                    <button
                      type="button"
                      key={item}
                      onClick={() => removeSpeciality(item)}
                      className="rounded-full bg-[rgba(184,134,11,.12)] px-2 py-0.5 text-xs text-[var(--gold-l)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--focus-ring)]"
                      title="Quitar"
                    >
                      {item} x
                    </button>
                  ))}
                </div>
                <input
                  value={specialityInput}
                  onChange={(e) => setSpecialityInput(e.target.value)}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter' || e.key === ',') {
                      e.preventDefault()
                      addSpeciality(specialityInput)
                    }
                  }}
                  onBlur={() => addSpeciality(specialityInput)}
                  placeholder="Escribe y presiona Enter"
                  className="form-control w-full rounded-md border-none bg-transparent px-0 text-sm outline-none"
                />
              </div>
            </div>

            <label className="md:col-span-2 flex flex-col gap-1.5">
              <span className="form-label text-[10px] uppercase tracking-[0.08em]">Biografia</span>
              <textarea
                value={form.biografia ?? ''}
                onChange={(e) => setForm((prev) => ({ ...prev, biografia: e.target.value }))}
                className="form-control min-h-24 rounded-md px-3 py-2 outline-none"
              />
            </label>

            <label className="form-check-label inline-flex items-center gap-2 text-sm">
              <input
                type="checkbox"
                checked={form.disponible}
                onChange={(e) => setForm((prev) => ({ ...prev, disponible: e.target.checked }))}
              />
              Disponible
            </label>

            <label className="form-check-label inline-flex items-center gap-2 text-sm">
              <input
                type="checkbox"
                checked={form.activo}
                onChange={(e) => setForm((prev) => ({ ...prev, activo: e.target.checked }))}
              />
              Activo
            </label>
          </div>

          {error ? <p className="form-message-error text-sm">{error}</p> : null}

          <div className="flex justify-end gap-2">
            <Button variant="ghost" onClick={resetForm}>
              Cancelar
            </Button>
            <Button type="submit" loading={isSaving}>
              {editing ? 'Guardar cambios' : 'Crear barbero'}
            </Button>
          </div>
        </form>
      </Modal>

      <ConfirmDialog
        open={confirmTarget !== null}
        onClose={() => setConfirmTarget(null)}
        onConfirm={handleConfirmDelete}
        loading={removeMutation.isPending}
        variant="danger"
        title="Eliminar barbero"
        message={`¿Estás seguro de que deseas eliminar a "${confirmTarget?.nombre} ${confirmTarget?.apellido}"? Esta acción no se puede deshacer.`}
      />

      <Modal
        open={openAvailabilityModal}
        onClose={() => {
          setOpenAvailabilityModal(false)
          setAvailabilityTarget(null)
          setAvailabilityRows([])
        }}
        title={`Disponibilidad de ${availabilityTarget?.nombre ?? ''} ${availabilityTarget?.apellido ?? ''}`}
        size="md"
      >
        <div className="space-y-4">
          <div className="rounded-md border border-[0.5px] border-[var(--border2)] bg-[var(--surface3)] p-3">
            <p className="mb-2 text-xs uppercase tracking-[0.08em] text-[var(--text-muted)]">Horario semanal</p>
            <div className="space-y-2">
              {dayConfig.map((day) => {
                const row = availabilityRows.find((x) => x.dayOfWeek === day.key)
                if (!row) return null

                return (
                  <div key={day.key} className="grid grid-cols-12 items-center gap-2 rounded-md bg-[var(--surface-hover)] p-2">
                    <div className="col-span-3 text-sm text-color-base">{day.label}</div>
                    <label className="col-span-2 inline-flex items-center gap-1 text-xs text-color-muted">
                      <input
                        type="checkbox"
                        checked={row.isActive}
                        onChange={(e) => {
                          setAvailabilityRows((prev) =>
                            prev.map((item) =>
                              item.dayOfWeek === day.key ? { ...item, isActive: e.target.checked } : item,
                            ),
                          )
                        }}
                      />
                      Activo
                    </label>
                    <div className="col-span-3">
                      <FormInput
                        label="Inicio"
                        type="time"
                        value={row.startTime ?? ''}
                        onChange={(e) => {
                          const value = e.target.value
                          setAvailabilityRows((prev) =>
                            prev.map((item) =>
                              item.dayOfWeek === day.key ? { ...item, startTime: value } : item,
                            ),
                          )
                        }}
                        disabled={!row.isActive}
                      />
                    </div>
                    <div className="col-span-3">
                      <FormInput
                        label="Fin"
                        type="time"
                        value={row.endTime ?? ''}
                        onChange={(e) => {
                          const value = e.target.value
                          setAvailabilityRows((prev) =>
                            prev.map((item) =>
                              item.dayOfWeek === day.key ? { ...item, endTime: value } : item,
                            ),
                          )
                        }}
                        disabled={!row.isActive}
                      />
                    </div>
                  </div>
                )
              })}
            </div>

            <div className="mt-3 flex justify-end">
              <Button onClick={saveAvailability} loading={upsertAvailabilityMutation.isPending}>
                Guardar horario
              </Button>
            </div>
          </div>

          <div className="rounded-md border border-[0.5px] border-[var(--border2)] bg-[var(--surface3)] p-3">
            <p className="mb-2 text-xs uppercase tracking-[0.08em] text-[var(--text-muted)]">Dias no disponibles</p>
            <div className="grid grid-cols-1 gap-2 md:grid-cols-2">
              <FormInput label="Fecha" type="date" value={dayOffDate} onChange={(e) => setDayOffDate(e.target.value)} />
              <FormInput
                label="Motivo (opcional)"
                value={dayOffReason}
                onChange={(e) => setDayOffReason(e.target.value)}
                placeholder="Vacaciones, incapacidad, etc"
              />
            </div>
            <div className="mt-3 flex justify-end">
              <Button onClick={saveDayOff} loading={addDayOffMutation.isPending}>
                Guardar dia no disponible
              </Button>
            </div>
          </div>
        </div>
      </Modal>
    </section>
  )
}
