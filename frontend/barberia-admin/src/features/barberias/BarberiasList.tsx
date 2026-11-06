import { useMemo, useState } from 'react'

import { useBarberias } from '../../hooks/useBarberias'
import type { Barberia, BarberiaUpsertInput } from '../../types/barberia'
import { PageHeader } from '../../components/shared/PageHeader'
import { Button } from '../../components/ui/Button'
import { FormInput } from '../../components/ui/FormInput'
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

/**
 * La app solo maneja una barbería, así que esta pantalla es un formulario de
 * configuración de "Mi negocio" — ver/editar los datos de la única
 * barbería, sin crear ni eliminar (ver roadmap de migración, sub-fase 3.4).
 */
export function BarberiasList() {
  const { barberiasQuery } = useBarberias()
  const barberia = barberiasQuery.data?.[0] ?? null

  return (
    <section className="relative">
      <PageHeader title="Mi negocio" subtitle="Datos de tu barbería visibles para tus clientes en la app" />

      {barberiasQuery.isLoading ? (
        <div className="surface-panel rounded-[28px] px-5 py-10 text-center text-sm text-[var(--text-ink-muted)]">
          Cargando…
        </div>
      ) : !barberia ? (
        <div className="surface-panel rounded-[28px] px-5 py-10 text-center text-sm text-[var(--warning)]">
          No hay una barbería configurada. Contacta a soporte.
        </div>
      ) : (
        <BarberiaForm key={barberia.id} barberia={barberia} />
      )}
    </section>
  )
}

function BarberiaForm({ barberia }: { barberia: Barberia }) {
  const { updateMutation } = useBarberias()
  const [form, setForm] = useState<BarberiaUpsertInput>(() => ({
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
  }))
  const [error, setError] = useState<string | null>(null)

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
      await updateMutation.mutateAsync({ id: barberia.id, data: form })
      toast.success('Datos de la barbería actualizados correctamente.')
    } catch {
      setError('No se pudo guardar la barbería. Revisa los datos e intenta de nuevo.')
    }
  }

  return (
    <form className="surface-panel max-w-3xl space-y-4 rounded-[28px] p-6" onSubmit={onSubmit}>
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
            <Button type="submit" loading={updateMutation.isPending}>
              Guardar cambios
            </Button>
          </div>
        </form>
  )
}
