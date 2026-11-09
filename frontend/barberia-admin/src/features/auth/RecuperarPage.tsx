import { useEffect, useState, type FormEvent } from 'react'
import { Link, useLocation, useNavigate } from 'react-router-dom'
import axios from 'axios'

import { Banner, Button, Input } from '../../components/bsm'
import { http } from '../../services/http'
import { toast } from '../../stores/toastStore'
import { AuthLayout } from './AuthLayout'

const ESPERA = 60
const correoValido = (v: string) => /^[^@\s]+@[^@\s]+\.[^@\s]{2,}$/.test(v.trim())

/**
 * Recuperar contraseña (sin diseño propio; patrones del login): 1) correo,
 * 2) código de 6 dígitos + contraseña nueva. La API no revela si el correo existe.
 */
export function RecuperarPage() {
  const navigate = useNavigate()
  const location = useLocation()
  const inicial = (location.state as { correo?: string } | null)?.correo ?? ''

  const [paso, setPaso] = useState<'correo' | 'codigo'>('correo')
  const [correo, setCorreo] = useState(inicial)
  const [codigo, setCodigo] = useState('')
  const [password, setPassword] = useState('')
  const [confirmar, setConfirmar] = useState('')
  const [errores, setErrores] = useState<{ correo?: string; codigo?: string; password?: string; confirmar?: string }>({})
  const [rechazo, setRechazo] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)
  const [espera, setEspera] = useState(0)

  useEffect(() => {
    if (espera <= 0) return
    const id = setTimeout(() => setEspera((s) => s - 1), 1000)
    return () => clearTimeout(id)
  }, [espera])

  async function pedirCodigo(e?: FormEvent) {
    e?.preventDefault()
    if (!correoValido(correo)) {
      setErrores({ correo: correo.trim() ? 'Ingresa un correo válido, por ejemplo nombre@correo.co.' : 'Escribe tu correo.' })
      return
    }
    setErrores({})
    setLoading(true)
    try {
      await http.post('/v1/auth/recuperar', { correo: correo.trim() })
      setPaso('codigo')
      setEspera(ESPERA)
      setRechazo(null)
    } catch {
      toast.error('No pudimos enviar el código. Revisa tu conexión e inténtalo de nuevo.')
    } finally {
      setLoading(false)
    }
  }

  async function restablecer(e: FormEvent) {
    e.preventDefault()
    setRechazo(null)
    const next: typeof errores = {}
    if (!/^\d{6}$/.test(codigo.trim())) next.codigo = 'Escribe los 6 dígitos del código.'
    if (password.length < 6) next.password = 'Usa al menos 6 caracteres.'
    if (confirmar !== password) next.confirmar = 'Las contraseñas no coinciden.'
    setErrores(next)
    if (Object.keys(next).length) return
    setLoading(true)
    try {
      await http.post('/v1/auth/restablecer', { correo: correo.trim(), codigo: codigo.trim(), nuevaPassword: password })
      toast.success('Listo, tu contraseña cambió. Ya puedes entrar.')
      navigate('/login', { replace: true })
    } catch (error) {
      const msg = axios.isAxiosError(error) ? (error.response?.data as { message?: string } | undefined)?.message : undefined
      if (axios.isAxiosError(error) && error.response?.status === 400 && msg) setRechazo(msg)
      else toast.error('No pudimos cambiar la contraseña. Revisa tu conexión e inténtalo de nuevo.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <AuthLayout>
      {paso === 'correo' ? (
        <form onSubmit={pedirCodigo} noValidate className="flex w-full max-w-[400px] flex-col gap-4">
          <div className="mb-2 flex flex-col gap-2">
            <h1 className="font-display text-display text-ink">Recupera tu contraseña</h1>
            <p className="text-body-lg text-ink-muted">Te enviamos un código de 6 dígitos al correo de tu cuenta.</p>
          </div>
          <Input
            label="Correo electrónico"
            type="email"
            icon="mail"
            autoComplete="username"
            placeholder="nombre@correo.co"
            value={correo}
            error={errores.correo}
            onChange={(e) => setCorreo(e.target.value)}
          />
          <Button type="submit" size="lg" block loading={loading}>
            {loading ? 'Enviando…' : 'Enviar código'}
          </Button>
          <Link to="/login" className="bsm-link self-center">
            Volver a iniciar sesión
          </Link>
        </form>
      ) : (
        <form onSubmit={restablecer} noValidate className="flex w-full max-w-[400px] flex-col gap-4">
          <div className="mb-2 flex flex-col gap-2">
            <h1 className="font-display text-display text-ink">Revisa tu correo</h1>
            <p className="text-body-lg text-ink-muted">
              Si <strong className="text-ink">{correo.trim()}</strong> tiene cuenta, te llegó un código. Vence en 15 minutos; revisa también la carpeta de spam.
            </p>
          </div>
          {rechazo && (
            <Banner tone="danger" title="No pudimos cambiar la contraseña">
              {rechazo}
            </Banner>
          )}
          <Input
            label="Código"
            inputMode="numeric"
            autoComplete="one-time-code"
            maxLength={6}
            placeholder="123456"
            value={codigo}
            error={errores.codigo}
            onChange={(e) => setCodigo(e.target.value.replace(/\D/g, '').slice(0, 6))}
          />
          <Input label="Contraseña nueva" revealable autoComplete="new-password" hint="Mínimo 6 caracteres." value={password} error={errores.password} onChange={(e) => setPassword(e.target.value)} />
          <Input label="Repite la contraseña" revealable autoComplete="new-password" value={confirmar} error={errores.confirmar} onChange={(e) => setConfirmar(e.target.value)} />
          <Button type="submit" size="lg" block loading={loading}>
            {loading ? 'Guardando…' : 'Cambiar contraseña'}
          </Button>
          <div className="flex flex-wrap items-center justify-between gap-2 text-body text-ink-muted">
            <button type="button" className="bsm-link" onClick={() => setPaso('correo')}>
              Cambiar correo
            </button>
            {espera > 0 ? (
              <span aria-live="polite">Puedes pedir otro código en {espera} s</span>
            ) : (
              <button type="button" className="bsm-link" disabled={loading} onClick={() => void pedirCodigo()}>
                Enviar otro código
              </button>
            )}
          </div>
        </form>
      )}
    </AuthLayout>
  )
}
