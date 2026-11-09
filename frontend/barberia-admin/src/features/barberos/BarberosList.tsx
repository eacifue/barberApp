import { useMemo, useState } from 'react'
import { useQuery, useQueryClient } from '@tanstack/react-query'

import {
  Avatar,
  Badge,
  Button,
  ConfirmDialog,
  EmptyState,
  IconButton,
  Rating,
  Select,
  Skeleton,
  Table,
  type TableColumn,
} from '../../components/bsm'
import { PageHeader } from '../../components/shared/PageHeader'
import { useBarberias } from '../../hooks/useBarberias'
import { useBarberos } from '../../hooks/useBarberos'
import { useServicios } from '../../hooks/useServicios'
import { useTenantBarberia } from '../../hooks/useTenantBarberia'
import { barberoService } from '../../services/barberoService'
import { citaService } from '../../services/citaService'
import { toast } from '../../stores/toastStore'
import type { Barbero } from '../../types/barbero'
import { cuentaParaIngresos, hhmm, mensajeDeError, todayIso } from '../citas/agendaUtils'
import { BarberoEditor } from './BarberoEditor'

type Estado = 'Disponible' | 'No disponible' | 'Inactivo'
const ESTADO_UI: Record<Estado, { tone: 'success' | 'warning' | 'neutral'; icon: 'circle-check' | 'calendar-x' | 'ban' }> = {
  Disponible: { tone: 'success', icon: 'circle-check' },
  'No disponible': { tone: 'warning', icon: 'calendar-x' },
  Inactivo: { tone: 'neutral', icon: 'ban' },
}
const estadoDe = (b: Barbero): Estado => (!b.activo ? 'Inactivo' : b.disponible ? 'Disponible' : 'No disponible')

/**
 * Equipo (design/pantallas/panel-web/Barberos): tabla con estado y citas de hoy,
 * editor en modal con servicios, horario y días libres.
 */
export function BarberosList() {
  const queryClient = useQueryClient()
  const { effectiveBarberiaId } = useTenantBarberia()
  const barberiaId = effectiveBarberiaId ?? ''
  const { barberosQuery, removeMutation } = useBarberos(barberiaId, true)
  const { serviciosQuery } = useServicios(barberiaId)
  const { barberiasQuery } = useBarberias()
  const barberia = barberiasQuery.data?.find((b) => b.id === barberiaId)
  const hoy = todayIso()
  const citasHoyQuery = useQuery({
    queryKey: ['barberos', 'citas-hoy', hoy],
    queryFn: () => citaService.getAdminList({ date: hoy, page: 1, pageSize: 200 }),
    refetchInterval: 120_000,
  })

  const [filtro, setFiltro] = useState<Estado | 'Todos'>('Todos')
  const [editando, setEditando] = useState<Barbero | 'nuevo' | null>(null)
  const [desactivar, setDesactivar] = useState<Barbero | null>(null)
  const [activando, setActivando] = useState<string | null>(null)

  const barberos = useMemo(
    () => (barberosQuery.data ?? []).slice().sort((a, b) => Number(b.activo) - Number(a.activo) || `${a.nombre} ${a.apellido}`.localeCompare(`${b.nombre} ${b.apellido}`)),
    [barberosQuery.data],
  )
  const citasHoy = useMemo(() => {
    const m = new Map<string, number>()
    for (const c of citasHoyQuery.data ?? []) if (cuentaParaIngresos(c)) m.set(c.barbero.id, (m.get(c.barbero.id) ?? 0) + 1)
    return m
  }, [citasHoyQuery.data])
  const visibles = barberos.filter((b) => filtro === 'Todos' || estadoDe(b) === filtro)
  const activos = barberos.filter((b) => b.activo)
  const trabajanHoy = activos.filter((b) => (citasHoy.get(b.id) ?? 0) > 0).length

  const activar = async (b: Barbero) => {
    setActivando(b.id)
    try {
      const actualizado = await barberoService.activate(b.id)
      await queryClient.invalidateQueries({ queryKey: ['barberos'] })
      toast.success('Barbero activado. Confirma los servicios que presta.')
      setEditando(actualizado)
    } catch (err) {
      toast.error(mensajeDeError(err, 'No pudimos activar al barbero.'))
    } finally {
      setActivando(null)
    }
  }
  const confirmarDesactivar = async () => {
    if (!desactivar) return
    try {
      await removeMutation.mutateAsync(desactivar.id)
      toast.success(`${desactivar.nombre} quedó desactivado`)
      setDesactivar(null)
      setEditando(null)
    } catch (err) {
      toast.error(mensajeDeError(err, 'No pudimos desactivar al barbero.'))
    }
  }

  const columnas: TableColumn<Barbero>[] = [
    {
      key: 'barbero',
      label: 'Barbero',
      render: (b) => (
        <span className="flex items-center gap-3 text-left">
          <Avatar name={`${b.nombre} ${b.apellido}`} src={b.fotoUrl} size={40} status={b.activo ? (b.disponible ? 'on' : 'off') : undefined} />
          <span className="flex min-w-0 flex-col">
            <strong className="text-label-sm text-ink">
              {b.nombre} {b.apellido}
            </strong>
            <span className="flex items-center gap-1 text-caption text-ink-muted">
              <Rating value={b.ratingPromedio || null} compact size={12} />
              <span>· {b.añosExperiencia === 1 ? '1 año' : `${b.añosExperiencia} años`}</span>
            </span>
          </span>
        </span>
      ),
    },
    {
      key: 'especialidades',
      label: 'Especialidades',
      render: (b) =>
        b.especialidades.length ? (
          <span className="flex flex-wrap gap-1">
            {b.especialidades.slice(0, 3).map((t) => (
              <Badge key={t}>{t}</Badge>
            ))}
            {b.especialidades.length > 3 && <span className="text-caption text-ink-muted">+{b.especialidades.length - 3}</span>}
          </span>
        ) : (
          <span className="text-ink-muted">—</span>
        ),
    },
    { key: 'servicios', label: 'Servicios', align: 'right', render: (b) => b.servicios?.length ?? 0 },
    {
      key: 'estado',
      label: 'Estado',
      render: (b) => {
        const e = estadoDe(b)
        return (
          <Badge tone={ESTADO_UI[e].tone} icon={ESTADO_UI[e].icon}>
            {e}
          </Badge>
        )
      },
    },
    { key: 'hoy', label: 'Citas hoy', align: 'right', render: (b) => (b.activo ? (citasHoyQuery.isLoading ? '…' : (citasHoy.get(b.id) ?? 0)) : '—') },
    {
      key: 'acciones',
      label: 'Acciones',
      align: 'right',
      render: (b) => (
        <span className="inline-flex items-center gap-1" onClick={(e) => e.stopPropagation()}>
          {b.activo ? (
            <>
              <IconButton icon="pencil" size="sm" label={`Editar a ${b.nombre}`} onClick={() => setEditando(b)} />
              <IconButton icon="ban" size="sm" label={`Desactivar a ${b.nombre}`} onClick={() => setDesactivar(b)} />
            </>
          ) : (
            <Button variant="secondary" size="sm" icon="rotate-ccw" loading={activando === b.id} onClick={() => void activar(b)}>
              Activar
            </Button>
          )}
        </span>
      ),
    },
  ]

  const resumen = barberosQuery.isLoading
    ? 'Cargando el equipo…'
    : `${activos.length === 1 ? '1 barbero' : `${activos.length} barberos`}${citasHoyQuery.isSuccess ? ` · ${trabajanHoy} con citas hoy` : ''}`

  return (
    <div className="mx-auto flex max-w-[1200px] flex-col gap-5 px-4 py-5 md:px-6 lg:px-8">
      <PageHeader
        title="Equipo"
        subtitle={resumen}
        actions={
          <Button icon="plus" onClick={() => setEditando('nuevo')}>
            Nuevo barbero
          </Button>
        }
      />

      <div className="w-full max-w-[240px]">
        <Select
          aria-label="Filtrar por estado"
          value={filtro}
          onChange={(e) => setFiltro(e.target.value as Estado | 'Todos')}
          options={[
            { value: 'Todos', label: 'Todos los estados' },
            { value: 'Disponible', label: 'Disponible' },
            { value: 'No disponible', label: 'No disponible' },
            { value: 'Inactivo', label: 'Inactivo' },
          ]}
        />
      </div>

      <Table
        caption="Equipo de barberos"
        columns={columnas}
        rows={visibles}
        rowKey={(b) => b.id}
        onRowClick={(b) => (b.activo ? setEditando(b) : undefined)}
        state={
          barberosQuery.isError ? (
            <EmptyState tone="error" title="No pudimos cargar el equipo" body="Revisa tu conexión e inténtalo de nuevo." actionLabel="Reintentar" actionIcon="refresh-cw" actionVariant="secondary" onAction={() => void barberosQuery.refetch()} />
          ) : barberosQuery.isLoading ? (
            <Skeleton variant="row" rows={5} label="Cargando el equipo" />
          ) : visibles.length === 0 ? (
            barberos.length ? (
              <EmptyState icon="users" title="Nadie con ese estado" body="Elige otro estado para ver al resto del equipo." actionLabel="Ver todos" actionVariant="secondary" onAction={() => setFiltro('Todos')} />
            ) : (
              <EmptyState icon="scissors" title="Aún no tienes barberos" body="Agrega el primero con sus servicios y horario para que los clientes puedan reservar." actionLabel="Nuevo barbero" actionIcon="plus" onAction={() => setEditando('nuevo')} />
            )
          ) : undefined
        }
      />

      {editando && (
        <BarberoEditor
          barbero={editando === 'nuevo' ? null : editando}
          barberiaId={barberiaId}
          servicios={serviciosQuery.data ?? []}
          apertura={barberia?.horaApertura ? hhmm(barberia.horaApertura) : '09:00'}
          cierre={barberia?.horaCierre ? hhmm(barberia.horaCierre) : '20:00'}
          diasDescanso={barberia?.diasDescanso ?? []}
          onClose={() => setEditando(null)}
          onDesactivar={setDesactivar}
        />
      )}

      <ConfirmDialog
        open={desactivar != null}
        tone="danger"
        icon="ban"
        title={`¿Desactivar a ${desactivar?.nombre ?? ''}?`}
        body="Deja de aparecer en la app y no recibe nuevas reservas. Sus citas ya agendadas se mantienen. Al activarlo de nuevo tendrás que confirmar sus servicios."
        confirmLabel="Desactivar barbero"
        loading={removeMutation.isPending}
        onCancel={() => setDesactivar(null)}
        onConfirm={() => void confirmarDesactivar()}
      />
    </div>
  )
}
