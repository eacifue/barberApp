import { useState } from 'react'

import { useBarberias } from '../../hooks/useBarberias'
import { useTenantBarberia } from '../../hooks/useTenantBarberia'
import { useServicios } from '../../hooks/useServicios'
import type { Servicio, ServicioUpsertInput } from '../../types/servicio'
import { TipoServicio, TipoServicioLabel } from '../../types/servicio'
import { PageHeader } from '../../components/shared/PageHeader'
import { Badge } from '../../components/ui/Badge'
import { Button } from '../../components/ui/Button'
import { ConfirmDialog } from '../../components/ui/ConfirmDialog'
import { DataTable } from '../../components/ui/DataTable'
import { FormInput } from '../../components/ui/FormInput'
import { FormSelect } from '../../components/ui/FormSelect'
import { Modal } from '../../components/ui/Modal'
import { toast } from '../../stores/toastStore'

const initialForm: ServicioUpsertInput = {
  nombre: '',
  descripcion: '',
  tipo: TipoServicio.Corte,
  duracionMinutos: 30,
  precio: 0,
  fotoUrl: '',
  activo: true,
}

function ScissorIcon() {
  return (
    <svg viewBox="0 0 24 24" className="h-4 w-4" fill="none" aria-hidden="true">
      <circle cx="6" cy="7" r="2.5" stroke="currentColor" strokeWidth="1.6" />
      <circle cx="6" cy="17" r="2.5" stroke="currentColor" strokeWidth="1.6" />
      <path d="M8.5 8.8L20 4M8.5 15.2L20 20" stroke="currentColor" strokeWidth="1.6" />
    </svg>
  )
}

function BeardIcon() {
  return (
    <svg viewBox="0 0 24 24" className="h-4 w-4" fill="none" aria-hidden="true">
      <path d="M4 10c0 5 3.2 8 8 8s8-3 8-8" stroke="currentColor" strokeWidth="1.6" />
      <path d="M7.5 10c0 2 1.5 3.2 2.8 3.2S13 12 13 10" stroke="currentColor" strokeWidth="1.6" />
      <path d="M11 10c0 2 1.5 3.2 2.8 3.2S16.5 12 16.5 10" stroke="currentColor" strokeWidth="1.6" />
    </svg>
  )
}

function DropIcon() {
  return (
    <svg viewBox="0 0 24 24" className="h-4 w-4" fill="none" aria-hidden="true">
      <path d="M12 3s6 6 6 10a6 6 0 11-12 0c0-4 6-10 6-10z" stroke="currentColor" strokeWidth="1.6" />
    </svg>
  )
}

function StarIcon() {
  return (
    <svg viewBox="0 0 24 24" className="h-4 w-4" fill="none" aria-hidden="true">
      <path d="M12 3l2.7 5.6 6.2.9-4.5 4.4 1 6.1-5.4-2.9-5.4 2.9 1-6.1-4.5-4.4 6.2-.9L12 3z" stroke="currentColor" strokeWidth="1.6" />
    </svg>
  )
}

function RazorIcon() {
  return (
    <svg viewBox="0 0 24 24" className="h-4 w-4" fill="none" aria-hidden="true">
      <path d="M4 8h8l2 2h6v4H8l-4 4" stroke="currentColor" strokeWidth="1.6" />
      <path d="M12 8l-1.5-2h-4" stroke="currentColor" strokeWidth="1.6" />
    </svg>
  )
}

function getTipoStyle(tipo: TipoServicio) {
  if (tipo === TipoServicio.Corte) return { color: '#e07060', icon: <ScissorIcon /> }
  if (tipo === TipoServicio.Barba) return { color: '#5dba8e', icon: <BeardIcon /> }
  if (tipo === TipoServicio.Tinte) return { color: '#5b9bd5', icon: <DropIcon /> }
  if (tipo === TipoServicio.Combo) return { color: '#D4A017', icon: <StarIcon /> }
  if (tipo === TipoServicio.Afeitado) return { color: '#c890e8', icon: <RazorIcon /> }
  return { color: '#6b6b6b', icon: <StarIcon /> }
}

function formatCurrency(value: number) {
  return `$${Math.round(value).toLocaleString('es-CO')}`
}

export function ServiciosList() {
  const { effectiveBarberiaId, tenantError } = useTenantBarberia()
  const { barberiasQuery } = useBarberias()

  const [confirmTarget, setConfirmTarget] = useState<Servicio | null>(null)
  const { serviciosQuery, createMutation, updateMutation, removeMutation } = useServicios(effectiveBarberiaId ?? '')

  const [openModal, setOpenModal] = useState(false)
  const [editing, setEditing] = useState<Servicio | null>(null)
  const [form, setForm] = useState<ServicioUpsertInput>(initialForm)
  const [error, setError] = useState<string | null>(null)

  const servicios = serviciosQuery.data ?? []
  const isSaving = createMutation.isPending || updateMutation.isPending

  const resetForm = () => {
    setOpenModal(false)
    setEditing(null)
    setForm(initialForm)
    setError(null)
  }

  const openCreateModal = () => {
    setEditing(null)
    setForm(initialForm)
    setError(null)
    setOpenModal(true)
  }

  const openEditModal = (servicio: Servicio) => {
    setEditing(servicio)
    setForm({
      nombre: servicio.nombre,
      descripcion: servicio.descripcion ?? '',
      tipo: servicio.tipo,
      duracionMinutos: servicio.duracionMinutos,
      precio: servicio.precio,
      fotoUrl: servicio.fotoUrl ?? '',
      activo: servicio.activo,
    })
    setError(null)
    setOpenModal(true)
  }

  const onSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    setError(null)

    if (!form.nombre.trim()) {
      setError('Completa el nombre con un valor válido.')
      return
    }

    if (form.duracionMinutos < 10 || form.duracionMinutos > 240) {
      setError('La duración debe estar entre 10 y 240 minutos.')
      return
    }

    if (form.precio <= 0 || form.precio >= 1_000_000) {
      setError('El precio debe ser mayor que cero y menor a 1.000.000.')
      return
    }

    try {
      if (editing) {
        await updateMutation.mutateAsync({ id: editing.id, data: form })
        toast.success(`Servicio "${form.nombre}" actualizado correctamente.`)
      } else {
        await createMutation.mutateAsync(form)
        toast.success(`Servicio "${form.nombre}" creado correctamente.`)
      }
      resetForm()
    } catch {
      setError('No se pudo guardar el servicio. Verifica datos e intenta de nuevo.')
    }
  }

  const onDelete = (servicio: Servicio) => {
    setConfirmTarget(servicio)
  }

  const handleConfirmDelete = async () => {
    if (!confirmTarget) return
    try {
      await removeMutation.mutateAsync(confirmTarget.id)
      toast.success(`Servicio "${confirmTarget.nombre}" eliminado.`)
    } catch {
      toast.error('No se pudo eliminar el servicio. Intenta de nuevo.')
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
        title="Servicios"
        subtitle="Catalogo editable de servicios y tarifas"
        actions={<Button onClick={openCreateModal}>Nuevo servicio</Button>}
      />

      <DataTable<Servicio>
        loading={serviciosQuery.isLoading || barberiasQuery.isLoading}
        emptyMessage="No hay servicios para la barberia seleccionada"
        columns={[
          {
            key: 'nombre',
            header: 'Nombre',
            width: '1.5fr',
            render: (row) => {
              const { color, icon } = getTipoStyle(row.tipo)
              return (
                <div className="inline-flex items-center gap-2">
                  <span style={{ color }}>{icon}</span>
                  <span>{row.nombre}</span>
                </div>
              )
            },
          },
          {
            key: 'tipo',
            header: 'Tipo',
            width: '1fr',
            render: (row) => TipoServicioLabel[row.tipo],
          },
          {
            key: 'duracionMinutos',
            header: 'Duracion',
            width: '0.9fr',
            render: (row) => `${row.duracionMinutos} min`,
          },
          {
            key: 'precio',
            header: 'Precio',
            width: '0.9fr',
            render: (row) => <span className="font-semibold text-[var(--success)]">{formatCurrency(row.precio)}</span>,
          },
          {
            key: 'activo',
            header: 'Estado',
            width: '0.9fr',
            render: (row) => (
              <Badge variant={row.activo ? 'success' : 'danger'} dot>
                {row.activo ? 'Activo' : 'Inactivo'}
              </Badge>
            ),
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
                <Button size="sm" variant="danger" onClick={() => onDelete(row)} loading={removeMutation.isPending}>
                  Eliminar
                </Button>
              </div>
            ),
          },
        ]}
        data={servicios}
      />

      <Modal open={openModal} onClose={resetForm} title={editing ? 'Editar servicio' : 'Nuevo servicio'}>
        <form className="space-y-4" onSubmit={onSubmit}>
          <div className="grid grid-cols-1 gap-3 md:grid-cols-2">
            <FormInput
              label="Nombre"
              required
              value={form.nombre}
              onChange={(e) => setForm((prev) => ({ ...prev, nombre: e.target.value }))}
            />
            <FormSelect
              label="Tipo"
              required
              value={String(form.tipo)}
              onChange={(e) => setForm((prev) => ({ ...prev, tipo: Number(e.target.value) as TipoServicio }))}
              options={Object.entries(TipoServicio).map(([key, value]) => ({
                label: key,
                value: String(value),
              }))}
            />
            <FormInput
              label="Duracion (min)"
              type="number"
              required
              min={1}
              value={form.duracionMinutos}
              onChange={(e) => setForm((prev) => ({ ...prev, duracionMinutos: Number(e.target.value || 0) }))}
            />
            <FormInput
              label="Precio ($)"
              type="number"
              required
              min={0}
              step="1"
              value={form.precio}
              onChange={(e) => setForm((prev) => ({ ...prev, precio: Number(e.target.value || 0) }))}
            />
            <FormInput
              label="Foto URL"
              value={form.fotoUrl ?? ''}
              onChange={(e) => setForm((prev) => ({ ...prev, fotoUrl: e.target.value }))}
            />
            <label className="form-check-label inline-flex items-center gap-2 self-end pb-2 text-sm">
              <input
                type="checkbox"
                checked={form.activo}
                onChange={(e) => setForm((prev) => ({ ...prev, activo: e.target.checked }))}
              />
              Estado activo
            </label>

            <label className="md:col-span-2 flex flex-col gap-1.5">
              <span className="form-label text-[10px] uppercase tracking-[0.08em]">Descripcion</span>
              <textarea
                value={form.descripcion ?? ''}
                onChange={(e) => setForm((prev) => ({ ...prev, descripcion: e.target.value }))}
                className="form-control min-h-24 rounded-md px-3 py-2 outline-none"
              />
            </label>
          </div>

          {error ? <p className="form-message-error text-sm">{error}</p> : null}

          <div className="flex justify-end gap-2">
            <Button variant="ghost" onClick={resetForm}>
              Cancelar
            </Button>
            <Button type="submit" loading={isSaving}>
              {editing ? 'Guardar cambios' : 'Crear servicio'}
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
        title="Eliminar servicio"
        message={`¿Estás seguro de que deseas eliminar "${confirmTarget?.nombre}"? Esta acción no se puede deshacer.`}
      />
    </section>
  )
}
