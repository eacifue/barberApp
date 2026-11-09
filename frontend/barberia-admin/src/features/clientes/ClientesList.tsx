import { useMemo, useState } from 'react'
import { useQuery } from '@tanstack/react-query'

import { Avatar, Badge, Button, Chip, formatPhone, ConfirmDialog, EmptyState, IconButton, Input, Modal, Pagination, Skeleton, Table, type TableColumn } from '../../components/bsm'
import { PageHeader } from '../../components/shared/PageHeader'
import { useClientes } from '../../hooks/useClientes'
import { useDebounce } from '../../hooks/useDebounce'
import { useMediaQuery } from '../../hooks/useMediaQuery'
import { toast } from '../../stores/toastStore'
import type { Cita } from '../../types/cita'
import type { Cliente } from '../../types/cliente'
import { addDaysIso, mensajeDeError, nowHHMM, todayIso } from '../citas/agendaUtils'
import { citasEnRango } from '../citas/citasEnRango'
import { CreateCitaModal } from '../citas/CreateCitaModal'
import { ClienteFicha } from './ClienteFicha'
import { fechaCorta, metricasDe } from './clientesUtils'

const POR_PAGINA = 25
type Filtro = 'Todos' | 'Activos' | 'Inactivos'
type Form = { nombre: string; apellido: string; telefono: string; correo: string; password: string }
type Errores = Partial<Record<keyof Form, string>>

const sinTildes = (s: string) => s.normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase()

/**
 * Clientes (design/pantallas/panel-web/Clientes): búsqueda, filtro por estado,
 * paginación y ficha lateral con métricas calculadas de las citas del último año.
 */
export function ClientesList() {
  const { clientesQuery, createMutation, updateMutation } = useClientes()
  const ancho = useMediaQuery('(min-width: 1280px)')
  const hoy = todayIso()
  const citasQuery = useQuery({
    queryKey: ['clientes', 'citas', hoy],
    queryFn: () => citasEnRango(addDaysIso(hoy, -365), addDaysIso(hoy, 90)),
    staleTime: 60_000,
  })

  const [busqueda, setBusqueda] = useState('')
  const q = useDebounce(busqueda, 200)
  const [filtro, setFiltro] = useState<Filtro>('Todos')
  const [pagina, setPagina] = useState(1)
  const [seleccionId, setSeleccionId] = useState<string | null>(null)
  const [editando, setEditando] = useState<Cliente | 'nuevo' | null>(null)
  const [form, setForm] = useState<Form>({ nombre: '', apellido: '', telefono: '', correo: '', password: '' })
  const [errores, setErrores] = useState<Errores>({})
  const [dirty, setDirty] = useState(false)
  const [cambiarEstado, setCambiarEstado] = useState<Cliente | null>(null)
  const [citaPara, setCitaPara] = useState<Cliente | null>(null)

  const clientes = useMemo(() => (clientesQuery.data ?? []).filter((c) => !c.rol || c.rol === 'Cliente'), [clientesQuery.data])
  const citasPorCliente = useMemo(() => {
    const m = new Map<string, Cita[]>()
    for (const c of citasQuery.data ?? []) {
      const l = m.get(c.cliente.id)
      if (l) l.push(c)
      else m.set(c.cliente.id, [c])
    }
    return m
  }, [citasQuery.data])
  const ultimaVisita = useMemo(() => {
    const m = new Map<string, string>()
    for (const c of citasQuery.data ?? []) {
      if (c.estado !== 'Completada') continue
      const d = c.fechaCita.slice(0, 10)
      if ((m.get(c.cliente.id) ?? '') < d) m.set(c.cliente.id, d)
    }
    return m
  }, [citasQuery.data])

  const filtrados = useMemo(() => {
    const t = sinTildes(q.trim())
    const digitos = q.replace(/\D/g, '')
    return clientes
      .filter((c) => filtro === 'Todos' || (filtro === 'Activos') === c.activo)
      .filter((c) => !t || sinTildes(`${c.nombre} ${c.apellido} ${c.correo}`).includes(t) || (digitos.length >= 3 && c.telefono.replace(/\D/g, '').includes(digitos)))
      .sort((a, b) => (ultimaVisita.get(b.id) ?? '').localeCompare(ultimaVisita.get(a.id) ?? '') || `${a.nombre} ${a.apellido}`.localeCompare(`${b.nombre} ${b.apellido}`))
  }, [clientes, filtro, q, ultimaVisita])
  const paginas = Math.max(1, Math.ceil(filtrados.length / POR_PAGINA))
  const paginaEf = Math.min(pagina, paginas)
  const visibles = filtrados.slice((paginaEf - 1) * POR_PAGINA, paginaEf * POR_PAGINA)

  const seleccionado = clientes.find((c) => c.id === seleccionId) ?? null
  const metricas = useMemo(() => (seleccionado && citasQuery.data ? metricasDe(citasPorCliente.get(seleccionado.id) ?? [], hoy, nowHHMM()) : null), [seleccionado, citasQuery.data, citasPorCliente, hoy])

  const mesActual = hoy.slice(0, 7)
  const nuevosMes = clientes.filter((c) => c.createdAt?.slice(0, 7) === mesActual).length

  const abrirEditor = (c: Cliente | 'nuevo') => {
    setEditando(c)
    setErrores({})
    setDirty(false)
    setForm(c === 'nuevo' ? { nombre: '', apellido: '', telefono: '', correo: '', password: '' } : { nombre: c.nombre, apellido: c.apellido, telefono: c.telefono, correo: c.correo, password: '' })
  }
  const set = (k: keyof Form, v: string) => {
    setForm((f) => ({ ...f, [k]: v }))
    setDirty(true)
    if (errores[k]) setErrores((e) => ({ ...e, [k]: undefined }))
  }
  const guardar = async () => {
    const e: Errores = {}
    if (!form.nombre.trim()) e.nombre = 'Escribe el nombre.'
    if (!form.apellido.trim()) e.apellido = 'Escribe el apellido.'
    if (form.telefono.replace(/\D/g, '').length < 7) e.telefono = 'Ingresa un celular de al menos 7 dígitos.'
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.correo.trim())) e.correo = 'Ingresa un correo válido, como nombre@correo.com.'
    if (editando === 'nuevo' && form.password.length < 6) e.password = 'Usa al menos 6 caracteres.'
    if (editando !== 'nuevo' && form.password && form.password.length < 6) e.password = 'Usa al menos 6 caracteres, o déjala vacía para no cambiarla.'
    setErrores(e)
    if (Object.keys(e).length) return
    try {
      if (editando === 'nuevo') {
        const nuevo = await createMutation.mutateAsync({ ...form, activo: true })
        toast.success(`${form.nombre.trim()} quedó registrado`)
        setSeleccionId(nuevo.id)
      } else if (editando) {
        await updateMutation.mutateAsync({ id: editando.id, data: { ...form, password: form.password || undefined, activo: editando.activo } })
        toast.success('Datos guardados')
      }
      setEditando(null)
    } catch (err) {
      toast.error(mensajeDeError(err, 'No pudimos guardar el cliente. Inténtalo de nuevo.'))
    }
  }
  const confirmarEstado = async () => {
    if (!cambiarEstado) return
    const c = cambiarEstado
    try {
      await updateMutation.mutateAsync({ id: c.id, data: { nombre: c.nombre, apellido: c.apellido, telefono: c.telefono, correo: c.correo, activo: !c.activo } })
      toast.success(c.activo ? `${c.nombre} quedó desactivado` : `${c.nombre} quedó activo`)
      setCambiarEstado(null)
    } catch (err) {
      toast.error(mensajeDeError(err, 'No pudimos cambiar el estado del cliente.'))
    }
  }

  const columnas: TableColumn<Cliente>[] = [
    {
      key: 'cliente',
      label: 'Cliente',
      render: (c) => (
        <span className="flex items-center gap-3 text-left">
          <Avatar name={`${c.nombre} ${c.apellido}`} src={c.fotoUrl} size={32} />
          <span className="flex min-w-0 flex-col">
            <strong className="truncate text-label-sm text-ink">
              {c.nombre} {c.apellido}
            </strong>
            <span className="truncate text-caption text-ink-muted">{c.correo}</span>
          </span>
        </span>
      ),
    },
    { key: 'celular', label: 'Celular', muted: true, render: (c) => <span className="whitespace-nowrap">{c.telefono ? formatPhone(c.telefono) : '—'}</span> },
    { key: 'citas', label: 'Citas', align: 'right', render: (c) => (citasQuery.isLoading ? '…' : (citasPorCliente.get(c.id)?.length ?? 0)) },
    { key: 'ultima', label: 'Última visita', render: (c) => (citasQuery.isLoading ? '…' : ultimaVisita.has(c.id) ? fechaCorta(ultimaVisita.get(c.id)!, hoy) : <span className="text-ink-muted">Sin visitas</span>) },
    { key: 'estado', label: 'Estado', render: (c) => (c.activo ? <Badge tone="success" icon="circle-check">Activo</Badge> : <Badge tone="neutral" icon="ban">Inactivo</Badge>) },
    {
      key: 'acciones',
      label: 'Acciones',
      align: 'right',
      render: (c) => (
        <span className="inline-flex gap-1" onClick={(e) => e.stopPropagation()}>
          <IconButton icon="pencil" size="sm" label={`Editar a ${c.nombre}`} onClick={() => abrirEditor(c)} />
          <IconButton icon={c.activo ? 'ban' : 'rotate-ccw'} size="sm" label={`${c.activo ? 'Desactivar' : 'Activar'} a ${c.nombre}`} onClick={() => setCambiarEstado(c)} />
        </span>
      ),
    },
  ]

  const ficha = seleccionado && (
    <ClienteFicha
      cliente={seleccionado}
      metricas={metricas}
      cargando={citasQuery.isLoading}
      onClose={() => setSeleccionId(null)}
      onNuevaCita={() => setCitaPara(seleccionado)}
      onEditar={() => abrirEditor(seleccionado)}
      onCambiarEstado={() => setCambiarEstado(seleccionado)}
    />
  )
  const guardando = createMutation.isPending || updateMutation.isPending
  const conteo = (f: Filtro) => clientes.filter((c) => f === 'Todos' || (f === 'Activos') === c.activo).length

  return (
    <div className="mx-auto flex max-w-[1400px] flex-col gap-5 px-4 py-5 md:px-6 lg:px-8">
      <PageHeader
        title="Clientes"
        subtitle={clientesQuery.isLoading ? 'Cargando clientes…' : `${clientes.length === 1 ? '1 cliente' : `${clientes.length} clientes`}${nuevosMes ? ` · ${nuevosMes} ${nuevosMes === 1 ? 'nuevo' : 'nuevos'} este mes` : ''}`}
        actions={
          <Button icon="user-plus" onClick={() => abrirEditor('nuevo')}>
            Nuevo cliente
          </Button>
        }
      />

      <div className="flex flex-wrap items-center gap-3">
        <div className="w-full max-w-[360px]">
          <Input
            aria-label="Buscar cliente"
            type="search"
            icon="search"
            placeholder="Buscar por nombre, correo o celular"
            value={busqueda}
            onChange={(e) => {
              setBusqueda(e.target.value)
              setPagina(1)
            }}
          />
        </div>
        <div role="group" aria-label="Filtrar por estado" className="bsm-chip-row">
          {(['Todos', 'Activos', 'Inactivos'] as Filtro[]).map((f) => (
            <Chip
              key={f}
              selected={filtro === f}
              count={conteo(f)}
              onClick={() => {
                setFiltro(f)
                setPagina(1)
              }}
            >
              {f}
            </Chip>
          ))}
        </div>
      </div>

      <div className={ancho && seleccionado ? 'grid grid-cols-[minmax(0,1fr)_380px] items-start gap-5' : ''}>
        <div className="flex min-w-0 flex-col gap-4">
          <Table
            caption="Clientes"
            columns={columnas}
            rows={visibles}
            rowKey={(c) => c.id}
            isSelected={(c) => c.id === seleccionId}
            onRowClick={(c) => setSeleccionId(c.id === seleccionId ? null : c.id)}
            state={
              clientesQuery.isError ? (
                <EmptyState tone="error" title="No pudimos cargar los clientes" body="Revisa tu conexión e inténtalo de nuevo." actionLabel="Reintentar" actionIcon="refresh-cw" actionVariant="secondary" onAction={() => void clientesQuery.refetch()} />
              ) : clientesQuery.isLoading ? (
                <Skeleton variant="row" rows={8} label="Cargando clientes" />
              ) : visibles.length === 0 ? (
                clientes.length ? (
                  <EmptyState icon="search" title="Sin resultados" body={q ? `Nadie coincide con «${q}». Revisa la ortografía o busca por celular.` : 'No hay clientes con ese estado.'} actionLabel="Limpiar búsqueda" actionVariant="secondary" onAction={() => { setBusqueda(''); setFiltro('Todos') }} />
                ) : (
                  <EmptyState icon="users" title="Aún no tienes clientes" body="Se registran solos desde la app, o puedes agregar a quien llama o llega sin reserva." actionLabel="Nuevo cliente" actionIcon="user-plus" onAction={() => abrirEditor('nuevo')} />
                )
              ) : undefined
            }
          />
          {filtrados.length > POR_PAGINA && <Pagination page={paginaEf} pages={paginas} total={filtrados.length} perPage={POR_PAGINA} onPageChange={setPagina} />}
        </div>
        {ancho && ficha && <div className="sticky top-4 rounded-lg border border-line bg-surface p-5">{ficha}</div>}
      </div>

      {!ancho && (
        <Modal open={seleccionado != null} onClose={() => setSeleccionId(null)} sheet title="Ficha del cliente">
          {ficha}
        </Modal>
      )}

      <Modal
        open={editando != null}
        onClose={() => setEditando(null)}
        dirty={dirty && !guardando}
        title={editando === 'nuevo' ? 'Nuevo cliente' : 'Editar datos'}
        subtitle={editando && editando !== 'nuevo' ? `${editando.nombre} ${editando.apellido}` : 'Podrá entrar a la app con su correo y esta contraseña.'}
        footer={
          <>
            <Button variant="secondary" onClick={() => setEditando(null)} disabled={guardando}>
              Cancelar
            </Button>
            <Button onClick={() => void guardar()} loading={guardando}>
              {guardando ? 'Guardando…' : editando === 'nuevo' ? 'Registrar cliente' : 'Guardar cambios'}
            </Button>
          </>
        }
      >
        <div className="grid gap-4 md:grid-cols-2">
          <Input label="Nombre" autoComplete="off" value={form.nombre} error={errores.nombre} onChange={(e) => set('nombre', e.target.value)} />
          <Input label="Apellido" autoComplete="off" value={form.apellido} error={errores.apellido} onChange={(e) => set('apellido', e.target.value)} />
        </div>
        <Input label="Celular" type="tel" inputMode="tel" value={form.telefono} error={errores.telefono} onChange={(e) => set('telefono', e.target.value)} />
        <Input label="Correo" type="email" autoComplete="off" value={form.correo} error={errores.correo} onChange={(e) => set('correo', e.target.value)} />
        <Input
          label={editando === 'nuevo' ? 'Contraseña' : 'Nueva contraseña'}
          optional={editando !== 'nuevo'}
          type="password"
          revealable
          autoComplete="new-password"
          value={form.password}
          hint={editando === 'nuevo' ? 'Mínimo 6 caracteres. Compártela con el cliente.' : 'Déjala vacía para no cambiarla.'}
          error={errores.password}
          onChange={(e) => set('password', e.target.value)}
        />
      </Modal>

      <ConfirmDialog
        open={cambiarEstado != null}
        tone={cambiarEstado?.activo ? 'danger' : 'info'}
        icon={cambiarEstado?.activo ? 'ban' : 'rotate-ccw'}
        title={cambiarEstado?.activo ? `¿Desactivar a ${cambiarEstado.nombre}?` : `¿Activar a ${cambiarEstado?.nombre ?? ''}?`}
        body={cambiarEstado?.activo ? 'No podrá entrar a la app ni reservar. Sus citas ya agendadas se mantienen.' : 'Podrá volver a entrar a la app y reservar.'}
        confirmLabel={cambiarEstado?.activo ? 'Desactivar cliente' : 'Activar cliente'}
        loading={updateMutation.isPending}
        onCancel={() => setCambiarEstado(null)}
        onConfirm={() => void confirmarEstado()}
      />

      <CreateCitaModal open={citaPara != null} onClose={() => setCitaPara(null)} initialClienteId={citaPara?.id} />
    </div>
  )
}
