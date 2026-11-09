import { Toast, type ToastTone } from '../bsm'
import { useToastStore, type ToastVariant } from '../../stores/toastStore'

const tone: Record<ToastVariant, ToastTone> = { success: 'success', error: 'danger', warning: 'warning', info: 'info' }

/** Snackbar del sistema (design/docs/componentes/Toast.md), abajo al centro. */
export function ToastContainer() {
  const { toasts, dismiss } = useToastStore()
  const t = toasts[toasts.length - 1]
  return (
    <div className="pointer-events-none fixed inset-x-4 bottom-6 z-[100] flex justify-center">
      {t && (
        <div key={t.id} className="pointer-events-auto w-full max-w-[480px]">
          <Toast
            tone={tone[t.variant]}
            actionLabel={t.action?.label}
            onAction={() => {
              t.action?.onAction()
              dismiss(t.id)
            }}
            onDismiss={() => dismiss(t.id)}
          >
            {t.message}
          </Toast>
        </div>
      )}
    </div>
  )
}
