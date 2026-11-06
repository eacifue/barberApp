import { useEffect, useState } from 'react'

/** `true` solo si `active` dura más de `delay` ms (evita parpadeos del Skeleton). */
export function useDelayedFlag(active: boolean, delay = 300) {
  const [elapsed, setElapsed] = useState(false)
  const [prevActive, setPrevActive] = useState(active)
  if (active !== prevActive) {
    setPrevActive(active)
    setElapsed(false)
  }
  useEffect(() => {
    if (!active) return
    const t = window.setTimeout(() => setElapsed(true), delay)
    return () => window.clearTimeout(t)
  }, [active, delay])
  return active && elapsed
}
