import { useState, type FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'
import axios from 'axios'
import { useQueryClient } from '@tanstack/react-query'

import { Banner, Button, Input, Logo, Tabs } from '../../components/bsm'
import { useTheme } from '../../components/theme/ThemeProvider'
import { useAuthStore } from '../../stores/authStore'
import { toast } from '../../stores/toastStore'
import { http } from '../../services/http'

type AuthPayload = {
  token: string
  clienteId: string
  rol: string
  nombreCompleto: string
  barberoId?: string | null
}

type ApiResponse<T> = {
  success: boolean
  message: string
  data: T | null
  errors: string[]
}

type Rechazo = { title: string; body: string }

const ROLES_PANEL = new Set(['Admin', 'AdministradorBarberia', 'Barbero'])

/**
 * Login del panel: panel de marca sobre `carbon` y formulario
 * (design/pantallas/panel-web/Login-panel, Login-panel-error, Login-panel-movil).
 */
export function LoginPage() {
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const { theme, setChoice } = useTheme()
  const login = useAuthStore((s) => s.login)
  const logout = useAuthStore((s) => s.logout)

  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [errores, setErrores] = useState<{ email?: string; password?: string }>({})
  const [rechazo, setRechazo] = useState<Rechazo | null>(null)
  const [loading, setLoading] = useState(false)

  const validar = () => {
    const next: typeof errores = {}
    if (!email.trim()) next.email = 'Escribe tu correo.'
    else if (!/^[^@\s]+@[^@\s]+\.[^@\s]{2,}$/.test(email.trim())) next.email = 'Ingresa un correo válido, por ejemplo nombre@correo.co.'
    if (!password) next.password = 'Escribe tu contraseña.'
    setErrores(next)
    return Object.keys(next).length === 0
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    setRechazo(null)
    if (!validar()) return
    setLoading(true)
    try {
      const res = await http.post<ApiResponse<AuthPayload>>('/v1/auth/login', { correo: email.trim(), password })
      const payload = res.data?.data
      if (!res.data?.success || !payload?.token) throw new Error(res.data?.message || 'No se pudo iniciar sesión')

      if (!ROLES_PANEL.has(payload.rol)) {
        setRechazo({ title: 'Esta cuenta es de cliente', body: 'Las reservas se hacen desde la app BarberShop Medellín.' })
        return
      }

      // Limpiar sesión anterior antes de guardar la nueva
      queryClient.clear()
      logout()
      login(payload.token, { id: payload.clienteId, nombre: payload.nombreCompleto, rol: payload.rol, barberoId: payload.barberoId })
      navigate('/dashboard', { replace: true })
    } catch (error) {
      const status = axios.isAxiosError(error) ? error.response?.status : undefined
      if (status === 401 || status === 400) {
        setRechazo({ title: 'Credenciales incorrectas', body: 'Revisa tu correo y tu contraseña e inténtalo de nuevo.' })
      } else {
        toast.error('No pudimos iniciar sesión. Revisa tu conexión e inténtalo de nuevo.')
      }
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="flex min-h-dvh flex-wrap bg-bg text-ink">
      <section
        data-theme="dark"
        aria-label="BarberShop Medellín"
        className="flex min-h-60 flex-[1_1_480px] flex-col justify-between gap-8 bg-carbon px-6 py-8 text-ink md:px-14 md:py-12"
      >
        <Logo variant="horizontal" surface="dark" height={44} />
        <div className="flex max-w-[520px] flex-col gap-4">
          <h2 className="font-display text-[36px] leading-[40px] tracking-[-0.01em] md:text-[48px] md:leading-[52px]">Agenda, clientes y equipo en un solo lugar.</h2>
          <p className="text-body-lg text-ink-muted">Confirma citas, atiende a quien llama y mira cómo va el día desde recepción o desde el celular.</p>
        </div>
        <p className="text-caption text-ink-muted">Medellín, Colombia</p>
      </section>

      <section className="flex flex-[1_1_480px] flex-col px-6 pb-10 pt-6 md:px-8">
        <div className="flex justify-end">
          <Tabs
            variant="segmented"
            label="Tema"
            value={theme}
            onChange={(v) => setChoice(v === 'dark' ? 'oscuro' : 'claro')}
            items={[
              { value: 'light', label: 'Claro', icon: 'sun' },
              { value: 'dark', label: 'Oscuro', icon: 'moon' },
            ]}
          />
        </div>
        <div className="flex flex-1 items-center justify-center py-8">
          <form onSubmit={handleSubmit} noValidate className="flex w-full max-w-[400px] flex-col gap-4">
            <div className="mb-2 flex flex-col gap-2">
              <h1 className="font-display text-display text-ink">Panel de BarberShop Medellín</h1>
              <p className="text-body-lg text-ink-muted">Ingresa con tu cuenta administrativa.</p>
            </div>
            {rechazo && (
              <Banner tone="danger" title={rechazo.title}>
                {rechazo.body}
              </Banner>
            )}
            <Input
              label="Correo electrónico"
              type="email"
              icon="mail"
              autoComplete="username"
              placeholder="nombre@correo.co"
              value={email}
              error={errores.email}
              onChange={(e) => setEmail(e.target.value)}
              onBlur={() => errores.email && validar()}
            />
            <Input
              label="Contraseña"
              revealable
              autoComplete="current-password"
              value={password}
              error={errores.password}
              onChange={(e) => setPassword(e.target.value)}
            />
            <button
              type="button"
              className="bsm-link self-end"
              onClick={() => toast.info('Pide a un administrador que restablezca tu contraseña desde Usuarios.')}
            >
              ¿Olvidaste tu contraseña?
            </button>
            <Button type="submit" size="lg" block loading={loading}>
              {loading ? 'Entrando…' : 'Entrar al panel'}
            </Button>
            <p className="text-center text-body text-ink-muted">¿Eres cliente? Reserva desde la app BarberShop Medellín.</p>
          </form>
        </div>
      </section>
    </div>
  )
}
