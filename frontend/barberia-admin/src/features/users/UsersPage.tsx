import { useMemo, useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Link } from 'react-router-dom'

import { Avatar, Badge, Button, Chip, ConfirmDialog, EmptyState, IconButton, Input, Modal, Select, Skeleton, Table, type IconName, type TableColumn } from '../../components/bsm'
import { PageHeader } from '../../components/shared/PageHeader'
import { useBarberos } from '../../hooks/useBarberos'
import { useTenantBarberia } from '../../hooks/useTenantBarberia'
import { userService, type UserDto } from '../../services/userService'
import { toast } from '../../stores/toastStore'
import { mensajeDeError } from '../citas/agendaUtils'

type Rol = 'Admin' | 'AdministradorBarberia' | 'Barbero'
const ROLES: Record<Rol, { label: string; icon: IconName; alcance: string }> = {
  Admin: { label: 'Administrador', icon: 'shield-check', alcance: 'Todo el panel, incluidos Usuarios y Mi negocio.' },
  AdministradorBarberia: { label: 'Admin Barbería', icon: 'store', alcance: 'Agenda, equipo, servicios y clientes de la barbería. No gestiona administradores.' },
  Barbero: { label: 'Barbero', icon: 'scissors', alcance: 'Solo su agenda en «Mis citas». No ve ingresos, clientes ni la configuración del negocio.' },
}
const ES_EQUIPO = (r: string): r is Rol => r in ROLES

type Form = { nombre: string; apellido: string; correo: string; telefono: string; password: string; rol: Rol; barberoId: string }
type Errores = Partial<Record<keyof Form, string>>

/** Cuentas del equipo (design/pantallas/panel-web/Usuarios): quién entra al panel y con qué rol. */
export function UsersPage() {
  const qc = useQueryClient()
  const { effectiveBarberiaId, isAdminBarberia } = useTenantBarberia()
  const { barberosQuery } = useBarberos(effectiveBarberiaId ?? '')
  const usersQuery = useQuery({ queryKey: ['users'], queryFn: userService.getAll })

  const [filtro, setFiltro] = useState<Rol | 'Todos'>('Todos')
  const [editando, setEditando] = useState<UserDto | 'nuevo' | null>(null)
  const [form, setForm] = useState<Form>({ nombre: '', apellido: '', correo: '', telefono: '', password: '', rol: 'Barbero', barberoId: '' })
  const [errores, setErrores] = useState<Errores>({})
  const [dirty, setDirty] = useState(false)
  const [cambiarEstado, setCambiarEstado] = useState<UserDto | null>(null)

  const invalidar = () => qc.invalidateQueries({ queryKey: ['users'] })
  const createMutation = useMutation({ mutationFn: userService.create, onSuccess: invalidar })
  const updateMutation = useMutation({ mutationFn: ({ id, payload }: { id: string; payload: Parameters<typeof userService.update>[1] }) => userService.update(id, payload), onSuccess: invalidar })
  const removeMutation = useMutation({ mutationFn: userService.remove, onSuccess: invalidar })

  const equipo = useMemo(
    () => (usersQuery.data ?? []).filter((u) => ES_EQUIPO(u.rol)).sort((a, b) => Number(b.activo) - Number(a.activo) || `${a.nombre} ${a.apellido}`.localeCompare(`${b.nombre} ${b.apellido}`)),
    [usersQuery.data],
  )
  const visibles = equipo.filter((u) => filtro === 'Todos' || u.rol === filtro)
  const barberos = useMemo(() => (barberosQuery.data ?? []).filter((b) => b.activo), [barberosQuery.data])
  const nombreBarbero = (id: string | null) => {
    const b = barberosQuery.data?.find((x) => x.id === id)
    return b ? `${b.nombre} ${b.apellido}` : null
  }
  const vinculados = new Set(equipo.filter((u) => u.activo && u.barberoId && (editando === 'nuevo' || u.id !== editando?.id)).map((u) => u.barberoId))
  const rolesPermitidos: Rol[] = isAdminBarberia ? ['Barbero'] : ['Admin', 'AdministradorBarberia', 'Barbero']
  const puedeGestionar = (u: UserDto) => !(isAdminBarberia && u.rol !== 'Barbero')

  const abrir = (u: UserDto | 'nuevo') => {
    setEditando(u)
    setErrores({})
    setDirty(false)
    setForm(
      u === 'nuevo'
        ? { nombre: '', apellido: '', correo: '', telefono: '', password: '', rol: 'Barbero', barberoId: '' }
        : { nombre: u.nombre, apellido: u.apellido, correo: u.correo, telefono: u.telefono, password: '', rol: ES_EQUIPO(u.rol) ? u.rol : 'Barbero', barberoId: u.barberoId ?? '' },
    )
  }
  const set = <K extends keyof Form>(k: K, v: Form[K]) => {
    setForm((f) => ({ ...f, [k]: v }))
    setDirty(true)
    if (errores[k]) setErrores((e) => ({ ...e, [k]: undefined }))
  }
  const elegirBarbero = (id: string) => {
    set('barberoId', id)
    // Al vincular una cuenta nueva, precarga los datos del barbero si aún están vacíos.
    const b = barberos.find((x) => x.id === id)
    if (b && editando === 'nuevo') setForm((f) => ({ ...f, barberoId: id, nombre: f.nombre || b.nombre, apellido: f.apellido || b.apellido, correo: f.correo || b.correo, telefono: f.telefono || b.telefono }))
  }

  const guardar = async () => {
    const e: Errores = {}
    if (!form.nombre.trim()) e.nombre = 'Escribe el nombre.'
    if (!form.apellido.trim()) e.apellido = 'Escribe el apellido.'
    if (editando === 'nuevo' && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.correo.trim())) e.correo = 'Ingresa un correo válido, como nombre@correo.com.'
    if (form.telefono.replace(/\D/g, '').length < 7) e.telefono = 'Ingresa un celular de al menos 7 dígitos.'
    if (editando === 'nuevo' && form.password.length < 6) e.password = 'Usa al menos 6 caracteres.'
    if (form.rol === 'Barbero' && !form.barberoId) e.barberoId = 'Elige el barbero de esta cuenta.'
    setErrores(e)
    if (Object.keys(e).length) return
    const barberoId = form.rol === 'Barbero' ? form.barberoId : null
    try {
      if (editando === 'nuevo') {
        await createMutation.mutateAsync({ nombre: form.nombre.trim(), apellido: form.apellido.trim(), correo: form.correo.trim(), telefono: form.telefono.trim(), password: form.password, rol: form.rol, barberoId })
        toast.success(`Cuenta creada para ${form.nombre.trim()}`)
      } else if (editando) {
        await updateMutation.mutateAsync({ id: editando.id, payload: { nombre: form.nombre.trim(), apellido: form.apellido.trim(), telefono: form.telefono.trim(), rol: form.rol, barberoId } })
        toast.success('Cambios guardados')
      }
      setEditando(null)
    } catch (err) {
      toast.error(mensajeDeError(err, 'No pudimos guardar el usuario. Inténtalo de nuevo.'))
    }
  }
  const confirmarEstado = async () => {
    if (!cambiarEstado) return
    const u = cambiarEstado
    try {
      if (u.activo) await removeMutation.mutateAsync(u.id)
      else await updateMutation.mutateAsync({ id: u.id, payload: { barberoId: u.barberoId, activo: true } })
      toast.success(u.activo ? `${u.nombre} ya no puede entrar al panel` : `${u.nombre} puede volver a entrar`)
      setCambiarEstado(null)
    } catch (err) {
      toast.error(mensajeDeError(err, 'No pudimos cambiar el estado de la cuenta.'))
    }
  }

  const columnas: TableColumn<UserDto>[] = [
    {
      key: 'usuario',
      label: 'Usuario',
      render: (u) => (
        <span className="flex items-center gap-3 text-left">
          <Avatar name={`${u.nombre} ${u.apellido}`} size={32} />
          <span className="flex min-w-0 flex-col">
            <strong className="truncate text-label-sm text-ink">
              {u.nombre} {u.apellido}
            </strong>
            <span className="truncate text-caption text-ink-muted">{u.correo}</span>
          </span>
        </span>
      ),
    },
    {
      key: 'rol',
      label: 'Rol',
      render: (u) => (ES_EQUIPO(u.rol) ? <Badge tone={u.rol === 'Barbero' ? 'neutral' : 'brass'} icon={ROLES[u.rol].icon}>{ROLES[u.rol].label}</Badge> : u.rol),
    },
    { key: 'vinculado', label: 'Barbero vinculado', muted: true, render: (u) => (u.rol === 'Barbero' ? (nombreBarbero(u.barberoId) ?? 'Barbero inactivo') : '—') },
    { key: 'estado', label: 'Estado', render: (u) => (u.activo ? <Badge tone="success" icon="circle-check">Activo</Badge> : <Badge tone="neutral" icon="ban">Inactivo</Badge>) },
    {
      key: 'acciones',
      label: 'Acciones',
      align: 'right',
      render: (u) =>
        puedeGestionar(u) ? (
          <span className="inline-flex gap-1" onClick={(e) => e.stopPropagation()}>
            <IconButton icon="pencil" size="sm" label={`Editar a ${u.nombre}`} onClick={() => abrir(u)} />
            {u.rol !== 'Admin' && <IconButton icon={u.activo ? 'ban' : 'rotate-ccw'} size="sm" label={`${u.activo ? 'Desactivar' : 'Activar'} a ${u.nombre}`} onClick={() => setCambiarEstado(u)} />}
          </span>
        ) : (
          <span className="text-caption text-ink-muted">Solo el administrador</span>
        ),
    },
  ]

  const guardando = createMutation.isPending || updateMutation.isPending
  const opcionesBarbero = barberos.filter((b) => !vinculados.has(b.id)).map((b) => ({ value: b.id, label: `${b.nombre} ${b.apellido}` }))

  return (
    <div className="mx-auto flex max-w-[1200px] flex-col gap-5 px-4 py-5 md:px-6 lg:px-8">
      <PageHeader
        title="Cuentas del equipo"
        subtitle={
          <>
            Quién entra al panel y con qué rol. Los clientes se gestionan en <Link to="/clientes">Clientes</Link>.
          </>
        }
        actions={
          <Button icon="user-plus" onClick={() => abrir('nuevo')}>
            Nuevo usuario
          </Button>
        }
      />

      <div role="group" aria-label="Filtrar por rol" className="bsm-chip-row">
        <Chip selected={filtro === 'Todos'} count={equipo.length} onClick={() => setFiltro('Todos')}>
          Todos
        </Chip>
        {(Object.keys(ROLES) as Rol[]).map((r) => (
          <Chip key={r} selected={filtro === r} icon={ROLES[r].icon} count={equipo.filter((u) => u.rol === r).length} onClick={() => setFiltro(r)}>
            {ROLES[r].label}
          </Chip>
        ))}
      </div>

      <Table
        caption="Cuentas del equipo"
        columns={columnas}
        rows={visibles}
        rowKey={(u) => u.id}
        onRowClick={(u) => (puedeGestionar(u) ? abrir(u) : undefined)}
        state={
          usersQuery.isError ? (
            <EmptyState tone="error" title="No pudimos cargar las cuentas" body="Revisa tu conexión e inténtalo de nuevo." actionLabel="Reintentar" actionIcon="refresh-cw" actionVariant="secondary" onAction={() => void usersQuery.refetch()} />
          ) : usersQuery.isLoading ? (
            <Skeleton variant="row" rows={5} label="Cargando cuentas" />
          ) : visibles.length === 0 ? (
            <EmptyState icon="user-cog" title="No hay cuentas con ese rol" body="Elige otro rol o crea una cuenta nueva." actionLabel="Nuevo usuario" actionIcon="user-plus" onAction={() => abrir('nuevo')} />
          ) : undefined
        }
      />

      <Modal
        open={editando != null}
        onClose={() => setEditando(null)}
        dirty={dirty && !guardando}
        title={editando === 'nuevo' ? 'Nuevo usuario' : 'Editar usuario'}
        subtitle={editando && editando !== 'nuevo' ? editando.correo : 'Entrará al panel con su correo y esta contraseña.'}
        footer={
          <>
            <Button variant="secondary" onClick={() => setEditando(null)} disabled={guardando}>
              Cancelar
            </Button>
            <Button icon="check" onClick={() => void guardar()} loading={guardando}>
              {guardando ? 'Guardando…' : editando === 'nuevo' ? 'Crear usuario' : 'Guardar cambios'}
            </Button>
          </>
        }
      >
        <div className="flex flex-col gap-2">
          <span className="text-label-sm text-ink">Rol</span>
          <div role="radiogroup" aria-label="Rol" className="bsm-chip-row">
            {rolesPermitidos.map((r) => (
              <Chip key={r} role="radio" aria-checked={form.rol === r} selected={form.rol === r} icon={ROLES[r].icon} onClick={() => set('rol', r)} disabled={editando !== 'nuevo' && editando?.rol === 'Admin'}>
                {ROLES[r].label}
              </Chip>
            ))}
          </div>
          <p className="text-caption text-ink-muted">{ROLES[form.rol].alcance}</p>
        </div>

        {form.rol === 'Barbero' && (
          <Select
            label="Barbero vinculado"
            placeholder={opcionesBarbero.length ? 'Elige un barbero' : 'Todos los barberos ya tienen cuenta'}
            value={form.barberoId}
            options={[...(form.barberoId && !opcionesBarbero.some((o) => o.value === form.barberoId) ? [{ value: form.barberoId, label: nombreBarbero(form.barberoId) ?? 'Barbero inactivo' }] : []), ...opcionesBarbero]}
            hint="Solo aparecen barberos activos sin cuenta. Verá su agenda al entrar."
            error={errores.barberoId}
            onChange={(e) => elegirBarbero(e.target.value)}
          />
        )}

        <div className="grid gap-4 md:grid-cols-2">
          <Input label="Nombre" autoComplete="off" value={form.nombre} error={errores.nombre} onChange={(e) => set('nombre', e.target.value)} />
          <Input label="Apellido" autoComplete="off" value={form.apellido} error={errores.apellido} onChange={(e) => set('apellido', e.target.value)} />
        </div>
        <Input
          label="Correo"
          type="email"
          autoComplete="off"
          value={form.correo}
          disabled={editando !== 'nuevo'}
          hint={editando !== 'nuevo' ? 'El correo de acceso no se puede cambiar.' : undefined}
          error={errores.correo}
          onChange={(e) => set('correo', e.target.value)}
        />
        <Input label="Celular" type="tel" inputMode="tel" value={form.telefono} error={errores.telefono} onChange={(e) => set('telefono', e.target.value)} />
        {editando === 'nuevo' && (
          <Input label="Contraseña" type="password" revealable autoComplete="new-password" value={form.password} hint="Mínimo 6 caracteres. Compártela por un canal privado." error={errores.password} onChange={(e) => set('password', e.target.value)} />
        )}
      </Modal>

      <ConfirmDialog
        open={cambiarEstado != null}
        tone={cambiarEstado?.activo ? 'danger' : 'info'}
        icon={cambiarEstado?.activo ? 'ban' : 'rotate-ccw'}
        title={cambiarEstado?.activo ? `¿Desactivar la cuenta de ${cambiarEstado.nombre}?` : `¿Activar la cuenta de ${cambiarEstado?.nombre ?? ''}?`}
        body={cambiarEstado?.activo ? 'No podrá entrar al panel. Sus datos y citas se mantienen.' : 'Podrá volver a entrar al panel con su correo y contraseña.'}
        confirmLabel={cambiarEstado?.activo ? 'Desactivar cuenta' : 'Activar cuenta'}
        loading={removeMutation.isPending || updateMutation.isPending}
        onCancel={() => setCambiarEstado(null)}
        onConfirm={() => void confirmarEstado()}
      />
    </div>
  )
}
