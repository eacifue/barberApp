import { useEffect, useLayoutEffect, useRef } from 'react'

const FOCUSABLE_SELECTOR =
  'a[href], button:not([disabled]), textarea:not([disabled]), input:not([disabled]), select:not([disabled]), [tabindex]:not([tabindex="-1"])'

/**
 * Focus-trap compartido por Modal y ConfirmDialog: enfoca el primer elemento
 * al abrir, cicla Tab dentro del diálogo, cierra con Escape y devuelve el
 * foco a quien lo abrió al cerrarse.
 */
export function useDialogFocus(open: boolean, onClose: () => void) {
  const containerRef = useRef<HTMLDivElement>(null)

  // Guarda siempre la versión más reciente de onClose sin que el efecto de
  // abajo dependa de ella: la mayoría de los llamadores pasan una función
  // nueva en cada render (p. ej. un closure inline o un handler no
  // memoizado), y si el efecto dependiera de esa referencia se re-ejecutaría
  // en cada tecla presionada dentro del formulario, robándole el foco al
  // campo activo para devolvérselo al primer elemento enfocable del diálogo.
  const onCloseRef = useRef(onClose)
  useLayoutEffect(() => {
    onCloseRef.current = onClose
  })

  useEffect(() => {
    if (!open) return

    const previouslyFocused = document.activeElement as HTMLElement | null
    const container = containerRef.current
    const focusable = container?.querySelectorAll<HTMLElement>(FOCUSABLE_SELECTOR)
    ;(focusable?.[0] ?? container)?.focus()

    function handleKeyDown(event: KeyboardEvent) {
      if (event.key === 'Escape') {
        event.preventDefault()
        onCloseRef.current()
        return
      }

      if (event.key !== 'Tab' || !container) return

      const nodes = Array.from(container.querySelectorAll<HTMLElement>(FOCUSABLE_SELECTOR))
      if (nodes.length === 0) return

      const first = nodes[0]
      const last = nodes[nodes.length - 1]

      if (event.shiftKey && document.activeElement === first) {
        event.preventDefault()
        last.focus()
      } else if (!event.shiftKey && document.activeElement === last) {
        event.preventDefault()
        first.focus()
      }
    }

    document.addEventListener('keydown', handleKeyDown)
    return () => {
      document.removeEventListener('keydown', handleKeyDown)
      previouslyFocused?.focus?.()
    }
    // Deliberado: solo re-ejecutar cuando el diálogo realmente se abre/cierra,
    // nunca por un cambio de identidad de onClose.
  }, [open])

  return containerRef
}
