import { useNavigate } from 'react-router-dom'

import { Button, EmptyState, Skeleton, StatCard, formatCOP, useDelayedFlag } from '../../components/bsm'
import { useResumenBarberias } from '../../hooks/useBarberias'
import type { ResumenBarberia } from '../../types/barberia'
import { BarList, type BarDatum } from './charts'
import { Panel } from './Panel'

function barras(filas: ResumenBarberia[], valor: (r: ResumenBarberia) => number, mostrar: (n: number) => string): BarDatum[] {
  return [...filas]
    .sort((a, b) => valor(b) - valor(a))
    .map((r) => {
      const nombre = r.activa ? r.nombre : `${r.nombre} (desactivada)`
      return { key: r.barberiaId, label: nombre, text: nombre, value: valor(r), display: mostrar(valor(r)) }
    })
}

/**
 * SuperAdmin en «Todas las barberías»: el mes en curso de todas juntas y cada una
 * frente a las demás. Mismas cuentas que el Dashboard de una barbería.
 */
export function DashboardConsolidado() {
  const navigate = useNavigate()
  const resumenQuery = useResumenBarberias()
  const loading = useDelayedFlag(resumenQuery.isLoading)

  const filas = resumenQuery.data ?? []
  const activas = filas.filter((r) => r.activa)
  const mesLargo = new Date().toLocaleDateString('es-CO', { month: 'long', year: 'numeric' })
  const mes = mesLargo.split(' ')[0]
  const total = (f: (r: ResumenBarberia) => number) => filas.reduce((s, r) => s + f(r), 0)

  const cobrado = barras(filas, (r) => r.ingresosMes, formatCOP)
  const citas = barras(filas, (r) => r.citasMes, (n) => `${n} ${n === 1 ? 'cita' : 'citas'}`)

  return (
    <div className="mx-auto flex max-w-[1200px] flex-col gap-6 px-4 py-5 md:px-6 lg:px-8">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h2 className="font-display text-display text-ink">Todas tus barberías</h2>
          <p className="text-body text-ink-muted">
            {mesLargo.charAt(0).toUpperCase() + mesLargo.slice(1)}
            {filas.length > 0 && ` · ${activas.length} ${activas.length === 1 ? 'barbería activa' : 'barberías activas'}`}
          </p>
        </div>
        <Button variant="secondary" icon="layers" onClick={() => navigate('/barberias')}>
          Ver barberías
        </Button>
      </div>

      {resumenQuery.isError ? (
        <EmptyState tone="error" title="No pudimos cargar el resumen" body="Revisa tu conexión e inténtalo de nuevo." actionLabel="Reintentar" actionIcon="refresh-cw" actionVariant="secondary" onAction={() => void resumenQuery.refetch()} />
      ) : loading ? (
        <Skeleton variant="card" rows={4} label="Cargando el resumen" />
      ) : resumenQuery.isLoading ? null : filas.length === 0 ? (
        <EmptyState icon="store" title="Aún no hay barberías" body="Crea la primera en Barberías, junto con la persona que la va a administrar." actionLabel="Ir a Barberías" actionIcon="layers" onAction={() => navigate('/barberias')} />
      ) : (
        <>
          <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-4">
            <StatCard label={`Citas de ${mes}`} value={String(total((r) => r.citasMes))} icon="calendar-days" hint="Sin canceladas ni «No asistió»" />
            <StatCard label={`Cobrado en ${mes}`} value={formatCOP(total((r) => r.ingresosMes))} icon="banknote" hint="Citas completadas" />
            <StatCard label="Clientes activos" value={String(total((r) => r.clientes))} icon="users" hint={`En ${filas.length} ${filas.length === 1 ? 'barbería' : 'barberías'}`} />
            <StatCard label="Barberos activos" value={String(total((r) => r.barberosActivos))} icon="scissors" hint="Sumando todos los equipos" />
          </div>

          <div className="grid gap-4 xl:grid-cols-2">
            <Panel title="Cobrado por barbería" subtitle={`${mes.charAt(0).toUpperCase() + mes.slice(1)} · citas completadas`}>
              <BarList data={cobrado} max={Math.max(1, ...cobrado.map((d) => d.value))} caption={`Cobrado en ${mes} por barbería`} valueHead="Cobrado" />
            </Panel>
            <Panel title="Citas por barbería" subtitle={`${mes.charAt(0).toUpperCase() + mes.slice(1)} · sin canceladas ni «No asistió»`}>
              <BarList data={citas} max={Math.max(1, ...citas.map((d) => d.value))} color="var(--chart-2)" caption={`Citas de ${mes} por barbería`} valueHead="Citas" />
            </Panel>
          </div>

          <p className="text-body text-ink-muted">Para ver la agenda, el equipo o los clientes de una barbería, elígela en el selector de arriba.</p>
        </>
      )}
    </div>
  )
}
