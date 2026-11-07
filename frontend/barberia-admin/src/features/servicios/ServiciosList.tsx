import { useMemo, useState } from 'react'

import {
  Badge,
  Banner,
  Button,
  Chip,
  ConfirmDialog,
  EmptyState,
  Icon,
  IconButton,
  Input,
  Modal,
  Select,
  ServiceCard,
  Skeleton,
  Table,
  SERVICE_ICON,
  formatCOP,
  formatDuration,
  type ServiceType,
  type TableColumn,
} from '../../components/bsm'
import { PageHeader } from '../../components/shared/PageHeader'
import { useBarberos } from '../../hooks/useBarberos'
import { useServicios } from '../../hooks/useServicios'
import { useTenantBarberia } from '../../hooks/useTenantBarberia'
import { servicioService } from '../../services/servicioService'
import { toast } from '../../stores/toastStore'
import { TipoServicio, TipoServicioLabel, type Servicio, type ServicioUpsertInput } from '../../types/servicio'
import { mensajeDeError } from '../citas/agendaUtils'
import { useQueryClient } from '@tanstack/react-query'

type Form = { nombre: string; descripcion: string; tipo: TipoServicio; duracion: string; precio: string; fotoUrl: string }
type Errores = Partial<Record<keyof Form, string>>

const VACIO: Form = { nombre: '', descripcion: '', tipo: TipoServicio.Corte, duracion: '30', precio: '', fotoUrl: '' }
const TIPOS = Object.entries(TipoServicioLabel).map(([value, label]) => ({ value: Number(value) as TipoServicio, label: label as ServiceType }))

function soloDigitos(v: string) {
  return v.replace(/\D/g, '')
}

function validar(f: Form): Errores {
  const e: Errores = {}
  if (!f.nombre.trim()) e.nombre = 'Escribe el nombre del servicio.'
  const d = Number(f.duracion)
  if (!Number.isInteger(d) || d < 10 || d > 240) e.duracion = 'Ingresa una duración entre 10 y 240 minutos.'
  else if (d % 5 !== 0) e.duracion = 'Usa pasos de 5 minutos (p. ej. 45 o 50).'
  if (!(Number(soloDigitos(f.precio)) > 0)) e.precio = 'Ingresa un precio mayor a $0.'
  if (f.fotoUrl.trim() && !/^https?:\/\//i.test(f.fotoUrl.trim())) e.fotoUrl = 'Usa un enlace que empiece por https://'
  return e
}

/**
 * Catálogo de servicios (design/pantallas/panel-web/Servicios y Servicio-editar):
 * filtro por tipo, tabla, edición en modal con vista previa en la app,
 * desactivar en vez de eliminar.
 */
export function ServiciosList() {
  const queryClient = useQueryClient()
  const { effectiveBarberiaId } = useTenantBarberia()
  const { serviciosQuery, createMutation, updateMutation } = useServicios(effectiveBarberiaId ?? '', true)
  const { barberosQuery } = useBarberos(effectiveBarberiaId ?? '')

  const [tipo, setTipo] = useState<TipoServicio | 0>(0)
  const [editando, setEditando] = useState<Servicio | 'nuevo' | null>(null)
  const [form, setForm] = useState<Form>(VACIO)
  const [errores, setErrores] = useState<Errores>({})
  const [dirty, setDirty] = useState(false)
  const [cambiarEstado, setCambiarEstado] = useState<Servicio | null>(null)
  const [cambiando, setCambiando] = useState(false)

  const servicios = useMemo(() => (serviciosQuery.data ?? []).slice().sort((a, b) => Number(b.activo) - Number(a.activo) || a.nombre.localeCompare(b.nombre)), [serviciosQuery.data])
  const visibles = servicios.filter((s) => !tipo || s.tipo === tipo)
  const barberosPorServicio = useMemo(() => {
    const m = new Map<string, number>()
    for (const b of barberosQuery.data ?? []) for (const s of b.servicios ?? []) m.set(s.id, (m.get(s.id) ?? 0) + 1)
    return m
  }, [barberosQuery.data])

  const abrir = (s: Servicio | 'nuevo') => {
    setEditando(s)
    setErrores({})
    setDirty(false)
    setForm(
      s === 'nuevo'
        ? VACIO
        : { nombre: s.nombre, descripcion: s.descripcion ?? '', tipo: s.tipo, duracion: String(s.duracionMinutos), precio: String(Math.round(s.precio)), fotoUrl: s.fotoUrl ?? '' },
    )
  }
  const set = <K extends keyof Form>(k: K, v: Form[K]) => {
    setForm((f) => ({ ...f, [k]: v }))
    setDirty(true)
    if (errores[k]) setErrores((e) => ({ ...e, [k]: undefined }))
  }

  const guardar = async () => {
    const e = validar(form)
    setErrores(e)
    if (Object.keys(e).length) return
    const payload: ServicioUpsertInput = {
      nombre: form.nombre.trim(),
      descripcion: form.descripcion.trim(),
      tipo: form.tipo,
      duracionMinutos: Number(form.duracion),
      precio: Number(soloDigitos(form.precio)),
      fotoUrl: form.fotoUrl.trim() || undefined,
      activo: editando === 'nuevo' ? true : (editando?.activo ?? true),
    }
    try {
      if (editando === 'nuevo') await createMutation.mutateAsync(payload)
      else if (editando) await updateMutation.mutateAsync({ id: editando.id, data: payload })
      toast.success(editando === 'nuevo' ? 'Servicio creado' : 'Cambios guardados')
      setEditando(null)
    } catch (err) {
      toast.error(mensajeDeError(err, 'No pudimos guardar el servicio. Inténtalo de nuevo.'))
    }
  }

  const confirmarEstado = async () => {
    if (!cambiarEstado) return
    setCambiando(true)
    try {
      if (cambiarEstado.activo) await servicioService.remove(cambiarEstado.id)
      else await servicioService.activate(cambiarEstado.id)
      await queryClient.invalidateQueries({ queryKey: ['servicios'] })
      toast.success(cambiarEstado.activo ? 'Servicio desactivado' : 'Servicio activado')
      setCambiarEstado(null)
    } catch (err) {
      toast.error(mensajeDeError(err, 'No pudimos cambiar el estado del servicio.'))
    } finally {
      setCambiando(false)
    }
  }

  const columnas: TableColumn<Servicio>[] = [
    {
      key: 'servicio',
      label: 'Servicio',
      render: (s) => (
        <span className="flex items-center gap-3 text-left">
          <span className="bsm-service-icon !h-10 !w-10 flex-none">
            <Icon name={SERVICE_ICON[TipoServicioLabel[s.tipo] as ServiceType] ?? 'scissors'} size={20} />
          </span>
          <span className="flex min-w-0 flex-col">
            <strong className="text-label-sm text-ink">{s.nombre}</strong>
            {s.descripcion && <span className="line-clamp-1 max-w-[320px] text-caption text-ink-muted">{s.descripcion}</span>}
          </span>
        </span>
      ),
    },
    { key: 'tipo', label: 'Tipo', muted: true, render: (s) => TipoServicioLabel[s.tipo] },
    { key: 'duracion', label: 'Duración', align: 'right', render: (s) => formatDuration(s.duracionMinutos) },
    { key: 'precio', label: 'Precio', align: 'right', render: (s) => formatCOP(s.precio) },
    { key: 'barberos', label: 'Barberos', align: 'right', render: (s) => barberosPorServicio.get(s.id) ?? 0 },
    {
      key: 'estado',
      label: 'Estado',
      render: (s) => (s.activo ? <Badge tone="success" icon="circle-check">Activo</Badge> : <Badge tone="neutral" icon="ban">Inactivo</Badge>),
    },
    {
      key: 'acciones',
      label: 'Acciones',
      align: 'right',
      render: (s) => (
        <span className="inline-flex gap-1" onClick={(e) => e.stopPropagation()}>
          <IconButton icon="pencil" size="sm" label={`Editar ${s.nombre}`} onClick={() => abrir(s)} />
          <IconButton icon={s.activo ? 'ban' : 'rotate-ccw'} size="sm" label={`${s.activo ? 'Desactivar' : 'Activar'} ${s.nombre}`} onClick={() => setCambiarEstado(s)} />
        </span>
      ),
    },
  ]

  const guardando = createMutation.isPending || updateMutation.isPending
  const tipoLabel = TipoServicioLabel[form.tipo] as ServiceType

  return (
    <div className="mx-auto flex max-w-[1200px] flex-col gap-5 px-4 py-5 md:px-6 lg:px-8">
      <PageHeader
        title="Catálogo de servicios"
        subtitle="Lo que los clientes pueden reservar en la app, con duración y precio general."
        actions={
          <Button icon="plus" onClick={() => abrir('nuevo')}>
            Nuevo servicio
          </Button>
        }
      />

      <div role="group" aria-label="Filtrar por tipo" className="bsm-chip-row">
        <Chip selected={!tipo} count={servicios.length} onClick={() => setTipo(0)}>
          Todos
        </Chip>
        {TIPOS.filter((t) => servicios.some((s) => s.tipo === t.value)).map((t) => (
          <Chip key={t.value} selected={tipo === t.value} icon={SERVICE_ICON[t.label]} count={servicios.filter((s) => s.tipo === t.value).length} onClick={() => setTipo(t.value)}>
            {t.label}
          </Chip>
        ))}
      </div>

      <Table
        caption="Catálogo de servicios"
        columns={columnas}
        rows={visibles}
        rowKey={(s) => s.id}
        onRowClick={(s) => abrir(s)}
        state={
          serviciosQuery.isError ? (
            <EmptyState tone="error" title="No pudimos cargar los servicios" body="Revisa tu conexión e inténtalo de nuevo." actionLabel="Reintentar" actionIcon="refresh-cw" actionVariant="secondary" onAction={() => void serviciosQuery.refetch()} />
          ) : serviciosQuery.isLoading ? (
            <Skeleton variant="row" rows={5} label="Cargando servicios" />
          ) : visibles.length === 0 ? (
            <EmptyState icon="scissors" title={servicios.length ? 'No hay servicios de este tipo' : 'Aún no tienes servicios'} body={servicios.length ? 'Elige otro tipo o crea uno nuevo.' : 'Crea el primero para que tus clientes puedan reservar.'} actionLabel="Nuevo servicio" actionIcon="plus" onAction={() => abrir('nuevo')} />
          ) : undefined
        }
      />

      <Modal
        open={editando != null}
        onClose={() => setEditando(null)}
        dirty={dirty && !guardando}
        title={editando === 'nuevo' ? 'Nuevo servicio' : 'Editar servicio'}
        subtitle={editando && editando !== 'nuevo' ? editando.nombre : 'Aparece en el paso 1 de la reserva.'}
        footer={
          <>
            <Button variant="secondary" onClick={() => setEditando(null)} disabled={guardando}>
              Cancelar
            </Button>
            <Button onClick={() => void guardar()} loading={guardando}>
              {guardando ? 'Guardando…' : editando === 'nuevo' ? 'Crear servicio' : 'Guardar cambios'}
            </Button>
          </>
        }
      >
        {editando && editando !== 'nuevo' && !editando.activo && (
          <Banner tone="warning" title="Este servicio está desactivado">
            Los clientes no lo ven en la app. Actívalo desde la tabla cuando quieras volver a ofrecerlo.
          </Banner>
        )}
        <Input label="Nombre" value={form.nombre} error={errores.nombre} onChange={(e) => set('nombre', e.target.value)} />
        <Input label="Descripción" multiline optional value={form.descripcion} hint="Una o dos frases. Se ve en la tarjeta del servicio." onChange={(e) => set('descripcion', e.target.value)} />
        <div className="grid gap-4 md:grid-cols-3">
          <Select label="Tipo" value={String(form.tipo)} onChange={(e) => set('tipo', Number(e.target.value) as TipoServicio)} options={TIPOS.map((t) => ({ value: String(t.value), label: t.label }))} />
          <Input label="Duración (min)" type="number" inputMode="numeric" min={10} max={240} step={5} value={form.duracion} hint="Entre 10 y 240." error={errores.duracion} onChange={(e) => set('duracion', e.target.value)} />
          <Input
            label="Precio general"
            inputMode="numeric"
            value={form.precio ? formatCOP(Number(soloDigitos(form.precio))) : ''}
            placeholder="$0"
            hint="Mayor a $0."
            error={errores.precio}
            onChange={(e) => set('precio', soloDigitos(e.target.value))}
          />
        </div>
        <Input label="Foto" optional icon="image-plus" placeholder="https://…" value={form.fotoUrl} hint="Enlace a una foto cuadrada. Sin foto se usa el ícono del tipo de servicio." error={errores.fotoUrl} onChange={(e) => set('fotoUrl', e.target.value)} />
        <div className="flex flex-col gap-2">
          <span className="bsm-overline">Así se ve en la app</span>
          <div className="max-w-[420px]">
            <ServiceCard
              name={form.nombre.trim() || 'Nombre del servicio'}
              type={tipoLabel}
              description={form.descripcion.trim() || undefined}
              duration={Number(form.duracion) || 30}
              price={Number(soloDigitos(form.precio)) || 0}
              image={/^https?:\/\//i.test(form.fotoUrl.trim()) ? form.fotoUrl.trim() : undefined}
            />
          </div>
        </div>
      </Modal>

      <ConfirmDialog
        open={cambiarEstado != null}
        tone={cambiarEstado?.activo ? 'danger' : 'info'}
        icon={cambiarEstado?.activo ? 'ban' : 'rotate-ccw'}
        title={cambiarEstado?.activo ? `¿Desactivar «${cambiarEstado.nombre}»?` : `¿Activar «${cambiarEstado?.nombre}»?`}
        body={
          cambiarEstado?.activo
            ? 'Deja de aparecer en la app. Las citas ya agendadas se mantienen y puedes activarlo cuando quieras.'
            : 'Volverá a aparecer en la app para los barberos que lo prestan.'
        }
        confirmLabel={cambiarEstado?.activo ? 'Desactivar servicio' : 'Activar servicio'}
        loading={cambiando}
        onCancel={() => setCambiarEstado(null)}
        onConfirm={() => void confirmarEstado()}
      />
    </div>
  )
}
