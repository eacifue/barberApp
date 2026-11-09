import { useState, type FormEvent } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import axios from 'axios'
import { useQueryClient } from '@tanstack/react-query'

import { Banner, Button, Input } from '../../components/bsm'
import { AuthLayout } from './AuthLayout'
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
    <AuthLayout>
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
            <Link to="/recuperar" state={{ correo: email.trim() }} className="bsm-link self-end">
              ¿Olvidaste tu contraseña?
            </Link>
            <Button type="submit" size="lg" block loading={loading}>
              {loading ? 'Entrando…' : 'Entrar al panel'}
            </Button>
            <p className="text-center text-body text-ink-muted">¿Eres cliente? Reserva desde la app BarberShop Medellín.</p>
          </form>
    </AuthLayout>
  )
}
