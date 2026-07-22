import { useMemo, useState } from 'react'

type AvatarSize = 'sm' | 'md' | 'lg' | 'xl'

type AvatarProps = {
  fotoUrl?: string
  nombre: string
  apellido: string
  size?: AvatarSize
  dashedFallback?: boolean
}

const sizeMap: Record<AvatarSize, number> = {
  sm: 32,
  md: 40,
  lg: 56,
  xl: 72,
}

function hashCode(value: string) {
  let hash = 0
  for (let i = 0; i < value.length; i += 1) {
    hash = (hash << 5) - hash + value.charCodeAt(i)
    hash |= 0
  }
  return Math.abs(hash)
}

function getColor(nombre: string) {
  const colors = [
    'rgba(192,57,43,.2)',
    'rgba(184,134,11,.15)',
    'rgba(26,82,118,.2)',
    'rgba(26,122,74,.2)',
    'rgba(74,32,96,.2)',
  ]
  const textColors = ['#e07060', '#D4A017', '#5b9bd5', '#5dba8e', '#c890e8']
  const idx = hashCode(nombre) % 5
  return { bg: colors[idx], color: textColors[idx] }
}

function UserSilhouetteIcon() {
  return (
    <svg viewBox="0 0 24 24" className="h-5 w-5" fill="none" aria-hidden="true">
      <circle cx="12" cy="9" r="3.2" stroke="currentColor" strokeWidth="1.6" />
      <path d="M5.5 19c1-3 3.4-4.7 6.5-4.7S17.5 16 18.5 19" stroke="currentColor" strokeWidth="1.6" />
    </svg>
  )
}

export function Avatar({ fotoUrl, nombre, apellido, size = 'md', dashedFallback = false }: AvatarProps) {
  const [imgError, setImgError] = useState(false)
  const fullName = `${nombre} ${apellido}`.trim()
  const initials = `${nombre?.[0] ?? ''}${apellido?.[0] ?? ''}`.toUpperCase()
  const avatarSize = sizeMap[size]
  const color = useMemo(() => getColor(nombre || fullName), [fullName, nombre])

  if (!fotoUrl && !nombre && !apellido) {
    return (
      <div
        className={[
          'inline-flex items-center justify-center rounded-full bg-[var(--accent-soft)] text-[var(--gold-l)]',
          dashedFallback ? 'border border-dashed border-[var(--accent)]' : '',
        ].join(' ')}
        style={{ width: avatarSize, height: avatarSize }}
        title="Foto pendiente"
      >
        <UserSilhouetteIcon />
      </div>
    )
  }

  if (fotoUrl && !imgError) {
    return (
      <img
        src={fotoUrl}
        alt={fullName}
        onError={() => setImgError(true)}
        className="rounded-full object-cover"
        style={{ width: avatarSize, height: avatarSize }}
      />
    )
  }

  if (!nombre && !apellido) {
    return (
      <div
        className={[
          'inline-flex items-center justify-center rounded-full bg-[var(--accent-soft)] text-[var(--gold-l)]',
          dashedFallback ? 'border border-dashed border-[var(--accent)]' : '',
        ].join(' ')}
        style={{ width: avatarSize, height: avatarSize }}
        title="Foto pendiente"
      >
        <UserSilhouetteIcon />
      </div>
    )
  }

  return (
    <div
      className={[
        'inline-flex items-center justify-center rounded-full font-semibold',
        dashedFallback ? 'border border-dashed border-[var(--accent)]' : '',
      ].join(' ')}
      style={{
        width: avatarSize,
        height: avatarSize,
        background: color.bg,
        color: color.color,
        fontSize: avatarSize >= 56 ? 18 : 13,
      }}
      title={fullName}
    >
      {initials || '--'}
    </div>
  )
}
