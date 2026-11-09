import { useState, type ReactNode } from 'react'

import {
  AgendaBoard,
  AppointmentCard,
  Avatar,
  Badge,
  Banner,
  BarberCard,
  Button,
  Calendar,
  Chip,
  ConfirmDialog,
  Countdown,
  EmptyState,
  IconButton,
  Input,
  Logo,
  Modal,
  Pagination,
  Rating,
  Select,
  ServiceCard,
  Skeleton,
  SlotGrid,
  StatCard,
  StatusBadge,
  Stepper,
  Switch,
  Table,
  Tabs,
  Toast,
  Topbar,
  type AppointmentStatus,
  type ServiceType,
} from '../../components/bsm'
import { useTheme } from '../../components/theme/themeContext'
import { toast } from '../../stores/toastStore'

// Galería de componentes del sistema (solo en desarrollo, ruta /_componentes).
// Datos de ejemplo de design/pantallas; no representan clientes reales.

function Section({ title, children }: { title: string; children: ReactNode }) {
  return (
    <section className="flex flex-col gap-4 border-t border-line pt-8">
      <h2 className="font-display text-title-lg text-ink">{title}</h2>
      {children}
    </section>
  )
}

const STATUSES: AppointmentStatus[] = ['Pendiente', 'Confirmada', 'EnProgreso', 'Completada', 'Cancelada', 'NoShow']
const SERVICES: Array<{ name: string; type: ServiceType; duration: number; price: number; description: string; tag?: string }> = [
  { name: 'Corte clásico', type: 'Corte', duration: 40, price: 35000, description: 'Tijera y máquina, lavado y peinado.', tag: 'Popular' },
  { name: 'Corte + barba', type: 'Combo', duration: 60, price: 50000, description: 'Corte completo con perfilado de barba.' },
  { name: 'Afeitado con toalla caliente', type: 'Afeitado', duration: 30, price: 28000, description: 'Navaja, toalla caliente y bálsamo.' },
  { name: 'Arreglo de barba', type: 'Barba', duration: 25, price: 22000, description: 'Perfilado y aceite.' },
]

export function ComponentesPage() {
  const { theme, setChoice } = useTheme()
  const [service, setService] = useState(SERVICES[1].name)
  const [barber, setBarber] = useState('Julián Restrepo')
  const [day, setDay] = useState(12)
  const [slot, setSlot] = useState('15:00')
  const [tab, setTab] = useState('proximas')
  const [view, setView] = useState('dia')
  const [chips, setChips] = useState('Todos')
  const [specialties, setSpecialties] = useState(['Fade', 'Barba', 'Diseños'])
  const [page, setPage] = useState(2)
  const [modal, setModal] = useState(false)
  const [dirty, setDirty] = useState(false)
  const [confirm, setConfirm] = useState(false)
  const [seconds, setSeconds] = useState(272)
  const [selectedAppt, setSelectedAppt] = useState<string | null>('a2')

  return (
    <div className="min-h-screen bg-bg text-ink">
      <Topbar title="Componentes" theme={theme} onThemeChange={setChoice} onNotifications={() => toast.info('Sin avisos nuevos')} unread />
      <main className="mx-auto flex max-w-[1200px] flex-col gap-10 px-4 py-8 md:px-8">
        <div className="flex flex-wrap items-center gap-8">
          <Logo />
          <Logo variant="emblem" />
          <span className="rounded-md bg-carbon p-4">
            <Logo surface="dark" />
          </span>
        </div>

        <Section title="Botones">
          <div className="flex flex-wrap items-center gap-3">
            <Button icon="calendar-plus">Crear cita</Button>
            <Button variant="secondary" icon="calendar-clock">
              Reprogramar
            </Button>
            <Button variant="ghost" icon="star">
              Calificar servicio
            </Button>
            <Button variant="danger-ghost" onClick={() => setConfirm(true)}>
              Cancelar cita
            </Button>
            <Button variant="danger">Sí, cancelar cita</Button>
            <Button loading>Reservando…</Button>
            <Button disabled>Continuar</Button>
            <Button size="sm" variant="secondary">
              Pequeño
            </Button>
            <Button size="lg">Reservar ahora</Button>
            <IconButton icon="pencil" label="Editar Laura Henao" />
            <IconButton icon="bell" label="Notificaciones" variant="secondary" badge />
          </div>
        </Section>

        <Section title="Campos">
          <div className="grid gap-4 md:grid-cols-2">
            <Input label="Correo" type="email" placeholder="andres@correo.co" icon="mail" hint="Te enviaremos la confirmación aquí." />
            <Input label="Contraseña" revealable defaultValue="secreto123" />
            <Input label="Teléfono" inputMode="numeric" defaultValue="300 123" error="Ingresa un número de 10 dígitos." />
            <Select label="Barbero" placeholder="Todos los barberos" options={['Julián Restrepo', 'Laura Henao', 'Mateo Ríos']} />
            <Input label="Alguna nota para el barbero" optional multiline placeholder="Ej.: llego 5 minutos antes" />
            <div className="flex flex-col gap-3">
              <Switch label="Barbería activa" hint="Los clientes pueden reservar." defaultChecked />
              <Switch label="Recordatorios" onChange={(on) => toast.success(on ? 'Recordatorios activados' : 'Recordatorios desactivados')} />
              <Switch label="Deshabilitado" disabled />
            </div>
          </div>
        </Section>

        <Section title="Chips, estados y atributos">
          <div className="flex flex-wrap gap-2">
            {['Todos', 'Corte', 'Barba', 'Afeitado', 'Combo'].map((c) => (
              <Chip key={c} selected={chips === c} onClick={() => setChips(c)} count={c === 'Todos' ? 12 : undefined}>
                {c}
              </Chip>
            ))}
          </div>
          <div className="flex flex-wrap gap-2">
            {specialties.map((s) => (
              <Chip key={s} onRemove={() => setSpecialties((list) => list.filter((x) => x !== s))}>
                {s}
              </Chip>
            ))}
            <Chip as="tag">Etiqueta</Chip>
          </div>
          <div className="flex flex-wrap gap-2">
            {STATUSES.map((s) => (
              <StatusBadge key={s} status={s} />
            ))}
          </div>
          <div className="flex flex-wrap items-center gap-3">
            <Badge tone="success" icon="circle-check">
              Activo
            </Badge>
            <Badge tone="neutral">Inactivo</Badge>
            <Badge tone="info" icon="bell">
              Notificaciones activas
            </Badge>
            <Badge tone="oxblood">Popular</Badge>
            <Rating value={4.8} count={126} />
            <Rating value={4.5} compact />
            <Rating value={null} />
            <Avatar name="Laura Henao" size={48} status="on" />
            <Avatar name="Mateo Ríos" size={32} />
          </div>
        </Section>

        <Section title="Reserva">
          <div className="max-w-[420px]">
            <Stepper current={3} onStep={(n) => toast.info(`Volver al paso ${n}`)} />
          </div>
          <div className="grid gap-3 md:grid-cols-2" role="radiogroup" aria-label="Servicios">
            {SERVICES.map((s) => (
              <ServiceCard key={s.name} {...s} selected={service === s.name} onClick={() => setService(s.name)} />
            ))}
          </div>
          <div className="grid gap-3 md:grid-cols-2" role="radiogroup" aria-label="Barberos">
            <BarberCard name="Julián Restrepo" rating={4.9} reviews={212} years={8} specialties={['Fade', 'Barba', 'Clásico']} selected={barber === 'Julián Restrepo'} onClick={() => setBarber('Julián Restrepo')} onProfile={() => toast.info('Perfil de Julián')} />
            <BarberCard name="Laura Henao" rating={4.7} reviews={98} years={5} specialPrice={45000} selected={barber === 'Laura Henao'} onClick={() => setBarber('Laura Henao')} />
            <BarberCard name="Mateo Ríos" rating={null} years={1} available={false} unavailableLabel="Vuelve el lunes" />
          </div>
          <div className="grid gap-6 md:grid-cols-[360px_1fr]">
            <Calendar
              year={2026}
              month={10}
              today={6}
              selected={day}
              disabled={(d) => d < 6 || new Date(2026, 10, d).getDay() === 0}
              marks={{ 12: 'few', 13: 'any', 14: 'any', 18: 'few' }}
              legend="Punto naranja: quedan pocos horarios."
              onSelect={setDay}
              onPrevMonth={() => toast.info('Mes anterior')}
              onNextMonth={() => toast.info('Mes siguiente')}
            />
            <div className="flex flex-col gap-4">
              <SlotGrid
                selected={slot}
                onSelect={(s) => setSlot(s.time)}
                slots={['09:00', '09:30', '10:00', '10:30', '11:00', '14:00', '14:30', '15:00', '15:30', '16:00', '18:00', '18:30'].map((t, i) => ({ time: t, state: i % 5 === 3 ? 'booked' : 'available' }))}
              />
              <div className="flex flex-wrap gap-2">
                <Button size="sm" variant="secondary" onClick={() => setSeconds(272)}>
                  4:32
                </Button>
                <Button size="sm" variant="secondary" onClick={() => setSeconds(45)}>
                  0:45
                </Button>
              </div>
              <Countdown seconds={seconds} />
              <Countdown seconds={seconds} variant="compact" />
            </div>
          </div>
        </Section>

        <Section title="Citas y KPI">
          <div className="grid gap-3 md:grid-cols-2">
            <AppointmentCard service="Corte + barba" barber="Julián Restrepo" date="2026-11-12" start="15:00" end="15:50" status="Confirmada" price={50000} onOpen={() => toast.info('Abrir detalle')} />
            <AppointmentCard
              service="Corte clásico"
              barber="Laura Henao"
              date="2026-10-28"
              start="10:30"
              end="11:10"
              status="Completada"
              actions={[{ label: 'Calificar servicio', variant: 'ghost', icon: 'star', onClick: () => toast.success('¡Gracias por tu reseña!') }]}
            />
          </div>
          <div className="grid gap-3 md:grid-cols-2 lg:grid-cols-4">
            <StatCard label="Citas del día" value="18" icon="calendar-days" delta={12} />
            <StatCard label="Ingresos del día" value="$745.000" icon="banknote" hint="Estimado · cobrado $410.000" />
            <StatCard label="Cancelaciones" value="3" icon="calendar-x" delta={-25} invert />
            <StatCard label="Barberos activos" value="4" icon="users" />
          </div>
        </Section>

        <Section title="Navegación y tablas">
          <Tabs value={tab} onChange={setTab} items={[{ value: 'proximas', label: 'Próximas', count: 2 }, { value: 'historial', label: 'Historial' }]} />
          <Tabs variant="segmented" value={view} onChange={setView} label="Vista" items={[{ value: 'dia', label: 'Día' }, { value: 'semana', label: 'Semana' }, { value: 'historial', label: 'Historial' }]} />
          <Table
            caption="Barberos"
            rowKey={(r) => r.name}
            onRowClick={(r) => toast.info(`Abrir ${r.name}`)}
            columns={[
              { key: 'name', label: 'Barbero', render: (r) => <span className="flex items-center gap-3"><Avatar name={r.name} size={32} />{r.name}</span> },
              { key: 'rating', label: 'Calificación', render: (r) => <Rating value={r.rating} compact /> },
              { key: 'citas', label: 'Citas hoy', align: 'right' },
              { key: 'estado', label: 'Estado', render: (r) => <Badge tone={r.estado === 'Disponible' ? 'success' : 'neutral'}>{r.estado}</Badge> },
              { key: 'acciones', label: 'Acciones', align: 'right', render: (r) => <IconButton icon="pencil" size="sm" label={`Editar ${r.name}`} onClick={(e) => e.stopPropagation()} /> },
            ]}
            rows={[
              { name: 'Julián Restrepo', rating: 4.9, citas: 7, estado: 'Disponible' },
              { name: 'Laura Henao', rating: 4.7, citas: 5, estado: 'Disponible' },
              { name: 'Mateo Ríos', rating: 4.2, citas: 0, estado: 'Vacaciones' },
            ]}
          />
          <Pagination page={page} pages={6} total={132} onPageChange={setPage} />
          <Pagination variant="more" shown={25} total={132} onLoadMore={() => toast.info('Cargando más')} />
        </Section>

        <Section title="Agenda">
          <AgendaBoard
            start="09:00"
            end="14:00"
            now="11:12"
            onItemClick={(a) => setSelectedAppt(a.id ?? null)}
            onSlotClick={(c, t) => toast.info(`Nueva cita con ${c.name} a las ${t}`)}
            columns={[
              { name: 'Julián Restrepo', items: [
                { id: 'a1', client: 'Andrés Gómez', service: 'Corte + barba', start: '09:00', end: '10:00', status: 'Completada', selected: selectedAppt === 'a1' },
                { id: 'a2', client: 'Juan Pablo Ríos', service: 'Corte clásico', start: '11:30', end: '12:10', status: 'Confirmada', selected: selectedAppt === 'a2' },
                { client: 'Almuerzo', start: '12:30', end: '13:30', block: true },
              ] },
              { name: 'Laura Henao', items: [
                { id: 'a3', client: 'Camilo Vélez', service: 'Afeitado', start: '10:00', end: '10:30', status: 'EnProgreso', selected: selectedAppt === 'a3' },
                { id: 'a4', client: 'Sergio Mejía', service: 'Barba', start: '11:00', end: '11:25', status: 'Pendiente', selected: selectedAppt === 'a4' },
              ] },
              { name: 'Mateo Ríos', items: [{ id: 'a5', client: 'Daniel Ochoa', service: 'Corte', start: '09:30', end: '10:10', status: 'NoShow', selected: selectedAppt === 'a5' }] },
            ]}
          />
          <SlotGrid
            mode="admin"
            onSelect={(s) => toast.info(`${s.time} · ${s.state}`)}
            slots={[
              { time: '09:00', state: 'available' },
              { time: '09:30', state: 'booked', note: 'Andrés Gómez' },
              { time: '10:00', state: 'blocked', note: 'Capacitación' },
              { time: '10:30', state: 'hold', note: 'Reservando · 3:12' },
              { time: '11:00', state: 'available' },
            ]}
          />
        </Section>

        <Section title="Avisos, diálogos, carga y vacío">
          <Banner tone="info" icon="calendar-clock" title="Estás reprogramando tu cita">
            Al confirmar, la anterior se cancela automáticamente.
          </Banner>
          <Banner tone="danger" title="No pudimos cargar los horarios" actionLabel="Reintentar" onAction={() => toast.info('Reintentando')}>
            Revisa tu conexión e inténtalo de nuevo.
          </Banner>
          <Banner tone="warning" title="Tu sesión expirará pronto">
            Si estás reservando, termina ahora o vuelve a iniciar sesión.
          </Banner>
          <div className="flex flex-wrap gap-3">
            <Button variant="secondary" icon="plus" onClick={() => setModal(true)}>
              Abrir modal
            </Button>
            <Button variant="secondary" onClick={() => toast.success('Cita cancelada', { label: 'Deshacer', onAction: () => toast.info('Cita restaurada') })}>
              Toast con acción
            </Button>
            <Button variant="secondary" onClick={() => toast.error('No pudimos guardar los cambios.')}>
              Toast de error
            </Button>
          </div>
          <div className="max-w-[480px]">
            <Toast actionLabel="Deshacer" onDismiss={() => undefined}>
              Cita cancelada
            </Toast>
          </div>
          <div className="grid gap-4 md:grid-cols-2">
            <Skeleton variant="card" rows={2} />
            <Skeleton variant="slots" />
          </div>
          <div className="grid gap-4 md:grid-cols-2">
            <EmptyState title="Aún no tienes citas" body="Cuando reserves, aparecerán aquí." actionLabel="Reservar" actionIcon="calendar-plus" />
            <EmptyState tone="error" title="No pudimos cargar los barberos" body="Revisa tu conexión e inténtalo de nuevo." actionLabel="Reintentar" actionIcon="refresh-cw" actionVariant="secondary" />
          </div>
        </Section>
      </main>

      <Modal
        open={modal}
        onClose={() => {
          setModal(false)
          setDirty(false)
        }}
        dirty={dirty}
        title="Nueva cita"
        subtitle="Jueves 12 de noviembre"
        footer={[
          { label: 'Cancelar', variant: 'secondary', onClick: () => setModal(false) },
          { label: 'Crear cita', variant: 'primary', icon: 'calendar-plus', onClick: () => { setModal(false); toast.success('Cita creada') } },
        ]}
      >
        <Select label="Barbero" options={['Julián Restrepo', 'Laura Henao']} />
        <Input label="Cliente" icon="search" placeholder="Nombre, correo o teléfono" onChange={() => setDirty(true)} />
        <SlotGrid selected={slot} onSelect={(s) => setSlot(s.time)} slots={['15:00', '15:30', '16:00', '16:30'].map((t) => ({ time: t }))} />
      </Modal>
      <ConfirmDialog
        open={confirm}
        title="¿Cancelar esta cita?"
        body="Se liberará el horario del jueves 12 de noviembre a las 3:00 p. m. con Julián. Esta acción no se puede deshacer."
        confirmLabel="Sí, cancelar cita"
        onCancel={() => setConfirm(false)}
        onConfirm={() => {
          setConfirm(false)
          toast.success('Cita cancelada')
        }}
      />
    </div>
  )
}
