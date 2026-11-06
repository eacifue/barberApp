import { useEffect, useMemo, useRef, useState } from 'react'
import { useMutation, useQuery } from '@tanstack/react-query'

import { slotsRedisService } from '../../services/slotsRedisService'
import type { SlotActivo } from '../../services/slotsRedisService'
import { PageHeader } from '../../components/shared/PageHeader'
import { Badge } from '../../components/ui/Badge'
import { Button } from '../../components/ui/Button'
import { SkeletonRow } from '../../components/ui/SkeletonRow'

function formatDateTime(value: string) {
  if (!value) return '-'
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return '-'
  return date.toLocaleString('es-CO')
}

function computeRemainingMs(expiraEn: string, nowMs: number) {
  if (!expiraEn) return 0
  const expiration = new Date(expiraEn).getTime()
  if (Number.isNaN(expiration)) return 0
  return Math.max(0, expiration - nowMs)
}

function formatRemaining(ms: number) {
  if (ms <= 0) return 'Expirado'
  const totalSec = Math.floor(ms / 1000)
  const min = Math.floor(totalSec / 60)
  const sec = totalSec % 60
  return `${min}:${String(sec).padStart(2, '0')} min`
}

export function SlotsRedisPage() {
  const [nowMs, setNowMs] = useState(Date.now())
  const [confirmInlineKey, setConfirmInlineKey] = useState<string | null>(null)
  const autoExpiredRef = useRef(new Set<string>())

  const redisHostPort = import.meta.env.VITE_REDIS_TARGET ?? 'localhost:6379'

  const slotsQuery = useQuery({
    queryKey: ['slots-activos'],
    queryFn: slotsRedisService.getActivos,
    refetchInterval: 10000,
  })

  const limpiarMutation = useMutation({
    mutationFn: slotsRedisService.limpiarExpirados,
    onSuccess: async () => {
      await slotsQuery.refetch()
    },
  })

  const liberarMutation = useMutation({
    mutationFn: (slot: SlotActivo) => slotsRedisService.liberar(slot),
    onSuccess: async () => {
      await slotsQuery.refetch()
    },
  })

  useEffect(() => {
    const timer = setInterval(() => {
      setNowMs(Date.now())
    }, 1000)
    return () => clearInterval(timer)
  }, [])

  const slots = slotsQuery.data ?? []

  const counters = useMemo(() => {
    let active = 0
    let nearExpire = 0
    let expiredToday = 0
    const today = new Date().toISOString().slice(0, 10)

    for (const slot of slots) {
      const remaining = computeRemainingMs(slot.expiraEn, nowMs)
      if (remaining > 0) {
        active += 1
      }
      if (remaining > 0 && remaining < 60_000) {
        nearExpire += 1
      }
      if (remaining <= 0 && slot.expiraEn.slice(0, 10) === today) {
        expiredToday += 1
      }
    }

    return { active, nearExpire, expiredToday }
  }, [slots, nowMs])

  useEffect(() => {
    const expiredKeys = slots
      .filter((slot) => computeRemainingMs(slot.expiraEn, nowMs) <= 0)
      .map((slot) => slot.keyRedis)

    const shouldRefetch = expiredKeys.some((key) => !autoExpiredRef.current.has(key))
    if (shouldRefetch && slots.length > 0) {
      expiredKeys.forEach((key) => autoExpiredRef.current.add(key))
      void slotsQuery.refetch()
    }
  }, [slots, nowMs, slotsQuery])

  return (
    <section>
      <PageHeader title="Slots / Redis" subtitle="Monitor de bloqueos Redis activos" />

      <div className="mb-4 grid gap-3 md:grid-cols-3">
        <div className="rounded-xl border border-[var(--border2)] bg-[var(--surface2)] p-3">
          <p className="text-[10px] uppercase text-ink-muted">Total activos</p>
          <p className="mt-1 font-display text-2xl text-ink">{counters.active}</p>
        </div>
        <div className="rounded-xl border border-[var(--border2)] bg-[var(--surface2)] p-3">
          <p className="text-[10px] uppercase text-ink-muted">Proximos a expirar (&lt;1min)</p>
          <p className="mt-1 font-display text-2xl text-[var(--danger)]">{counters.nearExpire}</p>
        </div>
        <div className="rounded-xl border border-[var(--border2)] bg-[var(--surface2)] p-3">
          <p className="text-[10px] uppercase text-ink-muted">Expirados hoy</p>
          <p className="mt-1 font-display text-2xl text-ink">{counters.expiredToday}</p>
        </div>
      </div>

      <div className="rounded-2xl border border-[var(--border2)] bg-[var(--surface2)] p-5">
        <div className="mb-4 flex flex-wrap items-center justify-between gap-2">
          <div className="flex items-center gap-2">
            <Badge variant={slotsQuery.isError ? 'danger' : 'success'} dot>
              ● Redis {slotsQuery.isError ? 'desconectado' : 'conectado'}
            </Badge>
            <span className="text-sm text-ink">
              {redisHostPort} · {counters.active} keys activas
            </span>
            {slotsQuery.isFetching ? <Badge variant="info">Actualizando...</Badge> : null}
          </div>
          <Button variant="ghost" onClick={() => limpiarMutation.mutate()} loading={limpiarMutation.isPending}>
            Limpiar expirados
          </Button>
        </div>

        {slotsQuery.isLoading ? (
          <div className="space-y-2">
            {Array.from({ length: 5 }).map((_, idx) => (
              <SkeletonRow key={idx} templateColumns="2fr 1fr 1fr 1fr 1.2fr" columnCount={5} />
            ))}
          </div>
        ) : (
          <div className="overflow-x-auto rounded-xl border border-[var(--border)]">
            <div className="grid min-w-[780px] grid-cols-[2fr_1fr_1fr_1fr_1.2fr] bg-[var(--ink2)] px-3 py-2 text-[10px] uppercase tracking-[0.08em] text-ink-muted">
              <div>Key Redis</div>
              <div>Cliente</div>
              <div>Bloqueado en</div>
              <div>Expira en</div>
              <div>Accion</div>
            </div>

            {slots.length === 0 ? (
              <div className="px-3 py-8 text-center text-sm text-ink-muted">No hay bloqueos activos.</div>
            ) : (
              slots.map((slot) => {
                const remainingMs = computeRemainingMs(slot.expiraEn, nowMs)
                const isExpired = remainingMs <= 0
                const isUrgent = remainingMs > 0 && remainingMs < 60_000
                const isGold = remainingMs >= 120_000

                return (
                  <div
                    key={slot.keyRedis}
                    className="grid min-w-[780px] grid-cols-[2fr_1fr_1fr_1fr_1.2fr] items-center border-t border-[var(--border)] px-3 py-2 text-sm"
                  >
                    <div className="font-mono text-xs text-[var(--info)]">{slot.keyRedis}</div>
                    <div className="text-ink">{slot.cliente}</div>
                    <div className="text-ink-muted">{formatDateTime(slot.bloqueadoEn)}</div>
                    <div>
                      {isExpired ? (
                        <Badge variant="muted">Expirado</Badge>
                      ) : (
                        <span
                          className={[
                            'font-semibold',
                            isUrgent ? 'text-[var(--danger)]' : isGold ? 'text-brass-ink' : 'text-ink',
                          ].join(' ')}
                        >
                          {formatRemaining(remainingMs)}
                        </span>
                      )}
                    </div>
                    <div>
                      {confirmInlineKey === slot.keyRedis ? (
                        <div className="flex items-center gap-2">
                          <Button
                            size="sm"
                            variant="danger"
                            onClick={() => liberarMutation.mutate(slot)}
                            loading={liberarMutation.isPending}
                          >
                            Confirmar
                          </Button>
                          <Button size="sm" variant="ghost" onClick={() => setConfirmInlineKey(null)}>
                            Cancelar
                          </Button>
                        </div>
                      ) : (
                        <Button
                          size="sm"
                          variant="ghost"
                          onClick={() => setConfirmInlineKey(slot.keyRedis)}
                          disabled={isExpired}
                        >
                          Liberar
                        </Button>
                      )}
                    </div>
                  </div>
                )
              })
            )}
          </div>
        )}
      </div>
    </section>
  )
}
