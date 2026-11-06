import { useState, type FormEvent } from 'react'
import { Eye, EyeOff, MoonStar, SunMedium } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import axios from 'axios'
import { useQueryClient } from '@tanstack/react-query'

import { useTheme } from '../../components/theme/ThemeProvider'
import { useAuthStore } from '../../stores/authStore'
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

export function LoginPage() {
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const { theme, toggleTheme } = useTheme()
  const login = useAuthStore((s) => s.login)
  const logout = useAuthStore((s) => s.logout)

  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)
    setLoading(true)
    try {
      const res = await http.post<ApiResponse<AuthPayload>>('/v1/auth/login', {
        correo: email,
        password,
      })

      const payload = res.data?.data
      if (!res.data?.success || !payload?.token) {
        throw new Error(res.data?.message || 'No se pudo iniciar sesión')
      }

      // Limpiar sesión anterior antes de guardar la nueva
      queryClient.clear()
      logout()

      login(payload.token, {
        id: payload.clienteId,
        nombre: payload.nombreCompleto,
        rol: payload.rol,
        barberoId: payload.barberoId,
      })
      navigate('/dashboard', { replace: true })
    } catch (error) {
      if (axios.isAxiosError(error)) {
        const apiMessage = (error.response?.data as { message?: string } | undefined)?.message
        setError(apiMessage || 'Credenciales incorrectas. Verifica tu correo y contraseña.')
      } else {
        setError('No se pudo iniciar sesión. Inténtalo de nuevo.')
      }
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="relative flex min-h-screen items-center justify-center overflow-hidden px-4 py-8 md:px-6">
      <div className="absolute right-6 top-6 z-10">
        <button
          type="button"
          onClick={toggleTheme}
          className="inline-flex h-11 w-11 items-center justify-center rounded-full border border-[var(--border-strong)] bg-[var(--surface-overlay)] text-[var(--text-base)] transition hover:border-brass-ink hover:text-brass-ink focus-visible:outline-none focus-visible:shadow-focus"
          aria-label={theme === 'dark' ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro'}
        >
          {theme === 'dark' ? <SunMedium className="h-4 w-4" /> : <MoonStar className="h-4 w-4" />}
        </button>
      </div>

      <div className="surface-panel relative w-full max-w-[420px] overflow-hidden rounded-[32px] px-6 py-8 md:px-10 md:py-10">
        <div className="mb-8 flex flex-col items-center text-center">
          <img src={theme === 'dark' ? '/logo-mark-sobre-oscuro.svg' : '/logo-mark.svg'} alt="BarberShop Medellín" className="mb-4 h-14 w-14" />
          <p className="font-display text-2xl text-[var(--text-strong)]">BarberShop Medellín</p>
          <p className="mt-1.5 text-sm text-[var(--text-ink-muted)]">Ingresa con tu cuenta administrativa</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-5">
          <div>
            <label htmlFor="email" className="form-label mb-2 block text-[11px] font-semibold uppercase tracking-[0.18em]">
              Email
            </label>
            <input
              id="email"
              type="email"
              autoComplete="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="form-control h-12 w-full rounded-2xl px-4 text-sm outline-none transition duration-200"
              placeholder="admin@barberia.local"
            />
          </div>

          <div>
            <label htmlFor="password" className="form-label mb-2 block text-[11px] font-semibold uppercase tracking-[0.18em]">
              Contraseña
            </label>
            <div className="relative">
              <input
                id="password"
                type={showPassword ? 'text' : 'password'}
                autoComplete="current-password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="form-control h-12 w-full rounded-2xl px-4 pr-12 text-sm outline-none transition duration-200"
                placeholder="••••••••"
              />
              <button
                type="button"
                onClick={() => setShowPassword((current) => !current)}
                className="absolute right-1.5 top-1/2 inline-flex h-9 w-9 -translate-y-1/2 items-center justify-center rounded-full text-[var(--text-faint)] transition hover:bg-[var(--surface-hover)] hover:text-[var(--text-strong)]"
                aria-label={showPassword ? 'Ocultar contraseña' : 'Mostrar contraseña'}
              >
                {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
              </button>
            </div>
          </div>

          {error ? (
            <p className="rounded-2xl border border-danger bg-[var(--danger-soft)] px-4 py-3 text-sm text-[var(--danger)]">
              {error}
            </p>
          ) : null}

          <button
            type="submit"
            disabled={loading}
            className="mt-2 inline-flex h-12 w-full items-center justify-center rounded-full bg-brass text-sm font-semibold text-brass-on transition duration-200 hover:bg-brass-strong disabled:cursor-not-allowed disabled:opacity-60"
          >
            {loading ? 'Entrando…' : 'Entrar al panel'}
          </button>
        </form>
      </div>
    </div>
  )
}
