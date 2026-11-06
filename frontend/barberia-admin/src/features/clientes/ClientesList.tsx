import { useMemo, useState } from 'react'

import { useClientes } from '../../hooks/useClientes'
import { useTenantBarberia } from '../../hooks/useTenantBarberia'
import type { Cliente, ClienteUpsertInput } from '../../types/cliente'
import { PageHeader } from '../../components/shared/PageHeader'
import { Avatar } from '../../components/ui/Avatar'
import { Badge } from '../../components/ui/Badge'
import { Button } from '../../components/ui/Button'
import { ConfirmDialog } from '../../components/ui/ConfirmDialog'
import { DataTable } from '../../components/ui/DataTable'
import { FormInput } from '../../components/ui/FormInput'
import { Modal } from '../../components/ui/Modal'

type ViewMode = 'tabla' | 'cards'

const initialForm: ClienteUpsertInput = {
  nombre: '',
  apellido: '',
  correo: '',
  telefono: '',
  password: '',
  activo: true,
}

function BellActiveIcon() {
  return (
    <svg viewBox="0 0 24 24" className="h-4 w-4" fill="none" aria-hidden="true">
      <path
        d="M12 4.5a4.5 4.5 0 00-4.5 4.5V11c0 1.6-.6 3.2-1.8 4.3L4.5 16.5h15l-1.2-1.2A6.1 6.1 0 0116.5 11V9A4.5 4.5 0 0012 4.5zM9.5 18a2.5 2.5 0 005 0"
        stroke="currentColor"
        strokeWidth="1.6"
      />
      <circle cx="18.5" cy="6" r="2.2" fill="currentColor" />
    </svg>
  )
}

function BellOffIcon() {
  return (
    <svg viewBox="0 0 24 24" className="h-4 w-4" fill="none" aria-hidden="true">
      <path
        d="M12 4.5a4.5 4.5 0 00-4.5 4.5V11c0 1.6-.6 3.2-1.8 4.3L4.5 16.5h15l-1.2-1.2A6.1 6.1 0 0116.5 11V9A4.5 4.5 0 0012 4.5zM9.5 18a2.5 2.5 0 005 0"
        stroke="currentColor"
        strokeWidth="1.6"
      />
      <path d="M5 5l14 14" stroke="currentColor" strokeWidth="1.6" />
    </svg>
  )
}

function formatDate(dateIso?: string) {
  if (!dateIso) return '-'
  const date = new Date(dateIso)
  if (Number.isNaN(date.getTime())) return '-'
  return date.toLocaleDateString('es-CO')
}

function daysSince(dateIso?: string) {
  if (!dateIso) return 'Sin visitas'
  const date = new Date(dateIso)
  if (Number.isNaN(date.getTime())) return 'Sin visitas'
  const diff = Math.max(0, Math.floor((Date.now() - date.getTime()) / (1000 * 60 * 60 * 24)))
  return `hace ${diff} dias`
}

export function ClientesList() {
  const { clientesQuery, createMutation, updateMutation } = useClientes()
  const { isAdmin, isAdminBarberia, effectiveBarberiaId, tenantError } = useTenantBarberia()

  const [viewMode, setViewMode] = useState<ViewMode>('tabla')
  const [openModal, setOpenModal] = useState(false)
  const [editing, setEditing] = useState<Cliente | null>(null)
  const [form, setForm] = useState<ClienteUpsertInput>(initialForm)
  const [error, setError] = useState<string | null>(null)
  const [confirmTarget, setConfirmTarget] = useState<Cliente | null>(null)

  const clientes = clientesQuery.data ?? []
  const isSaving = createMutation.isPending || updateMutation.isPending
  const canManage = isAdmin || isAdminBarberia

  const modalTitle = useMemo(() => (editing ? 'Editar cliente' : 'Nuevo cliente'), [editing])

  const resetForm = () => {
    setOpenModal(false)
    setEditing(null)
    setForm(initialForm)
    setError(null)
  }

  const openCreateModal = () => {
    if (!canManage) return
    setEditing(null)
    setForm(initialForm)
    setError(null)
    setOpenModal(true)
  }

  const openEditModal = (cliente: Cliente) => {
    if (!canManage) return
    setEditing(cliente)
    setForm({
      nombre: cliente.nombre,
      apellido: cliente.apellido,
      correo: cliente.correo,
      telefono: cliente.telefono,
      password: '',
      activo: cliente.activo,
    })
    setError(null)
    setOpenModal(true)
  }

  const onSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    setError(null)

    if (!canManage) {
      setError('No tienes permisos para modificar clientes desde esta pantalla.')
      return
    }

    if (!form.nombre.trim() || !form.apellido.trim() || !form.correo.trim() || !form.telefono.trim()) {
      setError('Nombre, apellido, correo y teléfono son obligatorios.')
      return
    }

    if (!editing && !(form.password ?? '').trim()) {
      setError('La contraseña es obligatoria para crear clientes.')
      return
    }

    if ((form.password ?? '').trim().length > 0 && (form.password ?? '').trim().length < 6) {
      setError('La contraseña debe tener al menos 6 caracteres.')
      return
    }

    try {
      if (editing) {
        await updateMutation.mutateAsync({ id: editing.id, data: form })
      } else {
        await createMutation.mutateAsync(form)
      }
      resetForm()
    } catch {
      setError('No se pudo guardar el cliente. Intenta nuevamente.')
    }
  }

  const onToggleActivo = (cliente: Cliente) => {
    if (!canManage) return
    setConfirmTarget(cliente)
  }

  const handleConfirmToggle = async () => {
    if (!confirmTarget) return
    try {
      await updateMutation.mutateAsync({
        id: confirmTarget.id,
        data: {
          nombre: confirmTarget.nombre,
          apellido: confirmTarget.apellido,
          correo: confirmTarget.correo,
          telefono: confirmTarget.telefono,
          password: '',
          activo: !confirmTarget.activo,
        },
      })
    } finally {
      setConfirmTarget(null)
    }
  }

  if (tenantError) {
    return (
      <section className="relative">
        <PageHeader
          title="Clientes"
          subtitle="No se pudo cargar la vista de clientes por configuración incompleta del tenant"
        />
        <div className="surface-panel rounded-[28px] px-5 py-10 text-center text-sm text-[var(--warning)]">
          {tenantError}
        </div>
      </section>
    )
  }

  return (
    <section className="relative">
      <PageHeader
        title="Clientes"
        subtitle={
          isAdminBarberia
            ? `Base de clientes e historial de tu barbería${effectiveBarberiaId ? '' : ' (sin barbería asignada)'}`
            : 'Base de clientes, historial y segmentacion'
        }
        actions={
          <div className="flex items-center gap-2">
            <Button
              variant={viewMode === 'tabla' ? 'gold' : 'ghost'}
              size="sm"
              onClick={() => setViewMode('tabla')}
            >
              Tabla
            </Button>
            <Button
              variant={viewMode === 'cards' ? 'gold' : 'ghost'}
              size="sm"
              onClick={() => setViewMode('cards')}
            >
              Cards
            </Button>
            {canManage ? <Button onClick={openCreateModal}>Nuevo cliente</Button> : null}
          </div>
        }
      />

      {viewMode === 'tabla' ? (
        <DataTable<Cliente>
          loading={clientesQuery.isLoading}
          emptyMessage="No hay clientes registrados"
          onRowClick={canManage ? openEditModal : undefined}
          columns={[
            {
              key: 'nombre',
              header: 'Nombre',
              width: '1.4fr',
              render: (row) => (
                <div className="inline-flex items-center gap-2.5">
                  <Avatar fotoUrl={row.fotoUrl} nombre={row.nombre} apellido={row.apellido} size="md" />
                  <span>{row.nombre} {row.apellido}</span>
                </div>
              ),
            },
            { key: 'correo', header: 'Correo', width: '1.4fr' },
            { key: 'telefono', header: 'Telefono', width: '1fr' },
            {
              key: 'fcm',
              header: 'FCM',
              width: '0.6fr',
              render: (row) => (
                <span className={row.tokenFCM ? 'text-[var(--success)]' : 'text-ink-muted'}>
                  {row.tokenFCM ? <BellActiveIcon /> : <BellOffIcon />}
                </span>
              ),
            },
            {
              key: 'totalCitas',
              header: 'Total citas',
              width: '0.8fr',
              render: (row) => row.totalCitas,
            },
            {
              key: 'ultimaCita',
              header: 'Ultima visita',
              width: '1fr',
              render: (row) => formatDate(row.ultimaCita),
            },
            {
              key: 'estado',
              header: 'Estado',
              width: '0.8fr',
              render: (row) => (
                <Badge variant={row.activo ? 'success' : 'danger'} dot>
                  {row.activo ? 'Activo' : 'Inactivo'}
                </Badge>
              ),
            },
            ...(canManage
              ? [
                  {
                    key: 'acciones',
                    header: 'Acciones',
                    width: '1fr',
                    render: (row: Cliente) => (
                      <div className="flex items-center gap-2" onClick={(e) => e.stopPropagation()}>
                        <Button size="sm" variant="ghost" onClick={() => openEditModal(row)}>
                          Editar
                        </Button>
                        <Button
                          size="sm"
                          variant={row.activo ? 'danger' : 'gold'}
                          onClick={() => onToggleActivo(row)}
                          loading={updateMutation.isPending && confirmTarget?.id === row.id}
                        >
                          {row.activo ? 'Desactivar' : 'Activar'}
                        </Button>
                      </div>
                    ),
                  },
                ]
              : []),
          ]}
          data={clientes}
        />
      ) : (
        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
          {clientes.map((cliente) => (
            <article
              key={cliente.id}
              onClick={canManage ? () => openEditModal(cliente) : undefined}
              className="cursor-pointer rounded-xl border border-[var(--border2)] bg-[var(--surface2)] p-4 transition hover:bg-[var(--surface-hover)]"
            >
              <div className="mb-4 flex items-center gap-3">
                <Avatar fotoUrl={cliente.fotoUrl} nombre={cliente.nombre} apellido={cliente.apellido} size="md" />
                <div>
                  <p className="text-sm font-semibold text-ink">{cliente.nombre} {cliente.apellido}</p>
                  <p className="text-xs text-ink-muted">{cliente.correo}</p>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3 text-sm">
                <div className="rounded-lg bg-[var(--surface3)] p-2">
                  <p className="text-[10px] uppercase text-ink-muted">N Citas</p>
                  <p className="text-ink">{cliente.totalCitas}</p>
                </div>
                <div className="rounded-lg bg-[var(--surface3)] p-2">
                  <p className="text-[10px] uppercase text-ink-muted">Ultima visita</p>
                  <p className="text-ink">{daysSince(cliente.ultimaCita)}</p>
                </div>
              </div>

              {cliente.tokenFCM ? (
                <div className="mt-3">
                  <Badge variant="info">🔔 Push activo</Badge>
                </div>
              ) : null}

              {canManage ? (
                <div className="mt-3 flex items-center gap-2" onClick={(e) => e.stopPropagation()}>
                  <Button size="sm" variant="ghost" onClick={() => openEditModal(cliente)}>
                    Editar
                  </Button>
                  <Button
                    size="sm"
                    variant={cliente.activo ? 'danger' : 'gold'}
                    onClick={() => onToggleActivo(cliente)}
                    loading={updateMutation.isPending && confirmTarget?.id === cliente.id}
                  >
                    {cliente.activo ? 'Desactivar' : 'Activar'}
                  </Button>
                </div>
              ) : null}
            </article>
          ))}
          {!clientesQuery.isLoading && clientes.length === 0 ? (
            <div className="rounded-xl border border-[var(--border2)] bg-[var(--surface2)] p-6 text-center text-sm text-ink-muted md:col-span-2 xl:col-span-3">
              No hay clientes registrados
            </div>
          ) : null}
        </div>
      )}

      <Modal open={openModal} onClose={resetForm} title={modalTitle}>
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
              onChange={(e) => setForm((prev) => ({ ...prev, telefono: e.target.value }))}
            />
            <FormInput
              label={editing ? 'Nueva contraseña (opcional)' : 'Contraseña'}
              type="password"
              required={!editing}
              value={form.password ?? ''}
              onChange={(e) => setForm((prev) => ({ ...prev, password: e.target.value }))}
            />
            <label className="form-check-label md:col-span-2 inline-flex items-center gap-2 text-sm">
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
              {editing ? 'Guardar cambios' : 'Crear cliente'}
            </Button>
          </div>
        </form>
      </Modal>

      <ConfirmDialog
        open={confirmTarget !== null}
        onClose={() => setConfirmTarget(null)}
        onConfirm={handleConfirmToggle}
        loading={updateMutation.isPending}
        variant={confirmTarget?.activo ? 'warning' : 'info'}
        confirmLabel={confirmTarget?.activo ? 'Desactivar' : 'Activar'}
        title={confirmTarget?.activo ? 'Desactivar cliente' : 'Activar cliente'}
        message={
          confirmTarget
            ? `¿Deseas ${confirmTarget.activo ? 'desactivar' : 'activar'} a ${confirmTarget.nombre} ${confirmTarget.apellido}?`
            : ''
        }
      />
    </section>
  )
}
