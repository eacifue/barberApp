import { Avatar, Badge, Button, IconButton, Skeleton, StatusBadge, formatCOP, formatTime, statusOf } from '../../components/bsm'
import type { Cliente } from '../../types/cliente'
import { nombreBarbero } from '../citas/agendaUtils'
import { fechaCorta, type Metricas } from './clientesUtils'

function plural(n: number, uno: string, varios: string) {
  return `${n} ${n === 1 ? uno : varios}`
}

type Props = {
  cliente: Cliente
  metricas: Metricas | null
  cargando: boolean
  onClose: () => void
  onNuevaCita: () => void
  onEditar: () => void
  onCambiarEstado: () => void
}

/** Ficha lateral del cliente (design/pantallas/panel-web/Clientes, panel «ficha»). */
export function ClienteFicha({ cliente, metricas: m, cargando, onClose, onNuevaCita, onEditar, onCambiarEstado }: Props) {
  const nombre = `${cliente.nombre} ${cliente.apellido}`.trim()
  const desde = cliente.createdAt ? new Date(cliente.createdAt).toLocaleDateString('es-CO', { month: 'long', year: 'numeric' }) : null
  const detalle = m
    ? [plural(m.completadas, 'completada', 'completadas'), m.canceladas ? plural(m.canceladas, 'cancelada', 'canceladas') : null, m.noAsistio ? `${m.noAsistio} no asistió` : null].filter(Boolean).join(' · ')
    : ''

  return (
    <aside aria-label={`Ficha de ${nombre}`} className="flex flex-col gap-5">
      <div className="flex items-start gap-3">
        <Avatar name={nombre} src={cliente.fotoUrl} size={56} />
        <div className="min-w-0 flex-1">
          <h3 className="font-display text-title text-ink">{nombre}</h3>
          {desde && <p className="text-caption text-ink-muted">Cliente desde {desde}</p>}
          <div className="mt-2">{cliente.activo ? <Badge tone="success" icon="circle-check">Activo</Badge> : <Badge tone="neutral" icon="ban">Inactivo</Badge>}</div>
        </div>
        <IconButton icon="x" label="Cerrar ficha" onClick={onClose} />
      </div>

      <dl className="flex flex-col gap-1 text-body-sm">
        <div className="flex items-center gap-2">
          <dt className="sr-only">Celular</dt>
          <dd>
            <a href={`tel:${cliente.telefono.replace(/\s/g, '')}`}>{cliente.telefono || '—'}</a>
          </dd>
        </div>
        <div className="flex items-center gap-2">
          <dt className="sr-only">Correo</dt>
          <dd className="break-all">
            <a href={`mailto:${cliente.correo}`}>{cliente.correo}</a>
          </dd>
        </div>
      </dl>

      {cargando ? (
        <Skeleton variant="card" rows={2} label="Cargando historial" />
      ) : m ? (
        <>
          <dl className="grid grid-cols-2 gap-px overflow-hidden rounded-md border border-line bg-line">
            <Metrica label="Citas" valor={String(m.total)} pie={detalle || 'Sin citas en el último año'} />
            <Metrica label="Gasto total" valor={formatCOP(m.gasto)} pie={m.completadas ? `En ${plural(m.completadas, 'servicio', 'servicios')}` : 'Aún sin servicios'} />
            <Metrica label="Barbero preferido" valor={m.preferido?.nombre ?? '—'} pie={m.preferido ? `${m.preferido.veces} de ${m.total} citas` : ''} texto />
            <Metrica label="Última visita" valor={m.ultima ? fechaCorta(m.ultima.fechaCita) : 'Sin visitas'} pie={m.ultima?.servicio.nombre ?? ''} texto />
          </dl>

          <div className="rounded-md border border-line p-4">
            <p className="bsm-overline">Próxima cita</p>
            {m.proxima ? (
              <>
                <p className="mt-1 text-label text-ink">
                  {fechaCorta(m.proxima.fechaCita)} · {formatTime(m.proxima.horaInicio.slice(0, 5))}
                </p>
                <p className="text-caption text-ink-muted">
                  {m.proxima.servicio.nombre} con {m.proxima.barbero.nombre}
                </p>
              </>
            ) : (
              <p className="mt-1 text-body-sm text-ink-muted">No tiene citas agendadas.</p>
            )}
          </div>

          {m.citas.length > 0 && (
            <section aria-labelledby="bsm-ficha-hist">
              <h4 id="bsm-ficha-hist" className="bsm-overline">
                Historial
              </h4>
              <ul className="mt-2 flex flex-col divide-y divide-line">
                {m.citas.slice(0, 6).map((c) => (
                  <li key={c.id} className="flex items-center gap-3 py-2">
                    <span className="w-14 flex-none text-caption text-ink-muted">{fechaCorta(c.fechaCita)}</span>
                    <span className="min-w-0 flex-1">
                      <span className="block truncate text-body-sm text-ink">{c.servicio.nombre}</span>
                      <span className="block truncate text-caption text-ink-muted">{nombreBarbero(c)}</span>
                    </span>
                    <span className="flex flex-col items-end gap-1">
                      <StatusBadge status={statusOf(c.estado)} size="sm" />
                      <span className="text-caption text-ink-muted">{c.estado === 'Completada' ? formatCOP(c.precioFinal) : '—'}</span>
                    </span>
                  </li>
                ))}
              </ul>
              {m.citas.length > 6 && <p className="mt-2 text-caption text-ink-muted">Y {plural(m.citas.length - 6, 'cita más', 'citas más')} en el último año.</p>}
            </section>
          )}
        </>
      ) : null}

      <div className="flex flex-col gap-2">
        {cliente.activo && (
          <Button icon="calendar-plus" block onClick={onNuevaCita}>
            Nueva cita para {cliente.nombre}
          </Button>
        )}
        <div className="flex gap-2">
          <Button variant="secondary" icon="pencil" className="flex-1" onClick={onEditar}>
            Editar datos
          </Button>
          <Button variant="ghost" icon={cliente.activo ? 'ban' : 'rotate-ccw'} className="flex-1" onClick={onCambiarEstado}>
            {cliente.activo ? 'Desactivar' : 'Activar'}
          </Button>
        </div>
      </div>
    </aside>
  )
}

function Metrica({ label, valor, pie, texto }: { label: string; valor: string; pie: string; texto?: boolean }) {
  return (
    <div className="flex flex-col gap-0.5 bg-surface p-3">
      <dt className="text-caption text-ink-muted">{label}</dt>
      <dd className={texto ? 'truncate text-label text-ink' : 'font-display text-title text-ink'}>{valor}</dd>
      {pie && <dd className="text-caption text-ink-muted">{pie}</dd>}
    </div>
  )
}
