import { useEffect, useMemo, useState } from 'react'
import { Plus } from 'lucide-react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'

import { userService, type CreateUserPayload, type UpdateUserPayload, type UserDto } from '../../services/userService'
import { barberiaService } from '../../services/barberiaService'
import { PageHeader } from '../../components/shared/PageHeader'
import { Badge } from '../../components/ui/Badge'
import { Button } from '../../components/ui/Button'
import { ConfirmDialog } from '../../components/ui/ConfirmDialog'
import { DataTable } from '../../components/ui/DataTable'
import { FormInput } from '../../components/ui/FormInput'
import { FormSelect } from '../../components/ui/FormSelect'
import { Modal } from '../../components/ui/Modal'
import { useAuthStore } from '../../stores/authStore'
import { useToastStore } from '../../stores/toastStore'

const ROLES = ['Admin', 'AdministradorBarberia', 'Barbero', 'Cliente'] as const
type Role = typeof ROLES[number]

const ROL_LABEL: Record<Role, string> = {
  Admin: 'Admin',
  AdministradorBarberia: 'Admin Barbería',
  Barbero: 'Barbero',
  Cliente: 'Cliente',
}

const ROL_BADGE: Record<Role, 'warning' | 'info' | 'success' | 'muted'> = {
  Admin: 'warning',
  AdministradorBarberia: 'info',
  Barbero: 'success',
  Cliente: 'muted',
}

const EMPTY_FORM: CreateUserPayload = {
  nombre: '',
  apellido: '',
  correo: '',
  telefono: '',
  password: '',
  rol: 'Cliente',
  barberiaId: null,
  barberoId: null,
}

export function UsersPage() {
  const qc = useQueryClient()
  const addToast = useToastStore((s) => s.push)
  const isGlobalAdmin = useAuthStore((s) => s.isAdmin())

  const [modalOpen, setModalOpen] = useState(false)
  const [editUser, setEditUser] = useState<UserDto | null>(null)
  const [form, setForm] = useState<CreateUserPayload>(EMPTY_FORM)
  const [deleteConfirm, setDeleteConfirm] = useState<UserDto | null>(null)

  const roleRequiresBarberia = form.rol === 'AdministradorBarberia' || form.rol === 'Barbero'
  const showBarberiaSelect = roleRequiresBarberia && isGlobalAdmin

  const barberiasQuery = useQuery({
    queryKey: ['barberias-for-users-form'],
    queryFn: barberiaService.getAll,
    enabled: isGlobalAdmin,
  })
  const barberias = barberiasQuery.data ?? []

  useEffect(() => {
    if (!roleRequiresBarberia) {
      setForm((prev) => ({ ...prev, barberiaId: null }))
      return
    }

    if (showBarberiaSelect && !form.barberiaId && barberias.length > 0) {
      setForm((prev) => ({ ...prev, barberiaId: barberias[0].id }))
    }
  }, [roleRequiresBarberia, showBarberiaSelect, form.barberiaId, barberias])

  const { data: users = [], isLoading } = useQuery({
    queryKey: ['users'],
    queryFn: userService.getAll,
  })

  const createMutation = useMutation({
    mutationFn: userService.create,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['users'] })
      addToast('Usuario creado correctamente.', 'success')
      closeModal()
    },
    onError: (err: { response?: { data?: { message?: string } } }) => {
      addToast(err.response?.data?.message ?? 'Error al crear usuario.', 'error')
    },
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, payload }: { id: string; payload: UpdateUserPayload }) =>
      userService.update(id, payload),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['users'] })
      addToast('Usuario actualizado.', 'success')
      closeModal()
    },
    onError: (err: { response?: { data?: { message?: string } } }) => {
      addToast(err.response?.data?.message ?? 'Error al actualizar.', 'error')
    },
  })

  const deleteMutation = useMutation({
    mutationFn: userService.remove,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['users'] })
      addToast('Usuario desactivado.', 'success')
      setDeleteConfirm(null)
    },
    onError: (err: { response?: { data?: { message?: string } } }) => {
      addToast(err.response?.data?.message ?? 'Error al eliminar.', 'error')
    },
  })

  function openCreate() {
    setEditUser(null)
    setForm(EMPTY_FORM)
    setModalOpen(true)
  }

  function openEdit(user: UserDto) {
    setEditUser(user)
    setForm({
      nombre: user.nombre,
      apellido: user.apellido,
      correo: user.correo,
      telefono: user.telefono,
      password: '',
      rol: user.rol,
      barberiaId: user.barberiaId,
      barberoId: user.barberoId,
    })
    setModalOpen(true)
  }

  function closeModal() {
    setModalOpen(false)
    setEditUser(null)
    setForm(EMPTY_FORM)
  }

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()

    if (showBarberiaSelect && !form.barberiaId) {
      addToast('Debes seleccionar una barbería para este rol.', 'error')
      return
    }

    if (editUser) {
      const payload: UpdateUserPayload = {
        nombre: form.nombre,
        apellido: form.apellido,
        telefono: form.telefono,
        rol: form.rol,
        barberiaId: form.barberiaId ?? null,
        barberoId: form.barberoId ?? null,
      }
      updateMutation.mutate({ id: editUser.id, payload })
    } else {
      createMutation.mutate(form)
    }
  }

  const isBusy = createMutation.isPending || updateMutation.isPending

  const roleOptions = useMemo(
    () => ROLES.map((role) => ({ label: ROL_LABEL[role], value: role })),
    [],
  )

  const barberiaOptions = useMemo(
    () => [
      {
        label: barberiasQuery.isLoading ? 'Cargando barberías...' : 'Selecciona una barbería',
        value: '',
      },
      ...barberias.map((barberia) => ({ label: barberia.nombre, value: barberia.id })),
    ],
    [barberias, barberiasQuery.isLoading],
  )

  const columns = useMemo(
    () => [
      {
        key: 'nombre',
        header: 'Usuario',
        width: '1.25fr',
        render: (row: UserDto) => (
          <div>
            <p className="font-semibold text-[var(--text-strong)]">{row.nombre} {row.apellido}</p>
            <p className="mt-1 text-xs text-[var(--text-faint)]">{row.telefono}</p>
          </div>
        ),
      },
      {
        key: 'correo',
        header: 'Correo',
        width: '1.1fr',
        render: (row: UserDto) => <span className="text-[var(--text-muted)]">{row.correo}</span>,
      },
      {
        key: 'rol',
        header: 'Rol',
        width: '0.9fr',
        render: (row: UserDto) => <Badge variant={ROL_BADGE[row.rol as Role] ?? 'muted'}>{ROL_LABEL[row.rol as Role] ?? row.rol}</Badge>,
      },
      {
        key: 'activo',
        header: 'Estado',
        width: '0.8fr',
        render: (row: UserDto) => <Badge variant={row.activo ? 'success' : 'danger'}>{row.activo ? 'Activo' : 'Inactivo'}</Badge>,
      },
      {
        key: 'acciones',
        header: 'Acciones',
        width: '0.9fr',
        render: (row: UserDto) => (
          <div className="flex justify-end gap-2">
            <Button size="sm" variant="ghost" onClick={() => openEdit(row)}>Editar</Button>
            {row.rol !== 'Admin' ? (
              <Button size="sm" variant="danger" onClick={() => setDeleteConfirm(row)}>Desactivar</Button>
            ) : null}
          </div>
        ),
      },
    ],
    [barberias, barberiasQuery.isLoading],
  )

  return (
    <div className="space-y-6">
      <PageHeader
        title="Usuarios"
        subtitle="Gestiona cuentas, roles y estados del sistema con una tabla más clara y formularios consistentes."
        actions={
          <Button onClick={openCreate}>
            <Plus className="h-4 w-4" />
            Nuevo usuario
          </Button>
        }
      />

      {isLoading ? (
        <div className="surface-panel rounded-[28px] px-5 py-10 text-center text-sm text-[var(--text-muted)]">Cargando usuarios…</div>
      ) : (
        <DataTable columns={columns} data={users} emptyMessage="No hay usuarios creados todavía." />
      )}

      <Modal open={modalOpen} title={editUser ? 'Editar usuario' : 'Nuevo usuario'} onClose={closeModal} size="md">
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid gap-4 md:grid-cols-2">
            <FormInput required label="Nombre" value={form.nombre} onChange={(e) => setForm((f) => ({ ...f, nombre: e.target.value }))} />
            <FormInput required label="Apellido" value={form.apellido} onChange={(e) => setForm((f) => ({ ...f, apellido: e.target.value }))} />
          </div>

          <FormInput required type="email" label="Correo" disabled={Boolean(editUser)} value={form.correo} onChange={(e) => setForm((f) => ({ ...f, correo: e.target.value }))} />

          <FormInput required label="Teléfono" value={form.telefono} onChange={(e) => setForm((f) => ({ ...f, telefono: e.target.value }))} />

          {!editUser ? (
            <FormInput required type="password" label="Contraseña" value={form.password} onChange={(e) => setForm((f) => ({ ...f, password: e.target.value }))} />
          ) : null}

          <FormSelect label="Rol" value={form.rol} onChange={(e) => setForm((f) => ({ ...f, rol: e.target.value }))} options={roleOptions} />

          {showBarberiaSelect ? (
            <div>
              <FormSelect
                required
                label="Barbería"
                value={form.barberiaId ?? ''}
                onChange={(e) => setForm((f) => ({ ...f, barberiaId: e.target.value || null }))}
                disabled={barberiasQuery.isLoading || barberias.length === 0}
                options={barberiaOptions}
              />
              {!barberiasQuery.isLoading && barberias.length === 0 ? (
                <p className="mt-2 text-xs text-[var(--warning)]">No hay barberías disponibles para asociar.</p>
              ) : null}
            </div>
          ) : null}

          {form.rol === 'Barbero' ? (
            <FormInput
              label="Barbero ID (UUID)"
              value={form.barberoId ?? ''}
              onChange={(e) => setForm((f) => ({ ...f, barberoId: e.target.value || null }))}
              placeholder="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
            />
          ) : null}

          <div className="flex justify-end gap-3 pt-2">
            <Button type="button" variant="ghost" onClick={closeModal}>Cancelar</Button>
            <Button type="submit" disabled={isBusy}>{isBusy ? 'Guardando…' : editUser ? 'Actualizar' : 'Crear'}</Button>
          </div>
        </form>
      </Modal>

      <ConfirmDialog
        open={Boolean(deleteConfirm)}
        onClose={() => setDeleteConfirm(null)}
        onConfirm={() => {
          if (deleteConfirm) deleteMutation.mutate(deleteConfirm.id)
        }}
        loading={deleteMutation.isPending}
        variant="warning"
        confirmLabel="Desactivar"
        title="Desactivar usuario"
        message={
          deleteConfirm
            ? `¿Deseas desactivar a ${deleteConfirm.nombre} ${deleteConfirm.apellido} (${deleteConfirm.correo})? Podrá reactivarse más adelante.`
            : ''
        }
      />
    </div>
  )
}
