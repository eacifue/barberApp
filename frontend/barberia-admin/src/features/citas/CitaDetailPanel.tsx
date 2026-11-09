import { useEffect, useRef, useState, type ReactNode } from 'react'
import { useMutation, useQueryClient } from '@tanstack/react-query'

import { useAuthStore } from '../../stores/authStore'
import { Avatar, Button, ConfirmDialog, Icon, IconButton, StatusBadge, formatCOP, formatDuration, formatLongDate, formatTime } from '../../components/bsm'
import { citaService } from '../../services/citaService'
import { toast } from '../../stores/toastStore'
import type { Cita } from '../../types/cita'
import { hhmm, mensajeDeError, nombreBarbero, nombreCliente, parseIso, todayIso, yaEmpezo } from './agendaUtils'
import { invalidarCitas } from './invalidarCitas'

type Accion = 'confirmar' | 'iniciar' | 'completar' | 'noAsistio' | 'cancelar'

const MENSAJE_OK: Record<Accion, string> = {
  confirmar: 'Cita confirmada',
  iniciar: 'Servicio iniciado',
  completar: 'Cita completada',
  noAsistio: 'Cita marcada como «No asistió»',
  cancelar: 'Cita cancelada',
}

function Section({ title, children }: { title: string; children: ReactNode }) {
  return (
    <section className="flex flex-col gap-1 border-b border-line px-6 py-4 last:border-b-0">
      <h3 className="bsm-overline">{title}</h3>
      {children}
    </section>
  )
}

type Props = {
  cita: Cita
  onClose: () => void
  onReprogramar: (cita: Cita) => void
  /** Sin superposición: el panel vive al lado de la agenda. En celular cubre la pantalla. */
  overlay?: boolean
}

/**
 * Detalle de la cita como panel lateral de 400 px, no modal: la agenda sigue
 * visible y se puede pasar de una cita a otra (design/pantallas/panel-web/Agenda-detalle).
 */
export function CitaDetailPanel({ cita, onClose, onReprogramar, overlay }: Props) {
  const esBarbero = useAuthStore((st) => st.usuario?.rol === 'Barbero')
  const queryClient = useQueryClient()
  const headingRef = useRef<HTMLHeadingElement>(null)
  const [confirmar, setConfirmar] = useState<'cancelar' | 'noAsistio' | null>(null)

  useEffect(() => {
    headingRef.current?.focus()
  }, [cita.id])

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && !confirmar) onClose()
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [onClose, confirmar])

  const mutation = useMutation({
    mutationFn: async (accion: Accion) => {
      switch (accion) {
        case 'confirmar':
          return citaService.confirm(cita.id)
        case 'iniciar':
          return citaService.start(cita.id)
        case 'completar':
          return citaService.complete(cita.id)
        case 'noAsistio':
          return citaService.noShow(cita.id)
        case 'cancelar':
          return citaService.cancel(cita.id, { citaId: cita.id, motivo: 'Cancelada desde la agenda' })
      }
    },
    onSuccess: async (_data, accion) => {
      setConfirmar(null)
      toast.success(MENSAJE_OK[accion])
      await invalidarCitas(queryClient)
    },
    onError: (error) => {
      setConfirmar(null)
      toast.error(mensajeDeError(error, 'No pudimos actualizar la cita. Inténtalo de nuevo.'))
    },
  })

  const cliente = nombreCliente(cita)
  const barbero = nombreBarbero(cita)
  const fecha = parseIso(cita.fechaCita)
  const esHoy = cita.fechaCita === todayIso()
  const telefono = cita.cliente.telefono?.replace(/\D/g, '') ?? ''
  const empezo = yaEmpezo(cita)
  const busy = mutation.isPending
  const accionEnCurso = mutation.isPending ? mutation.variables : null

  const run = (accion: Accion) => mutation.mutate(accion)

  let footer: ReactNode = null
  if (esBarbero) {
    // El backend reserva los cambios de estado a recepción (Admin y Admin Barbería).
    footer =
      cita.estado === 'Pendiente' || cita.estado === 'Confirmada' || cita.estado === 'EnProgreso' ? (
        <p className="flex items-center justify-center gap-2 text-center text-caption text-ink-muted">
          <Icon name="info" size={14} />
          Recepción confirma, inicia y completa tus citas desde el panel.
        </p>
      ) : null
  } else if (cita.estado === 'Pendiente') {
    footer = (
      <>
        <Button size="lg" block icon="circle-check" loading={accionEnCurso === 'confirmar'} disabled={busy} onClick={() => run('confirmar')}>
          {accionEnCurso === 'confirmar' ? 'Confirmando…' : 'Confirmar'}
        </Button>
        <div className="grid grid-cols-2 gap-2">
          <Button variant="secondary" icon="calendar-clock" disabled={busy} onClick={() => onReprogramar(cita)}>
            Reprogramar
          </Button>
          <Button variant="secondary" icon="user-x" disabled={busy || !empezo} onClick={() => setConfirmar('noAsistio')}>
            No asistió
          </Button>
        </div>
        <Button variant="danger-ghost" block disabled={busy} onClick={() => setConfirmar('cancelar')}>
          Cancelar cita
        </Button>
      </>
    )
  } else if (cita.estado === 'Confirmada') {
    footer = (
      <>
        <Button size="lg" block icon="scissors" loading={accionEnCurso === 'iniciar'} disabled={busy} onClick={() => run('iniciar')}>
          {accionEnCurso === 'iniciar' ? 'Iniciando…' : 'Iniciar servicio'}
        </Button>
        <div className="grid grid-cols-2 gap-2">
          <Button variant="secondary" icon="calendar-clock" disabled={busy} onClick={() => onReprogramar(cita)}>
            Reprogramar
          </Button>
          <Button variant="secondary" icon="user-x" disabled={busy || !empezo} onClick={() => setConfirmar('noAsistio')}>
            No asistió
          </Button>
        </div>
        <Button variant="danger-ghost" block disabled={busy} onClick={() => setConfirmar('cancelar')}>
          Cancelar cita
        </Button>
      </>
    )
  } else if (cita.estado === 'EnProgreso') {
    footer = (
      <Button size="lg" block icon="check-check" loading={accionEnCurso === 'completar'} onClick={() => run('completar')}>
        {accionEnCurso === 'completar' ? 'Completando…' : 'Completar'}
      </Button>
    )
  }

  return (
    <aside
      aria-labelledby="detalle-cita-titulo"
      className={[
        'flex flex-col border-l border-line bg-surface-raised',
        overlay ? 'fixed inset-0 z-40' : 'h-full w-[400px] flex-none shadow-lg',
      ].join(' ')}
    >
      <header className="flex items-start gap-3 border-b border-line px-6 py-5">
        <Avatar name={cliente} src={cita.cliente.fotoUrl} size={48} />
        <div className="flex min-w-0 flex-1 flex-col items-start gap-1">
          <h2 id="detalle-cita-titulo" ref={headingRef} tabIndex={-1} className="font-display text-title-lg text-ink outline-none">
            {cliente}
          </h2>
          <StatusBadge status={cita.estado} />
        </div>
        <IconButton icon="x" label="Cerrar detalle" onClick={onClose} />
      </header>

      <div className="min-h-0 flex-1 overflow-y-auto">
        <Section title="Cita">
          <p className="text-title-sm text-ink">
            {cita.servicio.nombre} · {formatDuration(cita.servicio.duracionMinutos)}
          </p>
          <p className="text-body text-ink">
            {esHoy ? 'Hoy, ' : ''}
            {formatLongDate(fecha)} · {formatTime(hhmm(cita.horaInicio))} – {formatTime(hhmm(cita.horaFin))}
          </p>
          <p className="text-body text-ink-muted">
            con {barbero} · <span className="tnum">{formatCOP(cita.precioFinal)}</span> · Pago en el local
          </p>
        </Section>

        <Section title="Cliente">
          {telefono ? (
            <div className="flex items-center gap-2">
              <span className="tnum flex-1 text-body text-ink">{cita.cliente.telefono}</span>
              <a className="bsm-iconbtn bsm-iconbtn-secondary bsm-iconbtn-sm" href={`tel:${telefono}`} aria-label={`Llamar a ${cita.cliente.nombre}`} title={`Llamar a ${cita.cliente.nombre}`}>
                <Icon name="phone" size={18} />
              </a>
              <a
                className="bsm-iconbtn bsm-iconbtn-secondary bsm-iconbtn-sm"
                href={`https://wa.me/${telefono.length === 10 ? `57${telefono}` : telefono}`}
                target="_blank"
                rel="noreferrer"
                aria-label={`Escribir por WhatsApp a ${cita.cliente.nombre}`}
                title={`Escribir por WhatsApp a ${cita.cliente.nombre}`}
              >
                <Icon name="message-circle" size={18} />
              </a>
            </div>
          ) : (
            <p className="text-body text-ink-muted">Sin teléfono registrado</p>
          )}
        </Section>

        {cita.notas?.trim() && (
          <Section title="Nota">
            <p className="whitespace-pre-line text-body text-ink">{cita.notas.trim()}</p>
          </Section>
        )}
      </div>

      {footer && (
        <footer className="flex flex-col gap-2 border-t border-line px-6 py-4">
          {footer}
          {!esBarbero && (cita.estado === 'Pendiente' || cita.estado === 'Confirmada') && !empezo && (
            <p className="text-center text-caption text-ink-muted">«No asistió» se habilita desde las {formatTime(hhmm(cita.horaInicio))}.</p>
          )}
        </footer>
      )}

      <ConfirmDialog
        open={confirmar === 'cancelar'}
        title="¿Cancelar esta cita?"
        body={`Se liberará el horario del ${formatLongDate(fecha)} a las ${formatTime(hhmm(cita.horaInicio))} con ${cita.barbero.nombre}. El cliente recibirá un aviso.`}
        confirmLabel="Sí, cancelar cita"
        loading={accionEnCurso === 'cancelar'}
        onCancel={() => setConfirmar(null)}
        onConfirm={() => run('cancelar')}
      />
      <ConfirmDialog
        open={confirmar === 'noAsistio'}
        icon="user-x"
        title={`¿${cita.cliente.nombre} no asistió?`}
        body="La cita queda como «No asistió» y le avisaremos al cliente para que pueda reservar de nuevo."
        confirmLabel="Sí, no asistió"
        loading={accionEnCurso === 'noAsistio'}
        onCancel={() => setConfirmar(null)}
        onConfirm={() => run('noAsistio')}
      />
    </aside>
  )
}
