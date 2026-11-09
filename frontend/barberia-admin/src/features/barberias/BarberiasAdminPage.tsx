import { useMemo, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useQueryClient } from '@tanstack/react-query'

import { Badge, Button, ConfirmDialog, EmptyState, IconButton, Input, Modal, Skeleton, Table, formatCOP, type TableColumn } from '../../components/bsm'
import { PageHeader } from '../../components/shared/PageHeader'
import { useBarberias, useResumenBarberias } from '../../hooks/useBarberias'
import { useTenantStore } from '../../stores/tenantStore'
import { toast } from '../../stores/toastStore'
import type { Barberia, CrearBarberiaInput } from '../../types/barberia'
import { mensajeDeError } from '../citas/agendaUtils'

type Fila = Barberia & { citasMes: number; ingresosMes: number; clientes: number; barberosActivos: number }

const CORREO = /^[^@\s]+@[^@\s]+\.[^@\s]{2,}$/

const FORM_VACIO = {
  nombre: '',
  telefono: '',
  correo: '',
  direccion: '',
  ciudad: '',
  departamento: '',
  pais: 'Colombia',
  horaApertura: '09:00',
  horaCierre: '19:00',
  adminNombre: '',
  adminApellido: '',
  adminTelefono: '',
  adminCorreo: '',
  adminPassword: '',
}
type Form = typeof FORM_VACIO
type Errores = Partial<Record<keyof Form, string>>

function validar(f: Form): Errores {
  const e: Errores = {}
  const requerido = (k: keyof Form, msg: string) => {
    if (!f[k].trim()) e[k] = msg
  }
  requerido('nombre', 'Escribe el nombre de la barbería.')
  requerido('telefono', 'Escribe un teléfono de contacto.')
  if (!CORREO.test(f.correo.trim())) e.correo = 'Escribe un correo válido, por ejemplo contacto@barberia.co.'
  requerido('direccion', 'Escribe la dirección del local.')
  requerido('ciudad', 'Escribe la ciudad.')
  requerido('departamento', 'Escribe el departamento.')
  requerido('pais', 'Escribe el país.')
  if (f.horaCierre <= f.horaApertura) e.horaCierre = 'Debe ser después de la apertura.'
  requerido('adminNombre', 'Escribe su nombre.')
  requerido('adminApellido', 'Escribe su apellido.')
  if (!CORREO.test(f.adminCorreo.trim())) e.adminCorreo = 'Escribe un correo válido. Con él entra al panel.'
  if (f.adminPassword.length < 6) e.adminPassword = 'Usa al menos 6 caracteres.'
  return e
}

/** Solo SuperAdmin: todas las barberías con su mes, alta con administrador y activar/desactivar. */
export function BarberiasAdminPage() {
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const elegir = useTenantStore((s) => s.elegir)
  const { barberiasQuery, crearMutation, estadoMutation } = useBarberias()
  const resumenQuery = useResumenBarberias()

  const [creando, setCreando] = useState(false)
  const [form, setForm] = useState<Form>(FORM_VACIO)
  const [errores, setErrores] = useState<Errores>({})
  const [cambiarEstado, setCambiarEstado] = useState<Fila | null>(null)

  const mes = new Date().toLocaleDateString('es-CO', { month: 'long' })

  const filas: Fila[] = useMemo(() => {
    const porId = new Map((resumenQuery.data ?? []).map((r) => [r.barberiaId, r]))
    return (barberiasQuery.data ?? [])
      .map((b) => {
        const r = porId.get(b.id)
        return { ...b, citasMes: r?.citasMes ?? 0, ingresosMes: r?.ingresosMes ?? 0, clientes: r?.clientes ?? 0, barberosActivos: r?.barberosActivos ?? 0 }
      })
      .sort((a, b) => Number(b.activa) - Number(a.activa) || b.ingresosMes - a.ingresosMes)
  }, [barberiasQuery.data, resumenQuery.data])

  const maxIngresos = Math.max(1, ...filas.map((f) => f.ingresosMes))
  const totales = filas.reduce((t, f) => ({ citas: t.citas + f.citasMes, cobrado: t.cobrado + f.ingresosMes, clientes: t.clientes + f.clientes }), { citas: 0, cobrado: 0, clientes: 0 })
  const desactivadas = filas.filter((f) => !f.activa).length

  const entrar = (b: Barberia) => {
    elegir(b.id)
    void queryClient.resetQueries()
    navigate('/dashboard')
  }

  const set = (k: keyof Form, v: string) => {
    setForm((f) => ({ ...f, [k]: v }))
    if (errores[k]) setErrores((e) => ({ ...e, [k]: undefined }))
  }

  const abrirAlta = () => {
    setForm(FORM_VACIO)
    setErrores({})
    setCreando(true)
  }

  const crear = async () => {
    const e = validar(form)
    setErrores(e)
    if (Object.keys(e).length) return
    const payload: CrearBarberiaInput = {
      nombre: form.nombre.trim(),
      telefono: form.telefono.trim(),
      correo: form.correo.trim(),
      direccion: form.direccion.trim(),
      ciudad: form.ciudad.trim(),
      departamento: form.departamento.trim(),
      pais: form.pais.trim(),
      latitud: 0,
      longitud: 0,
      horaApertura: form.horaApertura,
      horaCierre: form.horaCierre,
      diasDescanso: [],
      activa: true,
      administrador: {
        nombre: form.adminNombre.trim(),
        apellido: form.adminApellido.trim(),
        telefono: form.adminTelefono.trim(),
        correo: form.adminCorreo.trim(),
        password: form.adminPassword,
      },
    }
    try {
      await crearMutation.mutateAsync(payload)
      toast.success(`${payload.nombre} quedó creada. ${payload.administrador.nombre} ya puede entrar al panel.`)
      setCreando(false)
    } catch (err) {
      toast.error(mensajeDeError(err, 'No pudimos crear la barbería. Inténtalo de nuevo.'))
    }
  }

  const confirmarEstado = async () => {
    if (!cambiarEstado) return
    const activar = !cambiarEstado.activa
    try {
      await estadoMutation.mutateAsync({ id: cambiarEstado.id, activa: activar })
      toast.success(activar ? `${cambiarEstado.nombre} está activa otra vez` : `${cambiarEstado.nombre} quedó desactivada`)
      setCambiarEstado(null)
    } catch (err) {
      toast.error(mensajeDeError(err, 'No pudimos cambiar el estado de la barbería.'))
    }
  }

  const columnas: TableColumn<Fila>[] = [
    {
      key: 'barberia',
      label: 'Barbería',
      render: (b) => (
        <span className="flex min-w-0 flex-col text-left">
          <strong className="text-label-sm text-ink">{b.nombre}</strong>
          <span className="text-caption text-ink-muted">{[b.ciudad, b.direccion].filter(Boolean).join(' · ') || 'Sin dirección'}</span>
        </span>
      ),
    },
    {
      key: 'estado',
      label: 'Estado',
      render: (b) => (b.activa ? <Badge tone="success" icon="circle-check">Activa</Badge> : <Badge tone="neutral" icon="ban">Desactivada</Badge>),
    },
    { key: 'citas', label: 'Citas del mes', align: 'right', render: (b) => <span className="tnum">{b.citasMes}</span> },
    {
      key: 'cobrado',
      label: 'Cobrado',
      align: 'right',
      render: (b) => (
        <span className="ml-auto flex w-[9.5rem] flex-col items-end gap-1">
          <span className="tnum">{formatCOP(b.ingresosMes)}</span>
          <span className="h-1 w-full overflow-hidden rounded-full bg-surface-sunken" aria-hidden="true">
            <span className="block h-full rounded-full bg-chart-1" style={{ width: `${(b.ingresosMes / maxIngresos) * 100}%` }} />
          </span>
        </span>
      ),
    },
    { key: 'clientes', label: 'Clientes', align: 'right', render: (b) => <span className="tnum">{b.clientes}</span> },
    { key: 'barberos', label: 'Barberos', align: 'right', render: (b) => <span className="tnum">{b.barberosActivos}</span> },
    {
      key: 'acciones',
      label: 'Acciones',
      align: 'right',
      render: (b) => (
        <span className="inline-flex items-center gap-1" onClick={(e) => e.stopPropagation()}>
          <Button size="sm" variant="secondary" iconRight="arrow-right" onClick={() => entrar(b)}>
            Entrar
          </Button>
          <IconButton icon={b.activa ? 'ban' : 'rotate-ccw'} size="sm" label={`${b.activa ? 'Desactivar' : 'Activar'} ${b.nombre}`} onClick={() => setCambiarEstado(b)} />
        </span>
      ),
    },
  ]

  const cargando = barberiasQuery.isLoading || resumenQuery.isLoading
  const error = barberiasQuery.isError || resumenQuery.isError

  return (
    <div className="mx-auto flex max-w-[1200px] flex-col gap-5 px-4 py-5 md:px-6 lg:px-8">
      <PageHeader
        title="Tus barberías"
        subtitle={`Cómo va ${mes} en cada una. Entra a una barbería para operarla como su administrador.`}
        actions={
          <Button icon="plus" onClick={abrirAlta}>
            Nueva barbería
          </Button>
        }
      />

      <Table
        caption={`Barberías y su resumen de ${mes}`}
        columns={columnas}
        rows={filas}
        rowKey={(b) => b.id}
        state={
          error ? (
            <EmptyState
              tone="error"
              title="No pudimos cargar las barberías"
              body="Revisa tu conexión e inténtalo de nuevo."
              actionLabel="Reintentar"
              actionIcon="refresh-cw"
              actionVariant="secondary"
              onAction={() => {
                void barberiasQuery.refetch()
                void resumenQuery.refetch()
              }}
            />
          ) : cargando ? (
            <Skeleton variant="row" rows={3} label="Cargando barberías" />
          ) : filas.length === 0 ? (
            <EmptyState icon="store" title="Aún no hay barberías" body="Crea la primera junto con la persona que la va a administrar." actionLabel="Nueva barbería" actionIcon="plus" onAction={abrirAlta} />
          ) : undefined
        }
      />

      {!cargando && !error && filas.length > 0 && (
        <p className="text-body text-ink-muted">
          En {mes}, entre todas: <strong className="tnum text-ink">{totales.citas}</strong> {totales.citas === 1 ? 'cita' : 'citas'},{' '}
          <strong className="tnum text-ink">{formatCOP(totales.cobrado)}</strong> cobrados y <strong className="tnum text-ink">{totales.clientes}</strong>{' '}
          {totales.clientes === 1 ? 'cliente activo' : 'clientes activos'}.
          {desactivadas > 0 && ` ${desactivadas} ${desactivadas === 1 ? 'barbería desactivada' : 'barberías desactivadas'}.`}
        </p>
      )}

      <Modal
        open={creando}
        onClose={() => setCreando(false)}
        dirty={JSON.stringify(form) !== JSON.stringify(FORM_VACIO) && !crearMutation.isPending}
        size="lg"
        title="Nueva barbería"
        subtitle="Se crea activa, con la persona que la va a administrar."
        footer={
          <>
            <Button variant="secondary" onClick={() => setCreando(false)} disabled={crearMutation.isPending}>
              Cancelar
            </Button>
            <Button onClick={() => void crear()} loading={crearMutation.isPending}>
              {crearMutation.isPending ? 'Creando…' : 'Crear barbería'}
            </Button>
          </>
        }
      >
        <fieldset className="flex flex-col gap-4">
          <legend className="mb-3 text-title-sm text-ink">La barbería</legend>
          <Input label="Nombre" value={form.nombre} error={errores.nombre} onChange={(e) => set('nombre', e.target.value)} />
          <div className="grid gap-4 md:grid-cols-2">
            <Input label="Teléfono" type="tel" inputMode="tel" value={form.telefono} error={errores.telefono} onChange={(e) => set('telefono', e.target.value)} />
            <Input label="Correo" type="email" value={form.correo} error={errores.correo} onChange={(e) => set('correo', e.target.value)} />
          </div>
          <Input label="Dirección" icon="map-pin" value={form.direccion} error={errores.direccion} onChange={(e) => set('direccion', e.target.value)} />
          <div className="grid gap-4 md:grid-cols-3">
            <Input label="Ciudad" value={form.ciudad} error={errores.ciudad} onChange={(e) => set('ciudad', e.target.value)} />
            <Input label="Departamento" value={form.departamento} error={errores.departamento} onChange={(e) => set('departamento', e.target.value)} />
            <Input label="País" value={form.pais} error={errores.pais} onChange={(e) => set('pais', e.target.value)} />
          </div>
          <div className="grid gap-4 md:grid-cols-2">
            <Input label="Abre a las" type="time" value={form.horaApertura} onChange={(e) => set('horaApertura', e.target.value)} />
            <Input label="Cierra a las" type="time" value={form.horaCierre} error={errores.horaCierre} hint="Los días de descanso y los demás datos se completan en Mi negocio." onChange={(e) => set('horaCierre', e.target.value)} />
          </div>
        </fieldset>

        <hr className="border-line" />

        <fieldset className="flex flex-col gap-4">
          <legend className="mb-3 text-title-sm text-ink">Su administrador</legend>
          <div className="grid gap-4 md:grid-cols-2">
            <Input label="Nombre" autoComplete="off" value={form.adminNombre} error={errores.adminNombre} onChange={(e) => set('adminNombre', e.target.value)} />
            <Input label="Apellido" autoComplete="off" value={form.adminApellido} error={errores.adminApellido} onChange={(e) => set('adminApellido', e.target.value)} />
          </div>
          <div className="grid gap-4 md:grid-cols-2">
            <Input label="Correo" type="email" autoComplete="off" value={form.adminCorreo} error={errores.adminCorreo} hint="Con este correo entra al panel." onChange={(e) => set('adminCorreo', e.target.value)} />
            <Input label="Teléfono" type="tel" inputMode="tel" optional value={form.adminTelefono} onChange={(e) => set('adminTelefono', e.target.value)} />
          </div>
          <Input label="Contraseña inicial" revealable autoComplete="new-password" value={form.adminPassword} error={errores.adminPassword} hint="Mínimo 6 caracteres. Compártela con esa persona; puede cambiarla con «¿Olvidaste tu contraseña?»." onChange={(e) => set('adminPassword', e.target.value)} />
        </fieldset>
      </Modal>

      <ConfirmDialog
        open={cambiarEstado != null}
        tone={cambiarEstado?.activa ? 'danger' : 'info'}
        icon={cambiarEstado?.activa ? 'ban' : 'rotate-ccw'}
        title={cambiarEstado?.activa ? `¿Desactivar ${cambiarEstado.nombre}?` : `¿Activar ${cambiarEstado?.nombre}?`}
        body={
          cambiarEstado?.activa
            ? 'Su equipo y sus clientes no podrán entrar ni reservar, y las sesiones abiertas se cierran. No se borra nada: puedes activarla cuando quieras.'
            : 'Su equipo y sus clientes podrán volver a entrar y reservar.'
        }
        confirmLabel={cambiarEstado?.activa ? 'Desactivar barbería' : 'Activar barbería'}
        loading={estadoMutation.isPending}
        onCancel={() => setCambiarEstado(null)}
        onConfirm={() => void confirmarEstado()}
      />
    </div>
  )
}
