import { useMemo, useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'

import { Avatar, Banner, Button, Icon, Input, Modal, Select, Skeleton, SlotGrid, cx, formatCOP, formatLongDate, formatTime } from '../../components/bsm'
import { useBarberos } from '../../hooks/useBarberos'
import { useClientes } from '../../hooks/useClientes'
import { useTenantBarberia } from '../../hooks/useTenantBarberia'
import { citaService } from '../../services/citaService'
import { toast } from '../../stores/toastStore'
import type { Cita } from '../../types/cita'
import { hhmm, mensajeDeError, nombreCliente, parseIso, todayIso } from './agendaUtils'
import { invalidarCitas } from './invalidarCitas'

type Props = {
  open: boolean
  onClose: () => void
  /** Se llama tras crear la cita, además de cerrar el modal. */
  onCreated?: () => void
  initialBarberoId?: string
  initialServicioId?: string
  initialFecha?: string
  initialHora?: string
  /** Precarga el cliente (p. ej. desde su ficha). */
  initialClienteId?: string
  /** Reprogramar: precarga cliente, barbero y servicio; al crear, cancela esta cita. */
  reprogramarDe?: Cita | null
}

/**
 * Nueva cita para clientes que llaman o llegan sin reserva: barbero, servicio,
 * fecha, horas libres y búsqueda de cliente (design/pantallas/panel-web/Agenda-nueva-cita).
 * Compartido por Agenda y Disponibilidad.
 */
export function CreateCitaModal({ open, onClose, onCreated, initialBarberoId, initialServicioId, initialFecha, initialHora, initialClienteId, reprogramarDe }: Props) {
  const queryClient = useQueryClient()
  const { effectiveBarberiaId } = useTenantBarberia()
  const { barberosQuery } = useBarberos(effectiveBarberiaId ?? '')
  const { clientesQuery } = useClientes()
  const barberos = useMemo(() => (barberosQuery.data ?? []).filter((b) => b.activo), [barberosQuery.data])
  const clientes = useMemo(() => (clientesQuery.data ?? []).filter((c) => c.activo), [clientesQuery.data])

  const [barberoId, setBarberoId] = useState('')
  const [servicioId, setServicioId] = useState('')
  const [fecha, setFecha] = useState(todayIso())
  const [hora, setHora] = useState('')
  const [clienteId, setClienteId] = useState('')
  const [busqueda, setBusqueda] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [dirty, setDirty] = useState(false)

  // Cada vez que se abre se re-siembra con lo que traiga quien lo abre
  // (ajuste durante el render, sin efecto: https://react.dev/learn/you-might-not-need-an-effect).
  const [abiertoAntes, setAbiertoAntes] = useState(false)
  if (open !== abiertoAntes) {
    setAbiertoAntes(open)
    if (open) {
      setBarberoId(reprogramarDe?.barbero.id ?? initialBarberoId ?? '')
      setServicioId(reprogramarDe?.servicio.id ?? initialServicioId ?? '')
      setFecha(initialFecha ?? todayIso())
      setHora(initialHora ?? '')
      setClienteId(reprogramarDe?.cliente.id ?? initialClienteId ?? '')
      setBusqueda('')
      setError(null)
      setDirty(false)
    }
  }

  // Barbero y servicio efectivos: los elegidos o, si no hay, el primero disponible.
  const barbero = barberos.find((b) => b.id === barberoId) ?? barberos[0] ?? null
  const barberoEf = barbero?.id ?? ''
  const servicios = useMemo(() => barbero?.servicios ?? [], [barbero])
  const servicio = servicios.find((s) => s.id === servicioId) ?? servicios[0] ?? null
  const servicioEf = servicio?.id ?? ''

  const slotsQuery = useQuery({
    queryKey: ['agenda-nueva-slots', barberoEf, servicioEf, fecha],
    enabled: open && Boolean(barberoEf && servicioEf && fecha),
    queryFn: () => citaService.getDisponibilidad(barberoEf, servicioEf, fecha),
  })
  const libres = useMemo(
    () => (slotsQuery.data?.slots ?? []).filter((s) => s.disponible && !s.bloqueadoPorRedis).map((s) => ({ time: hhmm(s.horaInicio) })),
    [slotsQuery.data],
  )

  const encontrados = useMemo(() => {
    const q = busqueda.trim().toLowerCase()
    if (!q) return []
    const digits = q.replace(/\D/g, '')
    return clientes
      .filter((c) => `${c.nombre} ${c.apellido} ${c.correo}`.toLowerCase().includes(q) || (digits.length >= 3 && c.telefono.replace(/\D/g, '').includes(digits)))
      .slice(0, 6)
  }, [busqueda, clientes])
  const cliente = clientes.find((c) => c.id === clienteId) ?? null

  const createMutation = useMutation({
    mutationFn: async () => {
      const bloqueo = await citaService.bloquearSlot(barberoEf, servicioEf, fecha, hora, clienteId)
      if (!bloqueo.exitoso || !bloqueo.tokenBloqueo) {
        throw new Error(bloqueo.mensajeError ?? 'Ese horario acaba de ocuparse. Elige otro.')
      }
      const nueva = await citaService.create({ clienteId, barberoId: barberoEf, servicioId: servicioEf, fechaCita: fecha, horaInicio: hora, tokenRedisBloqueo: bloqueo.tokenBloqueo })
      let anteriorCancelada = true
      if (reprogramarDe) {
        try {
          await citaService.cancel(reprogramarDe.id, { citaId: reprogramarDe.id, motivo: 'Reprogramada desde la agenda' })
        } catch {
          anteriorCancelada = false
        }
      }
      return { nueva, anteriorCancelada }
    },
    onSuccess: async ({ anteriorCancelada }) => {
      await invalidarCitas(queryClient)
      if (reprogramarDe && !anteriorCancelada) {
        toast.warning('La nueva cita quedó creada, pero no pudimos cancelar la anterior. Cancélala desde la agenda.')
      } else {
        toast.success(reprogramarDe ? 'Cita reprogramada' : 'Cita creada')
      }
      onCreated?.()
      onClose()
    },
    onError: (err) => {
      setError(mensajeDeError(err, 'No pudimos crear la cita. Revisa los datos e inténtalo de nuevo.'))
      void queryClient.invalidateQueries({ queryKey: ['agenda-nueva-slots'] })
    },
  })

  const faltante = !barberoEf ? 'Elige un barbero.' : !servicioEf ? 'Elige un servicio.' : !hora ? 'Elige una hora de inicio.' : !clienteId ? 'Elige el cliente.' : null

  const guardar = () => {
    setError(null)
    if (faltante) {
      setError(faltante)
      return
    }
    createMutation.mutate()
  }

  const saving = createMutation.isPending
  const titulo = reprogramarDe ? `Reprogramar cita de ${nombreCliente(reprogramarDe)}` : 'Nueva cita'

  return (
    <Modal
      open={open}
      onClose={onClose}
      dirty={dirty && !saving}
      size="lg"
      title={titulo}
      subtitle={reprogramarDe ? 'Elige el nuevo horario; la cita anterior se cancela al guardar.' : 'Para clientes que llaman o llegan sin reserva.'}
      footer={
        <>
          <Button variant="secondary" onClick={onClose} disabled={saving}>
            Cancelar
          </Button>
          <Button icon={reprogramarDe ? 'calendar-clock' : 'calendar-plus'} onClick={guardar} loading={saving}>
            {saving ? 'Guardando…' : reprogramarDe ? 'Reprogramar cita' : 'Crear cita'}
          </Button>
        </>
      }
    >
      {error && (
        <Banner tone="danger" title="No pudimos guardar la cita">
          {error}
        </Banner>
      )}
      <div className="grid gap-4 md:grid-cols-2">
        <Select
          label="Barbero"
          value={barberoEf}
          disabled={Boolean(reprogramarDe)}
          onChange={(e) => {
            setBarberoId(e.target.value)
            setServicioId('')
            setHora('')
            setDirty(true)
          }}
          options={barberos.map((b) => ({ value: b.id, label: `${b.nombre} ${b.apellido}`.trim() }))}
          placeholder={barberos.length ? undefined : 'Cargando barberos…'}
        />
        <Select
          label="Servicio"
          value={servicioEf}
          disabled={Boolean(reprogramarDe)}
          onChange={(e) => {
            setServicioId(e.target.value)
            setHora('')
            setDirty(true)
          }}
          options={servicios.map((s) => ({ value: s.id, label: s.nombre }))}
          placeholder={barbero && !servicios.length ? 'Este barbero no tiene servicios' : undefined}
        />
      </div>
      <Input
        label="Fecha"
        type="date"
        icon="calendar"
        min={todayIso()}
        value={fecha}
        hint={fecha ? formatLongDate(parseIso(fecha)) : undefined}
        onChange={(e) => {
          setFecha(e.target.value)
          setHora('')
          setDirty(true)
        }}
      />
      <div className="bsm-field">
        <span className="bsm-field-label">Hora de inicio{barbero ? ` · horarios libres de ${barbero.nombre}` : ''}</span>
        {slotsQuery.isLoading ? (
          <Skeleton variant="slots" label="Cargando horarios" />
        ) : slotsQuery.isError ? (
          <Banner tone="danger" actionLabel="Reintentar" onAction={() => void slotsQuery.refetch()}>
            No pudimos cargar los horarios. Revisa tu conexión e inténtalo de nuevo.
          </Banner>
        ) : libres.length === 0 ? (
          <p className="text-body text-ink-muted">No hay horarios libres este día. Prueba con otra fecha.</p>
        ) : (
          <SlotGrid
            label="Hora de inicio"
            slots={libres}
            selected={hora}
            onSelect={(s) => {
              setHora(s.time)
              setDirty(true)
            }}
          />
        )}
      </div>

      <div className="flex flex-col gap-2">
        {cliente ? (
          <div className="bsm-field">
            <span className="bsm-field-label">Cliente</span>
            <div className="flex items-center gap-3 rounded-md border border-line-strong bg-surface px-3 py-2">
              <Avatar name={`${cliente.nombre} ${cliente.apellido}`} src={cliente.fotoUrl} size={32} />
              <span className="flex min-w-0 flex-1 flex-col">
                <strong className="text-label-sm text-ink">{`${cliente.nombre} ${cliente.apellido}`.trim()}</strong>
                <span className="truncate text-caption text-ink-muted">
                  {[cliente.correo, cliente.telefono].filter(Boolean).join(' · ')}
                </span>
              </span>
              {!reprogramarDe && (
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => {
                    setClienteId('')
                    setDirty(true)
                  }}
                >
                  Cambiar
                </Button>
              )}
            </div>
          </div>
        ) : (
          <>
            <Input
              label="Cliente"
              icon="search"
              placeholder="Busca por nombre, correo o teléfono"
              value={busqueda}
              onChange={(e) => {
                setBusqueda(e.target.value)
                setDirty(true)
              }}
              hint={busqueda.trim() && !encontrados.length ? 'No encontramos clientes con esa búsqueda.' : undefined}
            />
            {encontrados.length > 0 && (
              <div role="listbox" aria-label="Clientes encontrados" className="overflow-hidden rounded-md border border-line bg-surface">
                {encontrados.map((c) => (
                  <button
                    key={c.id}
                    type="button"
                    role="option"
                    aria-selected={false}
                    className={cx('flex w-full items-center gap-3 border-b border-line px-3 py-2 text-left last:border-b-0 hover:bg-surface-sunken focus-visible:shadow-focus')}
                    onClick={() => {
                      setClienteId(c.id)
                      setBusqueda('')
                    }}
                  >
                    <Avatar name={`${c.nombre} ${c.apellido}`} src={c.fotoUrl} size={32} />
                    <span className="flex min-w-0 flex-col">
                      <strong className="text-label-sm text-ink">{`${c.nombre} ${c.apellido}`.trim()}</strong>
                      <span className="truncate text-caption text-ink-muted">
                        {[c.correo, c.telefono, `${c.totalCitas} ${c.totalCitas === 1 ? 'cita' : 'citas'}`].filter(Boolean).join(' · ')}
                      </span>
                    </span>
                    <Icon name="chevron-right" size={16} className="ml-auto text-ink-muted" />
                  </button>
                ))}
              </div>
            )}
          </>
        )}
      </div>

      {servicio && (
        <p className="text-body text-ink-muted">
          Precio de {barbero?.nombre} para este servicio: <strong className="tnum text-ink">{formatCOP(servicio.precio)}</strong> · Pago en el local
          {hora && fecha ? ` · ${formatLongDate(parseIso(fecha))}, ${formatTime(hora)}` : ''}
        </p>
      )}
    </Modal>
  )
}
