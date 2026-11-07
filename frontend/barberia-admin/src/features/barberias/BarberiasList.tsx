import { useMemo, useState, type ReactNode } from 'react'
import { Link } from 'react-router-dom'

import { Badge, Banner, Button, EmptyState, Icon, Input, Logo, Select, Skeleton, Switch, formatTime } from '../../components/bsm'
import { PageHeader } from '../../components/shared/PageHeader'
import { useBarberias } from '../../hooks/useBarberias'
import { useTenantBarberia } from '../../hooks/useTenantBarberia'
import { toast } from '../../stores/toastStore'
import type { Barberia, BarberiaUpsertInput } from '../../types/barberia'
import { hhmm, mensajeDeError, minutesOf, nowHHMM } from '../citas/agendaUtils'
import { DEPARTAMENTOS, DIAS_SEMANA, PAISES, resumenHorario } from './negocioUtils'

type Form = BarberiaUpsertInput
type Errores = Partial<Record<keyof Form, string>>

const HORAS = (() => {
  const out: Array<{ value: string; label: string }> = []
  for (let m = 5 * 60; m <= 23 * 60; m += 30) {
    const v = `${String(Math.floor(m / 60)).padStart(2, '0')}:${String(m % 60).padStart(2, '0')}`
    out.push({ value: v, label: formatTime(v) })
  }
  return out
})()

function formDe(b: Barberia): Form {
  return {
    nombre: b.nombre ?? '',
    descripcion: b.descripcion ?? '',
    slogan: b.slogan ?? '',
    sitioWeb: b.sitioWeb ?? '',
    fotoPortada: b.fotoPortada ?? '',
    telefono: b.telefono ?? '',
    correo: b.correo ?? '',
    direccion: b.direccion ?? '',
    ciudad: b.ciudad ?? '',
    departamento: b.departamento ?? '',
    pais: b.pais || 'Colombia',
    latitud: Number(b.latitud ?? 0),
    longitud: Number(b.longitud ?? 0),
    horaApertura: hhmm(b.horaApertura || '09:00'),
    horaCierre: hhmm(b.horaCierre || '20:00'),
    diasDescanso: b.diasDescanso ?? [],
    activa: b.activa ?? true,
  }
}

const esUrl = (v?: string) => !!v && /^https?:\/\//i.test(v.trim())

function validar(f: Form): Errores {
  const e: Errores = {}
  if (!f.nombre.trim()) e.nombre = 'Escribe el nombre de la barbería.'
  if (f.telefono.replace(/\D/g, '').length < 7) e.telefono = 'Ingresa un teléfono de al menos 7 dígitos. Lo usan «Llamar» y «WhatsApp».'
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(f.correo.trim())) e.correo = 'Ingresa un correo válido, como hola@tubarberia.co.'
  if (f.sitioWeb?.trim() && !esUrl(f.sitioWeb)) e.sitioWeb = 'Usa un enlace que empiece por https://'
  if (f.fotoPortada?.trim() && !esUrl(f.fotoPortada)) e.fotoPortada = 'Usa un enlace que empiece por https://'
  if (!f.direccion.trim()) e.direccion = 'Escribe la dirección del local.'
  if (!f.ciudad.trim()) e.ciudad = 'Escribe la ciudad.'
  if (!(Math.abs(f.latitud) <= 90) || f.latitud === 0) e.latitud = 'Ingresa la latitud del local (entre -90 y 90).'
  if (!(Math.abs(f.longitud) <= 180) || f.longitud === 0) e.longitud = 'Ingresa la longitud del local (entre -180 y 180).'
  if (minutesOf(f.horaApertura) >= minutesOf(f.horaCierre)) e.horaCierre = 'El cierre debe ser después de la apertura.'
  if (f.diasDescanso.length === 7) e.diasDescanso = 'Deja al menos un día abierto.'
  return e
}

/** Mi negocio (design/pantallas/panel-web/Mi-negocio): datos que ven los clientes, con vista previa en vivo. */
export function BarberiasList() {
  const { barberiasQuery } = useBarberias()
  const { effectiveBarberiaId } = useTenantBarberia()
  const barberia = barberiasQuery.data?.find((b) => b.id === effectiveBarberiaId) ?? barberiasQuery.data?.[0]

  return (
    <div className="mx-auto flex max-w-[1200px] flex-col gap-5 px-4 py-5 md:px-6 lg:px-8">
      <PageHeader title="Tu barbería" subtitle="Datos de tu barbería visibles para tus clientes en la app." />
      {barberiasQuery.isError ? (
        <EmptyState tone="error" title="No pudimos cargar tu barbería" body="Revisa tu conexión e inténtalo de nuevo." actionLabel="Reintentar" actionIcon="refresh-cw" actionVariant="secondary" onAction={() => void barberiasQuery.refetch()} />
      ) : barberiasQuery.isLoading ? (
        <Skeleton variant="card" rows={3} label="Cargando tu barbería" />
      ) : !barberia ? (
        <EmptyState icon="store" title="No hay una barbería configurada" body="Crea la barbería desde la base de datos inicial o contacta a soporte." />
      ) : (
        <Editor key={barberia.id} barberia={barberia} />
      )}
    </div>
  )
}

function Editor({ barberia }: { barberia: Barberia }) {
  const { updateMutation } = useBarberias()
  const [base, setBase] = useState<Form>(() => formDe(barberia))
  const [form, setForm] = useState<Form>(base)
  const [errores, setErrores] = useState<Errores>({})
  const dirty = JSON.stringify(form) !== JSON.stringify(base)

  const set = <K extends keyof Form>(k: K, v: Form[K]) => {
    setForm((f) => ({ ...f, [k]: v }))
    if (errores[k]) setErrores((e) => ({ ...e, [k]: undefined }))
  }
  const toggleDia = (d: number) => set('diasDescanso', form.diasDescanso.includes(d) ? form.diasDescanso.filter((x) => x !== d) : [...form.diasDescanso, d].sort())

  const guardar = async () => {
    const e = validar(form)
    setErrores(e)
    if (Object.keys(e).length) {
      toast.error('Revisa los campos marcados antes de guardar.')
      return
    }
    try {
      const payload: Form = {
        ...form,
        nombre: form.nombre.trim(),
        slogan: form.slogan?.trim(),
        sitioWeb: form.sitioWeb?.trim(),
        fotoPortada: form.fotoPortada?.trim(),
        horaApertura: `${form.horaApertura}:00`,
        horaCierre: `${form.horaCierre}:00`,
      }
      const guardada = await updateMutation.mutateAsync({ id: barberia.id, data: payload })
      const nuevo = formDe(guardada)
      setBase(nuevo)
      setForm(nuevo)
      toast.success('Cambios guardados. Tus clientes ya los ven en la app.')
    } catch (err) {
      toast.error(mensajeDeError(err, 'No pudimos guardar los cambios. Inténtalo de nuevo.'))
    }
  }

  const mapaUrl = form.latitud && form.longitud ? `https://www.google.com/maps/search/?api=1&query=${form.latitud},${form.longitud}` : null
  const deptos = form.pais === 'Colombia' ? DEPARTAMENTOS : null

  return (
    <>
      <div className="grid items-start gap-6 lg:grid-cols-[minmax(0,1fr)_360px]">
        <div className="flex min-w-0 flex-col gap-5">
          <Seccion titulo="Identidad" ayuda="Lo primero que ven tus clientes en Inicio.">
            <Input label="Nombre" value={form.nombre} error={errores.nombre} onChange={(e) => set('nombre', e.target.value)} />
            <Input label="Slogan" optional value={form.slogan ?? ''} maxLength={80} hint="Una frase corta bajo el nombre." onChange={(e) => set('slogan', e.target.value)} />
            <Input label="Descripción" optional multiline value={form.descripcion ?? ''} hint="Dos o tres frases sobre el local y su estilo." onChange={(e) => set('descripcion', e.target.value)} />
            <Input
              label="Foto de portada"
              optional
              icon="image-plus"
              placeholder="https://…"
              value={form.fotoPortada ?? ''}
              hint="Una foto horizontal del local. Se recorta en la parte superior de la tarjeta de Inicio."
              error={errores.fotoPortada}
              onChange={(e) => set('fotoPortada', e.target.value)}
            />
          </Seccion>

          <Seccion titulo="Contacto" ayuda="Alimenta los botones «Llamar» y «WhatsApp» de la app.">
            <div className="grid gap-4 md:grid-cols-2">
              <Input label="Teléfono / WhatsApp" type="tel" inputMode="tel" value={form.telefono} error={errores.telefono} onChange={(e) => set('telefono', e.target.value)} />
              <Input label="Correo" type="email" value={form.correo} error={errores.correo} onChange={(e) => set('correo', e.target.value)} />
            </div>
            <Input label="Sitio web" optional placeholder="https://…" value={form.sitioWeb ?? ''} error={errores.sitioWeb} onChange={(e) => set('sitioWeb', e.target.value)} />
          </Seccion>

          <Seccion titulo="Ubicación" ayuda="Las coordenadas definen a dónde lleva «Cómo llegar».">
            <Input label="Dirección" value={form.direccion} placeholder="Cra. 37 #8A-32" error={errores.direccion} onChange={(e) => set('direccion', e.target.value)} />
            <div className="grid gap-4 md:grid-cols-3">
              <Input label="Ciudad" value={form.ciudad} error={errores.ciudad} onChange={(e) => set('ciudad', e.target.value)} />
              {deptos ? (
                <Select label="Departamento" placeholder="Elige el departamento" value={form.departamento} options={deptos.map((d) => ({ value: d, label: d }))} onChange={(e) => set('departamento', e.target.value)} />
              ) : (
                <Input label="Departamento o estado" value={form.departamento} onChange={(e) => set('departamento', e.target.value)} />
              )}
              <Select label="País" value={form.pais} options={(PAISES.includes(form.pais) ? PAISES : [form.pais, ...PAISES]).map((p) => ({ value: p, label: p }))} onChange={(e) => set('pais', e.target.value)} />
            </div>
            <div className="grid gap-4 md:grid-cols-2">
              <Input label="Latitud" inputMode="decimal" value={String(form.latitud || '')} placeholder="6.2087" error={errores.latitud} onChange={(e) => set('latitud', Number(e.target.value.replace(',', '.')) || 0)} />
              <Input label="Longitud" inputMode="decimal" value={String(form.longitud || '')} placeholder="-75.5676" error={errores.longitud} onChange={(e) => set('longitud', Number(e.target.value.replace(',', '.')) || 0)} />
            </div>
            <p className="text-caption text-ink-muted">
              En Google Maps, mantén presionada la entrada del local y copia las coordenadas.{' '}
              {mapaUrl && (
                <a href={mapaUrl} target="_blank" rel="noreferrer">
                  Ver el punto en el mapa
                </a>
              )}
            </p>
          </Seccion>

          <Seccion
            titulo="Horario de atención"
            ayuda={
              <>
                El horario de cada barbero se ajusta en <Link to="/barberos">Barberos</Link>.
              </>
            }
          >
            <div className="grid gap-4 md:grid-cols-2">
              <Select label="Abre" value={form.horaApertura} options={HORAS} onChange={(e) => set('horaApertura', e.target.value)} />
              <Select label="Cierra" value={form.horaCierre} options={HORAS} error={errores.horaCierre} onChange={(e) => set('horaCierre', e.target.value)} />
            </div>
            <div className="flex flex-col gap-2">
              <span className="text-label-sm text-ink" id="bsm-negocio-descanso">
                Días de descanso
              </span>
              <div className="flex flex-wrap gap-2" role="group" aria-labelledby="bsm-negocio-descanso">
                {DIAS_SEMANA.map((d) => {
                  const on = form.diasDescanso.includes(d.getDay)
                  return (
                    <button key={d.getDay} type="button" aria-pressed={on} onClick={() => toggleDia(d.getDay)} className={`bsm-chip${on ? ' is-selected' : ''}`}>
                      {on && <Icon name="check" size={14} />}
                      {d.label}
                    </button>
                  )
                })}
              </div>
              <p className={errores.diasDescanso ? 'text-caption text-danger' : 'text-caption text-ink-muted'} role={errores.diasDescanso ? 'alert' : undefined}>
                {errores.diasDescanso ?? 'Marcados: la barbería no abre y la app no muestra horarios ese día.'}
              </p>
            </div>
          </Seccion>

          <Seccion titulo="Estado">
            <Switch label="Barbería activa" hint={form.activa ? 'Visible en la app y recibiendo reservas.' : 'Oculta en la app: nadie puede reservar.'} checked={form.activa} onChange={(on) => set('activa', on)} />
            {!form.activa && base.activa && (
              <Banner tone="warning" title="Al guardar, la barbería deja de verse en la app">
                Las citas ya agendadas se mantienen, pero nadie podrá reservar hasta que la actives de nuevo.
              </Banner>
            )}
          </Seccion>
        </div>

        <aside className="flex flex-col gap-2 lg:sticky lg:top-4" aria-label="Vista previa en la app">
          <span className="bsm-overline">Así se ve en la app</span>
          <Vista form={form} />
          <p className="text-caption text-ink-muted">Se actualiza mientras editas. Los clientes la ven cuando guardas.</p>
        </aside>
      </div>

      {dirty && (
        <div role="region" aria-label="Cambios sin guardar" className="sticky bottom-3 z-30 rounded-lg border border-line bg-surface shadow-lg">
          <div className="flex flex-wrap items-center justify-end gap-3 px-4 py-3">
            <span className="mr-auto text-body-sm text-ink">Tienes cambios sin guardar.</span>
            <Button
              variant="secondary"
              onClick={() => {
                setForm(base)
                setErrores({})
              }}
              disabled={updateMutation.isPending}
            >
              Descartar
            </Button>
            <Button icon="check" onClick={() => void guardar()} loading={updateMutation.isPending}>
              {updateMutation.isPending ? 'Guardando…' : 'Guardar cambios'}
            </Button>
          </div>
        </div>
      )}
    </>
  )
}

function Seccion({ titulo, ayuda, children }: { titulo: string; ayuda?: ReactNode; children: ReactNode }) {
  return (
    <section className="flex flex-col gap-4 rounded-lg border border-line bg-surface p-5">
      <div>
        <h3 className="font-display text-title text-ink">{titulo}</h3>
        {ayuda && <p className="mt-1 text-body-sm text-ink-muted">{ayuda}</p>}
      </div>
      {children}
    </section>
  )
}

function Vista({ form }: { form: Form }) {
  const hoy = new Date().getDay()
  const ahora = nowHHMM()
  const abierto = form.activa && !form.diasDescanso.includes(hoy) && ahora >= form.horaApertura && ahora < form.horaCierre
  const estado = !form.activa ? 'No disponible en la app' : abierto ? `Abierto hasta las ${formatTime(form.horaCierre)}` : 'Cerrado ahora'
  const horario = useMemo(() => resumenHorario(form.diasDescanso, formatTime(form.horaApertura), formatTime(form.horaCierre)), [form.diasDescanso, form.horaApertura, form.horaCierre])
  const lugar = [form.ciudad, form.departamento].filter(Boolean).join(', ')

  return (
    <div className="overflow-hidden rounded-lg border border-line bg-surface">
      <div className="flex aspect-[16/9] items-center justify-center bg-brass-soft">
        {esUrl(form.fotoPortada) ? <img src={form.fotoPortada!.trim()} alt="" className="h-full w-full object-cover" /> : <Logo variant="emblem" height={56} />}
      </div>
      <div className="flex flex-col gap-3 p-4">
        <div>
          <p className="font-display text-title text-ink">{form.nombre.trim() || 'Nombre de la barbería'}</p>
          {form.slogan?.trim() && <p className="text-body-sm text-ink-muted">{form.slogan.trim()}</p>}
        </div>
        <Badge tone={abierto ? 'success' : 'neutral'} icon={abierto ? 'clock' : 'moon'}>
          {estado}
        </Badge>
        <p className="text-caption text-ink-muted">{horario}</p>
        {(form.direccion || lugar) && (
          <p className="flex items-start gap-2 text-body-sm text-ink">
            <Icon name="map-pin" size={16} className="mt-0.5 flex-none text-brass-ink" />
            <span>
              {form.direccion}
              {lugar && <span className="block text-caption text-ink-muted">{lugar}</span>}
            </span>
          </p>
        )}
        <div className="grid grid-cols-3 gap-2" aria-hidden="true">
          {[
            ['phone', 'Llamar'],
            ['message-circle', 'WhatsApp'],
            ['navigation', 'Cómo llegar'],
          ].map(([icon, label]) => (
            <span key={label} className="flex flex-col items-center gap-1 rounded-md border border-line py-2 text-caption text-ink">
              <Icon name={icon as 'phone'} size={18} className="text-brass-ink" />
              {label}
            </span>
          ))}
        </div>
      </div>
    </div>
  )
}
