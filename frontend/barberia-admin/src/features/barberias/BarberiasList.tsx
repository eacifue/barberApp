import { useMemo, useState } from 'react'

import { useBarberias } from '../../hooks/useBarberias'
import type { Barberia, BarberiaUpsertInput } from '../../types/barberia'
import { PageHeader } from '../../components/shared/PageHeader'
import { Badge } from '../../components/ui/Badge'
import { Button } from '../../components/ui/Button'
import { ConfirmDialog } from '../../components/ui/ConfirmDialog'
import { DataTable } from '../../components/ui/DataTable'
import { FormInput } from '../../components/ui/FormInput'
import { Modal } from '../../components/ui/Modal'
import { toast } from '../../stores/toastStore'

const days = [
  { value: 0, label: 'Dom' },
  { value: 1, label: 'Lun' },
  { value: 2, label: 'Mar' },
  { value: 3, label: 'Mie' },
  { value: 4, label: 'Jue' },
  { value: 5, label: 'Vie' },
  { value: 6, label: 'Sab' },
]

const PAISES = ['Colombia', 'México', 'Argentina', 'Chile', 'Perú', 'Ecuador', 'Venezuela', 'Otro']

const DEPARTAMENTOS_POR_PAIS: Record<string, string[]> = {
  Colombia: [
    'Antioquia', 'Cundinamarca', 'Valle del Cauca', 'Atlántico', 'Bolívar',
    'Santander', 'Córdoba', 'N. de Santander', 'Tolima', 'Cauca',
    'Nariño', 'Caldas', 'Risaralda', 'Quíndío', 'Huila',
    'Meta', 'Boyacá', 'Cesar', 'Magdalena', 'La Guajira', 'Otro',
  ],
  México: ['Ciudad de México', 'Jalisco', 'Nuevo León', 'Puebla', 'Guanajuato', 'Otro'],
  Argentina: ['Buenos Aires', 'Córdoba', 'Santa Fe', 'Mendoza', 'Tucumán', 'Otro'],
  Chile: ['Región Metropolitana', 'Valparaíso', 'Biobío', 'La Araucanía', 'Otro'],
  Perú: ['Lima', 'Arequipa', 'La Libertad', 'Cusco', 'Otro'],
  Ecuador: ['Pichincha', 'Guayas', 'Azuay', 'Manabí', 'Otro'],
  Venezuela: ['Distrito Capital', 'Miranda', 'Carabobo', 'Zulia', 'Otro'],
  Otro: [],
}

const initialForm: BarberiaUpsertInput = {
  nombre: '',
  descripcion: '',
  telefono: '',
  correo: '',
  direccion: '',
  ciudad: '',
  departamento: '',
  pais: 'Colombia',
  latitud: 0,
  longitud: 0,
  horaApertura: '09:00',
  horaCierre: '18:00',
  diasDescanso: [],
  activa: true,
}

function HomeIcon() {
  return (
    <svg viewBox="0 0 24 24" className="h-4 w-4" fill="none" aria-hidden="true">
      <path d="M3 10.5L12 3l9 7.5V21h-6.5v-6h-5V21H3v-10.5z" stroke="currentColor" strokeWidth="1.6" />
    </svg>
  )
}

export function BarberiasList() {
  const { barberiasQuery, createMutation, updateMutation, removeMutation } = useBarberias()
  const [openModal, setOpenModal] = useState(false)
  const [editing, setEditing] = useState<Barberia | null>(null)
  const [form, setForm] = useState<BarberiaUpsertInput>(initialForm)
  const [error, setError] = useState<string | null>(null)
  const [confirmTarget, setConfirmTarget] = useState<Barberia | null>(null)

  const isSaving = createMutation.isPending || updateMutation.isPending
  const barberias = barberiasQuery.data ?? []

  const modalTitle = editing ? 'Editar barberia' : 'Nueva barberia'

  const resetForm = () => {
    setForm(initialForm)
    setEditing(null)
    setError(null)
    setOpenModal(false)
  }

  const openCreateModal = () => {
    setForm(initialForm)
    setEditing(null)
    setError(null)
    setOpenModal(true)
  }

  const openEditModal = (barberia: Barberia) => {
    setForm({
      nombre: barberia.nombre,
      descripcion: barberia.descripcion ?? '',
      telefono: barberia.telefono,
      correo: barberia.correo,
      direccion: barberia.direccion,
      ciudad: barberia.ciudad,
      departamento: barberia.departamento ?? '',
      pais: barberia.pais ?? 'Colombia',
      latitud: barberia.latitud,
      longitud: barberia.longitud,
      horaApertura: barberia.horaApertura,
      horaCierre: barberia.horaCierre,
      diasDescanso: barberia.diasDescanso ?? [],
      activa: barberia.activa,
    })
    setEditing(barberia)
    setError(null)
    setOpenModal(true)
  }

  const requiredFieldsFilled = useMemo(() => {
    return (
      form.nombre.trim() &&
      form.ciudad.trim() &&
      form.departamento.trim() &&
      form.pais.trim() &&
      form.direccion.trim() &&
      form.telefono.trim() &&
      form.correo.trim() &&
      form.horaApertura.trim() &&
      form.horaCierre.trim()
    )
  }, [form])

  const onSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    setError(null)

    if (!requiredFieldsFilled) {
      setError('Completa todos los campos obligatorios marcados con *.')
      return
    }

    try {
      if (editing) {
        await updateMutation.mutateAsync({ id: editing.id, data: form })
        toast.success(`Barbería "${form.nombre}" actualizada correctamente.`)
      } else {
        await createMutation.mutateAsync(form)
        toast.success(`Barbería "${form.nombre}" creada correctamente.`)
      }
      resetForm()
    } catch {
      setError('No se pudo guardar la barberia. Revisa los datos e intenta de nuevo.')
    }
  }

  const onDelete = (barberia: Barberia) => {
    setConfirmTarget(barberia)
  }

  const handleConfirmDelete = async () => {
    if (!confirmTarget) return
    try {
      await removeMutation.mutateAsync(confirmTarget.id)
      toast.success(`Barbería "${confirmTarget.nombre}" eliminada.`)
    } catch {
      toast.error('No se pudo eliminar la barbería. Intenta de nuevo.')
    } finally {
      setConfirmTarget(null)
    }
  }

  return (
    <section className="relative">
      <PageHeader
        title="Barberias"
        subtitle="Gestion de sucursales, datos principales y estado"
        actions={<Button onClick={openCreateModal}>Nueva barberia</Button>}
      />

      <DataTable<Barberia>
        loading={barberiasQuery.isLoading}
        emptyMessage="No hay barberias registradas"
        columns={[
          {
            key: 'nombre',
            header: 'Nombre',
            width: '1.3fr',
            render: (row) => (
              <div className="inline-flex items-center gap-2">
                <span className="text-[var(--gold-l)]">
                  <HomeIcon />
                </span>
                <span>{row.nombre}</span>
              </div>
            ),
          },
          { key: 'direccion', header: 'Ubicacion', width: '1.6fr',
            render: (row) => (
              <span className="text-color-base">
                {row.ciudad}{row.departamento ? `, ${row.departamento}` : ''}
                {row.pais ? <span className="ml-1 text-color-muted">· {row.pais}</span> : null}
              </span>
            ),
          },
          {
            key: 'horario',
            header: 'Horario',
            width: '1fr',
            render: (row) => `${row.horaApertura} - ${row.horaCierre}`,
          },
          {
            key: 'totalBarberos',
            header: '# Barberos',
            width: '0.8fr',
            render: (row) => row.totalBarberos ?? 0,
          },
          {
            key: 'activa',
            header: 'Estado',
            width: '0.9fr',
            render: (row) => (
              <Badge variant={row.activa ? 'success' : 'danger'} dot>
                {row.activa ? 'Activa' : 'Inactiva'}
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
        data={barberias}
      />

      <Modal open={openModal} onClose={resetForm} title={modalTitle} size="lg">
        <form className="space-y-4" onSubmit={onSubmit}>
          <div className="grid grid-cols-1 gap-3 md:grid-cols-2">
            <FormInput
              label="Nombre"
              required
              value={form.nombre}
              onChange={(e) => setForm((prev) => ({ ...prev, nombre: e.target.value }))}
            />
            <FormInput
              label="Ciudad"
              required
              value={form.ciudad}
              onChange={(e) => setForm((prev) => ({ ...prev, ciudad: e.target.value }))}
            />

            {/* País */}
            <label className="flex flex-col gap-1.5">
              <span className="form-label text-[10px] uppercase tracking-[0.08em]">
                País <span className="text-[var(--danger)]" aria-hidden="true">*</span>
              </span>
              <select
                required
                value={form.pais}
                onChange={(e) =>
                  setForm((prev) => ({ ...prev, pais: e.target.value, departamento: '' }))
                }
                className="form-control h-9 rounded-md px-3 text-sm outline-none"
              >
                <option value="">Selecciona un país…</option>
                {PAISES.map((p) => (
                  <option key={p} value={p}>{p}</option>
                ))}
              </select>
            </label>

            {/* Estado / Departamento */}
            <label className="flex flex-col gap-1.5">
              <span className="form-label text-[10px] uppercase tracking-[0.08em]">
                Estado / Departamento <span className="text-[var(--danger)]" aria-hidden="true">*</span>
              </span>
              {(DEPARTAMENTOS_POR_PAIS[form.pais] ?? []).length > 0 ? (
                <select
                  required
                  value={form.departamento}
                  onChange={(e) => setForm((prev) => ({ ...prev, departamento: e.target.value }))}
                  className="form-control h-9 rounded-md px-3 text-sm outline-none"
                >
                  <option value="">Selecciona un departamento…</option>
                  {(DEPARTAMENTOS_POR_PAIS[form.pais] ?? []).map((d) => (
                    <option key={d} value={d}>{d}</option>
                  ))}
                </select>
              ) : (
                <input
                  required
                  type="text"
                  placeholder="Escribe el departamento"
                  value={form.departamento}
                  onChange={(e) => setForm((prev) => ({ ...prev, departamento: e.target.value }))}
                  className="form-control h-9 rounded-md px-3 text-sm outline-none"
                />
              )}
            </label>
            <FormInput
              label="Direccion"
              required
              value={form.direccion}
              onChange={(e) => setForm((prev) => ({ ...prev, direccion: e.target.value }))}
            />
            <FormInput
              label="Telefono"
              required
              value={form.telefono}
              onChange={(e) => setForm((prev) => ({ ...prev, telefono: e.target.value }))}
            />
            <FormInput
              label="Correo"
              type="email"
              required
              value={form.correo}
              onChange={(e) => setForm((prev) => ({ ...prev, correo: e.target.value }))}
            />
            <FormInput
              label="Hora apertura"
              type="time"
              required
              value={form.horaApertura}
              onChange={(e) => setForm((prev) => ({ ...prev, horaApertura: e.target.value }))}
            />
            <FormInput
              label="Hora cierre"
              type="time"
              required
              value={form.horaCierre}
              onChange={(e) => setForm((prev) => ({ ...prev, horaCierre: e.target.value }))}
            />

            <div className="md:col-span-2">
              <p className="form-label mb-1.5 text-[10px] uppercase tracking-[0.08em]">
                Dias de descanso
              </p>
              <div className="flex flex-wrap gap-2">
                {days.map((day) => {
                  const checked = form.diasDescanso.includes(day.value)
                  return (
                    <label
                      key={day.value}
                      className="form-check-label inline-flex cursor-pointer items-center gap-1.5 rounded-md border border-[var(--input-border)] bg-[var(--input-bg)] px-2.5 py-1.5 text-xs"
                    >
                      <input
                        type="checkbox"
                        checked={checked}
                        onChange={(e) => {
                          setForm((prev) => ({
                            ...prev,
                            diasDescanso: e.target.checked
                              ? [...prev.diasDescanso, day.value]
                              : prev.diasDescanso.filter((d) => d !== day.value),
                          }))
                        }}
                      />
                      {day.label}
                    </label>
                  )
                })}
              </div>
            </div>

            <FormInput
              label="Latitud"
              type="number"
              step="any"
              value={form.latitud}
              onChange={(e) => setForm((prev) => ({ ...prev, latitud: Number(e.target.value || 0) }))}
            />
            <FormInput
              label="Longitud"
              type="number"
              step="any"
              value={form.longitud}
              onChange={(e) => setForm((prev) => ({ ...prev, longitud: Number(e.target.value || 0) }))}
            />

            <label className="md:col-span-2 flex flex-col gap-1.5">
              <span className="form-label text-[10px] uppercase tracking-[0.08em]">Descripcion</span>
              <textarea
                value={form.descripcion ?? ''}
                onChange={(e) => setForm((prev) => ({ ...prev, descripcion: e.target.value }))}
                className="form-control min-h-24 rounded-md px-3 py-2 outline-none"
              />
            </label>

            <label className="form-check-label md:col-span-2 inline-flex items-center gap-2 text-sm">
              <input
                type="checkbox"
                checked={form.activa}
                onChange={(e) => setForm((prev) => ({ ...prev, activa: e.target.checked }))}
              />
              Activa
            </label>
          </div>

          {error ? <p className="form-message-error text-sm">{error}</p> : null}

          <div className="flex justify-end gap-2">
            <Button variant="ghost" onClick={resetForm}>
              Cancelar
            </Button>
            <Button type="submit" loading={isSaving}>
              {editing ? 'Guardar cambios' : 'Crear barberia'}
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
        title="Eliminar barbería"
        message={`¿Estás seguro de que deseas eliminar "${confirmTarget?.nombre}"? Esta acción no se puede deshacer.`}
      />
    </section>
  )
}
