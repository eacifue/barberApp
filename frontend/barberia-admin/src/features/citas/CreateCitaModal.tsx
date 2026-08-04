import { useEffect, useMemo, useState, type FormEvent } from 'react'
import { useMutation, useQueryClient } from '@tanstack/react-query'

import { useBarberos } from '../../hooks/useBarberos'
import { useClientes } from '../../hooks/useClientes'
import { useTenantBarberia } from '../../hooks/useTenantBarberia'
import { citaService } from '../../services/citaService'
import type { SlotDisponible } from '../../types/cita'
import { Button } from '../../components/ui/Button'
import { FormInput } from '../../components/ui/FormInput'
import { FormSelect } from '../../components/ui/FormSelect'
import { Modal } from '../../components/ui/Modal'

type CreateCitaForm = {
  barberoId: string
  servicioId: string
  fechaCita: string
  horaInicio: string
  clienteId: string
  notas: string
  precioFinal: number
}

type CreateCitaModalProps = {
  open: boolean
  onClose: () => void
  /** Se llama tras crear la cita con éxito, además de cerrar el modal — útil para refrescos propios del llamador. */
  onCreated?: () => void
  initialBarberoId?: string
  initialServicioId?: string
  initialFecha?: string
  initialHora?: string
}

function todayIso() {
  return new Date().toISOString().slice(0, 10)
}

function emptyForm(overrides: Partial<CreateCitaForm> = {}): CreateCitaForm {
  return {
    barberoId: '',
    servicioId: '',
    fechaCita: todayIso(),
    horaInicio: '',
    clienteId: '',
    notas: '',
    precioFinal: 0,
    ...overrides,
  }
}

/**
 * Formulario de creación de cita compartido por Agenda, Disponibilidad y el
 * historial de citas. Antes existían dos implementaciones independientes de
 * este mismo flujo (CitasList y DisponibilidadPage) que ya habían empezado a
 * divergir entre sí — ver auditoría UI/UX, hallazgo C-02.
 */
export function CreateCitaModal({
  open,
  onClose,
  onCreated,
  initialBarberoId,
  initialServicioId,
  initialFecha,
  initialHora,
}: CreateCitaModalProps) {
  const queryClient = useQueryClient()
  const { effectiveBarberiaId } = useTenantBarberia()
  const { clientesQuery } = useClientes()

  const clientes = clientesQuery.data ?? []

  const [form, setForm] = useState<CreateCitaForm>(() => emptyForm())
  const [searchCliente, setSearchCliente] = useState('')
  const [slotOptions, setSlotOptions] = useState<SlotDisponible[]>([])
  const [loadingSlots, setLoadingSlots] = useState(false)
  const [error, setError] = useState<string | null>(null)

  // Cada vez que se abre, se re-siembra con lo que traiga el llamador:
  // Disponibilidad pre-llena barbero/fecha/hora desde el slot en el que se
  // hizo clic; Agenda e Historial lo abren en blanco.
  useEffect(() => {
    if (!open) return
    setForm(
      emptyForm({
        barberoId: initialBarberoId ?? '',
        servicioId: initialServicioId ?? '',
        fechaCita: initialFecha ?? todayIso(),
        horaInicio: initialHora ?? '',
      }),
    )
    setSearchCliente('')
    setSlotOptions([])
    setError(null)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open])

  const { barberosQuery } = useBarberos(effectiveBarberiaId ?? '')
  const barberos = barberosQuery.data ?? []

  useEffect(() => {
    if (!open || barberos.length === 0) return
    if (!barberos.find((b) => b.id === form.barberoId)) {
      setForm((prev) => ({ ...prev, barberoId: barberos[0].id, servicioId: '', horaInicio: '' }))
    }
  }, [open, barberos, form.barberoId])

  const selectedBarbero = useMemo(
    () => barberos.find((barbero) => barbero.id === form.barberoId),
    [barberos, form.barberoId],
  )
  const servicios = useMemo(() => selectedBarbero?.servicios ?? [], [selectedBarbero])

  useEffect(() => {
    if (!open || servicios.length === 0) return
    if (!servicios.find((s) => s.id === form.servicioId)) {
      const servicio = servicios[0]
      setForm((prev) => ({ ...prev, servicioId: servicio.id, precioFinal: servicio.precio ?? 0, horaInicio: '' }))
    }
  }, [open, servicios, form.servicioId])

  const loadSlots = async () => {
    if (!form.barberoId || !form.servicioId || !form.fechaCita) return
    setLoadingSlots(true)
    setError(null)
    try {
      const disponibilidad = await citaService.getDisponibilidad(form.barberoId, form.servicioId, form.fechaCita)
      const available = (disponibilidad.slots ?? []).filter((slot) => slot.disponible && !slot.bloqueadoPorRedis)
      setSlotOptions(available)
      setForm((prev) => {
        const stillValid = available.some((slot) => slot.horaInicio === prev.horaInicio)
        return stillValid ? prev : { ...prev, horaInicio: available[0]?.horaInicio ?? '' }
      })
    } catch {
      setError('No fue posible cargar slots disponibles para el barbero.')
      setSlotOptions([])
    } finally {
      setLoadingSlots(false)
    }
  }

  useEffect(() => {
    if (open && form.barberoId && form.servicioId && form.fechaCita) {
      void loadSlots()
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open, form.barberoId, form.servicioId, form.fechaCita])

  const clienteOptions = useMemo(() => {
    const normalized = searchCliente.toLowerCase().trim()
    const filtered = normalized
      ? clientes.filter((c) => `${c.nombre} ${c.apellido} ${c.correo}`.toLowerCase().includes(normalized))
      : clientes
    return filtered.map((cliente) => ({
      value: cliente.id,
      label: `${cliente.nombre} ${cliente.apellido} - ${cliente.correo}`,
    }))
  }, [clientes, searchCliente])

  const createMutation = useMutation({
    mutationFn: async () => {
      const bloqueado = await citaService.bloquearSlot(
        form.barberoId,
        form.servicioId,
        form.fechaCita,
        form.horaInicio,
        form.clienteId,
      )
      if (!bloqueado.exitoso || !bloqueado.tokenBloqueo) {
        throw new Error(bloqueado.mensajeError ?? 'No se pudo bloquear el slot seleccionado.')
      }
      return citaService.create({
        clienteId: form.clienteId,
        barberoId: form.barberoId,
        servicioId: form.servicioId,
        fechaCita: form.fechaCita,
        horaInicio: form.horaInicio,
        tokenRedisBloqueo: bloqueado.tokenBloqueo,
      })
    },
    onSuccess: async () => {
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: ['citas-admin'] }),
        queryClient.invalidateQueries({ queryKey: ['appointments-scheduler'] }),
        queryClient.invalidateQueries({ queryKey: ['appointments-anchor'] }),
        queryClient.invalidateQueries({ queryKey: ['appointments-history'] }),
        queryClient.invalidateQueries({ queryKey: ['disponibilidad-week'] }),
        queryClient.invalidateQueries({ queryKey: ['dashboard-citas-hoy'] }),
        queryClient.invalidateQueries({ queryKey: ['dashboard-citas-mes'] }),
      ])
      onCreated?.()
      onClose()
    },
    onError: (err) => {
      setError(err instanceof Error ? err.message : 'No se pudo crear la cita. Verifica permisos y datos del formulario.')
    },
  })

  const onSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    setError(null)

    if (!form.barberoId || !form.servicioId || !form.fechaCita || !form.horaInicio || !form.clienteId) {
      setError('Completa barbero, servicio, fecha, hora y cliente.')
      return
    }

    createMutation.mutate()
  }

  return (
    <Modal open={open} onClose={onClose} title="Crear cita" size="lg">
      <form className="space-y-4" onSubmit={onSubmit}>
        <div className="grid grid-cols-1 gap-3 md:grid-cols-2">
          <FormSelect
            label="Barbero"
            required
            value={form.barberoId}
            onChange={(e) =>
              setForm((prev) => ({ ...prev, barberoId: e.target.value, servicioId: '', horaInicio: '' }))
            }
            options={barberos.map((barbero) => ({ value: barbero.id, label: `${barbero.nombre} ${barbero.apellido}` }))}
          />
          <FormSelect
            label="Servicio"
            required
            value={form.servicioId}
            onChange={(e) => {
              const servicioId = e.target.value
              const servicio = servicios.find((item) => item.id === servicioId)
              setForm((prev) => ({ ...prev, servicioId, horaInicio: '', precioFinal: servicio?.precio ?? 0 }))
            }}
            options={servicios.map((servicio) => ({
              value: servicio.id,
              label: `${servicio.nombre} (${servicio.duracionMinutos} min)`,
            }))}
          />
          <FormInput
            label="Fecha"
            type="date"
            required
            value={form.fechaCita}
            onChange={(e) => setForm((prev) => ({ ...prev, fechaCita: e.target.value, horaInicio: '' }))}
          />
          <FormSelect
            label="Hora inicio"
            required
            value={form.horaInicio}
            onChange={(e) => setForm((prev) => ({ ...prev, horaInicio: e.target.value }))}
            options={
              slotOptions.length > 0
                ? slotOptions.map((slot) => ({ value: slot.horaInicio, label: `${slot.horaInicio} - ${slot.horaFin}` }))
                : [{ value: '', label: loadingSlots ? 'Cargando slots...' : 'Sin slots disponibles' }]
            }
          />
          <FormInput
            label="Buscar cliente (nombre/correo)"
            value={searchCliente}
            onChange={(e) => setSearchCliente(e.target.value)}
          />
          <div className="md:col-span-2">
            <FormSelect
              label="Cliente"
              required
              value={form.clienteId}
              onChange={(e) => setForm((prev) => ({ ...prev, clienteId: e.target.value }))}
              options={
                clienteOptions.length > 0 ? clienteOptions : [{ value: '', label: 'No hay clientes para esa busqueda' }]
              }
            />
          </div>
          <label className="md:col-span-2 flex flex-col gap-1.5">
            <span className="form-label text-[10px] uppercase tracking-[0.08em]">Notas (opcional)</span>
            <textarea
              value={form.notas}
              onChange={(e) => setForm((prev) => ({ ...prev, notas: e.target.value }))}
              className="form-control min-h-20 rounded-md px-3 py-2 outline-none"
            />
          </label>
          <FormInput
            label="Precio final"
            value={String(form.precioFinal)}
            readOnly
            hint="Auto calculado desde el servicio"
          />
        </div>

        {error ? <p className="form-message-error text-sm">{error}</p> : null}

        <div className="flex justify-end gap-2">
          <Button type="button" variant="ghost" onClick={onClose}>
            Cancelar
          </Button>
          <Button type="submit" loading={createMutation.isPending}>
            Crear cita
          </Button>
        </div>
      </form>
    </Modal>
  )
}
